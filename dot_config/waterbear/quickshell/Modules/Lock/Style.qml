pragma Singleton

import QtQuick

QtObject {
  readonly property font clockFont: Qt.font({
    family: "CaskaydiaCove NFM",
    pointSize: 64
  })

  readonly property font passwordFont: Qt.font({
    family: "CaskaydiaCove NFM",
    pointSize: 16
  })

  readonly property font errorFont: Qt.font({
    family: "CaskaydiaCove NFM",
    pointSize: 12
  })

  readonly property font iconFont: Qt.font({
    family: "CaskaydiaCove NFM",
    pointSize: 20
  })

  readonly property real borderSize: 30
  readonly property real cornerRadius: 15
}
