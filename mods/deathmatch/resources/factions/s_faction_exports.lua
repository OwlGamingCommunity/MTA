--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

--[[function getFactionFromName(factionName)
	for k,v in ipairs(exports.pool:getPoolElementsByType("team")) do
		if string.lower(getTeamName(v)) == string.lower(factionName) then
			return v
		end
	end
	return false
end]]

function getFactionFromID(factionID)
	if not tonumber(factionID) then
		return false
	end
	return exports.pool:getElement("team", tonumber(factionID))
end

function getPlayersInFaction(factionID, leaderOnly)
	users = {}
	local factionID = tonumber(factionID)
	for k,v in ipairs(exports.pool:getPoolElementsByType("player")) do
		local f = getElementData(v, "faction") or {}
		if f[factionID] then
			f = f[factionID]
			if leaderOnly and f.leader then
				table.insert(users, v)
			elseif not leaderOnly then
				table.insert(users, v)
			end
		end
	end

	return users
end

function sendNotiToAllFactionMembers(fId, title, details, leaderOnly)
	local told = {} -- If you have 2 characters in the same faction you'd get two notifications. This is just a small fix to stop that.
	dbQuery( function( qh )
		local result, num_rows = dbPoll( qh, 0 )
		if result and num_rows > 0 then
			for i, member in ipairs( result ) do
				if not told[member.aid] then
					exports.announcement:makePlayerNotification(member.aid, title, details, 'noti_faction_updates')
					told[member.aid] = true
				end
			end
		end
	end, exports.mysql:getConn("mta"), "SELECT c.account AS aid, c.id AS cid, charactername FROM characters_faction cf LEFT JOIN characters c ON cf.character_id = c.id WHERE "..(leaderOnly and "cf.faction_leader=1 AND " or "").." cf.faction_id =? ORDER BY (aid) " , fId )
end

-- returns stateid, {[factionid] = {factionrank, factionleader, table with factionperks}, element of player if applicable
-- stateid 0: Online, stateid 1: Offline, stateid 2: Not found
function getPlayerFactions(playerName)
	local thePlayerElement = getPlayerFromName(playerName)
	local override = false
	if (thePlayerElement) then -- Player is online
		if (getElementData(thePlayerElement, "loggedin") ~= 1) then
			override = true
		else
			local playerFaction = getElementData(thePlayerElement, "faction")

			return 0, playerFaction, thePlayerElement
		end
	end

	if (not thePlayerElement or override) then  -- Player is offline
		local q = dbQuery(exports.mysql:getConn("mta"), "SELECT faction_id, faction_rank, faction_perks, cf.faction_leader FROM characters c LEFT JOIN characters_faction cf ON c.id=cf.character_id LEFT JOIN factions f ON cf.faction_id=f.id WHERE c.id IS NOT NULL AND cf.id IS NOT NULL AND f.id IS NOT NULL AND charactername=?", playerName)
		local result, num_rows = dbPoll(q, 10000)

		if not result then dbFree(q) return 2, {} end
		if result and num_rows > 0 then
			return 1, result, nil
		end
	end

	return 2, -1, 20, 0, { }, nil -- Player was not found
end

--- fetches the phone number prefixes assigned to all factions
-- this is [factionID] = number for all entries
function getAllFactionPhoneNumbers()
	local phones = {}
	for _, theTeam in ipairs(exports.pool:getPoolElementsByType("team")) do
		local factionId = getElementData(theTeam, "id")
		local phone = getElementData(theTeam, "phone")
		if factionId and phone then
			phones[factionId] = phone
		end
	end
	return phones
end
