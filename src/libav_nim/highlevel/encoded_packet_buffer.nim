# libav_nim/highlevel/encoded_packet_buffer.nim
#
# Owned encoded packet storage for event-recording pipelines.
#
# FFmpeg AVPacket memory is borrowed and short-lived.  Event recording needs to
# keep already-encoded packets for several seconds, so this module copies packet
# payloads into Nim-owned memory and stores them in a time/size bounded deque.

import std/[deques, strformat]

import ../lowlevel/types
import ../lowlevel/error
import ../lowlevel/mp4_writer

# =============================================================================
# === Owned encoded packet
# =============================================================================

type
  OwnedEncodedPacket* = object
    ## Nim-owned copy of an encoded video packet.
    ##
    ## data is independent from FFmpeg's AVPacket lifetime and can be stored in a
    ## ring buffer. timestampUsec is the application timeline used for trimming
    ## and event-window selection.
    data*: seq[byte]
    pts*: int64
    dts*: int64
    duration*: int64
    timeBase*: Rational
    isKeyframe*: bool
    hasH264Sps*: bool
    hasH264Pps*: bool
    timestampUsec*: int64

  EncodedPacketBuffer* = ref object
    ## Time/size bounded packet deque.
    ##
    ## This is a stateful high-level component. It is a ref object so callers can
    ## pass the buffer around cheaply without copying retained packet state. The
    ## buffer is not internally synchronized; keep one instance owned by a single
    ## pipeline/worker thread.
    ##
    ## After trimming, the first retained packet is kept on a keyframe boundary
    ## whenever possible. This makes later MP4 event clip generation simpler.
    packets*: Deque[OwnedEncodedPacket]
    maxDurationUsec*: int64
    maxBytes*: int64
    totalBytes*: int64
    h264ParameterSetPrefix*: seq[byte]

# =============================================================================
# === Packet copy helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- containsH264IdrNal
# -----------------------------------------------------------------------------

proc containsH264NalType*(data: openArray[byte]; targetNalType: int): bool =
  ## Return true when data appears to contain the requested H.264 NAL type.
  ##
  ## This supports both Annex B start-code packets and AVCC-style 4-byte
  ## length-prefixed packets. MP4 event clips should preferably start from a
  ## keyframe packet that also carries SPS/PPS, because some hardware encoders do
  ## not provide enough extradata for a mid-stream clip to decode otherwise.

  # Annex B: 00 00 01 xx or 00 00 00 01 xx
  var i = 0
  while i + 3 < data.len:
    if data[i] == 0'u8 and data[i + 1] == 0'u8:
      var nalIndex = -1
      if data[i + 2] == 1'u8:
        nalIndex = i + 3
      elif i + 4 < data.len and data[i + 2] == 0'u8 and data[i + 3] == 1'u8:
        nalIndex = i + 4

      if nalIndex >= 0 and nalIndex < data.len:
        let nalType = int(data[nalIndex]) and 0x1f
        if nalType == targetNalType:
          return true
        i = nalIndex + 1
        continue

    inc i

  # AVCC-style 4-byte length prefixed NAL units.
  var pos = 0
  while pos + 4 < data.len:
    let nalLen =
      (int(data[pos]) shl 24) or
      (int(data[pos + 1]) shl 16) or
      (int(data[pos + 2]) shl 8) or
      int(data[pos + 3])

    if nalLen <= 0 or pos + 4 + nalLen > data.len:
      break

    let nalType = int(data[pos + 4]) and 0x1f
    if nalType == targetNalType:
      return true

    pos += 4 + nalLen

  result = false

# -----------------------------------------------------------------------------
# --- containsH264IdrNal
# -----------------------------------------------------------------------------

proc containsH264IdrNal*(data: openArray[byte]): bool =
  ## Return true when data appears to contain an H.264 IDR NAL unit.
  result = data.containsH264NalType(5)

# -----------------------------------------------------------------------------
# --- containsH264SpsPps
# -----------------------------------------------------------------------------

proc containsH264SpsPps*(data: openArray[byte]): tuple[hasSps: bool, hasPps: bool] =
  ## Return whether data appears to contain H.264 SPS/PPS NAL units.
  result.hasSps = data.containsH264NalType(7)
  result.hasPps = data.containsH264NalType(8)

