# tests/test_decode_layout.nim
#
# Decode frames and validate the borrowed YUV420P layout that will be passed to
# upper-layer conversion code such as libyuv_nim.

import std/monotimes
import std/os
import std/strformat
import std/strutils
import std/times
import libav_nim

# =============================================================================
# === CLI helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- usage
# -----------------------------------------------------------------------------

proc usage() =
  echo "usage: test_decode_layout <input> [decoder-name] [max-frames]"
  echo ""
  echo "examples:"
  echo "  test_decode_layout bbb_h265.mp4 hevc_v4l2m2m"
  echo "  test_decode_layout bbb_h264.mp4 h264_v4l2m2m 300"

# -----------------------------------------------------------------------------
# --- parseMaxFrames
# -----------------------------------------------------------------------------

proc parseMaxFrames(args: seq[string]): int =
  if args.len < 3:
    return 0

  try:
    result = parseInt(args[2])
  except ValueError:
    result = 0

# =============================================================================
# === Measurement helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- elapsedSeconds
# -----------------------------------------------------------------------------

proc elapsedSeconds(started: MonoTime; finished: MonoTime): float64 =
  let elapsed = finished - started
  result = float64(inNanoseconds(elapsed)) / 1_000_000_000.0

# -----------------------------------------------------------------------------
# --- mixChecksum
# -----------------------------------------------------------------------------

proc mixChecksum(checksum: var uint64; value: uint8) =
  checksum = checksum xor uint64(value)
  checksum = checksum * 1099511628211'u64

# -----------------------------------------------------------------------------
# --- touchPlane
# -----------------------------------------------------------------------------

proc touchPlane(plane: PlaneView; checksum: var uint64) =
  if plane.data.isNil or plane.width <= 0 or plane.height <= 0 or plane.stride <= 0:
    checksum.mixChecksum(0)
    return

  let bytes = cast[ptr UncheckedArray[uint8]](plane.data)
  let p0 = 0
  let p1 = (plane.height div 2) * plane.stride + (plane.width div 2)
  let p2 = (plane.height - 1) * plane.stride + (plane.width - 1)

  checksum.mixChecksum(bytes[p0])
  checksum.mixChecksum(bytes[p1])
  checksum.mixChecksum(bytes[p2])

# -----------------------------------------------------------------------------
# --- touchFrameData
# -----------------------------------------------------------------------------

proc touchFrameData(frame: Yuv420FrameView; checksum: var uint64) =
  frame.yPlane().touchPlane(checksum)
  frame.uPlane().touchPlane(checksum)
  frame.vPlane().touchPlane(checksum)

# =============================================================================
# === Decode loop
# =============================================================================

# -----------------------------------------------------------------------------
# --- main
# -----------------------------------------------------------------------------

proc main() =
  let args = commandLineParams()
  if args.len < 1:
    usage()
    quit 1

  let inputPath = args[0]
  let decoderName = if args.len >= 2: args[1] else: ""
  let maxFrames = parseMaxFrames(args)

  let decoderRet = openVideoDecoder(inputPath, DecoderOptions(decoderName: decoderName))
  if decoderRet.isErr:
    echo decoderRet.error
    quit 1

  let decoder = decoderRet.value
  defer: decoder.close()

  var frameCount = 0
  var layoutErrorCount = 0
  var timestampChangeCount = 0
  var previousSelected = avNoPtsValue
  var checksum = 1469598103934665603'u64

  var firstFrame: Yuv420FrameView
  var lastFrame: Yuv420FrameView
  var sawFrame = false

  var minYStride = high(int)
  var maxYStride = 0
  var minUStride = high(int)
  var maxUStride = 0
  var minVStride = high(int)
  var maxVStride = 0

  let started = getMonoTime()

  while true:
    let readRet = decoder.readFrame()
    if readRet.isErr:
      echo readRet.error
      quit 1

    let read = readRet.value
    if read.eof:
      break

    let frame = read.frame
    inc frameCount

    if not frame.hasUsableYuv420Planes():
      inc layoutErrorCount
    else:
      frame.touchFrameData(checksum)

    if not sawFrame:
      firstFrame = frame
      sawFrame = true

    lastFrame = frame

    minYStride = min(minYStride, frame.yStride)
    maxYStride = max(maxYStride, frame.yStride)
    minUStride = min(minUStride, frame.uStride)
    maxUStride = max(maxUStride, frame.uStride)
    minVStride = min(minVStride, frame.vStride)
    maxVStride = max(maxVStride, frame.vStride)

    let selected = frame.timestamp.selectedTimestamp()
    if selected.hasTimestampValue():
      if previousSelected.hasTimestampValue() and selected != previousSelected:
        inc timestampChangeCount
      previousSelected = selected

    if maxFrames > 0 and frameCount >= maxFrames:
      break

  let finished = getMonoTime()
  let elapsed = elapsedSeconds(started, finished)
  let fps = if elapsed > 0.0: float64(frameCount) / elapsed else: 0.0

  echo "decode layout result:"
  echo &"  frames             : {frameCount}"
  echo &"  layout errors      : {layoutErrorCount}"
  echo &"  timestamp changes  : {timestampChangeCount}"
  echo &"  wall seconds       : {elapsed:.6f}"
  echo &"  wall fps           : {fps:.3f}"
  echo &"  data checksum      : 0x{checksum.toHex(16)}"

  if sawFrame:
    let firstLayout = firstFrame.yuv420Layout()
    let lastLayout = lastFrame.yuv420Layout()

    echo "  first frame:"
    echo &"    size             : {firstFrame.width}x{firstFrame.height}"
    echo &"    format           : {firstFrame.format.pixelFormatName()}"
    echo &"    yStride          : {firstFrame.yStride}"
    echo &"    uStride          : {firstFrame.uStride}"
    echo &"    vStride          : {firstFrame.vStride}"
    echo &"    yuv420 bytes     : {firstLayout.totalBytes}"
    echo &"    rgbx bytes       : {firstFrame.rgbxByteSize()}"

    echo "  last frame:"
    echo &"    size             : {lastFrame.width}x{lastFrame.height}"
    echo &"    format           : {lastFrame.format.pixelFormatName()}"
    echo &"    yStride          : {lastFrame.yStride}"
    echo &"    uStride          : {lastFrame.uStride}"
    echo &"    vStride          : {lastFrame.vStride}"
    echo &"    yuv420 bytes     : {lastLayout.totalBytes}"
    echo &"    rgbx bytes       : {lastFrame.rgbxByteSize()}"

    echo "  stride range:"
    echo &"    yStride          : {minYStride}..{maxYStride}"
    echo &"    uStride          : {minUStride}..{maxUStride}"
    echo &"    vStride          : {minVStride}..{maxVStride}"

when isMainModule:
  main()
