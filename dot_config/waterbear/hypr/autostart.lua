-------------------
---- AUTOSTART ----
-------------------

-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

-- Autostart necessary processes (like notifications daemons, status bars, etc.)
-- Or execute your favorite apps at launch like this:

local home = os.getenv("HOME")

hl.on("hyprland.start", function () 
  hl.exec_cmd("qs") -- my shell does most things!
  hl.exec_cmd(home .. "/.local/bin/set-background") -- background
  hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1") -- for priviledge escalation
  hl.exec_cmd("hypridle") -- for correct idling and locking
  hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=wayland") -- for DBUS integration (firefox correctly screen sharing)
  hl.exec_cmd("fcitx5") -- sets up the japanese romaji input program
end)
