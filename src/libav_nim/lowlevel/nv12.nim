# libav_nim/nv12.nim
#
# Small NV12 helpers backed by libyuv_nim.

import std/strformat
import results
import libyuv_nim
import ./error
import ./types
import ./i420
import ./rgbx

# =============================================================================
# === Owned NV12 frame buffer
# =============================================================================

type
  OwnedNV12Frame* = object
    ## Owned contiguous NV12 frame buffer.
    ##
    ## Layout:
    ##   Y plane: width * height bytes
    ##   UV plane: width * chromaHeight bytes, interleaved U,V,U,V...
    ##
    ## Strides are tightly packed. This is intentionally simple and independent
    ## from FFmpeg's AVFrame lifetime.
    width*: int
    height*: int
    yStride*: int
    uvStride*: int
    data: seq[byte]

# =============================================================================
# === Internal helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- chromaWidth
# -----------------------------------------------------------------------------

proc chromaWidth(width: int): int =
  result = (width + 1) div 2

# -----------------------------------------------------------------------------
# --- chromaHeight
# -----------------------------------------------------------------------------

proc chromaHeight(height: int): int =
  result = (height + 1) div 2

# -----------------------------------------------------------------------------
# --- ySize
# -----------------------------------------------------------------------------

proc ySize(frame: OwnedNV12Frame): int =
  result = frame.yStride * frame.height

# -----------------------------------------------------------------------------
# --- copyPlane
# -----------------------------------------------------------------------------

proc copyPlane(
    src: pointer;
    srcStride: int;
    dst: pointer;
    dstStride: int;
    rowBytes: int;
    rows: int
  ): FFmpegResult[void] =
  if rowBytes < 0 or rows < 0:
    result = fail[void](
      "copyPlane",
      &"Invalid plane copy size: rowBytes={rowBytes} rows={rows}"
    )
    return

  if rowBytes == 0 or rows == 0:
    result = ok()
    return

  if src.isNil or dst.isNil:
    result = fail[void]("copyPlane", "Plane pointer is nil")
    return

  if srcStride < rowBytes or dstStride < rowBytes:
    result = fail[void](
      "copyPlane",
      &"Invalid stride: srcStride={srcStride} dstStride={dstStride} rowBytes={rowBytes}"
    )
    return

  let srcBytes = cast[ptr UncheckedArray[byte]](src)
  let dstBytes = cast[ptr UncheckedArray[byte]](dst)

  for row in 0 ..< rows:
    copyMem(
      addr dstBytes[row * dstStride],
      addr srcBytes[row * srcStride],
      rowBytes
    )

  result = ok()

# -----------------------------------------------------------------------------
# --- copyI420ToNV12Libyuv
# -----------------------------------------------------------------------------

proc copyI420ToNV12Libyuv(
    srcY: pointer;
    srcYStride: int;
    srcU: pointer;
    srcUStride: int;
    srcV: pointer;
    srcVStride: int;
    dstY: pointer;
    dstYStride: int;
    dstUV: pointer;
    dstUVStride: int;
    width: int;
    height: int;
    caller: string
  ): FFmpegResult[void] =
  if width <= 0 or height <= 0:
    result = fail[void](
      caller,
      &"Invalid frame size: {width}x{height}"
    )
    return

  if srcY.isNil or srcU.isNil or srcV.isNil or dstY.isNil or dstUV.isNil:
    result = fail[void](caller, "Plane pointer is nil")
    return

  let cw = chromaWidth(width)
  if srcYStride < width or srcUStride < cw or srcVStride < cw or
      dstYStride < width or dstUVStride < width:
    result = fail[void](
      caller,
      &"Invalid stride: srcYStride={srcYStride} srcUStride={srcUStride} srcVStride={srcVStride} dstYStride={dstYStride} dstUVStride={dstUVStride} width={width}"
    )
    return

  let ret = I420ToNV12(
    cast[ptr uint8](srcY), cint(srcYStride),
    cast[ptr uint8](srcU), cint(srcUStride),
    cast[ptr uint8](srcV), cint(srcVStride),
    cast[ptr uint8](dstY), cint(dstYStride),
    cast[ptr uint8](dstUV), cint(dstUVStride),
    cint(width),
    cint(height)
  )
  if ret != 0:
    result = fail[void](caller, &"I420ToNV12 failed: {ret}")
    return

  result = ok()