# -----------------------------------------------------------------------------
# --- appendRange
# -----------------------------------------------------------------------------

proc appendRange(dest: var seq[byte]; src: openArray[byte]; first: int; lastExclusive: int) =
  if first < 0 or lastExclusive <= first or first >= src.len:
    return

  let boundedLast = min(lastExclusive, src.len)
  for i in first ..< boundedLast:
    dest.add(src[i])

# -----------------------------------------------------------------------------
# --- startCodeLenAt
# -----------------------------------------------------------------------------

proc startCodeLenAt(data: openArray[byte]; pos: int): int =
  ## Return Annex B start-code length at pos, or 0 when no start code exists.
  if pos < 0 or pos + 3 > data.len:
    return 0

  if pos + 3 <= data.len and
      data[pos] == 0'u8 and data[pos + 1] == 0'u8 and data[pos + 2] == 1'u8:
    return 3

  if pos + 4 <= data.len and
      data[pos] == 0'u8 and data[pos + 1] == 0'u8 and
      data[pos + 2] == 0'u8 and data[pos + 3] == 1'u8:
    return 4

  result = 0

# -----------------------------------------------------------------------------
# --- findAnnexBStartCode
# -----------------------------------------------------------------------------

proc findAnnexBStartCode(data: openArray[byte]; startPos: int): int =
  ## Return the next Annex B start-code index, or -1.
  var i = max(startPos, 0)
  while i + 3 <= data.len:
    if data.startCodeLenAt(i) > 0:
      return i
    inc i
  result = -1

# -----------------------------------------------------------------------------
# --- extractH264ParameterSetPrefix
# -----------------------------------------------------------------------------

proc extractH264ParameterSetPrefix*(data: openArray[byte]): seq[byte] =
  ## Extract H.264 SPS/PPS NAL units as a prefix byte sequence.
  ##
  ## The returned byte sequence keeps the original packet framing style:
  ## Annex B start-code framed input returns Annex B SPS/PPS NALs, while AVCC
  ## 4-byte length-prefixed input returns length-prefixed SPS/PPS NALs. The
  ## prefix is intended to be prepended to a later IDR packet when a mid-stream
  ## MP4 event clip needs decoder configuration but the encoder did not expose
  ## codec extradata.

  # Annex B: preserve each SPS/PPS NAL with its start code.
  var pos = data.findAnnexBStartCode(0)
  while pos >= 0:
    let scLen = data.startCodeLenAt(pos)
    let nalStart = pos + scLen
    if nalStart >= data.len:
      break

    let nextStart = data.findAnnexBStartCode(nalStart)
    let nalEnd = if nextStart >= 0: nextStart else: data.len
    let nalType = int(data[nalStart]) and 0x1f
    if nalType == 7 or nalType == 8:
      result.appendRange(data, pos, nalEnd)

    if nextStart < 0:
      break
    pos = nextStart

  if result.len > 0:
    return

  # AVCC-style 4-byte length-prefixed NAL units. Preserve the length prefixes.
  pos = 0
  while pos + 4 < data.len:
    let nalLen =
      (int(data[pos]) shl 24) or
      (int(data[pos + 1]) shl 16) or
      (int(data[pos + 2]) shl 8) or
      int(data[pos + 3])

    if nalLen <= 0 or pos + 4 + nalLen > data.len:
      break

    let nalStart = pos + 4
    let nalEnd = nalStart + nalLen
    let nalType = int(data[nalStart]) and 0x1f
    if nalType == 7 or nalType == 8:
      result.appendRange(data, pos, nalEnd)

    pos = nalEnd

# -----------------------------------------------------------------------------
# --- copyEncodedPacket
# -----------------------------------------------------------------------------

