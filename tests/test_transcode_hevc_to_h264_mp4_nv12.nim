# tests/test_transcode_hevc_to_h264_mp4_nv12.nim
#
# Decode an input HEVC/H.265 video as I420/YUV420P, repack it into NV12, encode
# it as H.264 with an NV12 encoder input frame, and mux the result into MP4.
#
# This is intended to check wave5 encoder behavior when avoiding the YU12 input
# path.

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
  echo "  test_transcode_hevc_to_h264_mp4_nv12 <input> <output.mp4> [decoder] [encoder] [fps] [bitrate] [maxFrames]"
  echo ""
  echo "example:"
  echo "  ./test_transcode_hevc_to_h264_mp4_nv12 bbb_h265.mp4 out_nv12.mp4 hevc_v4l2m2m h264_v4l2m2m 30 2000000 60"

# -----------------------------------------------------------------------------
# --- logStep
# -----------------------------------------------------------------------------

proc logStep(message: string) =
  stderr.writeLine(&"[transcode-nv12] {message}")

# -----------------------------------------------------------------------------
# --- parseIntArg
# -----------------------------------------------------------------------------

proc parseIntArg(args: seq[string]; index: int; defaultValue: int): int =
  if index >= args.len:
    result = defaultValue
    return

  result = parseInt(args[index])

# -----------------------------------------------------------------------------
# --- alignUp
# -----------------------------------------------------------------------------

proc alignUp(value, alignment: int): int =
  if alignment <= 0:
    result = value
    return

  result = ((value + alignment - 1) div alignment) * alignment

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
# --- encodeOwnedFrameNV12
# -----------------------------------------------------------------------------

proc encodeOwnedFrameNV12(
    encoder: VideoEncoder;
    writer: Mp4VideoWriter;
    frame: OwnedI420Frame;
    frameIndex: int64;
    packets: var int;
    packetBytes: var int64
  ) =
  let writable = check(encoder.beginFrameNV12(frameIndex))
  checkVoid(copyI420ToNV12Padded(frame, writable))
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
  let encoderHeight = alignUp(height, 16)
  logStep(&"first frame decoded: {width}x{height}")
  if encoderHeight != height:
    logStep(&"using padded NV12 encoder frame height: visible={height} storage={encoderHeight}")

  logStep("copying first frame into owned I420 buffer")
  var owned = check(newOwnedI420Frame(width, height))
  checkVoid(copyI420(firstRead.frame, owned))
  logStep(&"owned I420 buffer allocated: {owned.byteSize()} bytes")

  logStep(&"opening encoder with NV12 input: {encoderName}")
  var encoder = check(openVideoEncoder(VideoEncoderOptions(
    encoderName: encoderName,
    width: width,
    height: encoderHeight,
    pixelFormat: pfNv12,
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

  logStep("encoding frame 0 as NV12")
  encodeOwnedFrameNV12(
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
      logStep(&"encoding frame {decodedFrames} as NV12")

    encodeOwnedFrameNV12(
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

  logStep("finishing writer")
  checkVoid(writer.finish())

  echo "transcode NV12 result:"
  echo &"  input        : {inputPath}"
  echo &"  output       : {outputPath}"
  echo &"  decoder      : {decoderName}"
  echo &"  encoder      : {encoderName}"
  echo &"  input format : nv12"
  echo &"  visible size : {width}x{height}"
  echo &"  encoder size : {width}x{encoderHeight}"
  echo &"  fps          : {fps}"
  echo &"  bitrate      : {bitrate}"
  echo &"  frames       : {decodedFrames}"
  echo &"  packets      : {packets}"
  echo &"  packet bytes : {packetBytes}"
  echo &"  i420 bytes   : {owned.byteSize()}"

when isMainModule:
  main()
