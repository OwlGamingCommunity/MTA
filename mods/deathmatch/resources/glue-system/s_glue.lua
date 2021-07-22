
function gluePlayer(slot, vehicle, x, y, z, rotX, rotY, rotZ)
	attachElements(client, vehicle, x, y, z, rotX, rotY, rotZ)
	setElementRotation(client, rotX, rotY, rotZ)
	setPedWeaponSlot(client, slot)
end
addEvent("gluePlayer",true)
addEventHandler("gluePlayer",getRootElement(),gluePlayer)

function ungluePlayer()
	--outputDebugString('s_glue / ungluePlayer / ' .. getPlayerName(client))
	detachElements(client)
end
addEvent("ungluePlayer",true)
addEventHandler("ungluePlayer",getRootElement(),ungluePlayer)

function glueVehicle(attachedTo, x, y, z, rotX, rotY, rotZ)
	local playerX, playerY, playerZ = getElementPosition(client)
	local vehicleX, vehicleY, vehicleZ = getElementPosition(source)
	if getDistanceBetweenPoints3D(playerX, playerY, playerZ, vehicleX, vehicleY, vehicleZ) > 20 then
		return
	end

	if getElementModel(attachedTo) == 525 or isElementAttached(attachedTo) then
		return false
	end
	attachElements(source, attachedTo, x, y, z, rotX, rotY, rotZ)
	setElementCollisionsEnabled(source, false)
end
addEvent("glueVehicle",true)
addEventHandler("glueVehicle",getRootElement(),glueVehicle)

function unglueVehicle()
	setElementCollisionsEnabled(source, true)
	setElementFrozen(source, true)
	local x, y, z = getElementPosition(source)
	detachElements(source)
	setElementPosition(source, x, y, z+0.1)
	setTimer(setElementFrozen, 1000, 1, source, false)
end
addEvent("unglueVehicle",true)
addEventHandler("unglueVehicle",getRootElement(),unglueVehicle)

function getNearby(e)
	local t = {}
	local x, y, z = getElementPosition(e)
	for k, v in ipairs(getElementsByType"player") do
		local dist = getDistanceBetweenPoints3D(x, y, z, getElementPosition(v))
		if dist < 100 then
			table.insert(t, getPlayerName(v) .. ' ' .. math.floor(dist))
		end
	end
	return table.concat(t, ', ')
end

addEventHandler("onTrailerAttach", root,
	function(truck)
		outputDebugString('s_glue / onTrailerAttach / ' .. getElementData(source, "dbid") .. ' to ' .. getElementData(truck, "dbid"))
		outputDebugString('s_glue / nearby: ' .. getNearby(source))


		--Make trailers damage proof
		if getElementModel(source) == 611 then
			setVehicleDamageProof(source, true)
			outputDebugString("WAKKA WAKKA")
		end
	end)

addEventHandler("onTrailerDetach", root,
	function(truck)
		outputDebugString('s_glue / onTrailerDetach / ' .. getElementData(source, "dbid") .. ' to ' .. getElementData(truck, "dbid"))
		outputDebugString('s_glue / nearby: ' .. getNearby(source))
	end)

--If it respawns, set it back to collisions enabled so shit doesn't bug
addEventHandler("onVehicleRespawn", root, function(exploded)
	if getElementType(source) == "vehicle" then
		setElementCollisionsEnabled(source, true)
	end
end)
