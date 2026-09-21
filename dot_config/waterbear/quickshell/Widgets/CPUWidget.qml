import qs as Shell
import QtQuick
import QtQuick.Controls
import WallustTheme

import "../Services"
import "../Components"

ActionText {
  id: root

  function colour(u) {
    return u === null ? Colors.textMuted
    : u >= 90 ? Colors.urgent
    : u >= 70 ? Colors.accent
    : Colors.text
  }

  text: "󰍛"
  textItem.font: Shell.Style.uiFont
  textItem.color: hovered ? Colors.accent : colour(CPU.usage)

  onClicked: CentreService.openCentre()
}
