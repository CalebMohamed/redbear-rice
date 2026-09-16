import QtQuick
import QtQuick.Layouts

import Quickshell
import Quickshell.Services.SystemTray

import qs as Shell
import WallustTheme

import "../Services"
import "./Common"


Item {
  id: root

  property bool popupOpen: false
  property bool highlighted: false

  implicitWidth: trayIcon.implicitWidth
  implicitHeight: trayIcon.implicitHeight

  Text {
    id: trayIcon
    anchors.centerIn: parent

    text: "󰀻"

    font: Shell.Style.uiFont
    color: root.highlighted ? Colors.accent : Colors.text
  }

  MouseArea {
    anchors.fill: parent

    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onEntered: root.highlighted = true
    onExited: root.highlighted = false

    onClicked: root.popupOpen = !root.popupOpen
  }

  EdgePopup {
    open: root.popupOpen
    onCloseRequested: root.popupOpen = false

    popupWidth: Shell.Style.iconFont.pixelSize * 1 + 6
    popupHeight: Shell.Style.iconFont.pixelSize * SystemTray.items.values.length + 6

    edge: EdgePopup.Left

    ColumnLayout {
      spacing: 12

      Repeater {
        model: SystemTray.items

        delegate: Item {
          required property var modelData

          width: Shell.Style.iconFont.pixelSize
          height: Shell.Style.iconFont.pixelSize

          Image {
            anchors.fill: parent
            anchors.margins: 3
            source: modelData.icon
            fillMode: Image.PreserveAspectFit
          }

          MouseArea {
            anchors.fill: parent

            onClicked: mouse => {
              if (mouse.button === Qt.LeftButton) {
                modelData.activate()
              }
              else if (mouse.button === Qt.MiddleButton) {
                modelData.secondaryActivate()
              }
              // else if (mouse.button === Qt.RightButton && modelData.hasMenu)
              // modelData.display(
              //   /* containing window */,
              //   mouse.x,
              //   mouse.y
              // )
            }

            acceptedButtons:
            Qt.LeftButton |
            Qt.MiddleButton |
            Qt.RightButton
          }
        }
      }
    }
  }
}
