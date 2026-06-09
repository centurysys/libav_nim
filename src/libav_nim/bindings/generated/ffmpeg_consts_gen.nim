# Generated split from ffmpeg_lowlevel_gen.nim.
# Source: ffmpeg_lowlevel_gen(1).nim
# Do not edit manually unless this file is intentionally vendored.

const
  AV_FRAME_CROP_UNALIGNED* = cuint(1)
const
  AV_OPT_FLAG_IMPLICIT_KEY* = cuint(1)
const
  AV_HWFRAME_MAP_READ* = cuint(1)
const
  AV_HWFRAME_MAP_WRITE* = cuint(2)
const
  AV_HWFRAME_MAP_OVERWRITE* = cuint(4)
const
  AV_HWFRAME_MAP_DIRECT* = cuint(8)
const
  AV_CODEC_HW_CONFIG_METHOD_HW_DEVICE_CTX* = cuint(1)
const
  AV_CODEC_HW_CONFIG_METHOD_HW_FRAMES_CTX* = cuint(2)
const
  AV_CODEC_HW_CONFIG_METHOD_INTERNAL* = cuint(4)
const
  AV_CODEC_HW_CONFIG_METHOD_AD_HOC* = cuint(8)
const
  AV_PIX_FMT_Y400A* = enum_AVPixelFormat.AV_PIX_FMT_YA8
const
  AV_PIX_FMT_GRAY8A* = enum_AVPixelFormat.AV_PIX_FMT_YA8
const
  AV_PIX_FMT_GBR24P* = enum_AVPixelFormat.AV_PIX_FMT_GBRP
const
  AVCOL_PRI_SMPTEST428_1* = enum_AVColorPrimaries.AVCOL_PRI_SMPTE428
const
  AVCOL_PRI_JEDEC_P22* = enum_AVColorPrimaries.AVCOL_PRI_EBU3213
const
  AVCOL_TRC_SMPTEST2084* = enum_AVColorTransferCharacteristic.AVCOL_TRC_SMPTE2084
const
  AVCOL_TRC_SMPTEST428_1* = enum_AVColorTransferCharacteristic.AVCOL_TRC_SMPTE428
const
  AVCOL_SPC_YCOCG* = enum_AVColorSpace.AVCOL_SPC_YCGCO
const
  AV_CODEC_ID_PCM_S16LE* = enum_AVCodecID.AV_CODEC_ID_FIRST_AUDIO
const
  AV_CODEC_ID_DVD_SUBTITLE* = enum_AVCodecID.AV_CODEC_ID_FIRST_SUBTITLE
const
  AV_CODEC_ID_TTF* = enum_AVCodecID.AV_CODEC_ID_FIRST_UNKNOWN
when 7 is static:
  const
    FF_LAMBDA_SHIFT* = 7     ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/avutil.h:225:9
else:
  let FF_LAMBDA_SHIFT* = 7   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/avutil.h:225:9
when 118 is static:
  const
    FF_QP2LAMBDA* = 118      ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/avutil.h:227:9
else:
  let FF_QP2LAMBDA* = 118    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/avutil.h:227:9
when FF_LAMBDA_SCALE is typedesc:
  type
    FF_QUALITY_SCALE* = FF_LAMBDA_SCALE ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/avutil.h:230:9
else:
  when FF_LAMBDA_SCALE is static:
    const
      FF_QUALITY_SCALE* = FF_LAMBDA_SCALE ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/avutil.h:230:9
  else:
    let FF_QUALITY_SCALE* = FF_LAMBDA_SCALE ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/avutil.h:230:9
when 1000000 is static:
  const
    AV_TIME_BASE* = 1000000  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/avutil.h:254:9
else:
  let AV_TIME_BASE* = 1000000 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/avutil.h:254:9
when 0 is static:
  const
    AV_HAVE_BIGENDIAN* = 0   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/avconfig.h:4:9
else:
  let AV_HAVE_BIGENDIAN* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/avconfig.h:4:9
when 1 is static:
  const
    AV_HAVE_FAST_UNALIGNED* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/avconfig.h:5:9
else:
  let AV_HAVE_FAST_UNALIGNED* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/avconfig.h:5:9
when 64 is static:
  const
    AV_ERROR_MAX_STRING_SIZE* = 64 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/error.h:86:9
else:
  let AV_ERROR_MAX_STRING_SIZE* = 64 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/error.h:86:9
when 59 is static:
  const
    LIBAVUTIL_VERSION_MAJOR* = 59 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/version.h:81:9
else:
  let LIBAVUTIL_VERSION_MAJOR* = 59 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/version.h:81:9
when 39 is static:
  const
    LIBAVUTIL_VERSION_MINOR* = 39 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/version.h:82:9
else:
  let LIBAVUTIL_VERSION_MINOR* = 39 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/version.h:82:9
when 100 is static:
  const
    LIBAVUTIL_VERSION_MICRO* = 100 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/version.h:83:9
else:
  let LIBAVUTIL_VERSION_MICRO* = 100 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/version.h:83:9
when LIBAVUTIL_VERSION_INT is typedesc:
  type
    LIBAVUTIL_BUILD* = LIBAVUTIL_VERSION_INT ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/version.h:91:9
else:
  when LIBAVUTIL_VERSION_INT is static:
    const
      LIBAVUTIL_BUILD* = LIBAVUTIL_VERSION_INT ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/version.h:91:9
  else:
    let LIBAVUTIL_BUILD* = LIBAVUTIL_VERSION_INT ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/version.h:91:9
when AV_CEIL_RSHIFT is typedesc:
  type
    FF_CEIL_RSHIFT* = AV_CEIL_RSHIFT ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/common.h:63:9
else:
  when AV_CEIL_RSHIFT is static:
    const
      FF_CEIL_RSHIFT* = AV_CEIL_RSHIFT ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/common.h:63:9
  else:
    let FF_CEIL_RSHIFT* = AV_CEIL_RSHIFT ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/common.h:63:9
when 2.718281828459045 is static:
  const
    M_Ef* = 2.718281828459045 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:40:9
else:
  let M_Ef* = 2.718281828459045 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:40:9
when 0.6931471805599453 is static:
  const
    M_LN2f* = 0.6931471805599453 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:46:9
else:
  let M_LN2f* = 0.6931471805599453 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:46:9
when 2.302585092994046 is static:
  const
    M_LN10f* = 2.302585092994046 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:52:9
else:
  let M_LN10f* = 2.302585092994046 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:52:9
when 3.321928094887362 is static:
  const
    M_LOG2_10* = 3.321928094887362 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:55:9
else:
  let M_LOG2_10* = 3.321928094887362 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:55:9
when 3.321928094887362 is static:
  const
    M_LOG2_10f* = 3.321928094887362 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:58:9
else:
  let M_LOG2_10f* = 3.321928094887362 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:58:9
when 1.618033988749895 is static:
  const
    M_PHI* = 1.618033988749895 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:61:9
else:
  let M_PHI* = 1.618033988749895 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:61:9
when 1.618033988749895 is static:
  const
    M_PHIf* = 1.618033988749895 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:64:9
else:
  let M_PHIf* = 1.618033988749895 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:64:9
when 3.141592653589793 is static:
  const
    M_PIf* = 3.141592653589793 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:70:9
else:
  let M_PIf* = 3.141592653589793 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:70:9
when 1.5707963267948966 is static:
  const
    M_PI_2f* = 1.5707963267948966 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:76:9
else:
  let M_PI_2f* = 1.5707963267948966 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:76:9
when 0.7853981633974483 is static:
  const
    M_PI_4f* = 0.7853981633974483 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:82:9
else:
  let M_PI_4f* = 0.7853981633974483 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:82:9
when 0.3183098861837907 is static:
  const
    M_1_PIf* = 0.3183098861837907 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:88:9
else:
  let M_1_PIf* = 0.3183098861837907 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:88:9
when 0.6366197723675814 is static:
  const
    M_2_PIf* = 0.6366197723675814 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:94:9
else:
  let M_2_PIf* = 0.6366197723675814 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:94:9
when 1.1283791670955126 is static:
  const
    M_2_SQRTPIf* = 1.1283791670955126 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:100:9
else:
  let M_2_SQRTPIf* = 1.1283791670955126 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:100:9
when 0.7071067811865476 is static:
  const
    M_SQRT1_2f* = 0.7071067811865476 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:106:9
else:
  let M_SQRT1_2f* = 0.7071067811865476 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:106:9
when 1.4142135623730951 is static:
  const
    M_SQRT2f* = 1.4142135623730951 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:112:9
else:
  let M_SQRT2f* = 1.4142135623730951 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/mathematics.h:112:9
when -8 is static:
  const
    AV_LOG_QUIET* = -8       ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/log.h:162:9
else:
  let AV_LOG_QUIET* = -8     ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/log.h:162:9
when 0 is static:
  const
    AV_LOG_PANIC* = 0        ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/log.h:167:9
else:
  let AV_LOG_PANIC* = 0      ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/log.h:167:9
when 8 is static:
  const
    AV_LOG_FATAL* = 8        ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/log.h:174:9
else:
  let AV_LOG_FATAL* = 8      ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/log.h:174:9
when 16 is static:
  const
    AV_LOG_ERROR* = 16       ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/log.h:180:9
else:
  let AV_LOG_ERROR* = 16     ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/log.h:180:9
when 24 is static:
  const
    AV_LOG_WARNING* = 24     ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/log.h:186:9
else:
  let AV_LOG_WARNING* = 24   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/log.h:186:9
when 32 is static:
  const
    AV_LOG_INFO* = 32        ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/log.h:191:9
else:
  let AV_LOG_INFO* = 32      ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/log.h:191:9
when 40 is static:
  const
    AV_LOG_VERBOSE* = 40     ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/log.h:196:9
else:
  let AV_LOG_VERBOSE* = 40   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/log.h:196:9
when 48 is static:
  const
    AV_LOG_DEBUG* = 48       ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/log.h:201:9
else:
  let AV_LOG_DEBUG* = 48     ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/log.h:201:9
when 56 is static:
  const
    AV_LOG_TRACE* = 56       ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/log.h:206:9
else:
  let AV_LOG_TRACE* = 56     ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/log.h:206:9
when 1 is static:
  const
    AV_LOG_SKIP_REPEATED* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/log.h:370:9
else:
  let AV_LOG_SKIP_REPEATED* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/log.h:370:9
when 2 is static:
  const
    AV_LOG_PRINT_LEVEL* = 2  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/log.h:378:9
else:
  let AV_LOG_PRINT_LEVEL* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/log.h:378:9
when 1024 is static:
  const
    AVPALETTE_SIZE* = 1024   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/pixfmt.h:32:9
else:
  let AVPALETTE_SIZE* = 1024 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/pixfmt.h:32:9
when 256 is static:
  const
    AVPALETTE_COUNT* = 256   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/pixfmt.h:33:9
else:
  let AVPALETTE_COUNT* = 256 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/pixfmt.h:33:9
when 4 is static:
  const
    AV_VIDEO_MAX_PLANES* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/pixfmt.h:40:9
else:
  let AV_VIDEO_MAX_PLANES* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/pixfmt.h:40:9
when 32 is static:
  const
    AV_FOURCC_MAX_STRING_SIZE* = 32 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/avutil.h:343:9
else:
  let AV_FOURCC_MAX_STRING_SIZE* = 32 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/avutil.h:343:9
