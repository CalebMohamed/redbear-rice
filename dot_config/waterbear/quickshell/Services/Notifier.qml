pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Singleton {
  Process {
    id: notifier
  }

  function notify(title, message, urgency = "normal") {
    notifier.command = [
      "notify-send",
      "--urgency=" + urgency,
      title,
      message
    ]

    notifier.running = true
  }
}