# -----------------------------------------------------------------------------
# --- copyRGBXToNV12Libyuv
# -----------------------------------------------------------------------------

proc copyRGBXToNV12Libyuv(
    srcRGBX: pointer;
    srcRGBXStride: int;
    dstY: pointer;
    dstYStride: int;
    dstUV: pointer;
    dstUVStride: int;
    width: int;
    height: int;
    caller: string
  ): FFmpegResult[void] =
  if width <= 0 or height <= 0:
    result = fail[void](caller, &"Invalid frame size: {width}x{height}")
    return

  if srcRGBX.isNil or dstY.isNil or dstUV.isNil:
    result = fail[void](caller, "Plane pointer is nil")
    return

  if srcRGBXStride < width * 4 or dstYStride < width or dstUVStride < width:
    result = fail[void](
      caller,
      &"Invalid stride: srcRGBXStride={srcRGBXStride} dstYStride={dstYStride} dstUVStride={dstUVStride} width={width}"
    )
    return

  let ret = ABGRToNV12(
    cast[ptr uint8](srcRGBX), cint(srcRGBXStride),
    cast[ptr uint8](dstY), cint(dstYStride),
    cast[ptr uint8](dstUV), cint(dstUVStride),
    cint(width),
    cint(height)
  )
  if ret != 0:
    result = fail[void](caller, &"ABGRToNV12 failed: {ret}")
    return

  result = ok()

# -----------------------------------------------------------------------------
# --- replicateLastRows
# -----------------------------------------------------------------------------

proc replicateLastRows(
    dst: pointer;
    dstStride: int;
    rowBytes: int;
    validRows: int;
    totalRows: int
  ): FFmpegResult[void] =
  if rowBytes < 0 or validRows < 0 or totalRows < 0:
    result = fail[void](
      "replicateLastRows",
      &"Invalid row count: rowBytes={rowBytes} validRows={validRows} totalRows={totalRows}"
    )
    return

  if totalRows <= validRows:
    result = ok()
    return

  if rowBytes == 0 or totalRows == 0:
    result = ok()
    return

  if dst.isNil:
    result = fail[void]("replicateLastRows", "Destination pointer is nil")
    return

  if validRows <= 0:
    result = fail[void](
      "replicateLastRows",
      &"Cannot replicate padding without at least one valid row: validRows={validRows}"
    )
    return

  if dstStride < rowBytes:
    result = fail[void](
      "replicateLastRows",
      &"Invalid stride: dstStride={dstStride} rowBytes={rowBytes}"
    )
    return

  let dstBytes = cast[ptr UncheckedArray[byte]](dst)
  let lastRow = (validRows - 1) * dstStride

  for row in validRows ..< totalRows:
    copyMem(
      addr dstBytes[row * dstStride],
      addr dstBytes[lastRow],
      rowBytes
    )

  result = ok()

# =============================================================================
# === Public owned frame helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- newOwnedNV12Frame
# -----------------------------------------------------------------------------

proc newOwnedNV12Frame*(width, height: int): FFmpegResult[OwnedNV12Frame] =
  if width <= 0 or height <= 0:
    result = fail[OwnedNV12Frame](
      "newOwnedNV12Frame",
      &"Invalid frame size: {width}x{height}"
    )
    return

  let ch = chromaHeight(height)
  let totalBytes = width * height + width * ch

  var frame = OwnedNV12Frame(
    width: width,
    height: height,
    yStride: width,
    uvStride: width,
    data: newSeq[byte](totalBytes)
  )

  result = ok(frame)

# -----------------------------------------------------------------------------
# --- byteSize
# -----------------------------------------------------------------------------

proc byteSize*(frame: OwnedNV12Frame): int =
  result = frame.data.len

# -----------------------------------------------------------------------------
# --- clear
# -----------------------------------------------------------------------------

