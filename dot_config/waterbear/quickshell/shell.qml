// shell.qml

// import Quickshell
// 
// Scope {
//   Bar {}
// }

import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.UPower

ShellRoot {
    // Instantiate your custom temperature service
    TempService {
        id: tempService
    }

    PanelWindow {
        anchors {
            top: true
            left: true
            right: true
        }
        height: 40
        exclusionMode: ExclusionMode.Exclusive
        
        // Simple dark background container for the bar
        Rectangle {
            anchors.fill: parent
            color: "#111111"

            Row {
                anchors.centerIn: parent
                spacing: 30

                // 1. Your Custom Workspace Component
                WorkspaceIndicator {}

                // 2. Temperature using the new service style
                Text {
                    text: "Temp: " + tempService.temperature
                    color: "#ffffff"
                    font.pixelSize: 14
                }

                // 3. Battery Status via UPower
                Text {
                    text: "Battery: " + (UPower.displayDevice.ready 
                        ? Math.round(UPower.displayDevice.percentage) + "%" 
                        : "...")
                    color: "#ffffff"
                    font.pixelSize: 14
                }
            }
        }
    }
}
