import Quickshell

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs as Shell
import WallustTheme

import "./Widgets/Common"

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
    { top: true,  bottom: false, right: false, left: true,  rotation: 90 },
    { top: true,  bottom: false, right: true, left: false,  rotation: 180 },
    { top: false,  bottom: true, right: true, left: false,  rotation: 270 },
    { top: false,  bottom: true, right: false, left: true,  rotation: 0 },
  ]

  Variants {
    model: root.corners

    delegate: PanelWindow {
      required property var modelData

      screen: root.screen
      exclusionMode: ExclusionMode.Ignore
      color: "transparent"

      implicitWidth: Shell.Style.cornerRadius
      implicitHeight: Shell.Style.cornerRadius

      anchors {
        top: modelData.top
        bottom: modelData.bottom
        left: modelData.left
        right: modelData.right
      }

      margins {
        top: modelData.top ? Shell.Style.borderSize : 0
        bottom: modelData.bottom ? Shell.Style.borderSize : 0
        left: modelData.left ? Shell.Style.borderSize : 0
        right: modelData.right ? Shell.Style.borderSize : 0
      }

      BevelCorner {
        anchors.fill: parent
        transformOrigin: Item.Center
        rotation: modelData.rotation
        colour: root.borderColor
      }
    }
  }
}
