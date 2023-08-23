local Reference = require("telescope._extensions.bible.reference")
local config = require("telescope._extensions.bible.config")
local json = require("dkjson")

local file = io.open(config.code_dir .. "references.json", "r")
local json_string = file:read("*a")
file:close()

local referenceTable = json.decode(json_string)

file = io.open(config.code_dir .. "books.json", "r")
json_string = file:read("*a")
file:close()

local bookList = json.decode(json_string)

local getAllVersesFromSqlite = function()
	local verseList = {}
	for _, bookName in ipairs(bookList) do
		local chapterList = referenceTable[bookName]
		for chapter, verseCount in ipairs(chapterList) do
			for verse = 1, verseCount do
				local ref = Reference:new(bookName, chapter, verse)
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

M.getAllVerses = function(self)
	local file_path = config.cache_dir .. "bible.txt"
	local exists = os.rename(config.cache_dir, config.cache_dir)
	if not exists then
		os.execute("mkdir -p " .. config.cache_dir)
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
		local lines = getAllVersesFromSqlite()
		local oFile = io.open(file_path, "w")

		for _, line in ipairs(lines) do
			oFile:write(line .. "\n")
		end

		oFile:close()
		return lines
	end
end

M.getAllReferencesAfter = function(self, cur)
	local master = Reference:from_string(cur)
	local refs = self.getAllReferences()
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

M.getAllVersesAfter = function(self, cur)
	local master = Reference:from_string(cur)
	local refs = self.getAllVerses()
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
