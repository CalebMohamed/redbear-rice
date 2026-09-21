pragma Singleton

import Quickshell
import Quickshell.Hyprland

Singleton {
  id: root
  // this service is the authorative location of whether the Centre is open so
  // that the widget can hook into it without having to be connected directly
  // to it
  property bool centreOpen: false

  // the service also determines what screen the centre should open on
  property var centreScreen: null

  signal centreOpened()

  // Public mutations ----------------------------------------------------

  function openCentre() {
    // works out which hyprland monitor is focused
    const monitor = Hyprland.focusedMonitor

    if (monitor !== null) {
      for (const screen of Quickshell.screens) {
        const hm = Hyprland.monitorFor(screen)

        if (hm !== null && hm.id === monitor.id) {
          centreScreen = screen
          break
        }
      }
    }

    centreOpen = true

    NotificationService.makeReady()
    centreOpened()
  }

  function closeCentre() {
    centreOpen = false
  }

  function toggleCentre() {
    if (centreOpen)
    closeCentre()
    else
    openCentre()
  }
}
