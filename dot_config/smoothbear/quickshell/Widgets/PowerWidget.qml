import QtQuick
import "../Services/Power.qml"

Text {
  // directly access the time property from the Time singleton
  text: Power.energy
}
