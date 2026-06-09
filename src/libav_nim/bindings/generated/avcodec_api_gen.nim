# Generated split from ffmpeg_lowlevel_gen.nim.
# Source: ffmpeg_lowlevel_gen(1).nim
# Do not edit manually unless this file is intentionally vendored.

proc avcodec_get_type*(codec_id: enum_AVCodecID): enum_AVMediaType {.cdecl,
    importc: "avcodec_get_type".}
proc avcodec_get_name*(id: enum_AVCodecID): cstring {.cdecl,
    importc: "avcodec_get_name".}
proc av_get_bits_per_sample*(codec_id: enum_AVCodecID): cint {.cdecl,
    importc: "av_get_bits_per_sample".}
proc av_get_exact_bits_per_sample*(codec_id: enum_AVCodecID): cint {.cdecl,
    importc: "av_get_exact_bits_per_sample".}
proc avcodec_profile_name*(codec_id: enum_AVCodecID; profile: cint): cstring {.
    cdecl, importc: "avcodec_profile_name".}
proc av_get_pcm_codec*(fmt: enum_AVSampleFormat; be: cint): enum_AVCodecID {.
    cdecl, importc: "av_get_pcm_codec".}
proc av_codec_iterate*(opaque: ptr pointer): ptr AVCodec {.cdecl,
    importc: "av_codec_iterate".}
proc avcodec_find_decoder*(id: enum_AVCodecID): ptr AVCodec {.cdecl,
    importc: "avcodec_find_decoder".}
proc avcodec_find_decoder_by_name*(name: cstring): ptr AVCodec {.cdecl,
    importc: "avcodec_find_decoder_by_name".}
proc avcodec_find_encoder*(id: enum_AVCodecID): ptr AVCodec {.cdecl,
    importc: "avcodec_find_encoder".}
proc avcodec_find_encoder_by_name*(name: cstring): ptr AVCodec {.cdecl,
    importc: "avcodec_find_encoder_by_name".}
proc av_codec_is_encoder*(codec: ptr AVCodec): cint {.cdecl,
    importc: "av_codec_is_encoder".}
proc av_codec_is_decoder*(codec: ptr AVCodec): cint {.cdecl,
    importc: "av_codec_is_decoder".}
proc av_get_profile_name*(codec: ptr AVCodec; profile: cint): cstring {.cdecl,
    importc: "av_get_profile_name".}
proc avcodec_get_hw_config*(codec: ptr AVCodec; index: cint): ptr AVCodecHWConfig {.
    cdecl, importc: "avcodec_get_hw_config".}
proc av_cpb_properties_alloc*(size: ptr csize_t): ptr AVCPBProperties {.cdecl,
    importc: "av_cpb_properties_alloc".}
proc av_xiphlacing*(s: ptr uint8; v: cuint): cuint {.cdecl,
    importc: "av_xiphlacing".}
proc av_packet_side_data_new*(psd: ptr ptr AVPacketSideData; pnb_sd: ptr cint;
                              type_arg: enum_AVPacketSideDataType;
                              size: csize_t; flags: cint): ptr AVPacketSideData {.
    cdecl, importc: "av_packet_side_data_new".}
proc av_packet_side_data_add*(sd: ptr ptr AVPacketSideData; nb_sd: ptr cint;
                              type_arg: enum_AVPacketSideDataType;
                              data: pointer; size: csize_t; flags: cint): ptr AVPacketSideData {.
    cdecl, importc: "av_packet_side_data_add".}
proc av_packet_side_data_get*(sd: ptr AVPacketSideData; nb_sd: cint;
                              type_arg: enum_AVPacketSideDataType): ptr AVPacketSideData {.
    cdecl, importc: "av_packet_side_data_get".}
proc av_packet_side_data_remove*(sd: ptr AVPacketSideData; nb_sd: ptr cint;
                                 type_arg: enum_AVPacketSideDataType): void {.
    cdecl, importc: "av_packet_side_data_remove".}
proc av_packet_side_data_free*(sd: ptr ptr AVPacketSideData; nb_sd: ptr cint): void {.
    cdecl, importc: "av_packet_side_data_free".}
proc av_packet_side_data_name*(type_arg: enum_AVPacketSideDataType): cstring {.
    cdecl, importc: "av_packet_side_data_name".}
