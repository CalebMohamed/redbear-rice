import QtQuick

Item {
  id: root

  property alias text: label.text
  property alias textItem: label

  property bool enabled: true
  readonly property bool hovered: mouse.containsMouse

  signal clicked()

  implicitWidth: label.implicitWidth
  implicitHeight: label.implicitHeight

  Text {
    id: label
    anchors.centerIn: parent
  }

  MouseArea {
    id: mouse
    anchors.fill: parent
    enabled: root.enabled
    hoverEnabled: true

    onClicked: root.clicked()
  }
}
