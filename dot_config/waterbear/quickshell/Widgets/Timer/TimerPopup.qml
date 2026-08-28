import Quickshell

import QtQuick
import QtQuick.Layouts

import qs as Shell
import WallustTheme

import "../../Services"

// I gave up on the idea of having it appear above the timer
// since that requires me to call the item PopupWindow and use the regular Item positioning
// but then the animation of the rectangle leads to really ugly visual artifacts

PanelWindow {
  id: root

  required property bool open
  signal closeRequested

  exclusionMode: ExclusionMode.Ignore

  anchors { left: true }
  margins { left: Shell.Style.borderSize }

  implicitWidth: popupContent.implicitWidth
  implicitHeight: popupContent.implicitHeight

  color: "transparent"

  Rectangle {
    id: popupContent

    // approximately 6 characters wide
    implicitWidth: Shell.Style.iconFont.pixelSize * 6
    // approximately 6 characters tall
    implicitHeight: Shell.Style.iconFont.pixelSize * 6

    topLeftRadius: 0
    bottomLeftRadius: 0
    topRightRadius: 10
    bottomRightRadius: 10

    color: Colors.background

    x: root.open ? 0 : - width

    Behavior on x {
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

    ColumnLayout {
      id: content

      anchors.fill: parent
      spacing: 4

      RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: Shell.Style.iconFont.pixelSize * 2

        spacing: 4

        Item { Layout.fillWidth: true }

        TimerHold {
          icon: ""
          onClicked: TimerService.adjustMinutes(-1)
          onRepeatTriggered: TimerService.adjustMinutes(-1)
        }

        TimerControl {
          icon: TimerService.running ? "" : ""
          onClicked: TimerService.toggleRunning()
        }

        TimerHold {
          icon: ""
          onClicked: TimerService.adjustMinutes(1)
          onRepeatTriggered: TimerService.adjustMinutes(1)
        }

        Item { Layout.fillWidth: true }
      }

      Item { 
        Layout.fillWidth: true 

        Text {
          anchors.centerIn: parent

          text: TimerService.display

          font: Shell.Style.uiFont
          color: root.highlighted ? Colors.accent
          : TimerService.finished ? Colors.accent
          : TimerService.running ? Colors.text
          : Colors.textMuted
        }
      }

      RowLayout {
        Layout.fillWidth: true
        Layout.preferredHeight: Shell.Style.iconFont.pixelSize * 2

        spacing: 4

        Item { Layout.fillWidth: true }

        TimerControl {
          icon: "󰔟"
          onClicked: TimerService.setPreset(10)
        }

        TimerControl {
          icon: "󰔛"
          onClicked: TimerService.setPreset(30)
        }

        TimerControl {
          icon: "󰔚"
          onClicked: TimerService.setPreset(60)
        }

        Item { Layout.fillWidth: true }
      }
    }
  }
}
