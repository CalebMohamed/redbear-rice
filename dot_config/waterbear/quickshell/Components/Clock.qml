import QtQuick

import qs as Shell
import WallustTheme

import "../Services"
import "../Components"

EdgePopup {
  open: Time.clockOpen
  onCloseRequested: Time.closeClock()

  popupWidth: Shell.Style.uiFont.pixelSize * 16
  popupHeight: Shell.Style.uiFont.pixelSize * 1.25

  edge: EdgePopup.Edge.Top

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
