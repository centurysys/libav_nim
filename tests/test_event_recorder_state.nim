# tests/test_event_recorder_state.nim
#
# Pure state-machine checks for highlevel EventRecorder realtime trigger logic.

import libav_nim

proc main() =
  var recorder = initEventRecorder(preSeconds = 3, postSeconds = 2, outputPattern = "event_$1.mp4")

  doAssert recorder.state == ersIdle
  doAssert not recorder.hasPendingEvent()
  doAssert not recorder.readyToFinalize(0)

  let first = recorder.trigger(5_000_000'i64)
  doAssert first.started
  doAssert not first.extended
  doAssert first.eventUsec == 5_000_000'i64
  doAssert first.firstEventUsec == 5_000_000'i64
  doAssert first.recordUntilUsec == 7_000_000'i64
  doAssert first.outputPath == "event_0001.mp4"
  doAssert recorder.state == ersPending
  doAssert recorder.hasPendingEvent()
  doAssert recorder.pendingEventUsec == 5_000_000'i64
  doAssert recorder.pendingRecordUntilUsec == 7_000_000'i64
  doAssert not recorder.readyToFinalize(6_999_999'i64)
  doAssert recorder.readyToFinalize(7_000_000'i64)

  let second = recorder.trigger(6_500_000'i64)
  doAssert not second.started
  doAssert second.extended
  doAssert second.eventUsec == 6_500_000'i64
  doAssert second.firstEventUsec == 5_000_000'i64
  doAssert second.recordUntilUsec == 8_500_000'i64
  doAssert second.outputPath == "event_0001.mp4"
  doAssert recorder.pendingEventUsec == 5_000_000'i64
  doAssert recorder.pendingRecordUntilUsec == 8_500_000'i64
  doAssert not recorder.readyToFinalize(8_499_999'i64)
  doAssert recorder.readyToFinalize(8_500_000'i64)

  let third = recorder.trigger(6_000_000'i64)
  doAssert not third.started
  doAssert not third.extended
  doAssert third.recordUntilUsec == 8_500_000'i64

  recorder.clearPending()
  doAssert recorder.state == ersIdle
  doAssert not recorder.hasPendingEvent()

  echo "test_event_recorder_state: OK"

when isMainModule:
  main()
