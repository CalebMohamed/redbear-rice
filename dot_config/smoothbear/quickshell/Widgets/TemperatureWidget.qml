import QtQuick
import "../Services/Temperature.qml"

Text {
  // directly access the time property from the Time singleton
  text: Temperature.temperature
}
