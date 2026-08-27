import Quickshell
import QtQuick
import QtQuick.Layouts
import "./Widgets"

Scope {
  id: root

  required property var screen

  property real borderSize: 20
  property real cornerRadius: 10
  property color borderColor: "#020618"

  // =========================
  // Visual root overlays
  // =========================

  readonly property var borders: [
    { top: true, bottom: false, left: true, right: true, width: 0, height: borderSize },
    { top: false, bottom: true, left: true, right: true, width: 0, height: borderSize },
    { top: true, bottom: true, left: true, right: false, width: borderSize, height: 0 },
    { top: true, bottom: true, left: false, right: true, width: borderSize, height: 0 }
  ]

  Variants {
    model: root.borders

    delegate: PanelWindow {
      required property var modelData

      screen: root.screen
      anchors {
        top: modelData.top
        bottom: modelData.bottom
        left: modelData.left
        right: modelData.right
      }

      implicitWidth: modelData.width
      implicitHeight: modelData.height
      color: root.borderColor
    }
  }

  // =========================
  // Widgets
  // =========================

  // top border widgets
  PanelWindow {
    screen: root.screen

    anchors {
      top: true
      left: true
      right: true
    }

    implicitHeight: root.borderSize
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    // middle widgets
    Item {
      id: container
      anchors.centerIn: parent

      RowLayout {
        anchors.centerIn: parent
        spacing: 12

        ClockWidget{}
        PowerWidget{}
        TemperatureWidget{}
      }
    }
  }

  // bottom border overlay
  PanelWindow {
    screen: root.screen

    anchors {
      bottom: true
      left: true
      right: true
    }

    implicitHeight: root.borderSize
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    // bottom left widgets
    Item {
      anchors {
        left: parent.left
        verticalCenter: parent.verticalCenter
        leftMargin: 30
      }

      implicitWidth: blWidgets.implicitWidth
      implicitHeight: blWidgets.implicitHeight

      RowLayout {
        id: blWidgets
        anchors.centerIn: parent
        spacing: 12

        WorkspaceIndicator{}
      }
    }
  }

  // =========================
  // Visual corner overlays
  // =========================

  readonly property var corners: [
    { top: true,  bottom: false, right: false, left: true,  rotation: 0 },
    { top: true,  bottom: false, right: true, left: false,  rotation: 90 },
    { top: false,  bottom: true, right: true, left: false,  rotation: 180 },
    { top: false,  bottom: true, right: false, left: true,  rotation: 270 },
  ]

  Variants {
    model: root.corners

    delegate: PanelWindow {
      required property var modelData

      screen: root.screen
      aboveWindows: true
      exclusionMode: ExclusionMode.Ignore
      color: "transparent"

      implicitWidth: root.borderSize + root.cornerRadius
      implicitHeight: root.borderSize + root.cornerRadius

      anchors {
        top: modelData.top
        bottom: modelData.bottom
        left: modelData.left
        right: modelData.right
      }

      BevelCorner {
        anchors.fill: parent
        rotation: modelData.rotation
        borderWidth: root.borderSize
        radius: root.cornerRadius
        color: root.borderColor
      }
    }
  }
}
