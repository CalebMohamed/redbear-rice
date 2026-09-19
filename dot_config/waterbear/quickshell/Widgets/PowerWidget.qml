import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs as Shell
import WallustTheme

import "../Services"
import "./Common"

Text {
  id: root

  property bool popupOpen: false
  property bool highlight: false

  property string powerIcon: icon(Power.percentage, Power.charging)
  property string powerColor: colour(Power.percentage, Power.charging)

  function icon(p,c) {
    return p === null ? ""
    : c ? ""
    : p < 20 ? ""  
    : p < 40 ? ""
    : p < 60 ? ""  
    : p < 80 ? ""
    : ""  
  }

  function colour(p,c) {
    return highlight ? Colors.accent
    : p === null ? Colors.textMuted
    : c ? Colors.accent
    : p < 10 ? Colors.urgent
    : Colors.text
  }

  text: powerIcon

  font: Shell.Style.uiFont
  color: powerColor

  MouseArea { 
    anchors.fill: parent 
    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    // for visuals
    onEntered: highlight = true
    onExited: highlight = false

    onClicked: popupOpen = !popupOpen
  }

  EdgePopup {
    open: root.popupOpen
    onCloseRequested: root.popupOpen = false

    anchorItem: root

    popupWidth: Shell.Style.uiFont.pixelSize * 8
    popupHeight: Shell.Style.uiFont.pixelSize * 8

    edge: EdgePopup.Top
    alignment: EdgePopup.End

    ColumnLayout {
      id: content

      anchors.fill: parent
      spacing: 4

      Text {
        text: `${root.powerIcon} ${Power.percentage}%`

        font: Shell.Style.uiFont
        color: root.powerColor
      }

      Text {
        text: "lorem ipsum"

        font: Shell.Style.uiFont
        color: root.powerColor
      }
    }
  }
}
