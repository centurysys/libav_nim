# High-level API

この文書は、`libav_nim` の high-level API 第一弾の使い方をまとめたものです。

high-level API は、以下のような実用的なカメラ pipeline を作るための部品です。

1. video frame を受信 / decode する
2. overlay 描画や CPU から見える処理を行う
3. 処理済み frame を encode する
4. encode 済み packet を ring buffer に保持する
5. event 発生時に「過去 + 未来」の self-contained MP4 clip を書き出す

現時点では、まだ pipeline 全体を表す `CodecPipe` ではなく、再利用しやすい部品を提供する段階です。将来の `CodecPipe` や worker-based API は、この上に組む想定です。

## module import

通常は top-level module を import します。

```nim
import libav_nim
```

top-level module から、以下の high-level module が export されます。

- `VideoRate`
- RTSP/input option helper
- `EncodedPacketBuffer`
- `EventRecorder`

## 所有権モデル

`EncodedPacketBuffer` と `EventRecorder` は `ref object` です。

呼び出し側では `let` で保持できます。

```nim
let packetBuffer = newEncodedPacketBuffer(
  maxDurationUsec = 10_000_000'i64,
  maxBytes = 0
)

let eventRecorder = newEventRecorder(
  preSeconds = 3,
  postSeconds = 2,
  outputPattern = "event_$1.mp4",
  maxClipSeconds = 60
)
```

これらは状態を持つ object です。持ち回るときは参照だけがコピーされるため軽量です。内部状態の更新は `push()` や `trigger()` で行いますが、public API の receiver に `var` を付ける必要はありません。

ただし、内部で同期はしていません。**1 pipeline / 1 worker thread が所有する object** として扱ってください。別 thread で event を検出した場合は、複数 thread から直接 `trigger()` を呼ぶのではなく、queue で所有 thread に event request を送る想定です。

thread 化するときの推奨所有関係:

```text
Encoder/Event worker thread:
  EncodedPacketBuffer
  EventRecorder
  MP4 event clip writer/finalizer

その他の thread:
  decoder output
  inference/detection result
  UI/network request

thread 境界:
  直接共有して書き換えず、queue/message で渡す
```

## VideoRate

`VideoRate` は、encoder PTS や event timestamp 計算に使う nominal output fps を表します。

代表的な helper:

```nim
let fps = initVideoRate(20)

echo fps.rateText()       # "20"
echo fps.rateFloat()      # 20.0
echo fps.timeBase()       # encoder/writer 用の Rational time base
echo fps.frameRate()      # Rational frame rate
echo fps.gopSize()        # nominal fps から決める GOP size
echo fps.timestampUsecForFrame(100'i64)
```

`parseVideoRate()` は、以下のような整数または有理数表記を受け取れます。

```text
20
30
30000/1001
```

現在の network transcode test では、nominal output frame index から packet timestamp を作っています。

```nim
let packetUsec = fps.timestampUsecForFrame(frameIndex)
```

## RTSP/input option helper

high-level input option helper は、RTSP camera test で使う FFmpeg input option をまとめるためのものです。

典型的な使い方:

```nim
var inputOptions = initTable[string, string]()

setInputOption(inputOptions, "rtsp_transport", "tcp")
addRtspLowLatencyOptions(inputOptions)
```

low-latency preset は、実カメラでのテスト向けです。video-only media selection、小さな probe size、buffering 抑制 flag、短い analysis duration などを追加する想定です。

カメラごとに追加 option が必要な場合は raw option を指定します。

```nim
setInputOption(inputOptions, "timeout", "5000000")
setInputOption(inputOptions, "fflags", "nobuffer")
```

## EncodedPacketBuffer

`EncodedPacketBuffer` は、encode 済み video packet を Nim-owned copy として保持します。

FFmpeg の `AVPacket` memory は基本的に borrowed で短命です。event recording では数秒ぶんの encode 済み packet を保持したいので、`OwnedEncodedPacket` にコピーして time/size bounded ring buffer に入れます。

buffer の作成:

```nim
let packetBuffer = newEncodedPacketBuffer(
  maxDurationUsec = 12_000_000'i64,
  maxBytes = 0
)
```

`maxDurationUsec <= 0` なら時間による trim を無効化します。`maxBytes <= 0` なら byte size による trim を無効化します。

encoder output packet を追加:

```nim
let owned = copyEncodedPacket(packetView, timestampUsec)
packetBuffer.push(owned)
```

確認用 helper:

```nim
echo packetBuffer.len
echo packetBuffer.durationUsec()
echo packetBuffer.oldestTimestampUsec()
echo packetBuffer.newestTimestampUsec()
echo packetBuffer.keyframeCount()
echo packetBuffer.statsText()
```

buffer は、可能な限り保持 window の先頭が keyframe になるように trim します。最初の keyframe がまだ見つかっていない間は、diagnostics と encoder keyframe flag 不足への対策として、non-keyframe packet もすぐには捨てません。

### H.264 SPS/PPS handling

V4L2 mem2mem encoder など、一部の hardware H.264 encoder では、encoder open 後に使える `extradata` が取れないことがあります。検証した wave5 環境では encoder extradata は `0 bytes` でした。

event clip を単体再生可能にするため、`EncodedPacketBuffer` は packet stream 上で最初に見つけた H.264 SPS/PPS parameter set prefix を保存します。

```nim
if packetBuffer.hasH264ParameterSetPrefix():
  echo "H.264 parameter sets are available"
```

event clip が後続の IDR/keyframe から始まる場合、保存済み SPS/PPS prefix を最初の packet に prepend できます。これにより、元の SPS/PPS packet が ring から trim 済みでも、生成した MP4 clip を単体で decode できます。

