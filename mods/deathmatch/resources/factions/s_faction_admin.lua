--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

dutyAllow = { }
dutyAllowChanges = { }

function adminSetPlayerFaction(thePlayer, commandName, partialNick, factionID)
	if exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerFMTLeader(thePlayer) then
		factionID = tonumber(factionID)
		if not (partialNick) or not (factionID) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Name/ID] [Faction ID]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerNick = exports.global:findPlayerByPartialNick(thePlayer, partialNick)

			if targetPlayer then
				local defaultRank = getDefaultRank(factionID)
				local theTeam = exports.pool:getElement("team", factionID)
				if not theTeam then
					outputChatBox("Invalid Faction ID.", thePlayer, 255, 0, 0)
					return
				elseif isPlayerInFaction(targetPlayer, factionID) then
					outputChatBox("Player is already a member of this faction.", thePlayer, 255, 0, 0)
					return
				end 

				local factionInfo = getElementData(targetPlayer, "faction") or {}
				local num_factions = exports.global:countTable(factionInfo)
				if num_factions >= 5 then
					outputChatBox("This player is already in the maximum amount of factions.", thePlayer, 255, 0, 0)
					return
				end


				if dbExec(exports.mysql:getConn("mta"), "INSERT INTO characters_faction SET faction_leader = 0, faction_id = ?, faction_rank = ?, faction_phone = NULL, character_id=?", factionID, defaultRank, getElementData(targetPlayer, "dbid")) then
					local max = 0
					for id, _ in pairs(factionInfo) do
						if not max then max = _.count end
						if _.count >= max then
							max = _.count
						end
					end

					factionInfo[factionID] = { rank = defaultRank, leader = false, phone = nil, perks = { }, count = max+1 }
					exports.anticheat:changeProtectedElementDataEx(targetPlayer, "faction", factionInfo, true)

					triggerEvent("duty:offduty", targetPlayer)
					outputChatBox("Player " .. targetPlayerNick .. " is now a member of faction '" .. getTeamName(theTeam) .. "' (#" .. factionID .. ").", thePlayer, 0, 255, 0)
					triggerEvent("onPlayerJoinFaction", targetPlayer, theTeam)
					outputChatBox("You were set to Faction '" .. getTeamName(theTeam) .. "'.", targetPlayer, 255, 194, 14)
					exports.logs:dbLog(thePlayer, 4, { targetPlayer, theTeam }, "SET TO FACTION")
				end
			end
		end
	end
end
addCommandHandler("setfaction", adminSetPlayerFaction, false, false)

function adminRemovePlayerFaction(thePlayer, commandName, partialNick, factionID)
	if exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerFMTLeader(thePlayer) then
		factionID = tonumber(factionID)
		if not (partialNick) or not (factionID) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Name/ID] [Faction ID]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerNick = exports.global:findPlayerByPartialNick(thePlayer, partialNick)

			if targetPlayer then
				local theTeam = exports.pool:getElement("team", factionID)
				if not theTeam and factionID ~= -1 then
					outputChatBox("Invalid Faction ID.", thePlayer, 255, 0, 0)
					return
				end

				if dbExec(exports.mysql:getConn("mta"), "DELETE FROM characters_faction WHERE faction_id=? AND character_id=?", factionID, getElementData(targetPlayer, "dbid")) then
					local factionInfo = getElementData(targetPlayer, "faction")
					local organizedTable = {}

					for i, k in pairs(factionInfo) do
						organizedTable[k.count] = i
					end

					local found = false
					for k,v in ipairs(organizedTable) do
						if v == factionID then
							found = true
						end

						if found then
							factionInfo[v].count = factionInfo[v].count - 1
						end
					end

					factionInfo[factionID] = nil
					exports.anticheat:changeProtectedElementDataEx(targetPlayer, "faction", factionInfo, true)

					if getElementData(targetPlayer, "duty") and getElementData(targetPlayer, "duty") > 0 then
						takeAllWeapons(targetPlayer)
						exports.anticheat:changeProtectedElementDataEx(targetPlayer, "duty", 0, true)
					end

					outputChatBox("Player " .. targetPlayerNick .. " was removed from faction "..factionID, thePlayer, 0, 255, 0)
					outputChatBox("You were removed from faction #"..factionID, targetPlayer, 255, 0, 0)

					exports.logs:dbLog(thePlayer, 4, { targetPlayer, theTeam }, "REMOVE FROM FACTION "..factionID)
				end
			end
		end
	end
