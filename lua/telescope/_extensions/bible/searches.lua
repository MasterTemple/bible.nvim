local Reference = require('telescope._extensions.bible.reference')

getAllVersesFromSqlite = function()
	local file = io.open("/home/dglinuxtemple/references.json", "r") -- fix path issue
	local json = require("dkjson")
	local json_string = file:read("*a")
	file:close()
	local referenceTable = json.decode(json_string)
	local verseList = {}
	for bookName, chapterList in pairs(referenceTable) do
		for chapter, verseCount in ipairs(chapterList) do
			for verse=1,verseCount do
				local ref = Reference:new(bookName, chapter, verse)
				local line = ref:print()
				line = line:gsub("%s+", " ")
				table.insert(verseList, line)
			end
		end
	end
	return verseList
end

return {
	getAllReferences = function()
		local file = io.open("/home/dglinuxtemple/references.json", "r") -- fix path issue
		local json = require("dkjson")
		local json_string = file:read("*a")
		file:close()
		local referenceTable = json.decode(json_string)
		local referencesList = {}
		for bookName, chapterList in pairs(referenceTable) do
			for chapter, verseCount in ipairs(chapterList) do
				for verse=1,verseCount do
					table.insert(referencesList, bookName .. " " .. chapter .. ":" .. verse)
				end
			end
		end
		return referencesList
	end,
	getAllVerses = function()
		local file = io.open("/home/dglinuxtemple/bible.txt", "r")
		if file then
			local lines = {}
			for line in file:lines() do
				table.insert(lines, line)
			end
			io.close(file)
			return lines
		else
			local lines = getAllVersesFromSqlite()
			local oFile = io.open("/home/dglinuxtemple/bible.txt", "w")

			for i, line in ipairs(lines) do
				oFile:write(line .. "\n")
			end

			oFile:close()
			return lines
		end
	end
}
