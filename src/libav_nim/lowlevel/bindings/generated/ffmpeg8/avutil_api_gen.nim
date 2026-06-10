# Auto-split from ffmpeg_lowlevel_gen(2).nim.
# Source: Alpine / ffmpeg-wave5 FFmpeg 8.1.1 generated binding.
#
# Do not edit manually unless regenerating/splitting is intentionally avoided.

proc avutil_version*(): cuint {.cdecl, importc: "avutil_version".}

proc av_version_info*(): cstring {.cdecl, importc: "av_version_info".}

proc avutil_configuration*(): cstring {.cdecl, importc: "avutil_configuration".}

proc avutil_license*(): cstring {.cdecl, importc: "avutil_license".}

proc av_get_media_type_string*(media_type: enum_AVMediaType): cstring {.cdecl,
    importc: "av_get_media_type_string".}

proc av_get_picture_type_char*(pict_type: enum_AVPictureType): cschar {.cdecl,
    importc: "av_get_picture_type_char".}

proc av_strerror*(errnum: cint; errbuf: cstring; errbuf_size: csize_t): cint {.
    cdecl, importc: "av_strerror".}

proc av_malloc*(size: csize_t): pointer {.cdecl, importc: "av_malloc".}

proc av_mallocz*(size: csize_t): pointer {.cdecl, importc: "av_mallocz".}

proc av_malloc_array*(nmemb: csize_t; size: csize_t): pointer {.cdecl,
    importc: "av_malloc_array".}

proc av_calloc*(nmemb: csize_t; size: csize_t): pointer {.cdecl,
    importc: "av_calloc".}

proc av_realloc*(ptr_arg: pointer; size: csize_t): pointer {.cdecl,
    importc: "av_realloc".}

proc av_reallocp*(ptr_arg: pointer; size: csize_t): cint {.cdecl,
    importc: "av_reallocp".}

proc av_realloc_f*(ptr_arg: pointer; nelem: csize_t; elsize: csize_t): pointer {.
    cdecl, importc: "av_realloc_f".}

proc av_realloc_array*(ptr_arg: pointer; nmemb: csize_t; size: csize_t): pointer {.
    cdecl, importc: "av_realloc_array".}

proc av_reallocp_array*(ptr_arg: pointer; nmemb: csize_t; size: csize_t): cint {.
    cdecl, importc: "av_reallocp_array".}

proc av_fast_realloc*(ptr_arg: pointer; size: ptr cuint; min_size: csize_t): pointer {.
    cdecl, importc: "av_fast_realloc".}

proc av_fast_malloc*(ptr_arg: pointer; size: ptr cuint; min_size: csize_t): void {.
    cdecl, importc: "av_fast_malloc".}

proc av_fast_mallocz*(ptr_arg: pointer; size: ptr cuint; min_size: csize_t): void {.
    cdecl, importc: "av_fast_mallocz".}

proc av_free*(ptr_arg: pointer): void {.cdecl, importc: "av_free".}

proc av_freep*(ptr_arg: pointer): void {.cdecl, importc: "av_freep".}

proc av_strdup*(s: cstring): cstring {.cdecl, importc: "av_strdup".}

proc av_strndup*(s: cstring; len: csize_t): cstring {.cdecl,
    importc: "av_strndup".}

proc av_memdup*(p: pointer; size: csize_t): pointer {.cdecl,
    importc: "av_memdup".}

proc av_memcpy_backptr*(dst: ptr uint8; back: cint; cnt: cint): void {.cdecl,
    importc: "av_memcpy_backptr".}

proc av_dynarray_add*(tab_ptr: pointer; nb_ptr: ptr cint; elem: pointer): void {.
    cdecl, importc: "av_dynarray_add".}

proc av_dynarray_add_nofree*(tab_ptr: pointer; nb_ptr: ptr cint; elem: pointer): cint {.
    cdecl, importc: "av_dynarray_add_nofree".}

proc av_dynarray2_add*(tab_ptr: ptr pointer; nb_ptr: ptr cint;
                       elem_size: csize_t; elem_data: ptr uint8): pointer {.
    cdecl, importc: "av_dynarray2_add".}

proc av_size_mult*(a: csize_t; b: csize_t; r: ptr csize_t): cint {.cdecl,
    importc: "av_size_mult".}

proc av_max_alloc*(max: csize_t): void {.cdecl, importc: "av_max_alloc".}

proc av_log2*(v: cuint): cint {.cdecl, importc: "av_log2".}

proc av_log2_16bit*(v: cuint): cint {.cdecl, importc: "av_log2_16bit".}

proc av_reduce*(dst_num: ptr cint; dst_den: ptr cint; num: int64; den: int64;
                max: int64): cint {.cdecl, importc: "av_reduce".}

proc av_mul_q*(b: AVRational; c: AVRational): AVRational {.cdecl,
    importc: "av_mul_q".}

proc av_div_q*(b: AVRational; c: AVRational): AVRational {.cdecl,
    importc: "av_div_q".}

proc av_add_q*(b: AVRational; c: AVRational): AVRational {.cdecl,
    importc: "av_add_q".}

proc av_sub_q*(b: AVRational; c: AVRational): AVRational {.cdecl,
    importc: "av_sub_q".}

proc av_d2q*(d: cdouble; max: cint): AVRational {.cdecl, importc: "av_d2q".}

proc av_nearer_q*(q: AVRational; q1: AVRational; q2: AVRational): cint {.cdecl,
    importc: "av_nearer_q".}

proc av_q2intfloat*(q: AVRational): uint32 {.cdecl, importc: "av_q2intfloat".}

