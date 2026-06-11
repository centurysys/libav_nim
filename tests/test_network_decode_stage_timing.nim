# tests/test_network_decode_stage_timing.nim
#
# Open an RTSP/RTP/SDP/network input through FFmpeg, decode video frames,
# convert decoded YUV420P frames into RGBX, and report stage timing.
#
# This test intentionally stops at RGBX. It is meant to evaluate network input
# behavior before building higher-level DecoderWorker/CodecPipe APIs.

import std/[os, strformat, strutils, times]
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
    readFrame: StageStats
    copyDecodedI420ToOwned: StageStats
    copyOwnedI420ToRGBX: StageStats
    copyDecodedI420ToRGBXDirect: StageStats

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
# === CLI helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- usage
# -----------------------------------------------------------------------------

proc usage() =
  echo "usage:"
  echo "  test_network_decode_stage_timing <input-url-or-sdp> [decoder] [maxFrames] [options]"
  echo ""
  echo "arguments:"
  echo "  input-url-or-sdp  rtsp://, rtp://, udp://, or .sdp path passed to FFmpeg"
  echo "  decoder           decoder name. default: h264_v4l2m2m"
  echo "  maxFrames         frames to decode. default: 300. 0 means until EOF/error."
  echo ""
  echo "options:"
  echo "  --tcp                         request RTSP over TCP by setting rtsp_transport=tcp"
  echo "  --udp                         do not force RTSP over TCP"
  echo "  --timeout-usec=N              set FFmpeg input timeout option in usec"
  echo "  --video-only                  add allowed_media_types=video"
  echo "  --rtsp-low-latency           add common RTSP camera options: video-only, analyzeduration=0, probesize=32, fpsprobesize=0, fflags=nobuffer"
  echo "  --analyzeduration-usec=N      add analyzeduration=N"
  echo "  --probesize=N                 add probesize=N"
  echo "  --fpsprobesize=N              add fpsprobesize=N"
  echo "  --fflags=VALUE                add fflags=VALUE, e.g. nobuffer"
  echo "  --input-option=KEY=VALUE      add raw FFmpeg input option. Can be repeated. Later values override earlier ones."
  echo "  --owned-decoder-copy          copy decoder I420 into an owned buffer before RGBX conversion"
  echo "  --direct-decoder-rgbx         convert decoder I420 buffer directly into RGBX (default)"
  echo "  --dump-decoder-frame-info     print the first decoded YUV420 frame view information"
  echo "  --help                        show this help"
  echo ""
  echo "examples:"
  echo "  ./test_network_decode_stage_timing rtsp://192.168.1.10/live h264_v4l2m2m 300 --tcp --timeout-usec=5000000 --rtsp-low-latency"
  echo "  ./test_network_decode_stage_timing rtsp://192.168.1.10/live h264 300 --tcp --timeout-usec=5000000 --rtsp-low-latency"
  echo "  ./test_network_decode_stage_timing rtp://0.0.0.0:5004 h264_v4l2m2m 300 --input-option=protocol_whitelist=file,udp,rtp"
  echo "  ./test_network_decode_stage_timing stream.sdp h264_v4l2m2m 300 --input-option=protocol_whitelist=file,udp,rtp"

# -----------------------------------------------------------------------------
# --- logStep
# -----------------------------------------------------------------------------

proc logStep(message: string) =
  stderr.writeLine(&"[network-decode-timing] {message}")

# -----------------------------------------------------------------------------
# --- splitArgs
# -----------------------------------------------------------------------------

proc splitArgs(args: seq[string]): tuple[positionals: seq[string], flags: seq[string]] =
  for arg in args:
    if arg.startsWith("--"):
      result.flags.add(arg)
    else:
      result.positionals.add(arg)

# -----------------------------------------------------------------------------
# --- hasFlag
# -----------------------------------------------------------------------------

proc hasFlag(flags: seq[string]; name: string): bool =
  for flag in flags:
    if flag == name:
      return true

  result = false

