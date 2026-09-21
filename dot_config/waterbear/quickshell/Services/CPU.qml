pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  // Aggregate CPU usage, 0..100.
  readonly property real usage: _usage

  // Aggregate utilisation breakdown, 0..100.
  readonly property real userUsage: _userUsage
  readonly property real systemUsage: _systemUsage
  readonly property real iowaitUsage: _iowaitUsage
  readonly property real stealUsage: _stealUsage

  // Representative CPU frequency in MHz.
  readonly property real frequencyMHz: _frequencyMHz
  readonly property real maxFrequencyMHz: _maxFrequencyMHz

  // Load averages.
  readonly property real load1: _load1
  readonly property real load5: _load5
  readonly property real load15: _load15

  // Logical CPU count.
  readonly property int logicalCores: _logicalCores

  // Current per-core utilisation.
  //
  // Each entry contains:
  //   id      - logical CPU number
  //   usage   - CPU utilisation, 0..100
  readonly property var cores: _cores

  // Recent aggregate samples, oldest -> newest.
  //
  // Each sample contains:
  //   timestamp
  //   usage
  //   user
  //   system
  //   iowait
  //   steal
  //   frequencyMHz
  //   load1
  readonly property var history: _history

  property real _usage: 0

  property real _userUsage: 0
  property real _systemUsage: 0
  property real _iowaitUsage: 0
  property real _stealUsage: 0

  property real _frequencyMHz: 0
  property real _maxFrequencyMHz: 0

  property real _load1: 0
  property real _load5: 0
  property real _load15: 0

  property int _logicalCores: 0

  property var _cores: []
  property var _history: []

  property int _prevTotal: 0
  property int _prevIdle: 0
  property int _prevUser: 0
  property int _prevSystem: 0
  property int _prevIowait: 0
  property int _prevSteal: 0

  property var _corePrevious: ({})

  readonly property int historySize: 60
  readonly property int pollIntervalMs: 1000

  Process {
    id: cpuReader

    command: [
      "sh", "-c",
      "awk '\
      /^cpu / { \
      print \"TOTAL\", $2, $3, $4, $5, $6, $7, $8, $9; \
      next \
    } \
    /^cpu[0-9]+ / { \
    print $1, $2, $3, $4, $5, $6, $7, $8, $9; \
    next \
  }' /proc/stat; \
  cat /proc/loadavg"
]

stdout: StdioCollector {
  onStreamFinished: root.parseStats(text)
}

running: true

onRunningChanged: {
  if (!running)
  pollTimer.start()
}
    }

    Process {
      id: frequencyReader

      command: [
        "sh", "-c",
        "current=0; \
        current_count=0; \
        max=0; \
        max_count=0; \
        for cpu in /sys/devices/system/cpu/cpu[0-9]*; do \
        if [ -r \"$cpu/cpufreq/scaling_cur_freq\" ]; then \
        current=$((current + $(cat \"$cpu/cpufreq/scaling_cur_freq\"))); \
        current_count=$((current_count + 1)); \
        fi; \
        if [ -r \"$cpu/cpufreq/scaling_max_freq\" ]; then \
        max=$((max + $(cat \"$cpu/cpufreq/scaling_max_freq\"))); \
        max_count=$((max_count + 1)); \
        fi; \
        done; \
        if [ $current_count -gt 0 ]; then \
        awk -v v=$current -v n=$current_count \
        'BEGIN {print v / n / 1000}'; \
        else \
        awk '/^cpu MHz/ {sum += $4; count++} \
        END {if (count) print sum / count}' /proc/cpuinfo; \
        fi; \
        if [ $max_count -gt 0 ]; then \
        awk -v v=$max -v n=$max_count \
        'BEGIN {print v / n / 1000}'; \
        else \
        echo 0; \
        fi"
      ]

      stdout: StdioCollector {
        onStreamFinished: {
          const values = text.trim().split(/\s+/).map(Number)

          if (values.length >= 1 && Number.isFinite(values[0]))
          root._frequencyMHz = values[0]

          if (values.length >= 2 && Number.isFinite(values[1]))
          root._maxFrequencyMHz = values[1]
        }
      }

      running: true
    }

    Timer {
      id: pollTimer

      interval: root.pollIntervalMs
      repeat: false

      onTriggered: {
        cpuReader.running = true
        frequencyReader.running = true
      }
    }

    function parseStats(output) {
      const lines = output.trim().split(/\n/)

      let totalValues = null
      let loadValues = null

      const coreValues = []

      for (const line of lines) {
        const parts = line.trim().split(/\s+/)

        if (parts[0] === "TOTAL") {
          totalValues = parts.slice(1).map(Number)
          continue
        }

        if (/^cpu[0-9]+$/.test(parts[0])) {
          coreValues.push({
            id: parseInt(parts[0].slice(3), 10),
            counters: parts.slice(1).map(Number)
          })
          continue
        }

        // /proc/loadavg:
        // 1m 5m 15m running/total ...
        if (parts.length >= 4 && parts[3].includes("/")) {
          loadValues = parts.slice(0, 3).map(Number)
        }
      }

      if (!totalValues || totalValues.length < 8)
      return

      const user = totalValues[0]
      const nice = totalValues[1]
      const system = totalValues[2]
      const idle = totalValues[3]
      const iowait = totalValues[4]
      const irq = totalValues[5]
      const softirq = totalValues[6]
      const steal = totalValues[7]

      const total =
      user +
      nice +
      system +
      idle +
      iowait +
      irq +
      softirq +
      steal

      // Treat idle + iowait as non-working time.
      const idleTotal = idle + iowait

      if (root._prevTotal > 0) {
        const totalDelta = total - root._prevTotal
        const idleDelta = idleTotal - root._prevIdle

        if (totalDelta > 0) {
          const userDelta =
          (user + nice) - root._prevUser

          const systemDelta =
          (system + irq + softirq) - root._prevSystem

          const iowaitDelta =
          iowait - root._prevIowait

          const stealDelta =
          steal - root._prevSteal

          root._usage = clamp(
            100 * (1 - idleDelta / totalDelta)
          )

          root._userUsage = Math.max(
            0,
            100 * userDelta / totalDelta
          )

          root._systemUsage = Math.max(
            0,
            100 * systemDelta / totalDelta
          )

          root._iowaitUsage = Math.max(
            0,
            100 * iowaitDelta / totalDelta
          )

          root._stealUsage = Math.max(
            0,
            100 * stealDelta / totalDelta
          )

          root.recordCoreSamples(coreValues)
          root.recordSample(loadValues)
        }
      }

      root._prevTotal = total
      root._prevIdle = idleTotal
      root._prevUser = user + nice
      root._prevSystem = system + irq + softirq
      root._prevIowait = iowait
      root._prevSteal = steal

      root._logicalCores = coreValues.length

      if (loadValues && loadValues.length >= 3) {
        root._load1 = loadValues[0]
        root._load5 = loadValues[1]
        root._load15 = loadValues[2]
      }
    }

    function recordCoreSamples(coreValues) {
      const next = []

      for (const core of coreValues) {
        if (!core.counters || core.counters.length < 8)
        continue

        const values = core.counters

        const user = values[0]
        const nice = values[1]
        const system = values[2]
        const idle = values[3]
        const iowait = values[4]
        const irq = values[5]
        const softirq = values[6]
        const steal = values[7]

        const total =
        user +
        nice +
        system +
        idle +
        iowait +
        irq +
        softirq +
        steal

        const idleTotal = idle + iowait

        const previous = root._corePrevious[core.id]

        let usage = 0

        if (previous && total > previous.total) {
          const totalDelta = total - previous.total
          const idleDelta = idleTotal - previous.idle

          usage = 100 * (
            1 - idleDelta / totalDelta
          )
        }

        next.push({
          id: core.id,
          usage: clamp(usage)
        })

        root._corePrevious[core.id] = {
          total,
          idle: idleTotal
        }
      }

      root._cores = next
    }

    function recordSample(loadValues) {
      const next = root._history.slice()

      next.push({
        timestamp: Date.now(),
        usage: root._usage,
        user: root._userUsage,
        system: root._systemUsage,
        iowait: root._iowaitUsage,
        steal: root._stealUsage,
        frequencyMHz: root._frequencyMHz,
        load1: loadValues && loadValues.length >= 1
        ? loadValues[0]
        : root._load1
      })

      while (next.length > root.historySize)
      next.shift()

      root._history = next
    }

    function clamp(value) {
      return Math.max(0, Math.min(100, value))
    }
  }
