local previewers = require("telescope.previewers")
local Reference = require("telescope._extensions.bible.reference")

local ns_id = vim.api.nvim_create_namespace("Highlights")

local create_highlight_group = function(name, color)
	local highlightAttributes = {
			guifg = color, -- Set foreground color
			guibg = "NONE",  -- Set background color
			gui = "NONE",    -- Reset additional attributes
	}
	local attributesString = ""
	for key, value in pairs(highlightAttributes) do
			attributesString = attributesString .. key .. "=" .. value .. " "
	end
	local highlightGroupCommand = string.format("highlight %s %s", name, attributesString)
	vim.api.nvim_command(highlightGroupCommand)
end

create_highlight_group("Bible.Keybind", "#c488ec")
create_highlight_group("Bible.VerseNumber", "#f26e74")
create_highlight_group("Bible.Translation", "#82c29c")
create_highlight_group("Bible.True", "#82c29c")
create_highlight_group("Bible.False", "#f26e74")
create_highlight_group("Bible.Delimeters", "#79aaeb")
create_highlight_group("Bible.FocusedVerse", "#edc28b")


-- https://claude.ai/chat/5cb33a52-9e17-4e37-b686-7b373283ab76
local highlight_text = function(bufnr, hl_group, pattern)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

	for i, line in ipairs(lines) do
		for match in line:gmatch(pattern) do
			local row, col = line:find(match, 1, true)
			if row then
				vim.api.nvim_buf_add_highlight(bufnr, ns_id, hl_group, i - 1, row - 1, col)
			end
		end
	end
end

local highlight_lines = function(bufnr, hl_group, startLine, endLine)
	for line = startLine, endLine do
		local row = line - 1
		vim.api.nvim_buf_add_highlight(bufnr, ns_id, hl_group, row, 0, -1)
	end
end

createBiblePreviewer = function(opts)
	local title = "Scripture"
	if opts.value then
		title = opts.value .. " - "
	end
	return previewers.new_buffer_previewer({
		title = title,
		define_preview = function(self, entry, status)
			local ref
			if entry.value:match("%[") then
				local pattern = "%[(%d? ?[%a%s]+) (%d+):(%d+)%]"
				local book, chapter, verse = entry.value:match(pattern)
				ref = Reference:new(book, chapter, verse)
			else
				ref = Reference:from_string(entry.value)
			end
			local lines = {}
			if vim.g.showBibleSettings then
				-- make true bg green and false bg red
				-- add color to == and to values
				-- set color of [ch:v]
				lines = {
					"==============================================================================",
					"[Alt+T] Translation Used = English Standard Version (ESV)",
					"[Alt+R] Insert Reference = " .. tostring(vim.g.insertReference),
					"[Alt+C] Insert Content   = " .. tostring(vim.g.insertContent),
					"[Alt+I] Add Indentation  = " .. tostring(vim.g.addIndent),
					"==============================================================================",
				}
			end
			local cur = ref
			local context = 4
			local width = 68 -- todo: fix to make this dynamic
			local startLine
			local endLine
			for _ = 1, context do
				local tmp = cur:prev()
				if tmp == nil then
					break
				end
				cur = tmp
			end
			for _ = 1, context * 2 + 1 do
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

			-- create_highlight_group("Bible.Keybind", "#c488ec")
			-- create_highlight_group("Bible.VerseNumber", "#f26e74")
			-- create_highlight_group("Bible.Translation", "#82c29c")
			-- create_highlight_group("Bible.True", "#82c29c")
			-- create_highlight_group("Bible.False", "#f26e74")
			-- create_highlight_group("Bible.Delimeters", "#79aaeb")
			-- create_highlight_group("Bible.FocusedVerse", "#edc28b")

			highlight_text(self.state.bufnr, "Bible.Keybind", "%[Alt%+%a%]") -- [Alt+?]
			highlight_text(self.state.bufnr, "Bible.VerseNumber", "%[%d+:%d+%]") -- [1:1]
			highlight_text(self.state.bufnr, "Bible.Translation", "Translation Used = (.+)") -- = Translation (ABRV)
			highlight_text(self.state.bufnr, "Bible.True", "= (true)") -- = true
			highlight_text(self.state.bufnr, "Bible.False", "= (false)") -- = false
			highlight_text(self.state.bufnr, "Bible.Delimeters", "=+") -- ======
			highlight_lines(self.state.bufnr, "Bible.FocusedVerse", startLine, endLine) -- verse text

		end,
	})
end

return createBiblePreviewer