proc clear*(frame: var OwnedNV12Frame; yValue: byte = 0; uvValue: byte = 128) =
  let yBytes = frame.ySize()
  for i in 0 ..< yBytes:
    frame.data[i] = yValue

  for i in yBytes ..< frame.data.len:
    frame.data[i] = uvValue

# -----------------------------------------------------------------------------
# --- yPointer
# -----------------------------------------------------------------------------

proc yPointer*(frame: var OwnedNV12Frame): pointer =
  if frame.data.len == 0:
    result = nil
    return

  result = addr frame.data[0]

# -----------------------------------------------------------------------------
# --- uvPointer
# -----------------------------------------------------------------------------

proc uvPointer*(frame: var OwnedNV12Frame): pointer =
  if frame.data.len == 0:
    result = nil
    return

  result = addr frame.data[frame.ySize()]

# -----------------------------------------------------------------------------
# --- yPointer
# -----------------------------------------------------------------------------

proc yPointer*(frame: OwnedNV12Frame): pointer =
  if frame.data.len == 0:
    result = nil
    return

  result = unsafeAddr frame.data[0]

# -----------------------------------------------------------------------------
# --- uvPointer
# -----------------------------------------------------------------------------

proc uvPointer*(frame: OwnedNV12Frame): pointer =
  if frame.data.len == 0:
    result = nil
    return

  result = unsafeAddr frame.data[frame.ySize()]

# =============================================================================
# === Public I420 -> NV12 copy helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- copyI420ToNV12 decoded borrowed -> owned
# -----------------------------------------------------------------------------

proc copyI420ToNV12*(
    src: Yuv420FrameView;
    dst: var OwnedNV12Frame
  ): FFmpegResult[void] =
  if not src.hasUsableYuv420Planes():
    result = fail[void](
      "copyI420ToNV12",
      &"Source is not a usable I420 frame: {src.width}x{src.height} {src.format.pixelFormatName()}"
    )
    return

  if src.width != dst.width or src.height != dst.height:
    result = fail[void](
      "copyI420ToNV12",
      &"Frame size mismatch: src={src.width}x{src.height} dst={dst.width}x{dst.height}"
    )
    return

  result = copyI420ToNV12Libyuv(
    src.y, src.yStride,
    src.u, src.uStride,
    src.v, src.vStride,
    dst.yPointer(), dst.yStride,
    dst.uvPointer(), dst.uvStride,
    src.width, src.height,
    "copyI420ToNV12"
  )

# -----------------------------------------------------------------------------
# --- copyI420ToNV12 owned -> owned
# -----------------------------------------------------------------------------

proc copyI420ToNV12*(
    src: OwnedI420Frame;
    dst: var OwnedNV12Frame
  ): FFmpegResult[void] =
  if src.width != dst.width or src.height != dst.height:
    result = fail[void](
      "copyI420ToNV12",
      &"Frame size mismatch: src={src.width}x{src.height} dst={dst.width}x{dst.height}"
    )
    return

  result = copyI420ToNV12Libyuv(
    src.yPointer(), src.yStride,
    src.uPointer(), src.uStride,
    src.vPointer(), src.vStride,
    dst.yPointer(), dst.yStride,
    dst.uvPointer(), dst.uvStride,
    src.width, src.height,
    "copyI420ToNV12"
  )

# -----------------------------------------------------------------------------
# --- copyI420ToNV12 decoded borrowed -> encoder writable
# -----------------------------------------------------------------------------

proc copyI420ToNV12*(
    src: Yuv420FrameView;
    dst: WritableNV12FrameView
  ): FFmpegResult[void] =
  if not src.hasUsableYuv420Planes():
    result = fail[void](
      "copyI420ToNV12",
      &"Source is not a usable I420 frame: {src.width}x{src.height} {src.format.pixelFormatName()}"
    )
    return

  if not dst.hasUsableNv12Planes():
    result = fail[void](
      "copyI420ToNV12",
      &"Destination is not a usable writable NV12 frame: {dst.width}x{dst.height} {dst.format.pixelFormatName()}"
    )
    return

  if src.width != dst.width or src.height != dst.height:
    result = fail[void](
      "copyI420ToNV12",
      &"Frame size mismatch: src={src.width}x{src.height} dst={dst.width}x{dst.height}"
    )
    return

  result = copyI420ToNV12Libyuv(
    src.y, src.yStride,
    src.u, src.uStride,
    src.v, src.vStride,
    dst.y, dst.yStride,
    dst.uv, dst.uvStride,
    src.width, src.height,
    "copyI420ToNV12"
  )

