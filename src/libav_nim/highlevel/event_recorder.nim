# libav_nim/highlevel/event_recorder.nim
#
# Event clip writer built on EncodedPacketBuffer.
#
# This module is the first high-level event-recording API.  It keeps trigger
# handling separate from the decode/overlay/encode pipeline: callers push encoded
# packets into EncodedPacketBuffer, then ask EventRecorder to write a clip around
# an event timestamp.

import std/[strformat, strutils]

import ../lowlevel/types
import ../lowlevel/error
import ../lowlevel/mp4_writer
import ./encoded_packet_buffer

# =============================================================================
# === Public types
# =============================================================================

type
  EventRecorderOptions* = object
    ## Event clip selection and output settings.
    ##
    ## preUsec/postUsec define the requested time window around an event.
    ## outputPattern is used when writeEventClip() is called without an explicit
    ## output path.  The first occurrence of "$1" is replaced by a 1-based,
    ## zero-padded clip index.  If "$1" is not present, "_<index>" is inserted
    ## before the extension.
    preUsec*: int64
    postUsec*: int64
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

  EventRecorder* = object
    options*: EventRecorderOptions
    nextIndex*: int

# =============================================================================
# === Construction helpers
# =============================================================================

proc initEventRecorderOptions*(
    preSeconds: int = 10;
    postSeconds: int = 5;
    outputPattern: string = "event_$1.mp4"
  ): EventRecorderOptions =
  ## Create options from second-based pre/post durations.
  if preSeconds < 0:
    raise newException(ValueError, &"Invalid preSeconds: {preSeconds}")
  if postSeconds < 0:
    raise newException(ValueError, &"Invalid postSeconds: {postSeconds}")

  result = EventRecorderOptions(
    preUsec: int64(preSeconds) * 1_000_000'i64,
    postUsec: int64(postSeconds) * 1_000_000'i64,
    outputPattern: outputPattern
  )

proc initEventRecorderOptionsUsec*(
    preUsec: int64;
    postUsec: int64;
    outputPattern: string = "event_$1.mp4"
  ): EventRecorderOptions =
  ## Create options from microsecond-based pre/post durations.
  if preUsec < 0:
    raise newException(ValueError, &"Invalid preUsec: {preUsec}")
  if postUsec < 0:
    raise newException(ValueError, &"Invalid postUsec: {postUsec}")

  result = EventRecorderOptions(
    preUsec: preUsec,
    postUsec: postUsec,
    outputPattern: outputPattern
  )

proc initEventRecorder*(options: EventRecorderOptions): EventRecorder =
  result.options = options
  result.nextIndex = 1

proc initEventRecorder*(
    preSeconds: int = 10;
    postSeconds: int = 5;
    outputPattern: string = "event_$1.mp4"
  ): EventRecorder =
  result = initEventRecorder(initEventRecorderOptions(preSeconds, postSeconds, outputPattern))

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

proc planEventClip*(
    recorder: EventRecorder;
    buffer: EncodedPacketBuffer;
    streamInfo: EncodedStreamInfo;
    eventUsec: int64;
    outputPath: string = ""
  ): FFmpegResult[EventClipResult] =
  ## Select a packet window for an event without writing the output file.
  if buffer.len == 0:
    return fail[EventClipResult]("planEventClip", "encoded packet ring is empty")

  var requestedStartUsec = eventUsec - recorder.options.preUsec
  if requestedStartUsec < 0:
    requestedStartUsec = 0
  let requestedEndUsec = eventUsec + recorder.options.postUsec

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
      "planEventClip",
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

# =============================================================================
# === Clip writing
# =============================================================================

proc writeEventClip*(
    recorder: var EventRecorder;
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