proc av_gcd_q*(a: AVRational; b: AVRational; max_den: cint; def: AVRational): AVRational {.
    cdecl, importc: "av_gcd_q".}

proc av_gcd*(a: int64; b: int64): int64 {.cdecl, importc: "av_gcd".}

proc av_rescale*(a: int64; b: int64; c: int64): int64 {.cdecl,
    importc: "av_rescale".}

proc av_rescale_rnd*(a: int64; b: int64; c: int64; rnd: enum_AVRounding): int64 {.
    cdecl, importc: "av_rescale_rnd".}

proc av_rescale_q*(a: int64; bq: AVRational; cq: AVRational): int64 {.cdecl,
    importc: "av_rescale_q".}

proc av_rescale_q_rnd*(a: int64; bq: AVRational; cq: AVRational;
                       rnd: enum_AVRounding): int64 {.cdecl,
    importc: "av_rescale_q_rnd".}

proc av_compare_ts*(ts_a: int64; tb_a: AVRational; ts_b: int64; tb_b: AVRational): cint {.
    cdecl, importc: "av_compare_ts".}

proc av_compare_mod*(a: uint64; b: uint64; mod_arg: uint64): int64 {.cdecl,
    importc: "av_compare_mod".}

proc av_rescale_delta*(in_tb: AVRational; in_ts: int64; fs_tb: AVRational;
                       duration: cint; last: ptr int64; out_tb: AVRational): int64 {.
    cdecl, importc: "av_rescale_delta".}

proc av_add_stable*(ts_tb: AVRational; ts: int64; inc_tb: AVRational; inc: int64): int64 {.
    cdecl, importc: "av_add_stable".}

proc av_bessel_i0*(x: cdouble): cdouble {.cdecl, importc: "av_bessel_i0".}

proc av_log*(avcl: pointer; level: cint; fmt: cstring): void {.cdecl, varargs,
    importc: "av_log".}

proc av_log_once*(avcl: pointer; initial_level: cint; subsequent_level: cint;
                  state: ptr cint; fmt: cstring): void {.cdecl, varargs,
    importc: "av_log_once".}

proc av_vlog*(avcl: pointer; level: cint; fmt: cstring): void {.cdecl, varargs,
    importc: "av_vlog".}

proc av_log_get_level*(): cint {.cdecl, importc: "av_log_get_level".}

proc av_log_set_level*(level: cint): void {.cdecl, importc: "av_log_set_level".}

proc av_log_set_callback*(callback: proc (a0: pointer; a1: cint; a2: cstring): void {.
    cdecl, varargs.}): void {.cdecl, importc: "av_log_set_callback".}

proc av_log_default_callback*(avcl: pointer; level: cint; fmt: cstring): void {.
    cdecl, varargs, importc: "av_log_default_callback".}

proc av_default_item_name*(ctx: pointer): cstring {.cdecl,
    importc: "av_default_item_name".}

proc av_default_get_category*(ptr_arg: pointer): AVClassCategory {.cdecl,
    importc: "av_default_get_category".}

proc av_log_format_line*(ptr_arg: pointer; level: cint; fmt: cstring;
                         vl: va_list; line: cstring; line_size: cint;
                         print_prefix: ptr cint): void {.cdecl,
    importc: "av_log_format_line".}

proc av_log_format_line2*(ptr_arg: pointer; level: cint; fmt: cstring;
                          vl: va_list; line: cstring; line_size: cint;
                          print_prefix: ptr cint): cint {.cdecl,
    importc: "av_log_format_line2".}

proc av_log_set_flags*(arg: cint): void {.cdecl, importc: "av_log_set_flags".}

proc av_log_get_flags*(): cint {.cdecl, importc: "av_log_get_flags".}

proc av_int_list_length_for_size*(elsize: cuint; list: pointer; term: uint64): cuint {.
    cdecl, importc: "av_int_list_length_for_size".}

proc av_get_time_base_q*(): AVRational {.cdecl, importc: "av_get_time_base_q".}

proc av_fourcc_make_string*(buf: cstring; fourcc: uint32): cstring {.cdecl,
    importc: "av_fourcc_make_string".}

proc av_buffer_alloc*(size: csize_t): ptr AVBufferRef {.cdecl,
    importc: "av_buffer_alloc".}

proc av_buffer_allocz*(size: csize_t): ptr AVBufferRef {.cdecl,
    importc: "av_buffer_allocz".}

proc av_buffer_create*(data: ptr uint8; size: csize_t;
                       free: proc (a0: pointer; a1: ptr uint8): void {.cdecl.};
                       opaque: pointer; flags: cint): ptr AVBufferRef {.cdecl,
    importc: "av_buffer_create".}

proc av_buffer_default_free*(opaque: pointer; data: ptr uint8): void {.cdecl,
    importc: "av_buffer_default_free".}

proc av_buffer_ref*(buf: ptr AVBufferRef): ptr AVBufferRef {.cdecl,
    importc: "av_buffer_ref".}

proc av_buffer_unref*(buf: ptr ptr AVBufferRef): void {.cdecl,
    importc: "av_buffer_unref".}

proc av_buffer_is_writable*(buf: ptr AVBufferRef): cint {.cdecl,
    importc: "av_buffer_is_writable".}

proc av_buffer_get_opaque*(buf: ptr AVBufferRef): pointer {.cdecl,
    importc: "av_buffer_get_opaque".}

proc av_buffer_get_ref_count*(buf: ptr AVBufferRef): cint {.cdecl,
    importc: "av_buffer_get_ref_count".}

proc av_buffer_make_writable*(buf: ptr ptr AVBufferRef): cint {.cdecl,
    importc: "av_buffer_make_writable".}

