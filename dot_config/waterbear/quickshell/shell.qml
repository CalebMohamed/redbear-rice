import QtQuick
import QtQml

import Quickshell
import Quickshell.Io
import Quickshell.Networking

import "./Services"
import "./Widgets/OSD"
import "./Modules/notifications"

Scope {
  // this is for the wallust triggered reloads
  IpcHandler {
    target: "shell"

    function reload(): void {
      Quickshell.reload(false)
    }
  }

  IpcHandler {
    target: "osd"

    function volumeUp(): void {
      Audio.volumeUp()
      OSD.showVolume()
    }

    function volumeDown(): void {
      Audio.volumeDown()
      OSD.showVolume()
    }

    function volumeMute(): void {
      Audio.toggleMute()
      OSD.showVolume()
    }

    function brightnessUp(): void {
      Brightness.brightnessUp()
      OSD.showBrightness()
    }

    function brightnessDown(): void {
      Brightness.brightnessDown()
      OSD.showBrightness()
    }
  }

  // inhibits the reload popup (since I have it reload on every background change)
  Connections {
    target: Quickshell

    function onReloadCompleted(): void {
      Quickshell.inhibitReloadPopup()
    }
  }

  IpcHandler {
    target: "notifications"

    function toggle() {
      NotificationService.toggleCentre()
    }

    function open() {
      NotificationService.openCentre()
    }

    function close() {
      NotificationService.closeCentre()
    }
  }

  NotificationCentre {
    screen: NotificationService.centreScreen
  }

  Variants {
    model: Quickshell.screens

    Scope {
      required property var modelData

      Frame {
        screen: modelData
      }

      FrameWidgets {
        screen: modelData
      }

      MediaOSD {
        screen: modelData
      }
    }
  }
}
