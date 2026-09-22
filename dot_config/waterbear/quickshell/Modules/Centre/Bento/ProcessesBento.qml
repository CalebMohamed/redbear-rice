import QtQuick
import Quickshell

import qs as Shell
import WallustTheme

import "../../../Widgets"
import "../../../Services/"

BentoSquare {
  id: root

  function processColour(value) {
    return value >= 50 ? Colors.urgent
    : value >= 20 ? Colors.accent
    : Colors.text
  }

  function formatMemory(mib) {
    if (mib < 1024)
    return `${Math.round(mib)} MiB`

    return `${(mib / 1024).toFixed(1)} GiB`
  }

  function shortName(name) {
    if (name.length <= 16)
    return name

    return `${name.slice(0, 11)}…`
  }

  Item {
    anchors.fill: parent
    anchors.margins: 20

    Column {
      anchors.fill: parent
      spacing: 20

      // Header
      Row {
        spacing: 8

        Text {
          text: ""
          font: Shell.Style.uiFont
          color: Colors.text
        }

        Text {
          text: "processes"
          font: Shell.Style.uiFont
          color: Colors.text
        }

        Text {
          text: `${Processes.count}`

          font: Shell.Style.uiFont
          color: Colors.textMuted
        }
      }

      Column {
        width: parent.width
        spacing: 5

        // CPU
        Text {
          text: "CPU"
          font: Shell.Style.uiFont
          color: Colors.textMuted
        }


        Repeater {
          model: Math.min(3, Processes.byCpu.length)

          Item {
            width: parent.width
            height: 18

            readonly property var process:
            Processes.byCpu[index]

            Rectangle {
              anchors.fill: parent

              color: Qt.alpha(Colors.text, 0.06)
            }

            Rectangle {
              width: parent.width * Math.min(
                1,
                process.cpu / 100
              )

              height: parent.height

              color: Qt.alpha(
                processColour(process.cpu),
                0.35
              )
            }

            Text {
              anchors {
                left: parent.left
                leftMargin: 5
                verticalCenter: parent.verticalCenter
              }

              text: shortName(process.name)

              font: Shell.Style.uiFont
              color: Colors.text
            }

            Text {
              anchors {
                right: parent.right
                rightMargin: 5
                verticalCenter: parent.verticalCenter
              }

              text: `${process.cpu.toFixed(1)}%`

              font: Shell.Style.uiFont
              color: processColour(process.cpu)
            }
          }
        }
      }

      Column {
        width: parent.width
        spacing: 5

        // Memory
        Text {
          text: "RAM"
          font: Shell.Style.uiFont
          color: Colors.textMuted
        }

        Repeater {
          model: Math.min(3, Processes.byMemory.length)

          Item {
            width: parent.width
            height: 18

            readonly property var process:
            Processes.byMemory[index]

            Rectangle {
              anchors.fill: parent

              color: Qt.alpha(Colors.text, 0.06)
            }

            Rectangle {
              width: parent.width * Math.min(
                1,
                process.memory / 20
              )

              height: parent.height

              color: Qt.alpha(
                processColour(process.memory),
                0.35
              )
            }

            Text {
              anchors {
                left: parent.left
                leftMargin: 5
                verticalCenter: parent.verticalCenter
              }

              text: shortName(process.name)

              font: Shell.Style.uiFont
              color: Colors.text
            }

            Text {
              anchors {
                right: parent.right
                rightMargin: 5
                verticalCenter: parent.verticalCenter
              }

              text: formatMemory(process.rssMiB)

              font: Shell.Style.uiFont
              color: Colors.textMuted
            }
          }
        }
      }
    }
  }
}