when AV_CH_FRONT_CENTER is typedesc:
  type
    AV_CH_LAYOUT_MONO* = AV_CH_FRONT_CENTER ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/channel_layout.h:212:9
else:
  when AV_CH_FRONT_CENTER is static:
    const
      AV_CH_LAYOUT_MONO* = AV_CH_FRONT_CENTER ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/channel_layout.h:212:9
  else:
    let AV_CH_LAYOUT_MONO* = AV_CH_FRONT_CENTER ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/channel_layout.h:212:9
when AV_CH_LAYOUT_5POINT1POINT2_BACK is typedesc:
  type
    AV_CH_LAYOUT_7POINT1_TOP_BACK* = AV_CH_LAYOUT_5POINT1POINT2_BACK ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/channel_layout.h:250:9
else:
  when AV_CH_LAYOUT_5POINT1POINT2_BACK is static:
    const
      AV_CH_LAYOUT_7POINT1_TOP_BACK* = AV_CH_LAYOUT_5POINT1POINT2_BACK ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/channel_layout.h:250:9
  else:
    let AV_CH_LAYOUT_7POINT1_TOP_BACK* = AV_CH_LAYOUT_5POINT1POINT2_BACK ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/channel_layout.h:250:9
when AV_CHANNEL_LAYOUT_5POINT1POINT2_BACK is typedesc:
  type
    AV_CHANNEL_LAYOUT_7POINT1_TOP_BACK* = AV_CHANNEL_LAYOUT_5POINT1POINT2_BACK ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/channel_layout.h:424:9
else:
  when AV_CHANNEL_LAYOUT_5POINT1POINT2_BACK is static:
    const
      AV_CHANNEL_LAYOUT_7POINT1_TOP_BACK* = AV_CHANNEL_LAYOUT_5POINT1POINT2_BACK ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/channel_layout.h:424:9
  else:
    let AV_CHANNEL_LAYOUT_7POINT1_TOP_BACK* = AV_CHANNEL_LAYOUT_5POINT1POINT2_BACK ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/channel_layout.h:424:9
when 1 is static:
  const
    AV_DICT_MATCH_CASE* = 1  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/dict.h:74:9
else:
  let AV_DICT_MATCH_CASE* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/dict.h:74:9
when 2 is static:
  const
    AV_DICT_IGNORE_SUFFIX* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/dict.h:75:9
else:
  let AV_DICT_IGNORE_SUFFIX* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/dict.h:75:9
when 4 is static:
  const
    AV_DICT_DONT_STRDUP_KEY* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/dict.h:77:9
else:
  let AV_DICT_DONT_STRDUP_KEY* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/dict.h:77:9
when 8 is static:
  const
    AV_DICT_DONT_STRDUP_VAL* = 8 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/dict.h:79:9
else:
  let AV_DICT_DONT_STRDUP_VAL* = 8 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/dict.h:79:9
when 16 is static:
  const
    AV_DICT_DONT_OVERWRITE* = 16 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/dict.h:81:9
else:
  let AV_DICT_DONT_OVERWRITE* = 16 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/dict.h:81:9
when 32 is static:
  const
    AV_DICT_APPEND* = 32     ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/dict.h:82:9
else:
  let AV_DICT_APPEND* = 32   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/dict.h:82:9
when 64 is static:
  const
    AV_DICT_MULTIKEY* = 64   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/dict.h:84:9
else:
  let AV_DICT_MULTIKEY* = 64 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/dict.h:84:9
when 8 is static:
  const
    AV_NUM_DATA_POINTERS* = 8 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/frame.h:390:9
else:
  let AV_NUM_DATA_POINTERS* = 8 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/frame.h:390:9
when 1 is static:
  const
    FF_DECODE_ERROR_INVALID_BITSTREAM* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/frame.h:717:9
else:
  let FF_DECODE_ERROR_INVALID_BITSTREAM* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/frame.h:717:9
when 2 is static:
  const
    FF_DECODE_ERROR_MISSING_REFERENCE* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/frame.h:718:9
else:
  let FF_DECODE_ERROR_MISSING_REFERENCE* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/frame.h:718:9
when 4 is static:
  const
    FF_DECODE_ERROR_CONCEALMENT_ACTIVE* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/frame.h:719:9
else:
  let FF_DECODE_ERROR_CONCEALMENT_ACTIVE* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/frame.h:719:9
when 8 is static:
  const
    FF_DECODE_ERROR_DECODE_SLICES* = 8 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/frame.h:720:9
else:
  let FF_DECODE_ERROR_DECODE_SLICES* = 8 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/frame.h:720:9
when 1 is static:
  const
    AV_OPT_SERIALIZE_SKIP_DEFAULTS* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/opt.h:1118:9
else:
  let AV_OPT_SERIALIZE_SKIP_DEFAULTS* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/opt.h:1118:9
when 2 is static:
  const
    AV_OPT_SERIALIZE_OPT_FLAGS_EXACT* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/opt.h:1119:9
else:
  let AV_OPT_SERIALIZE_OPT_FLAGS_EXACT* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/opt.h:1119:9
when 4 is static:
  const
    AV_OPT_SERIALIZE_SEARCH_CHILDREN* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/opt.h:1120:9
else:
  let AV_OPT_SERIALIZE_SEARCH_CHILDREN* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavutil/opt.h:1120:9
when 61 is static:
  const
    LIBAVCODEC_VERSION_MAJOR* = 61 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/version_major.h:28:9
else:
  let LIBAVCODEC_VERSION_MAJOR* = 61 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/version_major.h:28:9
when AV_CODEC_ID_IFF_ILBM is typedesc:
  type
    AV_CODEC_ID_IFF_BYTERUN1* = AV_CODEC_ID_IFF_ILBM ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/codec_id.h:189:9
else:
  when AV_CODEC_ID_IFF_ILBM is static:
    const
      AV_CODEC_ID_IFF_BYTERUN1* = AV_CODEC_ID_IFF_ILBM ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/codec_id.h:189:9
  else:
    let AV_CODEC_ID_IFF_BYTERUN1* = AV_CODEC_ID_IFF_ILBM ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/codec_id.h:189:9
when AV_CODEC_ID_HEVC is typedesc:
  type
    AV_CODEC_ID_H265* = AV_CODEC_ID_HEVC ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/codec_id.h:227:9
else:
  when AV_CODEC_ID_HEVC is static:
    const
      AV_CODEC_ID_H265* = AV_CODEC_ID_HEVC ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/codec_id.h:227:9
  else:
    let AV_CODEC_ID_H265* = AV_CODEC_ID_HEVC ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/codec_id.h:227:9
when AV_CODEC_ID_VVC is typedesc:
  type
    AV_CODEC_ID_H266* = AV_CODEC_ID_VVC ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/codec_id.h:251:9
else:
  when AV_CODEC_ID_VVC is static:
    const
      AV_CODEC_ID_H266* = AV_CODEC_ID_VVC ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/codec_id.h:251:9
  else:
    let AV_CODEC_ID_H266* = AV_CODEC_ID_VVC ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/codec_id.h:251:9
when 64 is static:
  const
    AV_INPUT_BUFFER_PADDING_SIZE* = 64 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:40:9
else:
  let AV_INPUT_BUFFER_PADDING_SIZE* = 64 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:40:9
when 2 is static:
  const
    FF_COMPLIANCE_VERY_STRICT* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:58:9
else:
  let FF_COMPLIANCE_VERY_STRICT* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:58:9
when 1 is static:
  const
    FF_COMPLIANCE_STRICT* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:59:9
else:
  let FF_COMPLIANCE_STRICT* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:59:9
when 0 is static:
  const
    FF_COMPLIANCE_NORMAL* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:60:9
else:
  let FF_COMPLIANCE_NORMAL* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:60:9
when -1 is static:
  const
    FF_COMPLIANCE_UNOFFICIAL* = -1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:61:9
else:
  let FF_COMPLIANCE_UNOFFICIAL* = -1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:61:9
when -2 is static:
  const
    FF_COMPLIANCE_EXPERIMENTAL* = -2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:62:9
else:
  let FF_COMPLIANCE_EXPERIMENTAL* = -2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:62:9
when -99 is static:
  const
    AV_PROFILE_UNKNOWN* = -99 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:65:9
else:
  let AV_PROFILE_UNKNOWN* = -99 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:65:9
when -100 is static:
  const
    AV_PROFILE_RESERVED* = -100 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:66:9
else:
  let AV_PROFILE_RESERVED* = -100 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:66:9
when 0 is static:
  const
    AV_PROFILE_AAC_MAIN* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:68:9
else:
  let AV_PROFILE_AAC_MAIN* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:68:9
when 1 is static:
  const
    AV_PROFILE_AAC_LOW* = 1  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:69:9
else:
  let AV_PROFILE_AAC_LOW* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:69:9
when 2 is static:
  const
    AV_PROFILE_AAC_SSR* = 2  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:70:9
else:
  let AV_PROFILE_AAC_SSR* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:70:9
when 3 is static:
  const
    AV_PROFILE_AAC_LTP* = 3  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:71:9
else:
  let AV_PROFILE_AAC_LTP* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:71:9
when 4 is static:
  const
    AV_PROFILE_AAC_HE* = 4   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:72:9
else:
  let AV_PROFILE_AAC_HE* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:72:9
when 28 is static:
  const
    AV_PROFILE_AAC_HE_V2* = 28 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:73:9
else:
  let AV_PROFILE_AAC_HE_V2* = 28 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:73:9
when 22 is static:
  const
    AV_PROFILE_AAC_LD* = 22  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:74:9
else:
  let AV_PROFILE_AAC_LD* = 22 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:74:9
when 38 is static:
  const
    AV_PROFILE_AAC_ELD* = 38 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:75:9
else:
  let AV_PROFILE_AAC_ELD* = 38 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:75:9
when 41 is static:
  const
    AV_PROFILE_AAC_USAC* = 41 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:76:9
else:
  let AV_PROFILE_AAC_USAC* = 41 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:76:9
when 128 is static:
  const
    AV_PROFILE_MPEG2_AAC_LOW* = 128 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:77:9
else:
  let AV_PROFILE_MPEG2_AAC_LOW* = 128 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:77:9
when 131 is static:
  const
    AV_PROFILE_MPEG2_AAC_HE* = 131 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:78:9
else:
  let AV_PROFILE_MPEG2_AAC_HE* = 131 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:78:9
when 0 is static:
  const
    AV_PROFILE_DNXHD* = 0    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:80:9
else:
  let AV_PROFILE_DNXHD* = 0  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:80:9
when 1 is static:
  const
    AV_PROFILE_DNXHR_LB* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:81:9
else:
  let AV_PROFILE_DNXHR_LB* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:81:9
when 2 is static:
  const
    AV_PROFILE_DNXHR_SQ* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:82:9
else:
  let AV_PROFILE_DNXHR_SQ* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:82:9
when 3 is static:
  const
    AV_PROFILE_DNXHR_HQ* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:83:9
else:
  let AV_PROFILE_DNXHR_HQ* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:83:9
when 4 is static:
  const
    AV_PROFILE_DNXHR_HQX* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:84:9
else:
  let AV_PROFILE_DNXHR_HQX* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:84:9
when 5 is static:
  const
    AV_PROFILE_DNXHR_444* = 5 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:85:9
