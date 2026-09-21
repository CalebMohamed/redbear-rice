import QtQuick
import Quickshell

import qs as Shell
import WallustTheme

import "../../../Widgets"
import "../../../Services/"

BentoSquare {
  id: root

  function icon(t) {
    return t === null ? ""
    : t < 40 ? ""
    : t < 55 ? ""
    : t < 70 ? ""
    : t < 85 ? ""
    : ""
  }

  function colour(t) {
    return t === null ? Colors.textMuted
    : t < 75 ? Colors.text
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
        margins: 12
      }

      spacing: 12

      Text {
        text: `${icon(Temperature.temperature)} ${Temperature.temperature}°C`
        font: Shell.Style.uiFont
        color: colour(Temperature.temperature)
      }
    }

    Sparkline {
      anchors {
        bottom: parent.bottom
        horizontalCenter: parent.horizontalCenter
        bottomMargin: 12
      }

      width: parent.width * 0.8
      height: 32

      samples: Temperature.history
      valueKey: "temperature"
      lineColor: Power.charging ? Colors.accent : Colors.text
      minimumRange: 5
    }
  }
}
