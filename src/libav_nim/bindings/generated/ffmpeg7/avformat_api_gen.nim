# Generated split from ffmpeg_lowlevel_gen.nim.
# Source: ffmpeg_lowlevel_gen(1).nim
# Do not edit manually unless this file is intentionally vendored.

proc avio_find_protocol_name*(url: cstring): cstring {.cdecl,
    importc: "avio_find_protocol_name".}
proc avio_check*(url: cstring; flags: cint): cint {.cdecl, importc: "avio_check".}
proc avio_open_dir*(s: ptr ptr AVIODirContext; url: cstring;
                    options: ptr ptr AVDictionary): cint {.cdecl,
    importc: "avio_open_dir".}
proc avio_read_dir*(s: ptr AVIODirContext; next: ptr ptr AVIODirEntry): cint {.
    cdecl, importc: "avio_read_dir".}
proc avio_close_dir*(s: ptr ptr AVIODirContext): cint {.cdecl,
    importc: "avio_close_dir".}
proc avio_free_directory_entry*(entry: ptr ptr AVIODirEntry): void {.cdecl,
    importc: "avio_free_directory_entry".}
proc avio_alloc_context*(buffer: ptr uint8; buffer_size: cint; write_flag: cint;
                         opaque: pointer; read_packet: proc (a0: pointer;
    a1: ptr uint8; a2: cint): cint {.cdecl.}; write_packet: proc (a0: pointer;
    a1: ptr uint8; a2: cint): cint {.cdecl.}; seek: proc (a0: pointer;
    a1: int64; a2: cint): int64 {.cdecl.}): ptr AVIOContext {.cdecl,
    importc: "avio_alloc_context".}
proc avio_context_free*(s: ptr ptr AVIOContext): void {.cdecl,
    importc: "avio_context_free".}
proc avio_w8*(s: ptr AVIOContext; b: cint): void {.cdecl, importc: "avio_w8".}
proc avio_write*(s: ptr AVIOContext; buf: ptr uint8; size: cint): void {.cdecl,
    importc: "avio_write".}
proc avio_wl64*(s: ptr AVIOContext; val: uint64): void {.cdecl,
    importc: "avio_wl64".}
proc avio_wb64*(s: ptr AVIOContext; val: uint64): void {.cdecl,
    importc: "avio_wb64".}
proc avio_wl32*(s: ptr AVIOContext; val: cuint): void {.cdecl,
    importc: "avio_wl32".}
proc avio_wb32*(s: ptr AVIOContext; val: cuint): void {.cdecl,
    importc: "avio_wb32".}
proc avio_wl24*(s: ptr AVIOContext; val: cuint): void {.cdecl,
    importc: "avio_wl24".}
proc avio_wb24*(s: ptr AVIOContext; val: cuint): void {.cdecl,
    importc: "avio_wb24".}
proc avio_wl16*(s: ptr AVIOContext; val: cuint): void {.cdecl,
    importc: "avio_wl16".}
proc avio_wb16*(s: ptr AVIOContext; val: cuint): void {.cdecl,
    importc: "avio_wb16".}
proc avio_put_str*(s: ptr AVIOContext; str: cstring): cint {.cdecl,
    importc: "avio_put_str".}
proc avio_put_str16le*(s: ptr AVIOContext; str: cstring): cint {.cdecl,
    importc: "avio_put_str16le".}
proc avio_put_str16be*(s: ptr AVIOContext; str: cstring): cint {.cdecl,
    importc: "avio_put_str16be".}
proc avio_write_marker*(s: ptr AVIOContext; time: int64;
                        type_arg: enum_AVIODataMarkerType): void {.cdecl,
    importc: "avio_write_marker".}
proc avio_seek*(s: ptr AVIOContext; offset: int64; whence: cint): int64 {.cdecl,
    importc: "avio_seek".}
proc avio_skip*(s: ptr AVIOContext; offset: int64): int64 {.cdecl,
    importc: "avio_skip".}
