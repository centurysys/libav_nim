# libav_nim/mp4_writer.nim
#
# Minimal MP4 muxer for encoded video packets produced by VideoEncoder.

import std/strformat
import results
import ./bindings/c_api
import ./encoder
import ./error
import ./types

# =============================================================================
# === MP4 writer owner
# =============================================================================

type
  Mp4VideoWriter* = ref object
    fmtCtx*: AVFormatContextPtr
    stream*: AVStreamPtr
    path*: string
    encoderTimeBase*: Rational
    nextPts*: int64
    headerWritten*: bool
    trailerWritten*: bool
    closed*: bool

# =============================================================================
# === Internal helpers
# =============================================================================

# -----------------------------------------------------------------------------
# --- hasNoFileFlag
# -----------------------------------------------------------------------------

proc hasNoFileFlag(fmtCtx: AVFormatContextPtr): bool =
  if fmtCtx.isNil or fmtCtx[].oformat.isNil:
    result = false
    return

  result = (fmtCtx[].oformat[].flags and AVFMT_NOFILE) != 0

# -----------------------------------------------------------------------------
# --- requireOpen
# -----------------------------------------------------------------------------

proc requireOpen(writer: Mp4VideoWriter): FFmpegResult[void] =
  if writer.isNil or writer.fmtCtx.isNil or writer.stream.isNil or writer.closed:
    result = fail[void]("Mp4VideoWriter.requireOpen", "MP4 writer is closed")
    return

  if not writer.headerWritten:
    result = fail[void]("Mp4VideoWriter.requireOpen", "MP4 writer header has not been written")
    return

  if writer.trailerWritten:
    result = fail[void]("Mp4VideoWriter.requireOpen", "MP4 writer trailer has already been written")
    return

  result = ok()

# -----------------------------------------------------------------------------
# --- closeIo
# -----------------------------------------------------------------------------

proc closeIo(writer: Mp4VideoWriter) =
  if writer.isNil or writer.fmtCtx.isNil:
    return

  if writer.fmtCtx.hasNoFileFlag():
    return

  if writer.fmtCtx[].pb.isNil:
    return

  discard avio_closep(addr writer.fmtCtx[].pb)

# -----------------------------------------------------------------------------
# --- freeContext
# -----------------------------------------------------------------------------

proc freeContext(writer: Mp4VideoWriter) =
  if writer.isNil or writer.fmtCtx.isNil:
    return

  avformat_free_context(writer.fmtCtx)
  writer.fmtCtx = nil
  writer.stream = nil


# -----------------------------------------------------------------------------
# --- toRawCodecId
# -----------------------------------------------------------------------------

proc toRawCodecId(codecId: CodecId): AVCodecID =
  case codecId
  of cidH264:
    result = AV_CODEC_ID_H264
  of cidHevc:
    result = AV_CODEC_ID_HEVC
  of cidRawVideo:
    result = AV_CODEC_ID_RAWVIDEO
  else:
    result = AV_CODEC_ID_NONE

# -----------------------------------------------------------------------------
# --- toRawPixelFormatValue
# -----------------------------------------------------------------------------

proc toRawPixelFormatValue(format: PixelFormat): cint =
  case format
  of pfYuv420p:
    result = cint(AV_PIX_FMT_YUV420P)
  of pfNv12:
    result = cint(AV_PIX_FMT_NV12)
  of pfNv21:
    result = cint(AV_PIX_FMT_NV21)
  of pfRgb24:
    result = cint(AV_PIX_FMT_RGB24)
  of pfRgba:
    result = cint(AV_PIX_FMT_RGBA)
  of pfBgra:
    result = cint(AV_PIX_FMT_BGRA)
  of pfRgbx:
    result = cint(AV_PIX_FMT_RGB0)
  of pfBgrx:
    result = cint(AV_PIX_FMT_BGR0)
  else:
    result = -1

# -----------------------------------------------------------------------------
# --- copyExtradata
# -----------------------------------------------------------------------------

