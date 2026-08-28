local home = os.getenv("HOME")
local colors = dofile(home .. "/.cache/hypr/colors.lua")

-- Refer to https://wiki.hypr.land/Configuring/Basics/Variables/
hl.config({
  general = {
    gaps_in  = 5,
    gaps_out = 20,

    border_size = 2,

    col = {
      active_border   = { colors = {colors.text, colors.accent}, angle = 315 },
      inactive_border = colors.textMuted,
    },

    layout = "dwindle",

  },

  dwindle = {
    preserve_split = true, -- You probably want this
  },
})
