-- temp fix for MTA Issue 6846: getVehicleType with trailers returns empty string client-side
local vt = getVehicleType
function getVehicleType( ... )
	local ret = vt( ... )
	if ret == "" then
		return "Trailer"
	end
	return ret
end
