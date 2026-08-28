pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  property real _usage: 0
  readonly property real usage: _usage

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

        root._usage = Math.round(100 * (1 - v[1] / v[0]))
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
}
