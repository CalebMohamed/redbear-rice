import QtQuick
import QtQuick.Shapes

Item {
  id: root

  property real borderWidth: 10
  property real radius: 14
  property color color: "#1e1e2e"

  // Enough room for the border plus the rounded corner.
  implicitWidth: borderWidth + radius
  implicitHeight: borderWidth + radius

  Shape {
    anchors.fill: parent

    ShapePath {
      fillColor: root.color
      strokeWidth: 0

      // Outer top-left corner
      startX: 0
      startY: 0

      // Top edge
      PathLine {
        x: root.width
        y: 0
      }

      // Right, down to the inner curve
      PathLine {
        x: root.width
        y: root.borderWidth
      }

      // Rounded inner corner
      PathArc {
        x: root.borderWidth
        y: root.height
        radiusX: root.radius
        radiusY: root.radius
        direction: PathArc.Counterclockwise
      }

      // Bottom edge
      PathLine {
        x: 0
        y: root.height
      }

      PathLine {
        x: 0
        y: 0
      }
    }
  }
}