proc av_buffer_realloc*(buf: ptr ptr AVBufferRef; size: csize_t): cint {.cdecl,
    importc: "av_buffer_realloc".}

proc av_buffer_replace*(dst: ptr ptr AVBufferRef; src: ptr AVBufferRef): cint {.
    cdecl, importc: "av_buffer_replace".}

proc av_buffer_pool_init*(size: csize_t;
                          alloc: proc (a0: csize_t): ptr AVBufferRef {.cdecl.}): ptr AVBufferPool {.
    cdecl, importc: "av_buffer_pool_init".}

proc av_buffer_pool_init2*(size: csize_t; opaque: pointer; alloc: proc (
    a0: pointer; a1: csize_t): ptr AVBufferRef {.cdecl.};
                           pool_free: proc (a0: pointer): void {.cdecl.}): ptr AVBufferPool {.
    cdecl, importc: "av_buffer_pool_init2".}

proc av_buffer_pool_uninit*(pool: ptr ptr AVBufferPool): void {.cdecl,
    importc: "av_buffer_pool_uninit".}

proc av_buffer_pool_get*(pool: ptr AVBufferPool): ptr AVBufferRef {.cdecl,
    importc: "av_buffer_pool_get".}

proc av_buffer_pool_buffer_get_opaque*(ref_arg: ptr AVBufferRef): pointer {.
    cdecl, importc: "av_buffer_pool_buffer_get_opaque".}

proc av_channel_name*(buf: cstring; buf_size: csize_t; channel: enum_AVChannel): cint {.
    cdecl, importc: "av_channel_name".}

proc av_channel_name_bprint*(bp: ptr struct_AVBPrint; channel_id: enum_AVChannel): void {.
    cdecl, importc: "av_channel_name_bprint".}

proc av_channel_description*(buf: cstring; buf_size: csize_t;
                             channel: enum_AVChannel): cint {.cdecl,
    importc: "av_channel_description".}

proc av_channel_description_bprint*(bp: ptr struct_AVBPrint;
                                    channel_id: enum_AVChannel): void {.cdecl,
    importc: "av_channel_description_bprint".}

proc av_channel_from_string*(name: cstring): enum_AVChannel {.cdecl,
    importc: "av_channel_from_string".}

proc av_channel_layout_custom_init*(channel_layout: ptr AVChannelLayout;
                                    nb_channels: cint): cint {.cdecl,
    importc: "av_channel_layout_custom_init".}

proc av_channel_layout_from_mask*(channel_layout: ptr AVChannelLayout;
                                  mask: uint64): cint {.cdecl,
    importc: "av_channel_layout_from_mask".}

proc av_channel_layout_from_string*(channel_layout: ptr AVChannelLayout;
                                    str: cstring): cint {.cdecl,
    importc: "av_channel_layout_from_string".}

proc av_channel_layout_default*(ch_layout: ptr AVChannelLayout;
                                nb_channels: cint): void {.cdecl,
    importc: "av_channel_layout_default".}

proc av_channel_layout_standard*(opaque: ptr pointer): ptr AVChannelLayout {.
    cdecl, importc: "av_channel_layout_standard".}

proc av_channel_layout_uninit*(channel_layout: ptr AVChannelLayout): void {.
    cdecl, importc: "av_channel_layout_uninit".}

proc av_channel_layout_copy*(dst: ptr AVChannelLayout; src: ptr AVChannelLayout): cint {.
    cdecl, importc: "av_channel_layout_copy".}

proc av_channel_layout_describe*(channel_layout: ptr AVChannelLayout;
                                 buf: cstring; buf_size: csize_t): cint {.cdecl,
    importc: "av_channel_layout_describe".}

proc av_channel_layout_describe_bprint*(channel_layout: ptr AVChannelLayout;
                                        bp: ptr struct_AVBPrint): cint {.cdecl,
    importc: "av_channel_layout_describe_bprint".}

proc av_channel_layout_channel_from_index*(channel_layout: ptr AVChannelLayout;
    idx: cuint): enum_AVChannel {.cdecl, importc: "av_channel_layout_channel_from_index".}

proc av_channel_layout_index_from_channel*(channel_layout: ptr AVChannelLayout;
    channel: enum_AVChannel): cint {.cdecl, importc: "av_channel_layout_index_from_channel".}

proc av_channel_layout_index_from_string*(channel_layout: ptr AVChannelLayout;
    name: cstring): cint {.cdecl, importc: "av_channel_layout_index_from_string".}

proc av_channel_layout_channel_from_string*(channel_layout: ptr AVChannelLayout;
    name: cstring): enum_AVChannel {.cdecl, importc: "av_channel_layout_channel_from_string".}

proc av_channel_layout_subset*(channel_layout: ptr AVChannelLayout; mask: uint64): uint64 {.
    cdecl, importc: "av_channel_layout_subset".}

proc av_channel_layout_check*(channel_layout: ptr AVChannelLayout): cint {.
    cdecl, importc: "av_channel_layout_check".}

proc av_channel_layout_compare*(chl: ptr AVChannelLayout;
                                chl1: ptr AVChannelLayout): cint {.cdecl,
    importc: "av_channel_layout_compare".}

proc av_channel_layout_ambisonic_order*(channel_layout: ptr AVChannelLayout): cint {.
    cdecl, importc: "av_channel_layout_ambisonic_order".}

proc av_channel_layout_retype*(channel_layout: ptr AVChannelLayout;
                               order: enum_AVChannelOrder; flags: cint): cint {.
    cdecl, importc: "av_channel_layout_retype".}

