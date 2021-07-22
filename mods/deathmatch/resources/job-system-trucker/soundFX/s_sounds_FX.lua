function playSoundFX(theTruck)
	local distance = 100
	local affectedPlayers = { }
	local x, y, z = getElementPosition(theTruck)
	for index, nearbyPlayer in ipairs(getElementsByType("player")) do
		if getElementData(nearbyPlayer, "loggedin")==1 and getElementDimension(theTruck) == getElementDimension(nearbyPlayer) and getElementInterior(theTruck) == getElementInterior(nearbyPlayer) and getDistanceBetweenPoints3D(x, y, z, getElementPosition(nearbyPlayer)) < distance then
			triggerClientEvent(nearbyPlayer, "truckerjob:playSoundFX", theTruck, distance)
			table.insert(affectedPlayers, nearbyPlayer)
		end
	end
	return true, affectedPlayers
end