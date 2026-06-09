# tests/test_decode_one.nim
#
# Minimal one-frame decode smoke test for libav_nim.

import std/os
import libav_nim

# =============================================================================
# === Command line helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- usage
# -----------------------------------------------------------------------------

proc usage() =
  let exe = getAppFilename().extractFilename()
  echo "usage: ", exe, " <input> [decoder-name]"
  echo "example: ", exe, " bbb_h265.mp4 hevc_v4l2m2m"

# =============================================================================
# === Main
# =============================================================================

# -----------------------------------------------------------------------------
# --- main
# -----------------------------------------------------------------------------

proc main() =
  let args = commandLineParams()
  if args.len < 1:
    usage()
    quit 1

  let inputPath = args[0]
  let decoderName = if args.len >= 2: args[1] else: ""

  let options = DecoderOptions(decoderName: decoderName)
  let openRet = openVideoDecoder(inputPath, options)
  if openRet.isErr:
    echo openRet.error
    quit 1

  let decoder = openRet.value
  defer: decoder.close()

  let readRet = decoder.readFrame()
  if readRet.isErr:
    echo readRet.error
    quit 1

  if readRet.value.eof:
    echo "EOF before first video frame"
    quit 2

  let frame = readRet.value.frame
  echo "decoded frame:"
  echo "  size      : ", frame.width, "x", frame.height
  echo "  yStride   : ", frame.yStride
  echo "  uStride   : ", frame.uStride
  echo "  vStride   : ", frame.vStride
  echo "  pts       : ", frame.pts
  echo "  timeBase  : ", frame.timeBase.num, "/", frame.timeBase.den
  echo "  y pointer : ", cast[uint](frame.y)
  echo "  u pointer : ", cast[uint](frame.u)
  echo "  v pointer : ", cast[uint](frame.v)

when isMainModule:
  main()