# -----------------------------------------------------------------------------
# --- flagValue
# -----------------------------------------------------------------------------

proc flagValue(flags: seq[string]; prefix: string): tuple[found: bool, value: string] =
  let marker = prefix & "="
  for flag in flags:
    if flag.startsWith(marker):
      result = (true, flag[marker.len .. ^1])
      return

  result = (false, "")

# -----------------------------------------------------------------------------
# --- flagValues
# -----------------------------------------------------------------------------

proc flagValues(flags: seq[string]; prefix: string): seq[string] =
  let marker = prefix & "="
  for flag in flags:
    if flag.startsWith(marker):
      result.add(flag[marker.len .. ^1])

# -----------------------------------------------------------------------------
# --- validateFlags
# -----------------------------------------------------------------------------

proc validateFlags(flags: seq[string]) =
  for flag in flags:
    if flag in [
      "--tcp",
      "--udp",
      "--video-only",
      "--rtsp-low-latency",
      "--owned-decoder-copy",
      "--direct-decoder-rgbx",
      "--dump-decoder-frame-info",
      "--help"
    ]:
      continue

    if flag.startsWith("--timeout-usec="):
      continue

    if flag.startsWith("--analyzeduration-usec="):
      continue

    if flag.startsWith("--probesize="):
      continue

    if flag.startsWith("--fpsprobesize="):
      continue

    if flag.startsWith("--fflags="):
      continue

    if flag.startsWith("--input-option="):
      continue

    raise newException(IOError, &"Unknown option: {flag}")

# -----------------------------------------------------------------------------
# --- parseIntArg
# -----------------------------------------------------------------------------

proc parseIntArg(args: seq[string]; index: int; defaultValue: int): int =
  if index >= args.len:
    result = defaultValue
    return

  result = parseInt(args[index])

# -----------------------------------------------------------------------------
# --- parseInt64Flag
# -----------------------------------------------------------------------------

proc parseInt64Flag(flags: seq[string]; name: string; defaultValue: int64): int64 =
  let value = flags.flagValue(name)
  if not value.found:
    result = defaultValue
    return

  result = parseBiggestInt(value.value).int64

# -----------------------------------------------------------------------------
# --- decoderRgbxModeName
# -----------------------------------------------------------------------------

proc decoderRgbxModeName(mode: DecoderRgbxMode): string =
  case mode
  of drmOwnedCopy:
    result = "owned-copy"
  of drmDirect:
    result = "direct"

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

  echo &"  {name:<28} calls={stats.calls:>6} total_ms={stats.totalMs.formatMs():>12} avg_ms={stats.averageMs().formatMs():>10} min_ms={stats.minMs.formatMs():>10} max_ms={stats.maxMs.formatMs():>10} per_frame_ms={perFrame.formatMs():>10}"

# -----------------------------------------------------------------------------
# --- printTimingSummary
# -----------------------------------------------------------------------------

proc printTimingSummary(timing: PipelineTiming; frameCount: int) =
  echo ""
  echo "stage timing summary:"
  echo &"  measured frames : {frameCount}"
  echo ""
  echo "  one-time / setup stages:"
  printStage("decoderOpen", timing.decoderOpen, frameCount)
  printStage("firstReadFrame", timing.firstReadFrame, frameCount)
  echo ""
  echo "  per-frame decode stages:"
  printStage("readFrame", timing.readFrame, frameCount)
  printStage("copyDecodedI420ToOwned", timing.copyDecodedI420ToOwned, frameCount)
  printStage("copyOwnedI420ToRGBX", timing.copyOwnedI420ToRGBX, frameCount)
  printStage("copyDecodedI420ToRGBXDirect", timing.copyDecodedI420ToRGBXDirect, frameCount)

# =============================================================================
# === Frame dump helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- ptrHex
# -----------------------------------------------------------------------------

proc ptrHex(p: pointer): string =
  if p.isNil:
    result = "nil"
  else:
    result = "0x" & toHex(cast[uint](p))

