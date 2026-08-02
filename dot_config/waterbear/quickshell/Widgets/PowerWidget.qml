import QtQuick
import "../Services"
import qs as Shell

Text {
  function powerFormat(p, charging) {
    if (p === null) return "N/A"

    const icon = charging ? ""
      : p < 10 ? ""
      : p < 30 ? ""
      : p < 60 ? ""
      : p < 90 ? ""
      : ""

    return `${p}% ${icon}`
  }

  text: powerFormat(Power.energy, Power.charging)
  font: Shell.Style.uiFont
  color: "white"
}
