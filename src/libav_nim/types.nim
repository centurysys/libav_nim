# libav_nim/types.nim
#
# Nim-side public and semi-public types for libav_nim.
#
# This module intentionally keeps FFmpeg's raw C ABI types behind a thin
# layer. Higher-level modules should expose Frame/Packet/Decoder objects
# rather than raw FFmpeg pointers whenever possible.

import ./bindings/c_api

# =============================================================================
# === Raw FFmpeg type aliases
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
# === Nim-side small value types
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
# === Timestamp value types
# =============================================================================

const
  avNoPtsValue* = low(int64)


type
  TimestampSource* = enum
    ## Identifies which timestamp field was selected for presentation time.
    tsNone
    tsFrameBestEffort
    tsFramePts
    tsFramePktDts
    tsPacketPts
    tsPacketDts
    tsFrameIndex

  FrameTimestamp* = object
    ## Timestamp values collected while decoding one frame.
    ##
    ## FFmpeg can leave some fields unset. Unset timestamp fields are represented
    ## by AV_NOPTS_VALUE, exposed here as avNoPtsValue.
    pts*: int64
    bestEffortTimestamp*: int64
    pktDts*: int64
    duration*: int64
    packetPts*: int64
    packetDts*: int64
    packetDuration*: int64
    frameIndex*: int64
    selected*: int64
    source*: TimestampSource
    timeBase*: Rational

# -----------------------------------------------------------------------------
# --- hasTimestampValue
# -----------------------------------------------------------------------------

proc hasTimestampValue*(value: int64): bool =
  result = value != avNoPtsValue

# -----------------------------------------------------------------------------
# --- timestampSourceName
# -----------------------------------------------------------------------------

proc timestampSourceName*(source: TimestampSource): string =
  case source
  of tsNone:
    result = "none"
  of tsFrameBestEffort:
    result = "frame.best_effort_timestamp"
  of tsFramePts:
    result = "frame.pts"
  of tsFramePktDts:
    result = "frame.pkt_dts"
  of tsPacketPts:
    result = "packet.pts"
  of tsPacketDts:
    result = "packet.dts"
  of tsFrameIndex:
    result = "frame_index"

# -----------------------------------------------------------------------------
# --- emptyFrameTimestamp
# -----------------------------------------------------------------------------

proc emptyFrameTimestamp*(timeBase = Rational(num: 0, den: 1)): FrameTimestamp =
  result = FrameTimestamp(
    pts: avNoPtsValue,
    bestEffortTimestamp: avNoPtsValue,
    pktDts: avNoPtsValue,
    duration: 0,
    packetPts: avNoPtsValue,
    packetDts: avNoPtsValue,
    packetDuration: 0,
    frameIndex: -1,
    selected: avNoPtsValue,
    source: tsNone,
    timeBase: timeBase
  )

# -----------------------------------------------------------------------------
# --- selectFrameTimestamp
# -----------------------------------------------------------------------------

proc selectFrameTimestamp*(timestamp: var FrameTimestamp) =
  ## Select a presentation timestamp using frame-side values only.
  ##
  ## Hardware decoders can fail to propagate useful frame timestamps. Packet-side
  ## fallback is applied later by the decoder after a packet timestamp has been
  ## matched to the returned frame.
  if timestamp.bestEffortTimestamp.hasTimestampValue():
    timestamp.selected = timestamp.bestEffortTimestamp
    timestamp.source = tsFrameBestEffort
    return

  if timestamp.pts.hasTimestampValue():
    timestamp.selected = timestamp.pts
    timestamp.source = tsFramePts
    return

  if timestamp.pktDts.hasTimestampValue():
    timestamp.selected = timestamp.pktDts
    timestamp.source = tsFramePktDts
    return

  timestamp.selected = avNoPtsValue
  timestamp.source = tsNone

# -----------------------------------------------------------------------------
# --- selectedTimestamp
# -----------------------------------------------------------------------------

proc selectedTimestamp*(timestamp: FrameTimestamp): int64 =
  ## Return the timestamp selected for presentation/synchronization.
  if timestamp.selected.hasTimestampValue():
    result = timestamp.selected
    return

  if timestamp.bestEffortTimestamp.hasTimestampValue():
    result = timestamp.bestEffortTimestamp
    return

  if timestamp.pts.hasTimestampValue():
    result = timestamp.pts
    return

  if timestamp.pktDts.hasTimestampValue():
    result = timestamp.pktDts
    return

  if timestamp.packetPts.hasTimestampValue():
    result = timestamp.packetPts
    return

  if timestamp.packetDts.hasTimestampValue():
    result = timestamp.packetDts
    return

  result = avNoPtsValue

# -----------------------------------------------------------------------------
# --- hasTimestamp
# -----------------------------------------------------------------------------