# -----------------------------------------------------------------------------
# --- copyI420ToNV12 owned -> encoder writable
# -----------------------------------------------------------------------------

proc copyI420ToNV12*(
    src: OwnedI420Frame;
    dst: WritableNV12FrameView
  ): FFmpegResult[void] =
  if not dst.hasUsableNv12Planes():
    result = fail[void](
      "copyI420ToNV12",
      &"Destination is not a usable writable NV12 frame: {dst.width}x{dst.height} {dst.format.pixelFormatName()}"
    )
    return

  if src.width != dst.width or src.height != dst.height:
    result = fail[void](
      "copyI420ToNV12",
      &"Frame size mismatch: src={src.width}x{src.height} dst={dst.width}x{dst.height}"
    )
    return

  result = copyI420ToNV12Libyuv(
    src.yPointer(), src.yStride,
    src.uPointer(), src.uStride,
    src.vPointer(), src.vStride,
    dst.y, dst.yStride,
    dst.uv, dst.uvStride,
    src.width, src.height,
    "copyI420ToNV12"
  )

# -----------------------------------------------------------------------------
# --- copyNV12 owned -> encoder writable
# -----------------------------------------------------------------------------

proc copyNV12*(
    src: OwnedNV12Frame;
    dst: WritableNV12FrameView
  ): FFmpegResult[void] =
  if not dst.hasUsableNv12Planes():
    result = fail[void](
      "copyNV12",
      &"Destination is not a usable writable NV12 frame: {dst.width}x{dst.height} {dst.format.pixelFormatName()}"
    )
    return

  if src.width != dst.width or src.height != dst.height:
    result = fail[void](
      "copyNV12",
      &"Frame size mismatch: src={src.width}x{src.height} dst={dst.width}x{dst.height}"
    )
    return

  let yRet = copyPlane(
    src.yPointer(),
    src.yStride,
    dst.y,
    dst.yStride,
    src.width,
    src.height
  )
  if yRet.isErr:
    result = err(yRet.error)
    return

  result = copyPlane(
    src.uvPointer(),
    src.uvStride,
    dst.uv,
    dst.uvStride,
    src.width,
    chromaHeight(src.height)
  )

# =============================================================================
# === Public I420 -> padded NV12 copy helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- copyI420ToNV12Padded decoded borrowed -> encoder writable
# -----------------------------------------------------------------------------

proc copyI420ToNV12Padded*(
    src: Yuv420FrameView;
    dst: WritableNV12FrameView
  ): FFmpegResult[void] =
  ## Copy an I420 frame into an NV12 frame whose storage height may be larger
  ## than the visible source height.
  ##
  ## This is useful for V4L2 encoders that internally align 1080-line input to
  ## 1088 lines and expect the UV plane after the aligned Y storage area.
  if not src.hasUsableYuv420Planes():
    result = fail[void](
      "copyI420ToNV12Padded",
      &"Source is not a usable I420 frame: {src.width}x{src.height} {src.format.pixelFormatName()}"
    )
    return

  if not dst.hasUsableNv12Planes():
    result = fail[void](
      "copyI420ToNV12Padded",
      &"Destination is not a usable writable NV12 frame: {dst.width}x{dst.height} {dst.format.pixelFormatName()}"
    )
    return

  if src.width != dst.width or src.height > dst.height:
    result = fail[void](
      "copyI420ToNV12Padded",
      &"Frame size mismatch: src={src.width}x{src.height} dst={dst.width}x{dst.height}"
    )
    return

  let convertRet = copyI420ToNV12Libyuv(
    src.y, src.yStride,
    src.u, src.uStride,
    src.v, src.vStride,
    dst.y, dst.yStride,
    dst.uv, dst.uvStride,
    src.width, src.height,
    "copyI420ToNV12Padded"
  )
  if convertRet.isErr:
    result = err(convertRet.error)
    return

  let yPadRet = replicateLastRows(
    dst.y,
    dst.yStride,
    src.width,
    src.height,
    dst.height
  )
  if yPadRet.isErr:
    result = err(yPadRet.error)
    return

  result = replicateLastRows(
    dst.uv,
    dst.uvStride,
    src.width,
    chromaHeight(src.height),
    chromaHeight(dst.height)
  )

