pragma Singleton

import QtQuick

QtObject {
  readonly property font uiFont: Qt.font({
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
