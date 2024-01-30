local telescope = require("telescope")
local searches = require("telescope._extensions.bible.searches")
local versePicker = require("telescope._extensions.bible.picker")
local createHighlightGroups = require("telescope._extensions.bible.highlights")

local M = {}

M.bible = function(opts)
	if opts == nil then
		opts = {}
	end

	createHighlightGroups(opts.customHighlightMap or {})

	if opts.showBibleSettings == nil then
		opts.showBibleSettings = true
	end
	if opts.insertReference == nil then
		opts.insertReference = true
	end
	if opts.insertContent == nil then
		opts.insertContent = true
	end
	if opts.addIndent == nil then
		opts.addIndent = true
	end
	if opts.translation == nil then
		opts.translation = "KJV"
	end
	print('DEBUGPRINT[1]: bible.lua:28: translation=' .. vim.inspect(opts.translation))
	if opts.customHighlightMap == nil then
		opts.customHighlightMap = {}
	end

	opts.isMultiSelect = opts.isMultiSelect or false
	opts.isSecondVerse = opts.isSecondVerse or false

	local results
	if opts.isReferenceOnly and opts.isSecondVerse then
		results = searches:getAllReferencesAfter(opts.value, string.lower(opts.translation))
	elseif opts.isReferenceOnly then
		results = searches:getAllReferences()
	elseif not opts.isReferenceOnly and opts.isSecondVerse then
		results = searches:getAllVersesAfter(opts.value, string.lower(opts.translation))
	elseif not opts.isReferenceOnly then
		results = searches:getAllVerses(string.lower(opts.translation))
	end

	versePicker(opts, results)
end

return telescope.register_extension({
	exports = M,
})
