import QtQuick
import "../Services/Time.qml"

Text {
  // directly access the time property from the Time singleton
  text: Time.time
}
