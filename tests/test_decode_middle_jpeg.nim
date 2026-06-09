# tests/test_decode_middle_jpeg.nim
#
# Optional visual integration test:
#
#   libav_nim      : decode a video file into borrowed I420/YUV420P frame views
#   libyuv_nim     : letterbox the middle frame into a 640x640 RGB24 buffer
#   hyper_jpeg_nim : encode the letterbox buffer into JPEG, preferably by V4L2 HW
#
# This test intentionally does not make libyuv_nim or hyper_jpeg_nim normal
# libav_nim package dependencies. Build it only when both modules are available
# in the Nim import path.

import std/monotimes
import std/os
import std/strformat
import std/strutils
import std/times

import libav_nim
import libyuv_nim
import hyper_jpeg

# =============================================================================
# === Constants
# =============================================================================

const
  defaultOutputPath = "middle_letterbox.jpg"
  defaultYoloWidth = 640
  defaultYoloHeight = 640
  defaultJpegQuality = 90

# =============================================================================
# === RGBX buffer
# =============================================================================

type
  RgbxImage = object
    width: int
    height: int
    stride: int
    data: seq[uint8]

# -----------------------------------------------------------------------------
# --- allocRgbxImage
# -----------------------------------------------------------------------------

proc allocRgbxImage(width, height: int): RgbxImage =
  result.width = width
  result.height = height
  result.stride = width * 4
  result.data = newSeq[uint8](result.stride * height)

# -----------------------------------------------------------------------------
# --- dataPtr
# -----------------------------------------------------------------------------

proc dataPtr(image: var RgbxImage): pointer =
  if image.data.len == 0:
    result = nil
    return

  result = cast[pointer](addr image.data[0])

# -----------------------------------------------------------------------------
# --- rgbToRgbx
# -----------------------------------------------------------------------------

