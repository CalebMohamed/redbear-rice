import Quickshell
import QtQuick
import QtQuick.Layouts

import qs as Shell

import WallustTheme

import "../../Services"
import "../Common"

EdgePopup {
  id: root

  required property var screen

  Component.onCompleted: {
    OSD.register(screen, root)
  }

  Component.onDestruction: {
    OSD.unregister(root)
  }

  open: false
  edge: EdgePopup.Right
  popupWidth: Shell.Style.uiFont.pixelSize * 2
  popupHeight: content.implicitHeight

  enum Kind {
    Volume,
    Brightness
  }

  property int kind: MediaOSD.Kind.Volume
  property int displayTime: 1200 // How long the OSD remains visible after the last event.

  Timer {
    id: hideTimer

    interval: root.displayTime
    repeat: false

    onTriggered: root.open = false
  }

  function showVolume(): void {
    root.kind = MediaOSD.Kind.Volume
    root.open = true
    hideTimer.restart()
  }

  function showBrightness(): void {
    root.kind = MediaOSD.Kind.Brightness
    root.open = true
    hideTimer.restart()
  }

  // Useful later if you want to call this generically.
  function show(kind: int): void {
    root.kind = kind
    root.open = true
    hideTimer.restart()
  }

  // Don't let the HoverHandler in EdgePopup kill a keyboard-triggered OSD.
  // The OSD lifetime is controlled by the timer instead.
  onCloseRequested: {
    // Intentionally ignored.
  }

  ColumnLayout {
    id: content

    anchors.fill: parent
    spacing: Shell.Style.iconFont.pixelSize

    Text {
      Layout.alignment: Qt.AlignHCenter
      Layout.topMargin: Shell.Style.iconFont.pixelSize

      text: {
        var audioPercent = Audio.percentage
        var brightnessPercent = Brightness.percentage

        if (root.kind === MediaOSD.Kind.Brightness) {
          return brightnessPercent> 80 ? "󰃠"
          : brightnessPercent > 60 ? "󰃟"
          : brightnessPercent > 40 ? "󰃞"
          : brightnessPercent > 20 ? "󰃝"
          : "󰃚"
        }

        // I want to use more but couldn't find consistent ones
        return Audio.muted ? "󰝟"
        : audioPercent === 0 ? "󰖁"
        : "󰕾"
      }

      color: Colors.text
      font: Shell.Style.uiFont
    }

    Rectangle {
      Layout.alignment: Qt.AlignHCenter
      width: Shell.Style.uiFont.pixelSize * 0.5
      height: Shell.Style.uiFont.pixelSize * 10
      radius: width / 2
      color: Colors.backgroundAlt

      Rectangle {
        anchors.bottom: parent.bottom

        width: parent.width
        height: parent.height * (
          root.kind === MediaOSD.Kind.Brightness
          ? Brightness.value
          : Math.min(Audio.volume, 1)
        ) 
        radius: parent.width
        color: Colors.accent

        Behavior on height {
          NumberAnimation {
            duration: 100
            easing.type: Easing.OutCubic
          }
        }
      }
    }

    Text {
      Layout.alignment: Qt.AlignHCenter
      Layout.bottomMargin: Shell.Style.iconFont.pixelSize

      text: root.kind === MediaOSD.Kind.Brightness
      ? Brightness.percentage
      : Audio.percentage

      color: Colors.text
      font: Shell.Style.uiFont
    }
  }

  Connections {
    target: Audio

    function onVolumeChanged() {
      if (root.kind === MediaOSD.Kind.Volume && root.open)
      hideTimer.restart()
    }

    function onMutedChanged() {
      if (root.kind === MediaOSD.Kind.Volume && root.open)
      hideTimer.restart()
    }
  }

  Connections {
    target: Brightness

    function onValueChanged() {
      if (root.kind === MediaOSD.Kind.Brightness && root.open)
      hideTimer.restart()
    }
  }
}
