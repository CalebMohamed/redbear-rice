pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  // Connection state
  readonly property string interfaceName: _interfaceName
  readonly property string networkName: _networkName
  readonly property bool connected: _connected
  readonly property bool wired: _wired

  // Wi-Fi signal, 0..1.
  // Wired connections expose 1 when connected.
  readonly property real strength: _strength

  // Network information
  readonly property string ipv4: _ipv4
  readonly property string gateway: _gateway

  // Current traffic rates.
  readonly property real receiveBytesPerSecond: _receiveBytesPerSecond
  readonly property real transmitBytesPerSecond: _transmitBytesPerSecond

  readonly property real receivePacketsPerSecond: _receivePacketsPerSecond
  readonly property real transmitPacketsPerSecond: _transmitPacketsPerSecond

  // Recent traffic history, oldest -> newest.
  //
  // Each sample contains:
  //   timestamp
  //   receiveBytesPerSecond
  //   transmitBytesPerSecond
  readonly property var history: _history

  property string _interfaceName: ""
  property string _networkName: ""
  property bool _connected: false
  property bool _wired: false

  property real _strength: 0

  property string _ipv4: ""
  property string _gateway: ""

  property real _receiveBytesPerSecond: 0
  property real _transmitBytesPerSecond: 0

  property real _receivePacketsPerSecond: 0
  property real _transmitPacketsPerSecond: 0

  property var _history: []

  // Previous /proc/net/dev counters.
  property var _previousStats: null
  property real _previousTimestamp: 0
  property string _previousInterface: ""

  readonly property int historySize: 60
  readonly property int pollIntervalMs: 1000

  Process {
    id: deviceReader

    command: [
      "nmcli",
      "-t",
      "-f",
      "DEVICE,TYPE,STATE,CONNECTION",
      "device"
    ]

    running: true

    stdout: StdioCollector {
      onStreamFinished: {
        const lines = text.trim().split("\n")

        root._interfaceName = ""
        root._networkName = ""
        // root._strength = 0 not needed
        root._wired = false
        root._connected = false

        for (const line of lines) {
          if (!line)
          continue

          const fields = line.split(":")

          if (fields.length < 4)
          continue

          const device = fields[0]
          const type = fields[1]
          const state = fields[2]
          const connection = fields.slice(3).join(":")

          if (state !== "connected")
          continue

          if (type !== "wifi" && type !== "ethernet")
          continue

          root._interfaceName = device
          root._networkName = connection
          root._wired = type === "ethernet"
          root._connected = true

          if (root._wired)
          root._strength = 1

          break
        }

        if (root._connected && !root._wired)
        wifiReader.running = true

        detailsReader.running = true
      }
    }
  }

  Process {
    id: wifiReader

    command: [
      "nmcli",
      "-t",
      "-f",
      "IN-USE,SIGNAL,DEVICE",
      "device",
      "wifi"
    ]

    stdout: StdioCollector {
      onStreamFinished: {
        const lines = text.trim().split("\n")

        for (const line of lines) {
          if (!line)
          continue

          const fields = line.split(":")

          if (fields.length < 3)
          continue

          const inUse = fields[0]
          const signal = parseInt(fields[1], 10)
          const device = fields[2]

          if (
            inUse === "*" &&
            device === root._interfaceName &&
            Number.isFinite(signal)
          ) {
            root._strength = signal / 100
            return
          }
        }

        root._strength = 0
      }
    }

  }

  Process {
    id: detailsReader

    command: [
      "sh", "-c",
      "ip -4 -brief address show dev \"$1\" 2>/dev/null | " +
      "awk '{print $3}' | cut -d/ -f1; " +
      "ip route show default dev \"$1\" 2>/dev/null | " +
      "awk 'NR==1 {print $3}'",
      "sh",
      root._interfaceName
    ]

    stdout: StdioCollector {
      onStreamFinished: {
        const lines = text.trim().split("\n")

        root._ipv4 = lines.length >= 1
        ? lines[0].trim()
        : ""

        root._gateway = lines.length >= 2
        ? lines[1].trim()
        : ""
      }
    }

  }

  Process {
    id: statsReader

    command: [
      "cat",
      "/proc/net/dev"
    ]

    running: true

    stdout: StdioCollector {
      onStreamFinished: root.parseStats(text)
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

    onTriggered: {
      deviceReader.running = true
      statsReader.running = true
    }

  }

  function parseStats(output) {
    if (!root.connected || !root.interfaceName) {
      root._receiveBytesPerSecond = 0
      root._transmitBytesPerSecond = 0
      root._receivePacketsPerSecond = 0
      root._transmitPacketsPerSecond = 0
      root._previousStats = null
      root._previousTimestamp = 0
      root.recordSample()
      return
    }

    let current = null

    for (const line of output.trim().split("\n")) {
      const separator = line.indexOf(":")

      if (separator < 0)
      continue

      const interfaceName = line.slice(0, separator).trim()

      if (interfaceName !== root.interfaceName)
      continue

      const values = line
      .slice(separator + 1)
      .trim()
      .split(/\s+/)
      .map(Number)

      if (values.length < 16)
      return

      current = {
        receiveBytes: values[0],
        receivePackets: values[1],
        transmitBytes: values[8],
        transmitPackets: values[9]
      }

      break
    }

    if (!current)
    return

    const now = Date.now()

    // Reset the baseline when the interface changes.
    if (root._previousInterface !== root.interfaceName) {
      root._previousInterface = root.interfaceName
      root._previousStats = current
      root._previousTimestamp = now

      root._receiveBytesPerSecond = 0
      root._transmitBytesPerSecond = 0
      root._receivePacketsPerSecond = 0
      root._transmitPacketsPerSecond = 0

      return
    }

    if (root._previousStats && root._previousTimestamp > 0) {
      const elapsed =
      (now - root._previousTimestamp) / 1000

      if (elapsed > 0) {
        root._receiveBytesPerSecond =
        Math.max(
          0,
          current.receiveBytes -
          root._previousStats.receiveBytes
        ) / elapsed

        root._transmitBytesPerSecond =
        Math.max(
          0,
          current.transmitBytes -
          root._previousStats.transmitBytes
        ) / elapsed

        root._receivePacketsPerSecond =
        Math.max(
          0,
          current.receivePackets -
          root._previousStats.receivePackets
        ) / elapsed

        root._transmitPacketsPerSecond =
        Math.max(
          0,
          current.transmitPackets -
          root._previousStats.transmitPackets
        ) / elapsed

        root.recordSample(now)
      }
    }

    root._previousStats = current
    root._previousTimestamp = now

  }

  function recordSample(timestamp) {
    const next = root._history.slice()

    next.push({
      timestamp: timestamp || Date.now(),
      receiveBytesPerSecond: root._receiveBytesPerSecond,
      transmitBytesPerSecond: root._transmitBytesPerSecond
    })

    while (next.length > root.historySize)
    next.shift()

    root._history = next
  }
}
