# =============================================================================
# === FFmpeg C API binding include switch
# =============================================================================

import ./libnames

when defined(ffmpeg8):
  include generated/ffmpeg8/ffmpeg_types_gen
  include generated/ffmpeg8/ffmpeg_consts_gen
elif defined(ffmpeg7):
  include generated/ffmpeg7/ffmpeg_types_gen
  include generated/ffmpeg7/ffmpeg_consts_gen
else:
  {.error: "Define ffmpeg7 or ffmpeg8".}

{.push dynlib: avutilLib.}
when defined(ffmpeg8):
  include generated/ffmpeg8/avutil_api_gen
elif defined(ffmpeg7):
  include generated/ffmpeg7/avutil_api_gen
{.pop.}

{.push dynlib: avcodecLib.}
when defined(ffmpeg8):
  include generated/ffmpeg8/avcodec_api_gen
elif defined(ffmpeg7):
  include generated/ffmpeg7/avcodec_api_gen
{.pop.}

{.push dynlib: avformatLib.}
when defined(ffmpeg8):
  include generated/ffmpeg8/avformat_api_gen
elif defined(ffmpeg7):
  include generated/ffmpeg7/avformat_api_gen
{.pop.}
