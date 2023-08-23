local sqlite3 = require("lsqlite3")
local config = require("telescope._extensions.bible.config")
local db = sqlite3.open(config.code_dir .. "db/ESV.sqlite")

local json = require("dkjson")

local file = io.open(config.code_dir .. "references.json", "r")
local json_string = file:read("*a")
file:close()
local referenceTable = json.decode(json_string)

file = io.open(config.code_dir .. "books.json", "r")
json_string = file:read("*a")
file:close()
local bookList = json.decode(json_string)

local Reference = {}

function Reference:new(bk, ch, v)
	local instance = {}
	setmetatable(instance, { __index = Reference, __tostring = Reference.__tostring, __concat = Reference.__concat })
	instance.bk = bk
	instance.ch = tonumber(ch)
	instance.v = tonumber(v)
	instance.isValid = instance:checkValidity()
	instance.content = instance:get()
	return instance
end

function Reference:from_string(str)
	-- this is a simple match for a verse, it wont work for a lot of use cases
	local pattern = "(%d? ?[%a%s]+) (%d+):(%d+)"
  local book, chapter, verse = str:match(pattern)
  if book and chapter and verse then
    return Reference:new(book, tonumber(chapter), tonumber(verse))
  end
end

function Reference:get()
	if not self.isValid then
		return ""
	end
	local content = ""
	for row in
		db:nrows(
			"SELECT content, chapter, verse FROM '"
				.. self.bk
				.. "' WHERE chapter="
				.. self.ch
				.. " AND verse="
				.. self.v
				.. " ORDER BY chapter, verse LIMIT 1"
		)
	do
		content = row.content
	end
	return content
end

function Reference:next()
	-- increase verse
	local ref = Reference:new(self.bk, self.ch, self.v + 1)
	if ref.isValid then
		return ref
	end
	-- or increase ch
	ref = Reference:new(self.bk, self.ch + 1, 1)
	if ref.isValid then
		return ref
	end
	-- or increase book
	local nextBook = ""
	for i, book in ipairs(bookList) do
		if book == self.bk then
			nextBook = bookList[i + 1]
			break
		end
	end
	ref = Reference:new(nextBook, 1, 1)
	if ref.isValid then
		return ref
	end
	return nil
end

function Reference:prev()
	-- decrease verse
	local ref = Reference:new(self.bk, self.ch, self.v - 1)
	if ref.isValid then
		return ref
	end
	-- or decrease ch
	local lastVerse = referenceTable[self.bk][self.ch - 1]
	ref = Reference:new(self.bk, self.ch - 1, lastVerse)
	if ref.isValid then
		return ref
	end
	-- or decrease book
	local prevBook = ""
	for i, book in ipairs(bookList) do
		if book == self.bk then
			prevBook = bookList[i - 1]
			break
		end
	end
	if prevBook == nil then
		return nil
	end
	local lastChapter = #(referenceTable[prevBook])
	lastVerse = referenceTable[prevBook][lastChapter]
	ref = Reference:new(prevBook, lastChapter, lastVerse)
	if ref.isValid then
		return ref
	end
	return nil
end

function Reference:chapter()
	local cur = Reference:new(self.bk, self.ch, 1)
	local refs = {}
	while self.ch == cur.ch do
		table.insert(refs, cur)
		cur = cur:next()
	end
	return refs
end

function Reference:checkValidity()
	-- book is invalid
	local chapterList = referenceTable[self.bk]
	if not chapterList then
		return false
	end
	-- chapter is invalid
	if not (1 <= self.ch and self.ch <= #chapterList) then
		return false
	end
	-- verse is invalid
	local verseCount = chapterList[self.ch]
	if not (1 <= self.v and self.v <= verseCount) then
		return false
	end

	return true
end

function Reference:ref()
	return self.bk .. " " .. self.ch .. ":" .. self.v
end

function Reference:chRef()
	return self.bk .. " " .. self.ch
end

function Reference:inlinePrint()
	-- return self.content .. " [" .. self:ref() .. "]"
	return "["  .. self.ch .. ":" .. self.v .. "] " .. self.content 
end

function Reference:print()
	-- return self.content .. " [" .. self:ref() .. "]"
	return "[" .. self:ref() .. "] " .. self.content 
end

function Reference:verseLine()
	return  " [" .. self.ch .. ":" .. self.v .. "] " .. self.content:gsub("\n", " ")
	-- return  " [" .. self.v .. "] " .. self.content:gsub("\n", " ")
end

function Reference:__tostring()
	return self.bk .. " " .. self.ch .. ":" .. self.v
end

function Reference:__concat(other)
	return self:__tostring() .. other
end

return Reference
-- local ref = Reference:new("1 John", 1, 1)
-- local nref = ref:next()
-- local pref = ref:prev()
-- print(ref)
-- print("[" .. ref .. "]")
-- print(pref:ref())
-- print(ref:ref())
-- print(nref:ref())
-- local x = ref:chapter()
-- print(x)
-- for i,v in ipairs(x) do
-- 	print(v:fmt())
-- end
-- local ref = Reference:from_string("song of songs 1:1")
-- print(ref)
-- print(ref.bk)
-- print(ref.ch)
-- print(ref.v)
