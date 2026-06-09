# libav_nim/decoder.nim
#
# Result-based video decoder wrapper built on libavformat, libavcodec, and
# libavutil.

import std/strformat
import results
import ./bindings/c_api
import ./error
import ./frame
import ./packet
import ./types

# =============================================================================
# === Decoder options
# =============================================================================

type
  DecoderInputOption* = tuple[key: string, value: string]

  DecoderOptions* = object
    ## Options for opening an input video stream.
    ##
    ## decoderName can be used to force hardware decoders such as
    ## "h264_v4l2m2m" or "hevc_v4l2m2m".
    decoderName*: string
    rtspTransportTcp*: bool
    timeoutUsec*: int64
    inputOptions*: seq[DecoderInputOption]

# =============================================================================
# === Decoder owner
# =============================================================================

type
  VideoDecoder* = ref object
    fmtCtx*: AVFormatContextPtr
    codecCtx*: AVCodecContextPtr
    videoStreamIndex*: int
    timeBase*: Rational
    packet*: Packet
    frame*: Frame
    flushed*: bool

# =============================================================================
# === Read-frame result
# =============================================================================

type
  ReadFrame* = object
    ## Result value returned by readFrame().
    ##
    ## When eof is true, frame must be ignored.
    eof*: bool
    frame*: Yuv420FrameView

  ReadFrameResult* = FFmpegResult[ReadFrame]

# -----------------------------------------------------------------------------
# --- frameRead
# -----------------------------------------------------------------------------

proc frameRead*(frame: Yuv420FrameView): ReadFrame =
  result = ReadFrame(eof: false, frame: frame)

# -----------------------------------------------------------------------------
# --- eofRead
# -----------------------------------------------------------------------------

proc eofRead*(): ReadFrame =
  result = ReadFrame(eof: true)

# =============================================================================
# === Internal dictionary helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- setDictString
# -----------------------------------------------------------------------------

proc setDictString(
    dict: var AVDictionaryPtr;
    key: string;
    value: string
  ): FFmpegResult[void] =
  let ret = okAv(
    av_dict_set(addr dict, key.cstring, value.cstring, 0),
    &"av_dict_set({key})"
  )
  if ret.isErr:
    result = err(ret.error)
    return

  result = ok()

# -----------------------------------------------------------------------------
# --- freeDict
# -----------------------------------------------------------------------------

proc freeDict(dict: var AVDictionaryPtr) =
  if not dict.isNil:
    av_dict_free(addr dict)
    dict = nil

# -----------------------------------------------------------------------------
# --- buildInputOptions
# -----------------------------------------------------------------------------

proc buildInputOptions(options: DecoderOptions): FFmpegResult[AVDictionaryPtr] =
  var dict: AVDictionaryPtr = nil

  if options.rtspTransportTcp:
    let ret = dict.setDictString("rtsp_transport", "tcp")
    if ret.isErr:
      freeDict(dict)
      result = err(ret.error)
      return

  if options.timeoutUsec > 0:
    let ret = dict.setDictString("timeout", $options.timeoutUsec)
    if ret.isErr:
      freeDict(dict)
      result = err(ret.error)
      return

  for item in options.inputOptions:
    let ret = dict.setDictString(item.key, item.value)
    if ret.isErr:
      freeDict(dict)
      result = err(ret.error)
      return

  result = ok(dict)

# =============================================================================
# === Internal stream helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- streamAt
# -----------------------------------------------------------------------------

proc streamAt(ctx: AVFormatContextPtr; index: int): FFmpegResult[AVStreamPtr] =
  if ctx.isNil:
    result = fail[AVStreamPtr]("streamAt", "AVFormatContext is nil")
    return

  if index < 0 or index >= int(ctx[].nb_streams):
    result = fail[AVStreamPtr](
      "streamAt",
      &"Stream index out of range: {index} / {ctx[].nb_streams}"
    )
    return

  let streams = cast[ptr UncheckedArray[AVStreamPtr]](ctx[].streams)
  result = ok(streams[index])

# -----------------------------------------------------------------------------
# --- findVideoStreamIndex
# -----------------------------------------------------------------------------

proc findVideoStreamIndex(ctx: AVFormatContextPtr): FFmpegResult[int] =
  if ctx.isNil:
    result = fail[int]("findVideoStreamIndex", "AVFormatContext is nil")
    return

  for i in 0 ..< int(ctx[].nb_streams):
    let streamRet = ctx.streamAt(i)
    if streamRet.isErr:
      result = err(streamRet.error)
      return

    let stream = streamRet.value
    if stream.isNil or stream[].codecpar.isNil:
      continue

    if stream[].codecpar[].codec_type == AVMEDIA_TYPE_VIDEO:
      result = ok(i)
      return

  result = fail[int]("findVideoStreamIndex", "No video stream found")

# -----------------------------------------------------------------------------
# --- selectDecoder
# -----------------------------------------------------------------------------