proc rgbToRgbx(src: RgbImage; dst: var RgbxImage; xValue: uint8 = 255'u8) =
  ## Convert RGB24 into RGBX.
  ##
  ## Layout is R,G,B,X in memory.  This matches hyper_jpeg's RGBX/RGBA input
  ## path, where the fourth byte is ignored for JPEG content.
  if src.width != dst.width or src.height != dst.height:
    raise newException(
      ValueError,
      &"RGB/RGBX size mismatch: src={src.width}x{src.height}, dst={dst.width}x{dst.height}"
    )

  for y in 0 ..< src.height:
    let srcRow = y * src.stride
    let dstRow = y * dst.stride

    for x in 0 ..< src.width:
      let si = srcRow + x * 3
      let di = dstRow + x * 4

      dst.data[di] = src.data[si]
      dst.data[di + 1] = src.data[si + 1]
      dst.data[di + 2] = src.data[si + 2]
      dst.data[di + 3] = xValue

# =============================================================================
# === CLI helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- usage
# -----------------------------------------------------------------------------

proc usage() =
  echo "usage: test_decode_middle_jpeg <input> [decoder-name] [output.jpg] [quality]"
  echo ""
  echo "examples:"
  echo "  test_decode_middle_jpeg bbb_h265.mp4 hevc_v4l2m2m"
  echo "  test_decode_middle_jpeg bbb_h265.mp4 hevc_v4l2m2m middle.jpg 90"

# -----------------------------------------------------------------------------
# --- parseQuality
# -----------------------------------------------------------------------------

proc parseQuality(args: seq[string]): int =
  if args.len < 4:
    return defaultJpegQuality

  try:
    result = parseInt(args[3])
  except ValueError:
    result = defaultJpegQuality

# =============================================================================
# === Time helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- elapsedSeconds
# -----------------------------------------------------------------------------

proc elapsedSeconds(started: MonoTime; finished: MonoTime): float64 =
  let elapsed = finished - started
  result = float64(inNanoseconds(elapsed)) / 1_000_000_000.0

# -----------------------------------------------------------------------------
# --- timestampSummary
# -----------------------------------------------------------------------------

proc selectedSeconds(timestamp: FrameTimestamp): float64 =
  let selected = timestamp.selectedTimestamp()
  if not selected.hasTimestampValue():
    result = 0.0
    return

  if timestamp.timeBase.den == 0:
    result = 0.0
    return

  result = float64(selected) * float64(timestamp.timeBase.num) / float64(timestamp.timeBase.den)

# -----------------------------------------------------------------------------
# --- timestampSummary
# -----------------------------------------------------------------------------

proc timestampSummary(timestamp: FrameTimestamp): string =
  let selected = timestamp.selectedTimestamp()
  let seconds = timestamp.selectedSeconds()

  result = &"selected={selected} seconds={seconds:.6f} source={timestamp.source} " &
    &"framePts={timestamp.pts} bestEffort={timestamp.bestEffortTimestamp} " &
    &"framePktDts={timestamp.pktDts} packetPts={timestamp.packetPts} " &
    &"packetDts={timestamp.packetDts} duration={timestamp.duration} " &
    &"packetDuration={timestamp.packetDuration} frameIndex={timestamp.frameIndex} " &
    &"timeBase={timestamp.timeBase.num}/{timestamp.timeBase.den}"

# =============================================================================
# === libav_nim -> libyuv_nim view bridge
# =============================================================================

# -----------------------------------------------------------------------------
# --- toLibyuvI420View
# -----------------------------------------------------------------------------

proc toLibyuvI420View(frame: Yuv420FrameView): I420View =
  ## Convert libav_nim's borrowed YUV420P/I420 frame view into libyuv_nim's
  ## borrowed I420 view.  This does not copy image data.
  result = I420View(
    width: frame.width,
    height: frame.height,
    strideY: frame.yStride,
    strideU: frame.uStride,
    strideV: frame.vStride,
    y: cast[ptr uint8](frame.y),
    u: cast[ptr uint8](frame.u),
    v: cast[ptr uint8](frame.v)
  )

# -----------------------------------------------------------------------------
# --- toRgbView
# -----------------------------------------------------------------------------

proc toRgbView(image: var RgbImage): RgbView =
  if image.data.len == 0:
    result = RgbView(
      width: image.width,
      height: image.height,
      stride: image.stride,
      data: nil
    )
    return

  result = RgbView(
    width: image.width,
    height: image.height,
    stride: image.stride,
    data: addr image.data[0]
  )

# =============================================================================
# === Decode helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- openDecoderOrQuit
# -----------------------------------------------------------------------------

proc openDecoderOrQuit(inputPath, decoderName: string): VideoDecoder =
  let decoderRet = openVideoDecoder(
    inputPath,
    DecoderOptions(decoderName: decoderName)
  )

  if decoderRet.isErr:
    echo decoderRet.error
    quit 1

  result = decoderRet.value

# -----------------------------------------------------------------------------
# --- countFrames
# -----------------------------------------------------------------------------

proc countFrames(inputPath, decoderName: string): int =
  var decoder = openDecoderOrQuit(inputPath, decoderName)
  defer: decoder.close()

  while true:
    let readRet = decoder.readFrame()
    if readRet.isErr:
      echo readRet.error
      quit 1

    let read = readRet.value
    if read.eof:
      break

    inc result

# -----------------------------------------------------------------------------
# --- readMiddleLetterbox
# -----------------------------------------------------------------------------

proc readMiddleLetterbox(
    inputPath, decoderName: string;
    targetIndex: int;
    rgb: var RgbImage;
    scratch: var I420Image
  ): FFmpegResult[tuple[frame: Yuv420FrameView, letterbox: LetterboxInfo]] =
  ## Decode up to targetIndex and convert the target frame while the borrowed
  ## FFmpeg frame is still alive.
  ##
  ## Yuv420FrameView is a borrowed view.  It must not escape past decoder reuse or
  ## close if its plane pointers will be dereferenced.  This proc therefore does
  ## the libyuv conversion before closing the decoder.
  var decoder = openDecoderOrQuit(inputPath, decoderName)
  defer: decoder.close()

  var index = 0
  var rgbView = rgb.toRgbView()

  while true:
    let readRet = decoder.readFrame()
    if readRet.isErr:
      return err(readRet.error)

    let read = readRet.value
    if read.eof:
      return fail[tuple[frame: Yuv420FrameView, letterbox: LetterboxInfo]](
        "readMiddleLetterbox",
        &"target frame was not found: targetIndex={targetIndex}"
      )

    if index == targetIndex:
      let frame = read.frame
      if not frame.hasUsableYuv420Planes():
        return fail[tuple[frame: Yuv420FrameView, letterbox: LetterboxInfo]](
          "readMiddleLetterbox",
          "target frame is not a usable YUV420P frame"
        )

      let letterboxRet = toRgbLetterboxInto(
        frame.toLibyuvI420View(),
        rgbView,
        scratch
      )

      if letterboxRet.isErr:
        return fail[tuple[frame: Yuv420FrameView, letterbox: LetterboxInfo]](
          "readMiddleLetterbox",
          $letterboxRet.error
        )

      return ok((frame: frame, letterbox: letterboxRet.value))

    inc index

# =============================================================================
# === Encoding helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- saveJpeg
# -----------------------------------------------------------------------------

proc saveJpeg(path: string; jpeg: seq[uint8]) =
  var f = open(path, fmWrite)
  defer: f.close()

  if jpeg.len > 0:
    discard f.writeBuffer(unsafeAddr jpeg[0], jpeg.len)

# =============================================================================
# === Main
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
  let outputPath = if args.len >= 3: args[2] else: defaultOutputPath
  let quality = parseQuality(args)

  let totalFrames = countFrames(inputPath, decoderName)
  if totalFrames <= 0:
    echo "No frames decoded"
    quit 1

  let targetIndex = totalFrames div 2

  let started = getMonoTime()

  let rgbRet = allocRgbImage(defaultYoloWidth, defaultYoloHeight)
  if rgbRet.isErr:
    echo rgbRet.error
    quit 1

  var rgb = rgbRet.value
  var scratch: I420Image

  let middleRet = readMiddleLetterbox(
    inputPath,
    decoderName,
    targetIndex,
    rgb,
    scratch
  )

  if middleRet.isErr:
    echo middleRet.error
    quit 1

  let frame = middleRet.value.frame
  let letterbox = middleRet.value.letterbox

  var rgbx = allocRgbxImage(defaultYoloWidth, defaultYoloHeight)
  rgb.rgbToRgbx(rgbx)

  var encRet = JpegEncoder.open(
    defaultYoloWidth,
    defaultYoloHeight,
    backend = jbV4l2,
    quality = quality
  )

  if encRet.isErr:
    echo encRet.error
    quit 1

  var enc = encRet.value
  defer:
    let closeRet = enc.close()
    if closeRet.isErr:
      discard

  let jpegRet = enc.encodeRgbx(
    rgbx.dataPtr(),
    rgbx.width,
    rgbx.height,
    rgbx.stride,
    quality = quality
  )

  if jpegRet.isErr:
    echo jpegRet.error
    quit 1

  let jpeg = jpegRet.value
  saveJpeg(outputPath, jpeg)

  let finished = getMonoTime()
  let elapsed = elapsedSeconds(started, finished)

  echo "middle frame JPEG result:"
  echo &"  input              : {inputPath}"
  echo &"  output             : {outputPath}"
  echo &"  total frames       : {totalFrames}"
  echo &"  target index       : {targetIndex}"
  echo &"  source frame       : {frame.width}x{frame.height}"
  echo &"  source format      : {frame.format.pixelFormatName()}"
  echo &"  timestamp          : {timestampSummary(frame.timestamp)}"
  echo &"  letterbox image    : {defaultYoloWidth}x{defaultYoloHeight}"
  echo &"  resized            : {letterbox.resizedWidth}x{letterbox.resizedHeight}"
  echo &"  offset             : {letterbox.offsetX},{letterbox.offsetY}"
  echo &"  scale              : {letterbox.scaleX:.6f},{letterbox.scaleY:.6f}"
  echo &"  jpeg backend       : {enc.backend}"
  echo &"  jpeg quality       : {quality}"
  echo &"  jpeg bytes         : {jpeg.len}"
  echo &"  elapsed seconds    : {elapsed:.6f}"

when isMainModule:
  main()
