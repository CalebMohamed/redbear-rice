import QtQuick
import Quickshell

import qs as Shell
import WallustTheme

import "../../../Widgets"
import "../../../Services/"

BentoSquare {
  id: root

  function colour(u) {
    return u === null ? Colors.textMuted
    : u >= 90 ? Colors.urgent
    : u >= 70 ? Colors.accent
    : Colors.text
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
        text: `󰘚 ${RAM.usage === null ? "N/A" : `${RAM.usage}%`}`
        font: Shell.Style.uiFont
        color: colour(RAM.usage)
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

      samples: RAM.history
      valueKey: "usage"
      lineColor: Colors.text
      minimumRange: 5
    }
  }
}
