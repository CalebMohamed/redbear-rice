import QtQuick
import "../Services"
import qs as Shell
import WallustTheme

Text {
  function powerFormat(p, charging) {
    if (p === null) return "N/A"

    const icon = charging ? ""
      : p < 10 ? "󰁺"
      : p < 20 ? "󰁻"  
      : p < 30 ? "󰁼"
      : p < 40 ? "󰁽"
      : p < 50 ? "󰁾"
      : p < 60 ? "󰁿"
      : p < 70 ? "󰂀"
      : p < 80 ? "󰂁"
      : p < 90 ? "󰂂"
      : "󰁹"

    return `${p}% ${icon}`
  }

  function powerColor(p, charging) {
    if (p === null) return Colors.textMuted

    return charging ? Colors.accent
      : p < 10 ? Colors.urgent
      : Colors.text
  }

  text: powerFormat(Power.energy, Power.charging)
  font: Shell.Style.uiFont
  color: powerColor(Power.energy, Power.charging)
}
