local telescope = require('telescope')
local searches = require('telescope._extensions.bible.searches')
local versePicker = require('telescope._extensions.bible.picker')

local M = {}

M.bible = function(opts)
  opts = opts or {}
	local results = searches:getAllVerses()
	versePicker(opts, results)
end

M.bible_after = function(opts)
  opts = opts or {}
	local cur = tostring(opts.value)
  local results = searches:getAllVersesAfter(cur)
	versePicker(opts, results)
end

M.bible_ref = function(opts)
  opts = opts or {}
  local results = searches:getAllReferences()
	versePicker(opts, results)
end

M.bible_ref_after = function(opts)
  opts = opts or {}
	local cur = tostring(opts.value)
  local results = searches:getAllReferencesAfter(cur)
	versePicker(opts, results)
end

return telescope.register_extension({
	exports = M
})