proc av_dict_get*(m: ptr AVDictionary; key: cstring;
                  prev: ptr AVDictionaryEntry; flags: cint): ptr AVDictionaryEntry {.
    cdecl, importc: "av_dict_get".}

proc av_dict_iterate*(m: ptr AVDictionary; prev: ptr AVDictionaryEntry): ptr AVDictionaryEntry {.
    cdecl, importc: "av_dict_iterate".}

proc av_dict_count*(m: ptr AVDictionary): cint {.cdecl, importc: "av_dict_count".}

proc av_dict_set*(pm: ptr ptr AVDictionary; key: cstring; value: cstring;
                  flags: cint): cint {.cdecl, importc: "av_dict_set".}

proc av_dict_set_int*(pm: ptr ptr AVDictionary; key: cstring; value: int64;
                      flags: cint): cint {.cdecl, importc: "av_dict_set_int".}

proc av_dict_parse_string*(pm: ptr ptr AVDictionary; str: cstring;
                           key_val_sep: cstring; pairs_sep: cstring; flags: cint): cint {.
    cdecl, importc: "av_dict_parse_string".}

proc av_dict_copy*(dst: ptr ptr AVDictionary; src: ptr AVDictionary; flags: cint): cint {.
    cdecl, importc: "av_dict_copy".}

proc av_dict_free*(m: ptr ptr AVDictionary): void {.cdecl,
    importc: "av_dict_free".}

proc av_dict_get_string*(m: ptr AVDictionary; buffer: ptr cstring;
                         key_val_sep: cschar; pairs_sep: cschar): cint {.cdecl,
    importc: "av_dict_get_string".}

proc av_get_sample_fmt_name*(sample_fmt: enum_AVSampleFormat): cstring {.cdecl,
    importc: "av_get_sample_fmt_name".}

proc av_get_sample_fmt*(name: cstring): enum_AVSampleFormat {.cdecl,
    importc: "av_get_sample_fmt".}

proc av_get_alt_sample_fmt*(sample_fmt: enum_AVSampleFormat; planar: cint): enum_AVSampleFormat {.
    cdecl, importc: "av_get_alt_sample_fmt".}

proc av_get_packed_sample_fmt*(sample_fmt: enum_AVSampleFormat): enum_AVSampleFormat {.
    cdecl, importc: "av_get_packed_sample_fmt".}

proc av_get_planar_sample_fmt*(sample_fmt: enum_AVSampleFormat): enum_AVSampleFormat {.
    cdecl, importc: "av_get_planar_sample_fmt".}

proc av_get_sample_fmt_string*(buf: cstring; buf_size: cint;
                               sample_fmt: enum_AVSampleFormat): cstring {.
    cdecl, importc: "av_get_sample_fmt_string".}

proc av_get_bytes_per_sample*(sample_fmt: enum_AVSampleFormat): cint {.cdecl,
    importc: "av_get_bytes_per_sample".}

proc av_sample_fmt_is_planar*(sample_fmt: enum_AVSampleFormat): cint {.cdecl,
    importc: "av_sample_fmt_is_planar".}

proc av_samples_get_buffer_size*(linesize: ptr cint; nb_channels: cint;
                                 nb_samples: cint;
                                 sample_fmt: enum_AVSampleFormat; align: cint): cint {.
    cdecl, importc: "av_samples_get_buffer_size".}

proc av_samples_fill_arrays*(audio_data: ptr ptr uint8; linesize: ptr cint;
                             buf: ptr uint8; nb_channels: cint;
                             nb_samples: cint; sample_fmt: enum_AVSampleFormat;
                             align: cint): cint {.cdecl,
    importc: "av_samples_fill_arrays".}

proc av_samples_alloc*(audio_data: ptr ptr uint8; linesize: ptr cint;
                       nb_channels: cint; nb_samples: cint;
                       sample_fmt: enum_AVSampleFormat; align: cint): cint {.
    cdecl, importc: "av_samples_alloc".}

proc av_samples_alloc_array_and_samples*(audio_data: ptr ptr ptr uint8;
    linesize: ptr cint; nb_channels: cint; nb_samples: cint;
    sample_fmt: enum_AVSampleFormat; align: cint): cint {.cdecl,
    importc: "av_samples_alloc_array_and_samples".}

proc av_samples_copy*(dst: ptr ptr uint8; src: ptr ptr uint8; dst_offset: cint;
                      src_offset: cint; nb_samples: cint; nb_channels: cint;
                      sample_fmt: enum_AVSampleFormat): cint {.cdecl,
    importc: "av_samples_copy".}

proc av_samples_set_silence*(audio_data: ptr ptr uint8; offset: cint;
                             nb_samples: cint; nb_channels: cint;
                             sample_fmt: enum_AVSampleFormat): cint {.cdecl,
    importc: "av_samples_set_silence".}

proc av_frame_alloc*(): ptr AVFrame {.cdecl, importc: "av_frame_alloc".}

proc av_frame_free*(frame: ptr ptr AVFrame): void {.cdecl,
    importc: "av_frame_free".}

proc av_frame_ref*(dst: ptr AVFrame; src: ptr AVFrame): cint {.cdecl,
    importc: "av_frame_ref".}

proc av_frame_replace*(dst: ptr AVFrame; src: ptr AVFrame): cint {.cdecl,
    importc: "av_frame_replace".}

proc av_frame_clone*(src: ptr AVFrame): ptr AVFrame {.cdecl,
    importc: "av_frame_clone".}

proc av_frame_unref*(frame: ptr AVFrame): void {.cdecl,
    importc: "av_frame_unref".}

proc av_frame_move_ref*(dst: ptr AVFrame; src: ptr AVFrame): void {.cdecl,
    importc: "av_frame_move_ref".}

