import Quickshell
import QtQuick

import qs as Shell
import WallustTheme

import "../Common"

PanelWindow {
  id: root

  enum Edge {
    Left,
    Right,
    Top,
    Bottom
  }

  required property bool open             // exposed for externally controlled popup
  signal closeRequested

  property int edge: EdgePopup.Left       // default to left side

  property real popupWidth: Shell.Style.iconFont.pixelSize * 6
  property real popupHeight: Shell.Style.iconFont.pixelSize * 6

  default property alias content: contentContainer.data

  readonly property bool horizontal:
    edge === EdgePopup.Left || edge === EdgePopup.Right

  readonly property real corner: Shell.Style.cornerRadius

  exclusionMode: ExclusionMode.Ignore
  color: "transparent"

  anchors.left: edge === EdgePopup.Left
  anchors.right: edge === EdgePopup.Right
  anchors.top: edge === EdgePopup.Top
  anchors.bottom: edge === EdgePopup.Bottom

  margins.left: edge === EdgePopup.Left ? Shell.Style.borderSize : 0
  margins.right: edge === EdgePopup.Right ? Shell.Style.borderSize : 0
  margins.top: edge === EdgePopup.Top ? Shell.Style.borderSize : 0
  margins.bottom: edge === EdgePopup.Bottom ? Shell.Style.borderSize : 0

  implicitWidth: horizontal ? popupWidth : popupWidth + corner * 2
  implicitHeight: horizontal ? popupHeight + corner * 2 : popupHeight

  // removed mouse interaction when closed
  mask: Region {
    item: root.open ? popupContent : null
  }

  Rectangle {
    id: popupContent

    width: root.popupWidth
    height: root.popupHeight

    anchors.verticalCenter: root.horizontal ? parent.verticalCenter : undefined
    anchors.horizontalCenter: !root.horizontal ? parent.horizontalCenter : undefined

    topLeftRadius: root.edge === EdgePopup.Right || root.edge === EdgePopup.Bottom ? root.corner : 0
    bottomLeftRadius: root.edge === EdgePopup.Right || root.edge === EdgePopup.Top ? root.corner : 0
    topRightRadius: root.edge === EdgePopup.Left || root.edge === EdgePopup.Bottom ? root.corner : 0
    bottomRightRadius: root.edge === EdgePopup.Left || root.edge === EdgePopup.Top ? root.corner : 0

    color: Colors.background

    x: {
      switch (root.edge) {
        case EdgePopup.Left: return root.open ? 0 : -root.popupWidth
        case EdgePopup.Right: return root.open ? 0 : root.popupWidth
        default:
        return 0
      }
    }

    y: {
      switch (root.edge) {
        case EdgePopup.Top: return root.open ? 0 : -root.popupHeight
        case EdgePopup.Bottom: return root.open ? 0 : root.popupHeight
        default: return 0
      }
    }

    Behavior on x {
      NumberAnimation {
        duration: 200
        easing.type: Easing.OutCubic
      }
    }

    Behavior on y {
      NumberAnimation {
        duration: 200
        easing.type: Easing.OutCubic
      }
    }

    HoverHandler {
      onHoveredChanged: {
        if (!hovered)
        root.closeRequested()
      }
    }

    Item {
      id: contentContainer
      anchors.fill: parent
    }
  }

  // Leading bevel
  BevelCorner {
    colour: Colors.background

    anchors.top: root.horizontal ? parent.top : undefined
    anchors.left: !root.horizontal ? parent.left : undefined

    rotation: {
      switch (root.edge) {
        case EdgePopup.Left:   return 0
        case EdgePopup.Right:  return 270
        case EdgePopup.Top:    return 180
        case EdgePopup.Bottom: return 270
      }
    }

    // vertical doesn't matter; left put start of view by 0; right put right of view by the popupWidth - itself
    property var shownX: !root.horizontal ? 0
    : root.edge === EdgePopup.Left ? 0 
    : root.popupWidth - root.corner

    // vertical doesn't matter; left put out of view by a corner; right put out of view by the popupWidth
    property var hiddenX: !root.horizontal ? 0
    : root.edge === EdgePopup.Left ? -root.corner
    : root.popupWidth

    // horizontal doesn't matter; top put start of view by 0; bottom put bottom of view by the popupHeight - itself
    property var shownY: root.horizontal ? 0
    : root.edge === EdgePopup.Top ? 0 
    : root.popupHeight - root.corner

    // horizontal doesn't matter; top put out of view by a corner; bottom put out of view by the popupHeight
    property var hiddenY: root.horizontal ? 0
    : root.edge === EdgePopup.Top ? -root.corner
    : root.popupHeight

    x: root.open ? shownX : hiddenX
    y: root.open ? shownY : hiddenY

    Behavior on x {
      NumberAnimation {
        duration: 200
        easing.type: Easing.OutCubic
      }
    }

    Behavior on y {
      NumberAnimation {
        duration: 200
        easing.type: Easing.OutCubic
      }
    }
  }

  // Trailing bevel
  BevelCorner {
    colour: Colors.background

    anchors.bottom: root.horizontal ? parent.bottom : undefined
    anchors.right: !root.horizontal ? parent.right : undefined

    rotation: {
      switch (root.edge) {
        case EdgePopup.Left:   return 90
        case EdgePopup.Right:  return 180
        case EdgePopup.Top:    return 90
        case EdgePopup.Bottom: return 0
      }
    }

    // vertical doesn't matter; left put start of view by 0; right put right of view by the popupWidth - itself
    property var shownX: !root.horizontal ? 0
    : root.edge === EdgePopup.Left ? 0 
    : root.popupWidth - root.corner

    // vertical doesn't matter; left put out of view by a corner; right put out of view by the popupWidth
    property var hiddenX: !root.horizontal ? 0
    : root.edge === EdgePopup.Left ? -root.corner
    : root.popupWidth

    // horizontal doesn't matter; top put start of view by 0; bottom put bottom of view by the popupHeight - itself
    property var shownY: root.horizontal ? 0
    : root.edge === EdgePopup.Top ? 0 
    : root.popupHeight - root.corner

    // horizontal doesn't matter; top put out of view by a corner; bottom put out of view by the popupHeight
    property var hiddenY: root.horizontal ? 0
    : root.edge === EdgePopup.Top ? -root.corner
    : root.popupHeight

    x: root.open ? shownX : hiddenX
    y: root.open ? shownY : hiddenY

    Behavior on x {
      NumberAnimation {
        duration: 200
        easing.type: Easing.OutCubic
      }
    }

    Behavior on y {
      NumberAnimation {
        duration: 200
        easing.type: Easing.OutCubic
      }
    }
  }

}