end
addCommandHandler("removefaction", adminRemovePlayerFaction, false, false)

function adminSetFactionLeader(thePlayer, commandName, partialNick, factionID)
	if exports.integration:isPlayerAdmin(thePlayer) or exports.integration:isPlayerFMTLeader(thePlayer) then
		factionID = tonumber(factionID)
		if not (partialNick) or not (factionID)  then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Name] [Faction ID]", thePlayer, 255, 194, 14)
		elseif factionID > 0 then
			local targetPlayer, targetPlayerNick = exports.global:findPlayerByPartialNick(thePlayer, partialNick)

			if targetPlayer then
				local theRank = getLeaderRank(factionID)
				local theTeam = exports.pool:getElement("team", factionID)
				if not theTeam then
					outputChatBox("Invalid Faction ID.", thePlayer, 255, 0, 0)
					return
				elseif isPlayerInFaction(targetPlayer, factionID) then
					outputChatBox("Player is already a member of this faction, this command sets them to the faction with leader.", thePlayer, 255, 0, 0)
					return
				end

				local factionInfo = getElementData(targetPlayer, "faction") or {}
				local num_factions = exports.global:countTable(factionInfo)
				if num_factions >= 5 then
					outputChatBox("This player is already in the maximum amount of factions.", thePlayer, 255, 0, 0)
					return
				end

				if dbExec(exports.mysql:getConn("mta"), "INSERT INTO characters_faction SET faction_leader = 1, faction_id = ?, faction_rank = ?, faction_phone = NULL, character_id=?", factionID, theRank, getElementData(targetPlayer, "dbid")) then

					local max = 0
					for id, _ in pairs(factionInfo) do
						if not max then max = _.count end
						if _.count >= max then
							max = _.count
						end
					end
					factionInfo[factionID] = { rank = theRank, leader = true, phone = nil, perks = { }, count = max+1 }
					exports.anticheat:changeProtectedElementDataEx(targetPlayer, "faction", factionInfo, true)

					triggerEvent("duty:offduty", targetPlayer)

					outputChatBox("Player " .. targetPlayerNick .. " is now a leader of faction '" .. getTeamName(theTeam) .. "' (#" .. factionID .. ").", thePlayer, 0, 255, 0)

					triggerEvent("onPlayerJoinFaction", targetPlayer, theTeam)
					outputChatBox("You were set to the leader of Faction '" .. getTeamName(theTeam) .. "'.", targetPlayer, 255, 194, 14)

					exports.logs:dbLog(thePlayer, 4, { targetPlayer, theTeam }, "SET INTO FACTION LEADER")
					exports.factions:sendNotiToAllFactionMembers(factionID, targetPlayerNick .. " is now a leader of your faction '" .. getTeamName(theTeam) .. "'", "Set by "..exports.global:getPlayerFullIdentity(thePlayer))
				else
					outputChatBox("Invalid Faction ID.", thePlayer, 255, 0, 0)
				end
			end
		end
	end
end
addCommandHandler("setfactionleader", adminSetFactionLeader, false, false)

function adminSetFactionRank(thePlayer, commandName, partialNick, factionID, ...)
	if (exports.integration:isPlayerAdmin(thePlayer)) then
		factionID = tonumber(factionID)
		if not (partialNick) or not (...)  then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Name] [Faction ID] [Faction Rank, 1-20]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerNick = exports.global:findPlayerByPartialNick(thePlayer, partialNick)
			local rankName = table.concat({...}, " ")
			local rankID = getRankIDbyName(factionID, rankName)
			if targetPlayer then
				local theTeam = exports.pool:getElement("team", factionID)
				if not isPlayerInFaction(targetPlayer, factionID) then
					outputChatBox("Player is not in this faction.", thePlayer, 255, 0, 0)
					return
				end

				if dbExec(exports.mysql:getConn("mta"), "UPDATE characters_faction SET faction_rank =? WHERE character_id = ? AND faction_id=?", rankID, getElementData(targetPlayer, "dbid"), factionID) then
					local factionInfo = getElementData(targetPlayer, "faction")
					factionInfo[factionID].rank = rankID
					exports.anticheat:changeProtectedElementDataEx(targetPlayer, "faction", factionInfo, true)

					outputChatBox("Player " .. targetPlayerNick .. " is now rank " .. rankName .. ".", thePlayer, 0, 255, 0)
					outputChatBox("Admin " .. getPlayerName(thePlayer):gsub("_"," ") .. " set you to rank " .. rankName .. " in faction #"..factionID..".", targetPlayer, 0, 255, 0)

					exports.logs:dbLog(thePlayer, 4, { targetPlayer, theTeam }, "SET TO FACTION RANK " .. rankName)
				else
					outputChatBox("Error #125151 - Report on Mantis.", thePlayer, 255, 0, 0)
				end
			end
		end
	end
