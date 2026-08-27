import QtQml
import Quickshell
import Quickshell.Io
import "./Services"

Scope {
  // this is for the wallust triggered reloads
  IpcHandler {
    target: "shell"

    function reload(): void {
      Quickshell.reload(false)
    }
  }

  // inhibits the reload popup (since I have it reload on every background change)
  Connections {
    target: Quickshell

    function onReloadCompleted(): void {
      Quickshell.inhibitReloadPopup()
    }
  }

  Variants {
    model: Quickshell.screens

    Frame {
      required property var modelData
      screen: modelData
    }
  }

}
