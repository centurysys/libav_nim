# libav_nim/frame.nim
#
# Result-based thin ownership wrapper for AVFrame and borrowed Nim-side frame
# views.

import std/strformat
import results
import ./bindings/c_api
import ./error
import ./types

# =============================================================================
# === Frame owner
# =============================================================================

type
  Frame* = ref object
    raw*: AVFramePtr

# =============================================================================
# === Frame lifecycle
# =============================================================================

# -----------------------------------------------------------------------------
# --- newFrame
# -----------------------------------------------------------------------------

proc newFrame*(): FFmpegResult[Frame] =
  let raw = av_frame_alloc()
  if raw.isNil:
    result = fail[Frame]("av_frame_alloc", "allocation failed")
    return

  result = ok(Frame(raw: raw))

# -----------------------------------------------------------------------------
# --- close
# -----------------------------------------------------------------------------

proc close*(frame: Frame) =
  if frame.isNil:
    return

  if frame.raw.isNil:
    return

  var raw = frame.raw
  av_frame_free(addr raw)
  frame.raw = nil

# -----------------------------------------------------------------------------
# --- unref
# -----------------------------------------------------------------------------

proc unref*(frame: Frame) =
  if frame.isNil or frame.raw.isNil:
    return

  av_frame_unref(frame.raw)

# =============================================================================
# === Frame state
# =============================================================================

# -----------------------------------------------------------------------------
# --- isOpen
# -----------------------------------------------------------------------------

proc isOpen*(frame: Frame): bool =
  result = not frame.isNil and not frame.raw.isNil

# -----------------------------------------------------------------------------
# --- requireOpen
# -----------------------------------------------------------------------------

proc requireOpen*(frame: Frame): FFmpegResult[AVFramePtr] =
  if not frame.isOpen():
    result = fail[AVFramePtr]("Frame.requireOpen", "Frame is closed")
    return

  result = ok(frame.raw)

# =============================================================================
# === Writable frame helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- getBuffer
# -----------------------------------------------------------------------------

proc getBuffer*(frame: Frame; align = 32): FFmpegResult[void] =
  let rawRet = frame.requireOpen()
  if rawRet.isErr:
    result = err(rawRet.error)
    return

  let ret = okAv(av_frame_get_buffer(rawRet.value, cint(align)), "av_frame_get_buffer")
  if ret.isErr:
    result = err(ret.error)
    return

  result = ok()

# -----------------------------------------------------------------------------
# --- makeWritable
# -----------------------------------------------------------------------------

proc makeWritable*(frame: Frame): FFmpegResult[void] =
  let rawRet = frame.requireOpen()
  if rawRet.isErr:
    result = err(rawRet.error)
    return

  let ret = okAv(av_frame_make_writable(rawRet.value), "av_frame_make_writable")
  if ret.isErr:
    result = err(ret.error)
    return

  result = ok()

# =============================================================================
# === Frame metadata
# =============================================================================

# -----------------------------------------------------------------------------
# --- rawPixelFormat
# -----------------------------------------------------------------------------

proc rawPixelFormat*(frame: Frame): FFmpegResult[cint] =
  let rawRet = frame.requireOpen()
  if rawRet.isErr:
    result = err(rawRet.error)
    return

  result = ok(rawRet.value[].format)

# -----------------------------------------------------------------------------
# --- pixelFormat
# -----------------------------------------------------------------------------

proc pixelFormat*(frame: Frame): FFmpegResult[PixelFormat] =
  let rawRet = frame.rawPixelFormat()
  if rawRet.isErr:
    result = err(rawRet.error)
    return

  result = ok(pixelFormatFromRaw(rawRet.value))

# -----------------------------------------------------------------------------
# --- width
# -----------------------------------------------------------------------------

proc width*(frame: Frame): FFmpegResult[int] =
  let rawRet = frame.requireOpen()
  if rawRet.isErr:
    result = err(rawRet.error)
    return

  result = ok(int(rawRet.value[].width))

# -----------------------------------------------------------------------------
# --- height
# -----------------------------------------------------------------------------

proc height*(frame: Frame): FFmpegResult[int] =
  let rawRet = frame.requireOpen()
  if rawRet.isErr:
    result = err(rawRet.error)
    return

  result = ok(int(rawRet.value[].height))

# =============================================================================
# === Borrowed YUV420 view
# =============================================================================

# -----------------------------------------------------------------------------
# --- toYuv420FrameView
# -----------------------------------------------------------------------------

proc toYuv420FrameView*(
    frame: Frame;
    timeBase = Rational(num: 0, den: 1)
  ): FFmpegResult[Yuv420FrameView] =
  let rawRet = frame.requireOpen()
  if rawRet.isErr:
    result = err(rawRet.error)
    return

  let raw = rawRet.value
  let pixelFormat = pixelFormatFromRaw(raw[].format)

  if pixelFormat != pfYuv420p:
    result = fail[Yuv420FrameView](
      "toYuv420FrameView",
      &"Expected YUV420P frame, got pixel format {pixelFormat}"
    )
    return

  if raw[].width <= 0 or raw[].height <= 0:
    result = fail[Yuv420FrameView](
      "toYuv420FrameView",
      &"Invalid frame size: {raw[].width}x{raw[].height}"
    )
    return

  if raw[].data[0].isNil or raw[].data[1].isNil or raw[].data[2].isNil:
    result = fail[Yuv420FrameView](
      "toYuv420FrameView",
      "YUV420P frame has missing plane pointers"
    )
    return

  if raw[].linesize[0] < raw[].width:
    result = fail[Yuv420FrameView](
      "toYuv420FrameView",
      &"Invalid Y plane stride: {raw[].linesize[0]} for width {raw[].width}"
    )
    return

  let chromaWidth = (int(raw[].width) + 1) div 2
  if int(raw[].linesize[1]) < chromaWidth or int(raw[].linesize[2]) < chromaWidth:
    result = fail[Yuv420FrameView](
      "toYuv420FrameView",
      &"Invalid chroma stride: U={raw[].linesize[1]} V={raw[].linesize[2]} for chroma width {chromaWidth}"
    )
    return

  var timestamp = emptyFrameTimestamp(timeBase)
  timestamp.pts = raw[].pts
  timestamp.bestEffortTimestamp = raw[].best_effort_timestamp
  timestamp.pktDts = raw[].pkt_dts
  timestamp.duration = raw[].duration
  timestamp.selectFrameTimestamp()

  result = ok(Yuv420FrameView(
    width: int(raw[].width),
    height: int(raw[].height),
    format: pixelFormat,
    y: cast[pointer](raw[].data[0]),
    u: cast[pointer](raw[].data[1]),
    v: cast[pointer](raw[].data[2]),
    yStride: int(raw[].linesize[0]),
    uStride: int(raw[].linesize[1]),
    vStride: int(raw[].linesize[2]),
    pts: raw[].pts,
    timeBase: timeBase,
    timestamp: timestamp
  ))

