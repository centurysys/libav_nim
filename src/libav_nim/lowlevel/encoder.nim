# libav_nim/encoder.nim
#
# Result-based video encoder wrapper built on libavcodec and libavutil.

import std/strformat
import results
import ./bindings/c_api
import ./error
import ./frame
import ./packet
import ./types

# =============================================================================
# === FFmpeg local constants
# =============================================================================

const
  avCodecFlagGlobalHeader = 1 shl 22

# =============================================================================
# === Encoder options
# =============================================================================

type
  VideoEncoderOptions* = object
    ## Options for opening an output video encoder.
    ##
    ## The first target is raw H.264 elementary stream output with h264_v4l2m2m.
    encoderName*: string
    width*: int
    height*: int
    pixelFormat*: PixelFormat
    timeBase*: Rational
    framerate*: Rational
    bitRate*: int64
    gopSize*: int
    maxBFrames*: int
    globalHeader*: bool
    frameAlign*: int

# =============================================================================
# === Encoder owner
# =============================================================================

type
  VideoEncoder* = ref object
    codecCtx*: AVCodecContextPtr
    frame*: Frame
    packet*: Packet
    timeBase*: Rational
    width*: int
    height*: int
    framePrepared*: bool
    submittedFrames*: int64
    flushed*: bool

# =============================================================================
# === Receive-packet result
# =============================================================================

type
  EncodedPacketRead* = object
    ## Result value returned by receivePacket().
    ##
    ## packet is a borrowed view. It remains valid only until the next
    ## receivePacket(), packet unref, encoder flush/close, or encoder reuse.
    hasPacket*: bool
    flushed*: bool
    packet*: EncodedPacketView
    avPacket*: AVPacketPtr

# =============================================================================
# === Internal helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- defaultEncoderName
# -----------------------------------------------------------------------------

proc defaultEncoderName(options: VideoEncoderOptions): string =
  if options.encoderName.len > 0:
    result = options.encoderName
    return

  result = "h264_v4l2m2m"

# -----------------------------------------------------------------------------
# --- effectivePixelFormat
# -----------------------------------------------------------------------------

proc effectivePixelFormat(options: VideoEncoderOptions): PixelFormat =
  if options.pixelFormat == pfUnknown:
    result = pfYuv420p
    return

  result = options.pixelFormat

# -----------------------------------------------------------------------------
# --- effectiveTimeBase
# -----------------------------------------------------------------------------

proc effectiveTimeBase(options: VideoEncoderOptions): Rational =
  if options.timeBase.isValid():
    result = options.timeBase
    return

  result = Rational(num: 1, den: 30)

# -----------------------------------------------------------------------------
# --- effectiveFramerate
# -----------------------------------------------------------------------------

proc effectiveFramerate(options: VideoEncoderOptions; timeBase: Rational): Rational =
  if options.framerate.isValid():
    result = options.framerate
    return

  if timeBase.num > 0 and timeBase.den > 0:
    result = Rational(num: timeBase.den, den: timeBase.num)
    return

  result = Rational(num: 30, den: 1)

# -----------------------------------------------------------------------------
# --- effectiveBitRate
# -----------------------------------------------------------------------------

proc effectiveBitRate(options: VideoEncoderOptions): int64 =
  if options.bitRate > 0:
    result = options.bitRate
    return

  result = 2_000_000'i64

# -----------------------------------------------------------------------------
# --- effectiveGopSize
# -----------------------------------------------------------------------------

proc effectiveGopSize(options: VideoEncoderOptions): int =
  if options.gopSize > 0:
    result = options.gopSize
    return

  result = 30

# -----------------------------------------------------------------------------
# --- effectiveFrameAlign
# -----------------------------------------------------------------------------

proc effectiveFrameAlign(options: VideoEncoderOptions): int =
  if options.frameAlign > 0:
    result = options.frameAlign
    return

  result = 32

# -----------------------------------------------------------------------------
# --- rawPixelFormat
# -----------------------------------------------------------------------------

proc rawPixelFormat(format: PixelFormat): FFmpegResult[AVPixelFormat] =
  case format
  of pfYuv420p:
    result = ok(AV_PIX_FMT_YUV420P)
  of pfNv12:
    result = ok(AV_PIX_FMT_NV12)
  else:
    result = fail[AVPixelFormat](
      "rawPixelFormat",
      &"Unsupported encoder pixel format: {format.pixelFormatName()}"
    )