# -----------------------------------------------------------------------------
# --- planeDelta
# -----------------------------------------------------------------------------

proc planeDelta(base, p: pointer): string =
  if base.isNil or p.isNil:
    result = "n/a"
    return

  let b = cast[uint](base)
  let x = cast[uint](p)
  if x >= b:
    result = &"+{x - b}"
  else:
    result = &"-{b - x}"

# -----------------------------------------------------------------------------
# --- timestampText
# -----------------------------------------------------------------------------

proc timestampText(timestamp: FrameTimestamp): string =
  var seconds: float64
  if timestamp.timestampSeconds(seconds):
    result = &"selected={timestamp.selectedTimestamp()} source={timestamp.source.timestampSourceName()} seconds={seconds:.6f} timeBase={timestamp.timeBase.num}/{timestamp.timeBase.den}"
  else:
    result = &"selected={timestamp.selectedTimestamp()} source={timestamp.source.timestampSourceName()} seconds=n/a timeBase={timestamp.timeBase.num}/{timestamp.timeBase.den}"

# -----------------------------------------------------------------------------
# --- dumpYuv420FrameView
# -----------------------------------------------------------------------------

proc dumpYuv420FrameView(frame: Yuv420FrameView; label: string) =
  let chromaH = (frame.height + 1) div 2
  echo &"[network-decode-timing] {label}:"
  echo "  borrowed Yuv420FrameView:"
  echo &"    size       : {frame.width}x{frame.height}"
  echo &"    format     : {frame.format.pixelFormatName()}"
  echo &"    y          : {ptrHex(frame.y)}"
  echo &"    u          : {ptrHex(frame.u)}"
  echo &"    v          : {ptrHex(frame.v)}"
  echo &"    yStride    : {frame.yStride}"
  echo &"    uStride    : {frame.uStride}"
  echo &"    vStride    : {frame.vStride}"
  echo &"    u-y        : {planeDelta(frame.y, frame.u)}"
  echo &"    v-y        : {planeDelta(frame.y, frame.v)}"
  echo &"    v-u        : {planeDelta(frame.u, frame.v)}"
  echo &"    timestamp  : {frame.timestamp.timestampText()}"
  echo "    visible byte estimates:"
  echo &"      Y        : {frame.yStride * frame.height}"
  echo &"      U        : {frame.uStride * chromaH}"
  echo &"      V        : {frame.vStride * chromaH}"
  echo &"      total    : {frame.yStride * frame.height + frame.uStride * chromaH + frame.vStride * chromaH}"

var decoderFrameInfoDumped = false

# -----------------------------------------------------------------------------
# --- dumpYuv420FrameViewOnce
# -----------------------------------------------------------------------------

proc dumpYuv420FrameViewOnce(frame: Yuv420FrameView; label: string) =
  if decoderFrameInfoDumped:
    return

  decoderFrameInfoDumped = true
  dumpYuv420FrameView(frame, label)

# =============================================================================
# === Decode helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- convertDecodedFrameToRgbxTimed
# -----------------------------------------------------------------------------

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

# -----------------------------------------------------------------------------
# --- readFrameIntoRgbxTimed
# -----------------------------------------------------------------------------