# =============================================================================
# === Writable borrowed I420 view
# =============================================================================

# -----------------------------------------------------------------------------
# --- toWritableI420FrameView
# -----------------------------------------------------------------------------

proc toWritableI420FrameView*(
    frame: Frame;
    timeBase = Rational(num: 0, den: 1)
  ): FFmpegResult[WritableI420FrameView] =
  let rawRet = frame.requireOpen()
  if rawRet.isErr:
    result = err(rawRet.error)
    return

  let raw = rawRet.value
  let pixelFormat = pixelFormatFromRaw(raw[].format)

  if pixelFormat != pfYuv420p:
    result = fail[WritableI420FrameView](
      "toWritableI420FrameView",
      &"Expected YUV420P frame, got pixel format {pixelFormat}"
    )
    return

  if raw[].width <= 0 or raw[].height <= 0:
    result = fail[WritableI420FrameView](
      "toWritableI420FrameView",
      &"Invalid frame size: {raw[].width}x{raw[].height}"
    )
    return

  if raw[].data[0].isNil or raw[].data[1].isNil or raw[].data[2].isNil:
    result = fail[WritableI420FrameView](
      "toWritableI420FrameView",
      "YUV420P frame has missing plane pointers"
    )
    return

  if raw[].linesize[0] < raw[].width:
    result = fail[WritableI420FrameView](
      "toWritableI420FrameView",
      &"Invalid Y plane stride: {raw[].linesize[0]} for width {raw[].width}"
    )
    return

  let chromaWidth = (int(raw[].width) + 1) div 2
  if int(raw[].linesize[1]) < chromaWidth or int(raw[].linesize[2]) < chromaWidth:
    result = fail[WritableI420FrameView](
      "toWritableI420FrameView",
      &"Invalid chroma stride: U={raw[].linesize[1]} V={raw[].linesize[2]} for chroma width {chromaWidth}"
    )
    return

  result = ok(WritableI420FrameView(
    width: int(raw[].width),
    height: int(raw[].height),
    format: pixelFormat,
    y: cast[pointer](raw[].data[0]),
    u: cast[pointer](raw[].data[1]),
    v: cast[pointer](raw[].data[2]),
    yStride: int(raw[].linesize[0]),
    uStride: int(raw[].linesize[1]),
    vStride: int(raw[].linesize[2]),
    pts: raw[].pts,
    timeBase: timeBase
  ))

# =============================================================================
# === Writable borrowed NV12 view
# =============================================================================

# -----------------------------------------------------------------------------
# --- toWritableNV12FrameView
# -----------------------------------------------------------------------------

proc toWritableNV12FrameView*(
    frame: Frame;
    timeBase = Rational(num: 0, den: 1)
  ): FFmpegResult[WritableNV12FrameView] =
  let rawRet = frame.requireOpen()
  if rawRet.isErr:
    result = err(rawRet.error)
    return

  let raw = rawRet.value
  let pixelFormat = pixelFormatFromRaw(raw[].format)

  if pixelFormat != pfNv12:
    result = fail[WritableNV12FrameView](
      "toWritableNV12FrameView",
      &"Expected NV12 frame, got pixel format {pixelFormat}"
    )
    return

  if raw[].width <= 0 or raw[].height <= 0:
    result = fail[WritableNV12FrameView](
      "toWritableNV12FrameView",
      &"Invalid frame size: {raw[].width}x{raw[].height}"
    )
    return

  if raw[].data[0].isNil or raw[].data[1].isNil:
    result = fail[WritableNV12FrameView](
      "toWritableNV12FrameView",
      "NV12 frame has missing plane pointers"
    )
    return

  if raw[].linesize[0] < raw[].width:
    result = fail[WritableNV12FrameView](
      "toWritableNV12FrameView",
      &"Invalid Y plane stride: {raw[].linesize[0]} for width {raw[].width}"
    )
    return

  if raw[].linesize[1] < raw[].width:
    result = fail[WritableNV12FrameView](
      "toWritableNV12FrameView",
      &"Invalid UV plane stride: {raw[].linesize[1]} for width {raw[].width}"
    )
    return

  result = ok(WritableNV12FrameView(
    width: int(raw[].width),
    height: int(raw[].height),
    format: pixelFormat,
    y: cast[pointer](raw[].data[0]),
    uv: cast[pointer](raw[].data[1]),
    yStride: int(raw[].linesize[0]),
    uvStride: int(raw[].linesize[1]),
    pts: raw[].pts,
    timeBase: timeBase
  ))
