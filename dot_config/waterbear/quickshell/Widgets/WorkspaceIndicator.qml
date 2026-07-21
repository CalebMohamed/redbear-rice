import QtQuick
import Quickshell.Hyprland

Row {
    spacing: 8

    Repeater {
        model: 5 // made for 5 workspaces
        
        delegate: Rectangle {
            readonly property int wsId: index + 1
            
            // Check if this pip is the currently active/focused workspace
            readonly property bool isFocused: Hyprland.focusedMonitor 
                && Hyprland.focusedMonitor.activeWorkspace 
                && Hyprland.focusedMonitor.activeWorkspace.id === wsId

            // Check if the workspace actually contains windows/exists in Hyprland's map
            readonly property bool isPopulated: Hyprland.workspaces.values.some(
                ws => ws.id === wsId
            )

            width: isFocused ? 24 : 10
            height: 10
            radius: 5
            
            // animation on the properties for smooth transition
            Behavior on width { NumberAnimation { duration: 200 } }
            Behavior on color { ColorAnimation { duration: 200 } }

            // dynamic color based on state
            color: {
                if (isFocused) return "#ffffff";       // Focused: Bright White
                if (isPopulated) return "#888888";     // Populated but background: Gray
                return "#333333";                      // Empty: Dark Gray
            }
        }
    }
}
