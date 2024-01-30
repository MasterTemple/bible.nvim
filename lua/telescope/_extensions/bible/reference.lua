local config = require("telescope._extensions.bible.config")

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
local bibles = {}

local files = vim.fn.glob(config.code_dir .. "json/t_*.json", false, true)
for i, v in ipairs(files) do
	local translation = v:match("t_(.+).json")
	local f = io.open(v, "r")
	if f == nil then
		vim.api.nvim_echo({ { "Bible.nvim: T_" .. translation .. " file not found" } }, false, {})
	else
		json_string = f:read("*a")
		f:close()
		bibles[translation] = vim.fn.json_decode(json_string)
	end
end

local Reference = {}

local function indexOf(array, value)
	for i, v in ipairs(array) do
		if v == value then
			return i
		end
	end
	return nil
end

function Reference:new(bk, ch, v, translation)
	local instance = {}
	setmetatable(instance, { __index = Reference, __tostring = Reference.__tostring, __concat = Reference.__concat })
	instance.bk = bk
	instance.ch = tonumber(ch)
	instance.v = tonumber(v)
	instance.translation = translation
	instance.isValid = instance:checkValidity()
	instance.content = instance:get()
	return instance
end

function Reference:from_string(str, translation)
	-- this is a simple match for a verse, it wont work for a lot of use cases
	local pattern = "(%d? ?[%a%s]+) (%d+):(%d+)"
	local book, chapter, verse = str:match(pattern)
	if book and chapter and verse then
		return Reference:new(book, tonumber(chapter), tonumber(verse), translation)
	end
end

local function padleft(num, len)
	local str = tostring(num)
	while #str < len do
		str = "0" .. str
	end
	return str
end

local function bibleBinarySearch(arr, val)
	local low = 1
	local high = #arr
	while low <= high do
		local mid = math.floor((low + high) / 2)
		if tonumber(arr[mid].field[1]) == val then
			return mid
		elseif tonumber(arr[mid].field[1]) < val then
			low = mid + 1
		else
			high = mid - 1
		end
	end
	return nil
end

function Reference:get()
	if not self.isValid then
		return ""
	end
	local content = ""
	local id = self:id()
	print('DEBUGPRINT[2]: reference.lua:97: id=' .. vim.inspect(id))
	print('DEBUGPRINT[4]: reference.lua:105: translation=' .. vim.inspect(self.translation))
	local verseIndex = bibleBinarySearch(bibles[self.translation].resultset.row, tonumber(id))
	print('DEBUGPRINT[3]: reference.lua:99: verseIndex=' .. vim.inspect(verseIndex))
	if verseIndex == nil then
		return ""
	end
	if bibles[self.translation] == nil then
		return ""
	end
	content = bibles[self.translation].resultset.row[verseIndex].field[5]
	print('DEBUGPRINT[4]: reference.lua:107: content=' .. vim.inspect(content))
	if content == nil then
		return ""
	end
	return content
end

function Reference:next()
	-- increase verse
	local ref = Reference:new(self.bk, self.ch, self.v + 1, self.translation)
	if ref.isValid then
		return ref
	end
	-- or increase ch
	ref = Reference:new(self.bk, self.ch + 1, 1, self.translation)
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
	ref = Reference:new(nextBook, 1, 1, self.translation)
	if ref.isValid then
		return ref
	end
	return nil
end

function Reference:prev()
	-- decrease verse
	local ref = Reference:new(self.bk, self.ch, self.v - 1, self.translation)
	if ref.isValid then
		return ref
	end
	-- or decrease ch
	local lastVerse = referenceTable[self.bk][self.ch - 1]
	ref = Reference:new(self.bk, self.ch - 1, lastVerse, self.translation)
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
	ref = Reference:new(prevBook, lastChapter, lastVerse, self.translation)
	if ref.isValid then
		return ref
	end
	return nil
end

function Reference:chapter()
	local cur = Reference:new(self.bk, self.ch, 1, self.translation)
	local refs = {}
	while self.ch == cur.ch do
		table.insert(refs, cur)
		cur = cur:next()
	end
	return refs
end

function Reference:checkValidity()
	-- book is invalid
	vim.api.nvim_echo({ { self.bk } }, false, {})
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
	return "[" .. self.ch .. ":" .. self.v .. "] " .. "(" .. string.upper(self.translation) .. ") " .. self.content
end

function Reference:print()
	-- return self.content .. " [" .. self:ref() .. "]"
	return "[" .. self:ref() .. "] " .. "(" .. string.upper(self.translation) .. ") " .. self.content
end

function Reference:verseLine()
	return " [" .. self.ch .. ":" .. self.v .. "] " .. "(" .. string.upper(self.translation) .. ") " .. self.content:gsub("\n", " ")
	-- return  " [" .. self.v .. "] " .. self.content:gsub("\n", " ")
end

function Reference:__tostring()
	return self.bk .. " " .. self.ch .. ":" .. self.v
end

function Reference:id()
	return indexOf(bookList, self.bk) .. padleft(self.ch, 3) .. padleft(self.v, 3)
end

function Reference:__concat(other)
	return self:__tostring() .. other
end

return Reference
-- local ref = Reference:new("1 John", 1, 1, "kjv")
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
