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

  property string ramColor: hovered ? Colors.accent : colour(RAM.usage)

  text: "󰘚"

  textItem.font: Shell.Style.uiFont
  textItem.color: ramColor

  onClicked: CentreService.openCentre()
}

