# libav_nim/rgbx.nim
#
# Owned RGBX frame buffer and libyuv-backed I420 <-> RGBX helpers.
#
# This module intentionally does not depend on Pixie.  It exposes a pixel-based
# RGBX storage layout that an optional Pixie adapter can move into Pixie Image
# data without full-frame copies.

import std/[strformat]
import results
import ./error
import ./types
import ./i420

# =============================================================================
# === libyuv dynamic imports
# =============================================================================

when defined(libyuvStatic):
  {.passL: "-lyuv".}
  const libyuvDynlib = ""
else:
  const libyuvDynlib = "libyuv.so"

proc I420ToABGR(
    srcY: pointer;
    srcStrideY: cint;
    srcU: pointer;
    srcStrideU: cint;
    srcV: pointer;
    srcStrideV: cint;
    dstABGR: pointer;
    dstStrideABGR: cint;
    width: cint;
    height: cint
  ): cint {.cdecl, importc: "I420ToABGR", dynlib: libyuvDynlib.}

proc ABGRToI420(
    srcABGR: pointer;
    srcStrideABGR: cint;
    dstY: pointer;
    dstStrideY: cint;
    dstU: pointer;
    dstStrideU: cint;
    dstV: pointer;
    dstStrideV: cint;
    width: cint;
    height: cint
  ): cint {.cdecl, importc: "ABGRToI420", dynlib: libyuvDynlib.}

# =============================================================================
# === Types
# =============================================================================

type
  PixelRGBX* = object
    ## One RGBX/RGBA-compatible pixel in memory order.
    ##
    ## This layout intentionally matches Pixie ColorRGBX / RGBA-like 4-byte
    ## storage used by the optional zero-copy Pixie adapter.
    r*, g*, b*, x*: uint8

  OwnedRGBXFrame* = object
    ## Owned pixel-based RGBX frame buffer.
    ##
    ## `stridePixels` is the number of PixelRGBX elements per row.
    ## `strideBytes(frame)` returns the byte stride for C APIs such as libyuv.
    width*: int
    height*: int
    stridePixels*: int
    data*: seq[PixelRGBX]

# =============================================================================
# === Public frame helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- newOwnedRGBXFrame
# -----------------------------------------------------------------------------

proc newOwnedRGBXFrame*(width, height: int; stridePixels = 0): FFmpegResult[OwnedRGBXFrame] =
  if width <= 0 or height <= 0:
    result = fail[OwnedRGBXFrame](
      "newOwnedRGBXFrame",
      &"Invalid frame size: {width}x{height}"
    )
    return

  let actualStride = if stridePixels > 0: stridePixels else: width
  if actualStride < width:
    result = fail[OwnedRGBXFrame](
      "newOwnedRGBXFrame",
      &"Invalid stridePixels: {actualStride} for width {width}"
    )
    return

  result = ok(OwnedRGBXFrame(
    width: width,
    height: height,
    stridePixels: actualStride,
    data: newSeqUninit[PixelRGBX](actualStride * height)
  ))

# -----------------------------------------------------------------------------
# --- isValid
# -----------------------------------------------------------------------------

proc isValid*(frame: OwnedRGBXFrame): bool =
  result =
    frame.width > 0 and
    frame.height > 0 and
    frame.stridePixels >= frame.width and
    frame.data.len >= frame.stridePixels * frame.height

# -----------------------------------------------------------------------------
# --- byteSize
# -----------------------------------------------------------------------------

proc byteSize*(frame: OwnedRGBXFrame): int =
  result = frame.data.len * sizeof(PixelRGBX)

# -----------------------------------------------------------------------------
# --- strideBytes
# -----------------------------------------------------------------------------

proc strideBytes*(frame: OwnedRGBXFrame): int =
  result = frame.stridePixels * sizeof(PixelRGBX)

# -----------------------------------------------------------------------------
# --- rawData
# -----------------------------------------------------------------------------

proc rawData*(frame: var OwnedRGBXFrame): pointer =
  if frame.data.len == 0:
    result = nil
    return

  result = addr frame.data[0]

proc rawData*(frame: OwnedRGBXFrame): pointer =
  if frame.data.len == 0:
    result = nil
    return

  result = unsafeAddr frame.data[0]

# -----------------------------------------------------------------------------
# --- fillOpaque
# -----------------------------------------------------------------------------

proc fillOpaque*(frame: var OwnedRGBXFrame) =
  ## Set all X/alpha bytes to 255 without touching RGB.
  for i in 0 ..< frame.data.len:
    frame.data[i].x = 255'u8

# -----------------------------------------------------------------------------
# --- clear
# -----------------------------------------------------------------------------

proc clear*(frame: var OwnedRGBXFrame; r, g, b: uint8; x: uint8 = 255) =
  let pixel = PixelRGBX(r: r, g: g, b: b, x: x)
  for i in 0 ..< frame.data.len:
    frame.data[i] = pixel

# =============================================================================
# === I420 <-> RGBX conversion
# =============================================================================

# -----------------------------------------------------------------------------
# --- copyI420ToRGBX
# -----------------------------------------------------------------------------

