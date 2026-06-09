# =============================================================================
# === FFmpeg shared library names
# =============================================================================

when defined(ffmpeg8):
  const
    avutilLib* = "libavutil.so.60"
    avcodecLib* = "libavcodec.so.62"
    avformatLib* = "libavformat.so.62"
elif defined(ffmpeg7):
  const
    avutilLib* = "libavutil.so.59"
    avcodecLib* = "libavcodec.so.61"
    avformatLib* = "libavformat.so.61"
else:
  const
    avutilLib* = "libavutil.so"
    avcodecLib* = "libavcodec.so"
    avformatLib* = "libavformat.so"
