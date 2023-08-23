local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local createBiblePreviewer = require("telescope._extensions.bible.previewer")
local Reference = require("telescope._extensions.bible.reference")

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
						local startRef = Reference:from_string(opts.value)
						local endRef = Reference:from_string(selection.value)
						local breakRef = endRef:next():ref()
						local verses = {}
						table.insert(verses, startRef:ref() .. " - " .. endRef:ref())
						while startRef:ref() ~= breakRef do
							table.insert(verses, startRef:inlinePrint())
							startRef = startRef:next()
						end
						vim.api.nvim_put(verses, "l", true, false)

					-- if is first and only value selected
					else
						vim.api.nvim_put({ ref.content, ref:ref() }, "l", true, false)
					end
				end)

				-- Tab prints the reference only
				map("i", "<tab>", function()
					local selection = require("telescope.actions.state").get_selected_entry()
					require("telescope.actions").close(prompt_bufnr)
					local ref = Reference:from_string(selection.value)
					vim.api.nvim_put({ ref:ref() }, "l", true, false)
				end)

				-- Alt+R prints the reference only
				map("i", "<A-r>", function()
					local selection = require("telescope.actions.state").get_selected_entry()
					require("telescope.actions").close(prompt_bufnr)
					local ref = Reference:from_string(selection.value)
					vim.api.nvim_put({ ref:ref() }, "l", true, false)
				end)

				-- Alt+W prints whole chapter
				map("i", "<A-w>", function()
					local selection = require("telescope.actions.state").get_selected_entry()
					require("telescope.actions").close(prompt_bufnr)
					local ref = Reference:from_string(selection.value)
					local chapterReferences = ref:chapter()
					local verses = {}
					table.insert(verses, ref:chRef())
					for _, v in ipairs(chapterReferences) do
						table.insert(verses, v:inlinePrint())
					end
					vim.api.nvim_put(verses, "l", true, false)
				end)

				-- Alt+M toggles multi-select
				map("i", "<A-m>", function()
					opts.isMultiSelect = not opts.isMultiSelect
					vim.api.nvim_echo({{'Multi-select = '.. tostring(opts.isMultiSelect)}}, false, {})
				end)

				return true
			end,
		})
		:find()
end

return versePicker
