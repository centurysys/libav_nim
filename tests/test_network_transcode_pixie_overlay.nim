# tests/test_network_transcode_pixie_overlay.nim
#
# RTSP/RTP/SDP/network input -> decode -> RGBX -> Pixie zero-copy overlay
# -> padded NV12 -> H.264 MP4 output.
#
# This is an integration test for the practical camera pipeline. It only
# processes frames actually returned by the decoder; it does not duplicate
# frames to match an inferred source frame rate. The output PTS/fps is supplied
# by the caller with --fps.

import std/[os, strformat, strutils, times]

import pixie
import chroma

import libav_nim

# =============================================================================
# === Timing helpers
# =============================================================================

type
  DecoderRgbxMode = enum
    drmOwnedCopy
    drmDirect

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
    copyDecodedI420ToRGBXDirect: StageStats
    pixieOverlay: StageStats
    beginFrameNV12: StageStats
    copyRGBXToNV12Padded: StageStats
    submitFrame: StageStats
    drainTotal: StageStats
    receivePacket: StageStats
    writePacket: StageStats
    encoderFlush: StageStats
    writerFinish: StageStats

proc nowMs(): float =
  result = epochTime() * 1000.0

proc addSample(stats: var StageStats; elapsedMs: float) =
  inc stats.calls
  stats.totalMs += elapsedMs
  if stats.calls == 1 or elapsedMs < stats.minMs:
    stats.minMs = elapsedMs
  if stats.calls == 1 or elapsedMs > stats.maxMs:
    stats.maxMs = elapsedMs

proc averageMs(stats: StageStats): float =
  if stats.calls <= 0:
    return 0.0
  result = stats.totalMs / float(stats.calls)

template timeVoid(stats: var StageStats; body: untyped) =
  let startedAt = nowMs()
  body
  stats.addSample(nowMs() - startedAt)

# =============================================================================
# === CLI helpers
# =============================================================================

proc usage() =
  echo "usage:"
  echo "  test_network_transcode_pixie_overlay <input-url-or-sdp> <output.mp4> [options]"
  echo ""
  echo "required arguments:"
  echo "  input-url-or-sdp   rtsp://, rtp://, udp://, or .sdp path passed to FFmpeg"
  echo "  output.mp4         MP4 file to write"
  echo ""
  echo "options:"
  echo "  --decoder=NAME                 decoder name. default: h264_v4l2m2m"
  echo "  --encoder=NAME                 encoder name. default: h264_v4l2m2m"
  echo "  --frames=N                     number of decoded source frames to process. default: 300. 0 means until EOF/error"
  echo "  --fps=N or --fps=N/D           nominal output fps used for encoder PTS. default: 20"
  echo "  --bitrate=N                    encoder bitrate. default: 2000000"
  echo "  --tcp                          request RTSP over TCP by setting rtsp_transport=tcp"
  echo "  --udp                          do not force RTSP over TCP"
  echo "  --timeout-usec=N               set FFmpeg input timeout option in usec"
  echo "  --video-only                   add allowed_media_types=video"
  echo "  --rtsp-low-latency             add camera options: video-only, analyzeduration=0, probesize=32, fpsprobesize=0, fflags=nobuffer"
  echo "  --analyzeduration-usec=N       add analyzeduration=N"
  echo "  --probesize=N                  add probesize=N"
  echo "  --fpsprobesize=N               add fpsprobesize=N"
  echo "  --fflags=VALUE                 add fflags=VALUE, e.g. nobuffer"
  echo "  --input-option=KEY=VALUE       add raw FFmpeg input option. Can be repeated. Later values override earlier ones"
  echo "  --owned-decoder-copy           copy decoder I420 into an owned buffer before RGBX conversion"
  echo "  --direct-decoder-rgbx          convert decoder I420 buffer directly into RGBX (default)"
  echo "  --font=PATH                    optional TrueType/OpenType font for Pixie text overlay"
  echo "  --no-text                      draw Pixie boxes only, even if --font is given"
  echo "  --help                         show this help"
  echo ""
  echo "example:"
  echo "  ./test_network_transcode_pixie_overlay 'rtsp://user:pass@192.168.1.10/live' out.mp4 --decoder=h264_v4l2m2m --encoder=h264_v4l2m2m --frames=300 --fps=20 --tcp --timeout-usec=5000000 --rtsp-low-latency --font=/usr/share/fonts/TTF/DejaVuSans.ttf"

