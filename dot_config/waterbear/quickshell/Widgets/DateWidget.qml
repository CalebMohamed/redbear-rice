import QtQuick

import qs as Shell
import WallustTheme

import "../Services"
import "../Components"

Text {
  id: root

  property bool highlighted: false

  text: Time.date
  font: Shell.Style.uiFont
  color: highlighted ? Colors.accent : Colors.text

  MouseArea { 
    anchors.fill: parent 
    hoverEnabled: true 
    cursorShape: Qt.PointingHandCursor

    onEntered: highlighted = true 
    onExited: highlighted = false 

    onClicked: Time.toggleClock()
  }
}
