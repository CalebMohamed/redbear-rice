pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  // Current memory usage, 0..100.
  readonly property real usage: _usage

  // Physical memory, MiB.
  readonly property real totalMiB: _totalMiB
  readonly property real availableMiB: _availableMiB
  readonly property real usedMiB: _usedMiB
  readonly property real cachedMiB: _cachedMiB

  // Swap, MiB.
  readonly property real swapUsedMiB: _swapUsedMiB
  readonly property real swapTotalMiB: _swapTotalMiB
  readonly property real swapUsage: _swapUsage

  // Memory commit, MiB.
  readonly property real committedMiB: _committedMiB
  readonly property real commitLimitMiB: _commitLimitMiB

  // Memory pressure.
  // PSI "some" = percentage of time at least one task was stalled
  // because of memory pressure, over the last 10 seconds.
  readonly property real pressureSome: _pressureSome

  // Recent samples, oldest -> newest.
  //
  // Each sample contains:
  //   timestamp
  //   usage
  //   usedMiB
  //   availableMiB
  //   swapUsage
  //   pressureSome
  readonly property var history: _history

  property real _usage: 0

  property real _totalMiB: 0
  property real _availableMiB: 0
  property real _usedMiB: 0
  property real _cachedMiB: 0

  property real _swapUsedMiB: 0
  property real _swapTotalMiB: 0
  property real _swapUsage: 0

  property real _committedMiB: 0
  property real _commitLimitMiB: 0

  property real _pressureSome: 0

  property var _history: []

  readonly property int historySize: 60
  readonly property int pollIntervalMs: 1000

  Process {
    id: ramReader

    command: [
      "sh", "-c",
      "awk '\
      /^MemTotal:/     { total=$2 } \
      /^MemAvailable:/ { available=$2 } \
      /^Cached:/       { cached=$2 } \
      /^SwapTotal:/    { swapTotal=$2 } \
      /^SwapFree:/     { swapFree=$2 } \
      /^Committed_AS:/ { committed=$2 } \
      /^CommitLimit:/  { commitLimit=$2 } \
      END { \
      print total, available, cached, swapTotal, swapFree, committed, commitLimit \
    }' /proc/meminfo; \
    awk '/^some/ { \
    for (i = 1; i <= NF; i++) \
    if ($i ~ /^avg10=/) { split($i, a, \"=\"); print a[2]; exit } \
  }' /proc/pressure/memory"
]

stdout: StdioCollector {
  onStreamFinished: {
    const lines = text.trim().split(/\n/)

    if (lines.length < 2)
    return

    const memory = lines[0].trim().split(/\s+/).map(Number)
    const pressure = Number(lines[1].trim())

    if (memory.length < 7 || memory[0] <= 0)
    return

    const totalMiB = memory[0] / 1024
    const availableMiB = memory[1] / 1024
    const cachedMiB = memory[2] / 1024

    const swapTotalMiB = memory[3] / 1024
    const swapFreeMiB = memory[4] / 1024
    const swapUsedMiB = Math.max(
      0,
      swapTotalMiB - swapFreeMiB
    )

    const committedMiB = memory[5] / 1024
    const commitLimitMiB = memory[6] / 1024

    const usedMiB = Math.max(
      0,
      totalMiB - availableMiB
    )

    const usage = 100 * usedMiB / totalMiB

    root._totalMiB = totalMiB
    root._availableMiB = availableMiB
    root._usedMiB = usedMiB
    root._cachedMiB = cachedMiB

    root._swapTotalMiB = swapTotalMiB
    root._swapUsedMiB = swapUsedMiB
    root._swapUsage = swapTotalMiB > 0
    ? 100 * swapUsedMiB / swapTotalMiB
    : 0

    root._committedMiB = committedMiB
    root._commitLimitMiB = commitLimitMiB

    root._usage = Math.round(usage)

    if (Number.isFinite(pressure))
    root._pressureSome = pressure

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

    interval: root.pollIntervalMs
    repeat: false

    onTriggered: ramReader.running = true
  }

  function recordSample() {
    const next = root._history.slice()

    next.push({
      timestamp: Date.now(),
      usage: root._usage,
      usedMiB: root._usedMiB,
      availableMiB: root._availableMiB,
      swapUsage: root._swapUsage,
      pressureSome: root._pressureSome
    })

    while (next.length > root.historySize)
    next.shift()

    root._history = next
  }
}
