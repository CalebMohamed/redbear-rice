pragma Singleton

import Quickshell
import Quickshell.Services.UPower
import QtQuick

Singleton {
  id: root

  readonly property bool charging: UPower.displayDevice.state === 1
  readonly property var energy:
    UPower.displayDevice.ready
      ? Math.round(UPower.displayDevice.percentage) * 100
      : null
}
