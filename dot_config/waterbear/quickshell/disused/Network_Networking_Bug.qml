pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Networking

Singleton {
  id: root

  // Public API
  readonly property string interfaceName: _interfaceName
  readonly property string networkName: _networkName
  readonly property real strength: _strength
  readonly property bool wired: _wired
  readonly property bool connected: _device !== null

  // Internal state
  property string _interfaceName: ""
  property string _networkName: ""
  property real _strength: 0
  property bool _wired: false
  property var _device: null

  function updateDevice() {
    let found = null

    for (let i = 0; i < Networking.devices.count; ++i) {
      const device = Networking.devices.get(i)

      if (device.name === root._interfaceName) {
        found = device
        break
      }
    }

    root._device = found

    if (!found) {
      root._networkName = ""
      root._strength = 0
      root._wired = false
      return
    }

    // distinguishes wifi and wired, .Wifi is the dual
    root._wired = found.type === DeviceType.Wired

    if (root._wired) {
      root._networkName = found.network ? found.network.name : ""
      root._strength = 1 // strength meaningless for ethernet
      return
    }

    // Find the connected network belonging to this Wi-Fi device.
    for (let i = 0; i < found.networks.count; ++i) {
      const network = found.networks.get(i)

      if (network.connected) {
        root._networkName = network.name
        root._strength = network.signalStrength
        return
      }
    }

    root._networkName = ""
    root._strength = 0
  }

  Process {
    id: routeReader

    // queries arbitrary address to get network interface
    command: ["ip", "route", "get", "1.1.1.1"]

    stdout: StdioCollector {
      onStreamFinished: {
        // Example:
        //
        // 1.1.1.1 via 192.168.1.1 dev wlp2s0
        //     src 192.168.1.42 uid 1000

        const match = this.text.match(/\bdev\s+(\S+)/)

        root._interfaceName = match ? match[1] : ""
        root.updateDevice()
      }
    }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true

    onTriggered: routeReader.running = true
  }

  Component.onCompleted: routeReader.running = true
}