end
addCommandHandler("setfactionrank", adminSetFactionRank, false, false)

function setFactionMoney(thePlayer, commandName, factionID, amount)
	if (exports.integration:isPlayerLeadAdmin(thePlayer)) then
		if not (factionID) or not (amount)  then
			outputChatBox("SYNTAX: /" .. commandName .. " [Faction ID] [Money]", thePlayer, 255, 194, 14)
		else
			factionID = tonumber(factionID)
			if factionID and factionID > 0 then
				local theTeam = exports.pool:getElement("team", factionID)
				amount = tonumber(amount) or 0
				if amount and amount > 500000*2 then
					outputChatBox("For security reason, you're not allowed to set more than $1,000,000 at once to a faction.", thePlayer, 255, 0, 0)
					return false
				end

				if (theTeam) then
					if exports.global:setMoney(theTeam, amount) then
						outputChatBox("Set faction '" .. getTeamName(theTeam) .. "'s money to " .. amount .. " $.", thePlayer, 255, 194, 14)
						exports.factions:sendNotiToAllFactionMembers(factionID, "'"..getTeamName(theTeam).."' faction bank updated", exports.global:getPlayerFullIdentity(thePlayer, 1).." has set the bank to $"..exports.global:formatMoney(amount)..".", nil, true)
					else
						outputChatBox("Could not set money to that faction.", thePlayer, 255, 194, 14)
					end
				else
					outputChatBox("Invalid faction ID.", thePlayer, 255, 194, 14)
				end
			else
				outputChatBox("Invalid faction ID.", thePlayer, 255, 194, 14)
			end
		end
	end
end
addCommandHandler("setfactionmoney", setFactionMoney, false, false)


-----

function loadWelfare( )
	local result = exports.mysql:query_fetch_assoc( "SELECT value FROM settings WHERE name = 'welfare'" )
	if result then
		if not result.value then
			mysql:query_free( "INSERT INTO settings (name, value) VALUES ('welfare', " .. unemployedPay .. ")" )
		else
			unemployedPay = tonumber( result.value ) or 150
		end
	end
	adminDutyStart()
end
addEventHandler( "onResourceStart", resourceRoot, loadWelfare )

function getTax(thePlayer)
	loadWelfare( )
	outputChatBox( "Welfare: $" .. exports.global:formatMoney(unemployedPay), thePlayer, 255, 194, 14 )
	outputChatBox( "Tax: " .. ( exports.global:getTaxAmount(thePlayer) * 100 ) .. "%", thePlayer, 255, 194, 14 )
	outputChatBox( "Income Tax: " .. ( exports.global:getIncomeTaxAmount(thePlayer) * 100 ) .. "%", thePlayer, 255, 194, 14 )
end
addCommandHandler("gettax", getTax, false, false)

function setFactionBudget(thePlayer, commandName, factionID, amount)
	local isInFaction, rank = isPlayerInFaction(thePlayer, 3)
	if isInFaction and rank >= 15 then
		local amount = tonumber( amount )
		if not factionID or not amount or amount < 0 then
			outputChatBox("SYNTAX: /" .. commandName .. " [Faction ID] [Money]", thePlayer, 255, 194, 14)
		else
			factionID = tonumber(factionID)
			if factionID and factionID > 0 then
				local theTeam = exports.pool:getElement("team", factionID)
				amount = tonumber(amount)

				if (theTeam) then
					if getElementData(theTeam, "type") >= 2 and getElementData(theTeam, "type") <= 6 then
						if exports.global:takeMoney(getFactionFromName("Government of Los Santos"), amount) then
							exports.global:giveMoney(theTeam, amount)
							outputChatBox("You added $" .. exports.global:formatMoney(amount) .. " to the budget of '" .. getTeamName(theTeam) .. "' (Total: " .. exports.global:getMoney(theTeam) .. ").", thePlayer, 255, 194, 14)
							mysql:query_free( "INSERT INTO wiretransfers (`from`, `to`, `amount`, `reason`, `type`) VALUES (" .. -3 .. ", " .. -getElementData(theTeam, "id") .. ", " .. amount .. ", '', 8)" )
						else
							outputChatBox("You can't afford this.", thePlayer, 255, 194, 14)
						end
					else
						outputChatBox("You can't set a budget for that faction.", thePlayer, 255, 194, 14)
					end
				else
					outputChatBox("Invalid faction ID.", thePlayer, 255, 194, 14)
				end
			else
				outputChatBox("Invalid faction ID.", thePlayer, 255, 194, 14)
			end
		end
	end
