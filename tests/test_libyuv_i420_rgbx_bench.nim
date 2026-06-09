# tests/test_libyuv_i420_rgbx_bench.nim
#
# Benchmark libyuv-backed I420 <-> RGBX conversion used by libav_nim.
#
# This test decodes one frame, copies it into an owned I420 buffer, and then
# repeatedly measures:
#
#   1. OwnedI420Frame -> OwnedRGBXFrame
#   2. OwnedRGBXFrame -> OwnedI420Frame
#   3. roundtrip
#   4. optional basic overlay cost
#
# It avoids V4L2 encoder and MP4 muxer costs so Ubuntu/Alpine results can be
# compared directly.

import std/[monotimes, os, strformat, strutils, times]
import libav_nim

# =============================================================================
# === Helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- usage
# -----------------------------------------------------------------------------

proc usage() =
  echo "usage:"
  echo "  test_libyuv_i420_rgbx_bench <input> [decoder] [iterations] [warmup]"
  echo ""
  echo "example:"
  echo "  ./test_libyuv_i420_rgbx_bench Big_Buck_Bunny_720_10s_5MB.mp4 hevc_v4l2m2m 300 20"

# -----------------------------------------------------------------------------
# --- failWith
# -----------------------------------------------------------------------------

proc failWith(message: string) =
  raise newException(IOError, message)

# -----------------------------------------------------------------------------
# --- check
# -----------------------------------------------------------------------------

proc check[T](ret: FFmpegResult[T]): T =
  if ret.isErr:
    failWith(ret.error.message)

  result = ret.value

# -----------------------------------------------------------------------------
# --- checkVoid
# -----------------------------------------------------------------------------

proc checkVoid(ret: FFmpegResult[void]) =
  if ret.isErr:
    failWith(ret.error.message)

# -----------------------------------------------------------------------------
# --- parseIntArg
# -----------------------------------------------------------------------------

proc parseIntArg(args: seq[string]; index: int; defaultValue: int): int =
  if index >= args.len:
    result = defaultValue
    return

  result = parseInt(args[index])

# -----------------------------------------------------------------------------
# --- elapsedMs
# -----------------------------------------------------------------------------

proc elapsedMs(startTime, endTime: MonoTime): float =
  result = inNanoseconds(endTime - startTime).float / 1_000_000.0

# -----------------------------------------------------------------------------
# --- printBench
# -----------------------------------------------------------------------------

proc printBench(name: string; elapsed: float; iterations: int; bytesPerIter: int) =
  let perFrame = elapsed / iterations.float
  let fps = if perFrame > 0.0: 1000.0 / perFrame else: 0.0
  let mbTotal = (bytesPerIter.float * iterations.float) / (1024.0 * 1024.0)
  let mbps = if elapsed > 0.0: mbTotal / (elapsed / 1000.0) else: 0.0

  echo &"{name}:"
  echo &"  total ms       : {elapsed:.3f}"
  echo &"  per frame ms   : {perFrame:.3f}"
  echo &"  fps equivalent : {fps:.2f}"
  echo &"  touched MiB    : {mbTotal:.2f}"
  echo &"  MiB/s          : {mbps:.2f}"

# =============================================================================
# === Main
# =============================================================================

