# libav_nim/overlay_basic.nim
#
# Lightweight drawing helpers for OwnedRGBXFrame.
#
# This module intentionally avoids Pixie.  It is useful for validating the
# decode -> RGBX -> draw -> encode path and for very small production overlays.

import std/[algorithm, strformat]
import ./rgbx

# =============================================================================
# === Internal helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- clampInt
# -----------------------------------------------------------------------------

proc clampInt(x, lo, hi: int): int =
  if x < lo:
    result = lo
  elif x > hi:
    result = hi
  else:
    result = x

# -----------------------------------------------------------------------------
# --- makePixel
# -----------------------------------------------------------------------------

proc makePixel(r, g, b: uint8; x: uint8 = 255): PixelRGBX =
  result = PixelRGBX(r: r, g: g, b: b, x: x)

# -----------------------------------------------------------------------------
# --- putPixel
# -----------------------------------------------------------------------------

proc putPixel(frame: var OwnedRGBXFrame; px, py: int; pixel: PixelRGBX) =
  if not frame.isValid():
    return

  if px < 0 or px >= frame.width or py < 0 or py >= frame.height:
    return

  frame.data[py * frame.stridePixels + px] = pixel

# =============================================================================
# === Public drawing helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- drawHLine
# -----------------------------------------------------------------------------

proc drawHLine*(
    frame: var OwnedRGBXFrame;
    x0, x1, y: int;
    r, g, b: uint8;
    x: uint8 = 255
  ) =
  if not frame.isValid() or y < 0 or y >= frame.height:
    return

  let sx = clampInt(min(x0, x1), 0, frame.width - 1)
  let ex = clampInt(max(x0, x1), 0, frame.width - 1)
  let pixel = makePixel(r, g, b, x)

  for px in sx .. ex:
    frame.putPixel(px, y, pixel)

# -----------------------------------------------------------------------------
# --- drawVLine
# -----------------------------------------------------------------------------

proc drawVLine*(
    frame: var OwnedRGBXFrame;
    x, y0, y1: int;
    r, g, b: uint8;
    alpha: uint8 = 255
  ) =
  if not frame.isValid() or x < 0 or x >= frame.width:
    return

  let sy = clampInt(min(y0, y1), 0, frame.height - 1)
  let ey = clampInt(max(y0, y1), 0, frame.height - 1)
  let pixel = makePixel(r, g, b, alpha)

  for py in sy .. ey:
    frame.putPixel(x, py, pixel)

# -----------------------------------------------------------------------------
# --- drawRect
# -----------------------------------------------------------------------------

proc drawRect*(
    frame: var OwnedRGBXFrame;
    x0, y0, x1, y1: int;
    thickness: int;
    r, g, b: uint8;
    x: uint8 = 255
  ) =
  if not frame.isValid():
    return

  let t = max(thickness, 1)

  for i in 0 ..< t:
    frame.drawHLine(x0, x1, y0 + i, r, g, b, x)
    frame.drawHLine(x0, x1, y1 - i, r, g, b, x)
    frame.drawVLine(x0 + i, y0, y1, r, g, b, x)
    frame.drawVLine(x1 - i, y0, y1, r, g, b, x)

# -----------------------------------------------------------------------------
# --- fillRect
# -----------------------------------------------------------------------------

proc fillRect*(
    frame: var OwnedRGBXFrame;
    x0, y0, x1, y1: int;
    r, g, b: uint8;
    x: uint8 = 255
  ) =
  if not frame.isValid():
    return

  let sx = clampInt(min(x0, x1), 0, frame.width - 1)
  let ex = clampInt(max(x0, x1), 0, frame.width - 1)
  let sy = clampInt(min(y0, y1), 0, frame.height - 1)
  let ey = clampInt(max(y0, y1), 0, frame.height - 1)
  let pixel = makePixel(r, g, b, x)

  for py in sy .. ey:
    let base = py * frame.stridePixels
    for px in sx .. ex:
      frame.data[base + px] = pixel

# -----------------------------------------------------------------------------
# --- drawCrosshair
# -----------------------------------------------------------------------------

proc drawCrosshair*(
    frame: var OwnedRGBXFrame;
    cx, cy, size: int;
    r, g, b: uint8;
    x: uint8 = 255
  ) =
  frame.drawHLine(cx - size, cx + size, cy, r, g, b, x)
  frame.drawVLine(cx, cy - size, cy + size, r, g, b, x)

# -----------------------------------------------------------------------------
# --- drawTestOverlay
# -----------------------------------------------------------------------------

proc drawTestOverlay*(frame: var OwnedRGBXFrame; frameIndex: int) =
  ## Draw a small deterministic overlay for pipeline validation.
  ##
  ## This is intentionally primitive.  Pixie or an application-specific overlay
  ## module can be layered on top of OwnedRGBXFrame later.
  if not frame.isValid():
    return

  frame.drawRect(20, 20, frame.width - 21, frame.height - 21, 3, 255, 32, 32)
  frame.fillRect(30, 30, 270, 72, 0, 0, 0)
  frame.drawRect(30, 30, 270, 72, 2, 255, 255, 255)

  let boxW = max(frame.width div 8, 80)
  let boxH = max(frame.height div 8, 45)
  let rangeX = max(frame.width - boxW - 60, 1)
  let rangeY = max(frame.height - boxH - 100, 1)
  let x0 = 40 + ((frameIndex * 7) mod rangeX)
  let y0 = 90 + ((frameIndex * 3) mod rangeY)

  frame.drawRect(x0, y0, x0 + boxW, y0 + boxH, 4, 32, 255, 32)
  frame.drawCrosshair(frame.width div 2, frame.height div 2, 24, 255, 255, 0)
