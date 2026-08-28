import QtQuick
import "../Services"
import qs as Shell
import WallustTheme

Text {
  property bool showTime: false

  text: showTime ? Time.time : Time.date
  font: Shell.Style.uiFont
  color: Colors.text

  MouseArea { 
    anchors.fill: parent 
    hoverEnabled: true 
    onEntered: showTime = true 
    onExited: showTime = false 
  }
}
