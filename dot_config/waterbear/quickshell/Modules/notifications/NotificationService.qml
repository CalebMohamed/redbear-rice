pragma Singleton

import QtQml
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Hyprland

Singleton {
  id: root

  // Public state ---------------------------------------------------------

  // All historical records, newest first. This includes dismissed records.
  property var records: []

  // The notification centre can bind to this to switch between active
  // history and the complete history.
  property bool showDismissed: false

  // Persist transient notifications too. The freedesktop protocol describes
  // transient notifications as normally unsuitable for persistence; this is
  // deliberately true because this service is intended to own a permanent
  // history. Set false if you want to honour that hint strictly.
  property bool persistTransient: true

  readonly property int unreadCount: records.filter(function(record) {
    return !record.read && !record.dismissed
  }).length

  readonly property int urgentCount: records.filter(function(record) {
    return record.urgent && !record.dismissed
  }).length

  readonly property bool hasUnread: unreadCount > 0
  readonly property bool hasUrgent: urgentCount > 0
  readonly property bool needsAttention: hasUnread || hasUrgent

  // ListView-ready model. Toggle showDismissed to expose the full history.
  readonly property ScriptModel model: ScriptModel {
    values: root.showDismissed
    ? root.records
    : root.records.filter(function(record) { return !record.dismissed })
  }

  // All records are also exposed directly for consumers that want to build
  // their own model/filtering strategy.
  readonly property var allNotifications: records

  readonly property bool loading: !storeLoaded
  readonly property bool ready: storeLoaded

  // the service is the authorative location of whether the Notification centre
  // is open so that the widget can hook into it without having to be connected to the notification Centre
  property bool centreOpen: false

  // the service also determines what screen the centre should open on
  property var centreScreen: null

  // Signals --------------------------------------------------------------

  signal notificationAdded(var record)
  signal notificationUpdated(var record)
  signal notificationDismissed(var record)
  signal notificationReadChanged(var record)
  signal notificationUrgencyChanged(var record)
  signal centreOpened()

  // Internal state ------------------------------------------------------

  property bool storeLoaded: false
  property int nextRecordId: 1
  property var liveByNotificationId: ({})

  Component {
    id: recordComponent
    NotificationRecord {}
  }

  NotificationServer {
    id: server

    keepOnReload: true
    persistenceSupported: true
    actionsSupported: true
    imageSupported: true
    bodyImagesSupported: true
    bodyHyperlinksSupported: false
    bodyMarkupSupported: false
    inlineReplySupported: true

    onNotification: notification => root.acceptNotification(notification)
  }

  NotificationStore {
    id: store
    owner: root

    onLoaded: function(serialisedRecords, loadedNextId) {
      root.restore(serialisedRecords, loadedNextId)
    }

    onLoadError: message => console.warn("[NotificationService]", message)
    onSaveError: message => console.warn("[NotificationService]", message)
  }

  Component.onCompleted: store.load()

  // Persistence ---------------------------------------------------------

  function persist() {
    if (!storeLoaded)
    return
    store.save(records, nextRecordId)
  }

  function touchModel() {
    // Reassigning the array gives ScriptModel a new top-level value and
    // therefore reevaluates the dismissed filter.
    records = records.slice()
  }

  function restore(serialisedRecords, loadedNextId) {
    const restored = []
    let maximumRecordId = 0

    for (const data of serialisedRecords) {
      if (!data || typeof data !== "object")
      continue

      const record = recordComponent.createObject(root)
      if (!record)
      continue

      record.recordId = Number.isInteger(data.recordId) ? data.recordId : 0
      record.notificationId = Number.isInteger(data.notificationId) ? data.notificationId : -1
      record.appName = data.appName || ""
      record.appIcon = data.appIcon || ""
      record.desktopEntry = data.desktopEntry || ""
      record.summary = data.summary || ""
      record.body = data.body || ""
      record.image = data.image || ""
      record.timestampMs = Number(data.timestampMs) || Date.now()
      record.read = !!data.read
      record.urgent = !!data.urgent
      record.dismissed = !!data.dismissed
      record.actionData = Array.isArray(data.actionData) ? data.actionData : []
      record.resident = !!data.resident
      record.isTransient = !!data.transient
      record.hasInlineReply = !!data.hasInlineReply
      record.inlineReplyPlaceholder = data.inlineReplyPlaceholder || ""

      if (record.recordId > maximumRecordId)
      maximumRecordId = record.recordId

      restored.push(record)
      connectRecord(record)
    }

    restored.sort(function(a, b) { return b.timestampMs - a.timestampMs })

    records = restored
    nextRecordId = Math.max(loadedNextId, maximumRecordId + 1, 1)
    storeLoaded = true
    touchModel()

    // Save once after loading so legacy/defaulted fields are normalised.
    persist()
  }

  // Notification ingestion ---------------------------------------------

  function acceptNotification(notification) {
    if (!persistTransient && notification.transient)
    return

    // The server only retains notifications which we explicitly track.
    notification.tracked = true

    const key = String(notification.id)
    let record = liveByNotificationId[key] || null

    // On a soft reload, Quickshell can re-emit the notifications that were
    // tracked by the previous generation. Reconnect those to our existing
    // persistent records rather than creating duplicates.
    if (!record && notification.lastGeneration) {
      record = findReloadRecord(notification)
    }

    if (record) {
      record.setFromNotification(notification, true)
      record.bindLiveNotification(notification)
      liveByNotificationId[key] = record
      touchModel()
      notificationUpdated(record)
      persist()
      return
    }

    record = recordComponent.createObject(root)
    record.recordId = nextRecordId++
    record.timestampMs = Date.now()
    record.setFromNotification(notification, false)
    record.bindLiveNotification(notification)

    records = [record].concat(records)
    liveByNotificationId[key] = record
    connectRecord(record)
    notificationAdded(record)
    touchModel()
    persist()
  }

  function findReloadRecord(notification) {
    let best = null

    for (const record of records) {
      if (record.dismissed)
      continue
      if (record.notificationId !== notification.id)
      continue

      if (!best || record.timestampMs > best.timestampMs)
      best = record
    }

    return best
  }

  function connectRecord(record) {
    record.liveClosed.connect(function() {
      const key = String(record.notificationId)
      if (liveByNotificationId[key] === record)
      delete liveByNotificationId[key]
    })
  }

  // Public mutations ----------------------------------------------------

  function openCentre() {
    // works out which hyprland monitor is focused
    const monitor = Hyprland.focusedMonitor

    if (monitor !== null) {
      for (const screen of Quickshell.screens) {
        const hm = Hyprland.monitorFor(screen)

        if (hm !== null && hm.id === monitor.id) {
          centreScreen = screen
          break
        }
      }
    }

    centreOpen = true

    for (const record of records) {
      if (!record.dismissed && !record.read)
      record.read = true
    }

    touchModel()
    persist()
    centreOpened()
  }

  function closeCentre() {
    centreOpen = false
  }

  function toggleCentre() {
    if (centreOpen)
    closeCentre()
    else
    openCentre()
  }

  function markRead(recordId) {
    const record = findRecord(recordId)
    if (!record || record.read)
    return false

    record.read = true
    touchModel()
    persist()
    notificationReadChanged(record)
    return true
  }

  function markUnread(recordId) {
    const record = findRecord(recordId)
    if (!record || !record.read)
    return false

    record.read = false
    touchModel()
    persist()
    notificationReadChanged(record)
    return true
  }

  function toggleRead(recordId) {
    const record = findRecord(recordId)
    if (!record)
    return false
    return record.read ? markUnread(recordId) : markRead(recordId)
  }

  function setUrgent(recordId, urgent) {
    const record = findRecord(recordId)
    if (!record || record.urgent === urgent)
    return false

    record.urgent = urgent
    touchModel()
    persist()
    notificationUrgencyChanged(record)
    return true
  }

  function toggleUrgent(recordId) {
    const record = findRecord(recordId)
    if (!record)
    return false
    return setUrgent(recordId, !record.urgent)
  }

  function dismiss(recordId) {
    const record = findRecord(recordId)
    if (!record || record.dismissed)
    return false

    record.dismissed = true

    const key = String(record.notificationId)
    if (liveByNotificationId[key] === record)
    delete liveByNotificationId[key]

    // Clear the reference before calling dismiss() because Quickshell will
    // synchronously/soon emit Notification.closed(Dismissed).
    const live = record.liveNotification
    record.liveNotification = null
    if (live)
    live.dismiss()

    touchModel()
    persist()
    notificationDismissed(record)
    return true
  }

  function restoreFromHistory(recordId) {
    const record = findRecord(recordId)
    if (!record || !record.dismissed)
    return false

    record.dismissed = false
    touchModel()
    persist()
    return true
  }

  function clearDismissed() {
    const kept = []

    for (const record of records) {
      if (record.dismissed) {
        record.liveNotification = null
        record.destroy()
      } else {
        kept.push(record)
      }
    }

    records = kept
    touchModel()
    persist()
  }

  function clearAll() {
    for (const record of records) {
      const key = String(record.notificationId)
      if (liveByNotificationId[key] === record)
      delete liveByNotificationId[key]

      const live = record.liveNotification
      record.liveNotification = null
      if (live)
      live.dismiss()

      record.destroy()
    }

    records = []
    touchModel()
    persist()
  }

  function invokeAction(recordId, actionIdentifier) {
    const record = findRecord(recordId)
    if (!record)
    return false

    // Read state is controlled by openCentre(), not by individual
    // interactions. The centre has already called openCentre() when it
    // became visible.
    return record.invokeAction(actionIdentifier)
  }

  function sendInlineReply(recordId, replyText) {
    const record = findRecord(recordId)
    if (!record)
    return false

    return record.sendInlineReply(replyText)
  }

  function findRecord(recordId) {
    for (const record of records) {
      if (record.recordId === recordId)
      return record
    }
    return null
  }
}
