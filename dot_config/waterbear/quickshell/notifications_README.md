# Quickshell notification history service

Targeted at Quickshell 0.3.x.

## Layout

```text
notifications/
  NotificationService.qml
  NotificationStore.qml
  NotificationRecord.qml
```

Place the `notifications` directory under the same directory as your `shell.qml`.
Quickshell's `qs.<path>` module import can then be used:

```qml
import qs.notifications

Text {
    text: NotificationService.unreadCount
}
```

`NotificationService` is a singleton and owns the notification daemon, persistent
history, semantic state, and ListView model.

## Public API

### Counts / state

```qml
NotificationService.unreadCount
NotificationService.urgentCount
NotificationService.hasUnread
NotificationService.hasUrgent
NotificationService.needsAttention
NotificationService.showDismissed
NotificationService.ready
```

### Model

```qml
ListView {
    model: NotificationService.model

    delegate: Item {
        required property var modelData
        // modelData is a NotificationRecord
    }
}
```

By default `model` excludes dismissed notifications. Set
`NotificationService.showDismissed = true` to expose the complete permanent
history.

`NotificationService.records` / `allNotifications` contains the complete history
regardless of the toggle.

### State operations

```qml
NotificationService.openCentre()
NotificationService.markRead(recordId)
NotificationService.markUnread(recordId)
NotificationService.toggleRead(recordId)
NotificationService.setUrgent(recordId, true)
NotificationService.setUrgent(recordId, false)
NotificationService.toggleUrgent(recordId)
NotificationService.dismiss(recordId)
NotificationService.restoreFromHistory(recordId)
NotificationService.clearDismissed()
NotificationService.clearAll()
```

Opening the centre marks all non-dismissed notifications as read. Read does not
remove anything from history.

Urgency is initialised from the incoming notification's freedesktop urgency. A
critical notification becomes urgent; the service then owns the mutable `urgent`
flag, so the centre can toggle it independently.

### NotificationRecord

The delegate receives a `NotificationRecord` with at least:

```qml
record.recordId
record.notificationId
record.appName
record.appIcon
record.desktopEntry
record.summary
record.body
record.image
record.timestampMs
record.timeIso
record.read
record.urgent
record.dismissed
record.live
record.actionData
record.actions
record.resident
record.transient
record.hasInlineReply
record.inlineReplyPlaceholder
```

`actions` contains live Quickshell `NotificationAction` objects only while the
underlying notification is still alive. For persisted history use `actionData`
to display old action labels, but only enable invocation when `live` is true.

To invoke an action:

```qml
NotificationService.invokeAction(record.recordId, action.identifier)
```

For an inline-reply notification:

```qml
NotificationService.sendInlineReply(record.recordId, text)
```

## Persistence

History is stored as JSON in Quickshell's per-shell data directory at:

```text
Quickshell.dataPath("notifications.json")
```

Dismissed records remain in the file permanently until explicitly removed by
`clearDismissed()` or `clearAll()`.

## Important lifecycle detail

The live Quickshell notification object is deliberately not the history object.
Quickshell can destroy a notification after expiry, remote close, or dismissal;
the `NotificationRecord` remains in this service's history. Quickshell's
`keepOnReload` facility is enabled, and `lastGeneration` notifications are
reconnected to existing records after a soft reload.


## Optional notification centre

`NotificationCentre.qml` is included as a minimal keyboard-driven reference UI.
It uses a fullscreen Wayland layer-shell overlay rather than a Hyprland
workspace. The overlay is on `WlrLayer.Overlay` and requests exclusive keyboard
focus while open.

Instantiate it from your shell and control it through its `open` property:

```qml
import qs.notifications

NotificationCentre {
    id: notificationCentre
    // Set screen to whichever ShellScreen you use for the centre.
}

// Your global shortcut/widget can do:
notificationCentre.open = true
```

The centre starts in active-history mode. Press `h` or the History button to
include dismissed records. Relevant keyboard controls are:

```text
Up / k       previous
Down / j     next
Home / End   first / last
r            toggle read
u            toggle urgent
d / Delete   dismiss
h            active/history toggle
Esc          close
```

The component is intentionally only a reference UI; its styling, dimensions,
placement and shortcut integration are expected to be adapted to the rest of
the shell.
