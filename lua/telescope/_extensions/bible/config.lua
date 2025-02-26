local home = vim.fn.expand("$HOME")

local configPath = debug.getinfo(1).source:sub(2)
local configDir = vim.fn.fnamemodify(configPath, ":h")

return {
	home = home,
	-- plugin_dir = debug.getinfo(1).source:sub(2),
	code_dir = configDir .. "/",
	cache_dir = vim.fn.stdpath("data") .. "/bible.nvim/",
}