proc logStep(message: string) =
  stderr.writeLine(&"[network-transcode-pixie] {message}")

proc splitArgs(args: seq[string]): tuple[positionals: seq[string], flags: seq[string]] =
  for arg in args:
    if arg.startsWith("--"):
      result.flags.add(arg)
    else:
      result.positionals.add(arg)

proc hasFlag(flags: seq[string]; name: string): bool =
  for flag in flags:
    if flag == name:
      return true
  result = false

proc flagValue(flags: seq[string]; prefix: string): tuple[found: bool, value: string] =
  let marker = prefix & "="
  for flag in flags:
    if flag.startsWith(marker):
      return (true, flag[marker.len .. ^1])
  result = (false, "")

proc flagValues(flags: seq[string]; prefix: string): seq[string] =
  let marker = prefix & "="
  for flag in flags:
    if flag.startsWith(marker):
      result.add(flag[marker.len .. ^1])


proc validateFlags(flags: seq[string]) =
  for flag in flags:
    if flag in [
      "--tcp",
      "--udp",
      "--video-only",
      "--rtsp-low-latency",
      "--owned-decoder-copy",
      "--direct-decoder-rgbx",
      "--no-text",
      "--help"
    ]:
      continue

    if flag.startsWith("--decoder=") or
        flag.startsWith("--encoder=") or
        flag.startsWith("--frames=") or
        flag.startsWith("--fps=") or
        flag.startsWith("--bitrate=") or
        flag.startsWith("--timeout-usec=") or
        flag.startsWith("--analyzeduration-usec=") or
        flag.startsWith("--probesize=") or
        flag.startsWith("--fpsprobesize=") or
        flag.startsWith("--fflags=") or
        flag.startsWith("--input-option=") or
        flag.startsWith("--font="):
      continue

    raise newException(IOError, &"Unknown option: {flag}")

proc parseIntFlag(flags: seq[string]; name: string; defaultValue: int): int =
  let value = flags.flagValue(name)
  if not value.found:
    return defaultValue
  result = parseInt(value.value)

proc parseInt64Flag(flags: seq[string]; name: string; defaultValue: int64): int64 =
  let value = flags.flagValue(name)
  if not value.found:
    return defaultValue
  result = parseBiggestInt(value.value).int64

proc parseStringFlag(flags: seq[string]; name, defaultValue: string): string =
  let value = flags.flagValue(name)
  if not value.found:
    return defaultValue
  result = value.value

proc parseVideoRateFlag(flags: seq[string]; name: string; defaultValue: VideoRate): VideoRate =
  let value = flags.flagValue(name)
  if not value.found:
    return defaultValue

  try:
    result = parseVideoRate(value.value)
  except ValueError as e:
    raise newException(IOError, e.msg)

proc decoderRgbxModeName(mode: DecoderRgbxMode): string =
  case mode
  of drmOwnedCopy:
    result = "owned-copy"
  of drmDirect:
    result = "direct"

proc alignUp(value, alignment: int): int =
  if alignment <= 0:
    return value
  result = ((value + alignment - 1) div alignment) * alignment

proc failWith(message: string) =
  raise newException(IOError, message)

proc check[T](ret: FFmpegResult[T]): T =
  if ret.isErr:
    failWith(ret.error.message)
  result = ret.value

proc checkVoid(ret: FFmpegResult[void]) =
  if ret.isErr:
    failWith(ret.error.message)

proc formatMs(value: float): string =
  result = formatFloat(value, ffDecimal, 3)