proc hasTimestamp*(timestamp: FrameTimestamp): bool =
  result = timestamp.selectedTimestamp().hasTimestampValue()

# -----------------------------------------------------------------------------
# --- packetSelectedTimestamp
# -----------------------------------------------------------------------------

proc packetSelectedTimestamp*(timestamp: FrameTimestamp): tuple[value: int64, source: TimestampSource] =
  if timestamp.packetPts.hasTimestampValue():
    result = (value: timestamp.packetPts, source: tsPacketPts)
    return

  if timestamp.packetDts.hasTimestampValue():
    result = (value: timestamp.packetDts, source: tsPacketDts)
    return

  result = (value: avNoPtsValue, source: tsNone)

# -----------------------------------------------------------------------------
# --- withPacketFallback
# -----------------------------------------------------------------------------

proc withPacketFallback*(
    frameTimestamp: FrameTimestamp;
    packetTimestamp: FrameTimestamp;
    frameIndex: int64
  ): FrameTimestamp =
  ## Attach packet-side timestamps to a frame timestamp.
  ##
  ## Some V4L2 mem2mem hardware decoder paths return frame timestamps as zero
  ## for every decoded frame. In that case, use the matched packet timestamp as a
  ## more useful presentation timestamp. This is still a pragmatic fallback; it
  ## does not attempt full B-frame reordering semantics.
  result = frameTimestamp
  result.packetPts = packetTimestamp.packetPts
  result.packetDts = packetTimestamp.packetDts
  result.packetDuration = packetTimestamp.packetDuration
  result.frameIndex = frameIndex

  var selected = result.selectedTimestamp()
  var source = result.source
  let packetSelected = packetTimestamp.packetSelectedTimestamp()

  if (
      selected.hasTimestampValue() and
      selected == 0 and
      packetSelected.value.hasTimestampValue() and
      packetSelected.value != 0 and
      frameIndex > 0
    ):
    selected = packetSelected.value
    source = packetSelected.source

  if not selected.hasTimestampValue() and packetSelected.value.hasTimestampValue():
    selected = packetSelected.value
    source = packetSelected.source

  result.selected = selected
  result.source = source

# -----------------------------------------------------------------------------
# --- timestampSeconds
# -----------------------------------------------------------------------------

proc timestampSeconds*(timestamp: FrameTimestamp; seconds: var float64): bool =
  ## Convert selectedTimestamp() to seconds.
  ##
  ## Returns false when the timestamp is unset or the time base is invalid.
  let value = timestamp.selectedTimestamp()
  if not value.hasTimestampValue():
    return false

  if timestamp.timeBase.den == 0:
    return false

  seconds = (
    float64(value) *
    float64(timestamp.timeBase.num) /
    float64(timestamp.timeBase.den)
  )
  result = true

# -----------------------------------------------------------------------------
# --- durationSeconds
# -----------------------------------------------------------------------------

proc durationSeconds*(timestamp: FrameTimestamp; seconds: var float64): bool =
  let duration = if timestamp.packetDuration > 0: timestamp.packetDuration else: timestamp.duration
  if duration <= 0:
    return false

  if timestamp.timeBase.den == 0:
    return false

  seconds = (
    float64(duration) *
    float64(timestamp.timeBase.num) /
    float64(timestamp.timeBase.den)
  )
  result = true

# =============================================================================
# === Borrowed frame views
# =============================================================================

type
  PlaneView* = object
    ## Borrowed view of one image plane.
    ##
    ## data is owned by FFmpeg or another upstream component. The view does not
    ## own the memory.
    data*: pointer
    stride*: int
    width*: int
    height*: int

  Yuv420Layout* = object
    ## Byte sizes implied by a YUV420P/I420 frame layout.
    yBytes*: int
    uBytes*: int
    vBytes*: int
    totalBytes*: int

  Yuv420FrameView* = object
    ## Borrowed view of a decoded YUV420P/I420 frame.
    ##
    ## The plane pointers are owned by FFmpeg. They are valid only until the
    ## owning AVFrame is unref'ed/freed or reused by the decoder.
    width*: int
    height*: int
    format*: PixelFormat
    y*: pointer
    u*: pointer
    v*: pointer
    yStride*: int
    uStride*: int
    vStride*: int
    pts*: int64
    timeBase*: Rational
    timestamp*: FrameTimestamp

# =============================================================================
# === Borrowed frame view helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- pixelFormatName
# -----------------------------------------------------------------------------

proc pixelFormatName*(format: PixelFormat): string =
  case format
  of pfUnknown:
    result = "unknown"
  of pfYuv420p:
    result = "yuv420p"
  of pfNv12:
    result = "nv12"
  of pfNv21:
    result = "nv21"
  of pfRgb24:
    result = "rgb24"
  of pfRgba:
    result = "rgba"
  of pfBgra:
    result = "bgra"
  of pfRgbx:
    result = "rgbx"
  of pfBgrx:
    result = "bgrx"