proc copyExtradata(codecpar: AVCodecParametersPtr; extradata: openArray[byte]): FFmpegResult[void] =
  if codecpar.isNil:
    result = fail[void]("copyExtradata", "codec parameters are nil")
    return

  if extradata.len <= 0:
    result = ok()
    return

  let allocSize = extradata.len + AV_INPUT_BUFFER_PADDING_SIZE
  let mem = av_mallocz(csize_t(allocSize))
  if mem.isNil:
    result = fail[void]("av_mallocz", &"allocation failed for extradata: {extradata.len} bytes")
    return

  copyMem(mem, unsafeAddr extradata[0], extradata.len)
  codecpar[].extradata = cast[ptr uint8](mem)
  codecpar[].extradata_size = cint(extradata.len)
  result = ok()

# -----------------------------------------------------------------------------
# --- configureStreamFromInfo
# -----------------------------------------------------------------------------

proc configureStreamFromInfo(
    stream: AVStreamPtr;
    info: EncodedStreamInfo
  ): FFmpegResult[void] =
  if stream.isNil or stream[].codecpar.isNil:
    result = fail[void]("configureStreamFromInfo", "stream or codec parameters are nil")
    return

  if info.codecId == cidUnknown:
    result = fail[void]("configureStreamFromInfo", "encoded stream codec id is unknown")
    return

  if info.width <= 0 or info.height <= 0:
    result = fail[void]("configureStreamFromInfo", &"invalid encoded stream size: {info.width}x{info.height}")
    return

  let codecpar = stream[].codecpar
  codecpar[].codec_type = AVMEDIA_TYPE_VIDEO
  codecpar[].codec_id = info.codecId.toRawCodecId()
  codecpar[].width = cint(info.width)
  codecpar[].height = cint(info.height)
  codecpar[].format = info.pixelFormat.toRawPixelFormatValue()
  codecpar[].bit_rate = info.bitRate
  codecpar[].framerate = info.framerate.toAVRational()
  stream[].time_base = info.timeBase.toAVRational()

  let extraRet = codecpar.copyExtradata(info.extradata)
  if extraRet.isErr:
    result = err(extraRet.error)
    return

  result = ok()

# -----------------------------------------------------------------------------
# --- preparePacketViewForWriting
# -----------------------------------------------------------------------------

proc preparePacketViewForWriting(
    writer: Mp4VideoWriter;
    packet: AVPacketPtr;
    view: EncodedPacketView
  ): FFmpegResult[void] =
  if packet.isNil:
    result = fail[void]("Mp4VideoWriter.preparePacketViewForWriting", "Temporary packet is nil")
    return

  if view.size <= 0:
    result = fail[void](
      "Mp4VideoWriter.preparePacketViewForWriting",
      &"Encoded packet has no payload: size={view.size}"
    )
    return

  if view.data.isNil:
    result = fail[void]("Mp4VideoWriter.preparePacketViewForWriting", "Encoded packet payload is nil")
    return

  packet[].data = cast[ptr uint8](view.data)
  packet[].size = cint(view.size)
  packet[].pts = view.pts
  packet[].dts = view.dts
  packet[].duration = view.duration
  packet[].stream_index = writer.stream[].index
  packet[].flags = 0
  if view.isKeyframe:
    packet[].flags = packet[].flags or cint(AV_PKT_FLAG_KEY)

  if packet[].pts == avNoPtsValue:
    packet[].pts = writer.nextPts

  if packet[].dts == avNoPtsValue:
    packet[].dts = packet[].pts

  if packet[].duration <= 0:
    packet[].duration = 1

  writer.nextPts = packet[].pts + packet[].duration

  av_packet_rescale_ts(
    packet,
    writer.encoderTimeBase.toAVRational(),
    writer.stream[].time_base
  )

  result = ok()

# =============================================================================
# === MP4 writer lifecycle
# =============================================================================

# -----------------------------------------------------------------------------
# --- openMp4VideoWriter
# -----------------------------------------------------------------------------

