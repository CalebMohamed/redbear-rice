// Bar.qml
import Quickshell
import QtQuick
import QtQuick.Layouts
import "./Widgets"

Scope {
  Variants {
    model: Quickshell.screens

    PanelWindow {
      required property var modelData
      screen: modelData

      color: "transparent"
      implicitHeight: 30

      anchors {
        top: true
        left: true
        right: true
      }

      margins {
        top: 10
        left: 20
        right: 20
      }

      Rectangle {
        anchors.fill: parent

        radius: height / 2 // for pill shape

        color: "#C01E1E2E"

        RowLayout {
          anchors.fill: parent
          spacing: 2

          ClockWidget {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
          }

          PowerWidget {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
          }

          TemperatureWidget {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
          }

          WorkspaceIndicator {
            Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
          }
        }
      }

    }
  }
}