proc printStage(name: string; stats: StageStats; frameCount: int) =
  let perFrame = if frameCount > 0: stats.totalMs / float(frameCount) else: 0.0
  echo &"  {name:<28} calls={stats.calls:>6} total_ms={stats.totalMs.formatMs():>12} avg_ms={stats.averageMs().formatMs():>10} min_ms={stats.minMs.formatMs():>10} max_ms={stats.maxMs.formatMs():>10} per_frame_ms={perFrame.formatMs():>10}"

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
  printStage("copyDecodedI420ToRGBXDirect", timing.copyDecodedI420ToRGBXDirect, frameCount)
  printStage("pixieOverlay", timing.pixieOverlay, frameCount)
  printStage("beginFrameNV12", timing.beginFrameNV12, frameCount)
  printStage("copyRGBXToNV12Padded", timing.copyRGBXToNV12Padded, frameCount)
  printStage("submitFrame", timing.submitFrame, frameCount)
  printStage("drainTotal", timing.drainTotal, frameCount)
  printStage("receivePacket", timing.receivePacket, frameCount)
  printStage("writePacket", timing.writePacket, frameCount)

# =============================================================================
# === Pixie zero-copy move adapter and overlay
# =============================================================================

static:
  doAssert sizeof(PixelRGBX) == sizeof(ColorRGBX)

proc requirePackedRgbx(frame: OwnedRGBXFrame) =
  if not frame.isValid():
    failWith("RGBX frame is invalid")
  if frame.stridePixels != frame.width:
    failWith(&"Pixie zero-copy adapter requires packed RGBX: stridePixels={frame.stridePixels} width={frame.width}")
  if frame.data.len != frame.width * frame.height:
    failWith(&"Pixie zero-copy adapter requires exact data size: data.len={frame.data.len} expected={frame.width * frame.height}")

proc moveRgbxDataToPixieImage(frame: var OwnedRGBXFrame): Image =
  ## Move OwnedRGBXFrame.data into a Pixie Image.
  ##
  ## This intentionally transfers seq ownership instead of creating an aliasing
  ## seq. After this call, frame.data is moved-out and must not be touched until
  ## movePixieImageDataBack() is called.
  frame.requirePackedRgbx()
  result = Image()
  result.width = frame.width
  result.height = frame.height
  result.data = move cast[ptr seq[ColorRGBX]](addr frame.data)[]

proc movePixieImageDataBack(image: var Image; frame: var OwnedRGBXFrame) =
  ## Move Pixie Image.data back into OwnedRGBXFrame.data.
  frame.data = move cast[ptr seq[PixelRGBX]](addr image.data)[]

proc fillRect(ctx: Context; x, y, w, h: float32; c: ColorRGBX) =
  ctx.fillStyle = c
  ctx.fillRect(rect(vec2(x, y), vec2(w, h)))

proc fillRoundedRect(ctx: Context; x, y, w, h, radius: float32; c: ColorRGBX) =
  ctx.fillStyle = c
  ctx.fillRoundedRect(rect(vec2(x, y), vec2(w, h)), radius)

