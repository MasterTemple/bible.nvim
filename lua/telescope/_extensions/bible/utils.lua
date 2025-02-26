local utils = {}

function utils:indexOf(array, value)
	for i, v in ipairs(array) do
		if v == value then
			return i
		end
	end
	return nil
end

function utils:padleft(num, len)
	local str = tostring(num)
	while #str < len do
		str = "0" .. str
	end
	return str
end

return utils