proc av_packet_alloc*(): ptr AVPacket {.cdecl, importc: "av_packet_alloc".}
proc av_packet_clone*(src: ptr AVPacket): ptr AVPacket {.cdecl,
    importc: "av_packet_clone".}
proc av_packet_free*(pkt: ptr ptr AVPacket): void {.cdecl,
    importc: "av_packet_free".}
proc av_init_packet*(pkt: ptr AVPacket): void {.cdecl, importc: "av_init_packet".}
proc av_new_packet*(pkt: ptr AVPacket; size: cint): cint {.cdecl,
    importc: "av_new_packet".}
proc av_shrink_packet*(pkt: ptr AVPacket; size: cint): void {.cdecl,
    importc: "av_shrink_packet".}
proc av_grow_packet*(pkt: ptr AVPacket; grow_by: cint): cint {.cdecl,
    importc: "av_grow_packet".}
proc av_packet_from_data*(pkt: ptr AVPacket; data: ptr uint8; size: cint): cint {.
    cdecl, importc: "av_packet_from_data".}
proc av_packet_new_side_data*(pkt: ptr AVPacket;
                              type_arg: enum_AVPacketSideDataType; size: csize_t): ptr uint8 {.
    cdecl, importc: "av_packet_new_side_data".}
proc av_packet_add_side_data*(pkt: ptr AVPacket;
                              type_arg: enum_AVPacketSideDataType;
                              data: ptr uint8; size: csize_t): cint {.cdecl,
    importc: "av_packet_add_side_data".}
proc av_packet_shrink_side_data*(pkt: ptr AVPacket;
                                 type_arg: enum_AVPacketSideDataType;
                                 size: csize_t): cint {.cdecl,
    importc: "av_packet_shrink_side_data".}
proc av_packet_get_side_data*(pkt: ptr AVPacket;
                              type_arg: enum_AVPacketSideDataType;
                              size: ptr csize_t): ptr uint8 {.cdecl,
    importc: "av_packet_get_side_data".}
proc av_packet_pack_dictionary*(dict: ptr AVDictionary; size: ptr csize_t): ptr uint8 {.
    cdecl, importc: "av_packet_pack_dictionary".}
proc av_packet_unpack_dictionary*(data: ptr uint8; size: csize_t;
                                  dict: ptr ptr AVDictionary): cint {.cdecl,
    importc: "av_packet_unpack_dictionary".}
proc av_packet_free_side_data*(pkt: ptr AVPacket): void {.cdecl,
    importc: "av_packet_free_side_data".}
proc av_packet_ref*(dst: ptr AVPacket; src: ptr AVPacket): cint {.cdecl,
    importc: "av_packet_ref".}
proc av_packet_unref*(pkt: ptr AVPacket): void {.cdecl,
    importc: "av_packet_unref".}
proc av_packet_move_ref*(dst: ptr AVPacket; src: ptr AVPacket): void {.cdecl,
    importc: "av_packet_move_ref".}
proc av_packet_copy_props*(dst: ptr AVPacket; src: ptr AVPacket): cint {.cdecl,
    importc: "av_packet_copy_props".}
proc av_packet_make_refcounted*(pkt: ptr AVPacket): cint {.cdecl,
    importc: "av_packet_make_refcounted".}
proc av_packet_make_writable*(pkt: ptr AVPacket): cint {.cdecl,
    importc: "av_packet_make_writable".}
proc av_packet_rescale_ts*(pkt: ptr AVPacket; tb_src: AVRational;
                           tb_dst: AVRational): void {.cdecl,
    importc: "av_packet_rescale_ts".}
proc avcodec_descriptor_get*(id: enum_AVCodecID): ptr AVCodecDescriptor {.cdecl,
    importc: "avcodec_descriptor_get".}
proc avcodec_descriptor_next*(prev: ptr AVCodecDescriptor): ptr AVCodecDescriptor {.
    cdecl, importc: "avcodec_descriptor_next".}
proc avcodec_descriptor_get_by_name*(name: cstring): ptr AVCodecDescriptor {.
    cdecl, importc: "avcodec_descriptor_get_by_name".}
proc avcodec_parameters_alloc*(): ptr AVCodecParameters {.cdecl,
    importc: "avcodec_parameters_alloc".}
