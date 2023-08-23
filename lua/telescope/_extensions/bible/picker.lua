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
					-- is second value selected
					if(opts.value) then
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
					-- is first and only value selected
					else
						local ref = Reference:from_string(selection.value)
						vim.api.nvim_put({ ref.content, ref:ref() }, "l", true, false)
					end
				end)
				-- tab prints the reference only
				map("i", "<tab>", function()
					local selection = require("telescope.actions.state").get_selected_entry()
					require("telescope.actions").close(prompt_bufnr)
					local ref = Reference:from_string(selection.value)
					vim.api.nvim_put({ ref:ref() }, "l", true, false)
				end)
				-- CTRL+R prints the reference only
				map("i", "<C-r>", function()
					local selection = require("telescope.actions.state").get_selected_entry()
					require("telescope.actions").close(prompt_bufnr)
					local ref = Reference:from_string(selection.value)
					vim.api.nvim_put({ ref:ref() }, "l", true, false)
				end)
				-- CTRL+W prints whole chapter
				map("i", "<C-w>", function()
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
				-- CTRL+U prints until next selected verse
				map("i", "<C-u>", function()
					local selection = require("telescope.actions.state").get_selected_entry()
					require("telescope.actions").close(prompt_bufnr)
					local ref = Reference:from_string(selection.value)
					-- require("telescope").extensions.bible.bible_ref_after({ value = ref:ref() })
					if ref:ref() == selection.value then
						require("telescope").extensions.bible.bible_ref_after({ value = ref:ref() })
					else
						require("telescope").extensions.bible.bible_after({ value = ref:ref() })
					end
				end)
				return true
			end,
		})
		:find()
end

return versePicker
