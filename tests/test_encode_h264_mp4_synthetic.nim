# tests/test_encode_h264_mp4_synthetic.nim
#
# Encode synthetic I420 frames to an H.264 MP4 file.

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
  echo "usage: test_encode_h264_mp4_synthetic <output.mp4> [encoder-name] [width] [height] [frames] [fps] [bitrate]"
  echo ""
  echo "examples:"
  echo "  test_encode_h264_mp4_synthetic out.mp4 h264_v4l2m2m 1280 720 120 30 2000000"

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
# === Packet draining
# =============================================================================

# -----------------------------------------------------------------------------
# --- drainPackets
# -----------------------------------------------------------------------------

proc drainPackets(
    encoder: VideoEncoder;
    writer: Mp4VideoWriter;
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
      byteCount += int64(read.packet.size)
      let writeRet = writer.writePacket(read)
      if writeRet.isErr:
        echo writeRet.error
        quit 1

      inc packetCount
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
  let width = parseIntArg(args, 2, 1280)
  let height = parseIntArg(args, 3, 720)
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
    maxBFrames: 0,
    globalHeader: true
  ))
  if encoderRet.isErr:
    echo encoderRet.error
    quit 1

  let encoder = encoderRet.value
  defer: encoder.close()

  let writerRet = openMp4VideoWriter(outputPath, encoder)
  if writerRet.isErr:
    echo writerRet.error
    quit 1

  let writer = writerRet.value
  defer: writer.close()

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

    discard encoder.drainPackets(writer, packetCount, byteCount, expectFlush = false)

  let flushRet = encoder.flush()
  if flushRet.isErr:
    echo flushRet.error
    quit 1

  while true:
    if encoder.drainPackets(writer, packetCount, byteCount, expectFlush = true):
      break

  let finishRet = writer.finish()
  if finishRet.isErr:
    echo finishRet.error
    quit 1

  echo "encode h264 mp4 synthetic result:"
  echo &"  output       : {outputPath}"
  echo &"  encoder      : {encoderName}"
  echo &"  size         : {width}x{height}"
  echo &"  frames       : {frameCount}"
  echo &"  fps          : {fps}"
  echo &"  bitrate      : {bitRate}"
  echo &"  packets      : {packetCount}"
  echo &"  packet bytes : {byteCount}"

when isMainModule:
  main()
