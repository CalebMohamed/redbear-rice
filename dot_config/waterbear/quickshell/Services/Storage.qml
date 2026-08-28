pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  readonly property real usage: _usage

  property real _usage: 0

  Process {
    id: storageReader
    command: [ "df", "-P", "/" ]
    running: true

    stdout: StdioCollector {
      onStreamFinished: {
        const lines = text.trim().split("\n")

        if (lines.length < 2)
        return

        const fields = lines[1].trim().split(/\s+/)

        if (fields.length < 5)
        return

        const used = Number(fields[2])
        const available = Number(fields[3])
        const total = used + available

        if (total > 0)
        root._usage = Math.round(100 * used / total)
      }
    }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    onTriggered: storageReader.running = true
  }
}
