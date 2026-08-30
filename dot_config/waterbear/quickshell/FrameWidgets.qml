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

        PowerWidget{ expanded: true }
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
  }
}