proc selectDecoder(
    codecpar: AVCodecParametersPtr;
    decoderName: string
  ): FFmpegResult[AVCodecPtr] =
  if codecpar.isNil:
    result = fail[AVCodecPtr]("selectDecoder", "AVCodecParameters is nil")
    return

  if decoderName.len > 0:
    let decoder = avcodec_find_decoder_by_name(decoderName.cstring)
    if decoder.isNil:
      result = fail[AVCodecPtr]("selectDecoder", &"Decoder not found: {decoderName}")
      return

    result = ok(decoder)
    return

  let decoder = avcodec_find_decoder(codecpar[].codec_id)
  if decoder.isNil:
    result = fail[AVCodecPtr](
      "selectDecoder",
      &"Decoder not found for codec id {codecIdFromRaw(cuint(codecpar[].codec_id))}"
    )
    return

  result = ok(decoder)

# =============================================================================
# === Decoder lifecycle
# =============================================================================

# -----------------------------------------------------------------------------
# --- close
# -----------------------------------------------------------------------------

proc close*(decoder: VideoDecoder) =
  if decoder.isNil:
    return

  if not decoder.packet.isNil:
    decoder.packet.close()
    decoder.packet = nil

  if not decoder.frame.isNil:
    decoder.frame.close()
    decoder.frame = nil

  if not decoder.codecCtx.isNil:
    var codecCtx = decoder.codecCtx
    avcodec_free_context(addr codecCtx)
    decoder.codecCtx = nil

  if not decoder.fmtCtx.isNil:
    var fmtCtx = decoder.fmtCtx
    avformat_close_input(addr fmtCtx)
    decoder.fmtCtx = nil

# -----------------------------------------------------------------------------
# --- openVideoDecoder
# -----------------------------------------------------------------------------

proc openVideoDecoder*(
    path: string;
    options = DecoderOptions()
  ): FFmpegResult[VideoDecoder] =
  var fmtCtx: AVFormatContextPtr = nil
  var codecCtx: AVCodecContextPtr = nil
  var inputOptions: AVDictionaryPtr = nil
  var packet: Packet = nil
  var frame: Frame = nil

  let optionsRet = buildInputOptions(options)
  if optionsRet.isErr:
    result = err(optionsRet.error)
    return

  inputOptions = optionsRet.value

  let openRet = okAv(
    avformat_open_input(addr fmtCtx, path.cstring, nil, addr inputOptions),
    &"avformat_open_input({path})"
  )
  if openRet.isErr:
    result = err(openRet.error)
    freeDict(inputOptions)
    if not fmtCtx.isNil:
      var tmpFmtCtx = fmtCtx
      avformat_close_input(addr tmpFmtCtx)
    return

  freeDict(inputOptions)

  let streamInfoRet = okAv(
    avformat_find_stream_info(fmtCtx, nil),
    "avformat_find_stream_info"
  )
  if streamInfoRet.isErr:
    result = err(streamInfoRet.error)
    var tmpFmtCtx = fmtCtx
    avformat_close_input(addr tmpFmtCtx)
    return

  let videoStreamIndexRet = findVideoStreamIndex(fmtCtx)
  if videoStreamIndexRet.isErr:
    result = err(videoStreamIndexRet.error)
    var tmpFmtCtx = fmtCtx
    avformat_close_input(addr tmpFmtCtx)
    return

  let videoStreamIndex = videoStreamIndexRet.value

  let streamRet = fmtCtx.streamAt(videoStreamIndex)
  if streamRet.isErr:
    result = err(streamRet.error)
    var tmpFmtCtx = fmtCtx
    avformat_close_input(addr tmpFmtCtx)
    return

  let stream = streamRet.value
  let codecpar = stream[].codecpar

  let codecRet = selectDecoder(codecpar, options.decoderName)
  if codecRet.isErr:
    result = err(codecRet.error)
    var tmpFmtCtx = fmtCtx
    avformat_close_input(addr tmpFmtCtx)
    return

  let codec = codecRet.value

  codecCtx = avcodec_alloc_context3(codec)
  if codecCtx.isNil:
    result = fail[VideoDecoder]("avcodec_alloc_context3", "allocation failed")
    var tmpFmtCtx = fmtCtx
    avformat_close_input(addr tmpFmtCtx)
    return

  let paramsRet = okAv(
    avcodec_parameters_to_context(codecCtx, codecpar),
    "avcodec_parameters_to_context"
  )
  if paramsRet.isErr:
    result = err(paramsRet.error)
    var tmpCodecCtx = codecCtx
    avcodec_free_context(addr tmpCodecCtx)
    var tmpFmtCtx = fmtCtx
    avformat_close_input(addr tmpFmtCtx)
    return

  let codecOpenRet = okAv(avcodec_open2(codecCtx, codec, nil), "avcodec_open2")
  if codecOpenRet.isErr:
    result = err(codecOpenRet.error)
    var tmpCodecCtx = codecCtx
    avcodec_free_context(addr tmpCodecCtx)
    var tmpFmtCtx = fmtCtx
    avformat_close_input(addr tmpFmtCtx)
    return

  let packetRet = newPacket()
  if packetRet.isErr:
    result = err(packetRet.error)
    var tmpCodecCtx = codecCtx
    avcodec_free_context(addr tmpCodecCtx)
    var tmpFmtCtx = fmtCtx
    avformat_close_input(addr tmpFmtCtx)
    return

  packet = packetRet.value

  let frameRet = newFrame()
  if frameRet.isErr:
    result = err(frameRet.error)
    packet.close()
    var tmpCodecCtx = codecCtx
    avcodec_free_context(addr tmpCodecCtx)
    var tmpFmtCtx = fmtCtx
    avformat_close_input(addr tmpFmtCtx)
    return

  frame = frameRet.value

  result = ok(VideoDecoder(
    fmtCtx: fmtCtx,
    codecCtx: codecCtx,
    videoStreamIndex: videoStreamIndex,
    timeBase: stream[].time_base.toRational(),
    packet: packet,
    frame: frame,
    flushed: false
  ))

