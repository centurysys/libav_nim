# libav_nim/highlevel/event_recorder.nim
#
# Event clip writer built on EncodedPacketBuffer.
#
# This module provides the high-level event-recording API.  Callers keep pushing
# encoded packets into EncodedPacketBuffer.  EventRecorder can either write a clip
# around an explicit event timestamp, or keep a pending recording window that is
# triggered from the realtime pipeline and finalized after post-roll packets have
# arrived.

import std/[strformat, strutils]

import ../lowlevel/types
import ../lowlevel/error
import ../lowlevel/mp4_writer
import ./encoded_packet_buffer

# =============================================================================
# === Public types
# =============================================================================

type
  EventRecorderState* = enum
    ## Realtime event recording state.
    ersIdle
    ersPending

  EventRecorderOptions* = object
    ## Event clip selection and output settings.
    ##
    ## preUsec/postUsec define the requested time window around an event.
    ## outputPattern is used when writeEventClip() or trigger() is called without
    ## an explicit output path.  The first occurrence of "$1" is replaced by a
    ## 1-based, zero-padded clip index.  If "$1" is not present, "_<index>" is
    ## inserted before the extension.
    preUsec*: int64
    postUsec*: int64
    maxClipUsec*: int64
    outputPattern*: string

  EventClipResult* = object
    ## Result metadata for a written event clip.
    outputPath*: string
    eventUsec*: int64
    requestedStartUsec*: int64
    requestedEndUsec*: int64
    actualStartUsec*: int64
    startIndex*: int
    endIndexExclusive*: int
    packetsWritten*: int
    usedExtradata*: bool
    prependedH264ParameterSets*: bool
    requiredParameterSets*: bool

  EventTriggerResult* = object
    ## Result metadata for a realtime trigger operation.
    started*: bool
    extended*: bool
    eventUsec*: int64
    firstEventUsec*: int64
    recordUntilUsec*: int64
    maxRecordUntilUsec*: int64
    clipped*: bool
    outputPath*: string

  EventRecorder* = ref object
    options*: EventRecorderOptions
    nextIndex*: int
    state*: EventRecorderState
    pendingEventUsec*: int64
    pendingRecordUntilUsec*: int64
    pendingOutputPath*: string

# =============================================================================
# === Construction helpers
# =============================================================================

proc initEventRecorderOptions*(
    preSeconds: int = 10;
    postSeconds: int = 5;
    outputPattern: string = "event_$1.mp4";
    maxClipSeconds: int = 60
  ): EventRecorderOptions =
  ## Create options from second-based pre/post durations.
  if preSeconds < 0:
    raise newException(ValueError, &"Invalid preSeconds: {preSeconds}")
  if postSeconds < 0:
    raise newException(ValueError, &"Invalid postSeconds: {postSeconds}")
  if maxClipSeconds < 0:
    raise newException(ValueError, &"Invalid maxClipSeconds: {maxClipSeconds}")
  if maxClipSeconds > 0 and maxClipSeconds < preSeconds + postSeconds:
    raise newException(
      ValueError,
      &"Invalid maxClipSeconds: {maxClipSeconds}; must be 0 or >= preSeconds + postSeconds"
    )

  result = EventRecorderOptions(
    preUsec: int64(preSeconds) * 1_000_000'i64,
    postUsec: int64(postSeconds) * 1_000_000'i64,
    maxClipUsec: int64(maxClipSeconds) * 1_000_000'i64,
    outputPattern: outputPattern
  )

proc initEventRecorderOptionsUsec*(
    preUsec: int64;
    postUsec: int64;
    outputPattern: string = "event_$1.mp4";
    maxClipUsec: int64 = 60_000_000'i64
  ): EventRecorderOptions =
  ## Create options from microsecond-based pre/post durations.
  if preUsec < 0:
    raise newException(ValueError, &"Invalid preUsec: {preUsec}")
  if postUsec < 0:
    raise newException(ValueError, &"Invalid postUsec: {postUsec}")
  if maxClipUsec < 0:
    raise newException(ValueError, &"Invalid maxClipUsec: {maxClipUsec}")
  if maxClipUsec > 0 and maxClipUsec < preUsec + postUsec:
    raise newException(
      ValueError,
      &"Invalid maxClipUsec: {maxClipUsec}; must be 0 or >= preUsec + postUsec"
    )

  result = EventRecorderOptions(
    preUsec: preUsec,
    postUsec: postUsec,
    maxClipUsec: maxClipUsec,
    outputPattern: outputPattern
  )

