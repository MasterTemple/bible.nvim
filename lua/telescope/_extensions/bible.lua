local entry_display = require("telescope.pickers.entry_display")
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local conf = require("telescope.config").values
-- local reference = require("reference")

local function prepare_results()
    local next = {}
    for idx = 1, 20 do
        -- if list[idx].filename ~= "" then
        --     list[idx].index = idx
        --     table.insert(next, list[idx])
        -- end
				table.insert(next, idx)
    end

    return next
end

local generate_new_finder = function()
    return finders.new_table({
        results = prepare_results()
    })
end

return function(opts)
    opts = opts or {}

    pickers.new(opts, {
        prompt_title = "bible",
        finder = generate_new_finder(),
        sorter = conf.generic_sorter(opts),
        previewer = conf.grep_previewer(opts)
    }):find()
end
