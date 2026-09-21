import QtQuick
import Quickshell

import qs as Shell
import WallustTheme

import "../../../Widgets"
import "../../../Services"

BentoSquare {
  id: root

  function icon(p,c) {
    return p === null ? ""
    : c ? ""
    : p < 20 ? ""
    : p < 40 ? ""
    : p < 60 ? ""
    : p < 80 ? ""
    : ""
  }

  function colour(p,c) {
    return p === null ? Colors.textMuted
    : c ? Colors.accent
    : p < 10 ? Colors.urgent
    : Colors.text
  }

  function formatDuration(seconds) {
    if (seconds <= 0)
    return "—"

    const minutes = Math.round(seconds / 60)

    if (minutes < 60)
    return `${minutes}m`

    const hours = Math.floor(minutes / 60)
    const remainingMinutes = minutes % 60

    if (remainingMinutes === 0)
    return `${hours}h`

    return `${hours}h ${remainingMinutes}m`
  }

  Item {
    anchors.fill: parent

    // Header
    Column {
      anchors {
        top: parent.top
        left: parent.left
        right: parent.right
        margins: 20
      }

      spacing: 20

      Row {
        spacing: 8

        Text {
          text: icon(Power.percentage, Power.charging)
          font: Shell.Style.uiFont
          color: colour(Power.percentage, Power.charging)
        }

        Text {
          text: "power"
          font: Shell.Style.uiFont
          color: Colors.text
        }
      }

      Text {
        text: {
          if (Power.fullyCharged)
          return "Fully charged"

          if (Power.charging)
          return Power.timeToFullAvailable
          ? `${formatDuration(Power.timeToFullSeconds)} to full`
          : "Charging"

          return Power.timeToEmptyAvailable
          ? `${formatDuration(Power.timeToEmptySeconds)} remaining`
          : "On battery"
        }

        font: Shell.Style.uiFont
        color: Colors.textMuted
      }

      // Large battery bar
      Item {
        width: parent.width
        height: 32

        Rectangle {
          anchors.fill: parent
          radius: height / 2
          color: Colors.text
          opacity: 0.1
        }

        Rectangle {
          width: parent.width * Power.device.percentage
          height: parent.height

          radius: height / 2
          color: Power.charging ? Colors.accent : Colors.textMuted

          Behavior on width {
            NumberAnimation {
              duration: 100
              easing.type: Easing.OutCubic
            }
          }
        }

        Text {
          anchors.centerIn: parent

          text: `${Power.percentage}%`
          font: Shell.Style.uiFont
          color: Colors.text
        }
      }

      // Power flow / rate
      Row {
        spacing: 8

        Text {
          text: Power.charging
          ? `↑ ${Math.abs(Power.changeRate).toFixed(1)} W`
          : `↓ ${Math.abs(Power.changeRate).toFixed(1)} W`

          font: Shell.Style.uiFont
          color: Power.charging
          ? Colors.accent
          : Colors.textMuted
        }

        Text {
          text: Power.energy > 0
          ? `${Power.energy.toFixed(1)} Wh`
          : ""

          font: Shell.Style.uiFont
          color: Colors.textMuted
        }
      }

      Row {
        spacing: 8

        Text {
          text: ""
          font: Shell.Style.uiFont
          color: Colors.textMuted
        }

        Text {
          text: Power.healthSupported
          ? `${Math.round(Power.healthPercentage)}% health`
          : "Health unavailable"

          font: Shell.Style.uiFont
          color: Colors.textMuted
        }

        Text {
          visible: Power.healthSupported && Power.energyCapacity > 0

          text: `${Power.energyCapacity.toFixed(1)} Wh`
          font: Shell.Style.uiFont
          color: Colors.textMuted
          opacity: 0.7
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

      samples: Power.history
      valueKey: "percentage"
      lineColor: Power.charging
      ? Colors.accent
      : Colors.text
      minimumRange: 5
    }
  }
}
