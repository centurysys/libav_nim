# libav_nim/error.nim
#
# Result-based error helpers for FFmpeg return codes.

import std/strformat
import results
export results

import ./bindings/c_api

# =============================================================================
# === Error constants
# =============================================================================

const
  ffmpegErrorBufferSize* = 256
  posixEagain* = 11
  avErrorAgain* = -posixEagain
  avErrorEof* = -541478725

# =============================================================================
# === Error value types
# =============================================================================

type
  FFmpegFailure* = object
    ## Nim-side error value used by Result-based APIs.
    code*: cint
    context*: string
    message*: string

  FFmpegResult*[T] = Result[T, FFmpegFailure]

# =============================================================================
# === Error string helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- avErrorString
# -----------------------------------------------------------------------------

proc avErrorString*(code: cint): string =
  var buffer: array[ffmpegErrorBufferSize, char]
  let ret = av_strerror(code, cast[cstring](addr buffer[0]), csize_t(buffer.len))

  if ret < 0:
    result = &"FFmpeg error {code}"
    return

  result = $cast[cstring](addr buffer[0])

# -----------------------------------------------------------------------------
# --- newFFmpegFailure
# -----------------------------------------------------------------------------

proc newFFmpegFailure*(code: cint; context: string): FFmpegFailure =
  let detail = avErrorString(code)
  let message =
    if context.len > 0:
      &"{context}: {detail} ({code})"
    else:
      &"{detail} ({code})"

  result = FFmpegFailure(
    code: code,
    context: context,
    message: message
  )

# -----------------------------------------------------------------------------
# --- newLibraryFailure
# -----------------------------------------------------------------------------

proc newLibraryFailure*(context: string; message: string): FFmpegFailure =
  result = FFmpegFailure(
    code: 0,
    context: context,
    message: if context.len > 0: &"{context}: {message}" else: message
  )

# -----------------------------------------------------------------------------
# --- `$`
# -----------------------------------------------------------------------------

proc `$`*(failure: FFmpegFailure): string =
  result = failure.message

# =============================================================================
# === Result helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- okAv
# -----------------------------------------------------------------------------

proc okAv*(code: cint; context: string): FFmpegResult[cint] =
  if code < 0:
    result = err(newFFmpegFailure(code, context))
    return

  result = ok(code)

# -----------------------------------------------------------------------------
# --- fail
# -----------------------------------------------------------------------------

proc fail*[T](context: string; message: string): FFmpegResult[T] =
  result = err(newLibraryFailure(context, message))

# -----------------------------------------------------------------------------
# --- failCode
# -----------------------------------------------------------------------------

proc failCode*[T](code: cint; context: string): FFmpegResult[T] =
  result = err(newFFmpegFailure(code, context))

# -----------------------------------------------------------------------------
# --- isAgain
# -----------------------------------------------------------------------------

proc isAgain*(code: cint): bool =
  result = code == avErrorAgain

# -----------------------------------------------------------------------------
# --- isEof
# -----------------------------------------------------------------------------

proc isEof*(code: cint): bool =
  result = code == avErrorEof
