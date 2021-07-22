local airlinesCache = {}
local isCached = false

local function fetchNotamData()
	local table = exports.mysql:query_fetch_assoc("SELECT `information` FROM `pilot_notams` WHERE `id`='1'")
	local info = table and table["information"] or "No input"
	triggerClientEvent(client, "ippc:web:notamData", resourceRoot, tostring(info))
end
addEvent("ippc:web:fetchNotam", true)
addEventHandler("ippc:web:fetchNotam", resourceRoot, fetchNotamData)

local function updateNotamData(data)
	exports.mysql:query_free("UPDATE `pilot_notams` SET `information`='"..exports.global:toSQL(data).."' WHERE `id`='1'")
end
addEvent("ippc:web:saveNotam", true)
addEventHandler("ippc:web:saveNotam", resourceRoot, updateNotamData)

local function ippcGetSessionData()
	if not isCached then
		mysql = exports.mysql
		--local result = mysql:query("SELECT ippc_airlines.id AS airlineID, ippc_airlines.name AS airlineName, ippc_airlines.code AS airlineCode, ippc_airline_pilots.character AS pilot FROM ippc_airlines LEFT JOIN ippc_airline_pilots ON ippc_airlines.id=ippc_airline_pilots.airline")
		local result = mysql:query("SELECT * FROM ippc_airlines")
		if result then
			while true do
				row = mysql:fetch_assoc(result)
				if not row then break end
				local members = {}
				local result2 = mysql:query("SELECT `character`, `leader` FROM `ippc_airline_pilots` WHERE `airline` = "..mysql:escape_string(tostring(row.id)))
				if result2 then
					while true do
						row2 = mysql:fetch_assoc(result2)
						if not row2 then break end
						local charName = tostring(exports.cache:getCharacterNameFromID(tonumber(row2.character)))
						table.insert(members, {tonumber(row2.character), charName, tonumber(row2.leader)==1})
					end
					mysql:free_result(result2)
				end
				table.insert(airlinesCache, {tonumber(row.id), tostring(row.name), tostring(row.code), members})
			end
			mysql:free_result(result)
		end
		isCached = true
	end
	local pilotLicenses = exports.mdc:getPlayerPilotLicenses(client) or {}
	triggerClientEvent(client, "ippc:web:sessionData", resourceRoot, pilotLicenses, airlinesCache)
end
addEvent("ippc:web:getSessionData", true)
addEventHandler("ippc:web:getSessionData", resourceRoot, ippcGetSessionData)

local function addNewAirline(airlineName, airlineCode)
	local id = exports.mysql:query_insert_free("INSERT INTO `ippc_airlines` (`name`, `code`) VALUES('"..exports.mysql:escape_string(airlineName).."', '"..exports.mysql:escape_string(airlineCode).."')")
	--local id = tonumber(exports.mysql:insert_id())
	table.insert(airlinesCache, {id, airlineName, airlineCode, {}})
end
addEvent("ippc:web:addNewAirline", true)
addEventHandler("ippc:web:addNewAirline", resourceRoot, addNewAirline)

local function deleteAirline(airlineID)
	airlineID = tonumber(airlineID)
	exports.mysql:query_free("DELETE FROM `ippc_airlines` WHERE `id`="..exports.mysql:escape_string(tostring(airlineID)).." LIMIT 1")
	for k,v in ipairs(airlinesCache) do
		if v[1] == airlineID then
			table.remove(airlinesCache, k)
		end
	end
	exports.mysql:query_free("DELETE FROM `ippc_airline_pilots` WHERE `airline`="..exports.mysql:escape_string(tostring(airlineID)))
end
addEvent("ippc:web:deleteAirline", true)
addEventHandler("ippc:web:deleteAirline", resourceRoot, deleteAirline)