proc avio_size*(s: ptr AVIOContext): int64 {.cdecl, importc: "avio_size".}
proc avio_feof*(s: ptr AVIOContext): cint {.cdecl, importc: "avio_feof".}
proc avio_vprintf*(s: ptr AVIOContext; fmt: cstring): cint {.cdecl, varargs,
    importc: "avio_vprintf".}
proc avio_printf*(s: ptr AVIOContext; fmt: cstring): cint {.cdecl, varargs,
    importc: "avio_printf".}
proc avio_print_string_array*(s: ptr AVIOContext;
                              strings: ptr UncheckedArray[cstring]): void {.
    cdecl, importc: "avio_print_string_array".}
proc avio_flush*(s: ptr AVIOContext): void {.cdecl, importc: "avio_flush".}
proc avio_read*(s: ptr AVIOContext; buf: ptr uint8; size: cint): cint {.cdecl,
    importc: "avio_read".}
proc avio_read_partial*(s: ptr AVIOContext; buf: ptr uint8; size: cint): cint {.
    cdecl, importc: "avio_read_partial".}
proc avio_r8*(s: ptr AVIOContext): cint {.cdecl, importc: "avio_r8".}
proc avio_rl16*(s: ptr AVIOContext): cuint {.cdecl, importc: "avio_rl16".}
proc avio_rl24*(s: ptr AVIOContext): cuint {.cdecl, importc: "avio_rl24".}
proc avio_rl32*(s: ptr AVIOContext): cuint {.cdecl, importc: "avio_rl32".}
proc avio_rl64*(s: ptr AVIOContext): uint64 {.cdecl, importc: "avio_rl64".}
proc avio_rb16*(s: ptr AVIOContext): cuint {.cdecl, importc: "avio_rb16".}
proc avio_rb24*(s: ptr AVIOContext): cuint {.cdecl, importc: "avio_rb24".}
proc avio_rb32*(s: ptr AVIOContext): cuint {.cdecl, importc: "avio_rb32".}
proc avio_rb64*(s: ptr AVIOContext): uint64 {.cdecl, importc: "avio_rb64".}
proc avio_get_str*(pb: ptr AVIOContext; maxlen: cint; buf: cstring; buflen: cint): cint {.
    cdecl, importc: "avio_get_str".}
proc avio_get_str16le*(pb: ptr AVIOContext; maxlen: cint; buf: cstring;
                       buflen: cint): cint {.cdecl, importc: "avio_get_str16le".}
proc avio_get_str16be*(pb: ptr AVIOContext; maxlen: cint; buf: cstring;
                       buflen: cint): cint {.cdecl, importc: "avio_get_str16be".}
proc avio_open*(s: ptr ptr AVIOContext; url: cstring; flags: cint): cint {.
    cdecl, importc: "avio_open".}
proc avio_open2*(s: ptr ptr AVIOContext; url: cstring; flags: cint;
                 int_cb: ptr AVIOInterruptCB; options: ptr ptr AVDictionary): cint {.
    cdecl, importc: "avio_open2".}
proc avio_close*(s: ptr AVIOContext): cint {.cdecl, importc: "avio_close".}
proc avio_closep*(s: ptr ptr AVIOContext): cint {.cdecl, importc: "avio_closep".}
proc avio_open_dyn_buf*(s: ptr ptr AVIOContext): cint {.cdecl,
    importc: "avio_open_dyn_buf".}
proc avio_get_dyn_buf*(s: ptr AVIOContext; pbuffer: ptr ptr uint8): cint {.
    cdecl, importc: "avio_get_dyn_buf".}
proc avio_close_dyn_buf*(s: ptr AVIOContext; pbuffer: ptr ptr uint8): cint {.
    cdecl, importc: "avio_close_dyn_buf".}
proc avio_enum_protocols*(opaque: ptr pointer; output: cint): cstring {.cdecl,
    importc: "avio_enum_protocols".}
proc avio_protocol_get_class*(name: cstring): ptr AVClass {.cdecl,
    importc: "avio_protocol_get_class".}
proc avio_pause*(h: ptr AVIOContext; pause: cint): cint {.cdecl,
    importc: "avio_pause".}