# -----------------------------------------------------------------------------
# --- planeByteSize
# -----------------------------------------------------------------------------

proc planeByteSize*(stride: int; height: int): int =
  if stride <= 0 or height <= 0:
    result = 0
    return

  result = stride * height

# -----------------------------------------------------------------------------
# --- yuv420Layout
# -----------------------------------------------------------------------------

proc yuv420Layout*(
    width: int;
    height: int;
    yStride: int;
    uStride: int;
    vStride: int
  ): Yuv420Layout =
  let chromaHeight = (height + 1) div 2

  result.yBytes = planeByteSize(yStride, height)
  result.uBytes = planeByteSize(uStride, chromaHeight)
  result.vBytes = planeByteSize(vStride, chromaHeight)
  result.totalBytes = result.yBytes + result.uBytes + result.vBytes

# -----------------------------------------------------------------------------
# --- yuv420Layout
# -----------------------------------------------------------------------------

proc yuv420Layout*(frame: Yuv420FrameView): Yuv420Layout =
  result = yuv420Layout(
    frame.width,
    frame.height,
    frame.yStride,
    frame.uStride,
    frame.vStride
  )

# -----------------------------------------------------------------------------
# --- yPlane
# -----------------------------------------------------------------------------

proc yPlane*(frame: Yuv420FrameView): PlaneView =
  result = PlaneView(
    data: frame.y,
    stride: frame.yStride,
    width: frame.width,
    height: frame.height
  )

# -----------------------------------------------------------------------------
# --- uPlane
# -----------------------------------------------------------------------------

proc uPlane*(frame: Yuv420FrameView): PlaneView =
  result = PlaneView(
    data: frame.u,
    stride: frame.uStride,
    width: (frame.width + 1) div 2,
    height: (frame.height + 1) div 2
  )

# -----------------------------------------------------------------------------
# --- vPlane
# -----------------------------------------------------------------------------

proc vPlane*(frame: Yuv420FrameView): PlaneView =
  result = PlaneView(
    data: frame.v,
    stride: frame.vStride,
    width: (frame.width + 1) div 2,
    height: (frame.height + 1) div 2
  )

# -----------------------------------------------------------------------------
# --- hasUsableYuv420Planes
# -----------------------------------------------------------------------------

proc hasUsableYuv420Planes*(frame: Yuv420FrameView): bool =
  if frame.format != pfYuv420p:
    return false

  if frame.width <= 0 or frame.height <= 0:
    return false

  if frame.y.isNil or frame.u.isNil or frame.v.isNil:
    return false

  if frame.yStride < frame.width:
    return false

  if frame.uStride < ((frame.width + 1) div 2):
    return false

  if frame.vStride < ((frame.width + 1) div 2):
    return false

  result = true

# -----------------------------------------------------------------------------
# --- rgbxByteSize
# -----------------------------------------------------------------------------

proc rgbxByteSize*(width: int; height: int): int =
  if width <= 0 or height <= 0:
    result = 0
    return

  result = width * height * 4

# -----------------------------------------------------------------------------
# --- rgbxByteSize
# -----------------------------------------------------------------------------

proc rgbxByteSize*(frame: Yuv420FrameView): int =
  result = rgbxByteSize(frame.width, frame.height)

# =============================================================================
# === Rational conversion
# =============================================================================

# -----------------------------------------------------------------------------
# --- toRational
# -----------------------------------------------------------------------------

proc toRational*(value: AVRational): Rational =
  result = Rational(
    num: int32(value.num),
    den: int32(value.den)
  )

# -----------------------------------------------------------------------------
# --- toAVRational
# -----------------------------------------------------------------------------

proc toAVRational*(value: Rational): AVRational =
  result.num = cint(value.num)
  result.den = cint(value.den)

# -----------------------------------------------------------------------------
# --- isValid
# -----------------------------------------------------------------------------

proc isValid*(value: Rational): bool =
  result = value.den != 0

# =============================================================================
# === FFmpeg enum conversion
# =============================================================================

# -----------------------------------------------------------------------------
# --- toMediaType
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
# --- toCodecId
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
# --- toPixelFormat
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
# --- pixelFormatFromRaw
# -----------------------------------------------------------------------------

proc pixelFormatFromRaw*(value: cint): PixelFormat =
  result = toPixelFormat(cast[AVPixelFormat](value))

# -----------------------------------------------------------------------------
# --- mediaTypeFromRaw
# -----------------------------------------------------------------------------

proc mediaTypeFromRaw*(value: cint): MediaType =
  result = toMediaType(cast[AVMediaType](value))

# -----------------------------------------------------------------------------
# --- codecIdFromRaw
# -----------------------------------------------------------------------------

proc codecIdFromRaw*(value: cuint): CodecId =
  result = toCodecId(cast[AVCodecID](value))
