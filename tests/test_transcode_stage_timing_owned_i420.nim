# tests/test_transcode_stage_timing.nim
#
# Decode HEVC/H.265, copy decoded I420 into OwnedI420Frame, convert it into OwnedRGBXFrame, draw a basic
# overlay, convert RGBX back to I420, encode as H.264, mux into MP4, and report
# wall-clock timing for each pipeline stage.
#
# This is a measurement tool, not an optimization.  It intentionally keeps the
# same synchronous structure as test_transcode_hevc_to_h264_mp4_rgbx_basic, but explicitly splits decoder-owned I420 copy from owned-I420-to-RGBX conversion so the
# first result shows where the current pipeline actually spends time.

import std/[os, strformat, strutils, times]
import libav_nim

# =============================================================================
# === Timing helpers
# =============================================================================

type
  StageStats = object
    calls: int
    totalMs: float
    minMs: float
    maxMs: float

  PipelineTiming = object
    decoderOpen: StageStats
    firstReadFrame: StageStats
    encoderOpen: StageStats
    writerOpen: StageStats
    readFrame: StageStats
    copyDecodedI420ToOwned: StageStats
    copyOwnedI420ToRGBX: StageStats
    overlay: StageStats
    beginFrame: StageStats
    copyRGBXToI420: StageStats
    submitFrame: StageStats
    drainTotal: StageStats
    receivePacket: StageStats
    writePacket: StageStats
    encoderFlush: StageStats
    writerFinish: StageStats

# -----------------------------------------------------------------------------
# --- nowMs
# -----------------------------------------------------------------------------

proc nowMs(): float =
  result = epochTime() * 1000.0

# -----------------------------------------------------------------------------
# --- addSample
# -----------------------------------------------------------------------------

proc addSample(stats: var StageStats; elapsedMs: float) =
  inc stats.calls
  stats.totalMs += elapsedMs

  if stats.calls == 1 or elapsedMs < stats.minMs:
    stats.minMs = elapsedMs

  if stats.calls == 1 or elapsedMs > stats.maxMs:
    stats.maxMs = elapsedMs

# -----------------------------------------------------------------------------
# --- averageMs
# -----------------------------------------------------------------------------

proc averageMs(stats: StageStats): float =
  if stats.calls <= 0:
    result = 0.0
    return

  result = stats.totalMs / float(stats.calls)

# -----------------------------------------------------------------------------
# --- timeVoid
# -----------------------------------------------------------------------------

template timeVoid(stats: var StageStats; body: untyped) =
  let startedAt = nowMs()
  body
  stats.addSample(nowMs() - startedAt)

# =============================================================================
# === Test helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- usage
# -----------------------------------------------------------------------------

proc usage() =
  echo "usage:"
  echo "  test_transcode_stage_timing_owned_i420 <input> <output.mp4> [decoder] [encoder] [fps] [bitrate] [maxFrames]"
  echo ""
  echo "example:"
  echo "  ./test_transcode_stage_timing_owned_i420 bbb_h265.mp4 out_timing.mp4 hevc_v4l2m2m h264_v4l2m2m 30 2000000 300"

# -----------------------------------------------------------------------------
# --- logStep
# -----------------------------------------------------------------------------

proc logStep(message: string) =
  stderr.writeLine(&"[stage-timing] {message}")

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
# --- formatMs
# -----------------------------------------------------------------------------

proc formatMs(value: float): string =
  result = formatFloat(value, ffDecimal, 3)

# -----------------------------------------------------------------------------
# --- printStage
# -----------------------------------------------------------------------------

proc printStage(name: string; stats: StageStats; frameCount: int) =
  let perFrame = if frameCount > 0: stats.totalMs / float(frameCount) else: 0.0

  echo &"  {name:<18} calls={stats.calls:>6} total_ms={stats.totalMs.formatMs():>12} avg_ms={stats.averageMs().formatMs():>10} min_ms={stats.minMs.formatMs():>10} max_ms={stats.maxMs.formatMs():>10} per_frame_ms={perFrame.formatMs():>10}"

