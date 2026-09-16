import QtQuick
import Quickshell.Wayland

import WallustTheme
import qs as Shell

WlSessionLockSurface {
  id: root

  required property int state
  required property bool secure
  required property string errorMessage

  signal submit(string password)

  color: Colors.background

  Column {
    anchors.centerIn: parent
    width: Math.min(parent.width - 48, 420)
    spacing: 20

    Clock {}

    TextInput {
      id: passwordInput

      width: parent.width
      height: 52

      echoMode: TextInput.Password
      horizontalAlignment: TextInput.AlignHCenter
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

    Text {
      width: parent.width
      horizontalAlignment: Text.AlignHCenter

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
