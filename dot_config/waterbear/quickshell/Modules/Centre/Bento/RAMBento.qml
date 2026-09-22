import QtQuick
import Quickshell

import qs as Shell
import WallustTheme

import "../../../Widgets"
import "../../../Services/"

BentoSquare {
  id: root

  function colour(u) {
    return u >= 90 ? Colors.urgent
    : u >= 75 ? Colors.accent
    : Colors.text
  }

  function swapColour(u) {
    return u >= 80 ? Colors.urgent
    : u > 0 ? Colors.accent
    : Colors.textMuted
  }

  function colourMuted(u) {
    return u >= 90 ? Colors.urgent
    : u >= 75 ? Colors.accent
    : Colors.textMuted
  }

  function formatMemory(mib) {
    if (mib < 1024)
    return `${Math.round(mib)} MiB`

    return `${(mib / 1024).toFixed(1)} GiB`
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
          text: "󰘚"
          font: Shell.Style.uiFont
          color: colour(RAM.usage)
        }

        Text {
          text: "ram"
          font: Shell.Style.uiFont
          color: Colors.text
        }
      }

      // Memory capacity
      Item {
        width: parent.width
        height: 32

        Rectangle {
          anchors.fill: parent
          radius: height / 2
          color: Qt.alpha(Colors.text, 0.1)
        }

        Rectangle {
          width: parent.width * Math.max(0, Math.min(1, RAM.usage / 100))
          height: parent.height

          radius: height / 2
          color: colourMuted(RAM.usage)

          Behavior on width {
            NumberAnimation {
              duration: 100
              easing.type: Easing.OutCubic
            }
          }
        }

        Text {
          anchors.centerIn: parent

          text: `${formatMemory(RAM.usedMiB)} / ${formatMemory(RAM.totalMiB)}`
          font: Shell.Style.uiFont
          color: Colors.text
        }
      }

      // Available / cache
      Row {
        spacing: 12

        Text {
          text: `free ${formatMemory(RAM.availableMiB)}`
          font: Shell.Style.uiFont
          color: Colors.textMuted
        }

        Text {
          text: `cache ${formatMemory(RAM.cachedMiB)}`
          font: Shell.Style.uiFont
          color: Colors.textMuted
          opacity: 0.7
        }
      }

      // Swap / pressure
      Row {
        spacing: 12

        Text {
          text: RAM.swapTotalMiB > 0
          ? `swap ${formatMemory(RAM.swapUsedMiB)}`
          : "no swap"

          font: Shell.Style.uiFont
          color: swapColour(RAM.swapUsage)
        }

        Text {
          text: `pressure ${RAM.pressureSome.toFixed(1)}%`
          font: Shell.Style.uiFont

          color: RAM.pressureSome >= 10
          ? Colors.urgent
          : RAM.pressureSome > 1
          ? Colors.accent
          : Colors.textMuted
        }
      }
    }

    // Trends
    Column {
      anchors {
        bottom: parent.bottom
        horizontalCenter: parent.horizontalCenter
        bottomMargin: 20
      }

      width: parent.width * 0.8
      height: 32 * 2 + spacing
      spacing: 5

      Sparkline {
        width: parent.width
        height: 32

        samples: RAM.history
        valueKey: "usage"

        lineColor: colour(RAM.usage)
        minimumRange: 5
      }

      Sparkline {
        width: parent.width
        height: 32

        samples: RAM.history
        valueKey: "swapUsage"

        lineColor: swapColour(RAM.usage)
        minimumRange: 5
      }
    }
  }
}