else:
  let AV_PROFILE_DNXHR_444* = 5 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:85:9
when 20 is static:
  const
    AV_PROFILE_DTS* = 20     ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:87:9
else:
  let AV_PROFILE_DTS* = 20   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:87:9
when 30 is static:
  const
    AV_PROFILE_DTS_ES* = 30  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:88:9
else:
  let AV_PROFILE_DTS_ES* = 30 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:88:9
when 40 is static:
  const
    AV_PROFILE_DTS_96_24* = 40 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:89:9
else:
  let AV_PROFILE_DTS_96_24* = 40 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:89:9
when 50 is static:
  const
    AV_PROFILE_DTS_HD_HRA* = 50 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:90:9
else:
  let AV_PROFILE_DTS_HD_HRA* = 50 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:90:9
when 60 is static:
  const
    AV_PROFILE_DTS_HD_MA* = 60 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:91:9
else:
  let AV_PROFILE_DTS_HD_MA* = 60 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:91:9
when 70 is static:
  const
    AV_PROFILE_DTS_EXPRESS* = 70 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:92:9
else:
  let AV_PROFILE_DTS_EXPRESS* = 70 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:92:9
when 61 is static:
  const
    AV_PROFILE_DTS_HD_MA_X* = 61 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:93:9
else:
  let AV_PROFILE_DTS_HD_MA_X* = 61 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:93:9
when 62 is static:
  const
    AV_PROFILE_DTS_HD_MA_X_IMAX* = 62 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:94:9
else:
  let AV_PROFILE_DTS_HD_MA_X_IMAX* = 62 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:94:9
when 30 is static:
  const
    AV_PROFILE_EAC3_DDP_ATMOS* = 30 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:96:9
else:
  let AV_PROFILE_EAC3_DDP_ATMOS* = 30 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:96:9
when 30 is static:
  const
    AV_PROFILE_TRUEHD_ATMOS* = 30 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:98:9
else:
  let AV_PROFILE_TRUEHD_ATMOS* = 30 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:98:9
when 0 is static:
  const
    AV_PROFILE_MPEG2_422* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:100:9
else:
  let AV_PROFILE_MPEG2_422* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:100:9
when 1 is static:
  const
    AV_PROFILE_MPEG2_HIGH* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:101:9
else:
  let AV_PROFILE_MPEG2_HIGH* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:101:9
when 2 is static:
  const
    AV_PROFILE_MPEG2_SS* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:102:9
else:
  let AV_PROFILE_MPEG2_SS* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:102:9
when 3 is static:
  const
    AV_PROFILE_MPEG2_SNR_SCALABLE* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:103:9
else:
  let AV_PROFILE_MPEG2_SNR_SCALABLE* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:103:9
when 4 is static:
  const
    AV_PROFILE_MPEG2_MAIN* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:104:9
else:
  let AV_PROFILE_MPEG2_MAIN* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:104:9
when 5 is static:
  const
    AV_PROFILE_MPEG2_SIMPLE* = 5 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:105:9
else:
  let AV_PROFILE_MPEG2_SIMPLE* = 5 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:105:9
when 66 is static:
  const
    AV_PROFILE_H264_BASELINE* = 66 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:110:9
else:
  let AV_PROFILE_H264_BASELINE* = 66 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:110:9
when 77 is static:
  const
    AV_PROFILE_H264_MAIN* = 77 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:112:9
else:
  let AV_PROFILE_H264_MAIN* = 77 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:112:9
when 88 is static:
  const
    AV_PROFILE_H264_EXTENDED* = 88 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:113:9
else:
  let AV_PROFILE_H264_EXTENDED* = 88 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:113:9
when 100 is static:
  const
    AV_PROFILE_H264_HIGH* = 100 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:114:9
else:
  let AV_PROFILE_H264_HIGH* = 100 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:114:9
when 110 is static:
  const
    AV_PROFILE_H264_HIGH_10* = 110 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:115:9
else:
  let AV_PROFILE_H264_HIGH_10* = 110 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:115:9
when 118 is static:
  const
    AV_PROFILE_H264_MULTIVIEW_HIGH* = 118 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:117:9
else:
  let AV_PROFILE_H264_MULTIVIEW_HIGH* = 118 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:117:9
when 122 is static:
  const
    AV_PROFILE_H264_HIGH_422* = 122 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:118:9
else:
  let AV_PROFILE_H264_HIGH_422* = 122 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:118:9
when 128 is static:
  const
    AV_PROFILE_H264_STEREO_HIGH* = 128 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:120:9
else:
  let AV_PROFILE_H264_STEREO_HIGH* = 128 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:120:9
when 144 is static:
  const
    AV_PROFILE_H264_HIGH_444* = 144 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:121:9
else:
  let AV_PROFILE_H264_HIGH_444* = 144 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:121:9
when 244 is static:
  const
    AV_PROFILE_H264_HIGH_444_PREDICTIVE* = 244 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:122:9
else:
  let AV_PROFILE_H264_HIGH_444_PREDICTIVE* = 244 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:122:9
when 44 is static:
  const
    AV_PROFILE_H264_CAVLC_444* = 44 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:124:9
else:
  let AV_PROFILE_H264_CAVLC_444* = 44 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:124:9
when 0 is static:
  const
    AV_PROFILE_VC1_SIMPLE* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:126:9
else:
  let AV_PROFILE_VC1_SIMPLE* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:126:9
when 1 is static:
  const
    AV_PROFILE_VC1_MAIN* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:127:9
else:
  let AV_PROFILE_VC1_MAIN* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:127:9
when 2 is static:
  const
    AV_PROFILE_VC1_COMPLEX* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:128:9
else:
  let AV_PROFILE_VC1_COMPLEX* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:128:9
when 3 is static:
  const
    AV_PROFILE_VC1_ADVANCED* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:129:9
else:
  let AV_PROFILE_VC1_ADVANCED* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:129:9
when 0 is static:
  const
    AV_PROFILE_MPEG4_SIMPLE* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:131:9
else:
  let AV_PROFILE_MPEG4_SIMPLE* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:131:9
when 1 is static:
  const
    AV_PROFILE_MPEG4_SIMPLE_SCALABLE* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:132:9
else:
  let AV_PROFILE_MPEG4_SIMPLE_SCALABLE* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:132:9
when 2 is static:
  const
    AV_PROFILE_MPEG4_CORE* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:133:9
else:
  let AV_PROFILE_MPEG4_CORE* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:133:9
when 3 is static:
  const
    AV_PROFILE_MPEG4_MAIN* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:134:9
else:
  let AV_PROFILE_MPEG4_MAIN* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:134:9
when 4 is static:
  const
    AV_PROFILE_MPEG4_N_BIT* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:135:9
else:
  let AV_PROFILE_MPEG4_N_BIT* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:135:9
when 5 is static:
  const
    AV_PROFILE_MPEG4_SCALABLE_TEXTURE* = 5 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:136:9
else:
  let AV_PROFILE_MPEG4_SCALABLE_TEXTURE* = 5 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:136:9
when 6 is static:
  const
    AV_PROFILE_MPEG4_SIMPLE_FACE_ANIMATION* = 6 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:137:9
else:
  let AV_PROFILE_MPEG4_SIMPLE_FACE_ANIMATION* = 6 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:137:9
when 7 is static:
  const
    AV_PROFILE_MPEG4_BASIC_ANIMATED_TEXTURE* = 7 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:138:9
else:
  let AV_PROFILE_MPEG4_BASIC_ANIMATED_TEXTURE* = 7 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:138:9
when 8 is static:
  const
    AV_PROFILE_MPEG4_HYBRID* = 8 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:139:9
else:
  let AV_PROFILE_MPEG4_HYBRID* = 8 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:139:9
when 9 is static:
  const
    AV_PROFILE_MPEG4_ADVANCED_REAL_TIME* = 9 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:140:9
else:
  let AV_PROFILE_MPEG4_ADVANCED_REAL_TIME* = 9 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:140:9
when 10 is static:
  const
    AV_PROFILE_MPEG4_CORE_SCALABLE* = 10 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:141:9
else:
  let AV_PROFILE_MPEG4_CORE_SCALABLE* = 10 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:141:9
when 11 is static:
  const
    AV_PROFILE_MPEG4_ADVANCED_CODING* = 11 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:142:9
else:
  let AV_PROFILE_MPEG4_ADVANCED_CODING* = 11 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:142:9
when 12 is static:
  const
    AV_PROFILE_MPEG4_ADVANCED_CORE* = 12 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:143:9
else:
  let AV_PROFILE_MPEG4_ADVANCED_CORE* = 12 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:143:9
when 13 is static:
  const
    AV_PROFILE_MPEG4_ADVANCED_SCALABLE_TEXTURE* = 13 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:144:9
else:
  let AV_PROFILE_MPEG4_ADVANCED_SCALABLE_TEXTURE* = 13 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:144:9
when 14 is static:
  const
    AV_PROFILE_MPEG4_SIMPLE_STUDIO* = 14 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:145:9
else:
  let AV_PROFILE_MPEG4_SIMPLE_STUDIO* = 14 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:145:9
when 15 is static:
  const
    AV_PROFILE_MPEG4_ADVANCED_SIMPLE* = 15 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:146:9
else:
  let AV_PROFILE_MPEG4_ADVANCED_SIMPLE* = 15 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:146:9
when 1 is static:
  const
    AV_PROFILE_JPEG2000_CSTREAM_RESTRICTION_0* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:148:9
else:
  let AV_PROFILE_JPEG2000_CSTREAM_RESTRICTION_0* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:148:9
when 2 is static:
  const
    AV_PROFILE_JPEG2000_CSTREAM_RESTRICTION_1* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:149:9
else:
  let AV_PROFILE_JPEG2000_CSTREAM_RESTRICTION_1* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:149:9
when 32768 is static:
  const
    AV_PROFILE_JPEG2000_CSTREAM_NO_RESTRICTION* = 32768 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:150:9
else:
  let AV_PROFILE_JPEG2000_CSTREAM_NO_RESTRICTION* = 32768 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:150:9
when 3 is static:
  const
    AV_PROFILE_JPEG2000_DCINEMA_2K* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:151:9
else:
  let AV_PROFILE_JPEG2000_DCINEMA_2K* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:151:9
when 4 is static:
  const
    AV_PROFILE_JPEG2000_DCINEMA_4K* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:152:9
else:
  let AV_PROFILE_JPEG2000_DCINEMA_4K* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:152:9
when 0 is static:
  const
    AV_PROFILE_VP9_0* = 0    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:154:9
else:
  let AV_PROFILE_VP9_0* = 0  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:154:9
when 1 is static:
  const
    AV_PROFILE_VP9_1* = 1    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:155:9
else:
  let AV_PROFILE_VP9_1* = 1  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:155:9
when 2 is static:
  const
    AV_PROFILE_VP9_2* = 2    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:156:9
else:
  let AV_PROFILE_VP9_2* = 2  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:156:9
when 3 is static:
  const
    AV_PROFILE_VP9_3* = 3    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:157:9
else:
  let AV_PROFILE_VP9_3* = 3  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:157:9
when 1 is static:
  const
    AV_PROFILE_HEVC_MAIN* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:159:9
else:
  let AV_PROFILE_HEVC_MAIN* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:159:9
when 2 is static:
  const
    AV_PROFILE_HEVC_MAIN_10* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:160:9
