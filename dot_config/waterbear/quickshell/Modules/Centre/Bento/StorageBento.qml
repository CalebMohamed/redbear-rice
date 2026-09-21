import QtQuick
import Quickshell

import qs as Shell
import WallustTheme

import "../../../Widgets/"
import "../../../Services/"

BentoSquare {
  id: root

  function colour(usage) {
    return usage >= 90 ? Colors.urgent
    : usage >= 70 ? Colors.accent
    : Colors.text
  }

  function colourMuted(usage) {
    return usage >= 90 ? Colors.urgent
    : usage >= 70 ? Colors.accent
    : Colors.textMuted
  }

  function formatBytes(bytes) {
    if (bytes < 1024 * 1024 * 1024)
    return `${Math.round(bytes / (1024 * 1024))} MiB`

    if (bytes < 1024 * 1024 * 1024 * 1024)
    return `${(bytes / (1024 * 1024 * 1024)).toFixed(1)} GiB`

    return `${(bytes / (1024 * 1024 * 1024 * 1024)).toFixed(1)} TiB`
  }

  function formatRate(bytesPerSecond) {
    if (bytesPerSecond < 1024)
    return `${Math.round(bytesPerSecond)} B/s`

    if (bytesPerSecond < 1024 * 1024)
    return `${(bytesPerSecond / 1024).toFixed(1)} KiB/s`

    if (bytesPerSecond < 1024 * 1024 * 1024)
    return `${(bytesPerSecond / (1024 * 1024)).toFixed(1)} MiB/s`

    return `${(bytesPerSecond / (1024 * 1024 * 1024)).toFixed(1)} GiB/s`
  }

  Item {
    anchors.fill: parent

    Column {
      anchors {
        top: parent.top
        left: parent.left
        right: parent.right
        margins: 20
      }

      spacing: 12

      // Header
      Row {
        spacing: 8

        Text {
          text: "󰋊"
          font: Shell.Style.uiFont
          color: colour(Storage.usage)
        }

        Text {
          text: "storage"
          font: Shell.Style.uiFont
          color: Colors.text
        }
      }

      // Filesystem list
      Column {
        width: parent.width
        spacing: 6

        Repeater {
          model: Storage.filesystems

          delegate: Item {
            width: parent.width
            height: 24

            // Background
            Rectangle {
              anchors.fill: parent
              color: Qt.alpha(Colors.text, 0.1)
            }

            // Usage fill
            Rectangle {
              width: parent.width * Math.max(
                0,
                Math.min(1, modelData.usage / 100)
              )
              height: parent.height

              color: colourMuted(modelData.usage)

              Behavior on width {
                NumberAnimation {
                  duration: 150
                  easing.type: Easing.OutCubic
                }
              }
            }

            // Capacity text overlaid on top
            Text {
              anchors {
                right: parent.right
                rightMargin: 6
                verticalCenter: parent.verticalCenter
              }

              text: `${formatBytes(modelData.usedBytes)} / ${formatBytes(modelData.totalBytes)}`

              font: Shell.Style.uiFont
              color: Colors.text
            }

            // Mount name overlaid on the left
            Text {
              anchors {
                left: parent.left
                leftMargin: 6
                verticalCenter: parent.verticalCenter
              }

              text: modelData.mountpoint === "/"
              ? "root"
              : modelData.mountpoint

              font: Shell.Style.uiFont
              color: Colors.text
            }
          }

          // delegate: Column {
          //   width: parent.width
          //   spacing: 4

          //   Row {
          //     width: parent.width
          //     height: 18

          //     spacing: 8

          //     Text {
          //       width: 50

          //       text: modelData.mountpoint === "/"
          //       ? "root"
          //       : modelData.mountpoint

          //       elide: Text.ElideRight
          //       font: Shell.Style.uiFont
          //       color: Colors.textMuted
          //     }

          //     Item {
          //       width: parent.width - 50 - 8
          //       height: 8

          //       anchors.verticalCenter: parent.verticalCenter

          //       Rectangle {
          //         anchors.fill: parent

          //         color: Qt.alpha(Colors.text, 0.1)
          //       }

          //       Rectangle {
          //         width: parent.width * Math.max(0, Math.min(1, modelData.usage / 100))
          //         height: parent.height

          //         color: colour(modelData.usage)

          //         Behavior on width {
          //           NumberAnimation {
          //             duration: 100
          //             easing.type: Easing.OutCubic
          //           }
          //         }
          //       }
          //     }
          //   }

          //   Text {
          //     horizontalAlignment: Text.AlignRight

          //     width: parent.width

          //     text: `${formatBytes(modelData.usedBytes)} / ${formatBytes(modelData.totalBytes)}`
          //     font: Shell.Style.uiFont
          //     color: colour(modelData.usage)
          //   }
          // }
        }
      }

      // Current throughput
      Row {
        spacing: 12

        Text {
          text: `↓ ${formatRate(Storage.readBytesPerSecond)}`
          font: Shell.Style.uiFont
          color: Colors.textMuted
        }

        Text {
          text: `↑ ${formatRate(Storage.writeBytesPerSecond)}`
          font: Shell.Style.uiFont
          color: Colors.accent
        }
      }
    }

    // Read history
    Sparkline {
      anchors {
        left: parent.left
        bottom: parent.bottom
        leftMargin: 20
        bottomMargin: 20
      }

      width: (parent.width - 52) / 2
      height: 28

      samples: Storage.history
      valueKey: "readBytesPerSecond"

      lineColor: Colors.text
      minimumRange: 1024 * 1024
    }

    // Write history
    Sparkline {
      anchors {
        right: parent.right
        bottom: parent.bottom
        rightMargin: 20
        bottomMargin: 20
      }

      width: (parent.width - 52) / 2
      height: 28

      samples: Storage.history
      valueKey: "writeBytesPerSecond"

      lineColor: Colors.accent
      minimumRange: 1024 * 1024
    }
  }
}
