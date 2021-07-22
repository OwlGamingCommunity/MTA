alarmless = { [592]=true, [553]=true, [577]=true, [488]=true, [511]=true, [497]=true, [548]=true, [563]=true, [512]=true, [476]=true, [593]=true, [447]=true, [425]=true, [519]=true, [20]=true, [460]=true, [417]=true, [469]=true, [487]=true, [513]=true, [581]=true, [510]=true, [509]=true, [522]=true, [481]=true, [461]=true, [462]=true, [448]=true, [521]=true, [468]=true, [463]=true, [586]=true, [472]=true, [473]=true, [493]=true, [595]=true, [484]=true, [430]=true, [453]=true, [452]=true, [446]=true, [454]=true, [537]=true, [538]=true, [569]=true, [590]=true, [441]=true, [464]=true, [501]=true, [465]=true, [564]=true, [571]=true, [471]=true, [539]=true, [594]=true }

function onVehicleDamage(ignoredElement)
	local driver = getVehicleOccupant(source, 0)
	local passenger1 = getVehicleOccupant(source, 1)
	local passenger2 = getVehicleOccupant(source, 2)
	local passenger3 = getVehicleOccupant(source, 3)

	if isVehicleLocked(source) and not alarmless[getElementModel(source)]  and (not driver or driver == ignoredElement) and (not passenger1 or passenger1 == ignoredElement) and (not passenger2 or passenger2 == ignoredElement) and (not passenger3 or passenger3 == ignoredElement) then
	
		local players = exports.pool:getPoolElementsByType("player")
		for _, arrayPlayer in ipairs(players) do
			local x, y, z = getElementPosition(source)
			local vDim = getElementDimension(source)
			local vInt = getElementInterior(source)
			local px, py, pz = getElementPosition(arrayPlayer)
			local pDim = getElementDimension(arrayPlayer)
			local pInt = getElementDimension(arrayPlayer)
			if (pDim == vDim and pInt == vInt and getDistanceBetweenPoints2D(x, y, px, py) <= 30) then
				triggerClientEvent(arrayPlayer, "startCarAlarm", source)
			end
		end	
	end
end
addEventHandler("onVehicleDamage", getRootElement(), onVehicleDamage)
addEvent("onVehicleRemoteAlarm", true)
addEventHandler("onVehicleRemoteAlarm", getRootElement(), onVehicleDamage)


-- Make a district when alarm is triggered
function district()
	--[[
	local logged = getElementData(source, "loggedin")
	local dimension = getElementDimension(source)
	local interior = getElementInterior(source)
	
	local affectedElements = { }
	local playerName = getPlayerName(source)
	local zonename = exports.global:getElementZoneName(source)
	local x, y = getElementPosition(source)
		
	for key, value in ipairs(exports.pool:getPoolElementsByType("player")) do
		local playerzone = exports.global:getElementZoneName(value)
		local playerdimension = getElementDimension(value)
		local playerinterior = getElementInterior(value)
		--outputDebugString("loop entered")
		
		if (zonename==playerzone) and (dimension==playerdimension) and (interior==playerinterior) and getDistanceBetweenPoints2D(x, y, getElementPosition(value)) < 200 then
			local logged = getElementData(value, "loggedin")
			if (logged==1) then
				table.insert(affectedElements, value)
				if exports.integration:isPlayerTrialAdmin(value) then
					-- Disabled temporary (happens at random times?)
					--outputChatBox("District IC: The sound of a vehicle alarm can be heard in the area. ((".. playerName .."))", value, 255, 255, 255)
				else
					--outputChatBox("District IC: The sound of a vehicle alarm can be heard in the area." , value, 255, 255, 255)
				end
			end
		end
	end
	]]
end
addEvent("alarmDistrict", true)
addEventHandler("alarmDistrict", getRootElement(), district)