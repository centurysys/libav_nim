# High-level API

This document describes the first high-level API layer in `libav_nim`.

The high-level API is intended for practical camera pipelines where the
application wants to:

1. receive/decode video frames,
2. draw overlays or run CPU-visible processing,
3. encode the result,
4. keep recent encoded packets in a ring buffer, and
5. write self-contained event clips such as "pre-roll + post-roll" MP4 files.

The current high-level API is still intentionally small. It provides reusable
building blocks instead of a full pipeline object. A future `CodecPipe` or
worker-based API can be built on top of these parts.

## Module import

Most applications can import the top-level module:

```nim
import libav_nim
```

The top-level module exports the high-level modules, including:

- `VideoRate`
- RTSP/input option helpers
- `EncodedPacketBuffer`
- `EventRecorder`

## Ownership model

`EncodedPacketBuffer` and `EventRecorder` are `ref object` types.

Use `let` bindings:

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

These objects are stateful. Passing them around is cheap because only a
reference is copied. Their internal state is updated by methods such as
`push()` and `trigger()` without requiring `var` receivers in public API usage.

They are **not internally synchronized**. Treat them as owned by one pipeline or
one worker thread. If another thread detects an event, send an event request to
the owner thread through a queue instead of calling `trigger()` from multiple
threads.

Recommended ownership for a threaded camera pipeline:

```text
Encoder/Event worker thread:
  EncodedPacketBuffer
  EventRecorder
  MP4 event clip writer/finalizer

Other threads:
  decoder output
  inference/detection result
  UI/network requests

Thread boundary:
  queues/messages, not direct shared mutation
```

## VideoRate

`VideoRate` represents the nominal output frame rate used for encoder PTS and
event timestamp calculations.

Common helpers:

```nim
let fps = initVideoRate(20)

echo fps.rateText()       # "20"
echo fps.rateFloat()      # 20.0
echo fps.timeBase()       # Rational suitable for encoder/writer time base
echo fps.frameRate()      # Rational frame rate
echo fps.gopSize()        # GOP size derived from nominal rate
echo fps.timestampUsecForFrame(100'i64)
```

`parseVideoRate()` accepts integer or rational text such as:

```text
20
30
30000/1001
```

In the current network transcode tests, packet timestamps are generated from the
nominal output frame index:

```nim
let packetUsec = fps.timestampUsecForFrame(frameIndex)
```

## RTSP/input option helpers

The high-level input option helpers provide common FFmpeg input options for
RTSP camera testing.

Typical usage pattern:

```nim
var inputOptions = initTable[string, string]()

setInputOption(inputOptions, "rtsp_transport", "tcp")
addRtspLowLatencyOptions(inputOptions)
```

The low-latency preset is intended for practical camera tests and may add
options such as video-only media selection, small probe size, disabled buffering
flags, and reduced analysis duration.

Use raw options when a specific camera needs extra FFmpeg input settings:

```nim
setInputOption(inputOptions, "timeout", "5000000")
setInputOption(inputOptions, "fflags", "nobuffer")
```

## EncodedPacketBuffer

`EncodedPacketBuffer` stores Nim-owned copies of encoded video packets.

This is used for event recording because FFmpeg `AVPacket` memory is normally
borrowed and short-lived. Once copied into `OwnedEncodedPacket`, the packet data
can safely remain in a time/size bounded ring buffer.

Create a buffer:

```nim
let packetBuffer = newEncodedPacketBuffer(
  maxDurationUsec = 12_000_000'i64,
  maxBytes = 0
)
```

`maxDurationUsec <= 0` disables time-based trimming. `maxBytes <= 0` disables
byte-size trimming.

Push encoder output packets:

```nim
let owned = copyEncodedPacket(packetView, timestampUsec)
packetBuffer.push(owned)
```

Useful inspection helpers:

```nim
echo packetBuffer.len
echo packetBuffer.durationUsec()
echo packetBuffer.oldestTimestampUsec()
echo packetBuffer.newestTimestampUsec()
echo packetBuffer.keyframeCount()
echo packetBuffer.statsText()
```

The buffer keeps the retained window aligned to a leading keyframe whenever
possible. Before the first keyframe is observed, packets are kept for diagnostics
instead of being immediately discarded.

### H.264 SPS/PPS handling

Some hardware H.264 encoders, especially V4L2 mem2mem encoders, may not expose
usable encoder `extradata` after opening the encoder. In the tested wave5
environment, encoder extradata was `0 bytes`.

To make event clips self-contained, `EncodedPacketBuffer` detects the first
H.264 SPS/PPS parameter set prefix observed in the packet stream and stores it
separately:

