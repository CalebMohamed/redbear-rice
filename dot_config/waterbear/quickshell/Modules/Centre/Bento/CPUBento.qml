import QtQuick
import Quickshell

import qs as Shell
import WallustTheme

import "../../../Widgets"
import "../../../Services"

BentoSquare {
  id: root

  function usageColour(usage) {
    return usage >= 90 ? Colors.urgent
    : usage >= 70 ? Colors.accent
    : Colors.text
  }

  function formatFrequency(mhz) {
    if (mhz <= 0)
    return "—"

    return mhz >= 1000
    ? `${(mhz / 1000).toFixed(1)} GHz`
    : `${Math.round(mhz)} MHz`
  }

  function tempIcon(t) {
    return t === null ? ""
    : t < 40 ? ""
    : t < 55 ? ""
    : t < 70 ? ""
    : t < 85 ? ""
    : ""
  }

  function tempColour(t) {
    return t === null ? Colors.textMuted
    : t < 75 ? Colors.textMuted
    : t < 90 ? Colors.accent
    : Colors.urgent
  }

  Item {
    anchors.fill: parent

    Column {
      anchors {
        top: parent.top
        left: parent.left
        right: parent.right
        margins: 20
      }

      spacing: 20

      // Header
      Row {
        spacing: 8

        Text {
          text: ""
          font: Shell.Style.uiFont
          color: usageColour(CPU.usage)
        }

        Text {
          text: "cpu"
          font: Shell.Style.uiFont
          color: Colors.text
        }
      }

      // Utilisation
      Row {
        width: parent.width
        height: utilGrid.height
        spacing: 10

        // Per-core utilisation
        Grid {
          id: utilGrid

          width: parent.width * 0.6
          height: rows * blockWidth + (rows - 1) * rowSpacing

          property var blockWidth: (width - (columns - 1) * columnSpacing) / 4

          columns: 4
          rows: Math.ceil(CPU.cores.length / columns)

          rowSpacing: 4
          columnSpacing: 4

          Repeater {
            model: CPU.cores

            Item {
              width: utilGrid.blockWidth
              height: width

              Rectangle {
                anchors {
                  left: parent.left
                  right: parent.right
                  bottom: parent.bottom
                }

                height: parent.height * Math.max(0, Math.min(1, modelData.usage / 100))

                color: usageColour(modelData.usage)

                Behavior on height {
                  NumberAnimation {
                    duration: 100
                    easing.type: Easing.OutCubic
                  }
                }
              }

              Rectangle {
                anchors.fill: parent
                color: Colors.text
                opacity: 0.1
              }
            }
          }
        }

        // Overall utilisation
        Item {
          width: parent.width - utilGrid.width - parent.spacing
          height: parent.height

          Item {
            anchors.centerIn: parent

            width: Math.min(parent.width, parent.height)
            height: width

            Canvas {
              id: usageRing
              anchors.fill: parent

              property real usage: CPU.usage
              property real lineWidth: 2
              property color ringColor: usageColour(CPU.usage)

              onUsageChanged: requestPaint()
              onRingColorChanged: requestPaint()

              onPaint: {
                const ctx = getContext("2d")
                ctx.reset()

                const centerX = width / 2
                const centerY = height / 2
                const radius = Math.min(width, height) / 2 - lineWidth / 2

                // Start at 12 o'clock.
                const start = -Math.PI / 2
                const end = start + 2 * Math.PI * Math.min(usage, 100) / 100

                // Background ring.
                ctx.beginPath()
                ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI)
                ctx.lineWidth = lineWidth
                ctx.strokeStyle = Qt.alpha(Colors.text, 0.1)
                ctx.stroke()

                // Usage ring.
                ctx.beginPath()
                ctx.arc(centerX, centerY, radius, start, end)
                ctx.lineWidth = lineWidth
                ctx.lineCap = "round"
                ctx.strokeStyle = ringColor
                ctx.stroke()
              }
            }

            Text {
              anchors.centerIn: parent

              text: `${Math.round(CPU.usage)}%`
              font: Shell.Style.uiFont
              color: usageColour(CPU.usage)
            }
          }
        }
      }

      // Frequency / load
      Row {
        spacing: 12

        Text {
          text: `󰓅 ${formatFrequency(CPU.frequencyMHz)}`
          font: Shell.Style.uiFont
          color: Colors.textMuted
        }

        Text {
          text: ` ${CPU.load1.toFixed(2)} load`
          font: Shell.Style.uiFont
          color: Colors.textMuted
        }

        Text {
          text: tempIcon(Temperature.tempIcon)
          font: Shell.Style.uiFont
          color: tempColour(Temperature.temperature)
        }

        Text {
          text: Temperature.ready
          ? `${Math.round(Temperature.temperature)}°C`
          : "Temperature unavailable"

          font: Shell.Style.uiFont
          color: tempColour(Temperature.temperature)
        }
      }

      // CPU utilisation breakdown
      Column {
        width: parent.width
        spacing: 6

        Rectangle {
          width: parent.width
          height: 8
          color: Qt.alpha(Colors.text, 0.1)

          Row {
            anchors.fill: parent

            Rectangle {
              width: parent.width * CPU.userUsage / 100
              height: parent.height
              color: Colors.text
            }

            Rectangle {
              width: parent.width * CPU.systemUsage / 100
              height: parent.height
              color: Colors.accent
            }

            Rectangle {
              width: parent.width * CPU.iowaitUsage / 100
              height: parent.height
              color: Colors.urgent
            }
          }
        }

        Row {
          width: parent.width
          spacing: 12

          Text {
            text: `user ${Math.round(CPU.userUsage)}%`
            font: Shell.Style.uiFont
            color: Colors.text
          }

          Text {
            text: `sys ${Math.round(CPU.systemUsage)}%`
            font: Shell.Style.uiFont
            color: Colors.accent
          }

          Text {
            text: `io ${Math.round(CPU.iowaitUsage)}%`
            font: Shell.Style.uiFont
            color: Colors.urgent
          }
        }
      }
    }

    // Trend
    Sparkline {
      anchors {
        bottom: parent.bottom
        horizontalCenter: parent.horizontalCenter
        bottomMargin: 20
      }

      width: parent.width * 0.8
      height: 32

      samples: CPU.history
      valueKey: "usage"

      lineColor: usageColour(CPU.usage)

      minimumRange: 10
    }
  }
}
