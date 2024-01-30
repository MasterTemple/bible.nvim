local Reference = require("telescope._extensions.bible.reference")
local config = require("telescope._extensions.bible.config")
local json = vim.fn.json_decode

local json_string

local file = io.open(config.code_dir .. "references.json", "r")
if file == nil then
	vim.api.nvim_echo({ { "Bible.nvim: References file not found" } }, false, {})
else
	json_string = file:read("*a")
	file:close()
end

local referenceTable = vim.fn.json_decode(json_string)

file = io.open(config.code_dir .. "books.json", "r")
if file == nil then
	vim.api.nvim_echo({ { "Bible.nvim: Books file not found" } }, false, {})
else
	json_string = file:read("*a")
	file:close()
end
local bookList = vim.fn.json_decode(json_string)

if referenceTable == nil then
	vim.api.nvim_echo({ { "Bible.nvim: References table not found" } }, false, {})
	return
end
if bookList == nil then
	vim.api.nvim_echo({ { "Bible.nvim: Books table not found" } }, false, {})
	return
end


local getAllVersesFromSqlite = function(translation)
	local verseList = {}
	for _, bookName in ipairs(bookList) do
		local chapterList = referenceTable[bookName]
		for chapter, verseCount in ipairs(chapterList) do
			for verse = 1, verseCount do
				local ref = Reference:new(bookName, chapter, verse, translation)
				local line = ref:print()
				line = line:gsub("%s+", " ")
				table.insert(verseList, line)
			end
		end
	end
	return verseList
end

local M = {}

M.getAllReferences = function(self)
	local referencesList = {}
	for _, bookName in ipairs(bookList) do
		local chapterList = referenceTable[bookName]
		for chapter, verseCount in ipairs(chapterList) do
			for verse = 1, verseCount do
				table.insert(referencesList, bookName .. " " .. chapter .. ":" .. verse)
			end
		end
	end
	return referencesList
end

M.getAllVerses = function(self, translation)
	local file_path = config.cache_dir .. translation ..	 "-bible.txt"
	local exists = os.rename(config.cache_dir, config.cache_dir)
	if not exists then
		os.execute("mkdir " .. config.cache_dir)
	end

	local iFile = io.open(file_path, "r")
	if iFile then
		local lines = {}
		for line in iFile:lines() do
			table.insert(lines, line)
		end
		iFile:close()
		return lines
	else
		local lines = getAllVersesFromSqlite(translation)
		local oFile = io.open(file_path, "w")

		for _, line in ipairs(lines) do
			oFile:write(line .. "\n")
		end

		oFile:close()
		return lines
	end
end

M.getAllReferencesAfter = function(self, cur, translation)
	local master = Reference:from_string(cur)
	local refs = self.getAllReferences(translation)
	local followingRefs = {}
	local isPastRef = false
	for _, r in ipairs(refs) do
		if isPastRef then
			local this = Reference:from_string(r)
			if master.bk ~= this.bk then
				break
			end
			table.insert(followingRefs, r)
		end
		if cur == r then
			isPastRef = true
		end
	end
	return followingRefs
end

M.getAllVersesAfter = function(self, cur, translation)
	local master = Reference:from_string(cur)
	local refs = self.getAllVerses(translation)
	local followingRefs = {}
	local isPastRef = false
	for _, r in ipairs(refs) do
		if isPastRef then
			local this = Reference:from_string(r)
			if master.bk ~= this.bk then
				break
			end
			table.insert(followingRefs, r)
		end
		local pattern = "((%d? ?[%a%s]+) (%d+):(%d+))"
		local thisRef = r:match(pattern)
		if cur == thisRef then
			isPastRef = true
		end
	end
	return followingRefs
end

return M
