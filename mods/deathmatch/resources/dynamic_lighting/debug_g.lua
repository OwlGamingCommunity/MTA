ods = outputDebugString
function outputDebugString(str)
	if getElementData(resourceRoot, "debug_enabled") then
		str = tostring(str)
		ods(str)
	end
end