proc av_frame_get_buffer*(frame: ptr AVFrame; align: cint): cint {.cdecl,
    importc: "av_frame_get_buffer".}

proc av_frame_is_writable*(frame: ptr AVFrame): cint {.cdecl,
    importc: "av_frame_is_writable".}

proc av_frame_make_writable*(frame: ptr AVFrame): cint {.cdecl,
    importc: "av_frame_make_writable".}

proc av_frame_copy*(dst: ptr AVFrame; src: ptr AVFrame): cint {.cdecl,
    importc: "av_frame_copy".}

proc av_frame_copy_props*(dst: ptr AVFrame; src: ptr AVFrame): cint {.cdecl,
    importc: "av_frame_copy_props".}

proc av_frame_get_plane_buffer*(frame: ptr AVFrame; plane: cint): ptr AVBufferRef {.
    cdecl, importc: "av_frame_get_plane_buffer".}

proc av_frame_new_side_data*(frame: ptr AVFrame;
                             type_arg: enum_AVFrameSideDataType; size: csize_t): ptr AVFrameSideData {.
    cdecl, importc: "av_frame_new_side_data".}

proc av_frame_new_side_data_from_buf*(frame: ptr AVFrame;
                                      type_arg: enum_AVFrameSideDataType;
                                      buf: ptr AVBufferRef): ptr AVFrameSideData {.
    cdecl, importc: "av_frame_new_side_data_from_buf".}

proc av_frame_get_side_data*(frame: ptr AVFrame;
                             type_arg: enum_AVFrameSideDataType): ptr AVFrameSideData {.
    cdecl, importc: "av_frame_get_side_data".}

proc av_frame_remove_side_data*(frame: ptr AVFrame;
                                type_arg: enum_AVFrameSideDataType): void {.
    cdecl, importc: "av_frame_remove_side_data".}

proc av_frame_apply_cropping*(frame: ptr AVFrame; flags: cint): cint {.cdecl,
    importc: "av_frame_apply_cropping".}

proc av_frame_side_data_name*(type_arg: enum_AVFrameSideDataType): cstring {.
    cdecl, importc: "av_frame_side_data_name".}

proc av_frame_side_data_desc*(type_arg: enum_AVFrameSideDataType): ptr AVSideDataDescriptor {.
    cdecl, importc: "av_frame_side_data_desc".}

proc av_frame_side_data_free*(sd: ptr ptr ptr AVFrameSideData; nb_sd: ptr cint): void {.
    cdecl, importc: "av_frame_side_data_free".}

proc av_frame_side_data_new*(sd: ptr ptr ptr AVFrameSideData; nb_sd: ptr cint;
                             type_arg: enum_AVFrameSideDataType; size: csize_t;
                             flags: cuint): ptr AVFrameSideData {.cdecl,
    importc: "av_frame_side_data_new".}

proc av_frame_side_data_add*(sd: ptr ptr ptr AVFrameSideData; nb_sd: ptr cint;
                             type_arg: enum_AVFrameSideDataType;
                             buf: ptr ptr AVBufferRef; flags: cuint): ptr AVFrameSideData {.
    cdecl, importc: "av_frame_side_data_add".}

proc av_frame_side_data_clone*(sd: ptr ptr ptr AVFrameSideData; nb_sd: ptr cint;
                               src: ptr AVFrameSideData; flags: cuint): cint {.
    cdecl, importc: "av_frame_side_data_clone".}

proc av_frame_side_data_get_c*(sd: ptr ptr AVFrameSideData; nb_sd: cint;
                               type_arg: enum_AVFrameSideDataType): ptr AVFrameSideData {.
    cdecl, importc: "av_frame_side_data_get_c".}

proc av_frame_side_data_remove*(sd: ptr ptr ptr AVFrameSideData;
                                nb_sd: ptr cint;
                                type_arg: enum_AVFrameSideDataType): void {.
    cdecl, importc: "av_frame_side_data_remove".}

proc av_frame_side_data_remove_by_props*(sd: ptr ptr ptr AVFrameSideData;
    nb_sd: ptr cint; props: cint): void {.cdecl,
    importc: "av_frame_side_data_remove_by_props".}

proc av_opt_set_defaults*(s: pointer): void {.cdecl,
    importc: "av_opt_set_defaults".}

proc av_opt_set_defaults2*(s: pointer; mask: cint; flags: cint): void {.cdecl,
    importc: "av_opt_set_defaults2".}

proc av_opt_free*(obj: pointer): void {.cdecl, importc: "av_opt_free".}

proc av_opt_next*(obj: pointer; prev: ptr AVOption): ptr AVOption {.cdecl,
    importc: "av_opt_next".}

proc av_opt_child_next*(obj: pointer; prev: pointer): pointer {.cdecl,
    importc: "av_opt_child_next".}

proc av_opt_child_class_iterate*(parent: ptr AVClass; iter: ptr pointer): ptr AVClass {.
    cdecl, importc: "av_opt_child_class_iterate".}

proc av_opt_find*(obj: pointer; name: cstring; unit: cstring; opt_flags: cint;
                  search_flags: cint): ptr AVOption {.cdecl,
    importc: "av_opt_find".}

proc av_opt_find2*(obj: pointer; name: cstring; unit: cstring; opt_flags: cint;
                   search_flags: cint; target_obj: ptr pointer): ptr AVOption {.
    cdecl, importc: "av_opt_find2".}

proc av_opt_show2*(obj: pointer; av_log_obj: pointer; req_flags: cint;
                   rej_flags: cint): cint {.cdecl, importc: "av_opt_show2".}

