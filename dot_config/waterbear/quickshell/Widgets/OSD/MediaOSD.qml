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
  popupWidth: Shell.Style.uiFont.pixelSize * 4
  popupHeight: Shell.Style.iconFont.pixelSize * 16

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
    anchors.fill: parent
    // anchors.margins: Shell.Style.uiFont.pixelSize * 0.8

    spacing: Shell.Style.iconFont.pixelSize * 4

    Text {
      Layout.alignment: Qt.AlignHCenter

      text: {
        var audioPercent = Audio.percentage
        var brightnessPercent = Brightness.percentage

        if (root.kind === MediaOSD.Kind.Brightness)
        return brightnessPercent > 90 ? "󰃠"
        : brightnessPercent > 90 ? "󰃠"
        : brightnessPercent > 70 ? "󰃠"
        : brightnessPercent > 50 ? "󰃠"
        : brightnessPercent > 30 ? "󰃠"
        : brightnessPercent > 10 ? "󰃠"
        : "󰃠"

        return Audio.muted ? "󰝟"
        : Audio.percentage === 0 ? "󰖁"
        : Audio.percentage < 50 ? "󰕿"
        : "󰕾"
      }

      font.family: Shell.Style.iconFont.family
      font.pixelSize: Shell.Style.iconFont.pixelSize * 1.5
      color: Colors.text
    }

    Item {
      Layout.fillWidth: true
      Layout.fillHeight: true

      Rectangle {
        width: Shell.Style.uiFont * 0.5
        height: parent.height * (
          root.kind === MediaOSD.Kind.Brightness
          ? Brightness.value
          : Math.min(Audio.volume, 1)
        ) 
        radius: width / 2
        color: Colors.accent

        Behavior on width {
          NumberAnimation {
            duration: 100
            easing.type: Easing.OutCubic
          }
        }
      }
    }

    Text {
      Layout.alignment: Qt.AlignHCenter

      text: root.kind === MediaOSD.Kind.Brightness
      ? `${Brightness.percentage}%`
      : `${Audio.percentage}%`

      font.family: Shell.Style.iconFont.family
      font.pixelSize: Shell.Style.iconFont.pixelSize
      color: Colors.text
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
