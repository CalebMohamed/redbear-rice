import qs as Shell
import QtQuick
import QtQuick.Controls
import WallustTheme

import "../Services"
import "../Components"

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
    : t < 75 ? Colors.text
    : t < 90 ? Colors.accent
    : Colors.urgent
  }

  text: icon(Temperature.temperature)
  textItem.font: Shell.Style.uiFont
  textItem.color: hovered ? Colors.accent : colour(Temperature.temperature)

  onClicked: CentreService.openCentre()
}
