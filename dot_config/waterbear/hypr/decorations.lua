local home = os.getenv("HOME")
local colors = dofile(home .. "/.cache/hypr/colors.lua")

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
  decoration = {
    rounding       = 10,
    rounding_power = 2,

    -- Change transparency of focused and unfocused windows
    active_opacity   = 1.0,
    inactive_opacity = 1.0,

    shadow = {
      enabled      = true,
      range        = 4,
      render_power = 3,
      color        = colors.background,
    },

    blur = {
      enabled   = true,
      size      = 3,
      passes    = 1,
      vibrancy  = 0.1696,
    },
  },
})