proc initEventRecorder*(options: EventRecorderOptions): EventRecorder =
  ## Create an EventRecorder instance.
  ##
  ## EventRecorder is a ref object so it can be passed around cheaply without
  ## copying recorder state.  The recorder itself is not synchronized; keep it
  ## owned by one worker/thread and send trigger requests to that owner when a
  ## multithreaded pipeline is used.
  new(result)
  result.options = options
  result.nextIndex = 1
  result.state = ersIdle
  result.pendingEventUsec = 0
  result.pendingRecordUntilUsec = 0
  result.pendingOutputPath = ""

proc initEventRecorder*(
    preSeconds: int = 10;
    postSeconds: int = 5;
    outputPattern: string = "event_$1.mp4";
    maxClipSeconds: int = 60
  ): EventRecorder =
  result = initEventRecorder(initEventRecorderOptions(preSeconds, postSeconds, outputPattern, maxClipSeconds))

proc newEventRecorder*(options: EventRecorderOptions): EventRecorder =
  ## Alias for initEventRecorder(), for ref-object style call sites.
  result = initEventRecorder(options)

proc newEventRecorder*(
    preSeconds: int = 10;
    postSeconds: int = 5;
    outputPattern: string = "event_$1.mp4";
    maxClipSeconds: int = 60
  ): EventRecorder =
  ## Alias for initEventRecorder(), for ref-object style call sites.
  result = initEventRecorder(preSeconds, postSeconds, outputPattern, maxClipSeconds)

# =============================================================================
# === Output path helpers
# =============================================================================

proc zeroPadIndex(index: int; width: int = 4): string =
  result = $index
  if result.len < width:
    result = repeat('0', width - result.len) & result

proc insertIndexBeforeExtension(path: string; indexText: string): string =
  let dotIndex = path.rfind('.')
  let slashIndex = max(path.rfind('/'), path.rfind('\\'))
  if dotIndex > slashIndex and dotIndex > 0:
    result = path[0 ..< dotIndex] & "_" & indexText & path[dotIndex .. ^1]
  else:
    result = path & "_" & indexText

proc makeEventOutputPath*(recorder: EventRecorder; index: int): string =
  ## Build an event output path from recorder.options.outputPattern.
  let pattern = recorder.options.outputPattern
  let indexText = zeroPadIndex(index)
  if pattern.len == 0:
    return &"event_{indexText}.mp4"
  if pattern.contains("$1"):
    return pattern.replace("$1", indexText)
  result = insertIndexBeforeExtension(pattern, indexText)

# =============================================================================
# === Event window planning
# =============================================================================

proc planEventWindowClip*(
    recorder: EventRecorder;
    buffer: EncodedPacketBuffer;
    streamInfo: EncodedStreamInfo;
    eventUsec: int64;
    requestedEndUsec: int64;
    outputPath: string = ""
  ): FFmpegResult[EventClipResult] =
  ## Select a packet window without writing the output file.
  ##
  ## The start is calculated from eventUsec - preUsec.  requestedEndUsec is
  ## supplied explicitly so realtime recording can extend the clip after repeated
  ## triggers while keeping the pre-roll anchored to the first event.
  if buffer.len == 0:
    return fail[EventClipResult]("planEventWindowClip", "encoded packet ring is empty")

  var requestedStartUsec = eventUsec - recorder.options.preUsec
  if requestedStartUsec < 0:
    requestedStartUsec = 0

  if requestedEndUsec <= requestedStartUsec:
    return fail[EventClipResult](
      "planEventWindowClip",
      &"invalid event window start_us={requestedStartUsec} end_us={requestedEndUsec}"
    )

  let usedExtradata = streamInfo.extradata.len > 0
  let canPrependH264ParameterSets =
    streamInfo.extradata.len == 0 and buffer.hasH264ParameterSetPrefix()
  let hasDecoderHeader = usedExtradata or canPrependH264ParameterSets

  let startIndex = buffer.findStartKeyframeIndex(
    requestedStartUsec,
    requireParameterSets = not hasDecoderHeader
  )
  let endIndex = buffer.findEndPacketIndex(requestedEndUsec)
  if startIndex < 0 or endIndex <= startIndex:
    return fail[EventClipResult](
      "planEventWindowClip",
      &"no packets for event window start_us={requestedStartUsec} end_us={requestedEndUsec}"
    )

  let path = if outputPath.len > 0: outputPath else: recorder.makeEventOutputPath(recorder.nextIndex)

  result = ok(EventClipResult(
    outputPath: path,
    eventUsec: eventUsec,
    requestedStartUsec: requestedStartUsec,
    requestedEndUsec: requestedEndUsec,
    actualStartUsec: buffer.packetTimestampUsecAt(startIndex),
    startIndex: startIndex,
    endIndexExclusive: endIndex,
    packetsWritten: 0,
    usedExtradata: usedExtradata,
    prependedH264ParameterSets: canPrependH264ParameterSets,
    requiredParameterSets: not hasDecoderHeader
  ))