proc avcodec_parameters_free*(par: ptr ptr AVCodecParameters): void {.cdecl,
    importc: "avcodec_parameters_free".}
proc avcodec_parameters_copy*(dst: ptr AVCodecParameters;
                              src: ptr AVCodecParameters): cint {.cdecl,
    importc: "avcodec_parameters_copy".}
proc av_get_audio_frame_duration2*(par: ptr AVCodecParameters; frame_bytes: cint): cint {.
    cdecl, importc: "av_get_audio_frame_duration2".}
proc avcodec_version*(): cuint {.cdecl, importc: "avcodec_version".}
proc avcodec_configuration*(): cstring {.cdecl, importc: "avcodec_configuration".}
proc avcodec_license*(): cstring {.cdecl, importc: "avcodec_license".}
proc avcodec_alloc_context3*(codec: ptr AVCodec): ptr AVCodecContext {.cdecl,
    importc: "avcodec_alloc_context3".}
proc avcodec_free_context*(avctx: ptr ptr AVCodecContext): void {.cdecl,
    importc: "avcodec_free_context".}
proc avcodec_get_class*(): ptr AVClass {.cdecl, importc: "avcodec_get_class".}
proc avcodec_get_subtitle_rect_class*(): ptr AVClass {.cdecl,
    importc: "avcodec_get_subtitle_rect_class".}
proc avcodec_parameters_from_context*(par: ptr struct_AVCodecParameters;
                                      codec: ptr AVCodecContext): cint {.cdecl,
    importc: "avcodec_parameters_from_context".}
proc avcodec_parameters_to_context*(codec: ptr AVCodecContext;
                                    par: ptr struct_AVCodecParameters): cint {.
    cdecl, importc: "avcodec_parameters_to_context".}
proc avcodec_open2*(avctx: ptr AVCodecContext; codec: ptr AVCodec;
                    options: ptr ptr AVDictionary): cint {.cdecl,
    importc: "avcodec_open2".}
proc avcodec_close*(avctx: ptr AVCodecContext): cint {.cdecl,
    importc: "avcodec_close".}
proc avsubtitle_free*(sub: ptr AVSubtitle): void {.cdecl,
    importc: "avsubtitle_free".}
proc avcodec_default_get_buffer2*(s: ptr AVCodecContext; frame: ptr AVFrame;
                                  flags: cint): cint {.cdecl,
    importc: "avcodec_default_get_buffer2".}
proc avcodec_default_get_encode_buffer*(s: ptr AVCodecContext;
                                        pkt: ptr AVPacket; flags: cint): cint {.
    cdecl, importc: "avcodec_default_get_encode_buffer".}
proc avcodec_align_dimensions*(s: ptr AVCodecContext; width: ptr cint;
                               height: ptr cint): void {.cdecl,
    importc: "avcodec_align_dimensions".}
