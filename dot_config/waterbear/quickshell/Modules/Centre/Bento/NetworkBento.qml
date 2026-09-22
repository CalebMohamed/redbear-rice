import QtQuick
import Quickshell

import qs as Shell
import WallustTheme

import "../../../Widgets"
import "../../../Services/"

BentoSquare {
  id: root

  function formatRate(bytesPerSecond) {
    if (bytesPerSecond < 1024)
    return `${Math.round(bytesPerSecond)} B/s`

    if (bytesPerSecond < 1024 * 1024)
    return `${(bytesPerSecond / 1024).toFixed(1)} KiB/s`

    if (bytesPerSecond < 1024 * 1024 * 1024)
    return `${(bytesPerSecond / (1024 * 1024)).toFixed(1)} MiB/s`

    return `${(bytesPerSecond / (1024 * 1024 * 1024)).toFixed(1)} GiB/s`
  }

  function formatPackets(rate) {
    if (rate < 1000)
    return `${Math.round(rate)}`

    if (rate < 1000000)
    return `${(rate / 1000).toFixed(1)}k`

    return `${(rate / 1000000).toFixed(1)}M`
  }

  function signalColour(strength) {
    return strength < 0.2 ? Colors.urgent
    : strength < 0.5 ? Colors.accent
    : Colors.text
  }

  function signalIcon(strength) {
    return strength < 0.2 ? "󰤟"
    : strength < 0.4 ? "󰤢"
    : strength < 0.7 ? "󰤥"
    : "󰤨"
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

      spacing: 20

      // Header
      Row {
        spacing: 8

        Text {
          text: Network.connected
          ? (Network.wired ? "󰈀" : signalIcon(Network.strength))
          : "󰤭"

          font: Shell.Style.uiFont
          color: Network.connected
          ? signalColour(Network.strength)
          : Colors.textMuted
        }

        Text {
          text: "network"

          font: Shell.Style.uiFont
          color: Colors.text
        }
      }

      // Network identity / signal
      Row {
        width: parent.width
        spacing: 10

        Text {
          width: parent.width * 0.65

          text: Network.connected
          ? Network.networkName
          : "disconnected"

          elide: Text.ElideRight

          font: Shell.Style.uiFont
          color: Colors.text
        }

        Item {
          id: signalBars

          width: parent.width * 0.35
          height: 16

          Row {
            id: signalRow

            anchors.bottom: parent.bottom

            height: parent.height
            spacing: 3

            Repeater {
              model: 4

              Rectangle {
                anchors.bottom: signalRow.bottom

                width: signalBars.width / 6
                height: 4 + index * 3

                color: {
                  if (!Network.connected)
                  return Qt.alpha(Colors.text, 0.1)

                  if (Network.wired)
                  return Colors.accent

                  return Network.strength >= (index + 1) / 4
                  ? signalColour(Network.strength)
                  : Qt.alpha(Colors.text, 0.1)
                }
              }
            }
          }
        }
      }

      // Connection details
      Row {
        spacing: 12

        Text {
          visible: Network.connected

          text: Network.wired
          ? "wired"
          : `${Math.round(Network.strength * 100)}% signal`

          font: Shell.Style.uiFont
          color: Network.wired
          ? Colors.textMuted
          : signalColour(Network.strength)
        }

        Text {
          visible: Network.connected && Network.ipv4 !== ""

          text: Network.ipv4

          font: Shell.Style.uiFont
          color: Colors.textMuted
        }
      }

      // TX/RX rates
      Row {
        spacing: 8

        Text {
          text: "↓"
          font: Shell.Style.uiFont
          color: Colors.text
        }

        Text {
          text: formatRate(Network.receiveBytesPerSecond)

          font: Shell.Style.uiFont
          color: Colors.text
        }

        Text {
          text: "↑"
          font: Shell.Style.uiFont
          color: Colors.accent
        }

        Text {
          text: formatRate(Network.transmitBytesPerSecond)

          font: Shell.Style.uiFont
          color: Colors.accent
        }
      }

      // Packet activity
      Row {
        spacing: 8

        Text {
          text: "↓"
          font: Shell.Style.uiFont
          color: Colors.textMuted
        }

        Text {
          text: `${formatPackets(Network.receivePacketsPerSecond)} pkt/s`

          font: Shell.Style.uiFont
          color: Colors.textMuted
        }

        Text {
          text: "↑"
          font: Shell.Style.uiFont
          color: Colors.textMuted
        }

        Text {
          text: `${formatPackets(Network.transmitPacketsPerSecond)} pkt/s`
          font: Shell.Style.uiFont
          color: Colors.textMuted
        }
      }
    }

    // Receive history
    Sparkline {
      anchors {
        left: parent.left
        bottom: parent.bottom
        leftMargin: 20
        bottomMargin: 20
      }

      width: (parent.width - 52) / 2
      height: 32

      samples: Network.history
      valueKey: "receiveBytesPerSecond"

      lineColor: Colors.text
      minimumRange: 1024 * 1024
    }

    // Transmit history
    Sparkline {
      anchors {
        right: parent.right
        bottom: parent.bottom
        rightMargin: 20
        bottomMargin: 20
      }

      width: (parent.width - 52) / 2
      height: 32

      samples: Network.history
      valueKey: "transmitBytesPerSecond"

      lineColor: Colors.accent
      minimumRange: 1024 * 1024
    }
  }
}
