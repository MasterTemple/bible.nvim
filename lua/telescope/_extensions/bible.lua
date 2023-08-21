local telescope = require('telescope')
local searches = require('telescope._extensions.bible.searches')
local versePicker = require('telescope._extensions.bible.picker')

local M = {}

M.bible = function(opts)
  opts = opts or {}
	local results = searches:getAllVerses()
	versePicker(opts, results)
end

return telescope.register_extension({
	exports = M
})
