pragma Singleton

import Quickshell
import Quickshell.Services.UPower
import QtQuick

Singleton {
  id: root

  readonly property var device: UPower.displayDevice

  // State
  readonly property bool ready: device.ready
  readonly property bool charging: device.state === UPowerDeviceState.Charging
  readonly property bool discharging: device.state === UPowerDeviceState.Discharging
  readonly property bool fullyCharged: device.state === UPowerDeviceState.FullyCharged
  readonly property bool onBattery: UPower.onBattery

  // Charge
  readonly property int percentage: ready ? Math.round(device.percentage * 100) : 0
  readonly property real energy: ready ? device.energy : 0
  readonly property real energyCapacity: ready ? device.energyCapacity : 0

  // Power, Positive while charging, negative while discharging.
  readonly property real changeRate: ready ? device.changeRate : 0

  // Time estimates, in seconds.
  readonly property int timeToFullSeconds: ready && charging ? Math.round(device.timeToFull) : 0
  readonly property int timeToEmptySeconds: ready && discharging ? Math.round(device.timeToEmpty) : 0
  readonly property bool timeToFullAvailable: ready && charging && device.timeToFull > 0
  readonly property bool timeToEmptyAvailable: ready && discharging && device.timeToEmpty > 0

  // Battery health
  readonly property bool healthSupported: ready && device.healthSupported
  readonly property real healthPercentage: healthSupported ? device.healthPercentage : 0

  // Recent history
  // Oldest sample -> newest sample.
  readonly property var percentageHistory: history

  // Each sample has:
  //   timestamp   - Unix timestamp in milliseconds
  //   percentage  - battery percentage, 0..100
  //   power       - battery power in watts
  //   energy      - current stored energy in Wh
  property var history: []

  readonly property int historySize: 60
  readonly property int sampleIntervalMs: 30 * 1000

  // notifications
  readonly property int lowBatteryThreshold: 20
  readonly property int criticalBatteryThreshold: 10

  property bool _lowBatteryNotified: false
  property bool _criticalBatteryNotified: false

  Timer {
    interval: root.sampleIntervalMs
    running: root.ready
    repeat: true

    onTriggered: {
      root.recordSample()
      root.checkBatteryNotifications()
    }
  }

  function recordSample() {
    if (!device.ready)
    return

    const next = root.history.slice()

    next.push({
      timestamp: Date.now(),
      percentage: Math.round(device.percentage * 100),
      power: device.changeRate,
      energy: device.energy
    })

    while (next.length > root.historySize)
    next.shift()

    root.history = next
  }

  function checkBatteryNotifications() {
    if (!root.ready)
    return

    // Reset notification state whenever we're charging.
    if (root.charging) {
      root._lowBatteryNotified = false
      root._criticalBatteryNotified = false
      return
    }

    if (!root.discharging)
    return

    if (
      root.percentage <= root.criticalBatteryThreshold &&
      !root._criticalBatteryNotified
    ) {
      Notifier.notify(
        "battery critical",
        `${root.percentage}% remaining`,
        "critical"
      )

      root._criticalBatteryNotified = true
      root._lowBatteryNotified = true
      return
    }

    if (
      root.percentage <= root.lowBatteryThreshold &&
      !root._lowBatteryNotified
    ) {
      Notifier.notify(
        "battery low",
        `${root.percentage}% remaining`,
        "low"
      )

      root._lowBatteryNotified = true
    }
  }

  Component.onCompleted: {
    if (device.ready)
    recordSample()
  }
}
