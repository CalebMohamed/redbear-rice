import QtQuick

import qs as Shell
import WallustTheme

import "../Services"
import "./Common"

Text {
  id: root

  property bool popupOpen: false
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

    onClicked: popupOpen = !popupOpen
  }

  EdgePopup {
    open: root.popupOpen
    onCloseRequested: root.popupOpen = false

    popupWidth: Shell.Style.uiFont.pixelSize * 16
    popupHeight: Shell.Style.uiFont.pixelSize * 1.5

    edge: EdgePopup.Top

    Item {
      anchors.centerIn: parent

      implicitWidth: dateTimeText.implicitWidth
      implicitHeight: dateTimeText.implicitHeight

      Text {
        id: dateTimeText
        anchors.fill: parent
        text: Time.dateTime
        font: Shell.Style.uiFont
        color: Colors.text
      }
    }
  }
}
