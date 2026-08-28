import qs as Shell
import QtQuick
import QtQuick.Controls
import WallustTheme
import "../Services"

Text {
  property bool expanded: false
  property bool highlight: false

  function ramColor(u) {
    return highlight ? Colors.accent
      : u === null ? Colors.textMuted
      : u >= 90 ? Colors.urgent
      : u >= 70 ? Colors.accent
      : Colors.text
  }

  text: {
    if (!expanded) return "󰘚"
    return `󰘚 ${RAM.usage === null ? "N/A" : `${RAM.usage}%`}`
  }

  font: Shell.Style.uiFont
  color: ramColor(RAM.usage)

  MouseArea { 
    anchors.fill: parent 
    hoverEnabled: true 
    onClicked: expanded = !expanded

    // for visuals
    onEntered: highlight = true
    onExited: highlight = false
  }
}
