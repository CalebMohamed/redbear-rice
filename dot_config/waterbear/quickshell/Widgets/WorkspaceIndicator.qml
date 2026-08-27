import QtQuick
import Quickshell.Hyprland

// all of this is assuming that the pips are 8 wide
Row {
  spacing: 2

  Repeater {
    model: 10 // made for 10 workspaces

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

      width: isFocused ? 10 : 8
      height: 10
      radius: isFocused ? 5 : 2

      transformOrigin: Item.Center
      y: isFocused ? -1 : 0 

      // animation on the properties for smooth transition
      Behavior on width { NumberAnimation { duration: 200 } }
      Behavior on radius { NumberAnimation { duration: 200 } }
      Behavior on y { NumberAnimation { duration: 200 } }
      Behavior on color { ColorAnimation { duration: 300 } }

      // dynamic color based on state
      color: {
        // focused give purple
        if (isFocused) return "#00d5be";
        // populated give light teal
        if (isPopulated) return "#90a1b9";
        // else empty give dark teal
        return "#314158";                       
      }
    }
  }
}
