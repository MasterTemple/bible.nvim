local createBibleHighlightGroup = function(name, fg, bg)
	bg = bg or "NONE"
	local highlightAttributes = {
			guifg = fg, -- Set foreground color
			guibg = bg,  -- Set background color
			gui = "NONE",    -- Reset additional attributes
	}
	local attributesString = ""
	for key, value in pairs(highlightAttributes) do
			attributesString = attributesString .. key .. "=" .. value .. " "
	end
	local highlightGroupCommand = string.format("highlight %s %s", "Bible." .. name, attributesString)
	vim.api.nvim_command(highlightGroupCommand)
end

local defaultHighlightMap = {
	{ name = "Keybind", fg = "#c488ec" },
	{ name = "VerseNumber", fg = "#f26e74" },
	{ name = "Translation", fg = "#82c29c" },
	{ name = "True", fg = "#82c29c" },
	{ name = "False", fg = "#f26e74" },
	{ name = "Delimeters", fg = "#79aaeb" },
	{ name = "FocusedVerse", fg = "#edc28b", bg = "#222253" },
}

local createHighlightGroups = function(customHighlightMap)
	for _, hl in ipairs(defaultHighlightMap) do
		createBibleHighlightGroup(hl.name, hl.fg, hl.bg)
	end
	for _, hl in ipairs(customHighlightMap) do
		createBibleHighlightGroup(hl.name, hl.fg, hl.bg)
	end
end

return createHighlightGroups

