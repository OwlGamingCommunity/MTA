function getHotlines()
	return getElementData(resourceRoot, "hotlines:names") or {}
end

function getHotlineName(number)
	for _, v in ipairs(getHotlines()) do
		if v[2] == tonumber(number) then
			return v[1]
		end
	end
end

function isNumberAHotline(number)
	return getHotlineName(number) ~= nil
end