end
addCommandHandler("setbudget", setFactionBudget, false, false)

function setTax(thePlayer, commandName, amount)
	local isInFaction, rank = isPlayerInFaction(thePlayer, 3)
	if isInFaction and rank >= 15 then
		local amount = tonumber( amount )
		if not amount or amount < 0 or amount > 30 then
			outputChatBox("SYNTAX: /" .. commandName .. " [0-30%]", thePlayer, 255, 194, 14)
		else
			exports.global:setTaxAmount(amount)
			outputChatBox("New Tax is " .. amount .. "%", thePlayer, 0, 255, 0)
		end
	end
end
addCommandHandler("settax", setTax, false, false)

function setIncomeTax(thePlayer, commandName, amount)
	local isInFaction, rank = isPlayerInFaction(thePlayer, 3)
	if isInFaction and rank >= 15 then
		local amount = tonumber( amount )
		if not amount or amount < 0 or amount > 25 then
			outputChatBox("SYNTAX: /" .. commandName .. " [0-25%]", thePlayer, 255, 194, 14)
		else
			exports.global:setIncomeTaxAmount(amount)
			outputChatBox("New Income Tax is " .. amount .. "%", thePlayer, 0, 255, 0)
		end
	end
end
addCommandHandler("setincometax", setIncomeTax, false, false)

