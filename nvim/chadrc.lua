---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "neofusion",

	hl_ooverride = {
		Comment = { italic = true },
		["@comment"] = { italic = true },
	},
}

M.nvdash = { load_on_startup = false }
M.ui = {
	tabufline = {
		lazyload = false,
	},
}

return M