proc main() =
  let args = commandLineParams()
  if args.len < 1:
    usage()
    quit(1)

  let inputPath = args[0]
  let decoderName = if args.len >= 2: args[1] else: "hevc_v4l2m2m"
  let iterations = parseIntArg(args, 2, 300)
  let warmup = parseIntArg(args, 3, 20)

  if iterations <= 0:
    failWith(&"Invalid iterations: {iterations}")

  if warmup < 0:
    failWith(&"Invalid warmup: {warmup}")

  stderr.writeLine(&"[bench] opening decoder: {decoderName}")
  var decoder = check(openVideoDecoder(
    inputPath,
    DecoderOptions(decoderName: decoderName)
  ))
  defer:
    stderr.writeLine("[bench] closing decoder")
    decoder.close()

  stderr.writeLine("[bench] reading one decoded frame")
  let read = check(decoder.readFrame())
  if read.eof:
    failWith(&"Input has no decodable video frame: {inputPath}")

  let width = read.frame.width
  let height = read.frame.height
  let i420Bytes = width * height + ((width + 1) div 2) * ((height + 1) div 2) * 2
  let rgbxBytes = width * height * 4

  stderr.writeLine(&"[bench] decoded frame: {width}x{height}")

  var srcI420 = check(newOwnedI420Frame(width, height))
  var dstI420 = check(newOwnedI420Frame(width, height))
  var rgbx = check(newOwnedRGBXFrame(width, height))

  checkVoid(copyI420(read.frame, srcI420))

  stderr.writeLine(&"[bench] srcI420 bytes: {srcI420.byteSize()}")
  stderr.writeLine(&"[bench] dstI420 bytes: {dstI420.byteSize()}")
  stderr.writeLine(&"[bench] rgbx bytes   : {rgbx.byteSize()}")
  stderr.writeLine(&"[bench] warmup       : {warmup}")
  stderr.writeLine(&"[bench] iterations   : {iterations}")

  # Warmup
  for i in 0 ..< warmup:
    checkVoid(copyI420ToRGBX(srcI420, rgbx))
    drawTestOverlay(rgbx, i)
    checkVoid(copyRGBXToI420(rgbx, dstI420))

  # I420 -> RGBX only
  var startTime = getMonoTime()
  for i in 0 ..< iterations:
    checkVoid(copyI420ToRGBX(srcI420, rgbx))
  var endTime = getMonoTime()
  let i420ToRgbxMs = elapsedMs(startTime, endTime)

  # RGBX -> I420 only. Ensure rgbx has valid content.
  checkVoid(copyI420ToRGBX(srcI420, rgbx))
  startTime = getMonoTime()
  for i in 0 ..< iterations:
    checkVoid(copyRGBXToI420(rgbx, dstI420))
  endTime = getMonoTime()
  let rgbxToI420Ms = elapsedMs(startTime, endTime)

  # Roundtrip without drawing.
  startTime = getMonoTime()
  for i in 0 ..< iterations:
    checkVoid(copyI420ToRGBX(srcI420, rgbx))
    checkVoid(copyRGBXToI420(rgbx, dstI420))
  endTime = getMonoTime()
  let roundtripMs = elapsedMs(startTime, endTime)

  # Basic overlay only on already-RGBX buffer.
  checkVoid(copyI420ToRGBX(srcI420, rgbx))
  startTime = getMonoTime()
  for i in 0 ..< iterations:
    drawTestOverlay(rgbx, i)
  endTime = getMonoTime()
  let overlayMs = elapsedMs(startTime, endTime)

  # Roundtrip with basic overlay.
  startTime = getMonoTime()
  for i in 0 ..< iterations:
    checkVoid(copyI420ToRGBX(srcI420, rgbx))
    drawTestOverlay(rgbx, i)
    checkVoid(copyRGBXToI420(rgbx, dstI420))
  endTime = getMonoTime()
  let roundtripOverlayMs = elapsedMs(startTime, endTime)

  echo "libyuv I420/RGBX bench:"
  echo &"  input      : {inputPath}"
  echo &"  decoder    : {decoderName}"
  echo &"  size       : {width}x{height}"
  echo &"  iterations : {iterations}"
  echo &"  warmup     : {warmup}"
  echo &"  i420 bytes : {i420Bytes}"
  echo &"  rgbx bytes : {rgbxBytes}"
  echo ""

  printBench(
    "I420 -> RGBX",
    i420ToRgbxMs,
    iterations,
    i420Bytes + rgbxBytes
  )
  echo ""

  printBench(
    "RGBX -> I420",
    rgbxToI420Ms,
    iterations,
    rgbxBytes + i420Bytes
  )
  echo ""

  printBench(
    "I420 -> RGBX -> I420",
    roundtripMs,
    iterations,
    i420Bytes + rgbxBytes + rgbxBytes + i420Bytes
  )
  echo ""

  printBench(
    "basic overlay only",
    overlayMs,
    iterations,
    rgbxBytes
  )
  echo ""

  printBench(
    "I420 -> RGBX -> overlay -> I420",
    roundtripOverlayMs,
    iterations,
    i420Bytes + rgbxBytes + rgbxBytes + i420Bytes
  )

when isMainModule:
  main()
