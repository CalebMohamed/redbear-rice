import qs as Shell
import QtQuick
import QtQuick.Controls
import WallustTheme

import "../Services"
import "./Common"

ActionText {
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

  property string tempIcon: icon(Temperature.temperature)
  property string tempColor: hovered ? Colors.accent : colour(Temperature.temperature)

  text: tempIcon
  textItem.font: Shell.Style.uiFont
  textItem.color: tempColor

  onClicked: CentreService.openCentre()
}
