local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local createBiblePreviewer = require("telescope._extensions.bible.previewer")
local Reference = require("telescope._extensions.bible.reference")

local printVerses = function(opts, startVerse, endVerse)
	-- set indentation to proper value
	local ind = vim.fn.getline('.'):match("^%s+")
	local indent_type = vim.bo.expandtab and 'space' or 'tab'
	if indent_type == 'space' then
		local indent_size = vim.bo.shiftwidth
		ind = ind .. string.rep(" ", indent_size) 
	else
		ind = ind .. "\t"
	end

	local startRef = Reference:from_string(startVerse)
	if endVerse == nil then
		endVerse = startVerse
	end
	-- endVerse = endVerse or startVerse
	local endRef = Reference:from_string(endVerse)
	local breakRef = endRef:next():ref()
	local verses = {}
	-- insert reference?
	if opts.showReference then
		local refString = startRef:ref()
		-- same
		if startRef:ref() == endRef:ref() then
			refString = startRef:ref()
		-- diff verse
		elseif startRef.bk == endRef.bk and startRef.ch == endRef.ch then
			refString = refString .. "-" .. endRef.v
		-- diff chapter and verse
		elseif startRef.bk == endRef.bk then
			refString = refString .. "-" .. endRef.ch .. ":" .. endRef.v
		-- diff book, chapter, and verse
		else
			refString = refString .. " - " .. endRef:ref()
		end
		table.insert(verses, ind .. refString)
	end
	-- insert all verses
	if opts.showContent then
		while startRef:ref() ~= breakRef do
			-- table.insert(verses, startRef:inlinePrint())
			table.insert(verses, ind .. startRef:inlinePrint())
			startRef = startRef:next()
		end
	end
	-- put all verses into buffer
	vim.api.nvim_put(verses, "l", true, false)
end


local versePicker = function(opts, results)
	local prompt_title = "Select Verse"
	if(opts.value) then
		prompt_title = "Select End Verse"
	end

	pickers
		.new(opts, {
			prompt_title = prompt_title,
			finder = finders.new_table({
				results = results,
				entry_maker = function(entry)
					return {
						value = entry,
						ordinal = entry,
						display = entry,
					}
				end,
			}),
			sorter = conf.generic_sorter(opts),
			previewer = createBiblePreviewer(opts),
			attach_mappings = function(prompt_bufnr, map)

				-- Enter prints the content and the reference
				map("i", "<CR>", function()
					local selection = require("telescope.actions.state").get_selected_entry()
					require("telescope.actions").close(prompt_bufnr)
					local ref = Reference:from_string(selection.value)

					-- if is multi-select and needs to select second verse
					if(opts.isMultiSelect and not opts.isSecondVerse) then
						opts.value = ref:ref()
						opts.isSecondVerse = true
						require("telescope").extensions.bible.bible(opts)
						return
					end

					-- if second value is selected
					if(opts.isSecondVerse) then
						printVerses(opts, opts.value, selection.value)
					-- if is first and only value selected
					else
						printVerses(opts, selection.value)
					end
				end)

				-- Tab [saving this for later]
				map("i", "<tab>", function()
				end)

				-- Ctrl+W prints whole chapter
				map("i", "<A-w>", function()
					local selection = require("telescope.actions.state").get_selected_entry()
					require("telescope.actions").close(prompt_bufnr)
					local ref = Reference:from_string(selection.value)
					local chapterReferences = ref:chapter()
					printVerses(opts, chapterReferences[1]:ref(), chapterReferences[#chapterReferences]:ref())
				end)

				-- Alt+M toggles multi-select
				map("i", "<A-m>", function()
					opts.isMultiSelect = not opts.isMultiSelect
					vim.api.nvim_echo({{'Multi-select = '.. tostring(opts.isMultiSelect)}}, false, {})
				end)

				-- Alt+R toggles show reference
				map("i", "<A-r>", function()
					opts.showReference = not opts.showReference
					vim.api.nvim_echo({{'Show Reference = '.. tostring(opts.showReference)}}, false, {})
				end)

				-- Alt+C toggles show content
				map("i", "<A-c>", function()
					opts.showContent = not opts.showContent
					vim.api.nvim_echo({{'Show Content = '.. tostring(opts.showContent)}}, false, {})
				end)

				return true
			end,
		})
		:find()
end

return versePicker
