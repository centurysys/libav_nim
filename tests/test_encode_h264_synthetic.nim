# tests/test_encode_h264_synthetic.nim
#
# Encode synthetic I420 frames to a raw H.264 elementary stream.

import std/os
import std/strformat
import std/strutils
import libav_nim

# =============================================================================
# === CLI helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- usage
# -----------------------------------------------------------------------------

proc usage() =
  echo "usage: test_encode_h264_synthetic <output.h264> [encoder-name] [width] [height] [frames] [fps] [bitrate]"
  echo ""
  echo "examples:"
  echo "  test_encode_h264_synthetic out.h264 h264_v4l2m2m 640 360 120 30 2000000"
  echo "  test_encode_h264_synthetic out.h264 libx264 640 360 120 30 2000000"

# -----------------------------------------------------------------------------
# --- parseIntArg
# -----------------------------------------------------------------------------

proc parseIntArg(args: seq[string]; index: int; defaultValue: int): int =
  if args.len <= index:
    return defaultValue

  try:
    result = parseInt(args[index])
  except ValueError:
    result = defaultValue

# =============================================================================
# === Synthetic frame generation
# =============================================================================

# -----------------------------------------------------------------------------
# --- fillPlane
# -----------------------------------------------------------------------------

proc fillPlane(
    data: pointer;
    stride: int;
    width: int;
    height: int;
    frameIndex: int;
    seed: int
  ) =
  if data.isNil or stride <= 0 or width <= 0 or height <= 0:
    return

  let bytes = cast[ptr UncheckedArray[uint8]](data)
  for y in 0 ..< height:
    let row = y * stride
    for x in 0 ..< width:
      bytes[row + x] = uint8((x + y + frameIndex * 3 + seed) and 0xff)

# -----------------------------------------------------------------------------
# --- fillSyntheticI420
# -----------------------------------------------------------------------------

proc fillSyntheticI420(frame: WritableI420FrameView; frameIndex: int) =
  frame.y.fillPlane(frame.yStride, frame.width, frame.height, frameIndex, 0)
  frame.u.fillPlane(
    frame.uStride,
    (frame.width + 1) div 2,
    (frame.height + 1) div 2,
    frameIndex,
    64
  )
  frame.v.fillPlane(
    frame.vStride,
    (frame.width + 1) div 2,
    (frame.height + 1) div 2,
    frameIndex,
    128
  )

# =============================================================================
# === Packet output
# =============================================================================

# -----------------------------------------------------------------------------
# --- writePacket
# -----------------------------------------------------------------------------

proc writePacket(output: File; packet: EncodedPacketView; packetCount: var int; byteCount: var int64) =
  if packet.data.isNil or packet.size <= 0:
    return

  let written = output.writeBuffer(packet.data, packet.size)
  if written != packet.size:
    raise newException(IOError, &"Short write: wrote {written} of {packet.size} bytes")

  inc packetCount
  byteCount += int64(packet.size)

# -----------------------------------------------------------------------------
# --- drainPackets
# -----------------------------------------------------------------------------

proc drainPackets(
    encoder: VideoEncoder;
    output: File;
    packetCount: var int;
    byteCount: var int64;
    expectFlush: bool
  ): bool =
  ## Drain currently available packets.
  ##
  ## Returns true when the encoder reports EOF after flush.
  while true:
    let readRet = encoder.receivePacket()
    if readRet.isErr:
      echo readRet.error
      quit 1

    let read = readRet.value
    if read.hasPacket:
      output.writePacket(read.packet, packetCount, byteCount)
      continue

    if read.flushed:
      return true

    if expectFlush:
      return false

    return false

# =============================================================================
# === Encode loop
# =============================================================================

# -----------------------------------------------------------------------------
# --- main
# -----------------------------------------------------------------------------

proc main() =
  let args = commandLineParams()
  if args.len < 1:
    usage()
    quit 1

  let outputPath = args[0]
  let encoderName = if args.len >= 2: args[1] else: "h264_v4l2m2m"
  let width = parseIntArg(args, 2, 640)
  let height = parseIntArg(args, 3, 360)
  let frameCount = parseIntArg(args, 4, 120)
  let fps = parseIntArg(args, 5, 30)
  let bitRate = parseIntArg(args, 6, 2_000_000)

  if width <= 0 or height <= 0 or frameCount <= 0 or fps <= 0:
    usage()
    quit 1

  let encoderRet = openVideoEncoder(VideoEncoderOptions(
    encoderName: encoderName,
    width: width,
    height: height,
    pixelFormat: pfYuv420p,
    timeBase: Rational(num: 1, den: int32(fps)),
    framerate: Rational(num: int32(fps), den: 1),
    bitRate: int64(bitRate),
    gopSize: fps,
    maxBFrames: 0
  ))
  if encoderRet.isErr:
    echo encoderRet.error
    quit 1

  let encoder = encoderRet.value
  defer: encoder.close()

  var output: File
  if not output.open(outputPath, fmWrite):
    echo &"failed to open output: {outputPath}"
    quit 1
  defer: output.close()

  var packetCount = 0
  var byteCount = 0'i64

  for frameIndex in 0 ..< frameCount:
    let frameRet = encoder.beginFrame(int64(frameIndex))
    if frameRet.isErr:
      echo frameRet.error
      quit 1

    var frame = frameRet.value
    if not frame.hasUsableYuv420Planes():
      echo "encoder returned unusable I420 frame"
      quit 1

    frame.fillSyntheticI420(frameIndex)

    let submitRet = encoder.submitFrame()
    if submitRet.isErr:
      echo submitRet.error
      quit 1

    discard encoder.drainPackets(output, packetCount, byteCount, expectFlush = false)

  let flushRet = encoder.flush()
  if flushRet.isErr:
    echo flushRet.error
    quit 1

  while true:
    if encoder.drainPackets(output, packetCount, byteCount, expectFlush = true):
      break

  echo "encode h264 synthetic result:"
  echo &"  output       : {outputPath}"
  echo &"  encoder      : {encoderName}"
  echo &"  size         : {width}x{height}"
  echo &"  frames       : {frameCount}"
  echo &"  fps          : {fps}"
  echo &"  bitrate      : {bitRate}"
  echo &"  packets      : {packetCount}"
  echo &"  bytes        : {byteCount}"

when isMainModule:
  main()
