pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  id: root

  property int current: 0
  property int maximum: 0

  readonly property real value: maximum > 0 ? current / maximum : 0
  readonly property int percentage: Math.round(value * 100)
  readonly property bool available: maximum > 0

  Process {
    id: getBrightness

    command: ["brightnessctl", "-m"]

    stdout: StdioCollector {
      onStreamFinished: {
        const fields = text.trim().split(",")

        if (fields.length < 5)
        return

        const newCurrent = Number(fields[2])
        const newMaximum = Number(fields[4])

        if (isNaN(newCurrent) || isNaN(newMaximum))
        return

        root.current = newCurrent
        root.maximum = newMaximum
      }
    }
  }

  Process {
    id: adjustBrightness

    onExited: {
      root.refresh()
    }
  }

  function refresh(): void {
    getBrightness.running = true
  }

  function change(delta: int): void {
    adjustBrightness.exec({
      command: [
        "brightnessctl",
        "set",
        `${Math.abs(delta)}%${delta >= 0 ? "+" : "-"}`
      ]
    })
  }

  function brightnessUp(): void {
    change(5)
  }

  function brightnessDown(): void {
    change(-5)
  }

  function setPercentage(percent: int): void {
    const clamped = Math.max(0, Math.min(100, percent))

    adjustBrightness.exec({
      command: [
        "brightnessctl",
        "set",
        `${clamped}%`
      ]
    })
  }

  Component.onCompleted: {
    refresh()
  }
}
