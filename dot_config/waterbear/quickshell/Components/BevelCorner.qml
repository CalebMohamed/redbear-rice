import QtQuick
import QtQuick.Shapes

import qs as Shell

Item {
  id: corner

  property real radius: Shell.Style.cornerRadius
  property color colour: "red"

  width: radius
  height: radius

  Shape {
    anchors.fill: parent
    antialiasing: true

    ShapePath {
      fillColor: corner.colour
      strokeWidth: -1

      startX: 0
      startY: corner.radius

      PathLine {
        x: corner.radius
        y: corner.radius
      }

      PathArc {
        x: 0
        y: 0 

        radiusX: corner.radius
        radiusY: corner.radius

        useLargeArc: false
        direction: PathArc.Clockwise
      }

      PathLine {
        x: 0
        y: corner.radius
      }
    }
  }
}
