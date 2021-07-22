local affectedByGate = {}

addEvent("gate:trigger", true)
function triggerGate(password)
	if not source or not client then
		return
	end

	local isGate = getElementData(source, "gate")
	if not isGate then
		return
	end
	local playerX, playerY, playerZ = getElementPosition(client)
	local gateX, gateY, gateZ = getElementPosition(source)
	local reachedit = true --false
	--[[
	if ( getDistanceBetweenPoints3D(playerX, playerY, playerZ, gateX, gateY, gateZ) <= 5 ) then
		reachedit = true
	end
	if ( isPedInVehicle (client) and getDistanceBetweenPoints3D(playerX, playerY, playerZ, gateX, gateY, gateZ) <= 25 ) then
		reachedit = true
	end
	--]]
	if reachedit then
		local isGateBusy = getElementData(source, "gate:busy")
		if not (isGateBusy) then
			--[[local gateType = getProtectionType(source)
			if (gateType == 1 or gateType == 3 or gateType == 4 or gateType == 5 or gateType == 7) then
				-- Doesn't need players input]]
				if (canPlayerControlGate(source, client, password)) then
					moveGate(source)
				else
					--outputChatBox("You're unable to open this door, it seems to be locked.", client, 255, 0, 0)
				end
			--end
		end
	end
end
addEventHandler("gate:trigger", getRootElement(), triggerGate)

function moveGate(theGate, secondtime)
	if not secondtime then
		secondtime = false
	end
	local isGateBusy = getElementData(theGate, "gate:busy")
	if not (isGateBusy) or (secondtime) then
		exports.anticheat:changeProtectedElementDataEx(theGate, "gate:busy", true, false)
		local gateParameters = getElementData(theGate, "gate:parameters")

		local newX, newY, newZ, offsetRX, offsetRY, offsetRZ, movementTime, autocloseTime

		local startPosition = gateParameters["startPosition"]
		local endPosition = gateParameters["endPosition"]
		local sphere = nil
		if gateParameters["state"] then -- its opened, close it
			newX = startPosition[1]
			newY = startPosition[2]
			newZ = startPosition[3]
			offsetRX = endPosition[4] - startPosition[4]
			offsetRY = endPosition[5] - startPosition[5]
			offsetRZ = endPosition[6] - startPosition[6]
			gateParameters["state"] = false
			local x, y, z = getElementPosition(theGate)
			local int = getElementInterior(theGate)
			local dim = getElementDimension(theGate)
			local gateSound = getElementData(theGate, "gate:sound")
			
			if gateSound then
				sphere = createColSphere(startPosition[1], startPosition[2], startPosition[3], 100) 
				local affectedPlayers = getElementsWithinColShape(sphere, "player")
				affectedByGate[theGate] = affectedPlayers
				for k,v in ipairs(affectedPlayers) do
					triggerClientEvent("playGateSound", resourceRoot, theGate, false, {x, y, z, int, dim}, gateSound)
				end
			end
		else -- its closed, open it
			newX = endPosition[1]
			newY = endPosition[2]
			newZ = endPosition[3]
			offsetRX = startPosition[4] - endPosition[4]
			offsetRY = startPosition[5] - endPosition[5]
			offsetRZ = startPosition[6] - endPosition[6]
			gateParameters["state"] = true
			local x, y, z = getElementPosition(theGate)
			local int = getElementInterior(theGate)
			local dim = getElementDimension(theGate)
			local gateSound = getElementData(theGate, "gate:sound")
			if gateSound then
				sphere = createColSphere(startPosition[1], startPosition[2], startPosition[3], 100)
				local affectedPlayers = getElementsWithinColShape(sphere, "player")
				affectedByGate[theGate] = affectedPlayers
				for k,v in ipairs(affectedPlayers) do
					triggerClientEvent("playGateSound", resourceRoot, theGate, true, {x, y, z, int, dim}, gateSound)
				end
			end
		end

		movementTime = gateParameters["movementTime"] * 100

		offsetRX = fixRotation(offsetRX)
		offsetRY = fixRotation(offsetRY)
		offsetRZ = fixRotation(offsetRZ)

		moveObject ( theGate, movementTime, newX, newY, newZ, offsetRX, offsetRY, offsetRZ )

		setTimer(function(sphere)
			if isElement(sphere) then 
				destroyElement(sphere) 
			end 
		end, movementTime, 1, sphere)

		if (not secondtime) and (gateParameters["autocloseTime"] ~= 0) then
			autocloseTime = tonumber(gateParameters["autocloseTime"])*100
			gateParameters["timer"] = setTimer(moveGate, movementTime+autocloseTime, 1, theGate, true)
			gateParameters["timerSound"] = setTimer(resetGateSound, movementTime, 1, theGate)
		else
			setTimer(resetBusyState, movementTime, 1, theGate)
		end
		exports.anticheat:changeProtectedElementDataEx(theGate, "gate:parameters", gateParameters, false)
	end
end

function fixRotation(value)
	local invert = true
	if value < 0 then
		--invert = true
		--value = value - value - value
		while value < -360 do
			value = value + 360
		end
		if value < -180 then
			value = value + 180
			value = value - value - value
		end
	else
		while value > 360 do
			value = value - 360
		end
		if value > 180 then
			value = value - 180
			value = value - value - value
		end
	end

	--[[if invert then
		value = 360 - value
	end--]]
	return value
end

function resetGateSound(theGate)
	if affectedByGate[theGate] then
		for k,v in ipairs(affectedByGate[theGate]) do
			triggerClientEvent(v, "stopGateSound", resourceRoot, theGate)
		end
		affectedByGate[theGate] = nil
	end
end

function resetBusyState(theGate)
	local isGateBusy = getElementData(theGate, "gate:busy")
	if (isGateBusy) then
		exports.anticheat:changeProtectedElementDataEx(theGate, "gate:busy", false, false)
	end
	resetGateSound(theGate)
end

function getProtectionType(theGate)
	local gateParameters = getElementData(theGate, "gate:parameters")
	return tonumber(gateParameters["type"]) or -1
end

function canPlayerControlGate(theGate, thePlayer, password)
	if not password then
		password = ""
	end
	local gateParameters = getElementData(theGate, "gate:parameters")
	local gateProtection = getProtectionType(theGate)
	if gateProtection == 1 then
		return true
	elseif gateProtection == 2 then
		if password == gateParameters["gateSecurityParameters"] then
			return true
		end
	elseif gateProtection == 3 then
		local tempAccess = split(gateParameters["gateSecurityParameters"], " ")
		for _, itemID in ipairs(tempAccess) do
			if (exports.global:hasItem(thePlayer, tonumber(itemID))) then
				return true
			end
		end
		--outputDebugString("Found none, returning false.")
		return false
	elseif gateProtection == 4 then
		local tempAccess = split(gateParameters["gateSecurityParameters"], " ")
		local hasItem, slotID, itemValue, databaseID = exports.global:hasItem(thePlayer, tonumber(tempAccess[1]))
		if (hasItem) then
			if string.find(itemValue, tempAccess[2]) then
				return true
			end
		end
	elseif gateProtection == 5 then
		if password == gateParameters["gateSecurityParameters"] then
			return true
		end
	elseif gateProtection == 7 then --for faction ID
		local tempAccess = split(gateParameters["gateSecurityParameters"], " ")
		for _, factionID in ipairs(tempAccess) do
			if exports.factions:isPlayerInFaction(thePlayer, tonumber(factionID)) then
				return true
			end
		end
	elseif gateProtection == 8 then --Exciter Query string
		return exports.global:exciterQueryString(thePlayer, gateParameters["gateSecurityParameters"])
	elseif gateProtection == 9 then --If player has access to the given vehicle
		local tempAccess = split(gateParameters["gateSecurityParameters"], " ")
		for _, vehID in ipairs(tempAccess) do
			local veh
			for k,v in ipairs(exports.pool:getPoolElementsByType("vehicle")) do
				if(getElementData(v, "dbid") == tonumber(vehID)) then
					veh = v
					break
				end
			end
			if veh then
				if(exports.global:isAdminOnDuty(thePlayer) or exports.global:hasItem(thePlayer, 3, tonumber(vehID)) or (getElementData(veh, "faction") > 0 and exports.factions:isPlayerInFaction(thePlayer, getElementData(veh, "faction"))) ) then
					return true
				end
			end
		end
		return false
	elseif gateProtection == 10 then --keycard
		local keycardItemID = 170
		if(exports.global:hasItem(thePlayer, keycardItemID, gateParameters["gateSecurityParameters"])) then
			return true
		end
	else
		outputDebugString("nothing matched :( "..type(gateProtection) .. " "..tostring(gateProtection))
	end

	return false
end

function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

function isNumeric(a)
	if tonumber(a) ~= nil then return true else return false end
end

--[[
Gate types:
1. /gate for everyone
2. /gate for everyone with password
3. /gate with item
4. /gate with item and itemvalue ending on *
5. open with /gate and keypad
6. colsphere trigger
7. /gate for person in faction
8. query string which allows a variety of conditionals (ex: 170=mansion gate AND 168 OR PILOT) //Exciter
9. for person with access to given vehicle ID (vehicle key, member of vehicles faction, or admin on duty) //Exciter
10. gate that only work with the keycard item, whereas the item value and gate password need to be a exact match //Exciter
]]
