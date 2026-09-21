import qs as Shell
import QtQuick
import QtQuick.Controls
import WallustTheme

import "../Services"
import "../Components"

ActionText {
  id: root

  function colour(c) {
    return c === null ? Colors.textMuted
    : c >= 90 ? Colors.urgent
    : c >= 70 ? Colors.accent
    : Colors.text
  }

  text: "󰋊"
  textItem.font: Shell.Style.uiFont
  textItem.color: hovered ? Colors.accent : colour(Storage.usage)

  onClicked: CentreService.openCentre()
}
