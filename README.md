# libav_nim

`libav_nim` is a small Nim wrapper around FFmpeg/libav for building video
decode, CPU processing, and encode pipelines.

The current focus is embedded Linux systems that expose hardware video codecs
through FFmpeg's `v4l2_m2m` codecs, especially TI AM67A / wave5 VPU devices.

## Status

This project is currently focused on a practical CPU-visible video pipeline:

1. decode HEVC/H.264 using `*_v4l2m2m`
2. copy the decoded I420/YU12 frame into CPU-owned memory
3. convert I420 to RGBX
4. draw overlays or text on the RGBX frame
5. convert RGBX directly to padded NV12
6. encode H.264 using `h264_v4l2m2m`
7. write MP4 output

This keeps the video frame available to normal userspace code while still using
the hardware decoder and encoder.

## Features

- FFmpeg/libav based demux, decode, encode, and MP4 writing
- FFmpeg 8 bindings by default
- FFmpeg 7 bindings when built with `-d:ffmpeg7`
- CPU-owned I420 and RGBX frame buffers
- RGBX overlay/drawing path
- NV12 encoder input support
- Padded NV12 storage height for hardware encoders that require aligned luma
  storage
- Direct RGBX to padded NV12 conversion using `libyuv_nim`
- Stage timing test programs for measuring each pipeline step

## Why padded NV12?

On TI wave5 H.264 encoder, the YU12/yuv420p input path can produce shifted or
corrupted output for 1080p frames.

The encoder behaves correctly when using NV12 input, but the UV plane must be
placed after a 16-line aligned luma storage area.

For example, for a visible 1920x1080 frame:

- visible size: 1920x1080
- storage/coded height: 1088
- Y plane size used for UV offset: `1920 * 1088`
- UV plane starts after the padded Y plane

Without this padding, the encoded image can show chroma or plane offset
misalignment.

## Performance notes

Measured on AM67A / wave5 using a tuned FFmpeg/libavcodec build and a kernel
that allows V4L2 cache hints on the decoder capture queue:

- 1080p30 HEVC decode -> RGBX overlay -> H.264 encode: about 44 fps
- 720p30 HEVC decode -> RGBX overlay -> H.264 encode: about 87 fps

The important optimization is that the decoder capture buffers can be read by
the CPU through the non-coherent/cache-managed V4L2 MMAP path. Without that,
copying decoded 1080p frames from the decoder capture buffer can dominate the
pipeline.

The pipeline is intended to be practical for Full HD 30fps CPU-visible overlay
or preprocessing workloads.

## Dependencies

Required:

- Nim 2.2.x or later
- FFmpeg/libav development headers and libraries
- `libyuv_nim`
- `results`

Runtime libraries depend on the selected FFmpeg build. For the v4l2_m2m hardware
path, the system must expose suitable FFmpeg codecs such as:

- `hevc_v4l2m2m`
- `h264_v4l2m2m`

For hardware accelerated use, the target kernel and FFmpeg build must support
the relevant V4L2 mem2mem devices.

## FFmpeg binding selection

The default binding set is FFmpeg 8.

Build normally for FFmpeg 8:

    nim c tests/test_transcode_stage_timing_nv12_direct.nim

or explicitly:

    nim c -d:ffmpeg8 tests/test_transcode_stage_timing_nv12_direct.nim

Build with FFmpeg 7 bindings:

    nim c -d:ffmpeg7 tests/test_transcode_stage_timing_nv12_direct.nim

If both `ffmpeg7` and `ffmpeg8` are defined at the same time, the build should
fail. Only one binding version should be selected.

## Example: direct RGBX to padded NV12 transcode timing

Build and run the timing test:

    nim c -d:ffmpeg8 -r tests/test_transcode_stage_timing_nv12_direct.nim \
      input_hevc.mp4 \
      output_h264.mp4 \
      hevc_v4l2m2m \
      h264_v4l2m2m \
      30 \
      2000000 \
      0

Arguments:

1. input file
2. output file
3. decoder name
4. encoder name
5. output fps
6. output bitrate
7. maximum frames, or `0` for all frames

For H.264 input, use `h264_v4l2m2m` as the decoder.

## Important pipeline types

The main frame representations are:

- decoded I420/YU12 view from FFmpeg
- `OwnedI420Frame`
- `OwnedRGBXFrame`
- `WritableNV12FrameView`
- padded NV12 encoder input frame

The preferred overlay pipeline is:

    decoded I420/YU12
      -> OwnedI420Frame
      -> OwnedRGBXFrame
      -> overlay/drawing
      -> padded NV12 through direct RGBX -> NV12 conversion
      -> h264_v4l2m2m encoder

## libyuv_nim usage

`libav_nim` depends on `libyuv_nim` for color conversion.

The direct RGBX to NV12 path uses `ABGRToNV12`. In the current memory layout,
this matches the `OwnedRGBXFrame` byte order used by `libav_nim`.

The fallback or comparison path can use:

- RGBX -> I420
- I420 -> padded NV12

The direct RGBX -> padded NV12 path has been checked against the I420-based
path and produced identical encoded output in the current AM67A/wave5 tests.

## Hardware-specific notes

### TI AM67A / wave5

Known useful behavior:

- `hevc_v4l2m2m` decode to YU12/I420 works
- CPU copy from decoder capture buffers becomes fast when using cacheable
  non-coherent MMAP buffers
- `h264_v4l2m2m` YU12/yuv420p input can produce shifted output
- `h264_v4l2m2m` NV12 input works when the luma storage height is aligned to
  16 lines
- 1920x1080 should be encoded through a 1920x1088 padded NV12 buffer

### V4L2 cache hints

The best measured decoder copy performance was obtained with:

- kernel support for cache hints on the decoder capture queue
- FFmpeg/libavcodec requesting `V4L2_MEMORY_FLAG_NON_COHERENT` for the decoder
  capture queue

This is not necessarily enabled in stock kernels or stock FFmpeg builds.

## Development notes

The timing tests are intentionally verbose. They are used to separate:

- decoder open / first frame cost
- `readFrame`
- decoded frame copy
- I420 -> RGBX conversion
- overlay
- RGBX -> padded NV12 conversion
- encoder submission
- packet draining and writing

This makes it easier to see whether a change affects the CPU conversion path,
the hardware codec path, or only one-time initialization.

## Known limitations

- The current fast path is tuned around I420 decode, RGBX CPU drawing, and NV12
  encode.
- 1080p input may be encoded with a padded/coded height of 1088. Display/crop
  metadata handling may need further cleanup depending on the final product
  requirements.
- The wave5-specific behavior should not be assumed for every V4L2 encoder.
- The best performance numbers depend on kernel and FFmpeg changes that may not
  be present in a stock distribution build.

## License

See the repository license file.