proc av_opt_get_key_value*(ropts: ptr cstring; key_val_sep: cstring;
                           pairs_sep: cstring; flags: cuint; rkey: ptr cstring;
                           rval: ptr cstring): cint {.cdecl,
    importc: "av_opt_get_key_value".}

proc av_set_options_string*(ctx: pointer; opts: cstring; key_val_sep: cstring;
                            pairs_sep: cstring): cint {.cdecl,
    importc: "av_set_options_string".}

proc av_opt_set_from_string*(ctx: pointer; opts: cstring;
                             shorthand: ptr cstring; key_val_sep: cstring;
                             pairs_sep: cstring): cint {.cdecl,
    importc: "av_opt_set_from_string".}

proc av_opt_set_dict*(obj: pointer; options: ptr ptr struct_AVDictionary): cint {.
    cdecl, importc: "av_opt_set_dict".}

proc av_opt_set_dict2*(obj: pointer; options: ptr ptr struct_AVDictionary;
                       search_flags: cint): cint {.cdecl,
    importc: "av_opt_set_dict2".}

proc av_opt_copy*(dest: pointer; src: pointer): cint {.cdecl,
    importc: "av_opt_copy".}

proc av_opt_set*(obj: pointer; name: cstring; val: cstring; search_flags: cint): cint {.
    cdecl, importc: "av_opt_set".}

proc av_opt_set_int*(obj: pointer; name: cstring; val: int64; search_flags: cint): cint {.
    cdecl, importc: "av_opt_set_int".}

proc av_opt_set_double*(obj: pointer; name: cstring; val: cdouble;
                        search_flags: cint): cint {.cdecl,
    importc: "av_opt_set_double".}

proc av_opt_set_q*(obj: pointer; name: cstring; val: AVRational;
                   search_flags: cint): cint {.cdecl, importc: "av_opt_set_q".}

proc av_opt_set_bin*(obj: pointer; name: cstring; val: ptr uint8; size: cint;
                     search_flags: cint): cint {.cdecl,
    importc: "av_opt_set_bin".}

proc av_opt_set_image_size*(obj: pointer; name: cstring; w: cint; h: cint;
                            search_flags: cint): cint {.cdecl,
    importc: "av_opt_set_image_size".}

proc av_opt_set_pixel_fmt*(obj: pointer; name: cstring; fmt: enum_AVPixelFormat;
                           search_flags: cint): cint {.cdecl,
    importc: "av_opt_set_pixel_fmt".}

proc av_opt_set_sample_fmt*(obj: pointer; name: cstring;
                            fmt: enum_AVSampleFormat; search_flags: cint): cint {.
    cdecl, importc: "av_opt_set_sample_fmt".}

proc av_opt_set_video_rate*(obj: pointer; name: cstring; val: AVRational;
                            search_flags: cint): cint {.cdecl,
    importc: "av_opt_set_video_rate".}

proc av_opt_set_chlayout*(obj: pointer; name: cstring;
                          layout: ptr AVChannelLayout; search_flags: cint): cint {.
    cdecl, importc: "av_opt_set_chlayout".}

proc av_opt_set_dict_val*(obj: pointer; name: cstring; val: ptr AVDictionary;
                          search_flags: cint): cint {.cdecl,
    importc: "av_opt_set_dict_val".}

proc av_opt_set_array*(obj: pointer; name: cstring; search_flags: cint;
                       start_elem: cuint; nb_elems: cuint;
                       val_type: enum_AVOptionType; val: pointer): cint {.cdecl,
    importc: "av_opt_set_array".}

proc av_opt_get*(obj: pointer; name: cstring; search_flags: cint;
                 out_val: ptr ptr uint8): cint {.cdecl, importc: "av_opt_get".}

proc av_opt_get_int*(obj: pointer; name: cstring; search_flags: cint;
                     out_val: ptr int64): cint {.cdecl,
    importc: "av_opt_get_int".}

proc av_opt_get_double*(obj: pointer; name: cstring; search_flags: cint;
                        out_val: ptr cdouble): cint {.cdecl,
    importc: "av_opt_get_double".}

proc av_opt_get_q*(obj: pointer; name: cstring; search_flags: cint;
                   out_val: ptr AVRational): cint {.cdecl,
    importc: "av_opt_get_q".}

proc av_opt_get_image_size*(obj: pointer; name: cstring; search_flags: cint;
                            w_out: ptr cint; h_out: ptr cint): cint {.cdecl,
    importc: "av_opt_get_image_size".}

proc av_opt_get_pixel_fmt*(obj: pointer; name: cstring; search_flags: cint;
                           out_fmt: ptr enum_AVPixelFormat): cint {.cdecl,
    importc: "av_opt_get_pixel_fmt".}

proc av_opt_get_sample_fmt*(obj: pointer; name: cstring; search_flags: cint;
                            out_fmt: ptr enum_AVSampleFormat): cint {.cdecl,
    importc: "av_opt_get_sample_fmt".}

proc av_opt_get_video_rate*(obj: pointer; name: cstring; search_flags: cint;
                            out_val: ptr AVRational): cint {.cdecl,
    importc: "av_opt_get_video_rate".}

proc av_opt_get_chlayout*(obj: pointer; name: cstring; search_flags: cint;
                          layout: ptr AVChannelLayout): cint {.cdecl,
    importc: "av_opt_get_chlayout".}

proc av_opt_get_dict_val*(obj: pointer; name: cstring; search_flags: cint;
                          out_val: ptr ptr AVDictionary): cint {.cdecl,
    importc: "av_opt_get_dict_val".}

