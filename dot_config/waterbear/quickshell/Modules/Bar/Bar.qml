import Quickshell

Scope {
  Variants {
    // modelData <- list of screens
    model: Quickshell.screens 

    // implicit delegate (default property of Variants)
    // for each element in model, it creates an instantiation of the list of
    // nodes in delegate, and injects: modelData <- model[i]
    PanelWindow {
      required property var modelData
      screen: modelData

      anchors {
        top: true
        left: true
        right: true
      }

      implicitHeight: 30

      ClockWidget { 
        anchors.centerIn: parent 
      }
    }
  }
}
