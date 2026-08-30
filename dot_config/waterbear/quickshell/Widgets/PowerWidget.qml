import qs as Shell
import QtQuick
import QtQuick.Controls
import WallustTheme
import "../Services"

Text {
  property bool expanded: false
  property bool highlight: false

  function powerIcon(p, charging) {
    return p === null ? ""
      : charging ? ""
      : p < 20 ? ""  
      : p < 40 ? ""
      : p < 60 ? ""  
      : p < 80 ? ""
      : ""  
  }

  function powerColor(p, charging) {
    return highlight ? Colors.accent
    : p === null ? Colors.textMuted
    : charging ? Colors.accent
    : p < 10 ? Colors.urgent
    : Colors.text
  }

  text: {
    const icon = powerIcon(Power.percentage, Power.charging)

    if (!expanded)
    return icon

    return `${icon} ${Power.energy === null ? "N/A" : `${Power.percentage}%`}`
  }

  font: Shell.Style.uiFont
  color: powerColor(Power.percentage, Power.charging)

  MouseArea { 
    anchors.fill: parent 
    hoverEnabled: true
    onClicked: expanded = !expanded

    // for visuals
    onEntered: highlight = true
    onExited: highlight = false
  }
}
