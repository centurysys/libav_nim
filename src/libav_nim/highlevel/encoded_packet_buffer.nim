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
    timestampUsec*: int64

  EncodedPacketBuffer* = object
    ## Time/size bounded packet deque.
    ##
    ## After trimming, the first retained packet is kept on a keyframe boundary
    ## whenever possible. This makes later MP4 event clip generation simpler.
    packets*: Deque[OwnedEncodedPacket]
    maxDurationUsec*: int64
    maxBytes*: int64
    totalBytes*: int64

# =============================================================================
# === Packet copy helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- containsH264IdrNal
# -----------------------------------------------------------------------------

proc containsH264IdrNal*(data: openArray[byte]): bool =
  ## Return true when data appears to contain an H.264 IDR NAL unit.
  ##
  ## Some hardware encoders do not reliably propagate AV_PKT_FLAG_KEY on the
  ## packet wrapper. Event recording still needs a keyframe marker, so this
  ## provides a conservative H.264 payload fallback for both Annex B start-code
  ## packets and 4-byte length-prefixed packets.

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
        if nalType == 5:
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
    if nalType == 5:
      return true

    pos += 4 + nalLen

  result = false

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

  if not result.isKeyframe and result.data.containsH264IdrNal():
    result.isKeyframe = true

# =============================================================================
# === Buffer construction / state
# =============================================================================

# -----------------------------------------------------------------------------
# --- initEncodedPacketBuffer
# -----------------------------------------------------------------------------

proc initEncodedPacketBuffer*(maxDurationUsec: int64; maxBytes: int64 = 0): EncodedPacketBuffer =
  ## Create a packet buffer.
  ##
  ## maxDurationUsec <= 0 disables time-based trimming.
  ## maxBytes <= 0 disables byte-size trimming.
  result.maxDurationUsec = maxDurationUsec
  result.maxBytes = maxBytes
  result.totalBytes = 0
  result.packets = initDeque[OwnedEncodedPacket]()

# -----------------------------------------------------------------------------
# --- clear
# -----------------------------------------------------------------------------

proc clear*(buf: var EncodedPacketBuffer) =
  buf.packets.clear()
  buf.totalBytes = 0

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

# =============================================================================
# === Trimming
# =============================================================================

# -----------------------------------------------------------------------------
# --- popOldest
# -----------------------------------------------------------------------------

proc popOldest(buf: var EncodedPacketBuffer) =
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

proc trimLeadingNonKeyframes*(buf: var EncodedPacketBuffer) =
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

proc trim*(buf: var EncodedPacketBuffer; nowUsec: int64) =
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

proc push*(buf: var EncodedPacketBuffer; pkt: sink OwnedEncodedPacket) =
  ## Add one packet and trim using the packet timestamp as the current time.
  let nowUsec = pkt.timestampUsec
  buf.totalBytes += pkt.data.len
  buf.packets.addLast(pkt)
  buf.trim(nowUsec)

# =============================================================================
# === Event-window helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- findStartKeyframeIndex
# -----------------------------------------------------------------------------

proc findStartKeyframeIndex*(buf: EncodedPacketBuffer; desiredStartUsec: int64): int =
  ## Find the last keyframe at or before desiredStartUsec.
  ##
  ## Returns 0 when the buffer has packets but no earlier keyframe was found.
  ## Returns -1 when the buffer is empty.
  if buf.packets.len == 0:
    return -1

  result = -1
  var i = 0
  for pkt in buf.packets:
    if pkt.timestampUsec <= desiredStartUsec and pkt.isKeyframe:
      result = i
    inc i

  if result < 0:
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
  result = &"packets={buf.len} bytes={buf.totalBytes} duration_us={buf.durationUsec} keyframes={buf.keyframeCount}"
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

proc writeEncodedPacketBuffer*(
    writer: Mp4VideoWriter;
    buf: EncodedPacketBuffer;
    startIndex: int = 0;
    rebaseTimestamps: bool = true
  ): FFmpegResult[int] =
  ## Write retained packets from startIndex to writer.
  ##
  ## When rebaseTimestamps is true, the first written packet starts at pts/dts 0.
  ## Returns the number of packets written.
  if startIndex < 0 or startIndex >= buf.packets.len:
    result = ok(0)
    return

  var ptsOffset = 0'i64
  var dtsOffset = 0'i64
  if rebaseTimestamps:
    var found = false
    var i = 0
    for pkt in buf.packets:
      if i >= startIndex:
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
    if i >= startIndex:
      let writeRet = writer.writeOwnedEncodedPacket(pkt, ptsOffset, dtsOffset)
      if writeRet.isErr:
        result = err(writeRet.error)
        return
      inc count
    inc i

  result = ok(count)

