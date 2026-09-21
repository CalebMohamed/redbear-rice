pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  // Current memory usage, 0..100.
  readonly property real usage: _usage

  // Memory values in MiB.
  readonly property real totalMiB: _totalMiB
  readonly property real availableMiB: _availableMiB
  readonly property real usedMiB: _usedMiB

  property real _usage: 0
  property real _totalMiB: 0
  property real _availableMiB: 0
  property real _usedMiB: 0

  // Recent samples, oldest -> newest.
  //
  // Each sample contains:
  //   timestamp  - Unix timestamp in milliseconds
  //   usage      - memory usage, 0..100
  //   usedMiB    - used memory in MiB
  readonly property var history: _history

  property var _history: []

  readonly property int historySize: 60

  Process {
    id: ramReader

    command: [
      "sh", "-c",
      "awk '/^MemTotal:/ {total=$2} /^MemAvailable:/ {available=$2} END {print total, available}' /proc/meminfo"
    ]

    stdout: StdioCollector {
      onStreamFinished: {
        const v = text.trim().split(/\s+/).map(Number)

        if (v.length < 2 || v[0] <= 0)
        return

        // /proc/meminfo reports kB.
        const totalMiB = v[0] / 1024
        const availableMiB = v[1] / 1024
        const usedMiB = totalMiB - availableMiB
        const usage = 100 * usedMiB / totalMiB

        root._totalMiB = totalMiB
        root._availableMiB = availableMiB
        root._usedMiB = usedMiB
        root._usage = Math.round(usage)

        root.recordSample()
      }
    }

    running: true

    onRunningChanged: {
      if (!running)
      pollTimer.start()
    }
  }

  Timer {
    id: pollTimer

    interval: 1000
    repeat: false

    onTriggered: ramReader.running = true
  }

  function recordSample() {
    const next = root._history.slice()

    next.push({
      timestamp: Date.now(),
      usage: root._usage,
      usedMiB: root._usedMiB
    })

    while (next.length > root.historySize)
    next.shift()

    root._history = next
  }
}
