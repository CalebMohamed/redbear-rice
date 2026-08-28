import QtQuick
import QtQuick.Layouts
import Quickshell
import qs as Shell
import WallustTheme
import "../../Services"

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

  TimerPopup {
    id: popup
    open: root.popupOpen
    onCloseRequested: root.popupOpen = false
  }
}