# -----------------------------------------------------------------------------
# --- selectEncoder
# -----------------------------------------------------------------------------

proc selectEncoder(name: string): FFmpegResult[AVCodecPtr] =
  let encoder = avcodec_find_encoder_by_name(name.cstring)
  if encoder.isNil:
    result = fail[AVCodecPtr]("selectEncoder", &"Encoder not found: {name}")
    return

  result = ok(encoder)

# -----------------------------------------------------------------------------
# --- configureFrame
# -----------------------------------------------------------------------------

proc configureFrame(
    frame: Frame;
    width: int;
    height: int;
    format: AVPixelFormat;
    timeBase: Rational
  ): FFmpegResult[void] =
  let rawRet = frame.requireOpen()
  if rawRet.isErr:
    result = err(rawRet.error)
    return

  let raw = rawRet.value
  raw[].format = cint(format)
  raw[].width = cint(width)
  raw[].height = cint(height)
  raw[].time_base = timeBase.toAVRational()

  result = ok()

# =============================================================================
# === Encoder lifecycle
# =============================================================================

# -----------------------------------------------------------------------------
# --- close
# -----------------------------------------------------------------------------

proc close*(encoder: VideoEncoder) =
  if encoder.isNil:
    return

  if not encoder.packet.isNil:
    encoder.packet.close()
    encoder.packet = nil

  if not encoder.frame.isNil:
    encoder.frame.close()
    encoder.frame = nil

  if not encoder.codecCtx.isNil:
    var codecCtx = encoder.codecCtx
    avcodec_free_context(addr codecCtx)
    encoder.codecCtx = nil

# -----------------------------------------------------------------------------
# --- openVideoEncoder
# -----------------------------------------------------------------------------

proc openVideoEncoder*(options: VideoEncoderOptions): FFmpegResult[VideoEncoder] =
  if options.width <= 0 or options.height <= 0:
    result = fail[VideoEncoder](
      "openVideoEncoder",
      &"Invalid encoder size: {options.width}x{options.height}"
    )
    return

  let pixelFormat = options.effectivePixelFormat()
  let rawFormatRet = pixelFormat.rawPixelFormat()
  if rawFormatRet.isErr:
    result = err(rawFormatRet.error)
    return

  let encoderName = options.defaultEncoderName()
  let codecRet = selectEncoder(encoderName)
  if codecRet.isErr:
    result = err(codecRet.error)
    return

  let codec = codecRet.value
  var codecCtx = avcodec_alloc_context3(codec)
  if codecCtx.isNil:
    result = fail[VideoEncoder]("avcodec_alloc_context3", "allocation failed")
    return

  let timeBase = options.effectiveTimeBase()
  let framerate = options.effectiveFramerate(timeBase)

  codecCtx[].codec_type = AVMEDIA_TYPE_VIDEO
  codecCtx[].codec_id = codec[].id
  codecCtx[].width = cint(options.width)
  codecCtx[].height = cint(options.height)
  codecCtx[].pix_fmt = rawFormatRet.value
  codecCtx[].time_base = timeBase.toAVRational()
  codecCtx[].framerate = framerate.toAVRational()
  codecCtx[].bit_rate = options.effectiveBitRate()
  codecCtx[].gop_size = cint(options.effectiveGopSize())
  codecCtx[].max_b_frames = cint(options.maxBFrames)
  if options.globalHeader:
    codecCtx[].flags = codecCtx[].flags or avCodecFlagGlobalHeader

  let openRet = okAv(avcodec_open2(codecCtx, codec, nil), &"avcodec_open2({encoderName})")
  if openRet.isErr:
    result = err(openRet.error)
    var tmpCodecCtx = codecCtx
    avcodec_free_context(addr tmpCodecCtx)
    return

  let frameRet = newFrame()
  if frameRet.isErr:
    result = err(frameRet.error)
    var tmpCodecCtx = codecCtx
    avcodec_free_context(addr tmpCodecCtx)
    return

  let frame = frameRet.value
  let configureRet = frame.configureFrame(options.width, options.height, rawFormatRet.value, timeBase)
  if configureRet.isErr:
    result = err(configureRet.error)
    frame.close()
    var tmpCodecCtx = codecCtx
    avcodec_free_context(addr tmpCodecCtx)
    return

  let bufferRet = frame.getBuffer(options.effectiveFrameAlign())
  if bufferRet.isErr:
    result = err(bufferRet.error)
    frame.close()
    var tmpCodecCtx = codecCtx
    avcodec_free_context(addr tmpCodecCtx)
    return

  let packetRet = newPacket()
  if packetRet.isErr:
    result = err(packetRet.error)
    frame.close()
    var tmpCodecCtx = codecCtx
    avcodec_free_context(addr tmpCodecCtx)
    return

  result = ok(VideoEncoder(
    codecCtx: codecCtx,
    frame: frame,
    packet: packetRet.value,
    timeBase: timeBase,
    width: options.width,
    height: options.height,
    framePrepared: false,
    submittedFrames: 0,
    flushed: false
  ))

