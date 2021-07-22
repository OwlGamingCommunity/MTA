mysql = exports.mysql
local playersToBeSaved = { }

function beginSave()
	outputDebugString("WORLDSAVE INCOMING")
	for key, value in ipairs(getElementsByType("player")) do
		--triggerEvent("savePlayer", value, "Save All")
		table.insert(playersToBeSaved, value)
	end
	local timerDelay = 0
	for key, thePlayer in ipairs(playersToBeSaved) do
		timerDelay = timerDelay + 1000
		setTimer(savePlayer, timerDelay, 1, "Save All", thePlayer)
	end
end

function syncTIS()
	for key, value in ipairs(getElementsByType("player")) do
		local tis = getElementData(value, "timeinserver")
		if (tis) and (getPlayerIdleTime(value) < 600000)  then
			exports.anticheat:changeProtectedElementDataEx(value, "timeinserver", tonumber(tis)+1, false)
		end
	end
end
setTimer(syncTIS, 60000, 0)

function savePlayer(reason, player)
	if source ~= nil then
		player = source
	end
	if isElement(player) then
		local logged = getElementData(player, "loggedin")
		if (logged==1 or reason=="Change Character") then
			local vehicle = getPedOccupiedVehicle(player)
		
			if (vehicle) then
				local seat = getPedOccupiedVehicleSeat(player)
				triggerEvent("onVehicleExit", vehicle, player, seat)
			end
				
			local x, y, z = getElementPosition(player)
			local rot = getPedRotation(player)
			local health = isPedDead(player) and 0 or getElementHealth(player)
			local armor = getPedArmor(player)
			local interior = getElementInterior(player)
			local dimension = getElementDimension(player)
			local alcohollevel = getElementData(player, "alcohollevel")
			local d_addiction = ( getElementData(player, "drug.1") or 0 ) .. ";" .. ( getElementData(player, "drug.2") or 0 ) .. ";" .. ( getElementData(player, "drug.3") or 0 ) .. ";" .. ( getElementData(player, "drug.4") or 0 ) .. ";" .. ( getElementData(player, "drug.5") or 0 ) .. ";" .. ( getElementData(player, "drug.6") or 0 ) .. ";" .. ( getElementData(player, "drug.7") or 0 ) .. ";" .. ( getElementData(player, "drug.8") or 0 ) .. ";" .. ( getElementData(player, "drug.9") or 0 ) .. ";" .. ( getElementData(player, "drug.10") or 0 )
			
			local skin = getElementModel(player)
		
			if getElementData(player, "help") then
				dimension, interior, x, y, z = unpack( getElementData(player, "help") )
			elseif getElementData(player, "viewingInterior") then
				dimension, interior, x, y, z = unpack( getElementData(player, "viewingInterior") )
			elseif exports['freecam-tv']:isPlayerFreecamEnabled(player) then 
				x = getElementData(player, "tv:x")
				y = getElementData(player, "tv:y")
				z =  getElementData(player, "tv:z")
				interior = getElementData(player, "tv:int")
				dimension = getElementData(player, "tv:dim") 
			end
		
			local  timeinserver = getElementData(player, "timeinserver")
			-- LAST AREA
			local zone = exports.global:getElementZoneName(player)
			if not zone or #zone == 0 then
				zone = "Unknown"
			end
		
			dbExec(exports.mysql:getConn("mta"), "UPDATE characters SET x = ?, y = ?, z = ?, rotation = ?, health = ?, armor = ?, dimension_id = ?, interior_id = ?, lastlogin=NOW(), lastarea = ?, timeinserver = ?, alcohollevel = ? WHERE id = ?", x, y, z, rot, health, armor, dimension, interior, zone, timeinserver, tostring(alcohollevel), getElementData(player, "dbid"))
			dbExec(exports.mysql:getConn("mta"), "UPDATE account_details SET lastlogin=NOW() WHERE account_id = ?", getElementData(player,"account:id"))
		end
	end
end
addEventHandler("onPlayerQuit", getRootElement(), savePlayer)
addEvent("savePlayer", false)
addEventHandler("savePlayer", getRootElement(), savePlayer)
setTimer(beginSave, 3600000, 0)
addCommandHandler("saveall", function(p) if exports.integration:isPlayerLeadAdmin(p) then beginSave() outputChatBox("Done.", p) end end)
addCommandHandler("saveme", function(p) triggerEvent("savePlayer", p, "Save Me", p) end)
