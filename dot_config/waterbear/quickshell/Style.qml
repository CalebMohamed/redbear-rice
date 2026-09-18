pragma Singleton

import QtQuick

QtObject {
  readonly property font uiFont: Qt.font({
    family: "CaskaydiaCove NFM",
    pointSize: 12
  })

  readonly property font h1Font: Qt.font({
    family: "CaskaydiaCove NFM",
    pointSize: 24
  })

  readonly property font h2Font: Qt.font({
    family: "CaskaydiaCove NFM",
    pointSize: 18
  })

  readonly property font contentFont: Qt.font({
    family: "CaskaydiaCove NFM",
    pointSize: 16
  })

  readonly property font iconFont: Qt.font({
    family: "CaskaydiaCove NFM",
    pointSize: 20
  })

  readonly property real borderSize: 30
  readonly property real cornerRadius: 15
}