proc drawBox(ctx: Context; x, y, w, h, thickness: float32; c: ColorRGBX) =
  ## Draw a rectangle outline using Pixie's canvas fillRect path. This avoids
  ## relying on stroke API variants while still keeping drawing inside Pixie.
  let t = max(thickness, 1.0'f32)
  ctx.fillRect(x, y, w, t, c)
  ctx.fillRect(x, y + h - t, w, t, c)
  ctx.fillRect(x, y, t, h, c)
  ctx.fillRect(x + w - t, y, t, h, c)

proc drawCornerBox(ctx: Context; x, y, w, h, thickness: float32; c: ColorRGBX) =
  let t = max(thickness, 1.0'f32)
  let lx = max(24.0'f32, w * 0.18'f32)
  let ly = max(24.0'f32, h * 0.18'f32)

  # top-left
  ctx.fillRect(x, y, lx, t, c)
  ctx.fillRect(x, y, t, ly, c)
  # top-right
  ctx.fillRect(x + w - lx, y, lx, t, c)
  ctx.fillRect(x + w - t, y, t, ly, c)
  # bottom-left
  ctx.fillRect(x, y + h - t, lx, t, c)
  ctx.fillRect(x, y + h - ly, t, ly, c)
  # bottom-right
  ctx.fillRect(x + w - lx, y + h - t, lx, t, c)
  ctx.fillRect(x + w - t, y + h - ly, t, ly, c)

proc drawPixieOverlay(
    frame: var OwnedRGBXFrame;
    frameIndex: int;
    maxFrames: int;
    fps: VideoRate;
    font: Font;
    drawText: bool
  ) =
  var target = moveRgbxDataToPixieImage(frame)

  try:
    let ctx = newContext(target)
    let w = float32(target.width)
    let h = float32(target.height)
    let pulse = float32((frameIndex * 7) mod 120)
    let movingX = 80.0'f32 + pulse
    let movingY = 90.0'f32 + float32((frameIndex * 3) mod 60)

    # Semi-transparent status panel.
    ctx.fillRoundedRect(18, 18, 520, 92, 14, rgba(0, 0, 0, 120))
    ctx.fillRoundedRect(24, 24, 508, 80, 10, rgba(0, 80, 180, 70))

    # Detection-like boxes drawn through Pixie.
    ctx.drawCornerBox(movingX, movingY, 430, 270, 5, rgba(0, 255, 80, 230))
    ctx.drawBox(w - 560, h - 420, 420, 300, 4, rgba(255, 64, 64, 230))
    ctx.fillRoundedRect(w - 560, h - 454, 260, 34, 8, rgba(255, 64, 64, 150))

    # A translucent progress bar at the bottom.
    let barX = 32.0'f32
    let barY = h - 42.0'f32
    let barW = w - 64.0'f32
    let barH = 14.0'f32
    ctx.fillRoundedRect(barX, barY, barW, barH, 7, rgba(0, 0, 0, 130))
    let progress = if maxFrames > 0: min(1.0'f32, float32(frameIndex + 1) / float32(maxFrames)) else: float32((frameIndex mod 120) + 1) / 120.0'f32
    ctx.fillRoundedRect(barX, barY, barW * progress, barH, 7, rgba(0, 200, 255, 220))

    if drawText and not font.isNil:
      var overlayFont = font
      overlayFont.size = 28
      overlayFont.paint.color = color(1, 1, 1, 1)
      let text = &"AtomCam2 RTSP  frame={frameIndex}  fps={fps.rateText()}"
      target.fillText(
        overlayFont.typeset(text, bounds = vec2(490, 40)),
        translate(vec2(34.0'f32, 38.0'f32))
      )

      overlayFont.size = 18
      overlayFont.paint.color = color(1, 1, 1, 1)
      target.fillText(
        overlayFont.typeset("Pixie zero-copy overlay", bounds = vec2(260, 28)),
        translate(vec2(w - 548, h - 448))
      )
  finally:
    movePixieImageDataBack(target, frame)

# =============================================================================
# === Decode / encode helpers
# =============================================================================

proc convertDecodedFrameToRgbxTimed(
    frame: Yuv420FrameView;
    ownedI420: var OwnedI420Frame;
    rgbx: var OwnedRGBXFrame;
    mode: DecoderRgbxMode;
    timing: var PipelineTiming
  ) =
  case mode
  of drmOwnedCopy:
    timeVoid(timing.copyDecodedI420ToOwned):
      checkVoid(copyI420(frame, ownedI420))
    timeVoid(timing.copyOwnedI420ToRGBX):
      checkVoid(copyI420ToRGBX(ownedI420, rgbx))
  of drmDirect:
    timeVoid(timing.copyDecodedI420ToRGBXDirect):
      checkVoid(copyI420ToRGBX(frame, rgbx))

proc readFrameIntoRgbxTimed(
    decoder: VideoDecoder;
    ownedI420: var OwnedI420Frame;
    rgbx: var OwnedRGBXFrame;
    mode: DecoderRgbxMode;
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
  convertDecodedFrameToRgbxTimed(read.frame, ownedI420, rgbx, mode, timing)

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

proc encodeRgbxFrameNv12Timed(
    encoder: VideoEncoder;
    writer: Mp4VideoWriter;
    rgbx: OwnedRGBXFrame;
    frameIndex: int64;
    timing: var PipelineTiming;
    packets: var int;
    packetBytes: var int64
  ) =
  var writable: WritableNV12FrameView
  timeVoid(timing.beginFrameNV12):
    writable = check(encoder.beginFrameNV12(frameIndex))

  timeVoid(timing.copyRGBXToNV12Padded):
    checkVoid(copyRGBXToNV12Padded(rgbx, writable))

  timeVoid(timing.submitFrame):
    checkVoid(encoder.submitFrame())

  drainEncoderTimed(encoder, writer, timing, packets, packetBytes)

# =============================================================================
# === main
# =============================================================================

proc main() =
  let rawArgs = commandLineParams()
  let split = splitArgs(rawArgs)
  let args = split.positionals
  let flags = split.flags

  if flags.hasFlag("--help"):
    usage()
    quit(0)

  validateFlags(flags)

  if args.len < 2:
    usage()
    quit(1)

  if flags.hasFlag("--tcp") and flags.hasFlag("--udp"):
    failWith("--tcp and --udp are mutually exclusive")

  if flags.hasFlag("--owned-decoder-copy") and flags.hasFlag("--direct-decoder-rgbx"):
    failWith("--owned-decoder-copy and --direct-decoder-rgbx are mutually exclusive")

  let inputPath = args[0]
  let outputPath = args[1]
  let decoderName = parseStringFlag(flags, "--decoder", "h264_v4l2m2m")
  let encoderName = parseStringFlag(flags, "--encoder", "h264_v4l2m2m")
  let maxFrames = parseIntFlag(flags, "--frames", 300)
  let fps = parseVideoRateFlag(flags, "--fps", initVideoRate(20))
  let bitrate = parseIntFlag(flags, "--bitrate", 2_000_000)
  let rtspTransportTcp = flags.hasFlag("--tcp")
  let timeoutUsec = parseInt64Flag(flags, "--timeout-usec", 0'i64)
  let decoderRgbxMode = if flags.hasFlag("--owned-decoder-copy"): drmOwnedCopy else: drmDirect
  let fontPath = parseStringFlag(flags, "--font", "")
  let drawText = not flags.hasFlag("--no-text")

  if maxFrames < 0:
    failWith(&"Invalid frame count: {maxFrames}")
  if bitrate <= 0:
    failWith(&"Invalid bitrate: {bitrate}")

  var inputOptions: seq[DecoderInputOption]
  if flags.hasFlag("--rtsp-low-latency"):
    inputOptions.addRtspLowLatencyOptions()
  if flags.hasFlag("--video-only"):
    inputOptions.setInputOption("allowed_media_types", "video")

  let analyzedurationUsec = flags.flagValue("--analyzeduration-usec")
  if analyzedurationUsec.found:
    discard parseBiggestInt(analyzedurationUsec.value)
    inputOptions.setInputOption("analyzeduration", analyzedurationUsec.value)

  let probesize = flags.flagValue("--probesize")
  if probesize.found:
    discard parseBiggestInt(probesize.value)
    inputOptions.setInputOption("probesize", probesize.value)

  let fpsProbeSize = flags.flagValue("--fpsprobesize")
  if fpsProbeSize.found:
    discard parseBiggestInt(fpsProbeSize.value)
    inputOptions.setInputOption("fpsprobesize", fpsProbeSize.value)

  let fflags = flags.flagValue("--fflags")
  if fflags.found:
    inputOptions.setInputOption("fflags", fflags.value)

  for value in flags.flagValues("--input-option"):
    let item = parseInputOption(value)
    inputOptions.setInputOption(item.key, item.value)

  var font: Font = nil
  if fontPath.len > 0:
    logStep(&"loading Pixie font: {fontPath}")
    font = readFont(fontPath)

  var timing: PipelineTiming
  let totalStartedAt = nowMs()

  logStep(&"opening decoder: input={inputPath} decoder={decoderName}")
  if rtspTransportTcp:
    logStep("requesting RTSP over TCP")
  if timeoutUsec > 0:
    logStep(&"using input timeout: {timeoutUsec} usec")
  if flags.hasFlag("--rtsp-low-latency"):
    logStep("using RTSP low-latency camera option preset")
  for item in inputOptions:
    logStep(&"input option: {item.key}={item.value}")

  var decoder: VideoDecoder
  timeVoid(timing.decoderOpen):
    decoder = check(openVideoDecoder(
      inputPath,
      DecoderOptions(
        decoderName: decoderName,
        rtspTransportTcp: rtspTransportTcp,
        timeoutUsec: timeoutUsec,
        inputOptions: inputOptions
      )
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
  let encoderHeight = alignUp(height, 16)

  logStep(&"first frame decoded: {width}x{height}")
  logStep(&"decoder RGBX conversion mode: {decoderRgbxMode.decoderRgbxModeName()}")
  logStep(&"nominal output fps: {fps.rateText()} ({fps.rateFloat():.3f})")
  if encoderHeight != height:
    logStep(&"using padded NV12 encoder frame height: visible={height} storage={encoderHeight}")

  var ownedI420 = check(newOwnedI420Frame(width, height))
  var rgbx = check(newOwnedRGBXFrame(width, height))

  convertDecodedFrameToRgbxTimed(firstRead.frame, ownedI420, rgbx, decoderRgbxMode, timing)

  logStep(&"owned I420 buffer allocated: {ownedI420.byteSize()} bytes")
  logStep(&"owned RGBX buffer allocated: {rgbx.byteSize()} bytes")

  logStep(&"opening encoder with padded NV12 input: {encoderName}")
  var encoder: VideoEncoder
  timeVoid(timing.encoderOpen):
    encoder = check(openVideoEncoder(VideoEncoderOptions(
      encoderName: encoderName,
      width: width,
      height: encoderHeight,
      pixelFormat: pfNv12,
      timeBase: fps.timeBase(),
      framerate: fps.frameRate(),
      bitRate: bitrate,
      gopSize: fps.gopSize(),
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

  logStep("drawing and encoding first frame")
  timeVoid(timing.pixieOverlay):
    drawPixieOverlay(rgbx, decodedFrames, maxFrames, fps, font, drawText)
  encodeRgbxFrameNv12Timed(encoder, writer, rgbx, int64(decodedFrames), timing, packets, packetBytes)
  inc decodedFrames

  var eof = false
  while not eof:
    if maxFrames > 0 and decodedFrames >= maxFrames:
      break

    if decodedFrames mod 30 == 0:
      logStep(&"processing frame {decodedFrames}")

    readFrameIntoRgbxTimed(decoder, ownedI420, rgbx, decoderRgbxMode, timing, eof)
    if eof:
      logStep("decoder reached EOF")
      break

    timeVoid(timing.pixieOverlay):
      drawPixieOverlay(rgbx, decodedFrames, maxFrames, fps, font, drawText)

    encodeRgbxFrameNv12Timed(encoder, writer, rgbx, int64(decodedFrames), timing, packets, packetBytes)
    inc decodedFrames

  logStep("flushing encoder")
  timeVoid(timing.encoderFlush):
    checkVoid(encoder.flush())
  drainEncoderTimed(encoder, writer, timing, packets, packetBytes)

  logStep("finishing MP4 writer")
  timeVoid(timing.writerFinish):
    checkVoid(writer.finish())

  let totalMs = nowMs() - totalStartedAt
  let effectiveFps = if totalMs > 0.0: float(decodedFrames) * 1000.0 / totalMs else: 0.0
  let transportName = if rtspTransportTcp: "rtsp-tcp" else: "default"

  echo "network transcode Pixie overlay timing result:"
  echo &"  input        : {inputPath}"
  echo &"  output       : {outputPath}"
  echo &"  decoder      : {decoderName}"
  echo &"  encoder      : {encoderName}"
  echo &"  transport    : {transportName}"
  echo &"  timeout usec : {timeoutUsec}"
  echo &"  decoder RGBX : {decoderRgbxMode.decoderRgbxModeName()}"
  echo &"  visible size : {width}x{height}"
  echo &"  encoder size : {width}x{encoderHeight}"
  echo &"  nominal fps  : {fps.rateText()}"
  echo &"  bitrate      : {bitrate}"
  echo &"  frames       : {decodedFrames}"
  echo &"  packets      : {packets}"
  echo &"  packet bytes : {packetBytes}"
  echo &"  i420 bytes   : {ownedI420.byteSize()}"
  echo &"  rgbx bytes   : {rgbx.byteSize()}"
  echo &"  total ms     : {totalMs.formatMs()}"
  echo &"  effective fps: {effectiveFps.formatMs()}"

  printTimingSummary(timing, decodedFrames, packets)

when isMainModule:
  try:
    main()
  except CatchableError as e:
    stderr.writeLine(&"[network-transcode-pixie] ERROR: {e.msg}")
    quit(1)
