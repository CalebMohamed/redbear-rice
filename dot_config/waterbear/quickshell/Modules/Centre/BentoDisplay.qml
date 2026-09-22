import QtQuick
import Quickshell

import qs as Shell
import WallustTheme

import "../../Widgets/Common"
import "../../Services"
import "./Bento"

Item {
  id: root
  required property CentreControls keyboardScope

  anchors {
    top: parent.top
    left: parent.left
    bottom: parent.bottom

    topMargin: 15 + Shell.Style.borderSize
    leftMargin: 15 + Shell.Style.borderSize
    bottomMargin: 15 + Shell.Style.borderSize
  }

  width: bento.implicitWidth

  Column {
    id: bento

    anchors.fill: parent
    // anchors.margins: 20
    spacing: 20

    Row {
      spacing: 20

      PowerBento {
        container: root
      }

      CPUBento {
        container: root
      }
    }

    Row {
      spacing: 20

      RAMBento {
        container: root
      }

      StorageBento {
        container: root
      }
    }

    Row {
      spacing: 20

      NetworkBento {
        container: root
      }

      ProcessesBento {
        container: root
      }
    }
  }

  MouseArea {
    anchors.fill: parent

    onClicked: mouse => mouse.accepted = true
  }
}
