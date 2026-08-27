import Quickshell
import "./Services"

Scope {
  // Bar {}
  
  Variants {
    model: Quickshell.screens

    Frame {
      required property var modelData
      screen: modelData
    }
  }

}
