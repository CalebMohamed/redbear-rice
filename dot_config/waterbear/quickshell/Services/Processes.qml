pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  readonly property int count: _count
  readonly property var byCpu: _byCpu
  readonly property var byMemory: _byMemory
  readonly property int logicalCores: _logicalCores

  property int _count: 0
  property var _byCpu: []
  property var _byMemory: []

  property int _logicalCores: 1
  property int _totalMemoryKiB: 0

  // Previous cumulative CPU time for each PID.
  property var _previous: ({})

  // Previous total system CPU time.
  property real _previousSystemTicks: 0

  readonly property int processLimit: 8
  readonly property int pollIntervalMs: 2000

  Process {
    id: reader

    command: [
      "sh",
      "-c",
      "pagesize=$(getconf PAGESIZE); " +
      "printf 'CORES\\t%s\\n' \"$(nproc)\"; " +
      "awk 'BEGIN { OFS=\"\\t\" } /^MemTotal:/ { print \"MEM\", $2 }' /proc/meminfo; " +
      "awk 'BEGIN { OFS=\"\\t\" } /^cpu / { print \"CPU\", $2+$3+$4+$5+$6+$7+$8+$9 }' /proc/stat; " +
      "for stat in /proc/[0-9]*/stat; do " +
      "  [ -r \"$stat\" ] || continue; " +
      "  awk -v pagesize=\"$pagesize\" ' " +
      "    BEGIN { OFS=\"\\t\" } " +
      "    { " +
      "      line = $0; " +
      "      openPos = index(line, \"(\"); " +
      "      match(line, /\\) [RSDTtXZPIUW] /); " +
      "      closePos = RSTART; " +
      "      pid = $1; " +
      "      name = substr(line, openPos + 1, closePos - openPos - 1); " +
      "      rest = substr(line, closePos + 2); " +
      "      n = split(rest, fields, \" \"); " +
      "      if (n >= 22) " +
      "        print \"PROC\", pid, name, fields[12] + fields[13], fields[22] * pagesize / 1024; " +
      "    }' \"$stat\"; " +
      "done"
    ]

    running: true

    stdout: StdioCollector {
      onStreamFinished: root.parse(text)
    }

    onRunningChanged: {
      if (!running)
      pollTimer.start()
    }
  }

  Timer {
    id: pollTimer

    interval: root.pollIntervalMs
    repeat: false

    onTriggered: reader.running = true
  }

  function parse(output) {
    const lines = output.trim().split("\n")

    let logicalCores = 1
    let totalMemoryKiB = 0
    let systemTicks = 0

    const processes = []
    const current = {}

    for (const line of lines) {
      if (!line)
      continue

      const fields = line.split("\t")

      switch (fields[0]) {
        case "CORES":
        logicalCores = parseInt(fields[1], 10)
        break

        case "MEM":
        totalMemoryKiB = Number(fields[1])
        break

        case "CPU":
        systemTicks = Number(fields[1])
        break

        case "PROC": {
          if (fields.length < 5)
          break

          const pid = parseInt(fields[1], 10)
          const name = fields[2]
          const cpuTicks = Number(fields[3])
          const rssKiB = Number(fields[4])

          if (
            !Number.isFinite(pid) ||
            !Number.isFinite(cpuTicks) ||
            !Number.isFinite(rssKiB)
          ) {
            break
          }

          current[pid] = cpuTicks

          processes.push({
            pid,
            name,
            cpu: 0,
            memory: totalMemoryKiB > 0
            ? 100 * rssKiB / totalMemoryKiB
            : 0,
            rssMiB: rssKiB / 1024
          })

          break
        }
      }
    }

    root._logicalCores =
    Number.isFinite(logicalCores) && logicalCores > 0
    ? logicalCores
    : 1

    const systemDelta =
    root._previousSystemTicks > 0
    ? systemTicks - root._previousSystemTicks
    : 0

    for (const process of processes) {
      const previous = root._previous[process.pid]

      if (previous !== undefined && systemDelta > 0) {
        const processDelta =
        current[process.pid] - previous

        process.cpu = Math.max(
          0,
          100 *
          processDelta /
          systemDelta *
          root._logicalCores
        )
      }
    }

    root._count = processes.length
    root._previous = current
    root._previousSystemTicks = systemTicks
    root._totalMemoryKiB = totalMemoryKiB

    root._byCpu = processes
    .slice()
    .sort((a, b) => b.cpu - a.cpu)
    .slice(0, root.processLimit)

    root._byMemory = processes
    .slice()
    .sort((a, b) => b.memory - a.memory)
    .slice(0, root.processLimit)
  }
}
