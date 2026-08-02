import QtQuick
import "../Services"
import qs as Shell

Text {
  text: Time.date
  font: Shell.Style.uiFont
  color: "white"
}
