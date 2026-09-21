import QtQuick
import QtQuick.Controls

import qs as Shell
import WallustTheme

import "../Services"

Text {
  property bool highlight: false

  text: NotificationService.needsAttention ? "" : ""

  font: Shell.Style.uiFont
  color: highlight ? Colors.text
  : NotificationService.hasUrgent ? Colors.urgent 
  : Colors.accent 

  MouseArea { 
    anchors.fill: parent 
    hoverEnabled: true
    onClicked: CentreService.toggleCentre()

    // for visuals
    onEntered: highlight = true
    onExited: highlight = false
  }
}
