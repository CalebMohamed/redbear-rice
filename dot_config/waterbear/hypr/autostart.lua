-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:
--
hl.on("hyprland.start", function () 
  hl.exec_cmd("qs")
  hl.exec_cmd("set-background 'chintz-pattern.jpg'")
  hl.exec_cmd("waybar")
  hl.exec_cmd("inhibit-idle-on-audio")
  hl.exec_cmd("swayidle -w timeout 300 'gaussian-lock' timeout 360 'systemctl suspend' before-sleep 'gaussian-lock'")
  hl.exec_cmd("mako")
  hl.exec_cmd("nm-applet")
  hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
  hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=dwl")
  hl.exec_cmd("nm-applet --indicator")
end)

