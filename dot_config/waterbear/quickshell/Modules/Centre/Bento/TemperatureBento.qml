import QtQuick
import Quickshell

import qs as Shell
import WallustTheme

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
    : t < 55 ? Colors.text 
    : Colors.urgent
  }

  Item {
    anchors.fill: parent
    anchors.margins: 12

    Text {
      text: `${icon(Temperature.temperature)} ${Temperature.temperature === null ? "N/A" : `${Temperature.temperature}°C`}`
      font: Shell.Style.uiFont
      color: colour(Power.percentage, Power.charging)
    }
  }
}