function setWelfare(thePlayer, commandName, amount)
	local isInFaction, rank = isPlayerInFaction(thePlayer, 3)
	if isInFaction and rank >= 15 then
		local amount = tonumber( amount )
		if not amount or amount <= 0 then
			outputChatBox("SYNTAX: /" .. commandName .. " [Money]", thePlayer, 255, 194, 14)
		elseif mysql:query_free( "UPDATE settings SET value = " .. unemployedPay .. " WHERE name = 'welfare'" ) then
			unemployedPay = amount
			outputChatBox("New Welfare is $" .. exports.global:formatMoney(unemployedPay) .. "/payday", thePlayer, 0, 255, 0)
		else
			outputChatBox("Error 129314 - Report on Mantis.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("setwelfare", setWelfare, false, false)

function issueGovLicense(thePlayer, commandName, type, ...)
	local licenseTypes = {"Business License - Regular", "Business License - Premium", "Adult Entertainment License", "Gambling License", "Liquor License"}
	local isInFaction, rank = isPlayerInFaction(thePlayer, 3)
	if isInFaction and rank >= 3 then
		local type = tonumber(type)
		if not type or not licenseTypes[type] or not ... then
			outputChatBox("SYNTAX: /" .. commandName .. " [type] [biz name]", thePlayer, 255, 194, 14)
			for k, v in ipairs(licenseTypes) do
			outputChatBox("  " .. k .. ": " .. v, thePlayer, 255, 194, 14)
			end
		else
			local text = licenseTypes[type] .. " - " .. table.concat({...}, " ")
			local success, error = exports.global:giveItem(thePlayer, 80, text)
			if success then
				outputChatBox("Created a " .. text .. ".", thePlayer, 0, 255, 0)
			else
				outputChatBox(error, thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("govlicense", issueGovLicense, false, false)

--

function respawnFactionVehicles(thePlayer, commandName, factionID)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		local factionID = tonumber(factionID)
		if (factionID) and (factionID > 0) then
			local theTeam = exports.pool:getElement("team", factionID)
			if (theTeam) then
				for key, value in ipairs(exports.pool:getPoolElementsByType("vehicle")) do
					local faction = tonumber(getElementData(value, "faction"))
					if (faction == factionID and not getVehicleOccupant(value, 0) and not getVehicleOccupant(value, 1) and not getVehicleOccupant(value, 2) and not getVehicleOccupant(value, 3) and not getVehicleTowingVehicle(value)) then
						respawnVehicle(value)
						setElementInterior(value, getElementData(value, "interior"))
						setElementDimension(value, getElementData(value, "dimension"))
					end
				end

				local hiddenAdmin = tonumber(getElementData(thePlayer, "hiddenadmin"))
				local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
				local username = getPlayerName(thePlayer):gsub("_"," ")

				for k,v in ipairs(getPlayersInFaction(factionID)) do
					outputChatBox((hiddenAdmin == 0 and adminTitle .. " " .. username or "Hidden Admin") .. " respawned all unoccupied faction vehicles.", v)
				end

				exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. username .. " respawned all unoccupied faction vehicles for faction ID " .. factionID .. ".")
				exports.logs:dbLog(thePlayer, 4, theTeam, "FACTION RESPAWN for " .. factionID)
			else
				outputChatBox("Invalid faction ID.", thePlayer, 255, 0, 0, false)
			end
		else
			outputChatBox("SYNTAX: /" .. commandName .. " [Faction ID]", thePlayer, 255, 194, 14, false)
		end
	end
end
addCommandHandler("respawnfaction", respawnFactionVehicles, false, false)

-- // Chaos - Script stealers go away, make something for yourself.
function adminDutyStart()
	local result = mysql:query("SELECT id, name FROM factions WHERE type >= 2 ORDER BY id ASC")
	local max = mysql:query("SELECT id FROM duty_allowed ORDER BY id DESC LIMIT 0, 1")
	if result and max then
		local maxrow = mysql:fetch_assoc(max)
		maxIndex = type(maxrow) == 'table' and tonumber(maxrow.id) or 0

		while true do
			local row = mysql:fetch_assoc(result)
			if not row then break end

			dutyAllow[tonumber(row.id)] = { row.id, row.name, { --[[Duty information]] } }
			--table.insert(dutyAllow, { row.id, row.name, { --[[Duty information]] } })
			--i = i+1

			local result1 = mysql:query("SELECT * FROM duty_allowed WHERE faction="..tonumber(row.id))
			if result1 then
				while true do
					local row1 = mysql:fetch_assoc(result1)
					if not row1 then break end

					table.insert(dutyAllow[tonumber(row.id)][3], { row1.id, tonumber(row1.itemID), row1.itemValue })
				end
			end
		end

		setElementData(resourceRoot, "maxIndex", maxIndex)
		setElementData(resourceRoot, "dutyAllowTable", dutyAllow)
		mysql:free_result(result)
		mysql:free_result(result1)
		mysql:free_result(max)
	else
		outputDebugString("[Factions] ERROR: Duty allow permissions failed.")
	end
end
--addEventHandler("onResourceStart", resourceRoot, adminDutyStart)

function getAllowList(factionID)
	local factionID = tonumber(factionID)
	if factionID and dutyAllow[factionID] then
		return dutyAllow[factionID][3]
	end

	return {}
end

function adminDuty(thePlayer)
	if (exports.integration:isPlayerLeadAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) or exports.integration:isPlayerFMTLeader(thePlayer)) then
		if not getElementData(resourceRoot, "dutyadmin") and type(dutyAllow) == "table" then
			triggerClientEvent(thePlayer, "adminDutyAllow", resourceRoot, dutyAllow, dutyAllowChanges)
			setElementData( resourceRoot, "dutyadmin", true )
		elseif type(dutyAllow) ~= "table" then
			outputChatBox("There was a issue with the startup caching of this resource. Contact a Scripter.", thePlayer, 255, 0, 0)
		else
			outputChatBox("Oops! Someone is already editing duty permissions. Sorry!", thePlayer, 255, 0, 0) -- No time to set up proper syncing + kinda not needed.
		end
	end
end
addCommandHandler("dutyadmin", adminDuty, false, false)

function saveChanges()
	outputDebugString("[Factions] Saving duty allow changes...")
	local tick = getTickCount()

	for key,value in pairs(dutyAllowChanges) do
		if value[2] == 0 then -- Delete row
			mysql:query_free("DELETE FROM duty_allowed WHERE id="..mysql:escape_string(tonumber(value[3])))
		elseif value[2] == 1 then
			mysql:query_free("INSERT INTO duty_allowed SET id="..mysql:escape_string(tonumber(value[3]))..", faction="..mysql:escape_string(tonumber(value[1]))..", itemID="..mysql:escape_string(tonumber(value[4]))..", itemValue='"..mysql:escape_string(value[5]).."'")
		end
	end

	outputDebugString("[Factions] Completed in ".. math.floor((getTickCount()-tick)/60) .." seconds.")
