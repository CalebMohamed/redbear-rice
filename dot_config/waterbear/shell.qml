import Quickshell
import QtQuick

ShellRoot {
    PanelWindow {
        anchors {
            top: true
            left: true
            right: true
            bottom: true
        }

        color: "black"

        Image {
            anchors.fill: parent
            source: "file:///home/caleb/pictures/wallpapers-processed/chintz-pattern.jpg"
            fillMode: Image.PreserveAspectCrop
        }
    }
}
