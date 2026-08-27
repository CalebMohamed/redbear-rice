import QtQuick
import "../Services"
import qs as Shell
import WallustTheme

Text {
  text: Time.date
  font: Shell.Style.uiFont
  color: Colors.text
}
