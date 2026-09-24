import QtQuick
import QtQuick.Controls

import Quickshell
import Quickshell.Wayland
import WallustTheme
import qs as Shell

import "./Services"

WlSessionLockSurface {
  id: root

  required property int state
  required property bool secure
  required property string errorMessage

  signal submit(string password)

  color: Colors.background

  Column {
    anchors {
      verticalCenter: parent.verticalCenter
      left: parent.left
      leftMargin: 60
    }

    width: Math.min(parent.width - 60, 420)
    spacing: 10

    Clock {}

    Row {
      height: Shell.Style.passwordFont.pixelSize * 2
      width: Shell.Style.passwordFont.pixelSize * 9
      spacing: Shell.Style.passwordFont.pixelSize

      Rectangle {
        width: Shell.Style.passwordFont.pixelSize
        height: width
        radius: width / 2

        color: Colors.bright1
      }

      Rectangle {
        width: Shell.Style.passwordFont.pixelSize
        height: width
        radius: width / 2

        color: Colors.bright3
      }

      Rectangle {
        width: Shell.Style.passwordFont.pixelSize
        height: width
        radius: width / 2

        color: Colors.bright4
      }

      Rectangle {
        width: Shell.Style.passwordFont.pixelSize
        height: width
        radius: width / 2

        color: Colors.bright5
      }

      Rectangle {
        width: Shell.Style.passwordFont.pixelSize
        height: width
        radius: width / 2

        color: Colors.text
      }
    }

    TextInput {
      id: passwordInput

      width: parent.width
      height: Shell.Style.passwordFont.pixelSize

      echoMode: TextInput.Password
      horizontalAlignment: TextInput.AlignLeft
      verticalAlignment: TextInput.AlignVCenter

      color: Colors.text
      font: Shell.Style.passwordFont

      // Do not allow interaction until the compositor
      // confirms that the lock is secure.
      enabled: root.secure &&
      root.state !== LockContext.State.Authenticating

      focus: root.secure

      Keys.onReturnPressed: submitPassword()
      Keys.onEnterPressed: submitPassword()

      function submitPassword() {
        if (!enabled || text.length === 0)
        return

        root.submit(text)
        clear()
      }
    }
  }

  Text {
    anchors {
      left: parent.left
      bottom: parent.bottom
      leftMargin: 60
      bottomMargin: 60
    }

    text: `${Quickshell.env("USER")}`
    font: Shell.Style.passwordFont
    color: Colors.text
  }

  function icon(p,c) {
    return p === null ? ""
    : c ? ""
    : p < 20 ? ""
    : p < 40 ? ""
    : p < 60 ? ""
    : p < 80 ? ""
    : ""
  }

  function colour(p,c) {
    return p === null ? Colors.textMuted
    : c ? Colors.accent
    : p < 10 ? Colors.urgent
    : Colors.text
  }

  Text {
    anchors {
      right: parent.right
      top: parent.top
      rightMargin: 60
      topMargin: 60
    }

    text: `${icon(Power.percentage, Power.charging)}`
    font: Shell.Style.iconFont
    color: colour(Power.percentage, Power.charging)
  }

  Text {
    anchors {
      right: parent.right
      bottom: parent.bottom
      rightMargin: 60
      bottomMargin: 60
    }

    horizontalAlignment: Text.AlignRight

    text: {
      if (!root.secure)
      return "Securing..."

      switch (root.state) {
        case LockContext.State.Authenticating:
        return "Checking..."
        case LockContext.State.Error:
        return root.errorMessage
        default:
        return ""
      }
    }

    color: root.state === LockContext.State.Error
    ? Colors.urgent
    : Colors.textMuted 

    font: Shell.Style.errorFont
    visible: text.length > 0
  }

  Component.onCompleted: {
    if (root.secure)
    passwordInput.forceActiveFocus()
  }

  onSecureChanged: {
    if (secure)
    passwordInput.forceActiveFocus()
  }
}
