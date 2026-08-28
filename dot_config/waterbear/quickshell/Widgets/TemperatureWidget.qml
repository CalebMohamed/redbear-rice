import qs as Shell
import QtQuick
import QtQuick.Controls
import WallustTheme
import "../Services"

Text {
  property bool expanded: false
  property bool highlight: false

  function tempIcon(t) {
    return t === null ? ""
      : t < 40 ? ""
      : t < 55 ? ""
      : t < 70 ? ""
      : t < 85 ? ""
      : ""
  }

  function tempColor(t) {
    return highlight ? Colors.accent
      : t === null ? Colors.textMuted
      : t < 55 ? Colors.text 
      : Colors.urgent
  }

  text: {
    const icon = tempIcon(Temperature.temperature)

    if (!expanded) return icon

    return `${icon} ${Temperature.temperature === null ? "N/A" : `${Temperature.temperature}°C`}`
  }

  font: Shell.Style.uiFont
  color: tempColor(Temperature.temperature)

  MouseArea { 
    anchors.fill: parent 
    hoverEnabled: true 
    onClicked: expanded = !expanded

    // for visuals
    onEntered: highlight = true
    onExited: highlight = false
  }
}