proc copyEncodedPacket*(view: EncodedPacketView; timestampUsec: int64): OwnedEncodedPacket =
  ## Copy a borrowed EncodedPacketView into Nim-owned memory.
  if view.size < 0:
    raise newException(ValueError, &"Invalid encoded packet size: {view.size}")

  result = OwnedEncodedPacket(
    data: newSeq[byte](view.size),
    pts: view.pts,
    dts: view.dts,
    duration: view.duration,
    timeBase: view.timeBase,
    isKeyframe: view.isKeyframe,
    timestampUsec: timestampUsec
  )

  if view.size > 0:
    if view.data.isNil:
      raise newException(ValueError, "Encoded packet has nil data")
    copyMem(result.data[0].addr, view.data, view.size)

  let h264ParamSets = result.data.containsH264SpsPps()
  result.hasH264Sps = h264ParamSets.hasSps
  result.hasH264Pps = h264ParamSets.hasPps

  if not result.isKeyframe and result.data.containsH264IdrNal():
    result.isKeyframe = true

# =============================================================================
# === Buffer construction / state
# =============================================================================

# -----------------------------------------------------------------------------
# --- newEncodedPacketBuffer / initEncodedPacketBuffer
# -----------------------------------------------------------------------------

proc newEncodedPacketBuffer*(maxDurationUsec: int64; maxBytes: int64 = 0): EncodedPacketBuffer =
  ## Create a packet buffer.
  ##
  ## maxDurationUsec <= 0 disables time-based trimming.
  ## maxBytes <= 0 disables byte-size trimming.
  result = EncodedPacketBuffer(
    maxDurationUsec: maxDurationUsec,
    maxBytes: maxBytes,
    totalBytes: 0,
    h264ParameterSetPrefix: @[],
    packets: initDeque[OwnedEncodedPacket]()
  )

proc initEncodedPacketBuffer*(maxDurationUsec: int64; maxBytes: int64 = 0): EncodedPacketBuffer =
  ## Compatibility alias for newEncodedPacketBuffer().
  result = newEncodedPacketBuffer(maxDurationUsec, maxBytes)

# -----------------------------------------------------------------------------
# --- clear
# -----------------------------------------------------------------------------

proc clear*(buf: EncodedPacketBuffer) =
  buf.packets.clear()
  buf.totalBytes = 0
  buf.h264ParameterSetPrefix = @[]

# -----------------------------------------------------------------------------
# --- len
# -----------------------------------------------------------------------------

proc len*(buf: EncodedPacketBuffer): int =
  result = buf.packets.len

# -----------------------------------------------------------------------------
# --- isEmpty
# -----------------------------------------------------------------------------

proc isEmpty*(buf: EncodedPacketBuffer): bool =
  result = buf.packets.len == 0

# -----------------------------------------------------------------------------
# --- oldestTimestampUsec
# -----------------------------------------------------------------------------

proc oldestTimestampUsec*(buf: EncodedPacketBuffer): int64 =
  if buf.packets.len == 0:
    result = 0
  else:
    result = buf.packets.peekFirst().timestampUsec

# -----------------------------------------------------------------------------
# --- newestTimestampUsec
# -----------------------------------------------------------------------------

proc newestTimestampUsec*(buf: EncodedPacketBuffer): int64 =
  if buf.packets.len == 0:
    result = 0
  else:
    result = buf.packets.peekLast().timestampUsec

# -----------------------------------------------------------------------------
# --- durationUsec
# -----------------------------------------------------------------------------

proc durationUsec*(buf: EncodedPacketBuffer): int64 =
  if buf.packets.len <= 1:
    result = 0
  else:
    result = buf.newestTimestampUsec() - buf.oldestTimestampUsec()

# -----------------------------------------------------------------------------
# --- keyframeCount
# -----------------------------------------------------------------------------

proc keyframeCount*(buf: EncodedPacketBuffer): int =
  result = 0
  for pkt in buf.packets:
    if pkt.isKeyframe:
      inc result

# -----------------------------------------------------------------------------
# --- h264ParameterSetPacketCount
# -----------------------------------------------------------------------------

proc h264ParameterSetPacketCount*(buf: EncodedPacketBuffer): int =
  result = 0
  for pkt in buf.packets:
    if pkt.hasH264Sps and pkt.hasH264Pps:
      inc result

# -----------------------------------------------------------------------------
# --- hasH264ParameterSetPrefix
# -----------------------------------------------------------------------------