# =============================================================================
# === Encoder state
# =============================================================================

# -----------------------------------------------------------------------------
# --- isOpen
# -----------------------------------------------------------------------------

proc isOpen*(encoder: VideoEncoder): bool =
  result = not encoder.isNil and not encoder.codecCtx.isNil

# -----------------------------------------------------------------------------
# --- requireOpen
# -----------------------------------------------------------------------------

proc requireOpen*(encoder: VideoEncoder): FFmpegResult[AVCodecContextPtr] =
  if not encoder.isOpen():
    result = fail[AVCodecContextPtr]("VideoEncoder.requireOpen", "VideoEncoder is closed")
    return

  result = ok(encoder.codecCtx)

# -----------------------------------------------------------------------------
# --- encodedStreamInfo
# -----------------------------------------------------------------------------

proc encodedStreamInfo*(encoder: VideoEncoder): FFmpegResult[EncodedStreamInfo] =
  ## Copy codec parameters that are needed to create a later MP4 writer for
  ## already-encoded packets.
  ##
  ## This is intentionally a byte-preserving copy for extradata. It does not
  ## attempt to parse or regenerate H.264 SPS/PPS.
  let codecCtxRet = encoder.requireOpen()
  if codecCtxRet.isErr:
    result = err(codecCtxRet.error)
    return

  let codecCtx = codecCtxRet.value
  var extra = newSeq[byte]()
  if codecCtx[].extradata_size > 0 and not codecCtx[].extradata.isNil:
    extra = newSeq[byte](int(codecCtx[].extradata_size))
    copyMem(extra[0].addr, codecCtx[].extradata, extra.len)

  result = ok(EncodedStreamInfo(
    codecId: codecCtx[].codec_id.toCodecId(),
    width: int(codecCtx[].width),
    height: int(codecCtx[].height),
    pixelFormat: codecCtx[].pix_fmt.toPixelFormat(),
    timeBase: codecCtx[].time_base.toRational(),
    framerate: codecCtx[].framerate.toRational(),
    bitRate: codecCtx[].bit_rate,
    extradata: extra
  ))

# =============================================================================
# === Frame submission
# =============================================================================

# -----------------------------------------------------------------------------
# --- beginFrame
# -----------------------------------------------------------------------------

proc beginFrame*(encoder: VideoEncoder; pts: int64): FFmpegResult[WritableI420FrameView] =
  let openRet = encoder.requireOpen()
  if openRet.isErr:
    result = err(openRet.error)
    return

  if encoder.flushed:
    result = fail[WritableI420FrameView]("beginFrame", "Encoder has already been flushed")
    return

  if encoder.framePrepared:
    result = fail[WritableI420FrameView](
      "beginFrame",
      "Previous frame has not been submitted"
    )
    return

  let writableRet = encoder.frame.makeWritable()
  if writableRet.isErr:
    result = err(writableRet.error)
    return

  let rawRet = encoder.frame.requireOpen()
  if rawRet.isErr:
    result = err(rawRet.error)
    return

  rawRet.value[].pts = pts

  let viewRet = encoder.frame.toWritableI420FrameView(encoder.timeBase)
  if viewRet.isErr:
    result = err(viewRet.error)
    return

  encoder.framePrepared = true
  result = ok(viewRet.value)

# -----------------------------------------------------------------------------
# --- beginFrameNV12
# -----------------------------------------------------------------------------

