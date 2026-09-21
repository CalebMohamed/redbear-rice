import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs as Shell
import WallustTheme

import "../Services"
import "../Components"

ActionText {
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

  text: icon(Power.percentage, Power.charging)
  textItem.font: Shell.Style.uiFont
  textItem.color: hovered ? Colors.accent : colour(Power.percentage, Power.charging)

  onClicked: CentreService.openCentre()
}