proc hasH264ParameterSetPrefix*(buf: EncodedPacketBuffer): bool =
  ## Return true when SPS/PPS bytes were captured from the stream.
  result = buf.h264ParameterSetPrefix.len > 0

# =============================================================================
# === Trimming
# =============================================================================

# -----------------------------------------------------------------------------
# --- popOldest
# -----------------------------------------------------------------------------

proc popOldest(buf: EncodedPacketBuffer) =
  let old = buf.packets.popFirst()
  buf.totalBytes -= old.data.len
  if buf.totalBytes < 0:
    buf.totalBytes = 0

# -----------------------------------------------------------------------------
# --- hasKeyframe
# -----------------------------------------------------------------------------

proc hasKeyframe*(buf: EncodedPacketBuffer): bool =
  ## Return true when the current retained window contains at least one keyframe.
  for pkt in buf.packets:
    if pkt.isKeyframe:
      return true
  result = false

# -----------------------------------------------------------------------------
# --- trimLeadingNonKeyframes
# -----------------------------------------------------------------------------

proc trimLeadingNonKeyframes*(buf: EncodedPacketBuffer) =
  ## Drop leading non-keyframes once a keyframe exists in the retained window.
  ##
  ## If no keyframe is present yet, keep the packets for diagnostics and for
  ## encoders that do not mark keyframes correctly. Once a keyframe arrives,
  ## earlier non-decodable packets are removed and the front is aligned.
  if not buf.hasKeyframe():
    return

  while buf.packets.len > 0 and not buf.packets.peekFirst().isKeyframe:
    buf.popOldest()

# -----------------------------------------------------------------------------
# --- trim
# -----------------------------------------------------------------------------

proc trim*(buf: EncodedPacketBuffer; nowUsec: int64) =
  ## Apply time/byte limits and then keep the front aligned to a keyframe.
  let oldestAllowed = nowUsec - buf.maxDurationUsec

  while buf.packets.len > 0:
    let old = buf.packets.peekFirst()
    let tooOld = buf.maxDurationUsec > 0 and old.timestampUsec < oldestAllowed
    let tooLarge = buf.maxBytes > 0 and buf.totalBytes > buf.maxBytes

    if not tooOld and not tooLarge:
      break

    buf.popOldest()

  buf.trimLeadingNonKeyframes()

# -----------------------------------------------------------------------------
# --- push
# -----------------------------------------------------------------------------

proc push*(buf: EncodedPacketBuffer; pkt: sink OwnedEncodedPacket) =
  ## Add one packet and trim using the packet timestamp as the current time.
  let nowUsec = pkt.timestampUsec
  if buf.h264ParameterSetPrefix.len == 0:
    let prefix = pkt.data.extractH264ParameterSetPrefix()
    if prefix.len > 0:
      buf.h264ParameterSetPrefix = prefix

  buf.totalBytes += pkt.data.len
  buf.packets.addLast(pkt)
  buf.trim(nowUsec)

# =============================================================================
# === Event-window helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- findStartKeyframeIndex
# -----------------------------------------------------------------------------

proc findStartKeyframeIndex*(
    buf: EncodedPacketBuffer;
    desiredStartUsec: int64;
    requireParameterSets: bool = true
  ): int =
  ## Find a safe event clip start at or before desiredStartUsec.
  ##
  ## When requireParameterSets is true, prefer the last keyframe that also carries
  ## H.264 SPS/PPS at or before the requested start. This is the safe fallback for
  ## writers that do not have codec extradata. When a caller opens the writer from
  ## copied extradata, requireParameterSets can be false so an IDR-only keyframe
  ## near the requested start can be used.
  ##
  ## Returns 0 when the buffer has packets but no earlier keyframe was found.
  ## Returns -1 when the buffer is empty.
  if buf.packets.len == 0:
    return -1

  var fallbackKeyframe = -1
  var selfContainedKeyframe = -1
  var i = 0
  for pkt in buf.packets:
    if pkt.timestampUsec <= desiredStartUsec and pkt.isKeyframe:
      fallbackKeyframe = i
      if pkt.hasH264Sps and pkt.hasH264Pps:
        selfContainedKeyframe = i
    inc i

  if requireParameterSets and selfContainedKeyframe >= 0:
    result = selfContainedKeyframe
  elif requireParameterSets and fallbackKeyframe >= 0 and selfContainedKeyframe < 0:
    result = fallbackKeyframe
  elif fallbackKeyframe >= 0:
    result = fallbackKeyframe
  else:
    result = 0

