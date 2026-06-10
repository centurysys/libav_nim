# =============================================================================
# === FFmpeg C API binding include switch
# =============================================================================

import ./libnames

when defined(ffmpeg7):
  include generated/ffmpeg7/ffmpeg_types_gen
  include generated/ffmpeg7/ffmpeg_consts_gen
else:
  include generated/ffmpeg8/ffmpeg_types_gen
  include generated/ffmpeg8/ffmpeg_consts_gen

{.push dynlib: avutilLib.}
when defined(ffmpeg7):
  include generated/ffmpeg7/avutil_api_gen
else:
  include generated/ffmpeg8/avutil_api_gen
{.pop.}

{.push dynlib: avcodecLib.}
when defined(ffmpeg7):
  include generated/ffmpeg7/avcodec_api_gen
else:
  include generated/ffmpeg8/avcodec_api_gen
{.pop.}

{.push dynlib: avformatLib.}
when defined(ffmpeg7):
  include generated/ffmpeg7/avformat_api_gen
else:
  include generated/ffmpeg8/avformat_api_gen
{.pop.}
