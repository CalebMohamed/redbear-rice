import QtQuick
import Quickshell

import qs as Shell
import WallustTheme

import "../../../Services/"

BentoSquare {
  id: root

  function colour(c) {
    return c === null ? Colors.textMuted
    : c >= 90 ? Colors.urgent
    : c >= 70 ? Colors.accent
    : Colors.text
  }


  Item {
    anchors.fill: parent
    anchors.margins: 12

    Text {
      text: `󰋊 ${Storage.usage === null ? "N/A" : `${Storage.usage}%`}`
      font: Shell.Style.uiFont
      color: colour(Storage.usage)
    }
  }
}