else:
  let AV_PROFILE_HEVC_MAIN_10* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:160:9
when 3 is static:
  const
    AV_PROFILE_HEVC_MAIN_STILL_PICTURE* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:161:9
else:
  let AV_PROFILE_HEVC_MAIN_STILL_PICTURE* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:161:9
when 4 is static:
  const
    AV_PROFILE_HEVC_REXT* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:162:9
else:
  let AV_PROFILE_HEVC_REXT* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:162:9
when 6 is static:
  const
    AV_PROFILE_HEVC_MULTIVIEW_MAIN* = 6 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:163:9
else:
  let AV_PROFILE_HEVC_MULTIVIEW_MAIN* = 6 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:163:9
when 9 is static:
  const
    AV_PROFILE_HEVC_SCC* = 9 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:164:9
else:
  let AV_PROFILE_HEVC_SCC* = 9 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:164:9
when 1 is static:
  const
    AV_PROFILE_VVC_MAIN_10* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:166:9
else:
  let AV_PROFILE_VVC_MAIN_10* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:166:9
when 33 is static:
  const
    AV_PROFILE_VVC_MAIN_10_444* = 33 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:167:9
else:
  let AV_PROFILE_VVC_MAIN_10_444* = 33 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:167:9
when 0 is static:
  const
    AV_PROFILE_AV1_MAIN* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:169:9
else:
  let AV_PROFILE_AV1_MAIN* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:169:9
when 1 is static:
  const
    AV_PROFILE_AV1_HIGH* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:170:9
else:
  let AV_PROFILE_AV1_HIGH* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:170:9
when 2 is static:
  const
    AV_PROFILE_AV1_PROFESSIONAL* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:171:9
else:
  let AV_PROFILE_AV1_PROFESSIONAL* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:171:9
when 192 is static:
  const
    AV_PROFILE_MJPEG_HUFFMAN_BASELINE_DCT* = 192 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:173:9
else:
  let AV_PROFILE_MJPEG_HUFFMAN_BASELINE_DCT* = 192 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:173:9
when 193 is static:
  const
    AV_PROFILE_MJPEG_HUFFMAN_EXTENDED_SEQUENTIAL_DCT* = 193 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:174:9
else:
  let AV_PROFILE_MJPEG_HUFFMAN_EXTENDED_SEQUENTIAL_DCT* = 193 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:174:9
when 194 is static:
  const
    AV_PROFILE_MJPEG_HUFFMAN_PROGRESSIVE_DCT* = 194 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:175:9
else:
  let AV_PROFILE_MJPEG_HUFFMAN_PROGRESSIVE_DCT* = 194 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:175:9
when 195 is static:
  const
    AV_PROFILE_MJPEG_HUFFMAN_LOSSLESS* = 195 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:176:9
else:
  let AV_PROFILE_MJPEG_HUFFMAN_LOSSLESS* = 195 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:176:9
when 247 is static:
  const
    AV_PROFILE_MJPEG_JPEG_LS* = 247 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:177:9
else:
  let AV_PROFILE_MJPEG_JPEG_LS* = 247 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:177:9
when 1 is static:
  const
    AV_PROFILE_SBC_MSBC* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:179:9
else:
  let AV_PROFILE_SBC_MSBC* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:179:9
when 0 is static:
  const
    AV_PROFILE_PRORES_PROXY* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:181:9
else:
  let AV_PROFILE_PRORES_PROXY* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:181:9
when 1 is static:
  const
    AV_PROFILE_PRORES_LT* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:182:9
else:
  let AV_PROFILE_PRORES_LT* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:182:9
when 2 is static:
  const
    AV_PROFILE_PRORES_STANDARD* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:183:9
else:
  let AV_PROFILE_PRORES_STANDARD* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:183:9
when 3 is static:
  const
    AV_PROFILE_PRORES_HQ* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:184:9
else:
  let AV_PROFILE_PRORES_HQ* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:184:9
when 4 is static:
  const
    AV_PROFILE_PRORES_4444* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:185:9
else:
  let AV_PROFILE_PRORES_4444* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:185:9
when 5 is static:
  const
    AV_PROFILE_PRORES_XQ* = 5 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:186:9
else:
  let AV_PROFILE_PRORES_XQ* = 5 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:186:9
when 0 is static:
  const
    AV_PROFILE_ARIB_PROFILE_A* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:188:9
else:
  let AV_PROFILE_ARIB_PROFILE_A* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:188:9
when 1 is static:
  const
    AV_PROFILE_ARIB_PROFILE_C* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:189:9
else:
  let AV_PROFILE_ARIB_PROFILE_C* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:189:9
when 0 is static:
  const
    AV_PROFILE_KLVA_SYNC* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:191:9
else:
  let AV_PROFILE_KLVA_SYNC* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:191:9
when 1 is static:
  const
    AV_PROFILE_KLVA_ASYNC* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:192:9
else:
  let AV_PROFILE_KLVA_ASYNC* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:192:9
when 0 is static:
  const
    AV_PROFILE_EVC_BASELINE* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:194:9
else:
  let AV_PROFILE_EVC_BASELINE* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:194:9
when 1 is static:
  const
    AV_PROFILE_EVC_MAIN* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:195:9
else:
  let AV_PROFILE_EVC_MAIN* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:195:9
when -99 is static:
  const
    AV_LEVEL_UNKNOWN* = -99  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:198:9
else:
  let AV_LEVEL_UNKNOWN* = -99 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/defs.h:198:9
when AV_PKT_DATA_QUALITY_STATS is typedesc:
  type
    AV_PKT_DATA_QUALITY_FACTOR* = AV_PKT_DATA_QUALITY_STATS ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/packet.h:360:9
else:
  when AV_PKT_DATA_QUALITY_STATS is static:
    const
      AV_PKT_DATA_QUALITY_FACTOR* = AV_PKT_DATA_QUALITY_STATS ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/packet.h:360:9
  else:
    let AV_PKT_DATA_QUALITY_FACTOR* = AV_PKT_DATA_QUALITY_STATS ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/packet.h:360:9
when 1 is static:
  const
    AV_PKT_FLAG_KEY* = 1     ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/packet.h:594:9
else:
  let AV_PKT_FLAG_KEY* = 1   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/packet.h:594:9
when 2 is static:
  const
    AV_PKT_FLAG_CORRUPT* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/packet.h:595:9
else:
  let AV_PKT_FLAG_CORRUPT* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/packet.h:595:9
when 4 is static:
  const
    AV_PKT_FLAG_DISCARD* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/packet.h:601:9
else:
  let AV_PKT_FLAG_DISCARD* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/packet.h:601:9
when 8 is static:
  const
    AV_PKT_FLAG_TRUSTED* = 8 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/packet.h:608:9
else:
  let AV_PKT_FLAG_TRUSTED* = 8 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/packet.h:608:9
when 16 is static:
  const
    AV_PKT_FLAG_DISPOSABLE* = 16 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/packet.h:613:9
else:
  let AV_PKT_FLAG_DISPOSABLE* = 16 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/packet.h:613:9
when 19 is static:
  const
    LIBAVCODEC_VERSION_MINOR* = 19 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/version.h:32:9
else:
  let LIBAVCODEC_VERSION_MINOR* = 19 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/version.h:32:9
when 101 is static:
  const
    LIBAVCODEC_VERSION_MICRO* = 101 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/version.h:33:9
else:
  let LIBAVCODEC_VERSION_MICRO* = 101 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/version.h:33:9
when LIBAVCODEC_VERSION_INT is typedesc:
  type
    LIBAVCODEC_BUILD* = LIBAVCODEC_VERSION_INT ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/version.h:41:9
else:
  when LIBAVCODEC_VERSION_INT is static:
    const
      LIBAVCODEC_BUILD* = LIBAVCODEC_VERSION_INT ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/version.h:41:9
  else:
    let LIBAVCODEC_BUILD* = LIBAVCODEC_VERSION_INT ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/version.h:41:9
when 16384 is static:
  const
    AV_INPUT_BUFFER_MIN_SIZE* = 16384 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:198:9
else:
  let AV_INPUT_BUFFER_MIN_SIZE* = 16384 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:198:9
when 1 is static:
  const
    SLICE_FLAG_CODED_ORDER* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:737:9
else:
  let SLICE_FLAG_CODED_ORDER* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:737:9
when 2 is static:
  const
    SLICE_FLAG_ALLOW_FIELD* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:738:9
else:
  let SLICE_FLAG_ALLOW_FIELD* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:738:9
when 4 is static:
  const
    SLICE_FLAG_ALLOW_PLANE* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:739:9
else:
  let SLICE_FLAG_ALLOW_PLANE* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:739:9
when 0 is static:
  const
    FF_CMP_SAD* = 0          ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:901:9
else:
  let FF_CMP_SAD* = 0        ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:901:9
when 1 is static:
  const
    FF_CMP_SSE* = 1          ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:902:9
else:
  let FF_CMP_SSE* = 1        ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:902:9
when 2 is static:
  const
    FF_CMP_SATD* = 2         ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:903:9
else:
  let FF_CMP_SATD* = 2       ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:903:9
when 3 is static:
  const
    FF_CMP_DCT* = 3          ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:904:9
else:
  let FF_CMP_DCT* = 3        ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:904:9
when 4 is static:
  const
    FF_CMP_PSNR* = 4         ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:905:9
else:
  let FF_CMP_PSNR* = 4       ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:905:9
when 5 is static:
  const
    FF_CMP_BIT* = 5          ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:906:9
else:
  let FF_CMP_BIT* = 5        ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:906:9
when 6 is static:
  const
    FF_CMP_RD* = 6           ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:907:9
else:
  let FF_CMP_RD* = 6         ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:907:9
when 7 is static:
  const
    FF_CMP_ZERO* = 7         ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:908:9
else:
  let FF_CMP_ZERO* = 7       ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:908:9
when 8 is static:
  const
    FF_CMP_VSAD* = 8         ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:909:9
else:
  let FF_CMP_VSAD* = 8       ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:909:9
when 9 is static:
  const
    FF_CMP_VSSE* = 9         ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:910:9
else:
  let FF_CMP_VSSE* = 9       ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:910:9
when 10 is static:
  const
    FF_CMP_NSSE* = 10        ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:911:9
else:
  let FF_CMP_NSSE* = 10      ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:911:9
when 11 is static:
  const
    FF_CMP_W53* = 11         ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:912:9
else:
  let FF_CMP_W53* = 11       ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:912:9
when 12 is static:
  const
    FF_CMP_W97* = 12         ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:913:9
else:
  let FF_CMP_W97* = 12       ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:913:9
when 13 is static:
  const
    FF_CMP_DCTMAX* = 13      ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:914:9
else:
  let FF_CMP_DCTMAX* = 13    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:914:9
when 14 is static:
  const
    FF_CMP_DCT264* = 14      ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:915:9
else:
  let FF_CMP_DCT264* = 14    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:915:9
when 15 is static:
  const
    FF_CMP_MEDIAN_SAD* = 15  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:916:9
else:
  let FF_CMP_MEDIAN_SAD* = 15 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:916:9
when 256 is static:
  const
    FF_CMP_CHROMA* = 256     ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:917:9
else:
  let FF_CMP_CHROMA* = 256   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:917:9
when 0 is static:
  const
    FF_MB_DECISION_SIMPLE* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:969:9
else:
  let FF_MB_DECISION_SIMPLE* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:969:9
