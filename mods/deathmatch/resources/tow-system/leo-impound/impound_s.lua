-- MAXIME / 2015.1.31
local lanes = {}
local impounderCol = {
	[1] = createColCuboid ( 1540.2113037109, -1616.1185302734, 10, 23, 12.5, 7),
	[50] = createColCuboid ( 607.63671875, -614.357421875, 14, 20, 50, 10 ),
	[4] = createColCuboid ( 2727.73828125, -2564.3408203125, 12.600810050964, 13.2, 23, 5.5 ),
}


releasePositions = {
	[1] = {
		{ 1535.0107421875, -1615.9853515625, 13.384579658508, 0, 0, 0 },
		{ 1535.236328125, -1607.8779296875, 13.382263183594, 0, 0, 0 },
		{ 1535.4384765625, -1601.0361328125, 13.383508682251, 0, 0, 0 },
		{ 1541.671875, -1597.798828125, 13.386323928833, 0, 0, 270 },
		{ 1548.384765625, -1597.6689453125, 13.379026412964, 0, 0, 270 },
		{ 1555.10546875, -1597.74609375, 13.390182495117, 0, 0, 270 },
		{ 1561.4736328125, -1597.822265625, 13.377742767334, 0, 0, 270 },
	},
	[50] = {
		{639.916015625, -609.9833984375, 16.209426879883, 0, 0, 318},
		{633.2578125, -609.7763671875, 16.209985733032, 0, 0, 318},
		{660.3330078125, -605.2734375, 16.132459640503, 0, 0, 270},
	},

	[4] = {
        { 2669.4345703125, -2532.8291015625, 13.275592803955, 0, 0, 90 },
        { 2669.341796875, -2529.5126953125, 13.277523040771, 0, 0, 90 },
        { 2669.2509765625, -2526.3544921875, 13.277917861938, 0, 0, 90 },
        { 2669.2587890625, -2523.052734375, 13.27708530426, 0, 0, 90 },
        { 2669.2841796875, -2519.6826171875, 13.273972511292, 0, 0, 90 },
        { 2669.3173828125, -2516.3486328125, 13.272769927979, 0, 0, 90 },
        { 2692.251953125, -2534.84765625, 13.34419631958, 154.5 },
        { 2695.4345703125, -2536.3798828125, 13.342967987061, 0, 0, 154.50549316406 },
        { 2698.662109375, -2538.173828125, 13.341193199158, 0, 0, 154.50549316406 },
        { 2701.9111328125, -2539.7822265625, 13.340803146362, 0, 0, 154.50549316406 },
        { 2716.87109375, -2510.7099609375, 13.368440628052, 0, 0, 270 },
        { 2716.72265625, -2514.0546875, 13.361116409302, 0, 0, 270 },
        { 2716.599609375, -2517.5009765625, 13.350545883179, 0, 0, 270 },
        { 2716.732421875, -2520.9912109375, 13.34534072876, 0, 0, 270 },
    }
}

currentReleasePos = {}
function getReleasePosition(impounder)
	if not impounder then impounder = 4 end --RT
	impounder = tonumber(impounder)
    currentReleasePos[impounder] = (currentReleasePos[impounder] or 0) + 1
    if currentReleasePos[impounder] > #releasePositions[impounder] then
        currentReleasePos[impounder] = 1
    end

    local rp = releasePositions[impounder][currentReleasePos[impounder]]

    return rp[1], rp[2], rp[3], rp[4], rp[5], rp[6]
end


