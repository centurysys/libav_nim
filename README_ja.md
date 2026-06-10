# libav_nim

`libav_nim` は、FFmpeg/libav を Nim から扱うための小さなラッパーです。

現在の主な対象は、FFmpeg の `v4l2_m2m` codec 経由でハードウェア video codec を使える組み込み Linux 環境です。特に TI AM67A / wave5 VPU での利用を意識しています。

## 現状

現在の主目的は、次のような CPU から見える video pipeline を実用速度で動かすことです。

1. `*_v4l2m2m` で HEVC/H.264 を decode
2. decode された I420/YU12 frame を CPU owned memory にコピー
3. I420 から RGBX へ変換
4. RGBX 上で文字描画や overlay 処理
5. RGBX から padded NV12 へ直接変換
6. `h264_v4l2m2m` で H.264 encode
7. MP4 として出力

video frame を通常の userspace code から扱える状態にしつつ、decode / encode は hardware codec を使います。

## 機能

- FFmpeg/libav による demux / decode / encode / MP4 writer
- 既定では FFmpeg 8 binding を使用
- `-d:ffmpeg7` 指定時は FFmpeg 7 binding を使用
- CPU owned I420 / RGBX frame buffer
- RGBX overlay / drawing path
- NV12 encoder input 対応
- hardware encoder 向けの padded NV12 storage height 対応
- `libyuv_nim` による RGBX から padded NV12 への直接変換
- pipeline の各段階を測定する stage timing test

## なぜ padded NV12 が必要か

TI wave5 H.264 encoder では、YU12/yuv420p input path で 1080p frame を渡すと、出力画像がずれたり壊れたりすることがあります。

NV12 input にすると正常になりますが、UV plane は 16 line align された luma storage area の後ろに置く必要があります。

たとえば visible size が 1920x1080 の場合:

- visible size: 1920x1080
- storage/coded height: 1088
- UV offset に使う Y plane size: `1920 * 1088`
- UV plane は padded Y plane の後ろから開始

この padding を入れずに UV plane を 1920x1080 の直後に置くと、chroma や plane offset がずれたような出力になります。

## 性能メモ

AM67A / wave5 で、調整済み FFmpeg/libavcodec と、decoder capture queue で V4L2 cache hint を許可した kernel を使って測定した結果です。

- 1080p30 HEVC decode -> RGBX overlay -> H.264 encode: 約 44 fps
- 720p30 HEVC decode -> RGBX overlay -> H.264 encode: 約 87 fps

重要なのは、decoder capture buffer を non-coherent/cache-managed V4L2 MMAP path で CPU read できるようにすることです。これがない場合、1080p decoded frame のコピーだけで pipeline 全体の支配的なコストになることがあります。

この pipeline は、Full HD 30fps の CPU overlay / preprocessing 用途で実用になることを狙っています。

## 依存関係

必要なもの:

- Nim 2.2.x 以降
- FFmpeg/libav の development headers / libraries
- `libyuv_nim`
- `results`

runtime library は選択した FFmpeg build に依存します。v4l2_m2m hardware path を使う場合、以下のような FFmpeg codec が使える必要があります。

- `hevc_v4l2m2m`
- `h264_v4l2m2m`

hardware acceleration を使うには、target kernel と FFmpeg build が対象の V4L2 mem2mem device に対応している必要があります。

## FFmpeg binding の選択

既定では FFmpeg 8 binding を使います。

FFmpeg 8 で通常 build:

    nim c tests/test_transcode_stage_timing_nv12_direct.nim

明示する場合:

    nim c -d:ffmpeg8 tests/test_transcode_stage_timing_nv12_direct.nim

FFmpeg 7 binding を使う場合:

    nim c -d:ffmpeg7 tests/test_transcode_stage_timing_nv12_direct.nim

`ffmpeg7` と `ffmpeg8` を同時に define した場合は build error にするべきです。binding version はどちらか一方だけを選択します。

## 例: RGBX から padded NV12 へ直接変換する transcode timing

timing test の build / 実行例です。

    nim c -d:ffmpeg8 -r tests/test_transcode_stage_timing_nv12_direct.nim \
      input_hevc.mp4 \
      output_h264.mp4 \
      hevc_v4l2m2m \
      h264_v4l2m2m \
      30 \
      2000000 \
      0

引数:

1. input file
2. output file
3. decoder name
4. encoder name
5. output fps
6. output bitrate
7. 最大 frame 数。`0` の場合は最後まで処理

H.264 input の場合は decoder に `h264_v4l2m2m` を指定します。

## 主な frame 型

主に扱う frame 表現は以下です。

- FFmpeg から見える decoded I420/YU12 view
- `OwnedI420Frame`
- `OwnedRGBXFrame`
- `WritableNV12FrameView`
- padded NV12 encoder input frame

推奨 overlay pipeline:

    decoded I420/YU12
      -> OwnedI420Frame
      -> OwnedRGBXFrame
      -> overlay/drawing
      -> RGBX -> NV12 direct conversion で padded NV12
      -> h264_v4l2m2m encoder

## libyuv_nim の利用

`libav_nim` は色変換に `libyuv_nim` を使います。

RGBX から NV12 への直接変換では `ABGRToNV12` を使います。現在の `libav_nim` の `OwnedRGBXFrame` の byte order では、この指定で正しく変換できます。

比較用または fallback として、以下の経路も使えます。

- RGBX -> I420
- I420 -> padded NV12

AM67A / wave5 での検証では、RGBX -> padded NV12 direct path と I420 経由の padded NV12 path で encode 結果が一致しています。

## hardware 固有メモ

### TI AM67A / wave5

分かっている挙動:

- `hevc_v4l2m2m` decode から YU12/I420 を取り出せる
- decoder capture buffer は cacheable non-coherent MMAP buffer にすると CPU copy が高速になる
- `h264_v4l2m2m` の YU12/yuv420p input は出力がずれることがある
- `h264_v4l2m2m` の NV12 input は、luma storage height を 16 line align すると正常になる
- 1920x1080 は 1920x1088 の padded NV12 buffer として encoder に渡すのが安全

### V4L2 cache hint

最も良い decoder copy 性能は、以下の条件で得られています。

- kernel 側で decoder capture queue の cache hint を許可
- FFmpeg/libavcodec 側で decoder capture queue に `V4L2_MEMORY_FLAG_NON_COHERENT` を要求

stock kernel や distribution 標準の FFmpeg build では、この挙動は有効になっていない可能性があります。

## 開発メモ

timing test は意図的に細かい stage timing を出します。

分離して見たい項目:

- decoder open / first frame cost
- `readFrame`
- decoded frame copy
- I420 -> RGBX conversion
- overlay
- RGBX -> padded NV12 conversion
- encoder submission
- packet drain / write

これにより、変更の影響が CPU 変換なのか、hardware codec 側なのか、一度だけ発生する初期化なのかを見分けやすくしています。

## 既知の制限

- 現在の fast path は、I420 decode、RGBX CPU drawing、NV12 encode を主対象にしています。
- 1080p input は coded height / padded height が 1088 になる場合があります。最終製品で 1920x1080 として見せる必要がある場合、display/crop metadata の整理が追加で必要になる可能性があります。
- wave5 固有の挙動をすべての V4L2 encoder に一般化するべきではありません。
- 最高性能は kernel と FFmpeg 側の変更に依存します。stock distribution build では同じ数字にならない可能性があります。

## ライセンス

repository の license file を参照してください。
