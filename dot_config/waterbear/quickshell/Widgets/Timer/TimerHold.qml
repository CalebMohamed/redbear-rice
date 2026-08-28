import QtQuick
import qs as Shell
import WallustTheme

Item {
  id: root

  required property string icon
  property int repeatDelay: 450
  property int repeatInterval: 100

  signal clicked
  signal repeatTriggered

  // twice the size of an approximate em in the font
  implicitWidth: Shell.Style.iconFont.pixelSize * 1.5
  implicitHeight: Shell.Style.iconFont.pixelSize * 1.5

  Text {
    id: label

    anchors.centerIn: parent

    text: root.icon
    font: Shell.Style.iconFont

    color: mouseArea.containsMouse
    ? Colors.accent
    : Colors.text
  }

  MouseArea {
    id: mouseArea

    anchors.fill: parent

    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onClicked: root.clicked()

    onPressed: {
      repeatDelayTimer.start()
    }

    onReleased: {
      repeatDelayTimer.stop()
      repeatTimer.stop()
    }

    Timer {
      id: repeatDelayTimer

      interval: root.repeatDelay
      repeat: false

      onTriggered: repeatTimer.start()
    }

    Timer {
      id: repeatTimer

      interval: root.repeatInterval
      repeat: true

      onTriggered: root.repeatTriggered()
    }
  }
}
