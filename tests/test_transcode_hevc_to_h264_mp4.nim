# tests/test_transcode_hevc_to_h264_mp4.nim
#
# Decode an input HEVC/H.265 video with libav_nim, copy decoded frames into an
# owned I420 buffer, encode them as H.264, and mux the result into an MP4 file.

import std/[os, strformat, strutils]
import libav_nim

# =============================================================================
# === Test helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- usage
# -----------------------------------------------------------------------------

proc usage() =
  echo "usage:"
  echo "  test_transcode_hevc_to_h264_mp4 <input> <output.mp4> [decoder] [encoder] [fps] [bitrate] [maxFrames]"
  echo ""
  echo "example:"
  echo "  ./test_transcode_hevc_to_h264_mp4 bbb_h265.mp4 out.mp4 hevc_v4l2m2m h264_v4l2m2m 30 2000000 0"

# -----------------------------------------------------------------------------
# --- logStep
# -----------------------------------------------------------------------------

proc logStep(message: string) =
  stderr.writeLine(&"[transcode] {message}")

# -----------------------------------------------------------------------------
# --- parseIntArg
# -----------------------------------------------------------------------------

proc parseIntArg(args: seq[string]; index: int; defaultValue: int): int =
  if index >= args.len:
    result = defaultValue
    return

  result = parseInt(args[index])

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
# --- drainEncoder
# -----------------------------------------------------------------------------

proc drainEncoder(
    encoder: VideoEncoder;
    writer: Mp4VideoWriter;
    packets: var int;
    packetBytes: var int64
  ) =
  while true:
    let packetRead = check(encoder.receivePacket())
    if not packetRead.hasPacket:
      break

    inc packets
    packetBytes += packetRead.packet.size
    checkVoid(writer.writePacket(packetRead))

# -----------------------------------------------------------------------------
# --- encodeOwnedFrame
# -----------------------------------------------------------------------------

proc encodeOwnedFrame(
    encoder: VideoEncoder;
    writer: Mp4VideoWriter;
    frame: OwnedI420Frame;
    frameIndex: int64;
    packets: var int;
    packetBytes: var int64
  ) =
  let writable = check(encoder.beginFrame(frameIndex))
  checkVoid(copyI420(frame, writable))
  checkVoid(encoder.submitFrame())
  drainEncoder(encoder, writer, packets, packetBytes)

# -----------------------------------------------------------------------------
# --- readFrameIntoOwned
# -----------------------------------------------------------------------------

proc readFrameIntoOwned(
    decoder: VideoDecoder;
    owned: var OwnedI420Frame;
    eof: var bool
  ) =
  let read = check(decoder.readFrame())
  if read.eof:
    eof = true
    return

  eof = false
  checkVoid(copyI420(read.frame, owned))

# -----------------------------------------------------------------------------
# --- main
# -----------------------------------------------------------------------------

proc main() =
  let args = commandLineParams()
  if args.len < 2:
    usage()
    quit(1)

  let inputPath = args[0]
  let outputPath = args[1]
  let decoderName = if args.len >= 3: args[2] else: "hevc_v4l2m2m"
  let encoderName = if args.len >= 4: args[3] else: "h264_v4l2m2m"
  let fps = parseIntArg(args, 4, 30)
  let bitrate = parseIntArg(args, 5, 2_000_000)
  let maxFrames = parseIntArg(args, 6, 0)

  if fps <= 0:
    failWith(&"Invalid fps: {fps}")

  if bitrate <= 0:
    failWith(&"Invalid bitrate: {bitrate}")

  logStep(&"opening decoder: {decoderName}")
  var decoder = check(openVideoDecoder(
    inputPath,
    DecoderOptions(decoderName: decoderName)
  ))
  defer:
    logStep("closing decoder")
    decoder.close()

  logStep("reading first frame")
  let firstRead = check(decoder.readFrame())
  if firstRead.eof:
    failWith(&"Input has no decodable video frame: {inputPath}")

  let width = firstRead.frame.width
  let height = firstRead.frame.height
  logStep(&"first frame decoded: {width}x{height}")

  logStep("copying first frame into owned I420 buffer")
  var owned = check(newOwnedI420Frame(width, height))
  checkVoid(copyI420(firstRead.frame, owned))
  logStep(&"owned I420 buffer allocated: {owned.byteSize()} bytes")

  # From this point on, the first decoded frame view is no longer needed. Encoder
  # and writer setup no longer depend on an AVFrame borrowed from the decoder.
  logStep(&"opening encoder: {encoderName}")
  var encoder = check(openVideoEncoder(VideoEncoderOptions(
    encoderName: encoderName,
    width: width,
    height: height,
    pixelFormat: pfYuv420p,
    timeBase: Rational(num: 1, den: int32(fps)),
    framerate: Rational(num: int32(fps), den: 1),
    bitRate: bitrate,
    gopSize: fps,
    maxBFrames: 0,
    globalHeader: true
  )))
  defer:
    logStep("closing encoder")
    encoder.close()

  logStep(&"opening MP4 writer: {outputPath}")
  var writer = check(openMp4VideoWriter(outputPath, encoder))
  defer:
    logStep("closing MP4 writer")
    writer.close()

  var decodedFrames = 0
  var packets = 0
  var packetBytes = 0'i64

  logStep("encoding frame 0 from owned I420 buffer")
  encodeOwnedFrame(
    encoder,
    writer,
    owned,
    int64(decodedFrames),
    packets,
    packetBytes
  )
  inc decodedFrames

  while maxFrames <= 0 or decodedFrames < maxFrames:
    if decodedFrames mod 30 == 0:
      logStep(&"reading frame {decodedFrames}")

    var eof = false
    readFrameIntoOwned(decoder, owned, eof)
    if eof:
      logStep("decoder reached EOF")
      break

    if decodedFrames mod 30 == 0:
      logStep(&"encoding frame {decodedFrames}")

    encodeOwnedFrame(
      encoder,
      writer,
      owned,
      int64(decodedFrames),
      packets,
      packetBytes
    )
    inc decodedFrames

  logStep("flushing encoder")
  checkVoid(encoder.flush())
  drainEncoder(encoder, writer, packets, packetBytes)

  logStep("finishing MP4 writer")
  checkVoid(writer.finish())

  echo "transcode hevc to h264 mp4 result:"
  echo &"  input        : {inputPath}"
  echo &"  output       : {outputPath}"
  echo &"  decoder      : {decoderName}"
  echo &"  encoder      : {encoderName}"
  echo &"  size         : {width}x{height}"
  echo &"  fps          : {fps}"
  echo &"  bitrate      : {bitrate}"
  echo &"  frames       : {decodedFrames}"
  echo &"  packets      : {packets}"
  echo &"  packet bytes : {packetBytes}"

# =============================================================================
# === Program entry point
# =============================================================================

when isMainModule:
  main()
