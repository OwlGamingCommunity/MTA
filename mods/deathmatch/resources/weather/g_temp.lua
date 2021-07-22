function getSnowLevel(element)
	local snowRes = getResourceFromName("shader_snow_ground")
	if snowRes and getResourceState(snowRes) == "running" then
		return 2
	else
		return 0
	end
end