--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

function canAccessFactionManager( player )
	return exports.integration:isPlayerTrialAdmin( player ) or exports.integration:isPlayerSupporter( player ) or exports.integration:isPlayerScripter( player ) or exports.integration:isPlayerFMTMember( player )
end

local factionTypes = {
	['0'] = "Gang",
	['1'] = "Mafia",
	['2'] = "Law",
	['3'] = "Government",
	['4'] = "Medical",
	['5'] = "Other",
	['6'] = "News",
	['7'] = "Dealership"
}

function getFactionTypes( type )
	return type and factionTypes[ tostring( type ) ] or factionTypes
end

function isPlayerInFaction(thePlayer, factionID) --returns isMember, rankID, amLeader
	if not thePlayer or not factionID then return false end
	factionID = tonumber(factionID) or -1
	local faction = getElementData(thePlayer, "faction") or {}
	local faction = faction[factionID]
	if faction then
		return true, faction.rank, faction.leader
	end
	return false
end

function getPlayerFactionRank(thePlayer, factionID) --returns rank if member of factionID, false otherwise
	if not thePlayer or not factionID then return false end
	factionID = tonumber(factionID) or -1
	local faction = getElementData(thePlayer, "faction") or {}
	local faction = faction[factionID]
	if faction then
		return faction.rank
	end
	return false
end

function isPlayerFactionLeader(thePlayer, factionID) --returns boolean
	if not thePlayer or not factionID then return false end
	factionID = tonumber(factionID) or -1
	local faction = getElementData(thePlayer, "faction") or {}
	local faction = faction[factionID]
	if faction then
		return faction.leader
	end
	return false
end

function getFactionFromName(name)
	if not tostring(name) then
		return false
	end
	local faction = getTeamFromName(name)
	return faction
end

function getFactionType(factionID)
	local theTeam = getFactionFromID(factionID)
	if theTeam then
		local ftype = tonumber(getElementData(theTeam, "type"))
		if ftype then
			return ftype
		end
	end
	return false
end

function getFactionName(factionID)
	local theTeam = getFactionFromID(factionID)
	if theTeam then
		local name = getTeamName(theTeam)
		if name then
			name = tostring(name)
			return name
		end
	end
	return false
end

function getFactionIDFromName(factionName)
	local theTeam = getFactionFromName(factionName)
	if theTeam then
		local id = tonumber(getElementData(theTeam, "id"))
		if id then
			return id
		end
	end
	return false
end

function isInFactionType(element, ftype)
	if not getElementData(element, "faction") then return end
	for k,v in pairs(getElementData(element, "faction")) do
		local team = getFactionFromID(k)
		if team then
			local teamType = getElementData(team, "type")
			if ftype == teamType then
				return true
			end
		end
	end
	return false
end

function getPlayerFactionTypes(element)
	if not getElementData(element, "faction") then return end
	local table = {}
	for k,v in pairs(getElementData(element, "faction")) do
		local team = getFactionFromID(k)
		if team then
			local teamType = getElementData(team, "type")
			if table[teamType] then
				table[teamType][getElementData(team, "id")] = team
			else
				table[teamType] = { [getElementData(team, "id")] = team }
			end
		end
	end
	return table
end

function getCurrentFactionDuty(element)
	local playerFaction = getElementData(element, "faction") or {}
	local duty = getElementData(element, "duty") or 0
	local foundPackage = false
    if duty > 0 then
        for k,v in pairs(playerFaction) do
            for key, element in ipairs(v.perks) do
                if tonumber(element) == tonumber(duty) then
                    foundPackage = k
                    break
                end
            end
        end
    end
    return foundPackage
end

function getFactionFromID( factionID )
	if not tonumber(factionID) then
		return false
	end
	if triggerServerEvent then -- if called from client.
		for i, team in pairs( getElementsByType( 'team' ) ) do
			if getElementData( team, 'id' ) == tonumber( factionID ) then
				return team
			end
		end
	else -- server.
		return exports.pool:getElement("team", tonumber(factionID))
	end
end
