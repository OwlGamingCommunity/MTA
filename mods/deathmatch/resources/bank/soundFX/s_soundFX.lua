function playAtmInsert(theAtm)
	local affectedPlayers = { }
	local x, y, z = getElementPosition(theAtm)
	
	for index, nearbyPlayer in ipairs(getElementsByType("player")) do
		if isElement(nearbyPlayer) and getDistanceBetweenPoints3D(x, y, z, getElementPosition(nearbyPlayer)) < 10 then
			local logged = getElementData(nearbyPlayer, "loggedin")
			if logged==1 and getElementDimension(theAtm) == getElementDimension(nearbyPlayer) then
				triggerClientEvent(nearbyPlayer, "bank:playAtmInsert", theAtm)
				table.insert(affectedPlayers, nearbyPlayer)
			end
		end
	end
	return true, affectedPlayers
end

function playAtmEject(theAtm)
	local affectedPlayers = { }
	local x, y, z = getElementPosition(theAtm)
	
	for index, nearbyPlayer in ipairs(getElementsByType("player")) do
		if isElement(nearbyPlayer) and getDistanceBetweenPoints3D(x, y, z, getElementPosition(nearbyPlayer)) < 10 then
			local logged = getElementData(nearbyPlayer, "loggedin")
			if logged==1 and getElementDimension(theAtm) == getElementDimension(nearbyPlayer) then
				triggerClientEvent(nearbyPlayer, "bank:playAtmEject", theAtm)
				table.insert(affectedPlayers, nearbyPlayer)
			end
		end
	end
	return true, affectedPlayers
end

function playAtmWithdraw(theAtm)
	local affectedPlayers = { }
	local x, y, z = getElementPosition(theAtm)
	
	for index, nearbyPlayer in ipairs(getElementsByType("player")) do
		if isElement(nearbyPlayer) and getDistanceBetweenPoints3D(x, y, z, getElementPosition(nearbyPlayer)) < 10 then
			local logged = getElementData(nearbyPlayer, "loggedin")
			if logged==1 and getElementDimension(theAtm) == getElementDimension(nearbyPlayer) then
				triggerClientEvent(nearbyPlayer, "bank:playAtmWithdraw", theAtm)
				table.insert(affectedPlayers, nearbyPlayer)
			end
		end
	end
	return true, affectedPlayers
end

function playAtmError(theAtm)
	local affectedPlayers = { }
	local x, y, z = getElementPosition(theAtm)
	
	for index, nearbyPlayer in ipairs(getElementsByType("player")) do
		if isElement(nearbyPlayer) and getDistanceBetweenPoints3D(x, y, z, getElementPosition(nearbyPlayer)) < 10 then
			local logged = getElementData(nearbyPlayer, "loggedin")
			if logged==1 and getElementDimension(theAtm) == getElementDimension(nearbyPlayer) then
				triggerClientEvent(nearbyPlayer, "bank:playAtmError", theAtm)
				table.insert(affectedPlayers, nearbyPlayer)
			end
		end
	end
	return true, affectedPlayers
end