local convos = {
	['nobadge'] = {
		"Can I see your badge please?",
		"Badge please?",
	},
	['noveh'] = {
		"Where is the vehicle?",
		"What do you want me to impound?",
		"Bring the car in, please.",
		"Bring it here please."
	},
	['invalid_days'] = {
		"Impound length must be from 1 up to 500 days.",
		"The impound length is quite insane, don't you think?",
		"What the impound length, pal.",
	},
	['too_long_info'] = {
		"Erm.. additional info is too long, mind shortening it first?",
		"Shorten the additional info, pal.",
		"Can you shorten the additional info, it looks too long.",
	},
	['invalid_lanes'] = {
		"Lane number must be a number, dude..",
		"C'mon, be serious, lane number needs to be a number.",
		"Positive lane number please.",
	},
	['lane_not_free_anymore'] = {
		"Opps, sorry this lane is not free anymore, choose another lane please.",
		"Oh someone just took this lane, take another one please.",
		"Nah, pick another lane please.",
	},
	['one_car_at_once'] = {
		"Opps, something is wrong here, try again please.",
		"One car at once please.",
	},
	['invalid_fine'] = {
		"Fine must be positive and can't be greater than $50,000. Try again.",
	},
	['no_car_to_release'] = {
		"You don't have any vehicle in our impound lot at the moment.",
		"Sorry but I couldn't find any vehicle of yours in the impound lot here.",
		"Nothing of yours here, sorry pal.",
	},
	['select_to_release'] = {
		"Which one would you like to release?",
		"Tell me which vehicle do you want me to release?",
		"Select one please."
	},
}