when 1 is static:
  const
    FF_MB_DECISION_BITS* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:970:9
else:
  let FF_MB_DECISION_BITS* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:970:9
when 2 is static:
  const
    FF_MB_DECISION_RD* = 2   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:971:9
else:
  let FF_MB_DECISION_RD* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:971:9
when -1 is static:
  const
    FF_COMPRESSION_DEFAULT* = -1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1256:9
else:
  let FF_COMPRESSION_DEFAULT* = -1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1256:9
when 1 is static:
  const
    FF_BUG_AUTODETECT* = 1   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1360:9
else:
  let FF_BUG_AUTODETECT* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1360:9
when 4 is static:
  const
    FF_BUG_XVID_ILACE* = 4   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1361:9
else:
  let FF_BUG_XVID_ILACE* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1361:9
when 8 is static:
  const
    FF_BUG_UMP4* = 8         ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1362:9
else:
  let FF_BUG_UMP4* = 8       ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1362:9
when 16 is static:
  const
    FF_BUG_NO_PADDING* = 16  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1363:9
else:
  let FF_BUG_NO_PADDING* = 16 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1363:9
when 32 is static:
  const
    FF_BUG_AMV* = 32         ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1364:9
else:
  let FF_BUG_AMV* = 32       ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1364:9
when 64 is static:
  const
    FF_BUG_QPEL_CHROMA* = 64 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1365:9
else:
  let FF_BUG_QPEL_CHROMA* = 64 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1365:9
when 128 is static:
  const
    FF_BUG_STD_QPEL* = 128   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1366:9
else:
  let FF_BUG_STD_QPEL* = 128 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1366:9
when 256 is static:
  const
    FF_BUG_QPEL_CHROMA2* = 256 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1367:9
else:
  let FF_BUG_QPEL_CHROMA2* = 256 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1367:9
when 512 is static:
  const
    FF_BUG_DIRECT_BLOCKSIZE* = 512 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1368:9
else:
  let FF_BUG_DIRECT_BLOCKSIZE* = 512 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1368:9
when 1024 is static:
  const
    FF_BUG_EDGE* = 1024      ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1369:9
else:
  let FF_BUG_EDGE* = 1024    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1369:9
when 2048 is static:
  const
    FF_BUG_HPEL_CHROMA* = 2048 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1370:9
else:
  let FF_BUG_HPEL_CHROMA* = 2048 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1370:9
when 4096 is static:
  const
    FF_BUG_DC_CLIP* = 4096   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1371:9
else:
  let FF_BUG_DC_CLIP* = 4096 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1371:9
when 8192 is static:
  const
    FF_BUG_MS* = 8192        ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1372:9
else:
  let FF_BUG_MS* = 8192      ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1372:9
when 16384 is static:
  const
    FF_BUG_TRUNCATED* = 16384 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1373:9
else:
  let FF_BUG_TRUNCATED* = 16384 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1373:9
when 32768 is static:
  const
    FF_BUG_IEDGE* = 32768    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1374:9
else:
  let FF_BUG_IEDGE* = 32768  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1374:9
when 1 is static:
  const
    FF_EC_GUESS_MVS* = 1     ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1397:9
else:
  let FF_EC_GUESS_MVS* = 1   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1397:9
when 2 is static:
  const
    FF_EC_DEBLOCK* = 2       ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1398:9
else:
  let FF_EC_DEBLOCK* = 2     ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1398:9
when 256 is static:
  const
    FF_EC_FAVOR_INTER* = 256 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1399:9
else:
  let FF_EC_FAVOR_INTER* = 256 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1399:9
when 1 is static:
  const
    FF_DEBUG_PICT_INFO* = 1  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1407:9
else:
  let FF_DEBUG_PICT_INFO* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1407:9
when 2 is static:
  const
    FF_DEBUG_RC* = 2         ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1408:9
else:
  let FF_DEBUG_RC* = 2       ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1408:9
when 4 is static:
  const
    FF_DEBUG_BITSTREAM* = 4  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1409:9
else:
  let FF_DEBUG_BITSTREAM* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1409:9
when 8 is static:
  const
    FF_DEBUG_MB_TYPE* = 8    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1410:9
else:
  let FF_DEBUG_MB_TYPE* = 8  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1410:9
when 16 is static:
  const
    FF_DEBUG_QP* = 16        ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1411:9
else:
  let FF_DEBUG_QP* = 16      ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1411:9
when 64 is static:
  const
    FF_DEBUG_DCT_COEFF* = 64 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1412:9
else:
  let FF_DEBUG_DCT_COEFF* = 64 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1412:9
when 128 is static:
  const
    FF_DEBUG_SKIP* = 128     ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1413:9
else:
  let FF_DEBUG_SKIP* = 128   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1413:9
when 256 is static:
  const
    FF_DEBUG_STARTCODE* = 256 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1414:9
else:
  let FF_DEBUG_STARTCODE* = 256 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1414:9
when 1024 is static:
  const
    FF_DEBUG_ER* = 1024      ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1415:9
else:
  let FF_DEBUG_ER* = 1024    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1415:9
when 2048 is static:
  const
    FF_DEBUG_MMCO* = 2048    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1416:9
else:
  let FF_DEBUG_MMCO* = 2048  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1416:9
when 4096 is static:
  const
    FF_DEBUG_BUGS* = 4096    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1417:9
else:
  let FF_DEBUG_BUGS* = 4096  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1417:9
when 32768 is static:
  const
    FF_DEBUG_BUFFERS* = 32768 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1418:9
else:
  let FF_DEBUG_BUFFERS* = 32768 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1418:9
when 65536 is static:
  const
    FF_DEBUG_THREADS* = 65536 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1419:9
else:
  let FF_DEBUG_THREADS* = 65536 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1419:9
when 8388608 is static:
  const
    FF_DEBUG_GREEN_MD* = 8388608 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1420:9
else:
  let FF_DEBUG_GREEN_MD* = 8388608 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1420:9
when 16777216 is static:
  const
    FF_DEBUG_NOMC* = 16777216 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1421:9
else:
  let FF_DEBUG_NOMC* = 16777216 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1421:9
when 0 is static:
  const
    FF_DCT_AUTO* = 0         ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1545:9
else:
  let FF_DCT_AUTO* = 0       ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1545:9
when 1 is static:
  const
    FF_DCT_FASTINT* = 1      ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1546:9
else:
  let FF_DCT_FASTINT* = 1    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1546:9
when 2 is static:
  const
    FF_DCT_INT* = 2          ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1547:9
else:
  let FF_DCT_INT* = 2        ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1547:9
when 3 is static:
  const
    FF_DCT_MMX* = 3          ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1548:9
else:
  let FF_DCT_MMX* = 3        ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1548:9
when 5 is static:
  const
    FF_DCT_ALTIVEC* = 5      ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1549:9
else:
  let FF_DCT_ALTIVEC* = 5    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1549:9
when 6 is static:
  const
    FF_DCT_FAAN* = 6         ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1550:9
else:
  let FF_DCT_FAAN* = 6       ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1550:9
when 7 is static:
  const
    FF_DCT_NEON* = 7         ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1551:9
else:
  let FF_DCT_NEON* = 7       ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1551:9
when 0 is static:
  const
    FF_IDCT_AUTO* = 0        ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1559:9
else:
  let FF_IDCT_AUTO* = 0      ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1559:9
when 1 is static:
  const
    FF_IDCT_INT* = 1         ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1560:9
else:
  let FF_IDCT_INT* = 1       ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1560:9
when 2 is static:
  const
    FF_IDCT_SIMPLE* = 2      ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1561:9
else:
  let FF_IDCT_SIMPLE* = 2    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1561:9
when 3 is static:
  const
    FF_IDCT_SIMPLEMMX* = 3   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1562:9
else:
  let FF_IDCT_SIMPLEMMX* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1562:9
when 7 is static:
  const
    FF_IDCT_ARM* = 7         ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1563:9
else:
  let FF_IDCT_ARM* = 7       ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1563:9
when 8 is static:
  const
    FF_IDCT_ALTIVEC* = 8     ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1564:9
else:
  let FF_IDCT_ALTIVEC* = 8   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1564:9
when 10 is static:
  const
    FF_IDCT_SIMPLEARM* = 10  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1565:9
else:
  let FF_IDCT_SIMPLEARM* = 10 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1565:9
when 14 is static:
  const
    FF_IDCT_XVID* = 14       ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1566:9
else:
  let FF_IDCT_XVID* = 14     ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1566:9
when 16 is static:
  const
    FF_IDCT_SIMPLEARMV5TE* = 16 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1567:9
else:
  let FF_IDCT_SIMPLEARMV5TE* = 16 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1567:9
when 17 is static:
  const
    FF_IDCT_SIMPLEARMV6* = 17 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1568:9
else:
  let FF_IDCT_SIMPLEARMV6* = 17 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1568:9
when 20 is static:
  const
    FF_IDCT_FAAN* = 20       ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1569:9
else:
  let FF_IDCT_FAAN* = 20     ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1569:9
when 22 is static:
  const
    FF_IDCT_SIMPLENEON* = 22 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1570:9
else:
  let FF_IDCT_SIMPLENEON* = 22 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1570:9
when 128 is static:
  const
    FF_IDCT_SIMPLEAUTO* = 128 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1571:9
else:
  let FF_IDCT_SIMPLEAUTO* = 128 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1571:9
when 1 is static:
  const
    FF_THREAD_FRAME* = 1     ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1604:9
else:
  let FF_THREAD_FRAME* = 1   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1604:9
when 2 is static:
  const
    FF_THREAD_SLICE* = 2     ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1605:9
else:
  let FF_THREAD_SLICE* = 2   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1605:9
when -99 is static:
  const
    FF_PROFILE_UNKNOWN* = -99 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1654:9
else:
  let FF_PROFILE_UNKNOWN* = -99 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1654:9
when -100 is static:
  const
    FF_PROFILE_RESERVED* = -100 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1655:9
else:
  let FF_PROFILE_RESERVED* = -100 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1655:9
when 0 is static:
  const
    FF_PROFILE_AAC_MAIN* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1657:9
else:
  let FF_PROFILE_AAC_MAIN* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1657:9
when 1 is static:
  const
    FF_PROFILE_AAC_LOW* = 1  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1658:9
else:
  let FF_PROFILE_AAC_LOW* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1658:9
when 2 is static:
  const
    FF_PROFILE_AAC_SSR* = 2  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1659:9
else:
  let FF_PROFILE_AAC_SSR* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1659:9
when 3 is static:
  const
    FF_PROFILE_AAC_LTP* = 3  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1660:9
else:
  let FF_PROFILE_AAC_LTP* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1660:9
when 4 is static:
  const
    FF_PROFILE_AAC_HE* = 4   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1661:9
else:
  let FF_PROFILE_AAC_HE* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1661:9
when 28 is static:
  const
    FF_PROFILE_AAC_HE_V2* = 28 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1662:9
else:
  let FF_PROFILE_AAC_HE_V2* = 28 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1662:9
when 22 is static:
  const
    FF_PROFILE_AAC_LD* = 22  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1663:9
else:
  let FF_PROFILE_AAC_LD* = 22 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1663:9
when 38 is static:
  const
    FF_PROFILE_AAC_ELD* = 38 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1664:9
else:
  let FF_PROFILE_AAC_ELD* = 38 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1664:9
when 128 is static:
  const
    FF_PROFILE_MPEG2_AAC_LOW* = 128 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1665:9
