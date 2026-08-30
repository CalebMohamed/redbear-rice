pragma Singleton

import Quickshell
import Quickshell.Hyprland
import QtQml

Singleton {
  id: root

  // {
  //     screen: ShellScreen,
  //     osd: MediaOSD
  // }
  property var _instances: []

  function register(screen, osd): void {
    // Avoid duplicate registration.
    for (const instance of _instances) {
      if (instance.osd === osd)
      return
    }

    _instances.push({
      screen: screen,
      osd: osd
    })
  }

  function unregister(osd): void {
    for (let i = 0; i < _instances.length; ++i) {
      if (_instances[i].osd === osd) {
        _instances.splice(i, 1)
        return
      }
    }
  }

  function focused(): var {
    const monitor = Hyprland.focusedMonitor

    if (!monitor)
    return null

    for (const instance of _instances) {
      const instanceMonitor = Hyprland.monitorFor(instance.screen)

      if (instanceMonitor === monitor)
      return instance.osd
    }

    return null
  }

  function showVolume(): void {
    const osd = focused()

    if (osd)
    osd.showVolume()
  }

  function showBrightness(): void {
    const osd = focused()

    if (osd)
    osd.showBrightness()
  }

  function close(): void {
    const osd = focused()

    if (osd)
    osd.open = false
  }
}