proc readFrameIntoRgbxTimed(
    decoder: VideoDecoder;
    ownedI420: var OwnedI420Frame;
    rgbx: var OwnedRGBXFrame;
    mode: DecoderRgbxMode;
    dumpDecoderFrameInfo: bool;
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

  if dumpDecoderFrameInfo:
    dumpYuv420FrameViewOnce(read.frame, "decoded frame before RGBX conversion")

  convertDecodedFrameToRgbxTimed(read.frame, ownedI420, rgbx, mode, timing)

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

  if args.len < 1:
    usage()
    quit(1)

  if flags.hasFlag("--tcp") and flags.hasFlag("--udp"):
    failWith("--tcp and --udp are mutually exclusive")

  if flags.hasFlag("--owned-decoder-copy") and flags.hasFlag("--direct-decoder-rgbx"):
    failWith("--owned-decoder-copy and --direct-decoder-rgbx are mutually exclusive")

  let inputPath = args[0]
  let decoderName = if args.len >= 2: args[1] else: "h264_v4l2m2m"
  let maxFrames = parseIntArg(args, 2, 300)
  let rtspTransportTcp = flags.hasFlag("--tcp")
  let timeoutUsec = parseInt64Flag(flags, "--timeout-usec", 0'i64)
  let decoderRgbxMode = if flags.hasFlag("--owned-decoder-copy"): drmOwnedCopy else: drmDirect
  let dumpDecoderFrameInfo = flags.hasFlag("--dump-decoder-frame-info")

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

  # Apply raw options last so callers can override the convenience presets.
  for value in flags.flagValues("--input-option"):
    let item = parseInputOption(value)
    inputOptions.setInputOption(item.key, item.value)

  if maxFrames < 0:
    failWith(&"Invalid maxFrames: {maxFrames}")

  var timing: PipelineTiming

  logStep(&"opening decoder: input={inputPath} decoder={decoderName}")
  if rtspTransportTcp:
    logStep("requesting RTSP over TCP")
  if timeoutUsec > 0:
    logStep(&"using input timeout: {timeoutUsec} usec")
  if flags.hasFlag("--rtsp-low-latency"):
    logStep("using RTSP low-latency camera option preset")
  for item in inputOptions:
    logStep(&"input option: {item.key}={item.value}")

  let totalStartedAt = nowMs()

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

  logStep(&"first frame decoded: {width}x{height}")
  logStep(&"decoder RGBX conversion mode: {decoderRgbxMode.decoderRgbxModeName()}")

  var ownedI420 = check(newOwnedI420Frame(width, height))
  var rgbx = check(newOwnedRGBXFrame(width, height))

  if dumpDecoderFrameInfo:
    dumpYuv420FrameViewOnce(firstRead.frame, "first decoded frame before RGBX conversion")

  convertDecodedFrameToRgbxTimed(firstRead.frame, ownedI420, rgbx, decoderRgbxMode, timing)

  logStep(&"owned I420 buffer allocated: {ownedI420.byteSize()} bytes")
  logStep(&"owned RGBX buffer allocated: {rgbx.byteSize()} bytes")

  var frames = 1
  var eof = false

  while not eof:
    if maxFrames > 0 and frames >= maxFrames:
      break

    readFrameIntoRgbxTimed(
      decoder,
      ownedI420,
      rgbx,
      decoderRgbxMode,
      dumpDecoderFrameInfo,
      timing,
      eof
    )

    if eof:
      break

    inc frames

  let totalMs = nowMs() - totalStartedAt
  let effectiveFps = if totalMs > 0.0: float(frames) * 1000.0 / totalMs else: 0.0

  let transportName = if rtspTransportTcp: "rtsp-tcp" else: "default"

  echo "network decode RGBX stage timing result:"
  echo &"  input        : {inputPath}"
  echo &"  decoder      : {decoderName}"
  echo &"  transport    : {transportName}"
  echo &"  timeout usec : {timeoutUsec}"
  echo &"  decoder RGBX : {decoderRgbxMode.decoderRgbxModeName()}"
  echo &"  visible size : {width}x{height}"
  echo &"  frames       : {frames}"
  echo &"  i420 bytes   : {ownedI420.byteSize()}"
  echo &"  rgbx bytes   : {rgbx.byteSize()}"
  echo &"  total ms     : {totalMs.formatMs()}"
  echo &"  effective fps: {effectiveFps.formatMs()}"

  printTimingSummary(timing, frames)

when isMainModule:
  try:
    main()
  except CatchableError as e:
    stderr.writeLine(&"[network-decode-timing] ERROR: {e.msg}")
    quit(1)