else:
  let FF_PROFILE_MPEG2_AAC_LOW* = 128 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1665:9
when 131 is static:
  const
    FF_PROFILE_MPEG2_AAC_HE* = 131 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1666:9
else:
  let FF_PROFILE_MPEG2_AAC_HE* = 131 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1666:9
when 0 is static:
  const
    FF_PROFILE_DNXHD* = 0    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1668:9
else:
  let FF_PROFILE_DNXHD* = 0  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1668:9
when 1 is static:
  const
    FF_PROFILE_DNXHR_LB* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1669:9
else:
  let FF_PROFILE_DNXHR_LB* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1669:9
when 2 is static:
  const
    FF_PROFILE_DNXHR_SQ* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1670:9
else:
  let FF_PROFILE_DNXHR_SQ* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1670:9
when 3 is static:
  const
    FF_PROFILE_DNXHR_HQ* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1671:9
else:
  let FF_PROFILE_DNXHR_HQ* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1671:9
when 4 is static:
  const
    FF_PROFILE_DNXHR_HQX* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1672:9
else:
  let FF_PROFILE_DNXHR_HQX* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1672:9
when 5 is static:
  const
    FF_PROFILE_DNXHR_444* = 5 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1673:9
else:
  let FF_PROFILE_DNXHR_444* = 5 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1673:9
when 20 is static:
  const
    FF_PROFILE_DTS* = 20     ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1675:9
else:
  let FF_PROFILE_DTS* = 20   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1675:9
when 30 is static:
  const
    FF_PROFILE_DTS_ES* = 30  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1676:9
else:
  let FF_PROFILE_DTS_ES* = 30 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1676:9
when 40 is static:
  const
    FF_PROFILE_DTS_96_24* = 40 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1677:9
else:
  let FF_PROFILE_DTS_96_24* = 40 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1677:9
when 50 is static:
  const
    FF_PROFILE_DTS_HD_HRA* = 50 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1678:9
else:
  let FF_PROFILE_DTS_HD_HRA* = 50 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1678:9
when 60 is static:
  const
    FF_PROFILE_DTS_HD_MA* = 60 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1679:9
else:
  let FF_PROFILE_DTS_HD_MA* = 60 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1679:9
when 70 is static:
  const
    FF_PROFILE_DTS_EXPRESS* = 70 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1680:9
else:
  let FF_PROFILE_DTS_EXPRESS* = 70 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1680:9
when 61 is static:
  const
    FF_PROFILE_DTS_HD_MA_X* = 61 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1681:9
else:
  let FF_PROFILE_DTS_HD_MA_X* = 61 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1681:9
when 62 is static:
  const
    FF_PROFILE_DTS_HD_MA_X_IMAX* = 62 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1682:9
else:
  let FF_PROFILE_DTS_HD_MA_X_IMAX* = 62 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1682:9
when 30 is static:
  const
    FF_PROFILE_EAC3_DDP_ATMOS* = 30 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1685:9
else:
  let FF_PROFILE_EAC3_DDP_ATMOS* = 30 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1685:9
when 30 is static:
  const
    FF_PROFILE_TRUEHD_ATMOS* = 30 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1687:9
else:
  let FF_PROFILE_TRUEHD_ATMOS* = 30 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1687:9
when 0 is static:
  const
    FF_PROFILE_MPEG2_422* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1689:9
else:
  let FF_PROFILE_MPEG2_422* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1689:9
when 1 is static:
  const
    FF_PROFILE_MPEG2_HIGH* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1690:9
else:
  let FF_PROFILE_MPEG2_HIGH* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1690:9
when 2 is static:
  const
    FF_PROFILE_MPEG2_SS* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1691:9
else:
  let FF_PROFILE_MPEG2_SS* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1691:9
when 3 is static:
  const
    FF_PROFILE_MPEG2_SNR_SCALABLE* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1692:9
else:
  let FF_PROFILE_MPEG2_SNR_SCALABLE* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1692:9
when 4 is static:
  const
    FF_PROFILE_MPEG2_MAIN* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1693:9
else:
  let FF_PROFILE_MPEG2_MAIN* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1693:9
when 5 is static:
  const
    FF_PROFILE_MPEG2_SIMPLE* = 5 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1694:9
else:
  let FF_PROFILE_MPEG2_SIMPLE* = 5 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1694:9
when 66 is static:
  const
    FF_PROFILE_H264_BASELINE* = 66 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1699:9
else:
  let FF_PROFILE_H264_BASELINE* = 66 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1699:9
when 77 is static:
  const
    FF_PROFILE_H264_MAIN* = 77 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1701:9
else:
  let FF_PROFILE_H264_MAIN* = 77 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1701:9
when 88 is static:
  const
    FF_PROFILE_H264_EXTENDED* = 88 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1702:9
else:
  let FF_PROFILE_H264_EXTENDED* = 88 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1702:9
when 100 is static:
  const
    FF_PROFILE_H264_HIGH* = 100 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1703:9
else:
  let FF_PROFILE_H264_HIGH* = 100 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1703:9
when 110 is static:
  const
    FF_PROFILE_H264_HIGH_10* = 110 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1704:9
else:
  let FF_PROFILE_H264_HIGH_10* = 110 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1704:9
when 118 is static:
  const
    FF_PROFILE_H264_MULTIVIEW_HIGH* = 118 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1706:9
else:
  let FF_PROFILE_H264_MULTIVIEW_HIGH* = 118 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1706:9
when 122 is static:
  const
    FF_PROFILE_H264_HIGH_422* = 122 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1707:9
else:
  let FF_PROFILE_H264_HIGH_422* = 122 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1707:9
when 128 is static:
  const
    FF_PROFILE_H264_STEREO_HIGH* = 128 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1709:9
else:
  let FF_PROFILE_H264_STEREO_HIGH* = 128 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1709:9
when 144 is static:
  const
    FF_PROFILE_H264_HIGH_444* = 144 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1710:9
else:
  let FF_PROFILE_H264_HIGH_444* = 144 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1710:9
when 244 is static:
  const
    FF_PROFILE_H264_HIGH_444_PREDICTIVE* = 244 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1711:9
else:
  let FF_PROFILE_H264_HIGH_444_PREDICTIVE* = 244 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1711:9
when 44 is static:
  const
    FF_PROFILE_H264_CAVLC_444* = 44 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1713:9
else:
  let FF_PROFILE_H264_CAVLC_444* = 44 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1713:9
when 0 is static:
  const
    FF_PROFILE_VC1_SIMPLE* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1715:9
else:
  let FF_PROFILE_VC1_SIMPLE* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1715:9
when 1 is static:
  const
    FF_PROFILE_VC1_MAIN* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1716:9
else:
  let FF_PROFILE_VC1_MAIN* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1716:9
when 2 is static:
  const
    FF_PROFILE_VC1_COMPLEX* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1717:9
else:
  let FF_PROFILE_VC1_COMPLEX* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1717:9
when 3 is static:
  const
    FF_PROFILE_VC1_ADVANCED* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1718:9
else:
  let FF_PROFILE_VC1_ADVANCED* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1718:9
when 0 is static:
  const
    FF_PROFILE_MPEG4_SIMPLE* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1720:9
else:
  let FF_PROFILE_MPEG4_SIMPLE* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1720:9
when 1 is static:
  const
    FF_PROFILE_MPEG4_SIMPLE_SCALABLE* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1721:9
else:
  let FF_PROFILE_MPEG4_SIMPLE_SCALABLE* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1721:9
when 2 is static:
  const
    FF_PROFILE_MPEG4_CORE* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1722:9
else:
  let FF_PROFILE_MPEG4_CORE* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1722:9
when 3 is static:
  const
    FF_PROFILE_MPEG4_MAIN* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1723:9
else:
  let FF_PROFILE_MPEG4_MAIN* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1723:9
when 4 is static:
  const
    FF_PROFILE_MPEG4_N_BIT* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1724:9
else:
  let FF_PROFILE_MPEG4_N_BIT* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1724:9
when 5 is static:
  const
    FF_PROFILE_MPEG4_SCALABLE_TEXTURE* = 5 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1725:9
else:
  let FF_PROFILE_MPEG4_SCALABLE_TEXTURE* = 5 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1725:9
when 6 is static:
  const
    FF_PROFILE_MPEG4_SIMPLE_FACE_ANIMATION* = 6 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1726:9
else:
  let FF_PROFILE_MPEG4_SIMPLE_FACE_ANIMATION* = 6 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1726:9
when 7 is static:
  const
    FF_PROFILE_MPEG4_BASIC_ANIMATED_TEXTURE* = 7 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1727:9
else:
  let FF_PROFILE_MPEG4_BASIC_ANIMATED_TEXTURE* = 7 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1727:9
when 8 is static:
  const
    FF_PROFILE_MPEG4_HYBRID* = 8 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1728:9
else:
  let FF_PROFILE_MPEG4_HYBRID* = 8 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1728:9
when 9 is static:
  const
    FF_PROFILE_MPEG4_ADVANCED_REAL_TIME* = 9 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1729:9
else:
  let FF_PROFILE_MPEG4_ADVANCED_REAL_TIME* = 9 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1729:9
when 10 is static:
  const
    FF_PROFILE_MPEG4_CORE_SCALABLE* = 10 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1730:9
else:
  let FF_PROFILE_MPEG4_CORE_SCALABLE* = 10 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1730:9
when 11 is static:
  const
    FF_PROFILE_MPEG4_ADVANCED_CODING* = 11 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1731:9
else:
  let FF_PROFILE_MPEG4_ADVANCED_CODING* = 11 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1731:9
when 12 is static:
  const
    FF_PROFILE_MPEG4_ADVANCED_CORE* = 12 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1732:9
else:
  let FF_PROFILE_MPEG4_ADVANCED_CORE* = 12 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1732:9
when 13 is static:
  const
    FF_PROFILE_MPEG4_ADVANCED_SCALABLE_TEXTURE* = 13 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1733:9
else:
  let FF_PROFILE_MPEG4_ADVANCED_SCALABLE_TEXTURE* = 13 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1733:9
when 14 is static:
  const
    FF_PROFILE_MPEG4_SIMPLE_STUDIO* = 14 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1734:9
else:
  let FF_PROFILE_MPEG4_SIMPLE_STUDIO* = 14 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1734:9
when 15 is static:
  const
    FF_PROFILE_MPEG4_ADVANCED_SIMPLE* = 15 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1735:9
else:
  let FF_PROFILE_MPEG4_ADVANCED_SIMPLE* = 15 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1735:9
when 1 is static:
  const
    FF_PROFILE_JPEG2000_CSTREAM_RESTRICTION_0* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1737:9
else:
  let FF_PROFILE_JPEG2000_CSTREAM_RESTRICTION_0* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1737:9
when 2 is static:
  const
    FF_PROFILE_JPEG2000_CSTREAM_RESTRICTION_1* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1738:9
else:
  let FF_PROFILE_JPEG2000_CSTREAM_RESTRICTION_1* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1738:9
when 32768 is static:
  const
    FF_PROFILE_JPEG2000_CSTREAM_NO_RESTRICTION* = 32768 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1739:9
else:
  let FF_PROFILE_JPEG2000_CSTREAM_NO_RESTRICTION* = 32768 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1739:9