proc av_opt_get_array_size*(obj: pointer; name: cstring; search_flags: cint;
                            out_val: ptr cuint): cint {.cdecl,
    importc: "av_opt_get_array_size".}

proc av_opt_get_array*(obj: pointer; name: cstring; search_flags: cint;
                       start_elem: cuint; nb_elems: cuint;
                       out_type: enum_AVOptionType; out_val: pointer): cint {.
    cdecl, importc: "av_opt_get_array".}

proc av_opt_eval_flags*(obj: pointer; o: ptr AVOption; val: cstring;
                        flags_out: ptr cint): cint {.cdecl,
    importc: "av_opt_eval_flags".}

proc av_opt_eval_int*(obj: pointer; o: ptr AVOption; val: cstring;
                      int_out: ptr cint): cint {.cdecl,
    importc: "av_opt_eval_int".}

proc av_opt_eval_uint*(obj: pointer; o: ptr AVOption; val: cstring;
                       uint_out: ptr cuint): cint {.cdecl,
    importc: "av_opt_eval_uint".}

proc av_opt_eval_int64*(obj: pointer; o: ptr AVOption; val: cstring;
                        int64_out: ptr int64): cint {.cdecl,
    importc: "av_opt_eval_int64".}

proc av_opt_eval_float*(obj: pointer; o: ptr AVOption; val: cstring;
                        float_out: ptr cfloat): cint {.cdecl,
    importc: "av_opt_eval_float".}

proc av_opt_eval_double*(obj: pointer; o: ptr AVOption; val: cstring;
                         double_out: ptr cdouble): cint {.cdecl,
    importc: "av_opt_eval_double".}

proc av_opt_eval_q*(obj: pointer; o: ptr AVOption; val: cstring;
                    q_out: ptr AVRational): cint {.cdecl,
    importc: "av_opt_eval_q".}

proc av_opt_ptr*(avclass: ptr AVClass; obj: pointer; name: cstring): pointer {.
    cdecl, importc: "av_opt_ptr".}

proc av_opt_is_set_to_default*(obj: pointer; o: ptr AVOption): cint {.cdecl,
    importc: "av_opt_is_set_to_default".}

proc av_opt_is_set_to_default_by_name*(obj: pointer; name: cstring;
                                       search_flags: cint): cint {.cdecl,
    importc: "av_opt_is_set_to_default_by_name".}

proc av_opt_flag_is_set*(obj: pointer; field_name: cstring; flag_name: cstring): cint {.
    cdecl, importc: "av_opt_flag_is_set".}

proc av_opt_serialize*(obj: pointer; opt_flags: cint; flags: cint;
                       buffer: ptr cstring; key_val_sep: cschar;
                       pairs_sep: cschar): cint {.cdecl,
    importc: "av_opt_serialize".}

proc av_opt_freep_ranges*(ranges: ptr ptr AVOptionRanges): void {.cdecl,
    importc: "av_opt_freep_ranges".}

proc av_opt_query_ranges*(a0: ptr ptr AVOptionRanges; obj: pointer;
                          key: cstring; flags: cint): cint {.cdecl,
    importc: "av_opt_query_ranges".}

proc av_opt_query_ranges_default*(a0: ptr ptr AVOptionRanges; obj: pointer;
                                  key: cstring; flags: cint): cint {.cdecl,
    importc: "av_opt_query_ranges_default".}

proc av_hwdevice_find_type_by_name*(name: cstring): enum_AVHWDeviceType {.cdecl,
    importc: "av_hwdevice_find_type_by_name".}

proc av_hwdevice_get_type_name*(type_arg: enum_AVHWDeviceType): cstring {.cdecl,
    importc: "av_hwdevice_get_type_name".}

proc av_hwdevice_iterate_types*(prev: enum_AVHWDeviceType): enum_AVHWDeviceType {.
    cdecl, importc: "av_hwdevice_iterate_types".}

proc av_hwdevice_ctx_alloc*(type_arg: enum_AVHWDeviceType): ptr AVBufferRef {.
    cdecl, importc: "av_hwdevice_ctx_alloc".}

proc av_hwdevice_ctx_init*(ref_arg: ptr AVBufferRef): cint {.cdecl,
    importc: "av_hwdevice_ctx_init".}

proc av_hwdevice_ctx_create*(device_ctx: ptr ptr AVBufferRef;
                             type_arg: enum_AVHWDeviceType; device: cstring;
                             opts: ptr AVDictionary; flags: cint): cint {.cdecl,
    importc: "av_hwdevice_ctx_create".}

proc av_hwdevice_ctx_create_derived*(dst_ctx: ptr ptr AVBufferRef;
                                     type_arg: enum_AVHWDeviceType;
                                     src_ctx: ptr AVBufferRef; flags: cint): cint {.
    cdecl, importc: "av_hwdevice_ctx_create_derived".}

proc av_hwdevice_ctx_create_derived_opts*(dst_ctx: ptr ptr AVBufferRef;
    type_arg: enum_AVHWDeviceType; src_ctx: ptr AVBufferRef;
    options: ptr AVDictionary; flags: cint): cint {.cdecl,
    importc: "av_hwdevice_ctx_create_derived_opts".}

proc av_hwframe_ctx_alloc*(device_ctx: ptr AVBufferRef): ptr AVBufferRef {.
    cdecl, importc: "av_hwframe_ctx_alloc".}

proc av_hwframe_ctx_init*(ref_arg: ptr AVBufferRef): cint {.cdecl,
    importc: "av_hwframe_ctx_init".}

proc av_hwframe_get_buffer*(hwframe_ctx: ptr AVBufferRef; frame: ptr AVFrame;
                            flags: cint): cint {.cdecl,
    importc: "av_hwframe_get_buffer".}

