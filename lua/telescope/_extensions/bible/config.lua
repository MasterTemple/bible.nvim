local home = os.getenv("HOME")

return  {
	home = home,
	plugin_dir = home .. "/.local/share/nvim/bible.nvim/",
	code_dir = home .. "/.local/share/nvim/lazy/bible.nvim/lua/telescope/_extensions/bible/",
	cache_dir = home .. "/.cache/nvim/bible.nvim/",
}