when 3 is static:
  const
    FF_PROFILE_JPEG2000_DCINEMA_2K* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1740:9
else:
  let FF_PROFILE_JPEG2000_DCINEMA_2K* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1740:9
when 4 is static:
  const
    FF_PROFILE_JPEG2000_DCINEMA_4K* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1741:9
else:
  let FF_PROFILE_JPEG2000_DCINEMA_4K* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1741:9
when 0 is static:
  const
    FF_PROFILE_VP9_0* = 0    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1743:9
else:
  let FF_PROFILE_VP9_0* = 0  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1743:9
when 1 is static:
  const
    FF_PROFILE_VP9_1* = 1    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1744:9
else:
  let FF_PROFILE_VP9_1* = 1  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1744:9
when 2 is static:
  const
    FF_PROFILE_VP9_2* = 2    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1745:9
else:
  let FF_PROFILE_VP9_2* = 2  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1745:9
when 3 is static:
  const
    FF_PROFILE_VP9_3* = 3    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1746:9
else:
  let FF_PROFILE_VP9_3* = 3  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1746:9
when 1 is static:
  const
    FF_PROFILE_HEVC_MAIN* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1748:9
else:
  let FF_PROFILE_HEVC_MAIN* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1748:9
when 2 is static:
  const
    FF_PROFILE_HEVC_MAIN_10* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1749:9
else:
  let FF_PROFILE_HEVC_MAIN_10* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1749:9
when 3 is static:
  const
    FF_PROFILE_HEVC_MAIN_STILL_PICTURE* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1750:9
else:
  let FF_PROFILE_HEVC_MAIN_STILL_PICTURE* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1750:9
when 4 is static:
  const
    FF_PROFILE_HEVC_REXT* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1751:9
else:
  let FF_PROFILE_HEVC_REXT* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1751:9
when 9 is static:
  const
    FF_PROFILE_HEVC_SCC* = 9 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1752:9
else:
  let FF_PROFILE_HEVC_SCC* = 9 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1752:9
when 1 is static:
  const
    FF_PROFILE_VVC_MAIN_10* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1754:9
else:
  let FF_PROFILE_VVC_MAIN_10* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1754:9
when 33 is static:
  const
    FF_PROFILE_VVC_MAIN_10_444* = 33 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1755:9
else:
  let FF_PROFILE_VVC_MAIN_10_444* = 33 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1755:9
when 0 is static:
  const
    FF_PROFILE_AV1_MAIN* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1757:9
else:
  let FF_PROFILE_AV1_MAIN* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1757:9
when 1 is static:
  const
    FF_PROFILE_AV1_HIGH* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1758:9
else:
  let FF_PROFILE_AV1_HIGH* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1758:9
when 2 is static:
  const
    FF_PROFILE_AV1_PROFESSIONAL* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1759:9
else:
  let FF_PROFILE_AV1_PROFESSIONAL* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1759:9
when 192 is static:
  const
    FF_PROFILE_MJPEG_HUFFMAN_BASELINE_DCT* = 192 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1761:9
else:
  let FF_PROFILE_MJPEG_HUFFMAN_BASELINE_DCT* = 192 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1761:9
when 193 is static:
  const
    FF_PROFILE_MJPEG_HUFFMAN_EXTENDED_SEQUENTIAL_DCT* = 193 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1762:9
else:
  let FF_PROFILE_MJPEG_HUFFMAN_EXTENDED_SEQUENTIAL_DCT* = 193 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1762:9
when 194 is static:
  const
    FF_PROFILE_MJPEG_HUFFMAN_PROGRESSIVE_DCT* = 194 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1763:9
else:
  let FF_PROFILE_MJPEG_HUFFMAN_PROGRESSIVE_DCT* = 194 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1763:9
when 195 is static:
  const
    FF_PROFILE_MJPEG_HUFFMAN_LOSSLESS* = 195 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1764:9
else:
  let FF_PROFILE_MJPEG_HUFFMAN_LOSSLESS* = 195 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1764:9
when 247 is static:
  const
    FF_PROFILE_MJPEG_JPEG_LS* = 247 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1765:9
else:
  let FF_PROFILE_MJPEG_JPEG_LS* = 247 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1765:9
when 1 is static:
  const
    FF_PROFILE_SBC_MSBC* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1767:9
else:
  let FF_PROFILE_SBC_MSBC* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1767:9
when 0 is static:
  const
    FF_PROFILE_PRORES_PROXY* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1769:9
else:
  let FF_PROFILE_PRORES_PROXY* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1769:9
when 1 is static:
  const
    FF_PROFILE_PRORES_LT* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1770:9
else:
  let FF_PROFILE_PRORES_LT* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1770:9
when 2 is static:
  const
    FF_PROFILE_PRORES_STANDARD* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1771:9
else:
  let FF_PROFILE_PRORES_STANDARD* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1771:9
when 3 is static:
  const
    FF_PROFILE_PRORES_HQ* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1772:9
else:
  let FF_PROFILE_PRORES_HQ* = 3 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1772:9
when 4 is static:
  const
    FF_PROFILE_PRORES_4444* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1773:9
else:
  let FF_PROFILE_PRORES_4444* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1773:9
when 5 is static:
  const
    FF_PROFILE_PRORES_XQ* = 5 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1774:9
else:
  let FF_PROFILE_PRORES_XQ* = 5 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1774:9
when 0 is static:
  const
    FF_PROFILE_ARIB_PROFILE_A* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1776:9
else:
  let FF_PROFILE_ARIB_PROFILE_A* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1776:9
when 1 is static:
  const
    FF_PROFILE_ARIB_PROFILE_C* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1777:9
else:
  let FF_PROFILE_ARIB_PROFILE_C* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1777:9
when 0 is static:
  const
    FF_PROFILE_KLVA_SYNC* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1779:9
else:
  let FF_PROFILE_KLVA_SYNC* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1779:9
when 1 is static:
  const
    FF_PROFILE_KLVA_ASYNC* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1780:9
else:
  let FF_PROFILE_KLVA_ASYNC* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1780:9
when 0 is static:
  const
    FF_PROFILE_EVC_BASELINE* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1782:9
else:
  let FF_PROFILE_EVC_BASELINE* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1782:9
when 1 is static:
  const
    FF_PROFILE_EVC_MAIN* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1783:9
else:
  let FF_PROFILE_EVC_MAIN* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1783:9
when -99 is static:
  const
    FF_LEVEL_UNKNOWN* = -99  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1798:9
else:
  let FF_LEVEL_UNKNOWN* = -99 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1798:9
when 1 is static:
  const
    FF_CODEC_PROPERTY_LOSSLESS* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1807:9
else:
  let FF_CODEC_PROPERTY_LOSSLESS* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1807:9
when 2 is static:
  const
    FF_CODEC_PROPERTY_CLOSED_CAPTIONS* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1808:9
else:
  let FF_CODEC_PROPERTY_CLOSED_CAPTIONS* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1808:9
when 4 is static:
  const
    FF_CODEC_PROPERTY_FILM_GRAIN* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1809:9
else:
  let FF_CODEC_PROPERTY_FILM_GRAIN* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1809:9
when -1 is static:
  const
    FF_SUB_CHARENC_MODE_DO_NOTHING* = -1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1888:9
else:
  let FF_SUB_CHARENC_MODE_DO_NOTHING* = -1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1888:9
when 0 is static:
  const
    FF_SUB_CHARENC_MODE_AUTOMATIC* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1889:9
else:
  let FF_SUB_CHARENC_MODE_AUTOMATIC* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1889:9
when 1 is static:
  const
    FF_SUB_CHARENC_MODE_PRE_DECODER* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1890:9
else:
  let FF_SUB_CHARENC_MODE_PRE_DECODER* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1890:9
when 2 is static:
  const
    FF_SUB_CHARENC_MODE_IGNORE* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1891:9
else:
  let FF_SUB_CHARENC_MODE_IGNORE* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:1891:9
when 512 is static:
  const
    AV_HWACCEL_CODEC_CAP_EXPERIMENTAL* = 512 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:2139:9
else:
  let AV_HWACCEL_CODEC_CAP_EXPERIMENTAL* = 512 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:2139:9
when 1 is static:
  const
    AV_SUBTITLE_FLAG_FORCED* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:2209:9
else:
  let AV_SUBTITLE_FLAG_FORCED* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:2209:9
when 4 is static:
  const
    AV_PARSER_PTS_NB* = 4    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:2775:9
else:
  let AV_PARSER_PTS_NB* = 4  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:2775:9
when 1 is static:
  const
    PARSER_FLAG_COMPLETE_FRAMES* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:2782:9
else:
  let PARSER_FLAG_COMPLETE_FRAMES* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:2782:9
when 2 is static:
  const
    PARSER_FLAG_ONCE* = 2    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:2783:9
else:
  let PARSER_FLAG_ONCE* = 2  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:2783:9
when 4 is static:
  const
    PARSER_FLAG_FETCHED_OFFSET* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:2785:9
else:
  let PARSER_FLAG_FETCHED_OFFSET* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:2785:9
when 4096 is static:
  const
    PARSER_FLAG_USE_CODEC_TS* = 4096 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:2786:9
else:
  let PARSER_FLAG_USE_CODEC_TS* = 4096 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavcodec/avcodec.h:2786:9
when 61 is static:
  const
    LIBAVFORMAT_VERSION_MAJOR* = 61 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/version_major.h:32:9
else:
  let LIBAVFORMAT_VERSION_MAJOR* = 61 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/version_major.h:32:9
when 1 is static:
  const
    FF_API_R_FRAME_RATE* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/version_major.h:52:9
else:
  let FF_API_R_FRAME_RATE* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/version_major.h:52:9
when 65536 is static:
  const
    AVSEEK_SIZE* = 65536     ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avio.h:468:9
else:
  let AVSEEK_SIZE* = 65536   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avio.h:468:9
when 131072 is static:
  const
    AVSEEK_FORCE* = 131072   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avio.h:476:9
else:
  let AVSEEK_FORCE* = 131072 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avio.h:476:9
when 1 is static:
  const
    AVIO_FLAG_READ* = 1      ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avio.h:617:9
else:
  let AVIO_FLAG_READ* = 1    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avio.h:617:9
when 2 is static:
  const
    AVIO_FLAG_WRITE* = 2     ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avio.h:618:9
else:
  let AVIO_FLAG_WRITE* = 2   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avio.h:618:9
when 8 is static:
  const
    AVIO_FLAG_NONBLOCK* = 8  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avio.h:636:9
else:
  let AVIO_FLAG_NONBLOCK* = 8 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avio.h:636:9
when 32768 is static:
  const
    AVIO_FLAG_DIRECT* = 32768 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avio.h:644:9
else:
  let AVIO_FLAG_DIRECT* = 32768 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avio.h:644:9
when 7 is static:
  const
    LIBAVFORMAT_VERSION_MINOR* = 7 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/version.h:34:9
else:
  let LIBAVFORMAT_VERSION_MINOR* = 7 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/version.h:34:9
when 102 is static:
  const
    LIBAVFORMAT_VERSION_MICRO* = 102 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/version.h:35:9
else:
  let LIBAVFORMAT_VERSION_MICRO* = 102 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/version.h:35:9
when LIBAVFORMAT_VERSION_INT is typedesc:
  type
    LIBAVFORMAT_BUILD* = LIBAVFORMAT_VERSION_INT ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/version.h:43:9
