import QtQuick
import Quickshell
import Quickshell.Wayland

import "../../Services"

FocusScope {
  required property NotificationPanel panel

  Keys.onPressed: event => {
    switch (event.key) {
      case Qt.Key_Escape:
      CentreService.closeCentre()
      event.accepted = true
      break

      case Qt.Key_Up:
      case Qt.Key_K:
      panel.moveSelection(-1)
      event.accepted = true
      break

      case Qt.Key_Down:
      case Qt.Key_J:
      panel.moveSelection(1)
      event.accepted = true
      break

      case Qt.Key_Home:
      if (listView.count > 0)
      panel.selectFirst()
      event.accepted = true
      break

      case Qt.Key_End:
      if (listView.count > 0)
      panel.selectLast()
      event.accepted = true
      break

      case Qt.Key_R:
      panel.toggleSelectedRead()
      event.accepted = true
      break

      case Qt.Key_U:
      panel.toggleSelectedUrgent()
      event.accepted = true
      break

      case Qt.Key_D:
      if (event.modifiers & Qt.ControlModifier) {
        NotificationService.clearDismissed()
      } else {
        panel.dismissSelected()
      }
      event.accepted = true
      break

      case Qt.Key_Delete:
      panel.dismissSelected()
      event.accepted = true
      break

      case Qt.Key_H:
      panel.toggleHistory()
      event.accepted = true
      break

      case Qt.Key_Return:
      case Qt.Key_Enter:
      panel.activateSelected()
      event.accepted = true
      break
    }
  }
}
