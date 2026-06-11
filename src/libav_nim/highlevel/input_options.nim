# libav_nim/highlevel/input_options.nim
#
# Shared helpers for FFmpeg input options used by network camera inputs.

import std/[strformat, strutils]

import ../lowlevel/decoder

# =============================================================================
# === Decoder input option helpers
# =============================================================================

proc parseInputOption*(value: string): DecoderInputOption =
  ## Parse a KEY=VALUE input option string.
  ##
  ## This is intended for CLI/test tools that expose raw FFmpeg input options.
  let sep = value.find('=')
  if sep <= 0 or sep >= value.len - 1:
    raise newException(IOError, &"Invalid input option value: {value}. Expected KEY=VALUE")

  result = (key: value[0 ..< sep], value: value[sep + 1 .. ^1])

proc setInputOption*(options: var seq[DecoderInputOption]; key, value: string) =
  ## Add an input option, replacing an earlier option with the same key.
  ##
  ## This mirrors av_dict_set() behavior and keeps the option list deterministic
  ## when presets and explicit user options are combined.
  for item in options.mitems:
    if item.key == key:
      item.value = value
      return

  options.add((key: key, value: value))

proc addRtspLowLatencyOptions*(options: var seq[DecoderInputOption]) =
  ## Add common RTSP camera probing options.
  ##
  ## These options are passed to avformat_open_input(); codec-level options are
  ## intentionally not set here.
  options.setInputOption("allowed_media_types", "video")
  options.setInputOption("analyzeduration", "0")
  options.setInputOption("probesize", "32")
  options.setInputOption("fpsprobesize", "0")
  options.setInputOption("fflags", "nobuffer")