```nim
if packetBuffer.hasH264ParameterSetPrefix():
  echo "H.264 parameter sets are available"
```

When an event clip starts from a later IDR/keyframe, the saved SPS/PPS prefix can
be prepended to the first written packet. This allows the generated MP4 clip to
be decoded independently even when the original SPS/PPS packet has already been
trimmed from the ring.

## EventRecorder

`EventRecorder` plans and writes event clips from an `EncodedPacketBuffer`.

It supports two usage modes:

1. write a clip around an explicit event timestamp, or
2. keep a realtime pending event window and finalize it after post-roll packets
   have arrived.

Create a recorder:

```nim
let recorder = newEventRecorder(
  preSeconds = 3,
  postSeconds = 2,
  outputPattern = "event_$1.mp4",
  maxClipSeconds = 60
)
```

`maxClipSeconds = 0` means unlimited clip extension. A positive value clamps the
duration of one pending event clip. This prevents repeated triggers from growing
one clip indefinitely.

### Write a clip for an explicit event timestamp

If the ring already contains the full pre/post window, write one clip directly:

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

The recorder chooses a safe start packet at or before the requested pre-roll
start. If necessary, it starts slightly earlier to align with a keyframe.

### Realtime pending event recording

In a realtime pipeline, the post-roll part is not available at the moment the
event is detected. Use `trigger()` and finalize later.

```nim
discard recorder.trigger(eventUsec)

# Called after new encoded packets are pushed into packetBuffer.
if recorder.readyToFinalize(packetBuffer):
  let clip = check(recorder.writePendingClip(
    packetBuffer,
    encodedStreamInfo
  ))
```

When another event arrives while a clip is pending, the recorder extends the
pending `recordUntilUsec` timestamp:

```text
first event:
  requested start = eventUsec - preSeconds
  requested end   = eventUsec + postSeconds

second event while pending:
  requested end   = max(old end, secondEventUsec + postSeconds)
```

If `maxClipSeconds` is positive, the end time is clamped to:

```text
first clip start + maxClipSeconds
```

After the pending clip is written, the recorder returns to `ersIdle`.

### EventClipResult

`writeEventClip()` and `writePendingClip()` return `EventClipResult`.

Important fields include:

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

The requested window is the logical event window. The actual start may be
earlier when the writer must start from a keyframe.

## Practical packet flow

A simplified packet flow looks like this:

```nim
let packetBuffer = newEncodedPacketBuffer(12_000_000'i64)
let recorder = newEventRecorder(3, 2, "event_$1.mp4", 60)

while running:
  # Decode frame, draw overlay, encode frame.
  # Drain encoder packets.

  for packetView in drainedPackets:
    let timestampUsec = fps.timestampUsecForFrame(frameIndex)
    packetBuffer.push(copyEncodedPacket(packetView, timestampUsec))

  if detectionHappened:
    discard recorder.trigger(eventUsec)

  if recorder.readyToFinalize(packetBuffer):
    let clip = check(recorder.writePendingClip(packetBuffer, encodedStreamInfo))
    echo "wrote event clip: ", clip.outputPath
```

The exact decode/encode loop depends on the selected low-level FFmpeg wrappers,
but event recording should stay centered around encoded packets rather than raw
RGBX or I420 frame buffers.

## Why keep encoded packets instead of raw frames?

For Full HD RGBX:

```text
1920 * 1080 * 4 bytes ~= 8.3 MB/frame
20 fps * 10 sec       ~= 1.6 GB
```

Keeping raw frames for pre-roll is too expensive for embedded systems.

For H.264 at 2 Mbps:

```text
2 Mbps * 10 sec ~= 2.5 MB
```

Keeping encoded packets is much smaller and also avoids re-encoding old frames
when an event occurs.

## Threading guidance

The current high-level objects are designed to be easy to place inside a future
worker-based pipeline.

A likely design is:

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

The exact split may change, but the ownership rule should remain simple:

- one thread owns each `EncodedPacketBuffer`
- one thread owns each `EventRecorder`
- other threads send messages/events to the owner

## Current limitations

- The high-level API is not yet a full pipeline abstraction.
- `EncodedPacketBuffer` and `EventRecorder` are not thread-safe by themselves.
- Event clip writing currently targets MP4 through the existing MP4 writer.
- H.264 SPS/PPS prefix reuse is implemented for practical event clips. Other
  codecs may need different parameter-set handling.
- The current network/Pixie overlay pipeline still lives in tests as an
  integration scenario. A reusable `CodecPipe` API is a future step.