# -----------------------------------------------------------------------------
# --- printTimingSummary
# -----------------------------------------------------------------------------

proc printTimingSummary(timing: PipelineTiming; frameCount: int; packets: int) =
  echo ""
  echo "stage timing summary:"
  echo &"  measured frames : {frameCount}"
  echo &"  packets         : {packets}"
  echo ""
  echo "  one-time / setup stages:"
  printStage("decoderOpen", timing.decoderOpen, frameCount)
  printStage("firstReadFrame", timing.firstReadFrame, frameCount)
  printStage("encoderOpen", timing.encoderOpen, frameCount)
  printStage("writerOpen", timing.writerOpen, frameCount)
  printStage("encoderFlush", timing.encoderFlush, frameCount)
  printStage("writerFinish", timing.writerFinish, frameCount)
  echo ""
  echo "  per-frame pipeline stages:"
  printStage("readFrame", timing.readFrame, frameCount)
  printStage("copyDecodedI420ToOwned", timing.copyDecodedI420ToOwned, frameCount)
  printStage("copyOwnedI420ToRGBX", timing.copyOwnedI420ToRGBX, frameCount)
  printStage("overlay", timing.overlay, frameCount)
  printStage("beginFrame", timing.beginFrame, frameCount)
  printStage("copyRGBXToI420", timing.copyRGBXToI420, frameCount)
  printStage("submitFrame", timing.submitFrame, frameCount)
  printStage("drainTotal", timing.drainTotal, frameCount)
  printStage("receivePacket", timing.receivePacket, frameCount)
  printStage("writePacket", timing.writePacket, frameCount)

# -----------------------------------------------------------------------------
# --- drainEncoderTimed
# -----------------------------------------------------------------------------

proc drainEncoderTimed(
    encoder: VideoEncoder;
    writer: Mp4VideoWriter;
    timing: var PipelineTiming;
    packets: var int;
    packetBytes: var int64
  ) =
  timeVoid(timing.drainTotal):
    while true:
      var packetRead: EncodedPacketRead
      timeVoid(timing.receivePacket):
        packetRead = check(encoder.receivePacket())

      if not packetRead.hasPacket:
        break

      inc packets
      packetBytes += packetRead.packet.size

      timeVoid(timing.writePacket):
        checkVoid(writer.writePacket(packetRead))

# -----------------------------------------------------------------------------
# --- encodeRgbxFrameTimed
# -----------------------------------------------------------------------------

proc encodeRgbxFrameTimed(
    encoder: VideoEncoder;
    writer: Mp4VideoWriter;
    rgbx: OwnedRGBXFrame;
    frameIndex: int64;
    timing: var PipelineTiming;
    packets: var int;
    packetBytes: var int64
  ) =
  var writable: WritableI420FrameView
  timeVoid(timing.beginFrame):
    writable = check(encoder.beginFrame(frameIndex))

  timeVoid(timing.copyRGBXToI420):
    checkVoid(copyRGBXToI420(rgbx, writable))

  timeVoid(timing.submitFrame):
    checkVoid(encoder.submitFrame())

  drainEncoderTimed(encoder, writer, timing, packets, packetBytes)

# -----------------------------------------------------------------------------
# --- readFrameIntoRgbxTimed
# -----------------------------------------------------------------------------

proc readFrameIntoOwnedAndRgbxTimed(
    decoder: VideoDecoder;
    ownedI420: var OwnedI420Frame;
    rgbx: var OwnedRGBXFrame;
    timing: var PipelineTiming;
    eof: var bool
  ) =
  var read: ReadFrame
  timeVoid(timing.readFrame):
    read = check(decoder.readFrame())

  if read.eof:
    eof = true
    return

  eof = false
  timeVoid(timing.copyDecodedI420ToOwned):
    checkVoid(copyI420(read.frame, ownedI420))

  timeVoid(timing.copyOwnedI420ToRGBX):
    checkVoid(copyI420ToRGBX(ownedI420, rgbx))