proc planEventClip*(
    recorder: EventRecorder;
    buffer: EncodedPacketBuffer;
    streamInfo: EncodedStreamInfo;
    eventUsec: int64;
    outputPath: string = ""
  ): FFmpegResult[EventClipResult] =
  ## Select a packet window for a single event without writing the output file.
  result = recorder.planEventWindowClip(
    buffer,
    streamInfo,
    eventUsec,
    eventUsec + recorder.options.postUsec,
    outputPath
  )

# =============================================================================
# === Realtime trigger state
# =============================================================================

proc clearPending*(recorder: EventRecorder) =
  ## Clear any pending realtime event recording window.
  recorder.state = ersIdle
  recorder.pendingEventUsec = 0
  recorder.pendingRecordUntilUsec = 0
  recorder.pendingOutputPath = ""

proc hasPendingEvent*(recorder: EventRecorder): bool =
  result = recorder.state == ersPending

proc clipStartUsecFor*(recorder: EventRecorder; eventUsec: int64): int64 =
  ## Return the requested clip start timestamp for eventUsec, clamped to zero.
  result = eventUsec - recorder.options.preUsec
  if result < 0:
    result = 0

proc maxRecordUntilUsecFor*(recorder: EventRecorder; firstEventUsec: int64): int64 =
  ## Return the maximum allowed end timestamp for the clip anchored at firstEventUsec.
  ## A maxClipUsec of 0 means unlimited.
  let startUsec = recorder.clipStartUsecFor(firstEventUsec)
  if recorder.options.maxClipUsec <= 0:
    return high(int64)
  result = startUsec + recorder.options.maxClipUsec

proc trigger*(
    recorder: EventRecorder;
    eventUsec: int64;
    outputPath: string = ""
  ): EventTriggerResult =
  ## Start or extend a pending realtime event recording window.
  ##
  ## If idle, the first event anchors the pre-roll and output path.  If another
  ## trigger arrives before finalization, the clip end is extended to
  ## eventUsec + postUsec while preserving the first event timestamp.
  let desiredUntilUsec = eventUsec + recorder.options.postUsec

  if recorder.state == ersIdle:
    recorder.state = ersPending
    recorder.pendingEventUsec = eventUsec
    let maxUntilUsec = recorder.maxRecordUntilUsecFor(recorder.pendingEventUsec)
    recorder.pendingRecordUntilUsec = min(desiredUntilUsec, maxUntilUsec)
    recorder.pendingOutputPath = if outputPath.len > 0: outputPath else: recorder.makeEventOutputPath(recorder.nextIndex)

    result = EventTriggerResult(
      started: true,
      extended: false,
      eventUsec: eventUsec,
      firstEventUsec: recorder.pendingEventUsec,
      recordUntilUsec: recorder.pendingRecordUntilUsec,
      maxRecordUntilUsec: maxUntilUsec,
      clipped: desiredUntilUsec > maxUntilUsec,
      outputPath: recorder.pendingOutputPath
    )
  else:
    let oldUntil = recorder.pendingRecordUntilUsec
    let maxUntilUsec = recorder.maxRecordUntilUsecFor(recorder.pendingEventUsec)
    let cappedUntilUsec = min(desiredUntilUsec, maxUntilUsec)
    if cappedUntilUsec > recorder.pendingRecordUntilUsec:
      recorder.pendingRecordUntilUsec = cappedUntilUsec

    result = EventTriggerResult(
      started: false,
      extended: recorder.pendingRecordUntilUsec > oldUntil,
      eventUsec: eventUsec,
      firstEventUsec: recorder.pendingEventUsec,
      recordUntilUsec: recorder.pendingRecordUntilUsec,
      maxRecordUntilUsec: maxUntilUsec,
      clipped: desiredUntilUsec > maxUntilUsec,
      outputPath: recorder.pendingOutputPath
    )