proc openMp4VideoWriter*(path: string; encoder: VideoEncoder): FFmpegResult[Mp4VideoWriter] =
  if path.len == 0:
    result = fail[Mp4VideoWriter]("openMp4VideoWriter", "Output path is empty")
    return

  let codecCtxRet = encoder.requireOpen()
  if codecCtxRet.isErr:
    result = err(codecCtxRet.error)
    return

  let codecCtx = codecCtxRet.value
  var fmtCtx: AVFormatContextPtr = nil

  let allocRet = okAv(
    avformat_alloc_output_context2(addr fmtCtx, nil, "mp4", path.cstring),
    &"avformat_alloc_output_context2({path})"
  )
  if allocRet.isErr:
    result = err(allocRet.error)
    return

  if fmtCtx.isNil:
    result = fail[Mp4VideoWriter]("avformat_alloc_output_context2", "allocation failed")
    return

  let stream = avformat_new_stream(fmtCtx, nil)
  if stream.isNil:
    avformat_free_context(fmtCtx)
    result = fail[Mp4VideoWriter]("avformat_new_stream", "allocation failed")
    return

  let paramsRet = okAv(
    avcodec_parameters_from_context(stream[].codecpar, codecCtx),
    "avcodec_parameters_from_context"
  )
  if paramsRet.isErr:
    avformat_free_context(fmtCtx)
    result = err(paramsRet.error)
    return

  stream[].time_base = encoder.timeBase.toAVRational()

  if not fmtCtx.hasNoFileFlag():
    let ioRet = okAv(
      avio_open(addr fmtCtx[].pb, path.cstring, AVIO_FLAG_WRITE),
      &"avio_open({path})"
    )
    if ioRet.isErr:
      avformat_free_context(fmtCtx)
      result = err(ioRet.error)
      return

  let headerRet = okAv(avformat_write_header(fmtCtx, nil), "avformat_write_header")
  if headerRet.isErr:
    if not fmtCtx.hasNoFileFlag() and not fmtCtx[].pb.isNil:
      discard avio_closep(addr fmtCtx[].pb)
    avformat_free_context(fmtCtx)
    result = err(headerRet.error)
    return

  result = ok(Mp4VideoWriter(
    fmtCtx: fmtCtx,
    stream: stream,
    path: path,
    encoderTimeBase: encoder.timeBase,
    nextPts: 0,
    headerWritten: true,
    trailerWritten: false,
    closed: false
  ))

# -----------------------------------------------------------------------------
# --- openMp4VideoWriter
# -----------------------------------------------------------------------------

proc openMp4VideoWriter*(path: string; streamInfo: EncodedStreamInfo): FFmpegResult[Mp4VideoWriter] =
  ## Open an MP4 writer using copied codec parameters rather than a live encoder.
  ##
  ## This is used when already-encoded packets are written later, for example
  ## from an event-recording packet ring.
  if path.len == 0:
    result = fail[Mp4VideoWriter]("openMp4VideoWriter", "Output path is empty")
    return

  if not streamInfo.timeBase.isValid():
    result = fail[Mp4VideoWriter]("openMp4VideoWriter", "Encoded stream time_base is invalid")
    return

  var fmtCtx: AVFormatContextPtr = nil
  let allocRet = okAv(
    avformat_alloc_output_context2(addr fmtCtx, nil, "mp4", path.cstring),
    &"avformat_alloc_output_context2({path})"
  )
  if allocRet.isErr:
    result = err(allocRet.error)
    return

  if fmtCtx.isNil:
    result = fail[Mp4VideoWriter]("avformat_alloc_output_context2", "allocation failed")
    return

  let stream = avformat_new_stream(fmtCtx, nil)
  if stream.isNil:
    avformat_free_context(fmtCtx)
    result = fail[Mp4VideoWriter]("avformat_new_stream", "allocation failed")
    return

  let configRet = stream.configureStreamFromInfo(streamInfo)
  if configRet.isErr:
    avformat_free_context(fmtCtx)
    result = err(configRet.error)
    return

  if not fmtCtx.hasNoFileFlag():
    let ioRet = okAv(
      avio_open(addr fmtCtx[].pb, path.cstring, AVIO_FLAG_WRITE),
      &"avio_open({path})"
    )
    if ioRet.isErr:
      avformat_free_context(fmtCtx)
      result = err(ioRet.error)
      return

  let headerRet = okAv(avformat_write_header(fmtCtx, nil), "avformat_write_header")
  if headerRet.isErr:
    if not fmtCtx.hasNoFileFlag() and not fmtCtx[].pb.isNil:
      discard avio_closep(addr fmtCtx[].pb)
    avformat_free_context(fmtCtx)
    result = err(headerRet.error)
    return

  result = ok(Mp4VideoWriter(
    fmtCtx: fmtCtx,
    stream: stream,
    path: path,
    encoderTimeBase: streamInfo.timeBase,
    nextPts: 0,
    headerWritten: true,
    trailerWritten: false,
    closed: false
  ))