# -----------------------------------------------------------------------------
# --- packetsFrom
# -----------------------------------------------------------------------------

proc packetsFrom*(buf: EncodedPacketBuffer; startIndex: int): seq[OwnedEncodedPacket] =
  ## Return retained packets starting from startIndex.
  ##
  ## This returns packet objects with Nim-owned payloads. It is intended for the
  ## first event-recorder implementation where clarity is more important than
  ## avoiding small seq header copies.
  if startIndex < 0 or startIndex >= buf.packets.len:
    return @[]

  result = newSeq[OwnedEncodedPacket]()
  var i = 0
  for pkt in buf.packets:
    if i >= startIndex:
      result.add(pkt)
    inc i

# -----------------------------------------------------------------------------
# --- findEndPacketIndex
# -----------------------------------------------------------------------------

proc findEndPacketIndex*(buf: EncodedPacketBuffer; desiredEndUsec: int64): int =
  ## Find the exclusive end index for packets at or before desiredEndUsec.
  ##
  ## Returns 0 when the buffer is empty. The returned value is suitable as an
  ## exclusive end index for writeEncodedPacketBufferRange().
  result = 0
  var i = 0
  for pkt in buf.packets:
    if pkt.timestampUsec <= desiredEndUsec:
      result = i + 1
    inc i

# -----------------------------------------------------------------------------
# --- packetTimestampUsecAt
# -----------------------------------------------------------------------------

proc packetTimestampUsecAt*(buf: EncodedPacketBuffer; index: int): int64 =
  ## Return packet timestamp at index, or 0 for an invalid index.
  if index < 0 or index >= buf.packets.len:
    return 0

  var i = 0
  for pkt in buf.packets:
    if i == index:
      return pkt.timestampUsec
    inc i

  result = 0

# -----------------------------------------------------------------------------
# --- iterPacketsFrom
# -----------------------------------------------------------------------------

iterator iterPacketsFrom*(buf: EncodedPacketBuffer; startIndex: int): OwnedEncodedPacket =
  var i = 0
  for pkt in buf.packets:
    if i >= startIndex:
      yield pkt
    inc i

# -----------------------------------------------------------------------------
# --- statsText
# -----------------------------------------------------------------------------

proc statsText*(buf: EncodedPacketBuffer): string =
  result = &"packets={buf.len} bytes={buf.totalBytes} duration_us={buf.durationUsec} keyframes={buf.keyframeCount} h264_spspps={buf.h264ParameterSetPacketCount} h264_ps_prefix={buf.h264ParameterSetPrefix.len}"
  if buf.packets.len > 0:
    result.add(&" oldest_us={buf.oldestTimestampUsec} newest_us={buf.newestTimestampUsec}")
# =============================================================================
# === MP4 writer helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- toEncodedPacketView
# -----------------------------------------------------------------------------

proc toEncodedPacketView*(
    pkt: OwnedEncodedPacket;
    ptsOffset: int64 = 0;
    dtsOffset: int64 = 0
  ): EncodedPacketView =
  ## Create a borrowed view over Nim-owned packet data.
  ##
  ## The returned view is valid only while pkt.data is alive and not reallocated.
  ## ptsOffset/dtsOffset are subtracted before writing, which is useful when a
  ## clip starts from the middle of a longer packet timeline.
  if pkt.data.len <= 0:
    raise newException(ValueError, "Owned encoded packet has no payload")

  result = EncodedPacketView(
    data: cast[pointer](pkt.data[0].unsafeAddr),
    size: pkt.data.len,
    pts: pkt.pts - ptsOffset,
    dts: pkt.dts - dtsOffset,
    duration: pkt.duration,
    isKeyframe: pkt.isKeyframe,
    timeBase: pkt.timeBase
  )

# -----------------------------------------------------------------------------
# --- withH264ParameterSetPrefix
# -----------------------------------------------------------------------------

