pragma Singleton

import Quickshell
import QtQuick

Singleton {
  id: root

  readonly property string dateTime: {
    Qt.formatDateTime(clock.date, "ddd d MMM | hh:mm AP")
  }

  readonly property string date: Qt.formatDateTime(clock.date, "d MMM")
  readonly property string time: Qt.formatDateTime(clock.date, "hh:mm AP")

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }
}