else:
  when LIBAVFORMAT_VERSION_INT is static:
    const
      LIBAVFORMAT_BUILD* = LIBAVFORMAT_VERSION_INT ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/version.h:43:9
  else:
    let LIBAVFORMAT_BUILD* = LIBAVFORMAT_VERSION_INT ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/version.h:43:9
when 50 is static:
  const
    AVPROBE_SCORE_EXTENSION* = 50 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:461:9
else:
  let AVPROBE_SCORE_EXTENSION* = 50 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:461:9
when 75 is static:
  const
    AVPROBE_SCORE_MIME* = 75 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:462:9
else:
  let AVPROBE_SCORE_MIME* = 75 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:462:9
when 100 is static:
  const
    AVPROBE_SCORE_MAX* = 100 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:463:9
else:
  let AVPROBE_SCORE_MAX* = 100 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:463:9
when 32 is static:
  const
    AVPROBE_PADDING_SIZE* = 32 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:465:9
else:
  let AVPROBE_PADDING_SIZE* = 32 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:465:9
when 1 is static:
  const
    AVFMT_NOFILE* = 1        ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:468:9
else:
  let AVFMT_NOFILE* = 1      ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:468:9
when 2 is static:
  const
    AVFMT_NEEDNUMBER* = 2    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:469:9
else:
  let AVFMT_NEEDNUMBER* = 2  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:469:9
when 4 is static:
  const
    AVFMT_EXPERIMENTAL* = 4  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:476:9
else:
  let AVFMT_EXPERIMENTAL* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:476:9
when 8 is static:
  const
    AVFMT_SHOW_IDS* = 8      ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:477:9
else:
  let AVFMT_SHOW_IDS* = 8    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:477:9
when 64 is static:
  const
    AVFMT_GLOBALHEADER* = 64 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:478:9
else:
  let AVFMT_GLOBALHEADER* = 64 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:478:9
when 128 is static:
  const
    AVFMT_NOTIMESTAMPS* = 128 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:479:9
else:
  let AVFMT_NOTIMESTAMPS* = 128 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:479:9
when 256 is static:
  const
    AVFMT_GENERIC_INDEX* = 256 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:480:9
else:
  let AVFMT_GENERIC_INDEX* = 256 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:480:9
when 512 is static:
  const
    AVFMT_TS_DISCONT* = 512  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:481:9
else:
  let AVFMT_TS_DISCONT* = 512 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:481:9
when 1024 is static:
  const
    AVFMT_VARIABLE_FPS* = 1024 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:482:9
else:
  let AVFMT_VARIABLE_FPS* = 1024 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:482:9
when 2048 is static:
  const
    AVFMT_NODIMENSIONS* = 2048 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:483:9
else:
  let AVFMT_NODIMENSIONS* = 2048 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:483:9
when 4096 is static:
  const
    AVFMT_NOSTREAMS* = 4096  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:484:9
else:
  let AVFMT_NOSTREAMS* = 4096 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:484:9
when 8192 is static:
  const
    AVFMT_NOBINSEARCH* = 8192 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:485:9
else:
  let AVFMT_NOBINSEARCH* = 8192 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:485:9
when 16384 is static:
  const
    AVFMT_NOGENSEARCH* = 16384 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:486:9
else:
  let AVFMT_NOGENSEARCH* = 16384 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:486:9
when 32768 is static:
  const
    AVFMT_NO_BYTE_SEEK* = 32768 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:487:9
else:
  let AVFMT_NO_BYTE_SEEK* = 32768 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:487:9
when 65536 is static:
  const
    AVFMT_ALLOW_FLUSH* = 65536 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:489:9
else:
  let AVFMT_ALLOW_FLUSH* = 65536 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:489:9
when 131072 is static:
  const
    AVFMT_TS_NONSTRICT* = 131072 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:491:9
else:
  let AVFMT_TS_NONSTRICT* = 131072 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:491:9
when 262144 is static:
  const
    AVFMT_TS_NEGATIVE* = 262144 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:494:9
else:
  let AVFMT_TS_NEGATIVE* = 262144 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:494:9
when 67108864 is static:
  const
    AVFMT_SEEK_TO_PTS* = 67108864 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:503:9
else:
  let AVFMT_SEEK_TO_PTS* = 67108864 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:503:9
when 1 is static:
  const
    AVINDEX_KEYFRAME* = 1    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:610:9
else:
  let AVINDEX_KEYFRAME* = 1  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:610:9
when 2 is static:
  const
    AVINDEX_DISCARD_FRAME* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:611:9
else:
  let AVINDEX_DISCARD_FRAME* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:611:9
when 0 is static:
  const
    AV_PTS_WRAP_IGNORE* = 0  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:739:9
else:
  let AV_PTS_WRAP_IGNORE* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:739:9
when 1 is static:
  const
    AV_PTS_WRAP_ADD_OFFSET* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:740:9
else:
  let AV_PTS_WRAP_ADD_OFFSET* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:740:9
when -1 is static:
  const
    AV_PTS_WRAP_SUB_OFFSET* = -1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:741:9
else:
  let AV_PTS_WRAP_SUB_OFFSET* = -1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:741:9
when 1 is static:
  const
    AVSTREAM_EVENT_FLAG_METADATA_UPDATED* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:900:9
else:
  let AVSTREAM_EVENT_FLAG_METADATA_UPDATED* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:900:9
when 1 is static:
  const
    AV_PROGRAM_RUNNING* = 1  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1205:9
else:
  let AV_PROGRAM_RUNNING* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1205:9
when 1 is static:
  const
    AVFMTCTX_NOHEADER* = 1   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1240:9
else:
  let AVFMTCTX_NOHEADER* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1240:9
when 2 is static:
  const
    AVFMTCTX_UNSEEKABLE* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1242:9
else:
  let AVFMTCTX_UNSEEKABLE* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1242:9
when 1 is static:
  const
    AVFMT_FLAG_GENPTS* = 1   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1441:9
else:
  let AVFMT_FLAG_GENPTS* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1441:9
when 2 is static:
  const
    AVFMT_FLAG_IGNIDX* = 2   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1442:9
else:
  let AVFMT_FLAG_IGNIDX* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1442:9
when 4 is static:
  const
    AVFMT_FLAG_NONBLOCK* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1443:9
else:
  let AVFMT_FLAG_NONBLOCK* = 4 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1443:9
when 8 is static:
  const
    AVFMT_FLAG_IGNDTS* = 8   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1444:9
else:
  let AVFMT_FLAG_IGNDTS* = 8 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1444:9
when 16 is static:
  const
    AVFMT_FLAG_NOFILLIN* = 16 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1445:9
else:
  let AVFMT_FLAG_NOFILLIN* = 16 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1445:9
when 32 is static:
  const
    AVFMT_FLAG_NOPARSE* = 32 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1446:9
else:
  let AVFMT_FLAG_NOPARSE* = 32 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1446:9
when 64 is static:
  const
    AVFMT_FLAG_NOBUFFER* = 64 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1447:9
else:
  let AVFMT_FLAG_NOBUFFER* = 64 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1447:9
when 128 is static:
  const
    AVFMT_FLAG_CUSTOM_IO* = 128 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1448:9
else:
  let AVFMT_FLAG_CUSTOM_IO* = 128 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1448:9
when 256 is static:
  const
    AVFMT_FLAG_DISCARD_CORRUPT* = 256 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1449:9
else:
  let AVFMT_FLAG_DISCARD_CORRUPT* = 256 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1449:9
when 512 is static:
  const
    AVFMT_FLAG_FLUSH_PACKETS* = 512 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1450:9
else:
  let AVFMT_FLAG_FLUSH_PACKETS* = 512 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1450:9
when 1024 is static:
  const
    AVFMT_FLAG_BITEXACT* = 1024 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1457:9
else:
  let AVFMT_FLAG_BITEXACT* = 1024 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1457:9
when 65536 is static:
  const
    AVFMT_FLAG_SORT_DTS* = 65536 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1458:9
else:
  let AVFMT_FLAG_SORT_DTS* = 65536 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1458:9
when 524288 is static:
  const
    AVFMT_FLAG_FAST_SEEK* = 524288 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1459:9
else:
  let AVFMT_FLAG_FAST_SEEK* = 524288 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1459:9
when 1048576 is static:
  const
    AVFMT_FLAG_SHORTEST* = 1048576 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1461:9
else:
  let AVFMT_FLAG_SHORTEST* = 1048576 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1461:9
when 2097152 is static:
  const
    AVFMT_FLAG_AUTO_BSF* = 2097152 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1463:9
else:
  let AVFMT_FLAG_AUTO_BSF* = 2097152 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1463:9
when 1 is static:
  const
    FF_FDEBUG_TS* = 1        ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1568:9
else:
  let FF_FDEBUG_TS* = 1      ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1568:9
when 1 is static:
  const
    AVFMT_EVENT_FLAG_METADATA_UPDATED* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1666:9
else:
  let AVFMT_EVENT_FLAG_METADATA_UPDATED* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1666:9
when -1 is static:
  const
    AVFMT_AVOID_NEG_TS_AUTO* = -1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1677:9
else:
  let AVFMT_AVOID_NEG_TS_AUTO* = -1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1677:9
when 0 is static:
  const
    AVFMT_AVOID_NEG_TS_DISABLED* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1678:9
else:
  let AVFMT_AVOID_NEG_TS_DISABLED* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1678:9
when 1 is static:
  const
    AVFMT_AVOID_NEG_TS_MAKE_NON_NEGATIVE* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1679:9
else:
  let AVFMT_AVOID_NEG_TS_MAKE_NON_NEGATIVE* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1679:9
when 2 is static:
  const
    AVFMT_AVOID_NEG_TS_MAKE_ZERO* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1680:9
else:
  let AVFMT_AVOID_NEG_TS_MAKE_ZERO* = 2 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:1680:9
when 1 is static:
  const
    AVSEEK_FLAG_BACKWARD* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:2479:9
else:
  let AVSEEK_FLAG_BACKWARD* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:2479:9
when 2 is static:
  const
    AVSEEK_FLAG_BYTE* = 2    ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:2480:9
else:
  let AVSEEK_FLAG_BYTE* = 2  ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:2480:9
when 4 is static:
  const
    AVSEEK_FLAG_ANY* = 4     ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:2481:9
else:
  let AVSEEK_FLAG_ANY* = 4   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:2481:9
when 8 is static:
  const
    AVSEEK_FLAG_FRAME* = 8   ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:2482:9
else:
  let AVSEEK_FLAG_FRAME* = 8 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:2482:9
when 0 is static:
  const
    AVSTREAM_INIT_IN_WRITE_HEADER* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:2489:9
else:
  let AVSTREAM_INIT_IN_WRITE_HEADER* = 0 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:2489:9
when 1 is static:
  const
    AVSTREAM_INIT_IN_INIT_OUTPUT* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:2490:9
else:
  let AVSTREAM_INIT_IN_INIT_OUTPUT* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:2490:9
when 1 is static:
  const
    AV_FRAME_FILENAME_FLAGS_MULTIPLE* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:2925:9
else:
  let AV_FRAME_FILENAME_FLAGS_MULTIPLE* = 1 ## Generated based on /home/kikuchi/Data/src/NimModules/ffmpeg_nim/src/include/libavformat/avformat.h:2925:9
