import QtQuick
import qs as Shell
import WallustTheme

Item {
  id: root

  required property string icon
  property bool highlighted: false

  signal clicked
  signal pressed
  signal released

  // twice the size of an approximate em in the font
  implicitWidth: Shell.Style.iconFont.pixelSize * 1.5
  implicitHeight: Shell.Style.iconFont.pixelSize * 1.5

  Text {
    id: label

    anchors.centerIn: parent

    text: root.icon
    font: Shell.Style.iconFont

    color: root.highlighted
    ? Colors.accent
    : Colors.text
  }

  MouseArea {
    anchors.fill: parent

    hoverEnabled: true
    cursorShape: Qt.PointingHandCursor

    onEntered: root.highlighted = true
    onExited: root.highlighted = false

    onClicked: root.clicked()
    onPressed: root.pressed()
    onReleased: root.released()
  }
}
