function applyAnimation(thePlayer, block, name, animtime, loop, updatePosition)
	if client then thePlayer = client end
	if thePlayer and block and name then
		exports.global:applyAnimation(client, block, name, animtime, loop, updatePosition, true, false)
	end
end
addEvent("activities:surf:applyAnimation", true)
addEventHandler("activities:surf:applyAnimation", resourceRoot, applyAnimation, false)

function stopAnimation(thePlayer)
	if client then thePlayer = client end
	if thePlayer then
		exports.global:removeAnimation(client, false)
	end
end
addEvent("activities:surf:stopAnimation", true)
addEventHandler("activities:surf:stopAnimation", resourceRoot, stopAnimation, false)

local surfboards = {}

function launchSurfboard(thePlayer)
	triggerEvent("artifacts:remove", thePlayer, thePlayer, "surfboard")
	local x,y,z = getElementPosition(thePlayer)
	
	--local vehicle = createVehicle(473, x, y+3, z)
	--local surfboard = createObject(2406, x, y+3, z, 0, 0, 0)
	--exports.anticheat:setEld(vehicle, "specialpurpose", "surfboard", "all")
	--attachElements(surfboard, vehicle, 0, 0, 0.5, -90, 0, 0)
	--setElementAlpha(vehicle, 0)
	--setElementParent(surfboard, vehicle)
	--surfboards[thePlayer] = {vehicle, surfboard}
	--setVehicleLocked(vehicle, false)
	--warpPedIntoVehicle(thePlayer, vehicle)
	--setVehicleLocked(vehicle, true)
	--attachElements(thePlayer, vehicle, 0, 0, 1.5, 0, 0, 0)
	--setElementFrozen(vehicle, false)

	local physics = createObject(1598, x, y+3, z+5)
	local surfboard = createObject(2406, x, y+3, z, 0, 0, 0)
	attachElements(surfboard, physics, 0, 0, 0, -90, 0, 0)
	setElementAlpha(physics, 0)
	setElementParent(surfboard, physics)
	surfboards[thePlayer] = {physics, surfboard}
	attachElements(thePlayer, physics, 0, 0, 1, 0, 0, 0)
	setElementFrozen(physics, false)


	applyAnimation(thePlayer, "bikeleap", "bk_blnce_in", -1, true, false)
	triggerClientEvent("activities:surf:start", thePlayer, physics)
end

function unlaunchSurfboard(thePlayer)
	local data = surfboards[thePlayer]
	if data then
		--[[
		local vehicle = data[1]
		local surfboard = data[2]
		detachElements(thePlayer, surfboard)
		destroyElement(surfboard)
		destroyElement(vehicle)
		surfboards[thePlayer] = nil
		triggerEvent("artifacts:add", thePlayer, thePlayer, "surfboard")
		--]]

		triggerClientEvent("activities:surf:stop", thePlayer)

		local physics = data[1]
		local surfboard = data[2]
		detachElements(thePlayer, physics)
		destroyElement(surfboard)
		destroyElement(physics)
		surfboards[thePlayer] = nil
		triggerEvent("artifacts:add", thePlayer, thePlayer, "surfboard")

	end
end
addEvent("activities:surf:unlaunchSurfboard", true)
addEventHandler("activities:surf:unlaunchSurfboard", root, unlaunchSurfboard, false)

function toggleSurfboard(thePlayer)
	if surfboards[thePlayer] then
		unlaunchSurfboard(thePlayer)
	else
		if isElementInWater(thePlayer) then
			launchSurfboard(thePlayer)
		end
	end
end

function scriptWave(thePlayer, command, height)
	local oldHeight = getWaveHeight()
	height = tonumber ( height )
	success = setWaveHeight ( height )
	if ( success ) then
		outputChatBox ( "The old wave height was: " .. oldHeight .. "; " .. getPlayerName ( thePlayer ) .. " set it to: " .. height )
	else
		outputChatBox ( "Invalid number." )
	end
end
addCommandHandler ( "setwave", scriptWave )