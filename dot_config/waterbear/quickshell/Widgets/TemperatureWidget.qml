import QtQuick
import "../Services"
import qs as Shell
import WallustTheme

Text {
  function tempFormat(t) {
    if (t === null) return "N/A"

    return t < 40 ? `${t}°C `
      : t < 55 ? `${t}°C `
      : t < 70 ? `${t}°C `
      : t < 85 ? `${t}°C `
      : `${t}°C `
  }

  function tempColor(t) {
    if (t === null) return Colors.textMuted
    return t < 55 ? Colors.text : Colors.urgent
  }

  text: tempFormat(Temperature.temperature)
  font: Shell.Style.uiFont
  color: tempColor(Temperature.temperature)
}