proc avcodec_align_dimensions2*(s: ptr AVCodecContext; width: ptr cint;
                                height: ptr cint;
                                linesize_align: array[8'i64, cint]): void {.
    cdecl, importc: "avcodec_align_dimensions2".}
proc avcodec_decode_subtitle2*(avctx: ptr AVCodecContext; sub: ptr AVSubtitle;
                               got_sub_ptr: ptr cint; avpkt: ptr AVPacket): cint {.
    cdecl, importc: "avcodec_decode_subtitle2".}
proc avcodec_send_packet*(avctx: ptr AVCodecContext; avpkt: ptr AVPacket): cint {.
    cdecl, importc: "avcodec_send_packet".}
proc avcodec_receive_frame*(avctx: ptr AVCodecContext; frame: ptr AVFrame): cint {.
    cdecl, importc: "avcodec_receive_frame".}
proc avcodec_send_frame*(avctx: ptr AVCodecContext; frame: ptr AVFrame): cint {.
    cdecl, importc: "avcodec_send_frame".}
proc avcodec_receive_packet*(avctx: ptr AVCodecContext; avpkt: ptr AVPacket): cint {.
    cdecl, importc: "avcodec_receive_packet".}
proc avcodec_get_hw_frames_parameters*(avctx: ptr AVCodecContext;
                                       device_ref: ptr AVBufferRef;
                                       hw_pix_fmt: enum_AVPixelFormat;
                                       out_frames_ref: ptr ptr AVBufferRef): cint {.
    cdecl, importc: "avcodec_get_hw_frames_parameters".}
proc avcodec_get_supported_config*(avctx: ptr AVCodecContext;
                                   codec: ptr AVCodec;
                                   config: enum_AVCodecConfig; flags: cuint;
                                   out_configs: ptr pointer;
                                   out_num_configs: ptr cint): cint {.cdecl,
    importc: "avcodec_get_supported_config".}
proc av_parser_iterate*(opaque: ptr pointer): ptr AVCodecParser {.cdecl,
    importc: "av_parser_iterate".}
proc av_parser_init*(codec_id: cint): ptr AVCodecParserContext {.cdecl,
    importc: "av_parser_init".}
proc av_parser_parse2*(s: ptr AVCodecParserContext; avctx: ptr AVCodecContext;
                       poutbuf: ptr ptr uint8; poutbuf_size: ptr cint;
                       buf: ptr uint8; buf_size: cint; pts: int64; dts: int64;
                       pos: int64): cint {.cdecl, importc: "av_parser_parse2".}
proc av_parser_close*(s: ptr AVCodecParserContext): void {.cdecl,
    importc: "av_parser_close".}
proc avcodec_encode_subtitle*(avctx: ptr AVCodecContext; buf: ptr uint8;
                              buf_size: cint; sub: ptr AVSubtitle): cint {.
    cdecl, importc: "avcodec_encode_subtitle".}
proc avcodec_pix_fmt_to_codec_tag*(pix_fmt: enum_AVPixelFormat): cuint {.cdecl,
    importc: "avcodec_pix_fmt_to_codec_tag".}
proc avcodec_find_best_pix_fmt_of_list*(pix_fmt_list: ptr enum_AVPixelFormat;
                                        src_pix_fmt: enum_AVPixelFormat;
                                        has_alpha: cint; loss_ptr: ptr cint): enum_AVPixelFormat {.
    cdecl, importc: "avcodec_find_best_pix_fmt_of_list".}
proc avcodec_default_get_format*(s: ptr struct_AVCodecContext;
                                 fmt: ptr enum_AVPixelFormat): enum_AVPixelFormat {.
    cdecl, importc: "avcodec_default_get_format".}
proc avcodec_string*(buf: cstring; buf_size: cint; enc: ptr AVCodecContext;
                     encode: cint): void {.cdecl, importc: "avcodec_string".}
proc avcodec_default_execute*(c: ptr AVCodecContext; func_arg: proc (
    a0: ptr AVCodecContext; a1: pointer): cint {.cdecl.}; arg: pointer;
                              ret: ptr cint; count: cint; size: cint): cint {.
    cdecl, importc: "avcodec_default_execute".}
proc avcodec_default_execute2*(c: ptr AVCodecContext; func_arg: proc (
    a0: ptr AVCodecContext; a1: pointer; a2: cint; a3: cint): cint {.cdecl.};
                               arg: pointer; ret: ptr cint; count: cint): cint {.
    cdecl, importc: "avcodec_default_execute2".}
proc avcodec_fill_audio_frame*(frame: ptr AVFrame; nb_channels: cint;
                               sample_fmt: enum_AVSampleFormat; buf: ptr uint8;
                               buf_size: cint; align: cint): cint {.cdecl,
    importc: "avcodec_fill_audio_frame".}
proc avcodec_flush_buffers*(avctx: ptr AVCodecContext): void {.cdecl,
    importc: "avcodec_flush_buffers".}
proc av_get_audio_frame_duration*(avctx: ptr AVCodecContext; frame_bytes: cint): cint {.
    cdecl, importc: "av_get_audio_frame_duration".}
proc av_fast_padded_malloc*(ptr_arg: pointer; size: ptr cuint; min_size: csize_t): void {.
    cdecl, importc: "av_fast_padded_malloc".}
proc av_fast_padded_mallocz*(ptr_arg: pointer; size: ptr cuint;
                             min_size: csize_t): void {.cdecl,
    importc: "av_fast_padded_mallocz".}
proc avcodec_is_open*(s: ptr AVCodecContext): cint {.cdecl,
    importc: "avcodec_is_open".}
