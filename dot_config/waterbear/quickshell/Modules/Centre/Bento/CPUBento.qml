import QtQuick
import Quickshell

import qs as Shell
import WallustTheme

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
    anchors.margins: 12

    Text {
      text: `󰍛 ${CPU.usage === null ? "N/A" : `${CPU.usage}%`}`
      font: Shell.Style.uiFont
      color: colour(CPU.usage)
    }
  }
}
