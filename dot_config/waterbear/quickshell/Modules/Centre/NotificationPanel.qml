import QtQuick
import Quickshell
import Quickshell.Wayland

import qs as Shell
import WallustTheme

import "../../Widgets/Common"
import "../../Services"

Rectangle {
  id: root
  required property CentreControls keyboardScope

  property int selectedIndex: 0

  width: Math.min(parent.width * 0.40, 720)

  anchors {
    top: parent.top
    right: parent.right
    bottom: parent.bottom

    topMargin: 15 + Shell.Style.borderSize
    rightMargin: 15 + Shell.Style.borderSize
    bottomMargin: 15 + Shell.Style.borderSize
  }

  radius: Shell.Style.cornerRadius
  color: Colors.background

  MouseArea {
    anchors.fill: parent

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
        ? "notification history"
        : "notifications"

        color: Colors.text
        font: Shell.Style.h1Font
      }

      Row {
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter

        spacing: 12

        ActionText {
          text: NotificationService.showDismissed
          ? "󰁪 active"
          : "󰈙 history"

          textItem.color: hovered
          ? Colors.text
          : Colors.textMuted

          textItem.font: Shell.Style.uiFont

          onClicked: toggleHistory()
        }

        ActionText {
          visible: NotificationService.showDismissed

          text: "󰆴 clear"

          textItem.color: hovered
          ? Colors.urgent
          : Colors.textMuted

          textItem.font: Shell.Style.uiFont

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
      font: Shell.Style.uiFont
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

        if (currentIndex >= 0) {
          positionViewAtIndex(
            currentIndex,
            ListView.Contain
          )
        }
      }

      delegate: Rectangle {
        id: notificationDelegate

        required property var modelData
        required property int index

        width: list.width

        // The delegate now grows with its contents.
        height: content.implicitHeight + 24

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
            list.currentIndex =
            notificationDelegate.index
          }
        }

        // -------------------------------------------------------------------
        // Content
        // -------------------------------------------------------------------

        Column {
          id: content

          anchors {
            left: parent.left
            right: parent.right
            top: parent.top
            margins: 12
          }

          spacing: 5

          // -----------------------------------------------------------------
          // Metadata
          // -----------------------------------------------------------------

          Row {
            width: parent.width
            spacing: 8

            Text {
              text: notificationDelegate.modelData.appName

              color: Colors.textMuted
              font: Shell.Style.uiFont
            }

            Text {
              visible:
              !notificationDelegate.modelData.read

              text: "• unread"

              color: Colors.accent
              font: Shell.Style.uiFont
            }

            Text {
              visible:
              notificationDelegate.modelData.urgent

              text: "󰀦 urgent"

              color: Colors.urgent
              font: Shell.Style.uiFont
            }

            Text {
              visible:
              notificationDelegate.modelData.dismissed

              text: "󰈆 dismissed"

              color: Colors.text
              font: Shell.Style.uiFont
            }
          }

          // -----------------------------------------------------------------
          // Summary
          // -----------------------------------------------------------------

          Text {
            width: parent.width

            text: notificationDelegate.modelData.summary

            color: Colors.text
            font: Shell.Style.h2Font

            wrapMode: Text.Wrap
          }

          // -----------------------------------------------------------------
          // Body
          // -----------------------------------------------------------------

          Text {
            width: parent.width

            text: notificationDelegate.modelData.body

            color: Colors.textMuted
            font: Shell.Style.contentFont

            wrapMode: Text.Wrap

            // Prevent an absurdly large notification from taking
            // over the entire centre.
            maximumLineCount: 5
            elide: Text.ElideRight
          }

          // -----------------------------------------------------------------
          // Actions
          // -----------------------------------------------------------------

          Flow {
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
              model:
              notificationDelegate.modelData.live
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

  // ---------------------------------------------------------------------------
  // public API (for the keyboard control) 
  // ---------------------------------------------------------------------------
  
  function selectFirst() {
    if (list.count > 0)
    list.currentIndex = 0
  }

  function selectLast() {
    if (list.count > 0)
    list.currentIndex = list.count - 1
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
    if (
      list.currentIndex < 0
      || list.currentIndex >= list.count
    )
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

  // ---------------------------------------------------------------------------
  // Focus
  // ---------------------------------------------------------------------------

  onVisibleChanged: {
    if (visible) {
      root.selectedIndex =
      list.count > 0 ? 0 : -1

      Qt.callLater(function() {
        keyboardScope.forceActiveFocus()

        if (list.count > 0)
        list.currentIndex = 0
      })
    }
  }
}
