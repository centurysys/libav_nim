# libav_nim/highlevel/video_rate.nim
#
# Small video-rate helpers used by the high-level camera/transcode pipeline.
#
# VideoRate represents a nominal application/output frame rate.  RTSP sources
# can advertise misleading rates, so high-level code should keep the user-chosen
# nominal rate separate from any source stream metadata.

import std/[math, strformat, strutils]

import ../lowlevel/types

# =============================================================================
# === Video rate value type
# =============================================================================

type
  VideoRate* = object
    ## Rational video frame rate.
    ##
    ## Examples:
    ##   20       -> VideoRate(num: 20, den: 1)
    ##   30000/1001 -> VideoRate(num: 30000, den: 1001)
    num*: int32
    den*: int32

# =============================================================================
# === Construction / validation
# =============================================================================

# -----------------------------------------------------------------------------
# --- initVideoRate
# -----------------------------------------------------------------------------

proc initVideoRate*(num: int; den = 1): VideoRate =
  ## Create a validated VideoRate.
  if num <= 0 or den <= 0:
    raise newException(ValueError, &"Invalid video rate: {num}/{den}")

  if num > int(high(int32)) or den > int(high(int32)):
    raise newException(ValueError, &"Video rate is too large: {num}/{den}")

  result = VideoRate(num: int32(num), den: int32(den))

# -----------------------------------------------------------------------------
# --- isValid
# -----------------------------------------------------------------------------

proc isValid*(rate: VideoRate): bool =
  result = rate.num > 0 and rate.den > 0

# -----------------------------------------------------------------------------
# --- requireValid
# -----------------------------------------------------------------------------

proc requireValid*(rate: VideoRate) =
  if not rate.isValid():
    raise newException(ValueError, &"Invalid video rate: {rate.num}/{rate.den}")

# -----------------------------------------------------------------------------
# --- parseVideoRate
# -----------------------------------------------------------------------------

proc parseVideoRate*(text: string): VideoRate =
  ## Parse N or N/D as a VideoRate.
  let slash = text.find('/')
  if slash >= 0:
    if slash == 0 or slash >= text.len - 1:
      raise newException(ValueError, &"Invalid fps value: {text}")

    result = initVideoRate(
      parseInt(text[0 ..< slash]),
      parseInt(text[slash + 1 .. ^1])
    )
    return

  result = initVideoRate(parseInt(text), 1)

# =============================================================================
# === Formatting / conversion helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- rateText
# -----------------------------------------------------------------------------

proc rateText*(rate: VideoRate): string =
  rate.requireValid()
  if rate.den == 1:
    result = $rate.num
  else:
    result = &"{rate.num}/{rate.den}"

# -----------------------------------------------------------------------------
# --- `$`
# -----------------------------------------------------------------------------

proc `$`*(rate: VideoRate): string =
  result = rate.rateText()

# -----------------------------------------------------------------------------
# --- rateFloat
# -----------------------------------------------------------------------------

proc rateFloat*(rate: VideoRate): float =
  rate.requireValid()
  result = float(rate.num) / float(rate.den)

# -----------------------------------------------------------------------------
# --- timeBase
# -----------------------------------------------------------------------------

proc timeBase*(rate: VideoRate): Rational =
  ## Return the usual encoder time_base for one tick per frame.
  rate.requireValid()
  result = Rational(num: rate.den, den: rate.num)

# -----------------------------------------------------------------------------
# --- frameRate
# -----------------------------------------------------------------------------

proc frameRate*(rate: VideoRate): Rational =
  ## Return the same value as an FFmpeg-style frame rate Rational.
  rate.requireValid()
  result = Rational(num: rate.num, den: rate.den)

# -----------------------------------------------------------------------------
# --- gopSize
# -----------------------------------------------------------------------------

proc gopSize*(rate: VideoRate): int =
  ## Return an initial 1-second GOP size rounded up to at least one frame.
  rate.requireValid()
  result = max(1, int((rate.num + rate.den - 1) div rate.den))

# -----------------------------------------------------------------------------
# --- timestampUsecForFrame
# -----------------------------------------------------------------------------

proc timestampUsecForFrame*(rate: VideoRate; frameIndex: int64): int64 =
  ## Convert a zero-based frame index to microseconds using the nominal rate.
  rate.requireValid()
  if frameIndex < 0:
    raise newException(ValueError, &"Invalid frame index: {frameIndex}")

  result = frameIndex * 1_000_000'i64 * int64(rate.den) div int64(rate.num)
