--MAXIME / 2015.1.26

function isResourceRunning(resName)
	local res = getResourceFromName(resName)
	if res then
		return getResourceState(res) == "running" and getResourceRootElement( res )
	end
	return false
end