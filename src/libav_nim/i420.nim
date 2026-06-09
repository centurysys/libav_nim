# libav_nim/i420.nim
#
# Small I420/YUV420P helpers that do not depend on libyuv.

import std/strformat
import results
import ./error
import ./types

# =============================================================================
# === Owned I420 frame buffer
# =============================================================================

type
  OwnedI420Frame* = object
    ## Owned contiguous I420/YUV420P frame buffer.
    ##
    ## Layout:
    ##   Y plane: width * height bytes
    ##   U plane: chromaWidth * chromaHeight bytes
    ##   V plane: chromaWidth * chromaHeight bytes
    ##
    ## Strides are tightly packed. This is intentionally simple and independent
    ## from FFmpeg's AVFrame lifetime.
    width*: int
    height*: int
    yStride*: int
    uStride*: int
    vStride*: int
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

proc ySize(frame: OwnedI420Frame): int =
  result = frame.yStride * frame.height

# -----------------------------------------------------------------------------
# --- uSize
# -----------------------------------------------------------------------------

proc uSize(frame: OwnedI420Frame): int =
  result = frame.uStride * chromaHeight(frame.height)

# -----------------------------------------------------------------------------
# --- vSize
# -----------------------------------------------------------------------------

proc vSize(frame: OwnedI420Frame): int =
  result = frame.vStride * chromaHeight(frame.height)

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
# --- ownedPlanePointers
# -----------------------------------------------------------------------------

proc yPointer(frame: var OwnedI420Frame): pointer =
  if frame.data.len == 0:
    result = nil
    return

  result = addr frame.data[0]

proc uPointer(frame: var OwnedI420Frame): pointer =
  if frame.data.len == 0:
    result = nil
    return

  let offset = frame.ySize()
  result = addr frame.data[offset]

proc vPointer(frame: var OwnedI420Frame): pointer =
  if frame.data.len == 0:
    result = nil
    return

  let offset = frame.ySize() + frame.uSize()
  result = addr frame.data[offset]

proc yPointer(frame: OwnedI420Frame): pointer =
  if frame.data.len == 0:
    result = nil
    return

  result = unsafeAddr frame.data[0]

proc uPointer(frame: OwnedI420Frame): pointer =
  if frame.data.len == 0:
    result = nil
    return

  let offset = frame.ySize()
  result = unsafeAddr frame.data[offset]

proc vPointer(frame: OwnedI420Frame): pointer =
  if frame.data.len == 0:
    result = nil
    return

  let offset = frame.ySize() + frame.uSize()
  result = unsafeAddr frame.data[offset]

# =============================================================================
# === Public owned frame helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- newOwnedI420Frame
# -----------------------------------------------------------------------------

proc newOwnedI420Frame*(width, height: int): FFmpegResult[OwnedI420Frame] =
  if width <= 0 or height <= 0:
    result = fail[OwnedI420Frame](
      "newOwnedI420Frame",
      &"Invalid frame size: {width}x{height}"
    )
    return

  let cw = chromaWidth(width)
  let ch = chromaHeight(height)
  let totalBytes = width * height + cw * ch * 2

  var frame = OwnedI420Frame(
    width: width,
    height: height,
    yStride: width,
    uStride: cw,
    vStride: cw,
    data: newSeq[byte](totalBytes)
  )

  result = ok(frame)

# -----------------------------------------------------------------------------
# --- byteSize
# -----------------------------------------------------------------------------

proc byteSize*(frame: OwnedI420Frame): int =
  result = frame.data.len

# -----------------------------------------------------------------------------
# --- clear
# -----------------------------------------------------------------------------

proc clear*(frame: var OwnedI420Frame; value: byte = 0) =
  for i in 0 ..< frame.data.len:
    frame.data[i] = value

# =============================================================================
# === Public I420 copy helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- copyI420 decoded borrowed -> encoder writable
# -----------------------------------------------------------------------------

