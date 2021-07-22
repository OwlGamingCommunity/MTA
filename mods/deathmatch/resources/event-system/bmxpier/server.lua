local sx, sy = 819.71875, -2067.69140625
local perimeter = createColCuboid(sx, sy, 12, 34, 153, 17)

local startCoord = { 825.7197265625, -1921.798828125, 14.789143562317 }

local veh = nil
local ready = true
local competitor = nil

--[[addEventHandler("onResourceStart", resourceRoot, function()
	local thePed = createPed(82, 844.2763671875, -1906.1259765625, 12.8671875)
	exports.anticheat:changeProtectedElementDataEx(thePed, "nametag", true)
	exports.anticheat:changeProtectedElementDataEx(thePed, "name", "Marvel Dupont")
	setElementData(thePed, "rpp.npc.type", "bmxevent")
	setElementFrozen(thePed, true)
end)]]

function startTheRace(thePlayer)
	local isPlayerInACar = getPedOccupiedVehicle(thePlayer)
	if isPlayerInACar then
		removePedFromVehicle(thePlayer)
	end

	triggerClientEvent(thePlayer, "bmx:start", resourceRoot)
	setElementPosition(thePlayer, startCoord[1], startCoord[2], startCoord[3])
	setElementRotation(thePlayer, 0, 0, 180)
	veh = createVehicle(481, startCoord[1], startCoord[2], startCoord[3], 0, 0, 180)

	warpPedIntoVehicle(thePlayer, veh, 0)

	setVehicleOverrideLights(veh, 1)
	setVehicleEngineState(veh, false)
	setVehicleFuelTankExplodable(veh, false)
	setVehicleVariant(veh, exports.vehicle:getRandomVariant(getElementModel(veh)))
	exports.anticheat:changeProtectedElementDataEx(veh, "dbid", -1000)
	exports.anticheat:setEld( veh, "fuel", exports.vehicle_fuel:getMaxFuel(veh) )
	exports.anticheat:setEld(veh, "Impounded", 0, 'all')
	exports.anticheat:changeProtectedElementDataEx(veh, "engine", 0, false)
	exports.anticheat:changeProtectedElementDataEx(veh, "faction", -1)
	exports.anticheat:changeProtectedElementDataEx(veh, "owner", -1, false)
	exports.anticheat:changeProtectedElementDataEx(veh, "job", 0, false)
	exports.anticheat:changeProtectedElementDataEx(veh, "handbrake", 0, true)	
	exports.anticheat:changeProtectedElementDataEx(veh, "brand", "SPINE", true)
	exports.anticheat:changeProtectedElementDataEx(veh, "maximemodel", "CROSS ExTra", true)
	exports.anticheat:changeProtectedElementDataEx(veh, "year", "2016", true)
	exports.anticheat:changeProtectedElementDataEx(veh, "vehicle_shop_id", 449, true)
end



function endTheRace(thePlayer, time, changeChar)
	competitor = nil
	ready = true
	if isElement(thePlayer) then
		if changeChar == false then	
			local isPlayerInACar = getPedOccupiedVehicle(thePlayer)
			if isPlayerInACar then
				removePedFromVehicle(thePlayer)
			end		
			setElementPosition(thePlayer, 837.0546875, -1911.9951171875, 12.8671875) 	
		end

		destroyElement(veh)
		ready = true
		if tonumber(time) and tonumber(time) > 10 then
			fetchRemote("https://externet.website/tools/owl/supersecretadd.php?key=43q4LrGJ7CDvU6A&char="..getPlayerName(thePlayer).."&score="..time, function() end)
			outputChatBox("You have ended the race with a time of "..tostring(time).." seconds!", thePlayer)
		end
	end
end
addEvent("bmx:endrace", true)
addEventHandler("bmx:endrace", resourceRoot, endTheRace)


local queue = {}


function addToQueue(thePlayer)
	local alreadyInList = false
	for k, v in pairs(queue) do
		if v == thePlayer then
			alreadyInList = true
			break
		end
	end

	if alreadyInList then
		outputChatBox("You are already listed in the queue. Wait your turn!", thePlayer)
	else
		if exports.global:takeMoney(thePlayer, 50) then

			table.insert(queue, thePlayer)
			outputChatBox("You were added to the queue. Stand by! It will be your turn in "..tostring(#queue).." turn(s).", thePlayer)
			local file = fileOpen("bmxpier/ticketstotal.txt")
			fileSetPos(file, fileGetSize(file))
			fileWrite(file, "50\r\n")
			fileClose(file)
		else
			outputChatBox("You need 50$ to participate to this event.", thePlayer)
		end
	end
end
addEvent("bmx:addtoqueue", true)
addEventHandler("bmx:addtoqueue", resourceRoot, addToQueue)

setTimer(function()
	if (#queue > 0) and (ready == true) then
		local next = queue[1]
		table.remove(queue, 1)
		proceedNext(next)
	end
end, 5000, 0)

function proceedNext(player)
	if isElement(player) then
		ready = false
		competitor = player
		setTimer(function()
			startTheRace(player)
		end, 5000, 1)
		outputChatBox("You are up for the BMX event in 5 seconds!", player)
	end
end

function getQueue(ped)
	local thePlayer = source
	if #queue > 0 then
		outputChatBox("[English] Marvel Dupont says: The queue is currently:", thePlayer, 255, 255, 255) -- all this chat appears locally only.
		for k, v in pairs(queue) do
			if isElement(v) then
				outputChatBox("[English] Marvel Dupont says: #"..k..": "..string.gsub(getPlayerName(v), "_", " "), thePlayer, 255, 255, 255)
			else
				table.remove(queue, k)
			end
		end
	else
		outputChatBox("[English] Marvel Dupont says: There is no one in queue.", thePlayer, 255, 255, 255)
	end
end
addEvent("bmx:queue", true)
addEventHandler("bmx:queue", root, getQueue)

function spectate(ped)
	local thePlayer = source
	outputChatBox("[English] Marvel Dupont says: There are seats around the circuit! Go through the door on my left.", thePlayer, 255, 255, 255)
end
addEvent("bmx:spectate", true)
addEventHandler("bmx:spectate", root, spectate)

addEventHandler("onPlayerQuit", resourceRoot, function(thePlayer)
	if thePlayer == competitor then
		competitor = nil
		ready = true
	end
end)