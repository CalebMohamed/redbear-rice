pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  readonly property string interfaceName: _interfaceName
  readonly property string networkName: _networkName
  readonly property real strength: _strength
  readonly property bool wired: _wired
  readonly property bool connected: _connected

  property string _interfaceName: ""
  property string _networkName: ""
  property real _strength: 0
  property bool _wired: false
  property bool _connected: false

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
        // Example:
        //
        // wlo1:wifi:connected:GooseGoose
        // lo:loopback:connected (externally):lo
        // enp3s0:ethernet:unavailable:
        //
        // We only care about an actually activated device.

        const lines = this.text.trim().split("\n")

        root._interfaceName = ""
        root._networkName = ""
        root._strength = 0
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

          // Ignore loopback and bridges/etc.
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

        // If it's Wi-Fi, fetch the signal for this interface.
        if (root._connected && !root._wired)
        wifiReader.running = true
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
        // Example:
        //
        // *:87:wlo1
        // :32:wlo1
        //
        // Find the active AP on our selected interface.

        const lines = this.text.trim().split("\n")

        for (const line of lines) {
          if (!line)
          continue

          const fields = line.split(":")

          if (fields.length < 3)
          continue

          const inUse = fields[0]
          const signal = parseInt(fields[1])
          const device = fields[2]

          if (
            inUse === "*" &&
            device === root._interfaceName &&
            !isNaN(signal)
          ) {
            root._strength = signal / 100
            return
          }
        }

        root._strength = 0
      }
    }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true

    onTriggered: {
      if (!deviceReader.running)
      deviceReader.running = true
    }
  }
}
