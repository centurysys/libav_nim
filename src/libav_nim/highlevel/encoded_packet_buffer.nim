# libav_nim/highlevel/encoded_packet_buffer.nim
#
# Owned encoded packet storage for event-recording pipelines.
#
# FFmpeg AVPacket memory is borrowed and short-lived.  Event recording needs to
# keep already-encoded packets for several seconds, so this module copies packet
# payloads into Nim-owned memory and stores them in a time/size bounded deque.

import std/[deques, strformat]

import ../lowlevel/types

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
# --- trimLeadingNonKeyframes
# -----------------------------------------------------------------------------

proc trimLeadingNonKeyframes*(buf: var EncodedPacketBuffer) =
  ## Drop leading non-keyframes so a retained window starts decodably.
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
