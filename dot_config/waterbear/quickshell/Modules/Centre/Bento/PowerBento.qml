import QtQuick
import Quickshell

import qs as Shell
import WallustTheme

import "../../../Services/"

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

  Item {
    anchors.fill: parent
    anchors.margins: 12

    Text {
      text: `${icon(Power.percentage, Power.charging)} ${Power.percentage}%`
      font: Shell.Style.uiFont
      color: colour(Power.percentage, Power.charging)
    }
  }
}
