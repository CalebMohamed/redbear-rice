import qs as Shell
import QtQuick
import QtQuick.Controls
import WallustTheme

import "../Services"
import "./Common"

ActionText {
  id: root

  function colour(u) {
    return u === null ? Colors.textMuted
    : u >= 90 ? Colors.urgent
    : u >= 70 ? Colors.accent
    : Colors.text
  }

  property string cpuColor: hovered ? Colors.accent : colour(CPU.usage)

  text: "󰍛"
  textItem.font: Shell.Style.uiFont
  textItem.color: cpuColor

  onClicked: CentreService.openCentre()
}