proc avio_seek_time*(h: ptr AVIOContext; stream_index: cint; timestamp: int64;
                     flags: cint): int64 {.cdecl, importc: "avio_seek_time".}
proc avio_read_to_bprint*(h: ptr AVIOContext; pb: ptr struct_AVBPrint;
                          max_size: csize_t): cint {.cdecl,
    importc: "avio_read_to_bprint".}
proc avio_accept*(s: ptr AVIOContext; c: ptr ptr AVIOContext): cint {.cdecl,
    importc: "avio_accept".}
proc avio_handshake*(c: ptr AVIOContext): cint {.cdecl,
    importc: "avio_handshake".}
proc av_get_packet*(s: ptr AVIOContext; pkt: ptr AVPacket; size: cint): cint {.
    cdecl, importc: "av_get_packet".}
proc av_append_packet*(s: ptr AVIOContext; pkt: ptr AVPacket; size: cint): cint {.
    cdecl, importc: "av_append_packet".}
proc av_disposition_from_string*(disp: cstring): cint {.cdecl,
    importc: "av_disposition_from_string".}
proc av_disposition_to_string*(disposition: cint): cstring {.cdecl,
    importc: "av_disposition_to_string".}
proc av_stream_get_parser*(s: ptr AVStream): ptr struct_AVCodecParserContext {.
    cdecl, importc: "av_stream_get_parser".}
proc av_format_inject_global_side_data*(s: ptr AVFormatContext): void {.cdecl,
    importc: "av_format_inject_global_side_data".}
proc av_fmt_ctx_get_duration_estimation_method*(ctx: ptr AVFormatContext): enum_AVDurationEstimationMethod {.
    cdecl, importc: "av_fmt_ctx_get_duration_estimation_method".}
proc avformat_version*(): cuint {.cdecl, importc: "avformat_version".}
proc avformat_configuration*(): cstring {.cdecl,
    importc: "avformat_configuration".}
proc avformat_license*(): cstring {.cdecl, importc: "avformat_license".}
proc avformat_network_init*(): cint {.cdecl, importc: "avformat_network_init".}
proc avformat_network_deinit*(): cint {.cdecl,
                                        importc: "avformat_network_deinit".}
proc av_muxer_iterate*(opaque: ptr pointer): ptr AVOutputFormat {.cdecl,
    importc: "av_muxer_iterate".}
proc av_demuxer_iterate*(opaque: ptr pointer): ptr AVInputFormat {.cdecl,
    importc: "av_demuxer_iterate".}
proc avformat_alloc_context*(): ptr AVFormatContext {.cdecl,
    importc: "avformat_alloc_context".}
proc avformat_free_context*(s: ptr AVFormatContext): void {.cdecl,
    importc: "avformat_free_context".}
proc avformat_get_class*(): ptr AVClass {.cdecl, importc: "avformat_get_class".}
proc av_stream_get_class*(): ptr AVClass {.cdecl, importc: "av_stream_get_class".}
proc av_stream_group_get_class*(): ptr AVClass {.cdecl,
    importc: "av_stream_group_get_class".}
proc avformat_stream_group_name*(type_arg: enum_AVStreamGroupParamsType): cstring {.
    cdecl, importc: "avformat_stream_group_name".}
proc avformat_stream_group_create*(s: ptr AVFormatContext;
                                   type_arg: enum_AVStreamGroupParamsType;
                                   options: ptr ptr AVDictionary): ptr AVStreamGroup {.
    cdecl, importc: "avformat_stream_group_create".}
proc avformat_new_stream*(s: ptr AVFormatContext; c: ptr struct_AVCodec): ptr AVStream {.
    cdecl, importc: "avformat_new_stream".}
proc avformat_stream_group_add_stream*(stg: ptr AVStreamGroup; st: ptr AVStream): cint {.
    cdecl, importc: "avformat_stream_group_add_stream".}
proc av_stream_add_side_data*(st: ptr AVStream;
                              type_arg: enum_AVPacketSideDataType;
                              data: ptr uint8; size: csize_t): cint {.cdecl,
    importc: "av_stream_add_side_data".}
