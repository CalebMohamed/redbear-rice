pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property real usage: _usage

    property real _usage: 0
    property int _prevTotal: 0
    property int _prevIdle: 0

    Process {
        id: cpuReader

        command: [
            "sh", "-c",
            "awk '/^cpu / {print $2, $3, $4, $5, $6, $7, $8}' /proc/stat"
        ]

        stdout: StdioCollector {
            onStreamFinished: {
                const v = text.trim().split(/\s+/).map(Number)

                if (v.length < 7)
                    return

                const user = v[0]
                const nice = v[1]
                const system = v[2]
                const idle = v[3]
                const iowait = v[4]
                const irq = v[5]
                const softirq = v[6]

                const total = user + nice + system + idle + iowait + irq + softirq

                if (root._prevTotal > 0) {
                    const totalDelta = total - root._prevTotal
                    const idleDelta = idle - root._prevIdle

                    if (totalDelta > 0)
                        root._usage = Math.round(100 * (1 - idleDelta / totalDelta))
                }

                root._prevTotal = total
                root._prevIdle = idle
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

        onTriggered: cpuReader.running = true
    }
}
