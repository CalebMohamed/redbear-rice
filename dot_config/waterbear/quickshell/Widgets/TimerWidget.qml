import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs as Shell
import WallustTheme

Item {
  id: root

  property int durationSeconds: 25 * 60
  property int remainingSeconds: durationSeconds
  property bool running: false
  property bool finished: false

  property double _endTime: 0

  property bool popupOpen: false
  property real popupProgress: 0

  implicitWidth: timerText.implicitWidth + 12
  implicitHeight: timerText.implicitHeight

  function formatTime(seconds) {
    const mins = Math.floor(seconds / 60)
    const secs = seconds % 60

    return `${String(mins).padStart(2, "0")}:${String(secs).padStart(2, "0")}`
  }

  function start() {
    if (remainingSeconds <= 0)
    remainingSeconds = durationSeconds

    finished = false
    _endTime = Date.now() + remainingSeconds * 1000
    running = true
  }

  function pause() {
    if (running)
    remainingSeconds = Math.max(
      0,
      Math.ceil((_endTime - Date.now()) / 1000)
    )

    running = false
  }

  function toggleRunning() {
    if (running)
    pause()
    else
    start()
  }

  function reset() {
    running = false
    finished = false
    remainingSeconds = durationSeconds
  }

  function adjustMinutes(delta) {
    if (running) {
      _endTime += delta * 60 * 1000

      remainingSeconds = Math.max(
        0,
        Math.ceil((_endTime - Date.now()) / 1000)
      )

      if (remainingSeconds <= 0) {
        running = false
        finished = true
      }
    } else {
      remainingSeconds = Math.max(
        60,
        remainingSeconds + delta * 60
      )

      durationSeconds = remainingSeconds
      finished = false
    }
  }

  function setPreset(minutes) {
    durationSeconds = minutes * 60
    remainingSeconds = durationSeconds
    finished = false

    if (running)
    _endTime = Date.now() + durationSeconds * 1000
  }

  Item {
    anchors.centerIn: parent

    implicitWidth: timerText.implicitWidth
    implicitHeight: timerText.implicitHeight

    Text {
      id: timerText
      property bool highlight: false

      anchors.centerIn: parent

      text: root.formatTime(root.remainingSeconds)

      font: Shell.Style.uiFont
      color: highlight ? Colors.accent
      : root.finished ? Colors.accent
      : root.running ? Colors.text
      : Colors.textMuted
    }

    MouseArea {
      anchors.fill: parent

      cursorShape: Qt.PointingHandCursor
      onClicked: root.popupOpen = !root.popupOpen

      hoverEnabled: true 
      onEntered: timerText.highlight = true 
      onExited: timerText.highlight = false 
    }
  }



  Timer {
    interval: 200
    repeat: true
    running: root.running

    onTriggered: {
      root.remainingSeconds = Math.max(
        0,
        Math.ceil((root._endTime - Date.now()) / 1000)
      )

      if (root.remainingSeconds <= 0) {
        root.running = false
        root.finished = true
      }
    }
  }

  PopupWindow {
    id: popup

    visible: root.popupOpen

    anchor {
      item: root
      edges: Edges.Top
      gravity: Edges.Top
    }

    implicitWidth: timerText.implicitWidth * 2
    implicitHeight: container.implicitHeight

    color: "transparent"

    Rectangle {
      id: popupContent

      width: parent.width
      height: parent.height
      radius: 10
      color: Colors.background
      clip: true

      x: 0
      y: height

      NumberAnimation {
        id: popupAnimation

        target: popupContent
        property: "y"

        from: popupContent.height / 2
        to: 0

        duration: 200
        easing.type: Easing.OutCubic
      }

      onVisibleChanged: {
        if (visible)
        popupAnimation.restart()
      }

      HoverHandler {
        onHoveredChanged: {
          if (!hovered)
          root.popupOpen = false
        }
      }

      ColumnLayout {
        id: container
        anchors.fill: parent
        anchors.margins: 6

        spacing: 5

        RowLayout {
          Layout.fillWidth: true
          Layout.preferredHeight: 32

          Item { Layout.fillWidth: true } // spacer

          Item {
            width: decrement.implicitWidth * 1.5
            height: decrement.implicitHeight * 1.5

            Text {
              id: decrement
              property bool highlight: false

              text: ""

              font: Shell.Style.uiFont
              color: decrement.highlight ? Colors.accent : Colors.text
            }

            MouseArea {
              id: decrementMouseArea
              anchors.fill: parent

              hoverEnabled: true 
              onEntered: decrement.highlight = true 
              onExited: decrement.highlight = false 

              cursorShape: Qt.PointingHandCursor

              onPressed: {
                root.adjustMinutes(-1)
                decrementDelay.start()
              }

              onReleased: {
                decrementDelay.stop()
                decrementRepeat.stop()
              }

              Timer {
                id: decrementDelay
                interval: 450
                repeat: false

                onTriggered: decrementRepeat.start()
              }

              Timer {
                id: decrementRepeat
                interval: 100
                repeat: true

                onTriggered: root.adjustMinutes(-1)
              }
            }
          }

          Item {
            width: toggle.implicitWidth * 1.5
            height: toggle.implicitHeight * 1.5

            Text {
              id: toggle
              property bool highlight: false

              text: root.running ? "" : ""

              font: Shell.Style.uiFont
              color: toggle.highlight ? Colors.accent : Colors.text
            }

            MouseArea {
              anchors.fill: parent

              hoverEnabled: true 
              onEntered: toggle.highlight = true 
              onExited: toggle.highlight = false 

              cursorShape: Qt.PointingHandCursor

              onClicked: root.toggleRunning()
            }
          }

          Item {
            width: increment.implicitWidth * 1.5
            height: increment.implicitHeight * 1.5

            Text {
              id: increment
              property bool highlight: false

              text: ""

              font: Shell.Style.uiFont
              color: increment.highlight ? Colors.accent : Colors.text

            }

            MouseArea {
              id: incrementMouseArea
              anchors.fill: parent

              hoverEnabled: true 
              onEntered: increment.highlight = true 
              onExited: increment.highlight = false 

              cursorShape: Qt.PointingHandCursor

              onPressed: {
                root.adjustMinutes(1)
                incrementDelay.start()
              }

              onReleased: {
                incrementDelay.stop()
                incrementRepeat.stop()
              }

              Timer {
                id: incrementDelay
                interval: 450
                repeat: false

                onTriggered: incrementRepeat.start()
              }

              Timer {
                id: incrementRepeat
                interval: 100
                repeat: true

                onTriggered: root.adjustMinutes(1)
              }
            }
          }

          Item { Layout.fillWidth: true } // spacer
        }

        RowLayout {
          Layout.fillWidth: true
          Layout.preferredHeight: 32

          Item { Layout.fillWidth: true } // spacer

          Item {
            width: ten.implicitWidth * 1.5
            height: ten.implicitHeight * 1.5

            Text {
              id: ten
              property bool highlight: false

              text: "󰔟"
              font: Shell.Style.uiFont
              color: ten.highlight ? Colors.accent : Colors.text
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor

              hoverEnabled: true 
              onEntered: ten.highlight = true 
              onExited: ten.highlight = false 

              onClicked: root.setPreset(10)
            }
          }

          Item {
            width: thirty.implicitWidth * 1.5
            height: thirty.implicitHeight * 1.5

            Text {
              id: thirty
              property bool highlight: false

              text: "󰔛"
              font: Shell.Style.uiFont
              color: thirty.highlight ? Colors.accent : Colors.text
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor

              hoverEnabled: true 
              onEntered: thirty.highlight = true 
              onExited: thirty.highlight = false 

              onClicked: root.setPreset(30)
            }
          }

          Item {
            width: hour.implicitWidth * 1.5
            height: hour.implicitHeight * 1.5

            Text {
              id: hour
              property bool highlight: false

              text: "󰔚"
              font: Shell.Style.uiFont
              color: hour.highlight ? Colors.accent : Colors.text
            }

            MouseArea {
              anchors.fill: parent
              cursorShape: Qt.PointingHandCursor

              hoverEnabled: true 
              onEntered: hour.highlight = true 
              onExited: hour.highlight = false 

              onClicked: root.setPreset(60)
            }
          }

          Item { Layout.fillWidth: true } // spacer
        }
      }
    }
  }
}
