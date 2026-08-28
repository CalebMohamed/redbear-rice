pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
  id: root

  readonly property var temperature: _tempValue 

  property var _tempValue: null

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
