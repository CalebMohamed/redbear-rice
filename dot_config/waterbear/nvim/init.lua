local filePath = "~/nvim-configs/archleb"
local initPath = filePath .. "/init.lua"
vim.opt.runtimepath:prepend(filePath)
vim.cmd.source(initPath)