proc beginFrameNV12*(encoder: VideoEncoder; pts: int64): FFmpegResult[WritableNV12FrameView] =
  let openRet = encoder.requireOpen()
  if openRet.isErr:
    result = err(openRet.error)
    return

  if encoder.flushed:
    result = fail[WritableNV12FrameView]("beginFrameNV12", "Encoder has already been flushed")
    return

  if encoder.framePrepared:
    result = fail[WritableNV12FrameView](
      "beginFrameNV12",
      "Previous frame has not been submitted"
    )
    return

  let writableRet = encoder.frame.makeWritable()
  if writableRet.isErr:
    result = err(writableRet.error)
    return

  let rawRet = encoder.frame.requireOpen()
  if rawRet.isErr:
    result = err(rawRet.error)
    return

  rawRet.value[].pts = pts

  let viewRet = encoder.frame.toWritableNV12FrameView(encoder.timeBase)
  if viewRet.isErr:
    result = err(viewRet.error)
    return

  encoder.framePrepared = true
  result = ok(viewRet.value)

# -----------------------------------------------------------------------------
# --- submitFrame
# -----------------------------------------------------------------------------

proc submitFrame*(encoder: VideoEncoder): FFmpegResult[void] =
  let codecCtxRet = encoder.requireOpen()
  if codecCtxRet.isErr:
    result = err(codecCtxRet.error)
    return

  if not encoder.framePrepared:
    result = fail[void]("submitFrame", "No prepared frame to submit")
    return

  let rawFrameRet = encoder.frame.requireOpen()
  if rawFrameRet.isErr:
    result = err(rawFrameRet.error)
    return

  let ret = okAv(avcodec_send_frame(codecCtxRet.value, rawFrameRet.value), "avcodec_send_frame")
  if ret.isErr:
    result = err(ret.error)
    return

  encoder.framePrepared = false
  inc encoder.submittedFrames
  result = ok()

# -----------------------------------------------------------------------------
# --- flush
# -----------------------------------------------------------------------------

proc flush*(encoder: VideoEncoder): FFmpegResult[void] =
  let codecCtxRet = encoder.requireOpen()
  if codecCtxRet.isErr:
    result = err(codecCtxRet.error)
    return

  if encoder.framePrepared:
    result = fail[void]("flush", "Prepared frame has not been submitted")
    return

  if encoder.flushed:
    result = ok()
    return

  let ret = okAv(avcodec_send_frame(codecCtxRet.value, nil), "avcodec_send_frame(NULL)")
  if ret.isErr:
    result = err(ret.error)
    return

  encoder.flushed = true
  result = ok()

# =============================================================================
# === Packet receiving
# =============================================================================

# -----------------------------------------------------------------------------
# --- receivePacket
# -----------------------------------------------------------------------------

proc receivePacket*(encoder: VideoEncoder): FFmpegResult[EncodedPacketRead] =
  let codecCtxRet = encoder.requireOpen()
  if codecCtxRet.isErr:
    result = err(codecCtxRet.error)
    return

  if encoder.packet.isNil:
    result = fail[EncodedPacketRead]("receivePacket", "Encoder packet is missing")
    return

  encoder.packet.unref()
  let ret = avcodec_receive_packet(codecCtxRet.value, encoder.packet.raw)

  if ret == avErrorAgain:
    result = ok(EncodedPacketRead(hasPacket: false, flushed: false))
    return

  if ret == avErrorEof:
    result = ok(EncodedPacketRead(hasPacket: false, flushed: true))
    return

  let okRet = okAv(ret, "avcodec_receive_packet")
  if okRet.isErr:
    result = err(okRet.error)
    return

  let viewRet = encoder.packet.toEncodedPacketView(encoder.timeBase)
  if viewRet.isErr:
    result = err(viewRet.error)
    return

  result = ok(EncodedPacketRead(
    hasPacket: true,
    flushed: false,
    packet: viewRet.value,
    avPacket: encoder.packet.raw
  ))

# -----------------------------------------------------------------------------
# --- rawPacket
# -----------------------------------------------------------------------------

proc rawPacket*(read: EncodedPacketRead): FFmpegResult[AVPacketPtr] =
  if not read.hasPacket or read.avPacket.isNil:
    result = fail[AVPacketPtr]("EncodedPacketRead.rawPacket", "No encoded packet is available")
    return

  result = ok(read.avPacket)