# -----------------------------------------------------------------------------
# --- copyI420ToNV12Padded owned -> encoder writable
# -----------------------------------------------------------------------------

proc copyI420ToNV12Padded*(
    src: OwnedI420Frame;
    dst: WritableNV12FrameView
  ): FFmpegResult[void] =
  ## Copy an owned I420 frame into an NV12 frame whose storage height may be
  ## larger than the visible source height.
  if not dst.hasUsableNv12Planes():
    result = fail[void](
      "copyI420ToNV12Padded",
      &"Destination is not a usable writable NV12 frame: {dst.width}x{dst.height} {dst.format.pixelFormatName()}"
    )
    return

  if src.width != dst.width or src.height > dst.height:
    result = fail[void](
      "copyI420ToNV12Padded",
      &"Frame size mismatch: src={src.width}x{src.height} dst={dst.width}x{dst.height}"
    )
    return

  let convertRet = copyI420ToNV12Libyuv(
    src.yPointer(), src.yStride,
    src.uPointer(), src.uStride,
    src.vPointer(), src.vStride,
    dst.y, dst.yStride,
    dst.uv, dst.uvStride,
    src.width, src.height,
    "copyI420ToNV12Padded"
  )
  if convertRet.isErr:
    result = err(convertRet.error)
    return

  let yPadRet = replicateLastRows(
    dst.y,
    dst.yStride,
    src.width,
    src.height,
    dst.height
  )
  if yPadRet.isErr:
    result = err(yPadRet.error)
    return

  result = replicateLastRows(
    dst.uv,
    dst.uvStride,
    src.width,
    chromaHeight(src.height),
    chromaHeight(dst.height)
  )


# =============================================================================
# === Public RGBX -> padded NV12 copy helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- copyRGBXToNV12Padded owned RGBX -> encoder writable
# -----------------------------------------------------------------------------

proc copyRGBXToNV12Padded*(
    src: OwnedRGBXFrame;
    dst: WritableNV12FrameView
  ): FFmpegResult[void] =
  ## Convert an owned RGBX frame directly into an NV12 frame whose storage
  ## height may be larger than the visible source height.
  ##
  ## PixelRGBX uses R,G,B,X byte order. Existing RGBX helpers use libyuv's
  ## ABGR family for this memory layout on little-endian systems, so this uses
  ## ABGRToNV12 for the same reason.
  if not src.isValid():
    result = fail[void]("copyRGBXToNV12Padded", "Source RGBX frame is invalid")
    return

  if not dst.hasUsableNv12Planes():
    result = fail[void](
      "copyRGBXToNV12Padded",
      &"Destination is not a usable writable NV12 frame: {dst.width}x{dst.height} {dst.format.pixelFormatName()}"
    )
    return

  if src.width != dst.width or src.height > dst.height:
    result = fail[void](
      "copyRGBXToNV12Padded",
      &"Frame size mismatch: src={src.width}x{src.height} dst={dst.width}x{dst.height}"
    )
    return

  let convertRet = copyRGBXToNV12Libyuv(
    src.rawData(), src.strideBytes(),
    dst.y, dst.yStride,
    dst.uv, dst.uvStride,
    src.width, src.height,
    "copyRGBXToNV12Padded"
  )
  if convertRet.isErr:
    result = err(convertRet.error)
    return

  let yPadRet = replicateLastRows(
    dst.y,
    dst.yStride,
    src.width,
    src.height,
    dst.height
  )
  if yPadRet.isErr:
    result = err(yPadRet.error)
    return

  result = replicateLastRows(
    dst.uv,
    dst.uvStride,
    src.width,
    chromaHeight(src.height),
    chromaHeight(dst.height)
  )