proc copyI420*(
    src: Yuv420FrameView;
    dst: WritableI420FrameView
  ): FFmpegResult[void] =
  ## Copy a borrowed decoded I420/YUV420P frame into an encoder-owned writable
  ## I420/YUV420P frame.
  ##
  ## This copies only visible pixels row by row and tolerates different source
  ## and destination strides. The destination view must still be submitted before
  ## the encoder frame is reused.
  if not src.hasUsableYuv420Planes():
    result = fail[void](
      "copyI420",
      &"Source is not a usable I420 frame: {src.width}x{src.height} {src.format.pixelFormatName()}"
    )
    return

  if not dst.hasUsableYuv420Planes():
    result = fail[void](
      "copyI420",
      &"Destination is not a usable writable I420 frame: {dst.width}x{dst.height} {dst.format.pixelFormatName()}"
    )
    return

  if src.width != dst.width or src.height != dst.height:
    result = fail[void](
      "copyI420",
      &"Frame size mismatch: src={src.width}x{src.height} dst={dst.width}x{dst.height}"
    )
    return

  let yRet = copyPlane(
    src.y,
    src.yStride,
    dst.y,
    dst.yStride,
    src.width,
    src.height
  )
  if yRet.isErr:
    result = err(yRet.error)
    return

  let cw = chromaWidth(src.width)
  let ch = chromaHeight(src.height)

  let uRet = copyPlane(
    src.u,
    src.uStride,
    dst.u,
    dst.uStride,
    cw,
    ch
  )
  if uRet.isErr:
    result = err(uRet.error)
    return

  let vRet = copyPlane(
    src.v,
    src.vStride,
    dst.v,
    dst.vStride,
    cw,
    ch
  )
  if vRet.isErr:
    result = err(vRet.error)
    return

  result = ok()

# -----------------------------------------------------------------------------
# --- copyI420 decoded borrowed -> owned
# -----------------------------------------------------------------------------

proc copyI420*(
    src: Yuv420FrameView;
    dst: var OwnedI420Frame
  ): FFmpegResult[void] =
  ## Copy a borrowed decoded I420/YUV420P frame into an owned I420 buffer.
  ##
  ## This is useful when the decoded AVFrame lifetime must be decoupled from
  ## subsequent encoder or muxer operations.
  if not src.hasUsableYuv420Planes():
    result = fail[void](
      "copyI420",
      &"Source is not a usable I420 frame: {src.width}x{src.height} {src.format.pixelFormatName()}"
    )
    return

  if src.width != dst.width or src.height != dst.height:
    result = fail[void](
      "copyI420",
      &"Frame size mismatch: src={src.width}x{src.height} dst={dst.width}x{dst.height}"
    )
    return

  let yRet = copyPlane(
    src.y,
    src.yStride,
    dst.yPointer(),
    dst.yStride,
    src.width,
    src.height
  )
  if yRet.isErr:
    result = err(yRet.error)
    return

  let cw = chromaWidth(src.width)
  let ch = chromaHeight(src.height)

  let uRet = copyPlane(
    src.u,
    src.uStride,
    dst.uPointer(),
    dst.uStride,
    cw,
    ch
  )
  if uRet.isErr:
    result = err(uRet.error)
    return

  let vRet = copyPlane(
    src.v,
    src.vStride,
    dst.vPointer(),
    dst.vStride,
    cw,
    ch
  )
  if vRet.isErr:
    result = err(vRet.error)
    return

  result = ok()

# -----------------------------------------------------------------------------
# --- copyI420 owned -> encoder writable
# -----------------------------------------------------------------------------

proc copyI420*(
    src: OwnedI420Frame;
    dst: WritableI420FrameView
  ): FFmpegResult[void] =
  ## Copy an owned I420 buffer into an encoder-owned writable I420/YUV420P frame.
  if not dst.hasUsableYuv420Planes():
    result = fail[void](
      "copyI420",
      &"Destination is not a usable writable I420 frame: {dst.width}x{dst.height} {dst.format.pixelFormatName()}"
    )
    return

  if src.width != dst.width or src.height != dst.height:
    result = fail[void](
      "copyI420",
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

  let cw = chromaWidth(src.width)
  let ch = chromaHeight(src.height)

  let uRet = copyPlane(
    src.uPointer(),
    src.uStride,
    dst.u,
    dst.uStride,
    cw,
    ch
  )
  if uRet.isErr:
    result = err(uRet.error)
    return

  let vRet = copyPlane(
    src.vPointer(),
    src.vStride,
    dst.v,
    dst.vStride,
    cw,
    ch
  )
  if vRet.isErr:
    result = err(vRet.error)
    return

  result = ok()
