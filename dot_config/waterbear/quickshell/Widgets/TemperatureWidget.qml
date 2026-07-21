import QtQuick
import "../Services"

Text {
  // directly access the time property from the Time singleton
  text: Temperature.temperature
}
