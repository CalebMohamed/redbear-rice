hl = require("hyprland")

hl.config({
  general = {
    gaps_in = 5,
    gaps_out = 10,
    border_size = 2,
  },

  decoration = {
    rounding = 10,
  },

  input = {
    kb_layout = "uk",
  },
})

-- terminal
bind("SUPER SHIFT", "RETURN", function()
  exec("foot")
end)

-- app launcher
bind("SUPER", "P", function()
  exec("wmenu-pretty --run")
end)

-- close window
bind("SUPER SHIFT", "C", function()
  active.kill()
end)

-- reload config
bind("SUPER SHIFT", "R", function()
  hyprctl("reload")
end)

require("autostart")
