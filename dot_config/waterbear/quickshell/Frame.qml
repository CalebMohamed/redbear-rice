import Quickshell

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs as Shell
import WallustTheme

import "./Widgets"

Scope {
  id: root

  required property var screen
  property color borderColor: Colors.background

  // =========================
  // Visual root overlays
  // =========================

  readonly property var borders: [
    { top: true, bottom: false, left: true, right: true, width: 0, height: Shell.Style.borderSize },
    { top: false, bottom: true, left: true, right: true, width: 0, height: Shell.Style.borderSize },
    { top: true, bottom: true, left: true, right: false, width: Shell.Style.borderSize, height: 0 },
    { top: true, bottom: true, left: false, right: true, width: Shell.Style.borderSize, height: 0 }
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
      exclusionMode: ExclusionMode.Ignore
      color: "transparent"

      implicitWidth: Shell.Style.borderSize + Shell.Style.cornerRadius
      implicitHeight: Shell.Style.borderSize + Shell.Style.cornerRadius

      anchors {
        top: modelData.top
        bottom: modelData.bottom
        left: modelData.left
        right: modelData.right
      }

      BevelCorner {
        anchors.fill: parent
        rotation: modelData.rotation
        borderWidth: Shell.Style.borderSize
        radius: Shell.Style.cornerRadius
        color: root.borderColor
      }
    }
  }
}
