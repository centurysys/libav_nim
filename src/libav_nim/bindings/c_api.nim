# c_api.nim skeleton for the split Futhark output.
# Place this next to generated/ and adjust import paths as needed.

when defined(debianFfmpeg7):
  const
    avutilLib* = "libavutil.so.59"
    avcodecLib* = "libavcodec.so.61"
    avformatLib* = "libavformat.so.61"
elif defined(alpineFfmpeg8):
  const
    avutilLib* = "libavutil.so.60"
    avcodecLib* = "libavcodec.so.62"
    avformatLib* = "libavformat.so.62"
else:
  const
    avutilLib* = "libavutil.so"
    avcodecLib* = "libavcodec.so"
    avformatLib* = "libavformat.so"

include generated/ffmpeg_types_gen
include generated/ffmpeg_consts_gen

{.push dynlib: avutilLib.}
include generated/avutil_api_gen
{.pop.}

{.push dynlib: avcodecLib.}
include generated/avcodec_api_gen
{.pop.}

{.push dynlib: avformatLib.}
include generated/avformat_api_gen
{.pop.}
