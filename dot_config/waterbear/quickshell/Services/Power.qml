pragma Singleton

import Quickshell
import QtQuick

Singleton {
  id: root
  // an expression can be broken across multiple lines using {}
  readonly property string energy: {
    power.percent + "%"
  }

  UPower {
    id: power
    precision: SystemClock.Minutes
  }
}
