import QtQuick
import Quickshell
import Quickshell.Wayland

import WallustTheme
import "../../Widgets/Common"

PanelWindow {
  id: root

  property int selectedIndex: 0
  property int rowHeight: 110

  visible: NotificationService.centreOpen
  focusable: NotificationService.centreOpen
  aboveWindows: true

  anchors {
    left: true
    right: true
    top: true
    bottom: true
  }

  exclusionMode: ExclusionMode.Ignore

  WlrLayershell.layer: WlrLayer.Overlay
  WlrLayershell.keyboardFocus:
  NotificationService.centreOpen
  ? WlrKeyboardFocus.Exclusive
  : WlrKeyboardFocus.None

  color: "transparent"

  // ---------------------------------------------------------------------------
  // Keyboard
  // ---------------------------------------------------------------------------

  FocusScope {
    id: keyboardScope

    anchors.fill: parent
    focus: NotificationService.centreOpen

    Keys.onPressed: event => {
      switch (event.key) {
        case Qt.Key_Escape:
        NotificationService.closeCentre()
        event.accepted = true
        break

        case Qt.Key_Up:
        case Qt.Key_K:
        moveSelection(-1)
        event.accepted = true
        break

        case Qt.Key_Down:
        case Qt.Key_J:
        moveSelection(1)
        event.accepted = true
        break

        case Qt.Key_Home:
        if (list.count > 0)
        list.currentIndex = 0
        event.accepted = true
        break

        case Qt.Key_End:
        if (list.count > 0)
        list.currentIndex = list.count - 1
        event.accepted = true
        break

        case Qt.Key_R:
        toggleSelectedRead()
        event.accepted = true
        break

        case Qt.Key_U:
        toggleSelectedUrgent()
        event.accepted = true
        break

        case Qt.Key_D:
        case Qt.Key_Delete:
        if (event.modifiers & Qt.ControlModifier) {
          NotificationService.clearDismissed()
        } else {
          dismissSelected()
        }

        event.accepted = true
        break

        case Qt.Key_H:
        toggleHistory()
        event.accepted = true
        break

        case Qt.Key_Return:
        case Qt.Key_Enter:
        activateSelected()
        event.accepted = true
        break
      }
    }

    function moveSelection(delta) {
      if (list.count === 0)
      return

      list.currentIndex = Math.max(
        0,
        Math.min(
          list.count - 1,
          list.currentIndex + delta
        )
      )
    }

    function selectedRecord() {
      if (list.currentIndex < 0 || list.currentIndex >= list.count)
      return null

      return NotificationService.model.values[list.currentIndex]
    }

    function toggleSelectedRead() {
      const record = selectedRecord()
      if (record)
      NotificationService.toggleRead(record.recordId)
    }

    function toggleSelectedUrgent() {
      const record = selectedRecord()
      if (record)
      NotificationService.toggleUrgent(record.recordId)
    }

    function dismissSelected() {
      const record = selectedRecord()
      if (!record)
      return

      if (record.dismissed) {
        NotificationService.restoreFromHistory(record.recordId)
        return
      }

      NotificationService.dismiss(record.recordId)

      if (list.count === 0) {
        root.selectedIndex = -1
        return
      }

      list.currentIndex = Math.min(
        list.currentIndex,
        list.count - 1
      )
    }

    function toggleHistory() {
      NotificationService.showDismissed =
      !NotificationService.showDismissed

      root.selectedIndex = list.count > 0 ? 0 : -1

      if (list.count > 0)
      list.currentIndex = 0
    }

    function activateSelected() {
      const record = selectedRecord()

      if (!record || !record.live)
      return

      if (record.actions.length > 0) {
        NotificationService.invokeAction(
          record.recordId,
          record.actions[0].identifier
        )
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Backdrop
  // ---------------------------------------------------------------------------

  Rectangle {
    anchors.fill: parent
    color: Colors.background
    opacity: 0.85

    MouseArea {
      anchors.fill: parent
      onClicked: NotificationService.closeCentre()
    }
  }

  // ---------------------------------------------------------------------------
  // Main panel
  // ---------------------------------------------------------------------------

  Rectangle {
    id: panel

    width: Math.min(parent.width * 0.42, 720)

    anchors {
      top: parent.top
      right: parent.right
      bottom: parent.bottom

      topMargin: 24
      rightMargin: 24
      bottomMargin: 24
    }

    radius: 16

    color: Colors.backgroundAlt
    border.width: 1
    border.color: Colors.text

    opacity: 0.98

    MouseArea {
      anchors.fill: parent

      // Consume clicks so that they don't hit the backdrop.
      onClicked: mouse => mouse.accepted = true
    }

    Column {
      anchors.fill: parent
      anchors.margins: 20
      spacing: 12

      // -----------------------------------------------------------------------
      // Header
      // -----------------------------------------------------------------------

      Item {
        width: parent.width
        height: 36

        Text {
          anchors.left: parent.left
          anchors.verticalCenter: parent.verticalCenter

          text: NotificationService.showDismissed
          ? "Notification history"
          : "Notifications"

          color: Colors.text
          font.pixelSize: 22
          font.bold: true
        }

        Row {
          anchors.right: parent.right
          anchors.verticalCenter: parent.verticalCenter

          spacing: 12

          ActionText {
            text: NotificationService.showDismissed
            ? "󰁪 Active"
            : "󰈙 History"

            textItem.color: hovered
            ? Colors.text
            : Colors.textMuted

            onClicked: toggleHistory()
          }

          ActionText {
            visible: NotificationService.showDismissed

            text: "󰆴 Clear"

            textItem.color: hovered
            ? Colors.urgent
            : Colors.textMuted

            onClicked: NotificationService.clearDismissed()
          }
        }
      }

      // -----------------------------------------------------------------------
      // Summary
      // -----------------------------------------------------------------------

      Text {
        width: parent.width

        text: NotificationService.showDismissed
        ? `${NotificationService.allNotifications.length} notifications`
        : `${NotificationService.records.filter(
          function(record) {
            return !record.dismissed
          }
        ).length} active notifications`

        color: Colors.textMuted
        font.pixelSize: 13
      }

      // -----------------------------------------------------------------------
      // Notification list
      // -----------------------------------------------------------------------

      ListView {
        id: list

        width: parent.width
        height: parent.height - 84

        clip: true
        spacing: 8

        model: NotificationService.model
        currentIndex: root.selectedIndex

        highlightMoveDuration: 100

        onCurrentIndexChanged: {
          root.selectedIndex = currentIndex

          if (currentIndex >= 0)
          positionViewAtIndex(
            currentIndex,
            ListView.Contain
          )
        }

        delegate: Rectangle {
          id: notificationDelegate

          required property var modelData
          required property int index

          width: list.width
          height: root.rowHeight

          radius: 10

          color: list.currentIndex === index
          ? Colors.background
          : Colors.backgroundAlt

          border.width: modelData.urgent ? 2 : 1

          border.color: modelData.urgent
          ? Colors.urgent
          : Colors.text

          // -------------------------------------------------------------------
          // Selection
          // -------------------------------------------------------------------

          MouseArea {
            anchors.fill: parent
            hoverEnabled: true

            onClicked: {
              list.currentIndex = notificationDelegate.index
            }
          }

          // -------------------------------------------------------------------
          // Content
          // -------------------------------------------------------------------

          Column {
            anchors.fill: parent
            anchors.margins: 12

            spacing: 5

            // Metadata ----------------------------------------------------------

            Row {
              width: parent.width
              spacing: 8

              Text {
                text: notificationDelegate.modelData.appName

                color: Colors.textMuted
                font.pixelSize: 12
              }

              Text {
                visible: !notificationDelegate.modelData.read

                text: "• unread"

                color: Colors.accent
                font.pixelSize: 12
              }

              Text {
                visible: notificationDelegate.modelData.urgent

                text: "󰀦 urgent"

                color: Colors.urgent
                font.pixelSize: 12
                font.bold: true
              }

              Text {
                visible: notificationDelegate.modelData.dismissed

                text: "󰈆 dismissed"

                color: Colors.text
                font.pixelSize: 12
              }
            }

            // Summary -----------------------------------------------------------

            Text {
              width: parent.width

              text: notificationDelegate.modelData.summary

              color: Colors.text

              font.pixelSize: 15
              font.bold: true

              elide: Text.ElideRight
            }

            // Body --------------------------------------------------------------

            Text {
              width: parent.width

              text: notificationDelegate.modelData.body

              color: Colors.textMuted

              font.pixelSize: 13

              maximumLineCount: 2
              elide: Text.ElideRight
            }

            // Actions -----------------------------------------------------------

            Row {
              width: parent.width
              spacing: 10

              ActionText {
                text: notificationDelegate.modelData.read
                ? "󰈇"
                : "󰈈"

                textItem.color: hovered
                ? Colors.text
                : Colors.textMuted

                onClicked:
                NotificationService.toggleRead(
                  notificationDelegate.modelData.recordId
                )
              }

              ActionText {
                text: notificationDelegate.modelData.urgent
                ? "󰂛"
                : "󰂚"

                textItem.color: hovered
                ? Colors.urgent
                : Colors.textMuted

                onClicked:
                NotificationService.toggleUrgent(
                  notificationDelegate.modelData.recordId
                )
              }

              ActionText {
                text: notificationDelegate.modelData.dismissed
                ? "󰁍"
                : "󰆴"

                textItem.color: hovered
                ? Colors.text
                : Colors.textMuted

                onClicked: {
                  if (
                    notificationDelegate.modelData.dismissed
                  ) {
                    NotificationService.restoreFromHistory(
                      notificationDelegate.modelData.recordId
                    )
                  } else {
                    NotificationService.dismiss(
                      notificationDelegate.modelData.recordId
                    )
                  }
                }
              }

              Repeater {
                model: notificationDelegate.modelData.live
                ? notificationDelegate.modelData.actions
                : notificationDelegate.modelData.actionData

                delegate: ActionText {
                  required property var modelData

                  text: modelData.text

                  enabled:
                  notificationDelegate.modelData.live

                  textItem.color: hovered
                  ? Colors.text
                  : Colors.textMuted

                  onClicked:
                  NotificationService.invokeAction(
                    notificationDelegate.modelData.recordId,
                    modelData.identifier
                  )
                }
              }
            }
          }
        }
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Focus
  // ---------------------------------------------------------------------------

  onVisibleChanged: {
    if (visible) {
      root.selectedIndex = list.count > 0 ? 0 : -1

      Qt.callLater(function() {
        keyboardScope.forceActiveFocus()

        if (list.count > 0)
        list.currentIndex = 0
      })
    }
  }
}
