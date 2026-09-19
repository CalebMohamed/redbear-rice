import Quickshell

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import qs as Shell
import WallustTheme

import "./Widgets"
import "./Widgets/Timer"

Scope {
  id: root

  required property var screen

  // =========================
  // Widgets
  // =========================

  // top border widgets
  PanelWindow {
    screen: root.screen

    anchors {
      top: true
      left: true
      right: true
    }

    implicitHeight: Shell.Style.borderSize
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    // top left widgets
    Item {
      anchors {
        left: parent.left
        verticalCenter: parent.verticalCenter
        leftMargin: Shell.Style.borderSize + Shell.Style.cornerRadius
      }

      width: tlWidgets.width
      height: tlWidgets.height

      RowLayout {
        id: tlWidgets
        anchors.centerIn: parent
        spacing: 12

        PowerWidget{}
        CPUWidget{}
        RAMWidget{}
        StorageWidget{}
        TemperatureWidget{}
      }
    }

    // top middle widgets
    Item {
      anchors.centerIn: parent

      width: tmWidgets.width
      height: tmWidgets.height

      RowLayout {
        id: tmWidgets
        anchors.centerIn: parent
        spacing: 12

        TitleWidget{}
      }
    }

    // top right widgets
    Item {
      anchors {
        right: parent.right
        verticalCenter: parent.verticalCenter
        rightMargin: Shell.Style.borderSize + Shell.Style.cornerRadius
      }

      width: trWidgets.width
      height: trWidgets.height

      RowLayout {
        id: trWidgets
        anchors.centerIn: parent
        spacing: 12

        NetworkWidget{ expanded: true }
      }
    }
  }

  // bottom border overlay
  PanelWindow {
    id: bwidgets
    screen: root.screen

    anchors {
      bottom: true
      left: true
      right: true
    }

    implicitHeight: Shell.Style.borderSize
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"

    // bottom left widgets
    Item {
      anchors {
        left: parent.left
        verticalCenter: parent.verticalCenter
        leftMargin: Shell.Style.borderSize + Shell.Style.cornerRadius
      }

      width: blWidgets.width
      height: blWidgets.height

      RowLayout {
        id: blWidgets
        anchors.centerIn: parent
        spacing: 12

        WorkspaceIndicator{}
        ClockWidget{}
      }
    }

    // bottom middle widgets
    Item {
      anchors.centerIn: parent

      width: bmWidgets.width
      height: bmWidgets.height

      RowLayout {
        id: bmWidgets
        anchors.centerIn: parent
        spacing: 12

        TimerWidget{}
      }
    }

    // bottom right widgets
    Item {
      anchors {
        right: parent.right
        verticalCenter: parent.verticalCenter
        rightMargin: Shell.Style.borderSize + Shell.Style.cornerRadius
      }

      width: brWidgets.width
      height: brWidgets.height

      RowLayout {
        id: brWidgets
        anchors.centerIn: parent
        spacing: 12

        NotificationWidget {}
      }
    }
  }

  // left border overlay
  // PanelWindow {
  //   id: lwidgets
  //   screen: root.screen

  //   anchors {
  //     top: true
  //     bottom: true
  //     left: true
  //   }

  //   implicitWidth: Shell.Style.borderSize
  //   exclusionMode: ExclusionMode.Ignore
  //   color: "transparent"

  //   // left top widgets
  //   Item {
  //     anchors {
  //       horizontalCenter: parent.horizontalCenter
  //       top: parent.top
  //       topMargin: Shell.Style.borderSize + Shell.Style.cornerRadius
  //     }

  //     width: ltWidgets.width
  //     height: ltWidgets.height

  //     RowLayout {
  //       id: ltWidgets
  //       anchors.centerIn: parent
  //       spacing: 12
  //       // removed the TrayWidget because i don't like them and they take a lot of work use nmtui instead
  //     }
  //   }
  // }
}