function getConvoText(convoId)
	if convos[convoId] then
		return convos[convoId][math.random(1, #convos[convoId])]
	else
		return convoId
	end
end

function pedSay(pedName, convoId)
	return exports.global:sendLocalText( source, " [English] "..pedName.." says: "..(getConvoText(convoId)), 255, 255, 255, 10 )
end
addEvent("tow:pedSay", true)
addEventHandler("tow:pedSay", root, pedSay)

function getVehicleWithinBooth(factionId)
	for i, veh in pairs(getElementsWithinColShape(impounderCol[factionId], "vehicle")) do
		if getElementData(veh, "faction") ~= factionId and getElementData(veh, "Impounded") == 0 then
			return veh
		end
	end
end

function openImpGui(pedName)
	local dep = nil
	local badgeId = nil
	local factionId = 1
	if pedName == "Justin Borunda" then --pd
		dep = "LSPD"
		badgeId = 64
		factionId = 1
	elseif pedName == "Bobby Jones" then
		dep = "SCoSA"
		badgeId = 156
		factionId = 50
	elseif pedName == "Jacob Garcia" then
		dep = "RT"
		badgeId = 82
		factionId = 4
	end

	if not exports.global:hasItem(source, badgeId) then
		return exports.global:sendLocalText( source, " [English] "..pedName.." says: "..getConvoText('nobadge'), 255, 255, 255, 10 )
	end
	local found = getVehicleWithinBooth(factionId)
	if not found then
		return exports.global:sendLocalText( source, " [English] "..pedName.." says: "..getConvoText('noveh'), 255, 255, 255, 10 )
	end
	--[[
	if factionId == 4 and not exports.integration:isPlayerScripter(source) then
		return exports.global:sendLocalText( source, " [English] "..pedName.." says: The new impound lot is not ready yet, check back soon!", 255, 255, 255, 10 )
	end
	]]
	local freeLane, used, total = getAFreeLane(factionId)
	if not freeLane then
		return exports.global:sendLocalText( source, " [English] "..pedName.." says: "..getConvoText('The impound lot here is full, maybe release some or impound this else where?'), 255, 255, 255, 10 )
	end
	local vehName = exports.global:getVehicleName(found)
	local vehId = getElementData(found, "dbid")
	--exports.global:sendLocalText( source, " [English] "..pedName.." says: Alright, let's see. Hm.. "..vehName..", right?", 255, 255, 255, 10 )
	local first, last = getPlayerNameFirstLast(source)
	local plate = getElementData(found, "show_plate") == 1 and getElementData(found, "plate") or "No plate"
	local vin = getElementData(found, "show_vin") == 1 and getElementData(found, "dbid") or "No VIN"
	triggerClientEvent(source, "tow:openImpGui", source, dep, getElementData(found, "dbid"), first, last, vehName, plate, vin, {freeLane, used, total})

end
addEvent("tow:openImpGui", true)
addEventHandler("tow:openImpGui", root, openImpGui)

function leoStartImpounding(dep, vehid, laneNumber, days, fine, first, last, badge, rank, vehName, plate, vin, volations, location, other)
	local factionId = 1
	local pedName = "Justin Borunda"
	if dep == "LSPD" then
		pedName = "Justin Borunda"
		factionId = 1
	elseif dep == "SCoSA" then
		pedName = "Bobby Jones"
		factionId = 50
	elseif dep == "RT" then
		pedName = "Jacob Garcia"
		factionId = 4
	end

	local freeLane, used, total = getAFreeLane(factionId)
	if not freeLane or freeLane.veh ~= "0" then
		exports.global:sendLocalText( source, " [English] "..pedName.." says: "..getConvoText('lane_not_free_anymore'), 255, 255, 255, 10 )
		triggerClientEvent(source, "tow:reEnableImpGui", source)
		return false
	end

	local veh = exports.pool:getElement("vehicle", vehid)
	if getVehicleWithinBooth(factionId) ~= veh then
		triggerClientEvent(source, "tow:reEnableImpGui", source, true)
		exports.global:sendLocalText( source, " [English] "..pedName.." says: "..getConvoText('one_car_at_once'), 255, 255, 255, 10 )
		return false
	end
	--unlock it
	local time = getRealTime()
    exports.anticheat:setEld(veh, "Impounded", time.yearday, 'all')
    setVehicleLocked(veh, false)
    exports.anticheat:changeProtectedElementDataEx(veh, "enginebroke", 1, false)
    setVehicleEngineState(veh, false)


    -- fix trailing 0's
    local hour = tostring(time.hour)
    local mins = tostring(time.minute)
    if ( time.hour < 10 ) then
        hour = "0" .. hour
    end
    if ( time.minute < 10 ) then
        mins = "0" .. mins
    end
    local datestr = time.monthday .. "/" .. time.month .." " .. hour .. ":" .. mins
    exports.global:giveItem(veh, 72, "Towing Notice: Impounded by ".. rank .." '".. first .." "..last.."', Violation(s): '"..volations.."' at '"..datestr.."', "..factionId == 4 and "" or ("Releasing in next "..days.." day(s)."))
    --Impound it
    local mysql = exports.mysql
    local sql = "UPDATE vehicles SET x='" .. mysql:escape_string(freeLane.x) .. "', y='" .. mysql:escape_string(freeLane.y) .."', z='" .. mysql:escape_string(freeLane.z)
    .. "',   	rotx='" .. mysql:escape_string(freeLane.rx) .. "', roty='" .. mysql:escape_string(freeLane.ry) .. "', rotz='" .. mysql:escape_string(freeLane.rz)
    .. "',     	currx='" .. mysql:escape_string(freeLane.x) .. "', curry='" .. mysql:escape_string(freeLane.y) .. "', currz='" .. mysql:escape_string(freeLane.z)
    .. "',     	currrx='" .. mysql:escape_string(freeLane.rx) .. "', currry='" .. mysql:escape_string(freeLane.ry) .. "', currrz='" .. mysql:escape_string(freeLane.rz)
    .. "',     	interior='" .. mysql:escape_string(freeLane.int) .. "', currinterior='" .. mysql:escape_string(freeLane.int) .. "', dimension='" .. mysql:escape_string(freeLane.dim)
    .. "',     	currdimension='" .. mysql:escape_string(freeLane.dim) .. "', Impounded="..(time.yearday).." WHERE id='" .. mysql:escape_string(vehid)
    .. "'"
    mysql:query_free(sql)
    setVehicleRespawnPosition(veh, freeLane.x, freeLane.y, freeLane.z, freeLane.rx, freeLane.ry, freeLane.rz)
	exports.anticheat:changeProtectedElementDataEx(veh, "respawnposition", {freeLane.x, freeLane.y, freeLane.z, freeLane.rx, freeLane.ry, freeLane.rz}, false)
	exports.anticheat:changeProtectedElementDataEx(veh, "interior", freeLane.int)
	exports.anticheat:changeProtectedElementDataEx(veh, "dimension", freeLane.dim)

	--Remove everyone from vehicles
	local players = getVehicleOccupants ( veh  )
	for seat, player in pairs(players) do
		removePedFromVehicle(player)
	end

	--Detach it
	if isElementAttached(veh) then
		detachElements(veh)
		setElementCollisionsEnabled(veh, true)
	end

	--Respawn it
	respawnVehicle(veh)
	setElementInterior(veh, getElementData(veh, "interior"))
	setElementDimension(veh, getElementData(veh, "dimension"))

	--Make sure it's unlocked and /handbrake in the lot
	setVehicleLocked(veh, false)
	exports.anticheat:changeProtectedElementDataEx(veh, "handbrake", 1, true)
	setElementFrozen(veh, true)

	--Take free slot
	mysql:query_free("UPDATE leo_impound_lot SET veh="..vehid..", "..(tonumber(fine) and ("fine="..fine..",") or "").." release_date="..(tonumber(days)==0 and "NULL" or ("NOW() + INTERVAL "..days.." DAY")).." WHERE lane="..freeLane.lane.." AND veh=0 AND faction="..factionId)
	--outputChatBox("UPDATE leo_impound_lot SET veh="..vehid..", "..(tonumber(fine) and ("fine="..fine..",") or "").." release_date="..(tonumber(days)==0 and "NULL" or ("NOW() + INTERVAL "..days.." DAY")).." WHERE lane="..freeLane.lane.." AND veh=0 AND faction="..factionId)

	exports.anticheat:changeProtectedElementDataEx(veh, "impounder", factionId, false, true)

	--Create report
	local report = ""
	local thefaction = exports.pool:getElement("team", factionId)
	local factionName = getTeamName(thefaction) or "Unknown Organization"
	report = report..factionName.." - Trooper's Impound Report\n"
	report = report.."\nOfficer Information\n"
	report = report.."- First Name: "..string.upper(first).."\n"
	report = report.."- Last Name: "..string.upper(last).."\n"
	report = report.."- Badge: "..string.upper(badge).."\n"
	report = report.."- Rank: "..string.upper(rank).."\n"
	report = report.."\nVehicle Information\n"
	report = report.."- Model: "..string.upper(vehName).."\n"
	report = report.."- Location: "..string.upper(location).."\n"
	report = report.."- Impounded Lane: "..string.upper(laneNumber).."\n"
	report = report.."- Violation: "..string.upper(volations).."\n"
	report = report.."- Is up for release in: "..string.upper(days).." day(s)\n"
	report = report.."- Fine: $"..exports.global:formatMoney(tonumber(fine)).."\n"
	report = report.."\nAdditional Information\n"
	report = report..other.."\n"
	mysql:query_free("INSERT INTO mdc_impounds SET veh="..vehid..", content='"..mysql:escape_string(report).."', reporter='"..mysql:escape_string(first.." "..last).."' ")

	--notifications
	exports.global:sendLocalDoAction(source, "Vehicle "..vehName.." has been impounded to "..factionName.."'s impound lot at lane #"..freeLane.lane..".")
	local owner = getElementData(veh, "owner")
	local account = exports.cache:getAccountFromCharacterId(owner) or {id = 0, username="No-one"}
	local characterName = exports.cache:getCharacterNameFromID(owner) or "No-one"
	if owner > 0 and account then
		local state = "impounded"
		if factionId ~= 4 and tonumber(days)==0 then
			state = "seized"
		end
		exports.announcement:makePlayerNotification(account.id, factionName.." has "..state.." your "..vehName,"(owned by "..characterName..")"..(tonumber(days)>0 and (" for "..days.." day(s).") or "."))
	end

	--Leave some logs
	exports.logs:dbLog(source, 6, {  veh }, "IMPOUNDED "..days.." DAYS TO "..dep)
	exports.vehicle_manager:addVehicleLogs(vehid, "IMPOUNDED "..days.." DAYS TO "..dep, source)
	--Close GUI
	triggerClientEvent(source, "tow:reEnableImpGui", source, true)

	if factionId == 4 then
		insertTowRecord(source, veh)
	end
end
addEvent("tow:leoStartImpounding", true)
addEventHandler("tow:leoStartImpounding", root, leoStartImpounding)

function getAFreeLane(factionId)
	local foundLane = nil
	local countLane = 0
	local countLaneUsed = 0
	local q = exports.mysql:query("SELECT * FROM leo_impound_lot "..(factionId and ("WHERE faction="..factionId) or "").." ORDER BY lane")
	while q do
		local lane = exports.mysql:fetch_assoc(q)
		if not lane then break end
		if lane.veh == "0" then
			if not foundLane then foundLane = lane end
		else
			countLaneUsed = countLaneUsed + 1
		end
		countLane = countLane + 1
	end
	exports.mysql:free_result(q)
	return foundLane, countLaneUsed, countLane
end

function unimpVeh(vehid)
	local veh = exports.pool:getElement("vehicle", tonumber(vehid))
	if veh then
		local impounder = getElementData(veh, "Impounded") or 0
		if impounder == 0 then
			return false, "Vehicle is currently not impounded."
		end
		local impounder = getElementData(veh, "impounder") or 4
		if impounder == 1 or impounder == 50 or impounder == 4 then
			exports.mysql:query_free("UPDATE vehicles SET Impounded=0 WHERE id="..vehid)
			setElementFrozen(veh, false)
            local x, y, z, int, dim, rotation = getReleasePosition(impounder)
            setElementPosition(veh, x, y, z)
            if rotation == nil then rotation = 0 end
            setVehicleRotation(veh, 0, 0, rotation)
            if not int or int == nil then int = 0 end
			if not dim or dim == nil then dim = 0 end
            setElementInterior(veh, int)
            setElementDimension(veh, dim)
            setVehicleLocked(veh, true)
            exports.anticheat:changeProtectedElementDataEx(veh, "enginebroke", 0, true)
            setVehicleDamageProof(veh, false)
            setVehicleEngineState(veh, false)
            exports.anticheat:changeProtectedElementDataEx(veh, "handbrake", 0, true)
            exports.anticheat:changeProtectedElementDataEx(veh, "Impounded", 0, true)
			exports.anticheat:changeProtectedElementDataEx(veh, "impounder", nil, false, true)

            updateVehPos(veh)
			exports.anticheat:changeProtectedElementDataEx(veh, "interior", int)
			exports.anticheat:changeProtectedElementDataEx(veh, "dimension", dim)

			--Detach it
			if isElementAttached(veh) then
				detachElements(veh)
				setElementCollisionsEnabled(veh, true)
			end

			--Respawn it
			respawnVehicle(veh)
			setElementInterior(veh, getElementData(veh, "interior"))
			setElementDimension(veh, getElementData(veh, "dimension") or 0)

			--Make sure it's locked and /handbrake in the lot
			setVehicleLocked(veh, true)
			--exports.anticheat:changeProtectedElementDataEx(veh, "handbrake", 1, true)
			--setElementFrozen(veh, true)
			if source then
				--Create report
				local report = ""
				local thefaction = exports.pool:getElement("team", exports.factions:getCurrentFactionDuty(source))
				local factionName = thefaction and getTeamName(thefaction) or "Unknown Organization"
				report = report..factionName.." - Trooper's Impound Report\n"
				report = report.."\nReleased by "..exports.global:getPlayerName(source)
				exports.mysql:query_free("INSERT INTO mdc_impounds SET veh="..vehid..", content='"..exports.mysql:escape_string(report).."', reporter='"..exports.mysql:escape_string(exports.global:getPlayerName(source)).."' ")
			end
            exports.mysql:query_free("UPDATE leo_impound_lot SET veh=0, release_date=NULL, fine=0 WHERE veh="..vehid)
            return true, "You have unimpounded vehicle #" .. vehid .. "."
		else
			return false, "You are not authorized to release vehicle from this impounder."
		end
	else
		return false, "Vehicle not found."
	end
end

function unimpoundedVeh(vehId)
	local state, reason = unimpVeh(vehId)
	outputChatBox(reason, source)
	return state
end
addEvent("tow:unimpoundedVeh", true)
addEventHandler("tow:unimpoundedVeh", root, unimpoundedVeh)

--[[
addCommandHandler("unimp", function (player, cmd, id)
	local state, reason = unimpVeh(id)
	outputChatBox(reason, player)
end)
]]

function loadLanes()
	setTimer(fixLanes, 1000*60*60*3, 0) -- check and fix lanes every 3 hours.
end
--addEventHandler("onResourceStart", resourceRoot, loadLanes)

function fixLanes()
	local lanesFreed = {}
	for factionId, laness in pairs(lanes) do
		for i, lane in pairs(laness) do
			if tonumber(lane.veh) ~= 0 then
				local veh = exports.pool:getElement("vehicle", tonumber(lane.veh))
				if not veh or not isElement(veh) or getElementData(veh, "Impounded") == 0 or getElementData(veh, "impounder") ~= factionId then
					lanes[factionId][i].veh = 0
					lanes[factionId][i].release_date = nil
					lanes[factionId][i].fine = 0
					exports.mysql:query_free("UPDATE leo_impound_lot SET veh=0, release_date=NULL, fine=0 WHERE lane="..lane.lane)
					lanesFreed[factionId] = (lanesFreed[factionId] or 0) + 1
				end
			end
		end
	end
	for factionId, laness in pairs(lanes) do
		outputDebugString("[TOW] Fixed and Free'd "..(lanesFreed[factionId] or 0).." lane(s) for faction ID "..factionId)
	end
end

function getImpoundLanes(factionId)
	local imps = {}
	local q = exports.mysql:query("SELECT * FROM leo_impound_lot "..(factionId and ("WHERE faction="..factionId) or "").." ORDER BY lane")
	while q do
		local lane = exports.mysql:fetch_assoc(q)
		if not lane then break end
		table.insert(imps, lane)
	end
	exports.mysql:free_result(q)
	return imps
end

function addlane(player, cmd, fid)
		local x, y, z = getElementPosition(player)
		local rx, ry, rz = getElementRotation(player)
		local int = getElementInterior(player)
		local dim = getElementDimension(player)
		if exports.mysql:query_free("INSERT INTO leo_impound_lot SET x="..x..", y="..y..", z="..z..", rx="..rx..", ry="..ry..", rz="..rz..", `int`="..int..", dim="..dim..", faction="..fid) then
			outputChatBox("Land added.", player)
		end
end
--addCommandHandler("addlane", addlane)

function fixlanesC(player, cmd)
	if exports.integration:isPlayerScripter(player) then
		fixLanes()
	end
end
addCommandHandler("fixlanes", fixlanesC)

function getLaneFromVeh(vehid)
	return exports.mysql:query_fetch_assoc("SELECT * FROM leo_impound_lot WHERE veh="..vehid)
end

function openReleaseGUI(pedName)
	local factionId = nil
	if pedName == "Sergeant K. Johnson" then
		factionId = 1
	elseif pedName == "Robert Dunston" then
		factionId = 50
	elseif pedName == "Greer Reid" then
		factionId = 4
	end

	local vehs = {}
	local empty = true
	for i, veh in pairs(exports.pool:getPoolElementsByType("vehicle")) do
		local oneVeh = {}
		local owner = getElementData(veh, "owner")
		local impounded = getElementData(veh, "Impounded")
		local impounder = getElementData(veh, "impounder")
		if owner == getElementData(source, "dbid") and impounded ~= 0 and impounder == factionId then
			oneVeh.vin = getElementData(veh, "dbid")
			oneVeh.model = exports.global:getVehicleName(veh)
			oneVeh.impounded = getRealTime().yearday-impounded
			oneVeh.lane = getLaneFromVeh(oneVeh.vin)
			vehs[oneVeh.vin] = oneVeh
			empty = nil
		end
	end
	if not empty then
		return triggerClientEvent(source, "tow:openReleaseGUI", source, factionId, vehs)
	else
		return exports.global:sendLocalText( source, " [English] "..pedName.." says: "..(getConvoText("no_car_to_release")), 255, 255, 255, 10 )
	end
end
addEvent("tow:openReleaseGUI", true)
addEventHandler("tow:openReleaseGUI", root, openReleaseGUI)

function release(pedName, vehid, cost)
	local lane = exports.mysql:query_fetch_assoc("SELECT CASE WHEN release_date IS NULL THEN 'seized' ELSE TO_SECONDS(release_date) END AS secdiff FROM leo_impound_lot WHERE veh="..vehid.." LIMIT 1")
	if not lane or lane.secdiff == mysql_null() then
		local veh = exports.pool:getElement('vehicle', vehid)
		if veh then
			exports.anticheat:setEld(veh, 'Impounded', 0, 'all')
		end
		outputChatBox("Internal Error. Vehicle is not found in impound database, please get assistance from admins to teleport it to you.", source, 255, 0, 0)
		return false
	end

	if pedName ~= "Greer Reid" and lane.secdiff == "seized" then
		exports.global:sendLocalText( source, " [English] "..pedName.." says: "..(getConvoText("I'm sorry your vehicle is seized, I can not release it until further notice, you gotta contact our officiers about that.")), 255, 255, 255, 10 )
		return false
	end
	local text, sec = exports.datetime:formatFutureTimeInterval(tonumber(lane.secdiff))
	if pedName ~= "Greer Reid" and sec ~= 0 then
		exports.global:sendLocalText( source, " [English] "..pedName.." says: "..(getConvoText("Well, according to the document I got here, you gotta wait ".. text.." more to release this vehicle. Sorry..")), 255, 255, 255, 10 )
		return false
	end

	if not exports.global:takeMoney(source, cost) then
		exports.global:sendLocalText( source, " [English] "..pedName.." says: "..(getConvoText("$"..exports.global:formatMoney(cost).." please..")), 255, 255, 255, 10 )
		return false
	end

	local veh = exports.pool:getElement("vehicle", vehid)
	local impounder = getElementData(veh, "impounder")
	local thefaction = exports.pool:getElement("team", impounder)
	if thefaction then
		if exports.bank:giveBankMoney(thefaction, cost) then
			exports.bank:addBankTransactionLog(getElementData(source,"dbid"), -getElementData(thefaction, "id"), cost, 16, "Impound fee & fine to release vehicle VIN #"..vehid)
			exports.logs:dbLog(source, 25 , {thefaction}, "$"..exports.global:formatMoney(cost).." Impound fee & fine to release vehicle VIN #"..vehid)
		end
	end

	local state, reason = unimpVeh(vehid)
	if state then
		exports.global:sendLocalText( source, " [English] "..pedName.." says: "..(getConvoText("Your vehicle has been released, it's out front. (( Please remember to /park your vehicle so it does not respawn back here. ))")), 255, 255, 255, 10 )
		exports.vehicle_manager:addVehicleLogs(vehid, "LEO UNIMPOUND.", source)
		exports.logs:dbLog(source, 6, {  veh }, "LEO UNIMPOUNDED ")
	else
		exports.global:sendLocalText( source, " [English] "..pedName.." says: "..(getConvoText("Opps, sorry. "..reason)), 255, 255, 255, 10 )
	end
end
addEvent("tow:release", true)
addEventHandler("tow:release", root, release)

function scripterCreateLot(player, cmd, int, dim, faction)
	if exports.integration:isPlayerScripter(player) and int and dim and faction then
		local q = exports.mysql:query("SELECT * FROM leo_impound_lot WHERE `int`=1 AND dim=1060 ORDER BY lane")
		while q do
			local lane = exports.mysql:fetch_assoc(q)
			if not lane then break end
			if exports.mysql:query_free("INSERT INTO leo_impound_lot SET x='"..lane.x.."', y='"..lane.y.."', z='"..lane.z.."', rx='"..lane.rx.."', ry='"..lane.ry.."', rz='"..lane.rz.."', `int`="..int..", dim="..dim..", faction="..faction.."") then
				outputChatBox("Lane added "..int.." "..dim.." "..faction, player)
			end
		end
		exports.mysql:free_result(q)
	end
end
addCommandHandler("scripterCreateLot", scripterCreateLot)

function rtMoveImpoundsToNewLot(player)
	if exports.integration:isPlayerScripter(player) then
		--Free all slots
		exports.mysql:query_free("UPDATE leo_impound_lot SET veh=0, fine=0, release_date=NULL WHERE faction=4 ")

		local q = exports.mysql:query("SELECT * FROM leo_impound_lot WHERE faction=4 AND veh=0 ORDER BY lane")
		local lanes = {}
		while q do
			local lane = exports.mysql:fetch_assoc(q)
			if not lane then break end
			table.insert(lanes, lane)
		end
		exports.mysql:free_result(q)
		outputChatBox("There are "..#lanes.." free lanes in RT lot.", player)
		local vehs = getElementsByType("vehicle")
		local imps = {}
		for i, veh in pairs(vehs) do
			if getElementData(veh, "dbid") > 0 and getElementData(veh, "Impounded") > 0 and getElementData(veh, "impounder") == 4 then
				table.insert(imps, veh)
			end
		end
		outputChatBox("There are "..#imps.." vehicles currently impounded by RT.", player)
		outputChatBox("Start moving now..", player)

		local vehIndex = 1
		for i, freeLane in ipairs(lanes) do
			local veh = imps[vehIndex]
			if veh and isElement(veh) and getElementType(veh) == "vehicle" then
				local vehid = getElementData(veh, "dbid")

				--unlock it
				local time = getRealTime()
			    --exports.anticheat:setEld(veh, "Impounded", time.yearday, 'all')
			    setVehicleLocked(veh, false)
			    exports.anticheat:changeProtectedElementDataEx(veh, "enginebroke", 1, false)
			    setVehicleEngineState(veh, false)

			    --Impound it
			    local mysql = exports.mysql
			    local sql = "UPDATE vehicles SET x='" .. mysql:escape_string(freeLane.x) .. "', y='" .. mysql:escape_string(freeLane.y) .."', z='" .. mysql:escape_string(freeLane.z)
			    .. "',   	rotx='" .. mysql:escape_string(freeLane.rx) .. "', roty='" .. mysql:escape_string(freeLane.ry) .. "', rotz='" .. mysql:escape_string(freeLane.rz)
			    .. "',     	currx='" .. mysql:escape_string(freeLane.x) .. "', curry='" .. mysql:escape_string(freeLane.y) .. "', currz='" .. mysql:escape_string(freeLane.z)
			    .. "',     	currrx='" .. mysql:escape_string(freeLane.rx) .. "', currry='" .. mysql:escape_string(freeLane.ry) .. "', currrz='" .. mysql:escape_string(freeLane.rz)
			    .. "',     	interior='" .. mysql:escape_string(freeLane.int) .. "', currinterior='" .. mysql:escape_string(freeLane.int) .. "', dimension='" .. mysql:escape_string(freeLane.dim)
			    .. "',     	currdimension='" .. mysql:escape_string(freeLane.dim) .. "' WHERE id='" .. mysql:escape_string(vehid)
			    .. "'"
			    mysql:query_free(sql)
			    setVehicleRespawnPosition(veh, freeLane.x, freeLane.y, freeLane.z, freeLane.rx, freeLane.ry, freeLane.rz)
				exports.anticheat:changeProtectedElementDataEx(veh, "respawnposition", {freeLane.x, freeLane.y, freeLane.z, freeLane.rx, freeLane.ry, freeLane.rz}, false)
				exports.anticheat:changeProtectedElementDataEx(veh, "interior", freeLane.int)
				exports.anticheat:changeProtectedElementDataEx(veh, "dimension", freeLane.dim)

				--Detach it
				if isElementAttached(veh) then
					detachElements(veh)
					setElementCollisionsEnabled(veh, true)
				end

				--Respawn it
				respawnVehicle(veh)
				setElementInterior(veh, getElementData(veh, "interior"))
				setElementDimension(veh, getElementData(veh, "dimension"))

				--Make sure it's unlocked and /handbrake in the lot
				setVehicleLocked(veh, false)
				exports.anticheat:changeProtectedElementDataEx(veh, "handbrake", 1, true)
				setElementFrozen(veh, true)

				--Take free slot
				mysql:query_free("UPDATE leo_impound_lot SET veh="..vehid.." WHERE lane="..freeLane.lane.." ")

				--Leave some logs
				local dep = "RT"
				local days = 0
				exports.logs:dbLog(player, 6, {  veh }, "IMPOUNDED "..days.." DAYS TO "..dep)
				exports.vehicle_manager:addVehicleLogs(vehid, "IMPOUNDED "..days.." DAYS TO "..dep, player)

				outputChatBox(i..". Moved vehicle #"..vehid.." to lane #"..freeLane.lane, player)

				vehIndex = vehIndex + 1
			else
				break
			end
		end
	end
end
addCommandHandler("rtMoveImpoundsToNewLot", rtMoveImpoundsToNewLot)
