import qs as Shell
import QtQuick
import QtQuick.Controls
import WallustTheme
import "../Services"

Text {
  property bool expanded: false
  property bool highlight: false

  function storageColor(c) {
    return highlight ? Colors.accent
      : c === null ? Colors.textMuted
      : c >= 90 ? Colors.urgent
      : c >= 70 ? Colors.accent
      : Colors.text
  }

  text: {
    if (!expanded) return "󰋊"
    return `󰋊 ${Storage.usage === null ? "N/A" : `${Storage.usage}%`}`
  }

  font: Shell.Style.uiFont
  color: storageColor(Storage.usage)

  MouseArea { 
    anchors.fill: parent 
    hoverEnabled: true 
    onClicked: expanded = !expanded

    // for visuals
    onEntered: highlight = true
    onExited: highlight = false
  }
}
