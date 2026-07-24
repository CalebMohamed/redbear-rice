pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
  id: root

  // Internal raw value (null until loaded)
  property var _tempValue: null

  // Readonly formatted property exposed globally
  readonly property var temperature: _tempValue 

  // Sensor reader
  property FileView sensorFile: FileView {
    id: sensorFile
    path: "/sys/class/thermal/thermal_zone7/temp"
    watchChanges: true

    onLoaded: (data) => {
      let rawTemp = parseInt(sensorFile.text().trim());
      if (!isNaN(rawTemp)) {
        root._tempValue = Math.round(rawTemp / 1000);
      }
    }
  }
}