proc av_stream_new_side_data*(stream: ptr AVStream;
                              type_arg: enum_AVPacketSideDataType; size: csize_t): ptr uint8 {.
    cdecl, importc: "av_stream_new_side_data".}
proc av_stream_get_side_data*(stream: ptr AVStream;
                              type_arg: enum_AVPacketSideDataType;
                              size: ptr csize_t): ptr uint8 {.cdecl,
    importc: "av_stream_get_side_data".}
proc av_new_program*(s: ptr AVFormatContext; id: cint): ptr AVProgram {.cdecl,
    importc: "av_new_program".}
proc avformat_alloc_output_context2*(ctx: ptr ptr AVFormatContext;
                                     oformat: ptr AVOutputFormat;
                                     format_name: cstring; filename: cstring): cint {.
    cdecl, importc: "avformat_alloc_output_context2".}
proc av_find_input_format*(short_name: cstring): ptr AVInputFormat {.cdecl,
    importc: "av_find_input_format".}
proc av_probe_input_format*(pd: ptr AVProbeData; is_opened: cint): ptr AVInputFormat {.
    cdecl, importc: "av_probe_input_format".}
proc av_probe_input_format2*(pd: ptr AVProbeData; is_opened: cint;
                             score_max: ptr cint): ptr AVInputFormat {.cdecl,
    importc: "av_probe_input_format2".}
proc av_probe_input_format3*(pd: ptr AVProbeData; is_opened: cint;
                             score_ret: ptr cint): ptr AVInputFormat {.cdecl,
    importc: "av_probe_input_format3".}
proc av_probe_input_buffer2*(pb: ptr AVIOContext; fmt: ptr ptr AVInputFormat;
                             url: cstring; logctx: pointer; offset: cuint;
                             max_probe_size: cuint): cint {.cdecl,
    importc: "av_probe_input_buffer2".}
proc av_probe_input_buffer*(pb: ptr AVIOContext; fmt: ptr ptr AVInputFormat;
                            url: cstring; logctx: pointer; offset: cuint;
                            max_probe_size: cuint): cint {.cdecl,
    importc: "av_probe_input_buffer".}
proc avformat_open_input*(ps: ptr ptr AVFormatContext; url: cstring;
                          fmt: ptr AVInputFormat; options: ptr ptr AVDictionary): cint {.
    cdecl, importc: "avformat_open_input".}
proc avformat_find_stream_info*(ic: ptr AVFormatContext;
                                options: ptr ptr AVDictionary): cint {.cdecl,
    importc: "avformat_find_stream_info".}
proc av_find_program_from_stream*(ic: ptr AVFormatContext; last: ptr AVProgram;
                                  s: cint): ptr AVProgram {.cdecl,
    importc: "av_find_program_from_stream".}
proc av_program_add_stream_index*(ac: ptr AVFormatContext; progid: cint;
                                  idx: cuint): void {.cdecl,
    importc: "av_program_add_stream_index".}
proc av_find_best_stream*(ic: ptr AVFormatContext; type_arg: enum_AVMediaType;
                          wanted_stream_nb: cint; related_stream: cint;
                          decoder_ret: ptr ptr struct_AVCodec; flags: cint): cint {.
    cdecl, importc: "av_find_best_stream".}
proc av_read_frame*(s: ptr AVFormatContext; pkt: ptr AVPacket): cint {.cdecl,
    importc: "av_read_frame".}
proc av_seek_frame*(s: ptr AVFormatContext; stream_index: cint;
                    timestamp: int64; flags: cint): cint {.cdecl,
    importc: "av_seek_frame".}
proc avformat_seek_file*(s: ptr AVFormatContext; stream_index: cint;
                         min_ts: int64; ts: int64; max_ts: int64; flags: cint): cint {.
    cdecl, importc: "avformat_seek_file".}
proc avformat_flush*(s: ptr AVFormatContext): cint {.cdecl,
    importc: "avformat_flush".}
proc av_read_play*(s: ptr AVFormatContext): cint {.cdecl,
    importc: "av_read_play".}
