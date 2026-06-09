# tests/test_decode_count.nim
#
# Decode all video frames from an input and print timestamp and wall-clock
# throughput statistics.

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
  echo "usage: test_decode_count <input> [decoder-name] [max-frames]"
  echo ""
  echo "examples:"
  echo "  test_decode_count bbb_h265.mp4 hevc_v4l2m2m"
  echo "  test_decode_count bbb_h264.mp4 h264_v4l2m2m 300"

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
# === Timestamp formatting
# =============================================================================

# -----------------------------------------------------------------------------
# --- timestampSummary
# -----------------------------------------------------------------------------

proc timestampSummary(timestamp: FrameTimestamp): string =
  var seconds: float64
  let selected = timestamp.selectedTimestamp()

  if timestamp.timestampSeconds(seconds):
    result = &"selected={selected} seconds={seconds:.6f} " &
      &"source={timestamp.source.timestampSourceName()} " &
      &"framePts={timestamp.pts} bestEffort={timestamp.bestEffortTimestamp} " &
      &"framePktDts={timestamp.pktDts} packetPts={timestamp.packetPts} " &
      &"packetDts={timestamp.packetDts} duration={timestamp.duration} " &
      &"packetDuration={timestamp.packetDuration} frameIndex={timestamp.frameIndex} " &
      &"timeBase={timestamp.timeBase.num}/{timestamp.timeBase.den}"
    return

  result = &"selected=none source={timestamp.source.timestampSourceName()} " &
    &"framePts={timestamp.pts} bestEffort={timestamp.bestEffortTimestamp} " &
    &"framePktDts={timestamp.pktDts} packetPts={timestamp.packetPts} " &
    &"packetDts={timestamp.packetDts} duration={timestamp.duration} " &
    &"packetDuration={timestamp.packetDuration} frameIndex={timestamp.frameIndex} " &
    &"timeBase={timestamp.timeBase.num}/{timestamp.timeBase.den}"

# =============================================================================
# === Measurement helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- elapsedSeconds
# -----------------------------------------------------------------------------

proc elapsedSeconds(started: MonoTime; finished: MonoTime): float64 =
  result = float64((finished - started).inNanoseconds) / 1_000_000_000.0

# -----------------------------------------------------------------------------
# --- mixChecksum
# -----------------------------------------------------------------------------

proc mixChecksum(checksum: var uint64; value: uint8) =
  checksum = checksum xor uint64(value)
  checksum = checksum * 1099511628211'u64

# -----------------------------------------------------------------------------
# --- touchFrameData
# -----------------------------------------------------------------------------

proc touchFrameData(frame: Yuv420FrameView; checksum: var uint64) =
  ## Touch a few bytes from each decoded frame so the benchmark is not merely
  ## counting borrowed AVFrame handles.
  if frame.y.isNil or frame.width <= 0 or frame.height <= 0 or frame.yStride <= 0:
    checksum.mixChecksum(0)
    return

  let y = cast[ptr UncheckedArray[uint8]](frame.y)
  let p0 = 0
  let p1 = (frame.height div 2) * frame.yStride + (frame.width div 2)
  let p2 = (frame.height - 1) * frame.yStride + (frame.width - 1)

  checksum.mixChecksum(y[p0])
  checksum.mixChecksum(y[p1])
  checksum.mixChecksum(y[p2])

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

  let options = DecoderOptions(decoderName: decoderName)
  let decoderRet = openVideoDecoder(inputPath, options)
  if decoderRet.isErr:
    echo decoderRet.error
    quit 1

  let decoder = decoderRet.value
  defer: decoder.close()

  var frameCount = 0
  var timestampCount = 0
  var timestampChangeCount = 0
  var firstTimestamp: FrameTimestamp
  var lastTimestamp: FrameTimestamp
  var previousSelected = avNoPtsValue
  var sawFirstTimestamp = false
  var firstFrame: Yuv420FrameView
  var lastFrame: Yuv420FrameView
  var checksum = 1469598103934665603'u64

  let started = getMonoTime()

  while true:
    let readRet = decoder.readFrame()
    if readRet.isErr:
      echo readRet.error
      quit 1

    let read = readRet.value
    if read.eof:
      break

    inc frameCount
    let frame = read.frame
    frame.touchFrameData(checksum)
    lastFrame = frame

    if frameCount == 1:
      firstFrame = frame
      firstTimestamp = frame.timestamp
      sawFirstTimestamp = true

    lastTimestamp = frame.timestamp

    let selected = frame.timestamp.selectedTimestamp()
    if selected.hasTimestampValue():
      inc timestampCount
      if previousSelected.hasTimestampValue() and selected != previousSelected:
        inc timestampChangeCount
      previousSelected = selected

    if maxFrames > 0 and frameCount >= maxFrames:
      break

  let finished = getMonoTime()
  let elapsed = elapsedSeconds(started, finished)
  let fps = if elapsed > 0.0: float64(frameCount) / elapsed else: 0.0

  echo "decode count result:"
  echo &"  frames             : {frameCount}"
  echo &"  timestamped        : {timestampCount}"
  echo &"  timestamp changes  : {timestampChangeCount}"
  echo &"  wall seconds       : {elapsed:.6f}"
  echo &"  wall fps           : {fps:.3f}"
  echo &"  data checksum      : 0x{checksum.toHex(16)}"

  if frameCount > 0:
    echo "  first frame:"
    echo &"    size             : {firstFrame.width}x{firstFrame.height}"
    echo &"    yStride          : {firstFrame.yStride}"
    echo &"    uStride          : {firstFrame.uStride}"
    echo &"    vStride          : {firstFrame.vStride}"
    if sawFirstTimestamp:
      echo &"    timestamp        : {timestampSummary(firstTimestamp)}"

    echo "  last frame:"
    echo &"    size             : {lastFrame.width}x{lastFrame.height}"
    echo &"    yStride          : {lastFrame.yStride}"
    echo &"    uStride          : {lastFrame.uStride}"
    echo &"    vStride          : {lastFrame.vStride}"
    echo &"    timestamp        : {timestampSummary(lastTimestamp)}"

when isMainModule:
  main()
