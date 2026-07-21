pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

QtObject {
  id: root

  // Internal raw value (null until loaded)
  property var _tempValue: null

  // Readonly formatted property exposed globally
  readonly property string temperature: _tempValue !== null ? _tempValue + "°C" : "N/A"

  // Sensor reader
  property FileView _sensorFile: FileView {
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
