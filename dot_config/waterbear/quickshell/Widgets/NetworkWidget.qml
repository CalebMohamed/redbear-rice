import qs as Shell
import QtQuick
import QtQuick.Controls
import WallustTheme
import "../Services"

Text {
  property bool expanded: false
  property bool highlight: false

  function networkIcon(connected, wired, strength) {
    return (!connected) ? "󰤭"
      : wired ? "󰈀"
      : strength >= 0.90 ? "󰤨"  
      : strength >= 0.75 ? "󰤥"  
      : strength >= 0.50 ? "󰤢"
      : strength >= 0.25 ? "󰤟"  
      : "󰤯"  
  }

  // i did have more colours but there's no need
  function networkColor(connected, strength) {
    return highlight ? Colors.accent
      : !connected ? Colors.textMuted
      : Colors.text
  }

  text: {
    const icon = networkIcon(Network.connected, Network.wired, Network.strength)

    if (!expanded)
    return icon

    return `${icon} ${Network.connected ? Network.networkName : "disconnected"}`
  }

  font: Shell.Style.uiFont
  color: networkColor(Network.connected, Network.wired, Network.strength)

  MouseArea { 
    anchors.fill: parent 
    hoverEnabled: true
    onClicked: expanded = !expanded

    // for visuals
    onEntered: highlight = true
    onExited: highlight = false
  }
}