end
addEventHandler("onResourceStop", resourceRoot, saveChanges)

function updateTable(newTable, changesTable)
	dutyAllow = newTable
	dutyAllowChanges = changesTable
	removeElementData(resourceRoot, "dutyadmin")
	setElementData(resourceRoot, "dutyAllowTable", dutyAllow)
	exports.logs:dbLog(client, 4, client, "Has saved /dutyadmin")
end
addEvent("dutyAdmin:Save", true)
addEventHandler("dutyAdmin:Save", resourceRoot, updateTable)

-- Cleanup/convert functions, pretty much a 1 use only as they are now deprecated.

function convert(player)
	if not exports.integration:isPlayerScripter(player) then return end
	local qh = dbQuery(
		function(qh)
			local result, num_affected_rows, last_insert_id = dbPoll ( qh, 0 )
			if result then
				for k,row in pairs(result) do
					if row.faction_id ~= -1 then
						dbExec(exports.mysql:getConn("mta"), "INSERT INTO characters_faction SET character_id=?, faction_id=?, faction_rank=?, faction_leader=?, faction_phone=?, faction_perks=?", row.id, row.faction_id, row.faction_rank, row.faction_leader, row.faction_phone, row.faction_perks, row.id)
					end
				end
			end
	end, exports.mysql:getConn("mta"), "SELECT faction_id, faction_rank, faction_leader, faction_phone, faction_perks, id FROM characters")
end
addCommandHandler( "convertFactions", convert )

function startDeleteProcess(start)
	allowedCount = 0
	local qh = dbQuery(
	function(qh)
		local result, num_affected_rows, last_insert_id = dbPoll ( qh, 0 )
		if result then
			for k,row in pairs(result) do
				if not start[row.faction] then
					dbExec(exports.mysql:getConn("mta"), "DELETE FROM duty_allowed WHERE id=?", row.id)
					outputDebugString("DELETE FROM duty_allowed FACTION "..row.faction)
					allowedCount = allowedCount + 1
				end
			end
			outputDebugString("DONE! Removed from duty_allowed "..allowedCount.." rows.")
		end
	end, exports.mysql:getConn("mta"), "SELECT * FROM duty_allowed")

	customCount = 0
	local qh = dbQuery(
	function(qh)
		local result, num_affected_rows, last_insert_id = dbPoll ( qh, 0 )
		if result then
			for k,row in pairs(result) do
				if not start[row.factionid] then
					dbExec(exports.mysql:getConn("mta"), "DELETE FROM duty_custom WHERE id=?", row.id)
					outputDebugString("DELETE FROM duty_custom FACTION "..row.factionid)
					customCount = customCount + 1
				end
			end
			outputDebugString("DONE! Removed from duty_custom "..customCount.." rows.")
		end
	end, exports.mysql:getConn("mta"), "SELECT * FROM duty_custom")

	customLocation = 0
	local qh = dbQuery(
	function(qh)
		local result, num_affected_rows, last_insert_id = dbPoll ( qh, 0 )
		if result then
			for k,row in pairs(result) do
				if not start[row.factionid] then
					dbExec(exports.mysql:getConn("mta"), "DELETE FROM duty_locations WHERE id=?", row.id)
					outputDebugString("DELETE FROM duty_locations FACTION "..row.factionid)
					customLocation = customLocation + 1
				end
			end
			outputDebugString("DONE! Removed from duty_locations "..customLocation.." rows.")
		end
	end, exports.mysql:getConn("mta"), "SELECT * FROM duty_locations")
end

function cleanupDuty(player)
	if not exports.integration:isPlayerScripter(player) then return end
	start = {}
	local qh = dbQuery(
	function(qh)
		local result, num_affected_rows, last_insert_id = dbPoll ( qh, 0 )
		if result then
			for k,row in pairs(result) do
				start[row.id] = true
			end
			startDeleteProcess(start)
		end
	end, exports.mysql:getConn("mta"), "SELECT * FROM factions")
end
addCommandHandler("cleanupDuty", cleanupDuty)

