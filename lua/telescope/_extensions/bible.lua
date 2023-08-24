local telescope = require('telescope')
local searches = require('telescope._extensions.bible.searches')
local versePicker = require('telescope._extensions.bible.picker')

local M = {}

vim.g.translation = "ESV"
vim.g.showBibleSettings = true
vim.g.insertReference = true
vim.g.insertContent = true
vim.g.addIndent = true

M.bible = function(opts)
	if opts == nil then
		opts = {}
	end

	opts.isMultiSelect = opts.isMultiSelect or false
	opts.isSecondVerse = opts.isSecondVerse or false

	local results
	if(opts.isReferenceOnly and opts.isSecondVerse) then
		results = searches:getAllReferencesAfter(opts.value)
	elseif(opts.isReferenceOnly) then
		results = searches:getAllReferences()
	elseif(not opts.isReferenceOnly and opts.isSecondVerse) then
		results = searches:getAllVersesAfter(opts.value)
	elseif(not opts.isReferenceOnly) then
		results = searches:getAllVerses()
	end
	versePicker(opts, results)
end

return telescope.register_extension({
	exports = M
})
