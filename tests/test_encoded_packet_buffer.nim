import std/deques

import libav_nim

proc makePacket(timestampUsec: int64; isKeyframe: bool; size = 10): OwnedEncodedPacket =
  result = OwnedEncodedPacket(
    data: newSeq[byte](size),
    pts: timestampUsec,
    dts: timestampUsec,
    duration: 1,
    timeBase: Rational(num: 1, den: 1_000_000),
    isKeyframe: isKeyframe,
    timestampUsec: timestampUsec
  )

block leading_non_keyframes_are_kept_until_keyframe_arrives:
  var buf = initEncodedPacketBuffer(maxDurationUsec = 5_000_000)
  buf.push(makePacket(0, false))
  buf.push(makePacket(500_000, false))

  doAssert buf.len == 2
  doAssert buf.keyframeCount == 0
  doAssert buf.totalBytes == 20

  buf.push(makePacket(1_000_000, true))
  buf.push(makePacket(2_000_000, false))

  doAssert buf.len == 2
  doAssert buf.totalBytes == 20
  doAssert buf.oldestTimestampUsec == 1_000_000
  doAssert buf.keyframeCount == 1
  doAssert buf.packets.peekFirst().isKeyframe

block trim_keeps_front_on_keyframe:
  var buf = initEncodedPacketBuffer(maxDurationUsec = 3_000_000)
  buf.push(makePacket(0, true))
  buf.push(makePacket(1_000_000, false))
  buf.push(makePacket(2_000_000, true))
  buf.push(makePacket(3_000_000, false))
  buf.push(makePacket(4_000_000, false))

  doAssert buf.len == 3
  doAssert buf.oldestTimestampUsec == 2_000_000
  doAssert buf.packets.peekFirst().isKeyframe

block find_start_keyframe:
  var buf = initEncodedPacketBuffer(maxDurationUsec = 10_000_000)
  buf.push(makePacket(0, true))
  buf.push(makePacket(1_000_000, false))
  buf.push(makePacket(2_000_000, true))
  buf.push(makePacket(3_000_000, false))

  doAssert buf.findStartKeyframeIndex(1_500_000) == 0
  doAssert buf.findStartKeyframeIndex(2_500_000) == 2
  doAssert buf.packetsFrom(2).len == 2

block max_bytes_trims:
  var buf = initEncodedPacketBuffer(maxDurationUsec = 0, maxBytes = 25)
  buf.push(makePacket(0, true, 10))
  buf.push(makePacket(1_000_000, false, 10))
  buf.push(makePacket(2_000_000, true, 10))

  doAssert buf.totalBytes <= 25
  doAssert buf.packets.peekFirst().isKeyframe

block h264_idr_annexb_marks_keyframe:
  var payload = @[0'u8, 0'u8, 0'u8, 1'u8, 0x65'u8, 0x88'u8, 0x99'u8]
  let view = EncodedPacketView(
    data: cast[pointer](payload[0].addr),
    size: payload.len,
    pts: 0,
    dts: 0,
    duration: 1,
    timeBase: Rational(num: 1, den: 1_000_000),
    isKeyframe: false
  )

  let pkt = copyEncodedPacket(view, 0)
  doAssert pkt.isKeyframe

block h264_idr_avcc_marks_keyframe:
  var payload = @[0'u8, 0'u8, 0'u8, 3'u8, 0x65'u8, 0x88'u8, 0x99'u8]
  let view = EncodedPacketView(
    data: cast[pointer](payload[0].addr),
    size: payload.len,
    pts: 0,
    dts: 0,
    duration: 1,
    timeBase: Rational(num: 1, den: 1_000_000),
    isKeyframe: false
  )

  let pkt = copyEncodedPacket(view, 0)
  doAssert pkt.isKeyframe
