import qs as Shell
import QtQuick
import QtQuick.Controls
import WallustTheme

import "../Services"
import "./Common"

ActionText {
  id: root

  function colour(c) {
    return c === null ? Colors.textMuted
    : c >= 90 ? Colors.urgent
    : c >= 70 ? Colors.accent
    : Colors.text
  }

  property string storageColor: hovered ? Colors.accent : colour(Storage.usage)

  text: "󰋊"
  textItem.font: Shell.Style.uiFont
  textItem.color: storageColor

  onClicked: CentreService.openCentre()
}
