// Bar.qml
import Quickshell
import "./Widgets"

Scope {
  Variants {
    model: Quickshell.screens

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

      PowerWidget {
        anchors.centerIn: parent
      }

      TemperatureWidget {
        anchors.centerIn: parent
      }

      WorkspaceIndicator {
        anchors.centerIn: parent
      }
    }
  }
}
