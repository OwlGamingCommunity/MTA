mysql = exports.mysql

routes = { }
destinations = { }
stops = { }

-- When a player enters a SAPT bus and is a SAPT member
function showIBIS(thePlayer, seat)
	local vehicleModel = getElementModel(source)
	if seat == 0 then
		if exports.factions:isPlayerInFaction(thePlayer, 64) then
			if (vehicleModel == 431 or vehicleModel == 437) then
				triggerClientEvent(thePlayer, "client:sapt_drawIBIS", thePlayer)
			end
		end
	else
		if (getElementData(source, "faction") == 64) and (vehicleModel == 431 or vehicleModel == 437) then
			if (exports.global:takeMoney(thePlayer, 10)) then
				exports.global:giveMoney(exports.factions:getFactionFromName("San Andreas Public Transport"), 10)
				exports.hud:sendBottomNotification(thePlayer, "SAPT Bus Notification", "You have been charged $10 to use our services.")
			else
				local x, y, z = getElementPosition(thePlayer)
				removePedFromVehicle(thePlayer)
				setElementPosition(thePlayer, x, y, z+1)
				exports.hud:sendBottomNotification(thePlayer, "SAPT Bus Notification", "You need $10 to user our services, sorry!")
			end
		end
	end
end
addEventHandler("onVehicleEnter", getRootElement(), showIBIS)

-- When a player leaves a SAPT bus and is a SAPT member
function hideIBIS(thePlayer, seat)
	if seat == 0 then
		if exports.factions:isPlayerInFaction(thePlayer, 64) then
			local vehicleModel = getElementModel(source)
			if (vehicleModel == 431 or vehicleModel == 437) then
				triggerClientEvent(thePlayer, "client:sapt_stopRoute", thePlayer)
				triggerClientEvent(thePlayer, "client:sapt_closeIBIS", thePlayer)
			end
		end
	end
end
addEventHandler("onVehicleExit", getRootElement(), hideIBIS)

-- This function fetches the MySQL Data for the SAPT destinations and routes.
-- This function should be executed on resource start, and when a faction leader updates anything on the lines.
function fetchData()
	local result = mysql:query("SELECT * FROM sapt_destinations")
	while true do
		local row = mysql:fetch_assoc(result)
		if (not row) then break end

		destinations[tostring(row["destinationID"])] = { ["id"] = row["id"], ["name"] = row["name"] }
	end
	mysql:free_result(result)

	result = mysql:query("SELECT * FROM sapt_routes")
	while true do
		local row = mysql:fetch_assoc(result)
		if (not row) then break end

		id = row["id"]
		routes[id] = { }
		routes[id]["route"] = row["route"]
		routes[id]["line"] = row["line"]
		routes[id]["destination"] = row["destination"]

		stops[id] = { }
		local quickRes = mysql:query("SELECT * FROM sapt_locations WHERE route='" .. row["id"] .. "'")
		stops[id]["totalStops"] = mysql:num_rows(quickRes)
		while true do
			local quickRow = mysql:fetch_assoc(quickRes)
			if (not quickRow) then break end

			rid = quickRow["stopID"]
			stops[id][rid] = { }
			stops[id][rid]["posX"] = quickRow["posX"]
			stops[id][rid]["posY"] = quickRow["posY"]
			stops[id][rid]["posZ"] = quickRow["posZ"]
			stops[id][rid]["name"] = quickRow["name"]

		end
		mysql:free_result(quickRes)
	end
	mysql:free_result(result)
	triggerClientEvent(client, "client:sapt_fetchData", client, destinations, routes, stops)
end
addEvent("server:sapt_fetchData", true)
addEventHandler("server:sapt_fetchData", getRootElement(), fetchData)

function checkData(typeOfData, value, otherValues)
	--[[ Types of data:
		0: Fetch Line from SQL
		1: Fetch Route from SQL
		2: Fetch Destination from SQL ]]--
	if value == nil or not value then value = "000" end
	if otherValues == nil or not otherValues then otherValues = "000" end

	if (typeOfData == 0) then
		local result = mysql:query("SELECT * FROM sapt_routes WHERE line='" .. mysql:escape_string(value) .. "'")
		if (mysql:num_rows(result) > 0) then
			dataCorrect = 1 -- Line exists
			triggerClientEvent(client, "client:sapt_checkData", client, typeOfData, dataCorrect, false)
		else
			dataCorrect = 0 -- Line does not exist
			triggerClientEvent(client, "client:sapt_checkData", client, typeOfData, dataCorrect, false)
		end
		mysql:free_result(result)
	elseif (typeOfData == 1) then
		local result = mysql:query("SELECT * FROM sapt_routes WHERE line='" .. mysql:escape_string(otherValues) .. "' AND route='" .. tonumber(value) .. "'")
		if (mysql:num_rows(result) > 0) then
			dataCorrect = 1 -- Route exists
			local row = mysql:fetch_assoc(result)
			local valsToSend = { tostring(row["destination"]), tonumber(row["id"]) }
			triggerClientEvent(client, "client:sapt_checkData", client, typeOfData, dataCorrect, valsToSend)
		else
			dataCorrect = 0 -- Route does not exist
			triggerClientEvent(client, "client:sapt_checkData", client, typeOfData, dataCorrect, false)
		end
		mysql:free_result(result)
	elseif (typeOfData == 2) then
		local result = mysql:query("SELECT * FROM sapt_destinations WHERE destinationID='" .. mysql:escape_string(value) .. "'")
		if (mysql:num_rows(result) > 0) then
			dataCorrect = 1 -- Destination exists
			triggerClientEvent(client, "client:sapt_checkData", client, typeOfData, dataCorrect, false)
		else
			dataCorrect = 0 -- Destination does not exist
			triggerClientEvent(client, "client:sapt_checkData", client, typeOfData, dataCorrect, false)
		end
		mysql:free_result(result)
	end
end
addEvent("server:sapt_checkData", true)
addEventHandler("server:sapt_checkData", getRootElement(), checkData)

-- Announcing stops
function announceStop(thisStop, nextStop)
	if (nextStop == "") then
		exports.global:sendLocalText(client, "|| SAPT Announcement - This stop: " .. thisStop .. " ||", 0, 0, 191)
		exports.global:sendLocalText(client, "|| SAPT Announcement - End of the line ||", 0, 0, 191)
	elseif (thisStop == "") then
		exports.global:sendLocalText(client, "|| SAPT Announcement - Start of the line ||", 0, 0, 191)
		exports.global:sendLocalText(client, "|| SAPT Announcement - First stop: " .. nextStop .. " ||", 0, 0, 191)
	else
		exports.global:sendLocalText(client, "|| SAPT Announcement - This stop: " .. thisStop .. " ||", 0, 0, 191)
		exports.global:sendLocalText(client, "|| SAPT Announcement - Next stop: " .. nextStop .. " ||", 0, 0, 191)
	end
end
addEvent("sapt:server_announceStops", true)
addEventHandler("sapt:server_announceStops", getRootElement(), announceStop)
