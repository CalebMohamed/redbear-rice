pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland

Singleton {
  id: root

  readonly property string dateTime: Qt.formatDateTime(clock.date, "ddd d MMM | hh:mm AP")
  readonly property string date: Qt.formatDateTime(clock.date, "d MMM")
  readonly property string time: Qt.formatDateTime(clock.date, "hh:mm AP")

  // is also responsible for whether the clock is showing at the top of the screen
  // and determines which screen the clock should open on
  property bool clockOpen: false
  property var clockScreen: null

  signal clockOpened()

  SystemClock {
    id: clock
    precision: SystemClock.Minutes
  }

  // Public mutations ----------------------------------------------------

  function openClock() {
    // works out which hyprland monitor is focused
    const monitor = Hyprland.focusedMonitor

    if (monitor !== null) {
      for (const screen of Quickshell.screens) {
        const hm = Hyprland.monitorFor(screen)

        if (hm !== null && hm.id === monitor.id) {
          clockScreen = screen
          break
        }
      }
    }

    clockOpen = true
    clockOpened()
  }

  function closeClock() {
    clockOpen = false
  }

  function toggleClock() {
    if (clockOpen)
    closeClock()
    else
    openClock()
  }
}