# =============================================================================
# === Decoder state
# =============================================================================

# -----------------------------------------------------------------------------
# --- isOpen
# -----------------------------------------------------------------------------

proc isOpen*(decoder: VideoDecoder): bool =
  result = (
    not decoder.isNil and
    not decoder.fmtCtx.isNil and
    not decoder.codecCtx.isNil and
    not decoder.packet.isNil and
    not decoder.frame.isNil
  )

# -----------------------------------------------------------------------------
# --- requireOpen
# -----------------------------------------------------------------------------

proc requireOpen*(decoder: VideoDecoder): FFmpegResult[VideoDecoder] =
  if not decoder.isOpen():
    result = fail[VideoDecoder]("VideoDecoder.requireOpen", "VideoDecoder is closed")
    return

  result = ok(decoder)

# =============================================================================
# === Packet feeding
# =============================================================================

# -----------------------------------------------------------------------------
# --- sendNextPacket
# -----------------------------------------------------------------------------

proc sendNextPacket(decoder: VideoDecoder): FFmpegResult[bool] =
  let openRet = decoder.requireOpen()
  if openRet.isErr:
    result = err(openRet.error)
    return

  if decoder.flushed:
    result = ok(false)
    return

  while true:
    let packetPtrRet = decoder.packet.requireOpen()
    if packetPtrRet.isErr:
      result = err(packetPtrRet.error)
      return

    let packetPtr = packetPtrRet.value
    let readRet = av_read_frame(decoder.fmtCtx, packetPtr)

    if readRet == avErrorEof:
      let flushRet = okAv(
        avcodec_send_packet(decoder.codecCtx, nil),
        "avcodec_send_packet(flush)"
      )
      if flushRet.isErr:
        result = err(flushRet.error)
        return

      decoder.flushed = true
      result = ok(true)
      return

    let checkedReadRet = okAv(readRet, "av_read_frame")
    if checkedReadRet.isErr:
      result = err(checkedReadRet.error)
      return

    if int(packetPtr[].stream_index) != decoder.videoStreamIndex:
      decoder.packet.unref()
      continue

    let sendRet = avcodec_send_packet(decoder.codecCtx, packetPtr)
    decoder.packet.unref()

    if sendRet == 0 or sendRet == avErrorAgain:
      result = ok(true)
      return

    let checkedSendRet = okAv(sendRet, "avcodec_send_packet")
    if checkedSendRet.isErr:
      result = err(checkedSendRet.error)
      return

# =============================================================================
# === Frame reading
# =============================================================================

# -----------------------------------------------------------------------------
# --- readFrameInto
# -----------------------------------------------------------------------------

proc readFrameInto*(
    decoder: VideoDecoder;
    view: var Yuv420FrameView
  ): FFmpegResult[bool] =
  let openRet = decoder.requireOpen()
  if openRet.isErr:
    result = err(openRet.error)
    return

  decoder.frame.unref()

  while true:
    let framePtrRet = decoder.frame.requireOpen()
    if framePtrRet.isErr:
      result = err(framePtrRet.error)
      return

    let receiveRet = avcodec_receive_frame(decoder.codecCtx, framePtrRet.value)

    if receiveRet == 0:
      let viewRet = decoder.frame.toYuv420FrameView(decoder.timeBase)
      if viewRet.isErr:
        result = err(viewRet.error)
        return

      view = viewRet.value
      result = ok(true)
      return

    if receiveRet == avErrorEof:
      result = ok(false)
      return

    if receiveRet == avErrorAgain:
      let sentRet = decoder.sendNextPacket()
      if sentRet.isErr:
        result = err(sentRet.error)
        return

      if not sentRet.value:
        result = ok(false)
        return

      continue

    let checkedReceiveRet = okAv(receiveRet, "avcodec_receive_frame")
    if checkedReceiveRet.isErr:
      result = err(checkedReceiveRet.error)
      return

# -----------------------------------------------------------------------------
# --- readFrame
# -----------------------------------------------------------------------------

proc readFrame*(decoder: VideoDecoder): ReadFrameResult =
  var view: Yuv420FrameView
  let readRet = decoder.readFrameInto(view)
  if readRet.isErr:
    result = err(readRet.error)
    return

  if not readRet.value:
    result = ok(eofRead())
    return

  result = ok(frameRead(view))
