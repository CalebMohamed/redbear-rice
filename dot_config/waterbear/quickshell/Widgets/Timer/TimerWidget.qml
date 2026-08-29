import QtQuick
import QtQuick.Layouts
import Quickshell
import qs as Shell
import WallustTheme
import "../../Services"
import "../Common"

Item {
  id: root

  property bool popupOpen: false
  property bool highlighted: false

  implicitWidth: timerText.implicitWidth
  implicitHeight: timerText.implicitHeight

  Text {
    id: timerText

    anchors.centerIn: parent

    text: TimerService.display

    font: Shell.Style.uiFont
    color: root.highlighted ? Colors.accent
      : TimerService.finished ? Colors.accent
      : TimerService.running ? Colors.text
      : Colors.textMuted
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

    popupWidth: Shell.Style.iconFont.pixelSize * 6
    popupHeight: Shell.Style.iconFont.pixelSize * 6

    edge: EdgePopup.Right

    ColumnLayout {
      id: content

      anchors.fill: parent
      spacing: 4

      RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: Shell.Style.iconFont.pixelSize * 2

        spacing: 4

        Item { Layout.fillWidth: true }

        TimerHold {
          icon: ""
          onClicked: TimerService.adjustMinutes(-1)
          onRepeatTriggered: TimerService.adjustMinutes(-1)
        }

        TimerControl {
          icon: TimerService.running ? "" : ""
          onClicked: TimerService.toggleRunning()
        }

        TimerHold {
          icon: ""
          onClicked: TimerService.adjustMinutes(1)
          onRepeatTriggered: TimerService.adjustMinutes(1)
        }

        Item { Layout.fillWidth: true }
      }

      Item { 
        id: timerDisplay

        property bool highlighted: false

        Layout.fillWidth: true 
        implicitHeight: timerPopupText.implicitHeight

        Text {
          id: timerPopupText
          anchors.centerIn: parent

          text: TimerService.display

          font: Shell.Style.uiFont
          color: timerDisplay.highlighted ? Colors.accent
          : TimerService.finished ? Colors.accent
          : TimerService.running ? Colors.text
          : Colors.textMuted
        }

        MouseArea {
          anchors.fill: parent

          hoverEnabled: true
          cursorShape: Qt.PointingHandCursor

          onEntered: timerDisplay.highlighted = true
          onExited: timerDisplay.highlighted = false

          onClicked: { TimerService.toggleRunning(); root.popupOpen = false }
        }
      }

      RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: Shell.Style.iconFont.pixelSize * 2

        spacing: 4

        Item { Layout.fillWidth: true }

        TimerControl {
          icon: "󰔟"
          onClicked: TimerService.setPreset(10)
        }

        TimerControl {
          icon: "󰔛"
          onClicked: TimerService.setPreset(30)
        }

        TimerControl {
          icon: "󰔚"
          onClicked: TimerService.setPreset(60)
        }

        Item { Layout.fillWidth: true }
      }
    }
  }
}