## EventRecorder

`EventRecorder` は、`EncodedPacketBuffer` から event clip を計画・書き出しする high-level component です。

使い方は大きく2つあります。

1. 明示的な event timestamp の前後を clip として書き出す
2. realtime pipeline で event pending 状態を持ち、post-roll packet が入った後で finalize する

recorder の作成:

```nim
let recorder = newEventRecorder(
  preSeconds = 3,
  postSeconds = 2,
  outputPattern = "event_$1.mp4",
  maxClipSeconds = 60
)
```

`maxClipSeconds = 0` は無制限です。正の値を指定すると、1本の pending event clip の最大長を制限します。これにより、event が入り続けて1本の clip が無限に伸びることを防ぎます。

### 明示的な event timestamp で clip を書く

ring に pre/post window がすでに入っている場合は、1本の clip を直接書けます。

```nim
let clip = check(recorder.writeEventClip(
  packetBuffer,
  encodedStreamInfo,
  eventUsec = 5_000_000'i64,
  outputPath = "event_0001.mp4"
))

echo clip.actualStartUsec
echo clip.writtenPackets
```

recorder は requested pre-roll start 以前の安全な開始 packet を選びます。必要であれば、keyframe に合わせるために requested start より少し前から開始します。

### realtime pending event recording

realtime pipeline では、event を検出した瞬間には post-roll 部分がまだ存在しません。`trigger()` で pending にして、後で finalize します。

```nim
discard recorder.trigger(eventUsec)

# 新しい encoded packet を packetBuffer に push した後で呼ぶ
if recorder.readyToFinalize(packetBuffer):
  let clip = check(recorder.writePendingClip(
    packetBuffer,
    encodedStreamInfo
  ))
```

pending 中に次の event が来た場合、recorder は pending の `recordUntilUsec` を延長します。

```text
最初の event:
  requested start = eventUsec - preSeconds
  requested end   = eventUsec + postSeconds

pending 中の次 event:
  requested end   = max(旧 end, secondEventUsec + postSeconds)
```

`maxClipSeconds` が正の値なら、終了時刻は以下で clamp されます。

```text
first clip start + maxClipSeconds
```

pending clip の書き出し後、recorder は `ersIdle` に戻ります。

### EventClipResult

`writeEventClip()` と `writePendingClip()` は `EventClipResult` を返します。

主な field:

- `requestedStartUsec`
- `requestedEndUsec`
- `actualStartUsec`
- `startIndex`
- `endIndexExclusive`
- `outputPath`
- `writtenPackets`
- `extradataBytes`
- `h264ParameterSetPrefixBytes`
- `prependedH264ParameterSets`
- `requireParameterSets`

requested window は論理上の event window です。actual start は keyframe に合わせるため、requested start より前になることがあります。

## 実用的な packet flow

簡略化した packet flow は以下です。

```nim
let packetBuffer = newEncodedPacketBuffer(12_000_000'i64)
let recorder = newEventRecorder(3, 2, "event_$1.mp4", 60)

while running:
  # decode frame, overlay, encode frame
  # encoder packet を drain

  for packetView in drainedPackets:
    let timestampUsec = fps.timestampUsecForFrame(frameIndex)
    packetBuffer.push(copyEncodedPacket(packetView, timestampUsec))

  if detectionHappened:
    discard recorder.trigger(eventUsec)

  if recorder.readyToFinalize(packetBuffer):
    let clip = check(recorder.writePendingClip(packetBuffer, encodedStreamInfo))
    echo "wrote event clip: ", clip.outputPath
```

実際の decode/encode loop は low-level FFmpeg wrapper の使い方に依存します。ただし、event recording は raw RGBX/I420 frame ではなく、encode 済み packet を中心に行います。

## raw frame ではなく encoded packet を保持する理由

Full HD RGBX の場合:

```text
1920 * 1080 * 4 bytes ~= 8.3 MB/frame
20 fps * 10 sec       ~= 1.6 GB
```

pre-roll 用に raw frame を保持するには大きすぎます。

H.264 2 Mbps なら:

```text
2 Mbps * 10 sec ~= 2.5 MB
```

encoded packet を保持すればかなり小さく、event 発生時に過去 frame を再 encode する必要もありません。

## thread 化の指針

現在の high-level object は、将来の worker-based pipeline に置きやすい形にしています。

想定される分割例:

```text
Decoder worker:
  RTSP read
  hardware decode
  YUV -> RGBX

Application/inference worker:
  HAILO or CPU inference
  event decision
  overlay metadata

Encoder/Event worker:
  overlay rendering or final RGBX preparation
  RGBX -> padded NV12
  hardware encode
  EncodedPacketBuffer.push()
  EventRecorder.trigger()
  EventRecorder.writePendingClip()
```

実際の分割は変わる可能性がありますが、所有権のルールは単純に保ちます。

- 1つの `EncodedPacketBuffer` は1つの thread が所有する
- 1つの `EventRecorder` は1つの thread が所有する
- 他 thread は message/event を所有 thread に送る

## 現在の制限

- high-level API はまだ pipeline 全体の抽象化ではありません。
- `EncodedPacketBuffer` と `EventRecorder` 自体は thread-safe ではありません。
- event clip 書き出しは、現時点では既存 MP4 writer 経由です。
- H.264 SPS/PPS prefix reuse は実用的な event clip 用に実装済みです。他 codec では別の parameter set handling が必要になる可能性があります。
- 現在の network/Pixie overlay pipeline は、まだ integration test として `tests/` にあります。再利用可能な `CodecPipe` API は今後のステップです。
