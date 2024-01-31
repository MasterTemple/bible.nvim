local telescope = require("telescope")
local searches = require("telescope._extensions.bible.searches")
local versePicker = require("telescope._extensions.bible.picker")
local createHighlightGroups = require("telescope._extensions.bible.highlights")
local config = require("telescope._extensions.bible.config")

local translations = {}
local files = vim.fn.glob(config.code_dir .. "json/t_*.json", false, true)
for i, v in ipairs(files) do
	local translation = v:match("t_(.+).json")
	table.insert(translations, translation)
end

local file_path = config.cache_dir .. "config.json"
local exists = os.rename(config.cache_dir, config.cache_dir)
if not exists then
	os.execute("mkdir " .. config.cache_dir)
end

local M = {}
M.bible = function(opts)
	local iFile = io.open(file_path, "r")
	if iFile then
		if opts == nil then
			opts = vim.json.decode(iFile:read())
		else
			local json = vim.json.decode(iFile:read())
			if json then
				for k, v in pairs(json) do
					if opts[k] == nil and k ~= "isSecondVerse" and k ~= "value" then
						opts[k] = v
					end
				end
			end
		end
		iFile:close()
	end

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
		opts.translation = string.upper(translations[1])
	end
	if opts.customHighlightMap == nil then
		opts.customHighlightMap = {}
	end
	if opts.translations == nil then
		opts.translations = translations
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

	local optsToSave = vim.json.encode(opts)
	local oFile = io.open(file_path, "w")
	if oFile then
		oFile:write(optsToSave)
		oFile:close()
	end
	versePicker(opts, results)
end

return telescope.register_extension({
	exports = M,
})
