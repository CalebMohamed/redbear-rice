import QtQuick
import Quickshell
import Quickshell.Hyprland
import WallustTheme

Text {
  text: Hyprland.activeToplevel ? (Hyprland.activeToplevel.title).toLowerCase() : "desktop"
  color: Colors.text
}
