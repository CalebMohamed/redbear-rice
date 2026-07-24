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

      exclusionMode: ExclusionMode.Ignore
      aboveWindows: true

      color: "transparent"
      implicitWidth: container.implicitWidth
      implicitHeight: 45

      anchors {
        top: true
        left: true
      }

      // purely visual background for the bar
      Rectangle {
        id: background

        anchors.fill: parent
        bottomRightRadius: height / 2
        antialiasing: true
        color: "#FF111111"
      }

      Item {
        id: container
        anchors.fill: parent

        readonly property int padLeft: 10
        readonly property int padRight: 30
        readonly property int padTop: 10
        readonly property int padBottom: 15

        implicitWidth: row.implicitWidth + padLeft + padRight
        implicitHeight: row.implicitHeight + padTop + padBottom

        RowLayout {
          id: row
          anchors.left: parent.left
          anchors.right: parent.right
          anchors.top: parent.top
          anchors.bottom: parent.bottom

          anchors.leftMargin: container.padLeft
          anchors.rightMargin: container.padRight
          anchors.topMargin: container.padTop
          anchors.bottomMargin: container.padBottom
          spacing: 12

          ClockWidget{}
          PowerWidget{}
          TemperatureWidget{}
          WorkspaceIndicator{}
        }
      }
    }
  }
}
