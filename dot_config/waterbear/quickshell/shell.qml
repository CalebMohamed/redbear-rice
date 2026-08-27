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

  Variants {
    model: Quickshell.screens

    Frame {
      required property var modelData
      screen: modelData
    }
  }

}