# =============================================================================
# === main
# =============================================================================

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

  var timing: PipelineTiming

  logStep(&"opening decoder: {decoderName}")
  var decoder: VideoDecoder
  timeVoid(timing.decoderOpen):
    decoder = check(openVideoDecoder(
      inputPath,
      DecoderOptions(decoderName: decoderName)
    ))
  defer:
    logStep("closing decoder")
    decoder.close()

  logStep("reading first frame")
  var firstRead: ReadFrame
  timeVoid(timing.firstReadFrame):
    firstRead = check(decoder.readFrame())
  if firstRead.eof:
    failWith(&"Input has no decodable video frame: {inputPath}")

  let width = firstRead.frame.width
  let height = firstRead.frame.height
  logStep(&"first frame decoded: {width}x{height}")

  var ownedI420 = check(newOwnedI420Frame(width, height))
  var rgbx = check(newOwnedRGBXFrame(width, height))

  timeVoid(timing.copyDecodedI420ToOwned):
    checkVoid(copyI420(firstRead.frame, ownedI420))

  timeVoid(timing.copyOwnedI420ToRGBX):
    checkVoid(copyI420ToRGBX(ownedI420, rgbx))

  logStep(&"owned I420 buffer allocated: {ownedI420.byteSize()} bytes")
  logStep(&"owned RGBX buffer allocated: {rgbx.byteSize()} bytes")

  logStep(&"opening encoder: {encoderName}")
  var encoder: VideoEncoder
  timeVoid(timing.encoderOpen):
    encoder = check(openVideoEncoder(VideoEncoderOptions(
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
  var writer: Mp4VideoWriter
  timeVoid(timing.writerOpen):
    writer = check(openMp4VideoWriter(outputPath, encoder))
  defer:
    logStep("closing MP4 writer")
    writer.close()

  var decodedFrames = 0
  var packets = 0
  var packetBytes = 0'i64
  let totalStartedAt = nowMs()

  logStep("drawing and encoding frame 0")
  timeVoid(timing.overlay):
    drawTestOverlay(rgbx, decodedFrames)

  encodeRgbxFrameTimed(
    encoder,
    writer,
    rgbx,
    int64(decodedFrames),
    timing,
    packets,
    packetBytes
  )
  inc decodedFrames

  while maxFrames <= 0 or decodedFrames < maxFrames:
    if decodedFrames mod 30 == 0:
      logStep(&"reading frame {decodedFrames}")

    var eof = false
    readFrameIntoOwnedAndRgbxTimed(decoder, ownedI420, rgbx, timing, eof)
    if eof:
      logStep("decoder reached EOF")
      break

    timeVoid(timing.overlay):
      drawTestOverlay(rgbx, decodedFrames)

    if decodedFrames mod 30 == 0:
      logStep(&"encoding frame {decodedFrames}")

    encodeRgbxFrameTimed(
      encoder,
      writer,
      rgbx,
      int64(decodedFrames),
      timing,
      packets,
      packetBytes
    )
    inc decodedFrames

  logStep("flushing encoder")
  timeVoid(timing.encoderFlush):
    checkVoid(encoder.flush())
  drainEncoderTimed(encoder, writer, timing, packets, packetBytes)

  logStep("finishing MP4 writer")
  timeVoid(timing.writerFinish):
    checkVoid(writer.finish())

  let totalMs = nowMs() - totalStartedAt
  let fpsEquivalent = if totalMs > 0.0: float(decodedFrames) * 1000.0 / totalMs else: 0.0

  echo "transcode stage timing result:"
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
  echo &"  i420 bytes   : {ownedI420.byteSize()}"
  echo &"  rgbx bytes   : {rgbx.byteSize()}"
  echo &"  total ms     : {totalMs.formatMs()}"
  echo &"  effective fps: {fpsEquivalent.formatMs()}"

  printTimingSummary(timing, decodedFrames, packets)

# =============================================================================
# === Program entry point
# =============================================================================

when isMainModule:
  main()