proc av_hwframe_transfer_data*(dst: ptr AVFrame; src: ptr AVFrame; flags: cint): cint {.
    cdecl, importc: "av_hwframe_transfer_data".}

proc av_hwframe_transfer_get_formats*(hwframe_ctx: ptr AVBufferRef;
                                      dir: enum_AVHWFrameTransferDirection;
                                      formats: ptr ptr enum_AVPixelFormat;
                                      flags: cint): cint {.cdecl,
    importc: "av_hwframe_transfer_get_formats".}

proc av_hwdevice_hwconfig_alloc*(device_ctx: ptr AVBufferRef): pointer {.cdecl,
    importc: "av_hwdevice_hwconfig_alloc".}

proc av_hwdevice_get_hwframe_constraints*(ref_arg: ptr AVBufferRef;
    hwconfig: pointer): ptr AVHWFramesConstraints {.cdecl,
    importc: "av_hwdevice_get_hwframe_constraints".}

proc av_hwframe_constraints_free*(constraints: ptr ptr AVHWFramesConstraints): void {.
    cdecl, importc: "av_hwframe_constraints_free".}

proc av_hwframe_map*(dst: ptr AVFrame; src: ptr AVFrame; flags: cint): cint {.
    cdecl, importc: "av_hwframe_map".}

proc av_hwframe_ctx_create_derived*(derived_frame_ctx: ptr ptr AVBufferRef;
                                    format: enum_AVPixelFormat;
                                    derived_device_ctx: ptr AVBufferRef;
                                    source_frame_ctx: ptr AVBufferRef;
                                    flags: cint): cint {.cdecl,
    importc: "av_hwframe_ctx_create_derived".}

proc av_get_bits_per_sample*(codec_id: enum_AVCodecID): cint {.cdecl,
    importc: "av_get_bits_per_sample".}

proc av_get_exact_bits_per_sample*(codec_id: enum_AVCodecID): cint {.cdecl,
    importc: "av_get_exact_bits_per_sample".}

proc av_get_pcm_codec*(fmt: enum_AVSampleFormat; be: cint): enum_AVCodecID {.
    cdecl, importc: "av_get_pcm_codec".}

proc av_codec_iterate*(opaque: ptr pointer): ptr AVCodec {.cdecl,
    importc: "av_codec_iterate".}

proc av_codec_is_encoder*(codec: ptr AVCodec): cint {.cdecl,
    importc: "av_codec_is_encoder".}

proc av_codec_is_decoder*(codec: ptr AVCodec): cint {.cdecl,
    importc: "av_codec_is_decoder".}

proc av_get_profile_name*(codec: ptr AVCodec; profile: cint): cstring {.cdecl,
    importc: "av_get_profile_name".}

proc av_cpb_properties_alloc*(size: ptr csize_t): ptr AVCPBProperties {.cdecl,
    importc: "av_cpb_properties_alloc".}

proc av_init_packet*(pkt: ptr AVPacket): void {.cdecl, importc: "av_init_packet".}

proc av_container_fifo_alloc_avpacket*(flags: cuint): ptr struct_AVContainerFifo {.
    cdecl, importc: "av_container_fifo_alloc_avpacket".}

proc av_get_audio_frame_duration2*(par: ptr AVCodecParameters; frame_bytes: cint): cint {.
    cdecl, importc: "av_get_audio_frame_duration2".}

proc av_get_audio_frame_duration*(avctx: ptr AVCodecContext; frame_bytes: cint): cint {.
    cdecl, importc: "av_get_audio_frame_duration".}

proc av_disposition_from_string*(disp: cstring): cint {.cdecl,
    importc: "av_disposition_from_string".}

proc av_disposition_to_string*(disposition: cint): cstring {.cdecl,
    importc: "av_disposition_to_string".}

proc av_new_program*(s: ptr AVFormatContext; id: cint): ptr AVProgram {.cdecl,
    importc: "av_new_program".}

proc av_codec_get_id*(tags: ptr ptr struct_AVCodecTag; tag: cuint): enum_AVCodecID {.
    cdecl, importc: "av_codec_get_id".}

proc av_codec_get_tag*(tags: ptr ptr struct_AVCodecTag; id: enum_AVCodecID): cuint {.
    cdecl, importc: "av_codec_get_tag".}

proc av_codec_get_tag2*(tags: ptr ptr struct_AVCodecTag; id: enum_AVCodecID;
                        tag: ptr cuint): cint {.cdecl,
    importc: "av_codec_get_tag2".}

proc av_index_search_timestamp*(st: ptr AVStream; timestamp: int64; flags: cint): cint {.
    cdecl, importc: "av_index_search_timestamp".}

proc av_add_index_entry*(st: ptr AVStream; pos: int64; timestamp: int64;
                         size: cint; distance: cint; flags: cint): cint {.cdecl,
    importc: "av_add_index_entry".}

proc av_dump_format*(ic: ptr AVFormatContext; index: cint; url: cstring;
                     is_output: cint): void {.cdecl, importc: "av_dump_format".}

proc av_get_frame_filename2*(buf: cstring; buf_size: cint; path: cstring;
                             number: cint; flags: cint): cint {.cdecl,
    importc: "av_get_frame_filename2".}

proc av_get_frame_filename*(buf: cstring; buf_size: cint; path: cstring;
                            number: cint): cint {.cdecl,
    importc: "av_get_frame_filename".}

proc av_mime_codec_str*(par: ptr AVCodecParameters; frame_rate: AVRational;
                        out_arg: ptr struct_AVBPrint): cint {.cdecl,
    importc: "av_mime_codec_str".}
