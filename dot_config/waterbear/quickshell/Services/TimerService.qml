pragma Singleton

import QtQuick
import Quickshell

Singleton {
  id: root

  property int durationSeconds: 25 * 60             // default duration
  property int remainingSeconds: durationSeconds    // main variable

  property bool running: false
  property bool finished: false

  property double _endTime: 0                       // used to turn the remainingSeconds into a true time for accurate time keeping

  readonly property string display: formatTime(remainingSeconds)

  function formatTime(seconds) {
    const mins = Math.floor(seconds / 60)
    const secs = seconds % 60

    return `${String(mins).padStart(2, "0")}:${String(secs).padStart(2, "0")}`
  }

  function start() {
    if (remainingSeconds <= 0)
    remainingSeconds = durationSeconds

    finished = false
    _endTime = Date.now() + remainingSeconds * 1000
    running = true
  }

  function pause() {
    if (running) {
      remainingSeconds = Math.max(
        0,
        Math.ceil((_endTime - Date.now()) / 1000)
      )
    }

    running = false
  }

  function toggleRunning() {
    if (running)
    pause()
    else
    start()
  }

  function reset() {
    running = false
    finished = false
    remainingSeconds = durationSeconds
  }

  function adjustMinutes(delta) {
    if (running) {
      _endTime += delta * 60 * 1000

      remainingSeconds = Math.max(
        0,
        Math.ceil((_endTime - Date.now()) / 1000)
      )

      if (remainingSeconds <= 0) {
        running = false
        finished = true
      }
    } else {
      remainingSeconds = Math.max(
        60,
        remainingSeconds + delta * 60
      )

      durationSeconds = remainingSeconds
      finished = false
    }
  }

  function setPreset(minutes) {
    durationSeconds = minutes * 60
    remainingSeconds = durationSeconds
    finished = false

    if (running)
    _endTime = Date.now() + durationSeconds * 1000
  }

  Timer {
    interval: 200
    repeat: true
    running: root.running

    onTriggered: {
      root.remainingSeconds = Math.max(
        0,
        Math.ceil((root._endTime - Date.now()) / 1000)
      )

      if (root.remainingSeconds <= 0) {
        root.running = false
        root.finished = true
      }
    }
  }
}
