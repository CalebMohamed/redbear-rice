import QtQml
import Quickshell.Services.Notifications

QtObject {
  id: root

  property int recordId: 0
  property int notificationId: -1

  property string appName: ""
  property string appIcon: ""
  property string desktopEntry: ""
  property string summary: ""
  property string body: ""
  property string image: ""

  property real timestampMs: 0

  property bool read: false
  property bool urgent: false
  property bool dismissed: false

  property var actionData: []

  property bool resident: false
  property bool isTransient: false
  property bool hasInlineReply: false
  property string inlineReplyPlaceholder: ""

  property var liveNotification: null

  readonly property bool live: liveNotification !== null

  readonly property var actions:
  live && liveNotification.actions !== undefined
  ? liveNotification.actions
  : []

  readonly property string timeIso:
  new Date(timestampMs).toISOString()

  signal liveClosed(var reason)

  function setFromNotification(notification, preserveState) {
    notificationId = notification.id
    appName = notification.appName
    appIcon = notification.appIcon
    desktopEntry = notification.desktopEntry
    summary = notification.summary
    body = notification.body
    image = notification.image
    resident = notification.resident
    isTransient = notification.transient
    hasInlineReply = notification.hasInlineReply
    inlineReplyPlaceholder = notification.inlineReplyPlaceholder

    const actions = []

    for (const action of notification.actions) {
      actions.push({
        identifier: action.identifier,
        text: action.text,
      })
    }

    actionData = actions

    if (!preserveState) {
      urgent = notification.urgency === NotificationUrgency.Critical
      read = false
      dismissed = false
    } else if (notification.urgency === NotificationUrgency.Critical) {
      urgent = true
    }
  }

  function bindLiveNotification(notification) {
    if (liveNotification !== null) {
      try {
        liveNotification.closed.disconnect(onLiveClosed)
      } catch (e) {
        // Already disconnected/destroyed.
      }
    }

    liveNotification = notification

    if (notification !== null)
    notification.closed.connect(onLiveClosed)
  }

  function onLiveClosed(reason) {
    liveNotification = null
    liveClosed(reason)
  }

  function invokeAction(identifier) {
    if (!liveNotification)
    return false

    for (const action of liveNotification.actions) {
      if (action.identifier === identifier) {
        action.invoke()
        return true
      }
    }

    return false
  }

  function sendInlineReply(replyText) {
    if (!liveNotification || !liveNotification.hasInlineReply)
    return false

    liveNotification.sendInlineReply(replyText)
    return true
  }
}
