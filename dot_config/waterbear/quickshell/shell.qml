import QtQml
import Quickshell
import Quickshell.Io
import "./Services"

import QtQuick
import Quickshell.Networking

Scope {
  Component.onCompleted: {
    console.log("devices:", Networking.devices.values)

    for (const device of Networking.devices.values) {
      console.log(
        "device:",
        device.name,
        "connected:", device.connected,
        "type:", device.type
      )
    }
  }
  // Component.onCompleted: {
  //   console.log("=== NETWORK DEVICES ===")

  //   for (let i = 0; i < Networking.devices.count; ++i) {
  //     const d = Networking.devices.get(i)

  //     console.log(
  //       "device:",
  //       d.name,
  //       "type:", d.type,
  //       "state:", d.state,
  //       "connected:", d.connected,
  //       "networks:", d.networks.count
  //     )

  //     for (let j = 0; j < d.networks.count; ++j) {
  //       const n = d.networks.get(j)

  //       console.log(
  //         "  network:",
  //         n.name,
  //         "connected:", n.connected
  //       )
  //     }
  //   }
  // }

  // this is for the wallust triggered reloads
  IpcHandler {
    target: "shell"

    function reload(): void {
      Quickshell.reload(false)
    }
  }

  // inhibits the reload popup (since I have it reload on every background change)
  Connections {
    target: Quickshell

    function onReloadCompleted(): void {
      Quickshell.inhibitReloadPopup()
    }
  }

  Variants {
    model: Quickshell.screens

    Frame {
      required property var modelData
      screen: modelData
    }
  }

}
