local home = vim.fn.expand("$HOME") 
local os = vim.loop.os_uname().sysname

-- vim.api.nvim_echo({{home}}, false, {})
return  {
	home = home,
	plugin_dir = home .. "\\development\\personal\\nvim-plugins\\bible.nvim\\",
	code_dir = home .. "\\development\\personal\\nvim-plugins\\bible.nvim\\lua\\telescope\\_extensions\\bible\\",
	cache_dir = home .. "\\.cache\\nvim\\bible.nvim\\",
}