proc copyI420ToRGBX*(
    src: Yuv420FrameView;
    dst: var OwnedRGBXFrame
  ): FFmpegResult[void] =
  ## Convert a borrowed I420/YUV420P frame into an owned RGBX frame with libyuv.
  ##
  ## libyuv's `I420ToABGR` maps to byte order R,G,B,A on little-endian systems,
  ## which matches PixelRGBX/ColorRGBX-style memory layout used here.
  if not src.hasUsableYuv420Planes():
    result = fail[void](
      "copyI420ToRGBX",
      &"Source is not a usable I420 frame: {src.width}x{src.height} {src.format.pixelFormatName()}"
    )
    return

  if not dst.isValid():
    result = fail[void]("copyI420ToRGBX", "Destination RGBX frame is invalid")
    return

  if src.width != dst.width or src.height != dst.height:
    result = fail[void](
      "copyI420ToRGBX",
      &"Frame size mismatch: src={src.width}x{src.height} dst={dst.width}x{dst.height}"
    )
    return

  let ret = I420ToABGR(
    src.y,
    cint(src.yStride),
    src.u,
    cint(src.uStride),
    src.v,
    cint(src.vStride),
    dst.rawData(),
    cint(dst.strideBytes()),
    cint(src.width),
    cint(src.height)
  )
  if ret != 0:
    result = fail[void]("copyI420ToRGBX", &"I420ToABGR failed: {ret}")
    return

  result = ok()

# -----------------------------------------------------------------------------
# --- copyRGBXToI420
# -----------------------------------------------------------------------------

proc copyRGBXToI420*(
    src: OwnedRGBXFrame;
    dst: WritableI420FrameView
  ): FFmpegResult[void] =
  ## Convert an owned RGBX frame into an encoder-owned writable I420/YUV420P
  ## frame with libyuv.
  if not src.isValid():
    result = fail[void]("copyRGBXToI420", "Source RGBX frame is invalid")
    return

  if not dst.hasUsableYuv420Planes():
    result = fail[void](
      "copyRGBXToI420",
      &"Destination is not a usable writable I420 frame: {dst.width}x{dst.height} {dst.format.pixelFormatName()}"
    )
    return

  if src.width != dst.width or src.height != dst.height:
    result = fail[void](
      "copyRGBXToI420",
      &"Frame size mismatch: src={src.width}x{src.height} dst={dst.width}x{dst.height}"
    )
    return

  let ret = ABGRToI420(
    src.rawData(),
    cint(src.strideBytes()),
    dst.y,
    cint(dst.yStride),
    dst.u,
    cint(dst.uStride),
    dst.v,
    cint(dst.vStride),
    cint(src.width),
    cint(src.height)
  )
  if ret != 0:
    result = fail[void]("copyRGBXToI420", &"ABGRToI420 failed: {ret}")
    return

  result = ok()


# =============================================================================
# === Owned I420 <-> RGBX conversion overloads
# =============================================================================

# -----------------------------------------------------------------------------
# --- copyI420ToRGBX
# -----------------------------------------------------------------------------

proc copyI420ToRGBX*(
    src: OwnedI420Frame;
    dst: var OwnedRGBXFrame
  ): FFmpegResult[void] =
  ## Convert an owned I420/YUV420P frame into an owned RGBX frame with libyuv.
  if not dst.isValid():
    result = fail[void]("copyI420ToRGBX", "Destination RGBX frame is invalid")
    return

  if src.width != dst.width or src.height != dst.height:
    result = fail[void](
      "copyI420ToRGBX",
      &"Frame size mismatch: src={src.width}x{src.height} dst={dst.width}x{dst.height}"
    )
    return

  let ret = I420ToABGR(
    src.yPointer(),
    cint(src.yStride),
    src.uPointer(),
    cint(src.uStride),
    src.vPointer(),
    cint(src.vStride),
    dst.rawData(),
    cint(dst.strideBytes()),
    cint(src.width),
    cint(src.height)
  )
  if ret != 0:
    result = fail[void]("copyI420ToRGBX", &"I420ToABGR failed: {ret}")
    return

  result = ok()

# -----------------------------------------------------------------------------
# --- copyRGBXToI420
# -----------------------------------------------------------------------------

proc copyRGBXToI420*(
    src: OwnedRGBXFrame;
    dst: var OwnedI420Frame
  ): FFmpegResult[void] =
  ## Convert an owned RGBX frame into an owned I420/YUV420P frame with libyuv.
  if not src.isValid():
    result = fail[void]("copyRGBXToI420", "Source RGBX frame is invalid")
    return

  if src.width != dst.width or src.height != dst.height:
    result = fail[void](
      "copyRGBXToI420",
      &"Frame size mismatch: src={src.width}x{src.height} dst={dst.width}x{dst.height}"
    )
    return

  let ret = ABGRToI420(
    src.rawData(),
    cint(src.strideBytes()),
    dst.yPointer(),
    cint(dst.yStride),
    dst.uPointer(),
    cint(dst.uStride),
    dst.vPointer(),
    cint(dst.vStride),
    cint(src.width),
    cint(src.height)
  )
  if ret != 0:
    result = fail[void]("copyRGBXToI420", &"ABGRToI420 failed: {ret}")
    return

  result = ok()
