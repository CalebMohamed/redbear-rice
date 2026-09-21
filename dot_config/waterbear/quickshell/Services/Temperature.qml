pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
  id: root

  // Current temperature in °C.
  readonly property real temperature: _temperature
  readonly property bool ready: _ready

  property real _temperature: 0
  property bool _ready: false

  // Recent samples, oldest -> newest.
  //
  // Each sample contains:
  //   timestamp    - Unix timestamp in milliseconds
  //   temperature  - temperature in °C
  readonly property var history: _history

  property var _history: []

  readonly property int historySize: 60
  readonly property int sampleIntervalMs: 5 * 1000

  FileView {
    id: sensorFile

    path: "/sys/class/thermal/thermal_zone7/temp"
    watchChanges: false

    onLoaded: {
      const rawTemperature = parseInt(text().trim(), 10)

      if (Number.isNaN(rawTemperature))
      return

      root._temperature = Math.round(rawTemperature / 1000)
      root._ready = true

      root.recordSample()
    }
  }

  Timer {
    interval: root.sampleIntervalMs
    running: true
    repeat: true

    onTriggered: sensorFile.reload()
  }

  function recordSample() {
    if (!root.ready)
    return

    const next = root._history.slice()

    next.push({
      timestamp: Date.now(),
      temperature: root._temperature
    })

    while (next.length > root.historySize)
    next.shift()

    root._history = next
  }

  Component.onCompleted: sensorFile.reload()
}
