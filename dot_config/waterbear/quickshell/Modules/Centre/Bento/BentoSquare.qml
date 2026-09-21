import QtQuick
import Quickshell

import qs as Shell
import WallustTheme

Rectangle {
  required property var container

  width: (container.height - 40) / 3
  height: width

  radius: Shell.Style.cornerRadius
  color: Colors.background
  opacity: 0.85

  MouseArea {
    anchors.fill: parent

    onClicked: mouse => mouse.accepted = true
  }
}
