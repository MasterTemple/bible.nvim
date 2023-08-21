local pickers = require'telescope.pickers'
local finders = require'telescope.finders'
local conf = require'telescope.config'.values
local bible_previewer = require('telescope._extensions.bible.previewer')
local Reference = require('telescope._extensions.bible.reference')

local versePicker = function(opts, results)
  pickers.new(opts, {
    prompt_title = "Select Verse",
    finder = finders.new_table {
      results = results,
      entry_maker = function(entry)
        return {
          value = entry,
          ordinal = entry,
          display = entry,
        }
      end,
    },
    sorter = conf.generic_sorter(opts),
		previewer = bible_previewer,
		attach_mappings = function(prompt_bufnr, map)
			-- tab prints the content and the reference
			map('i', '<CR>', function()
				local selection = require('telescope.actions.state').get_selected_entry()
				require('telescope.actions').close(prompt_bufnr)
				local ref = Reference:from_string(selection.value)
				vim.api.nvim_put({ref.content, ref:ref()}, 'l', true, false)
			end)
			-- tab prints the reference only
			map('i', '<tab>', function()
				local selection = require('telescope.actions.state').get_selected_entry()
				require('telescope.actions').close(prompt_bufnr)
				local ref = Reference:from_string(selection.value)
				vim.api.nvim_put({ref:ref()}, 'l', true, false)
			end)

			return true
		end,
  }):find()
end

return versePicker