proc withH264ParameterSetPrefix*(pkt: OwnedEncodedPacket; prefix: openArray[byte]): OwnedEncodedPacket =
  ## Return pkt with SPS/PPS prefix prepended when pkt is not already self-contained.
  ##
  ## This is a pragmatic fallback for hardware encoders that put SPS/PPS only in
  ## the first packet and expose no codec extradata. The event clip can then
  ## start from a later IDR packet while still carrying decoder configuration in
  ## its first sample.
  result = pkt
  if prefix.len == 0 or (pkt.hasH264Sps and pkt.hasH264Pps):
    return

  result.data = newSeq[byte](prefix.len + pkt.data.len)
  for i in 0 ..< prefix.len:
    result.data[i] = prefix[i]
  for i in 0 ..< pkt.data.len:
    result.data[prefix.len + i] = pkt.data[i]

  let h264ParamSets = result.data.containsH264SpsPps()
  result.hasH264Sps = h264ParamSets.hasSps
  result.hasH264Pps = h264ParamSets.hasPps
  if not result.isKeyframe and result.data.containsH264IdrNal():
    result.isKeyframe = true

# -----------------------------------------------------------------------------
# --- writeOwnedEncodedPacket
# -----------------------------------------------------------------------------

proc writeOwnedEncodedPacket*(
    writer: Mp4VideoWriter;
    pkt: OwnedEncodedPacket;
    ptsOffset: int64 = 0;
    dtsOffset: int64 = 0
  ): FFmpegResult[void] =
  ## Write one Nim-owned encoded packet to an MP4 writer.
  let view = pkt.toEncodedPacketView(ptsOffset, dtsOffset)
  result = writer.writePacket(view)

# -----------------------------------------------------------------------------
# --- writeEncodedPacketBuffer
# -----------------------------------------------------------------------------

proc writeEncodedPacketBufferRange*(
    writer: Mp4VideoWriter;
    buf: EncodedPacketBuffer;
    startIndex: int;
    endIndexExclusive: int;
    rebaseTimestamps: bool = true;
    prependH264ParameterSets: bool = false
  ): FFmpegResult[int] =
  ## Write retained packets in [startIndex, endIndexExclusive) to writer.
  ##
  ## When rebaseTimestamps is true, the first written packet starts at pts/dts 0.
  ## When prependH264ParameterSets is true, the first written packet is prefixed
  ## with captured SPS/PPS bytes if it does not already contain them.
  ## Returns the number of packets written.
  if startIndex < 0 or startIndex >= buf.packets.len:
    result = ok(0)
    return

  let boundedEnd = min(endIndexExclusive, buf.packets.len)
  if boundedEnd <= startIndex:
    result = ok(0)
    return

  var ptsOffset = 0'i64
  var dtsOffset = 0'i64
  if rebaseTimestamps:
    var found = false
    var i = 0
    for pkt in buf.packets:
      if i == startIndex:
        ptsOffset = pkt.pts
        dtsOffset = pkt.dts
        found = true
        break
      inc i
    if not found:
      result = ok(0)
      return

  var count = 0
  var i = 0
  for pkt in buf.packets:
    if i >= startIndex and i < boundedEnd:
      var packetToWrite = pkt
      if i == startIndex and prependH264ParameterSets:
        packetToWrite = pkt.withH264ParameterSetPrefix(buf.h264ParameterSetPrefix)

      let writeRet = writer.writeOwnedEncodedPacket(packetToWrite, ptsOffset, dtsOffset)
      if writeRet.isErr:
        result = err(writeRet.error)
        return
      inc count
    inc i

  result = ok(count)

# -----------------------------------------------------------------------------
# --- writeEncodedPacketBuffer
# -----------------------------------------------------------------------------

proc writeEncodedPacketBuffer*(
    writer: Mp4VideoWriter;
    buf: EncodedPacketBuffer;
    startIndex: int = 0;
    rebaseTimestamps: bool = true
  ): FFmpegResult[int] =
  ## Write retained packets from startIndex to writer.
  result = writer.writeEncodedPacketBufferRange(
    buf,
    startIndex,
    buf.packets.len,
    rebaseTimestamps
  )