proc readyToFinalize*(recorder: EventRecorder; newestPacketUsec: int64): bool =
  ## Return true when a pending event has received enough post-roll packets.
  ##
  ## The argument should be the timestamp of the newest encoded packet retained
  ## in the ring, not the timestamp of the frame currently submitted to the
  ## encoder.  Hardware encoders may emit packets with a small delay, so using
  ## frame timestamps can finalize one packet too early.
  result = recorder.state == ersPending and newestPacketUsec >= recorder.pendingRecordUntilUsec

proc readyToFinalize*(recorder: EventRecorder; buffer: EncodedPacketBuffer): bool =
  ## Return true when the packet ring contains packets up to the pending
  ## post-roll end timestamp.
  ##
  ## This is the preferred realtime check because it is based on encoded packet
  ## timestamps actually available for writing.
  if recorder.state != ersPending or buffer.len == 0:
    return false

  result = buffer.newestTimestampUsec() >= recorder.pendingRecordUntilUsec

# =============================================================================
# === Clip writing
# =============================================================================

proc writePlannedClip(
    recorder: EventRecorder;
    buffer: EncodedPacketBuffer;
    streamInfo: EncodedStreamInfo;
    clip: var EventClipResult
  ): FFmpegResult[EventClipResult] =
  var writerRet = openMp4VideoWriter(clip.outputPath, streamInfo)
  if writerRet.isErr:
    return err(writerRet.error)

  var writer = writerRet.get()
  try:
    let writtenRet = writer.writeEncodedPacketBufferRange(
      buffer,
      clip.startIndex,
      clip.endIndexExclusive,
      rebaseTimestamps = true,
      prependH264ParameterSets = clip.prependedH264ParameterSets
    )
    if writtenRet.isErr:
      return err(writtenRet.error)

    clip.packetsWritten = writtenRet.get()

    let finishRet = writer.finish()
    if finishRet.isErr:
      return err(finishRet.error)
  finally:
    writer.close()

  inc recorder.nextIndex
  result = ok(clip)

proc writeEventClip*(
    recorder: EventRecorder;
    buffer: EncodedPacketBuffer;
    streamInfo: EncodedStreamInfo;
    eventUsec: int64;
    outputPath: string = ""
  ): FFmpegResult[EventClipResult] =
  ## Write one event clip around eventUsec from already-encoded packets.
  ##
  ## This does not decode or re-encode video.  It opens a new MP4 writer from the
  ## encoded stream information, selects a keyframe-bounded packet range, and
  ## writes copied packets from the ring buffer.  When encoder extradata is not
  ## available, a captured H.264 SPS/PPS prefix is prepended to the first packet
  ## when possible.
  let plannedRet = recorder.planEventClip(buffer, streamInfo, eventUsec, outputPath)
  if plannedRet.isErr:
    return err(plannedRet.error)

  var clip = plannedRet.get()
  result = recorder.writePlannedClip(buffer, streamInfo, clip)

proc writePendingClip*(
    recorder: EventRecorder;
    buffer: EncodedPacketBuffer;
    streamInfo: EncodedStreamInfo
  ): FFmpegResult[EventClipResult] =
  ## Finalize and write the currently pending realtime event clip.
  if recorder.state != ersPending:
    return fail[EventClipResult]("writePendingClip", "no pending event clip")

  let plannedRet = recorder.planEventWindowClip(
    buffer,
    streamInfo,
    recorder.pendingEventUsec,
    recorder.pendingRecordUntilUsec,
    recorder.pendingOutputPath
  )
  if plannedRet.isErr:
    return err(plannedRet.error)

  var clip = plannedRet.get()
  let writeRet = recorder.writePlannedClip(buffer, streamInfo, clip)
  if writeRet.isErr:
    return err(writeRet.error)

  recorder.clearPending()
  result = writeRet
