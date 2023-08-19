local sqlite3 = require("lsqlite3")
local db = sqlite3.open("/home/dglinuxtemple/ESV.sqlite")

local json = require("dkjson")

local file = io.open("./references.json", "r")
local json_string = file:read("*a")
file:close()
local referenceTable = json.decode(json_string)

file = io.open("./books.json", "r")
json_string = file:read("*a")
file:close()
local bookList = json.decode(json_string)

local Reference = {}

function Reference:new(bk, ch, v)
	local instance = {}
	setmetatable(instance, { __index = Reference, __tostring = Reference.__tostring, __concat = Reference.__concat })
	instance.bk = bk
	instance.ch = ch
	instance.v = v
	instance.isValid = instance:checkValidity()
	instance.content = instance:get()
	return instance
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

	local lastChapter = #referenceTable[prevBook]
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

function Reference:print()
	return self.content .. " [" .. self:ref() .. "]"
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
