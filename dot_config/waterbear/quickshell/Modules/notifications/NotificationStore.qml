import QtQml
import Quickshell
import Quickshell.Io

QtObject {
  id: root

  required property QtObject owner

  readonly property string path: Quickshell.dataPath("notifications.json")

  signal loaded(var records, int nextRecordId)
  signal saved()
  signal loadError(string message)
  signal saveError(string message)

  property FileView file: FileView {
    id: file
    path: root.path
    blockLoading: true
    atomicWrites: true

    onSaved: root.saved()
    onSaveFailed: error => root.saveError(String(error))
  }

  function load() {
    let text = ""

    try {
      text = file.text()
    } catch (error) {
      root.loadError("Unable to read notification history: " + error)
      root.loaded([], 1)
      return
    }

    if (!text || !text.trim()) {
      root.loaded([], 1)
      return
    }

    try {
      const document = JSON.parse(text)
      if (!document || document.version !== 1 || !Array.isArray(document.notifications)) {
        throw new Error("unsupported notification history format")
      }

      const nextId = Number.isInteger(document.nextRecordId)
      ? Math.max(1, document.nextRecordId)
      : 1

      root.loaded(document.notifications, nextId)
    } catch (error) {
      root.loadError("Unable to parse notification history: " + error)
      root.loaded([], 1)
    }
  }

  function save(records, nextRecordId) {
    const serialised = []

    for (const record of records) {
      serialised.push({
        recordId: record.recordId,
        notificationId: record.notificationId,
        appName: record.appName,
        appIcon: record.appIcon,
        desktopEntry: record.desktopEntry,
        summary: record.summary,
        body: record.body,
        image: record.image,
        timestampMs: record.timestampMs,
        read: record.read,
        urgent: record.urgent,
        dismissed: record.dismissed,
        actionData: record.actionData,
        resident: record.resident,
        transient: record.transient,
        hasInlineReply: record.hasInlineReply,
        inlineReplyPlaceholder: record.inlineReplyPlaceholder,
      })
    }

    const document = {
      version: 1,
      nextRecordId: nextRecordId,
      notifications: serialised,
    }

    try {
      file.setText(JSON.stringify(document))
    } catch (error) {
      root.saveError("Unable to write notification history: " + error)
    }
  }
}
