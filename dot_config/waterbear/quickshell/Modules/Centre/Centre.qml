import QtQuick
import Quickshell
import Quickshell.Wayland

import qs as Shell
import WallustTheme

import "../../Components"
import "../../Services"

PanelWindow {
  id: root

  visible: CentreService.centreOpen
  focusable: CentreService.centreOpen
  aboveWindows: true

  anchors {
    left: true
    right: true
    top: true
    bottom: true
  }

  exclusionMode: ExclusionMode.Ignore

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus:
  CentreService.centreOpen
  ? WlrKeyboardFocus.Exclusive
  : WlrKeyboardFocus.None

  color: "transparent"

  CentreControls {
    id: keyboardScope

    anchors.fill: parent
    focus: CentreService.centreOpen

    panel: panel
  }

  // Backdrop
  Rectangle {
    anchors.fill: parent

    color: Colors.accent
    opacity: 0.25

    MouseArea {
      anchors.fill: parent
      onClicked: CentreService.closeCentre()
    }
  }

  NotificationPanel {
    id: panel
    keyboardScope: keyboardScope
  }

  BentoDisplay {
    id: bento
  }
}
