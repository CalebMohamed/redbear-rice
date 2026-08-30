pragma Singleton

import Quickshell
import Quickshell.Services.UPower
import QtQuick

Singleton {
  id: root

  readonly property bool charging: UPower.displayDevice.state === UPowerDeviceState.Charging
  readonly property int percentage: UPower.displayDevice.ready ? Math.round(UPower.displayDevice.percentage * 100) : 0
  readonly property real energy: UPower.displayDevice.ready ? UPower.displayDevice.energy : 0 
}
