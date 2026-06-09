# libav_nim/types.nim
#
# Nim-side public and semi-public types for libav_nim.
#
# This module intentionally keeps FFmpeg's raw C ABI types behind a thin
# layer. Higher-level modules should expose Frame/Packet/Decoder objects
# rather than raw FFmpeg pointers whenever possible.

import ./bindings/c_api

# =============================================================================
# Raw FFmpeg type aliases
# =============================================================================

type
  AVMediaType* = enum_AVMediaType
  AVPixelFormat* = enum_AVPixelFormat
  AVCodecID* = enum_AVCodecID

  AVFramePtr* = ptr AVFrame
  AVPacketPtr* = ptr AVPacket
  AVCodecPtr* = ptr AVCodec
  AVCodecContextPtr* = ptr AVCodecContext
  AVCodecParametersPtr* = ptr AVCodecParameters
  AVFormatContextPtr* = ptr AVFormatContext
  AVStreamPtr* = ptr AVStream
  AVInputFormatPtr* = ptr AVInputFormat
  AVOutputFormatPtr* = ptr AVOutputFormat
  AVIOContextPtr* = ptr AVIOContext
  AVDictionaryPtr* = ptr AVDictionary

# =============================================================================
# Nim-side small value types
# =============================================================================

type
  Rational* = object
    num*: int32
    den*: int32

  MediaType* = enum
    mtUnknown
    mtVideo
    mtAudio
    mtData
    mtSubtitle
    mtAttachment

  CodecId* = enum
    cidUnknown
    cidH264
    cidHevc
    cidRawVideo

  PixelFormat* = enum
    pfUnknown
    pfYuv420p
    pfNv12
    pfNv21
    pfRgb24
    pfRgba
    pfBgra
    pfRgbx
    pfBgrx

# =============================================================================
# Borrowed frame views
# =============================================================================

type
  Yuv420FrameView* = object
    ## Borrowed view of a decoded YUV420P/I420 frame.
    ##
    ## The plane pointers are owned by FFmpeg. They are valid only until the
    ## owning AVFrame is unref'ed/freed or reused by the decoder.
    width*: int
    height*: int
    y*: pointer
    u*: pointer
    v*: pointer
    yStride*: int
    uStride*: int
    vStride*: int
    pts*: int64
    timeBase*: Rational

# =============================================================================
# Rational conversion
# =============================================================================

# -----------------------------------------------------------------------------
# toRational
# -----------------------------------------------------------------------------

proc toRational*(value: AVRational): Rational =
  result = Rational(
    num: int32(value.num),
    den: int32(value.den)
  )

# -----------------------------------------------------------------------------
# toAVRational
# -----------------------------------------------------------------------------

proc toAVRational*(value: Rational): AVRational =
  result.num = cint(value.num)
  result.den = cint(value.den)

# -----------------------------------------------------------------------------
# isValid
# -----------------------------------------------------------------------------

proc isValid*(value: Rational): bool =
  result = value.den != 0

# =============================================================================
# FFmpeg enum conversion
# =============================================================================

# -----------------------------------------------------------------------------
# toMediaType
# -----------------------------------------------------------------------------

proc toMediaType*(value: AVMediaType): MediaType =
  case value
  of AVMEDIA_TYPE_VIDEO:
    result = mtVideo
  of AVMEDIA_TYPE_AUDIO:
    result = mtAudio
  of AVMEDIA_TYPE_DATA:
    result = mtData
  of AVMEDIA_TYPE_SUBTITLE:
    result = mtSubtitle
  of AVMEDIA_TYPE_ATTACHMENT:
    result = mtAttachment
  else:
    result = mtUnknown

# -----------------------------------------------------------------------------
# toCodecId
# -----------------------------------------------------------------------------

proc toCodecId*(value: AVCodecID): CodecId =
  case value
  of AV_CODEC_ID_H264:
    result = cidH264
  of AV_CODEC_ID_HEVC:
    result = cidHevc
  of AV_CODEC_ID_RAWVIDEO:
    result = cidRawVideo
  else:
    result = cidUnknown

# -----------------------------------------------------------------------------
# toPixelFormat
# -----------------------------------------------------------------------------

proc toPixelFormat*(value: AVPixelFormat): PixelFormat =
  case value
  of AV_PIX_FMT_YUV420P:
    result = pfYuv420p
  of AV_PIX_FMT_NV12:
    result = pfNv12
  of AV_PIX_FMT_NV21:
    result = pfNv21
  of AV_PIX_FMT_RGB24:
    result = pfRgb24
  of AV_PIX_FMT_RGBA:
    result = pfRgba
  of AV_PIX_FMT_BGRA:
    result = pfBgra
  of AV_PIX_FMT_RGB0:
    result = pfRgbx
  of AV_PIX_FMT_BGR0:
    result = pfBgrx
  else:
    result = pfUnknown

# -----------------------------------------------------------------------------
# pixelFormatFromRaw
# -----------------------------------------------------------------------------

proc pixelFormatFromRaw*(value: cint): PixelFormat =
  result = toPixelFormat(cast[AVPixelFormat](value))

# -----------------------------------------------------------------------------
# mediaTypeFromRaw
# -----------------------------------------------------------------------------

proc mediaTypeFromRaw*(value: cint): MediaType =
  result = toMediaType(cast[AVMediaType](value))

# -----------------------------------------------------------------------------
# codecIdFromRaw
# -----------------------------------------------------------------------------

proc codecIdFromRaw*(value: cuint): CodecId =
  result = toCodecId(cast[AVCodecID](value))