--[[function convertFactionRanks(query)
	-- define the variables based on which items we're converting, either world or inventory
	local idRow = "id"
	local factionID = "faction_id"
	local factionRank = "faction_rank"
	local factionLeader = "faction_leader"
	local queryStr = "SELECT `"..idRow.."`, `"..factionID.."`, `"..factionRank.."`, `"..factionLeader.."` FROM characters_faction"
	local updateStr = "UPDATE characters_faction SET "..factionRank.." = ? WHERE "..idRow.." = ?"
	
	outputDebugString("[FACTIONS] Converting all faction ranks in the Faction system ...")
	
	oldFactionRanks = {}
	if query then
        local pollResult = dbPoll(query, 0)
        if not pollResult then 
            dbFree(query) 
            return 
		else
			for i, row in pairs(pollResult) do
				local oldFID = row["id"]
				oldFactionRanks[oldFID] = {}
				for v=1,20 do
					table.insert(oldFactionRanks[oldFID], {v, row["rank_" .. v]})
				end
            end
		end
	end	

	local counter = 0
	dbQuery(function(qh)
		local res, rows, err = dbPoll(qh,0)
		if rows > 0 then
			for _, row in pairs(res) do
				if row then
					local fID = tonumber(row["faction_id"])
					if not fID and type(fID) ~= "number" then return end

					local rankID = 0
					for i,rID in ipairs(getFactionRanks(fID)) do
						local rankName = getRankName(rID)
						local oldRank = tonumber(row["faction_rank"])
						for a,b in pairs(oldFactionRanks[fID]) do
							if rankName == b[2] and oldRank == b[1] then
								rankID = rID
							end	
						end	
					end		

					if rankID ~= 0 then
						counter = counter + 1
						dbExec(mysql:getConn('mta'), updateStr, rankID, row["id"])
					end	
				end
			end
			
			outputDebugString("[Factions] " .. counter .. " ranks have been converted.")
			setTimer(restartResource, 30000, 1, getResourceFromName("factions"))
		end
	end, mysql:getConn('mta'), queryStr)
end

function commandConvertFactionRanks(player, cmd)
	if exports.integration:isPlayerScripter(player) then
		local seconds = 30
		outputChatBox(" WARNING: Large script execution will take place in " .. seconds .. " seconds, it will cause major delays for a few minutes.", root, 255, 0, 0)
		setElementData(getResourceRootElement(getThisResource()), "debug_enabled", true, true)
		setTimer(function() dbQuery(convertFactionRanks, mysql:getConn("mta"), "SELECT `id`, `rank_1`, `rank_2`, `rank_3`, `rank_4`, `rank_5`, `rank_6`, `rank_7`, `rank_8`, `rank_9`, `rank_10`, `rank_11`, `rank_12`, `rank_13`, `rank_14`, `rank_15`, `rank_16`, `rank_17`, `rank_18`, `rank_19`, `rank_20` FROM `factions`") end, seconds*1000, 1)
	end
end
addCommandHandler("convertfactionranks", commandConvertFactionRanks)--]]

--[[addCommandHandler("fixfactions", function(thePlayer)
	if not exports.integration:isPlayerScripter(thePlayer) then 
		return 
	end

	local seconds = 30
	outputChatBox(" WARNING: Large script execution will take place in " .. seconds .. " seconds, it will cause major delays for a few minutes.", root, 255, 0, 0)
	setElementData(getResourceRootElement(getThisResource()), "debug_enabled", true, true)
	setTimer(function()
		dbQuery(processBrokenRanks, exports.mysql:getConn("mta"), "SELECT * FROM faction_ranks")
	end, seconds * 1000, 1)
end)

function processBrokenRanks(qh)
	local result = dbPoll(qh, 0)
	local ranks = {}
	for _, rows in ipairs(result) do 
		table.insert(ranks, rows['id'], rows['faction_id'])
	end

	dbQuery(
		function(query)
			local res = dbPoll(query, 0)
			for _, rows in ipairs(res) do 
				if not ranks[rows['faction_rank'] ] then 
					dbExec(exports.mysql:getConn("mta"), "UPDATE characters_faction SET faction_rank = ? WHERE faction_rank = ? AND faction_id = ? AND character_id = ?", getDefaultRank(rows['faction_id']), rows['faction_rank'], rows['faction_id'], rows['character_id'])
				end
			end

			outputDebugString("[Factions] Rank fixer has completed its journey.")
			setTimer(restartResource, 30000, 1, getResourceFromName("factions"))
		end, 
	exports.mysql:getConn("mta"), "SELECT * FROM characters_faction")
end--]]