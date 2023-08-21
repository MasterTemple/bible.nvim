local previewers = require('telescope.previewers')
local Reference = require('telescope._extensions.bible.reference')

local ns_id = vim.api.nvim_create_namespace("Highlights")

local highlight_lines = function(bufnr, hl_group, startLine, endLine)
  vim.api.nvim_buf_clear_namespace(bufnr, ns_id, 0, -1) 
	for line=startLine,endLine do
		local row = line - 1 
		vim.api.nvim_buf_add_highlight(bufnr, ns_id, hl_group, row, 0, -1) 
	end
end

local bible_previewer = previewers.new_buffer_previewer {
	title = "Scripture",
	define_preview = function(self, entry, status)
		local ref
		if entry.value:match("%[") then
			local pattern = "%[(%d? ?[%a%s]+) (%d+):(%d+)%]"
			local book, chapter, verse = entry.value:match(pattern)
			-- print(book, chapter, verse)
			ref = Reference:new(book, chapter, verse)
			-- print(ref:ref())
		else
			ref = Reference:from_string(entry.value)
		end
		-- ref = Reference:from_string(entry.value)
		local lines = {}
		local cur = ref
		local context = 4
		local width = 68 -- fix to make this dynamic
		local startLine
		local endLine
		-- print(cur)
		for i=1,context do
			local tmp = cur:prev()
			if tmp == nil then
				break
			end
			cur = tmp
		end
		for i=1,context*2+1 do
			if cur.bk == ref.bk then
				local line = cur:verseLine()
				if cur.ch == ref.ch and cur.v == ref.v then
					startLine = #lines + 1
				end
				while #line > width do
					local breakpoint = width
					local split_idx = line:sub(1, breakpoint):find("%s+$")
					if split_idx then
						breakpoint = split_idx 
					end

					table.insert(lines, line:sub(1, breakpoint))
					line = line:sub(breakpoint + 1)
				end
				table.insert(lines, line)
				if cur.ch == ref.ch and cur.v == ref.v then
					endLine = #lines
				end
			end
			cur = cur:next()
		end
		vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
    highlight_lines(self.state.bufnr, "Search", startLine, endLine)

	end
}
return bible_previewer