# -----------------------------------------------------------------------------
# --- finish
# -----------------------------------------------------------------------------

proc finish*(writer: Mp4VideoWriter): FFmpegResult[void] =
  if writer.isNil:
    result = ok()
    return

  if writer.closed:
    result = ok()
    return

  if writer.fmtCtx.isNil:
    writer.closed = true
    result = ok()
    return

  if writer.headerWritten and not writer.trailerWritten:
    let trailerRet = okAv(av_write_trailer(writer.fmtCtx), "av_write_trailer")
    if trailerRet.isErr:
      writer.closeIo()
      writer.freeContext()
      writer.closed = true
      result = err(trailerRet.error)
      return

    writer.trailerWritten = true

  writer.closeIo()
  writer.freeContext()
  writer.closed = true
  result = ok()

# -----------------------------------------------------------------------------
# --- close
# -----------------------------------------------------------------------------

proc close*(writer: Mp4VideoWriter) =
  if writer.isNil:
    return

  discard writer.finish()

# =============================================================================
# === Packet writing
# =============================================================================

# -----------------------------------------------------------------------------
# --- writePacket
# -----------------------------------------------------------------------------

proc writePacket*(writer: Mp4VideoWriter; read: EncodedPacketRead): FFmpegResult[void] =
  let openRet = writer.requireOpen()
  if openRet.isErr:
    result = err(openRet.error)
    return

  if not read.hasPacket:
    result = ok()
    return

  let packetRet = read.rawPacket()
  if packetRet.isErr:
    result = err(packetRet.error)
    return

  let packet = packetRet.value
  if packet.isNil:
    result = fail[void]("Mp4VideoWriter.writePacket", "Encoded packet is nil")
    return

  if packet[].pts == avNoPtsValue:
    packet[].pts = writer.nextPts

  if packet[].dts == avNoPtsValue:
    packet[].dts = packet[].pts

  if packet[].duration <= 0:
    packet[].duration = 1

  writer.nextPts = packet[].pts + packet[].duration
  packet[].stream_index = writer.stream[].index
  av_packet_rescale_ts(
    packet,
    writer.encoderTimeBase.toAVRational(),
    writer.stream[].time_base
  )

  let writeRet = okAv(
    av_interleaved_write_frame(writer.fmtCtx, packet),
    "av_interleaved_write_frame"
  )
  if writeRet.isErr:
    result = err(writeRet.error)
    return

  result = ok()

# -----------------------------------------------------------------------------
# --- writePacket
# -----------------------------------------------------------------------------

proc writePacket*(writer: Mp4VideoWriter; view: EncodedPacketView): FFmpegResult[void] =
  ## Write one encoded packet view.
  ##
  ## This is intended for packet data owned outside FFmpeg, such as a packet copied
  ## into an event-recording ring buffer. The view.data memory only has to remain
  ## valid for the duration of this call.
  let openRet = writer.requireOpen()
  if openRet.isErr:
    result = err(openRet.error)
    return

  var packet = av_packet_alloc()
  if packet.isNil:
    result = fail[void]("av_packet_alloc", "allocation failed")
    return

  let prepareRet = writer.preparePacketViewForWriting(packet, view)
  if prepareRet.isErr:
    av_packet_free(addr packet)
    result = err(prepareRet.error)
    return

  let writeRet = okAv(
    av_interleaved_write_frame(writer.fmtCtx, packet),
    "av_interleaved_write_frame"
  )
  if writeRet.isErr:
    av_packet_free(addr packet)
    result = err(writeRet.error)
    return

  av_packet_free(addr packet)
  result = ok()

