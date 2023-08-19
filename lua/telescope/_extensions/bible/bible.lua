local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
local actions = require("telescope.actions")

local M = {}

M.search_test_file = function()

  local lines = {}
  for line in io.lines("~/test.txt") do 
    table.insert(lines, line)
  end

  pickers.new(opts, {
    prompt_title = "Search Test File",
    finder    = finders.new_table({
      results = lines,
      entry_maker = function(entry)
        return {
          value = entry,
          display = entry,
          ordinal = entry,
        }
      end
    }),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        print("Selected: " .. selection.value)
      end)
      return true
    end
  }):find()

end

return M
