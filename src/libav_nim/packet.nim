# libav_nim/packet.nim
#
# Result-based thin ownership wrapper for AVPacket.

import results
import ./bindings/c_api
import ./error
import ./types

# =============================================================================
# === Packet owner
# =============================================================================

type
  Packet* = ref object
    raw*: AVPacketPtr

# =============================================================================
# === Packet lifecycle
# =============================================================================

# -----------------------------------------------------------------------------
# --- newPacket
# -----------------------------------------------------------------------------

proc newPacket*(): FFmpegResult[Packet] =
  let raw = av_packet_alloc()
  if raw.isNil:
    result = fail[Packet]("av_packet_alloc", "allocation failed")
    return

  result = ok(Packet(raw: raw))

# -----------------------------------------------------------------------------
# --- close
# -----------------------------------------------------------------------------

proc close*(packet: Packet) =
  if packet.isNil:
    return

  if packet.raw.isNil:
    return

  var raw = packet.raw
  av_packet_free(addr raw)
  packet.raw = nil

# -----------------------------------------------------------------------------
# --- unref
# -----------------------------------------------------------------------------

proc unref*(packet: Packet) =
  if packet.isNil or packet.raw.isNil:
    return

  av_packet_unref(packet.raw)

# =============================================================================
# === Packet state
# =============================================================================

# -----------------------------------------------------------------------------
# --- isOpen
# -----------------------------------------------------------------------------

proc isOpen*(packet: Packet): bool =
  result = not packet.isNil and not packet.raw.isNil

# -----------------------------------------------------------------------------
# --- requireOpen
# -----------------------------------------------------------------------------

proc requireOpen*(packet: Packet): FFmpegResult[AVPacketPtr] =
  if not packet.isOpen():
    result = fail[AVPacketPtr]("Packet.requireOpen", "Packet is closed")
    return

  result = ok(packet.raw)

# -----------------------------------------------------------------------------
# --- streamIndex
# -----------------------------------------------------------------------------

proc streamIndex*(packet: Packet): FFmpegResult[int] =
  let rawRet = packet.requireOpen()
  if rawRet.isErr:
    result = err(rawRet.error)
    return

  result = ok(int(rawRet.value[].stream_index))

# -----------------------------------------------------------------------------
# --- packetTimestamp
# -----------------------------------------------------------------------------

proc packetTimestamp*(packet: Packet; timeBase: Rational): FFmpegResult[FrameTimestamp] =
  let rawRet = packet.requireOpen()
  if rawRet.isErr:
    result = err(rawRet.error)
    return

  let raw = rawRet.value
  var timestamp = emptyFrameTimestamp(timeBase)
  timestamp.packetPts = raw[].pts
  timestamp.packetDts = raw[].dts
  timestamp.packetDuration = raw[].duration

  if timestamp.packetPts.hasTimestampValue():
    timestamp.selected = timestamp.packetPts
    timestamp.source = tsPacketPts
  elif timestamp.packetDts.hasTimestampValue():
    timestamp.selected = timestamp.packetDts
    timestamp.source = tsPacketDts

  result = ok(timestamp)