proc av_read_pause*(s: ptr AVFormatContext): cint {.cdecl,
    importc: "av_read_pause".}
proc avformat_close_input*(s: ptr ptr AVFormatContext): void {.cdecl,
    importc: "avformat_close_input".}
proc avformat_write_header*(s: ptr AVFormatContext;
                            options: ptr ptr AVDictionary): cint {.cdecl,
    importc: "avformat_write_header".}
proc avformat_init_output*(s: ptr AVFormatContext; options: ptr ptr AVDictionary): cint {.
    cdecl, importc: "avformat_init_output".}
proc av_write_frame*(s: ptr AVFormatContext; pkt: ptr AVPacket): cint {.cdecl,
    importc: "av_write_frame".}
proc av_interleaved_write_frame*(s: ptr AVFormatContext; pkt: ptr AVPacket): cint {.
    cdecl, importc: "av_interleaved_write_frame".}
proc av_write_uncoded_frame*(s: ptr AVFormatContext; stream_index: cint;
                             frame: ptr struct_AVFrame): cint {.cdecl,
    importc: "av_write_uncoded_frame".}
proc av_interleaved_write_uncoded_frame*(s: ptr AVFormatContext;
    stream_index: cint; frame: ptr struct_AVFrame): cint {.cdecl,
    importc: "av_interleaved_write_uncoded_frame".}
proc av_write_uncoded_frame_query*(s: ptr AVFormatContext; stream_index: cint): cint {.
    cdecl, importc: "av_write_uncoded_frame_query".}
proc av_write_trailer*(s: ptr AVFormatContext): cint {.cdecl,
    importc: "av_write_trailer".}
proc av_guess_format*(short_name: cstring; filename: cstring; mime_type: cstring): ptr AVOutputFormat {.
    cdecl, importc: "av_guess_format".}
proc av_guess_codec*(fmt: ptr AVOutputFormat; short_name: cstring;
                     filename: cstring; mime_type: cstring;
                     type_arg: enum_AVMediaType): enum_AVCodecID {.cdecl,
    importc: "av_guess_codec".}
proc av_get_output_timestamp*(s: ptr struct_AVFormatContext; stream: cint;
                              dts: ptr int64; wall: ptr int64): cint {.cdecl,
    importc: "av_get_output_timestamp".}
proc av_hex_dump*(f: ptr FILE; buf: ptr uint8; size: cint): void {.cdecl,
    importc: "av_hex_dump".}
proc av_hex_dump_log*(avcl: pointer; level: cint; buf: ptr uint8; size: cint): void {.
    cdecl, importc: "av_hex_dump_log".}
proc av_pkt_dump2*(f: ptr FILE; pkt: ptr AVPacket; dump_payload: cint;
                   st: ptr AVStream): void {.cdecl, importc: "av_pkt_dump2".}
proc av_pkt_dump_log2*(avcl: pointer; level: cint; pkt: ptr AVPacket;
                       dump_payload: cint; st: ptr AVStream): void {.cdecl,
    importc: "av_pkt_dump_log2".}
proc av_codec_get_id*(tags: ptr ptr struct_AVCodecTag; tag: cuint): enum_AVCodecID {.
    cdecl, importc: "av_codec_get_id".}
proc av_codec_get_tag*(tags: ptr ptr struct_AVCodecTag; id: enum_AVCodecID): cuint {.
    cdecl, importc: "av_codec_get_tag".}
proc av_codec_get_tag2*(tags: ptr ptr struct_AVCodecTag; id: enum_AVCodecID;
                        tag: ptr cuint): cint {.cdecl,
    importc: "av_codec_get_tag2".}
proc av_find_default_stream_index*(s: ptr AVFormatContext): cint {.cdecl,
    importc: "av_find_default_stream_index".}
proc av_index_search_timestamp*(st: ptr AVStream; timestamp: int64; flags: cint): cint {.
    cdecl, importc: "av_index_search_timestamp".}
proc avformat_index_get_entries_count*(st: ptr AVStream): cint {.cdecl,
    importc: "avformat_index_get_entries_count".}
