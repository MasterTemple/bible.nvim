local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local createBiblePreviewer = require("telescope._extensions.bible.previewer")
local Reference = require("telescope._extensions.bible.reference")

local refreshPreview = function(prompt_bufnr)
	require('telescope.actions').move_selection_next(prompt_bufnr)
	require('telescope.actions').move_selection_previous(prompt_bufnr)
end

local printVerses = function(opts, startVerse, endVerse)
	-- set indentation to proper value
	local ind = vim.fn.getline('.'):match("^%s+") or ""
	local indent_type = vim.bo.expandtab and 'space' or 'tab'
	if opts.addIndent then
		if indent_type == 'space' then
			local indent_size = vim.bo.shiftwidth
			ind = ind .. string.rep(" ", indent_size)
		else
			ind = ind .. "\t"
		end
	end

	local startRef = Reference:from_string(startVerse, string.lower(opts.translation))
	if endVerse == nil then
		endVerse = startVerse
	end
	-- endVerse = endVerse or startVerse
	local endRef = Reference:from_string(endVerse, string.lower(opts.translation))
	local breakRef = endRef:next():ref()
	local verses = {}
	-- insert reference?
	if opts.insertReference then
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
	if opts.insertContent then
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
				-- Shift+Enter
				map("i", "<S-CR>", function()
					-- Your handler
					vim.api.nvim_echo({{"<S-CR>"}}, false, {})
				end)
				-- Disable any defaults that may conflict
				map("i", "<C-CR>", nil) 
				map("i", "<S-CR>", nil)

				-- Alt+Enter: works
				map("i", "<M-CR>", function()
					-- Your handler 
					vim.api.nvim_echo({{"<M-CR>"}}, false, {})
				end)

				-- Ctrl+Enter
				map("i", "<C-CR>", function()
					-- Your handler
					vim.api.nvim_echo({{"<C-CR>"}}, false, {})
				end)
				-- Enter prints the content and the reference
				map("i", "<CR>", function()
					local mods = vim.fn.getcharmod
					-- print(mods)
					-- print(tostring(mods == "S"))
					print(tostring(mods == "C"))
					local selection = require("telescope.actions.state").get_selected_entry()
					require("telescope.actions").close(prompt_bufnr)
					local ref = Reference:from_string(selection.value, string.lower(opts.translation))

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
				-- map("i", "<tab>", function()
					-- vim.api.nvim_echo({{tostring(conf.win_config)}}, false, {})
				-- end)

				-------------------
				-- CTRL COMMANDS --
				-------------------

				-- Ctrl+W prints whole chapter
				map("i", "<C-w>", function()
					local selection = require("telescope.actions.state").get_selected_entry()
					require("telescope.actions").close(prompt_bufnr)
					local ref = Reference:from_string(selection.value, string.lower(opts.translation))
					local chapterReferences = ref:chapter()
					printVerses(opts, chapterReferences[1]:ref(), chapterReferences[#chapterReferences]:ref())
				end)

				------------------
				-- ALT COMMANDS --
				------------------

				-- Alt+M toggles multi-select [current selection]
				map("i", "<A-m>", function()
					opts.isMultiSelect = not opts.isMultiSelect
					vim.api.nvim_echo({{'Multi-select = '.. tostring(opts.isMultiSelect)}}, false, {})
					refreshPreview(prompt_bufnr)
				end)

				-- Alt+R toggles show reference [global]
				map("i", "<A-r>", function()
					opts.insertReference = not opts.insertReference
					vim.api.nvim_echo({{'Insert Reference = '.. tostring(opts.insertReference)}}, false, {})
					refreshPreview(prompt_bufnr)
				end)

				-- Alt+C toggles show content [global]
				map("i", "<A-c>", function()
					opts.insertContent = not opts.insertContent
					vim.api.nvim_echo({{'Insert Content = '.. tostring(opts.insertContent)}}, false, {})
					refreshPreview(prompt_bufnr)
				end)

				-- Alt+I toggles add indent [global]
				map("i", "<A-i>", function()
					opts.addIndent = not opts.addIndent
					vim.api.nvim_echo({{'Add Indent = '.. tostring(opts.addIndent)}}, false, {})
					refreshPreview(prompt_bufnr)
				end)

				-- Alt+S toggles settings in preview [global]
				map("i", "<A-s>", function()
					opts.showBibleSettings = not opts.showBibleSettings
					-- local showBibleSettings = vim.api.nvim_get_var("showBibleSettings") 
					-- showBibleSettings = not showBibleSettings
					-- vim.api.nvim_set_var("showBibleSettings", showBibleSettings) 

					-- vim.api.nvim_echo({{'Show Settings in Preview = '.. tostring(showBibleSettings)}}, false, {})
					vim.api.nvim_echo({{'Show Settings in Preview = '.. tostring(opts.showBibleSettings)}}, false, {})
					refreshPreview(prompt_bufnr)
				end)

				-- Alt+T change Bible translation
				map("i", "<A-t>", function()
					vim.api.nvim_echo({{'This feature is in progress...'}}, false, {})
					refreshPreview(prompt_bufnr)
				end)

				return true
			end,
		})
		:find()
end

return versePicker
