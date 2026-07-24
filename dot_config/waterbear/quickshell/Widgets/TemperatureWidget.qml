import QtQuick
import "../Services"

Text {
  function tempFormat(t) {
    if (t === null) return "N/A"
    if (t < 40) return `${t}°C `   // thermometer-empty
    if (t < 55) return `${t}°C `   // thermometer-quarter
    if (t < 70) return `${t}°C `   // thermometer-half
    if (t < 85) return `${t}°C `   // thermometer-three-quarters
    return `${t}°C `               // thermometer-full
  }

  text: tempFormat(Temperature.temperature)
  font: Style.uiFont
  color: "white"
}