proc avformat_index_get_entry*(st: ptr AVStream; idx: cint): ptr AVIndexEntry {.
    cdecl, importc: "avformat_index_get_entry".}
proc avformat_index_get_entry_from_timestamp*(st: ptr AVStream;
    wanted_timestamp: int64; flags: cint): ptr AVIndexEntry {.cdecl,
    importc: "avformat_index_get_entry_from_timestamp".}
proc av_add_index_entry*(st: ptr AVStream; pos: int64; timestamp: int64;
                         size: cint; distance: cint; flags: cint): cint {.cdecl,
    importc: "av_add_index_entry".}
proc av_url_split*(proto: cstring; proto_size: cint; authorization: cstring;
                   authorization_size: cint; hostname: cstring;
                   hostname_size: cint; port_ptr: ptr cint; path: cstring;
                   path_size: cint; url: cstring): void {.cdecl,
    importc: "av_url_split".}
proc av_dump_format*(ic: ptr AVFormatContext; index: cint; url: cstring;
                     is_output: cint): void {.cdecl, importc: "av_dump_format".}
proc av_get_frame_filename2*(buf: cstring; buf_size: cint; path: cstring;
                             number: cint; flags: cint): cint {.cdecl,
    importc: "av_get_frame_filename2".}
proc av_get_frame_filename*(buf: cstring; buf_size: cint; path: cstring;
                            number: cint): cint {.cdecl,
    importc: "av_get_frame_filename".}
proc av_filename_number_test*(filename: cstring): cint {.cdecl,
    importc: "av_filename_number_test".}
proc av_sdp_create*(ac: ptr UncheckedArray[ptr AVFormatContext]; n_files: cint;
                    buf: cstring; size: cint): cint {.cdecl,
    importc: "av_sdp_create".}
proc av_match_ext*(filename: cstring; extensions: cstring): cint {.cdecl,
    importc: "av_match_ext".}
proc avformat_query_codec*(ofmt: ptr AVOutputFormat; codec_id: enum_AVCodecID;
                           std_compliance: cint): cint {.cdecl,
    importc: "avformat_query_codec".}
proc avformat_get_riff_video_tags*(): ptr struct_AVCodecTag {.cdecl,
    importc: "avformat_get_riff_video_tags".}
proc avformat_get_riff_audio_tags*(): ptr struct_AVCodecTag {.cdecl,
    importc: "avformat_get_riff_audio_tags".}
proc avformat_get_mov_video_tags*(): ptr struct_AVCodecTag {.cdecl,
    importc: "avformat_get_mov_video_tags".}
proc avformat_get_mov_audio_tags*(): ptr struct_AVCodecTag {.cdecl,
    importc: "avformat_get_mov_audio_tags".}
proc av_guess_sample_aspect_ratio*(format: ptr AVFormatContext;
                                   stream: ptr AVStream;
                                   frame: ptr struct_AVFrame): AVRational {.
    cdecl, importc: "av_guess_sample_aspect_ratio".}
proc av_guess_frame_rate*(ctx: ptr AVFormatContext; stream: ptr AVStream;
                          frame: ptr struct_AVFrame): AVRational {.cdecl,
    importc: "av_guess_frame_rate".}
proc avformat_match_stream_specifier*(s: ptr AVFormatContext; st: ptr AVStream;
                                      spec: cstring): cint {.cdecl,
    importc: "avformat_match_stream_specifier".}
proc avformat_queue_attached_pictures*(s: ptr AVFormatContext): cint {.cdecl,
    importc: "avformat_queue_attached_pictures".}
proc avformat_transfer_internal_stream_timing_info*(ofmt: ptr AVOutputFormat;
    ost: ptr AVStream; ist: ptr AVStream; copy_tb: enum_AVTimebaseSource): cint {.
    cdecl, importc: "avformat_transfer_internal_stream_timing_info".}
proc av_stream_get_codec_timebase*(st: ptr AVStream): AVRational {.cdecl,
    importc: "av_stream_get_codec_timebase".}
