import QtQuick
import Quickshell

import WallustTheme
import qs as Shell

Text {
  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  width: parent.width
  horizontalAlignment: Text.AlignHCenter

  text: Qt.formatDateTime(clock.date, "HH:mm")

  color: Colors.text
  font: Shell.Style.clockFont
}
