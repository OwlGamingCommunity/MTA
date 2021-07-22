function canAccessEarlyZone(theVehicle, thePlayer)
	if theVehicle and getElementData(theVehicle, "lspd:siren") then
		return true
	end
	
	local hasPerk, pValue = exports.donators:hasPlayerPerk(thePlayer, 27)
	return hasPerk and tonumber(pValue) == 1
end