local function fetchAirlines(page)
	local flights
	if page then
		if page == "flights" then
			if flightsCache then
				flights = flightsCache
			else
				flights = {}
				--local result = mysql:query("SELECT * FROM `ippc_flights` WHERE DATE_SUB(NOW(), INTERVAL 14 DAY) <= `etd` AND DATE_SUB(NOW(), INTERVAL 14 DAY) >= `etd` ORDER BY `etd` DESC")
				local result = mysql:query("SELECT * FROM `ippc_flights` ORDER BY `etd` DESC")
				if result then
					while true do
						row = mysql:fetch_assoc(result)
						if not row then break end
						local data = {}
						for k,v in pairs(row) do
							if v == mysql_null() then v = "" end
							data[k] = v
						end
						table.insert(flights, data)
					end
					mysql:free_result(result)
				end
				flightsCache = flights
				--outputDebugString("Loaded "..tostring(#flights).." flights ("..tostring(#flightsCache)..")")

				for k,v in pairs(flights) do
					--outputDebugString("--")
					for k2,v2 in pairs(v) do
						--outputDebugString(tostring(k2).." : "..tostring(v2))
					end
				end
			end
		end
	end
	triggerClientEvent(client, "ippc:web:airlinesCache", resourceRoot, airlinesCache, page, flights)
end
addEvent("ippc:web:fetchAirlines", true)
addEventHandler("ippc:web:fetchAirlines", resourceRoot, fetchAirlines)

local function loadOneFlightToCache(id)
	if flightsCache and tonumber(id) then
		id = tonumber(id)
		local result = mysql:query("SELECT * FROM `ippc_flights` WHERE `id`="..exports.mysql:escape_string(id).." LIMIT 1")
		if result then
			while true do
				row = mysql:fetch_assoc(result)
				if not row then break end
				local data = {}
				for k,v in pairs(row) do
					data[k] = v
				end
				table.insert(flightsCache, data)
			end
			mysql:free_result(result)
		end		
	end
end

local function reloadOneFlightToCache(id)
	if flightsCache and tonumber(id) then
		id = tonumber(id)
		local key
		for k,v in ipairs(flightsCache) do
			if tonumber(v["id"]) == id then
				key = k
				break
			end
		end
		if not key then
			loadOneFlightToCache(id)
			return
		end
		flightsCache[key] = {}
		local result = mysql:query("SELECT * FROM `ippc_flights` WHERE `id`="..exports.mysql:escape_string(id).." LIMIT 1")
		if result then
			while true do
				row = mysql:fetch_assoc(result)
				if not row then break end
				local data = {}
				for k,v in pairs(row) do
					flightsCache[key][k] = v
				end
			end
			mysql:free_result(result)
		end		
	end
end

local function addPilotToAirline(airlineID, pilotName)
	if tonumber(airlineID) and pilotName then
		local charID = exports.cache:getCharacterIDFromName(pilotName)
		if not charID then
			triggerClientEvent(client, "ippc:web:addPilotToAirlineResult", resourceRoot, false, "Not found!")
			return
		end

		local result = exports.mysql:query("SELECT `id` FROM `ippc_airline_pilots` WHERE `airline`="..exports.mysql:escape_string(airlineID).." AND `character`="..exports.mysql:escape_string(charID).." LIMIT 1")
		local num = exports.mysql:num_rows(result)
		exports.mysql:free_result(result)
		if num > 0 then
			triggerClientEvent(client, "ippc:web:addPilotToAirlineResult", resourceRoot, false, "Already added!")
			return
		end

		exports.mysql:query_free("INSERT INTO `ippc_airline_pilots` (`airline`, `character`) VALUES("..exports.mysql:escape_string(airlineID)..", "..exports.mysql:escape_string(charID)..")")
		for k,v in ipairs(airlinesCache) do
			if v[1] == airlineID then
				table.insert(v[4], {charID, pilotName, false})
			end
		end
		triggerClientEvent(client, "ippc:web:addPilotToAirlineResult", resourceRoot, true, "Added!", pilotName, charID, airlineID)
		return
	end
	triggerClientEvent(client, "ippc:web:addPilotToAirlineResult", resourceRoot, false, "Error!")
end
addEvent("ippc:web:addPilotToAirline", true)
addEventHandler("ippc:web:addPilotToAirline", resourceRoot, addPilotToAirline)

local function setPilotAirlineLeader(airlineID, pilotID, leader)
	if tonumber(airlineID) and tonumber(pilotID) then
		local intLeader
		if leader then intLeader = 1 else intLeader = 0 end
		exports.mysql:query_free("UPDATE `ippc_airline_pilots` SET `leader`="..exports.mysql:escape_string(intLeader).." WHERE `airline`="..exports.mysql:escape_string(airlineID).." AND `character`="..exports.mysql:escape_string(pilotID).." LIMIT 1")
		for k,v in ipairs(airlinesCache) do
			if v[1] == airlineID then
				for k2,v2 in ipairs(v[4]) do
					if v2[1] == pilotID then
						airlinesCache[k][4][k2] = {v2[1], v2[2], leader}
						return
					end
				end
			end
		end
	end
end
addEvent("ippc:web:setPilotAirlineLeader", true)
addEventHandler("ippc:web:setPilotAirlineLeader", resourceRoot, setPilotAirlineLeader)

local function removePilotFromAirline(airlineID, pilotID)
	if tonumber(airlineID) and tonumber(pilotID) then
		exports.mysql:query_free("DELETE FROM `ippc_airline_pilots` WHERE `airline`="..exports.mysql:escape_string(tostring(airlineID)).." AND `character`="..exports.mysql:escape_string(tostring(pilotID)).." LIMIT 1")
		for k,v in ipairs(airlinesCache) do
			if v[1] == airlineID then
				for k2,v2 in ipairs(v[4]) do
					if v2[1] == pilotID then
						table.remove(airlinesCache[k][4], k2)
						return
					end
				end
			end
		end
	end
end
addEvent("ippc:web:removePilotFromAirline", true)
addEventHandler("ippc:web:removePilotFromAirline", resourceRoot, removePilotFromAirline)

local function newFpl(adep, ades, etd, eta, tail, pilot1, pilot2, remarks, airline, category)
	--outputDebugString("hey")
	--outputDebugString(tostring(adep)..","..tostring(ades)..","..tostring(etd)..","..tostring(eta)..","..tostring(tail)..","..tostring(pilot1)..","..tostring(pilot2)..","..tostring(remarks)..","..tostring(airline)..","..tostring(category))
	local vehicle
	local vin
	for k,v in ipairs(getElementsByType("vehicle")) do
		if getVehiclePlateText(v) == tail then
			vehicle = v
			vin = tonumber(getElementData(v, "dbid"))
			break
		end
	end
	if not vin then
		triggerClientEvent(client, "ippc:web:fplResult", resourceRoot, false, "Tailnumber not found!")
		return
	end
	local pilot1ID, pilot2ID
	if isStringCharName(pilot1) then
		pilot1ID = exports.cache:getCharacterIDFromName(pilot1) or 0
	end
	if isStringCharName(pilot2) then
		pilot2ID = exports.cache:getCharacterIDFromName(pilot2) or 0
	end
	if not pilot1ID then pilot1ID = 0 end
	if not pilot2ID then pilot2ID = 0 end
	local callsign
	if airline > 0 then
		if airlinesCache then
			for k,v in ipairs(airlinesCache) do
				if v[1] == airline then
					if math.random(1,2) == 1 then
						callsign = v[3]..tostring(math.random(0,9))..tostring(math.random(0,9))..tostring(math.random(0,9))
					else
						callsign = v[3]..tostring(math.random(0,9))..tostring(math.random(0,9))..tostring(math.random(0,9))..tostring(math.random(0,9))
					end
					break
				end
			end
		end
	end
	if not callsign then
		callsign = tail
	end
	local submitter = tonumber(getElementData(client, "dbid"))

	if not eta or tostring(eta) == "NULL" then
		etainsert = "NULL"
	else
		etainsert = "'"..exports.mysql:escape_string(tostring(eta)).."'"
	end

	local flightID = exports.mysql:query_insert_free("INSERT INTO `ippc_flights` (`callsign`, `adep`, `ades`, `etd`, `eta`, `vin`, `pilot1`, `pilot2`, `remarks`, `airline`, `category`, `tickets`, `submitter`, `submitted`) VALUES('"..exports.mysql:escape_string(tostring(callsign)).."', '"..exports.mysql:escape_string(tostring(adep)).."', '"..exports.mysql:escape_string(tostring(ades)).."', '"..exports.mysql:escape_string(tostring(etd)).."', "..tostring(etainsert)..", '"..exports.mysql:escape_string(tostring(vin)).."', '"..exports.mysql:escape_string(tostring(pilot1ID)).."', '"..exports.mysql:escape_string(tostring(pilot2ID)).."', '"..exports.mysql:escape_string(tostring(remarks)).."', '"..exports.mysql:escape_string(tostring(airline)).."', '"..exports.mysql:escape_string(tostring(category)).."', 0, '"..exports.mysql:escape_string(tostring(submitter)).."', NOW() )")

	if flightsCache then
		loadOneFlightToCache(flightID)
	end

	local askTickets = false
	if airline > 0 and category == "Commercial PAX" then
		askTickets = true
	end

	triggerClientEvent(client, "ippc:web:fplResult", resourceRoot, true, callsign, askTickets, flightID)
end
addEvent("ippc:web:newFpl", true)
addEventHandler("ippc:web:newFpl", resourceRoot, newFpl)

function isStringCharName(blah)
	if string.len(blah) > 5 then
		blah = blah:gsub("_", " ")
		blah2 = split(blah, " ")
		if #blah2 > 1 then
			return true
		end
	end
	return false
end