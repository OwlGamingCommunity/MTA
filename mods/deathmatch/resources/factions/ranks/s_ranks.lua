FactionRanks = {}	
RanksByFaction = {}


function getRankInfo(factionID, player)
	if (not client) then client = player end
	local fID = tonumber(factionID)
	local ranks_ = getFactionRanks(fID, true)
	local ranks = {}			-- Ranks Table
	local rank_perms = {}		-- Permissions by Rank
	local wages = {}

	for i,rankID in ipairs(ranks_) do
		local rankName = getRankName(tonumber(rankID))
		table.insert(ranks, {rankID, rankName})
		
		local wage = getFactionRankData(rankID, "wage")
		if wage then
			wages[rankID] = wage
		end	

		rank_perms[rankID] = getAllRankPermissions(rankID)
	end
	local permissions_ = getFactionPermissions(fID)
	local permissions = {}
	for i,perm in ipairs(permissions_) do
		table.insert(permissions, perm[2])
	end
	triggerClientEvent(client, "faction-system.setRankInfo", resourceRoot, ranks, rank_perms, permissions, wages)
end
addEvent("faction-system.getRankInfo", true)
addEventHandler("faction-system.getRankInfo", root, getRankInfo)

-- Add Faction Rank
------------------>>

addEvent("faction-system.addFactionRank", true)
addEventHandler("faction-system.addFactionRank", root, function(rank, perms, factionID)
	local fID = tonumber(factionID)
		-- Check for Same Rank Name
	for i,rankID in ipairs(getFactionRanks(fID)) do
		local rankName = getRankName(rankID)
		if (rankName == rank) then
			outputChatBox("A rank with this name already exists. Choose another rank name.", client, 255, 100, 100)
			return
		end
	end
	
	local rank_perms = getAllRankPermissions(perms, true) or {}
	addFactionRank(fID, rank, rank_perms, client)
	getRankInfo(fID, client)
	outputChatBox("Faction rank '"..rank.."' has been successfully created.", client, 255, 100, 100)
	triggerClientEvent(client, "faction-system.closeAddFactionRankPanel", resourceRoot)
end)


-- Add Faction Rank
------------------>>

function addFactionRank(FactionID, rankName, permissions, plr)
	local rank_perms = getAllRankPermissions(perms, true) or {}
	-- Add Permissions Set
	if (type(permissions) ~= "table") then
		permissions = getDefaultPermissionSet("New Member")
	end
	permissions = table.concat(permissions, ",") or ""
	local qh = dbQuery(exports.mysql:getConn("mta"),"INSERT INTO `faction_ranks` (`faction_id`, `name`, `permissions`) VALUES ('"..FactionID.."','"..rankName.."','"..permissions.."')")
	local res, num, rID = dbPoll(qh, 10000)

	local rankID = tonumber(rID)
		-- Rank by Faction Association
	if not (RanksByFaction[FactionID]) then RanksByFaction[FactionID] = {} end
	table.insert(RanksByFaction[FactionID], rankID)
	if not FactionRanks[rankID] then FactionRanks[rankID] = {} end
	FactionRanks[rankID]["name"] = rankName
	FactionRanks[rankID]["permissions"] = permissions
	FactionRanks[rankID]["isDefault"] = "0"
	FactionRanks[rankID]["isLeader"] = "0"
	FactionRanks[rankID]["faction_id"] = FactionID
	local factionRanks = {}
	factionRanks[rankID] = rankName
	local theTeam = getFactionFromID(FactionID)
	for i,v in pairs(getElementData(theTeam, "ranks")) do
		factionRanks[i] = v
	end	
	
	local rankOrder = getElementData(theTeam, "rank_order")
	if rankOrder then
		local newOrder = rankOrder..","..rankID
		exports.anticheat:setEld(theTeam, "rank_order", newOrder, 'all') 
		dbExec(exports.mysql:getConn("mta"), "UPDATE `factions` SET `rank_order` = '"..newOrder.."' WHERE `id` = "..FactionID)
	end
	exports.anticheat:setEld(theTeam, "ranks", factionRanks, 'all')
	triggerClientEvent("faction-system.cacheRanks", client, FactionRanks)
	return true
end

-- Call Faction Rank
------------------->>

function getFactionRanks(factionID, inOrder)
	if (not factionID or type(factionID) ~= "number") then return false end
	if (not inOrder) then
		return RanksByFaction[factionID] or {}
	else
		local ranks = {}	-- Ranks Table
		local added = {}	-- Record of Added Ranks
		local theTeam = getFactionFromID(factionID)

		-- Start with Ranks in DB Storage
		local rankOrder = getElementData(theTeam, "rank_order") or ""
		rankOrder = split(rankOrder, ",")
			-- Add Ranks in Table
		for i,rankID in ipairs(rankOrder) do
			rankID = tonumber(rankID)
			if (getRankFaction(rankID) == factionID) then
				table.insert(ranks, rankID)
				added[rankID] = true
			end
		end
		return ranks
	end
end

function getFactionRankIDByName(factionID, rankName)
	local ranks = getFactionRanks(factionID)
	for i,rankID in ipairs(ranks) do
		local rName = getFactionRankData(rankID, "name")
		if (rName == rankName) then 
			return tonumber(rankID)
		end
	end
	return false
end

function getDefaultRank(factionID)
	if (not factionID or type(factionID) ~= "number") then return false end
	local ranks = getFactionRanks(factionID)
	for i,rankID in ipairs(ranks) do
		if FactionRanks[rankID]["isDefault"] == 1 then
			local rankID = tonumber(rankID)
			return rankID
		end	
	end
	return false
end

-- Rank Ordering
----------------->>

function sortFactionRanks(factionID, ranks)
	if (not factionID or type(factionID) ~= "number") then return false end
	if (not ranks or type(ranks) ~= "table") then return false end
	ranks = table.concat(ranks, ",")
	setFactionData(factionID, "rank_order", ranks)
	return true
end

function getLeaderRank(factionID)
	if (not factionID or type(factionID) ~= "number") then return false end
	for i,rankID in ipairs(getFactionRanks(factionID)) do
		local rankID = tonumber(rankID)
		if FactionRanks[rankID]["isLeader"] == 1 then
			return rankID
		end	
	end
end

function getSeniorRank(factionID, rankID1, rankID2)
	if (not factionID or type(factionID) ~= "number") then return false end
	if (not rankID1 or type(rankID1) ~= "number") then return false end
	if (not rankID2 or type(rankID2) ~= "number") then return false end
	if (rankID1 == rankID2) then return false end
	
	for i,rankID in ipairs(getFactionRanks(factionID, true)) do
		if (rankID == rankID1) then
			return rankID1
		elseif (rankID == rankID2) then
			return rankID2
		end
	end
	return false
end

-- Manage Rank Info
-------------------->>

function getRankFaction(rankID)
	if (not rankID or type(rankID) ~= "number") then return false end
	return getFactionRankData(rankID, "faction_id")
end

function getRankName(rankID)
	if (not rankID or type(rankID) ~= "number") then return false end
	return getFactionRankData(rankID, "name")
end

function getRankIDbyName(fID, rankName)
	if not rankName or type(rankName) ~= "string" then return false end
	for i,rankID in ipairs(getFactionRanks(fID)) do
		local rName = getRankName(rankID)
		if rName == rankName then
			return rankID
		end
	end
end
-- Player Rank
--------------->>

function getPlayerFactionRank(thePlayer, factionID)
	if (not thePlayer or not isElement(thePlayer) or getElementType(thePlayer) ~= "player") then return false end
	local faction = getElementData(thePlayer, "faction")
	for i,v in pairs(faction) do
		if i == factionID then
			rankID = tonumber(v.rank)
			return rankID
		else
			return false	
		end	
	end	
end

--------------------
-- Database Stuff --
--------------------
function getFactionRankData(id, key)
	if (not id or not key) then return nil end
	if (type(id) ~= "number" or type(key) ~= "string") then return nil end
	
	if (FactionRanks[id] == nil) then return nil end
	if (FactionRanks[id][key] == nil) then return nil end
	
	return tonumber(FactionRanks[id][key]) or FactionRanks[id][key]
end

function cacheFactionRankDatabase(qh)
	local result = dbPoll(qh, 0)
	FactionRanks[0] = {}
	for i,row in ipairs(result) do
		FactionRanks[row.id] = {}
		for column,value in pairs(row) do
			if (column ~= "id") then
				FactionRanks[0][column] = true
				if (value == "true") then value = true end
				if (value == "false") then value = false end
				FactionRanks[row.id][column] = value
					-- Associate Faction Ranks
				if (column == "faction_id") then
					value = tonumber(value)
					if (not RanksByFaction[value]) then RanksByFaction[value] = {} end
					table.insert(RanksByFaction[value], tonumber(row.id))
				end
			end
		end
	end
	setTimer(function()
		triggerClientEvent("faction-system.cacheRanks", root, FactionRanks)
	end, 1000, 1)
end 

addEventHandler("onResourceStart", resourceRoot, function()
	dbQuery(cacheFactionRankDatabase, {}, exports.mysql:getConn("mta"), "SELECT * FROM `faction_ranks`")
end)



-- Rename Faction Rank
--------------------->>

addEvent("faction-system.setFactionRankName", true)
addEventHandler("faction-system.setFactionRankName", root, function(rankID, rankName, factionID)
	if not hasMemberPermissionTo(client, factionID, "modify_ranks") then
		return false
	end
	
	local factionID = tonumber(factionID)
		-- Check for Same Rank Name
	for i,rank in ipairs(getFactionRanks(factionID)) do
		local rankNm = getRankName(rank)
		if (rankNm == rankName) then
			outputChatBox("A rank with this name already exists. Choose another rank name.", client, 255, 100, 100)
			return
		end
	end
	local oldName = getRankName(rankID)
	dbExec(exports.mysql:getConn("mta"), "UPDATE `faction_ranks` SET `name` = '"..rankName.."' WHERE `id` = "..rankID)
	outputChatBox("The '"..oldName.."' rank has been renamed to '"..rankName.."'", client, 255, 100, 100)
	FactionRanks[rankID]["name"] = rankName
	local factionRanks = {}
	local theTeam = getFactionFromID(factionID)
	for i,v in pairs(getElementData(theTeam, "ranks")) do
		if i ~= rankID then
			factionRanks[i] = v
		else
			factionRanks[rankID] = rankName	
		end	
	end	
	exports.anticheat:setEld(theTeam, "ranks", factionRanks, 'all')
	getRankInfo(factionID, client)
end)

-- Remove Faction Rank
--------------------->>

addEvent("faction-system.removeFactionRank", true)
addEventHandler("faction-system.removeFactionRank", root, function(rankID, factionID)
	-- Security check.
	if not hasMemberPermissionTo(client, factionID, "modify_ranks") then
		return false
	end

	local factionID = tonumber(factionID)
	local rankName = getRankName(rankID)
	dbExec(exports.mysql:getConn("mta"), "DELETE FROM `faction_ranks` WHERE id="..rankID) 
	dbQuery(resetPlayerRanks,{rankID, factionID},exports.mysql:getConn("mta"), "SELECT * FROM `characters_faction` WHERE `faction_rank` = ?", rankID)
	outputChatBox("The '"..rankName.."' rank has been successfully deleted.", client, 255, 100, 100)
	FactionRanks[rankID] = nil
	local factionRankTable = {}
	local newrank_order = ""
	local theTeam = getFactionFromID(factionID)
	local rankOrder = split(getElementData(theTeam, "rank_order"), ",")
	for i,rID in pairs(rankOrder) do
		local rID = tonumber(rID)
		if rID ~= rankID then
			factionRankTable[rID] = getRankName(rID)
			newrank_order = newrank_order..rID..","
		end	
	end	
	dbExec(exports.mysql:getConn("mta"), "UPDATE `factions` SET `rank_order` = '"..newrank_order.."' WHERE `id` = "..factionID)
	exports.anticheat:setEld(theTeam, "rank_order", newrank_order, 'all')
	exports.anticheat:setEld(theTeam, "ranks", factionRankTable, 'all')
	getRankInfo(factionID, client)
end)

function resetPlayerRanks(query, rankId, factionId)
	local pollResult = dbPoll(query, 0)
	local newRank = getDefaultRank(factionId)
	
	dbExec(exports.mysql:getConn("mta"), "UPDATE `characters_faction` SET `faction_rank` = ? WHERE `faction_rank` = ? AND `faction_id` = ?", newRank, rankId, factionId)
	
	for _, row in pairs(pollResult) do
		local charID = tonumber(row["character_id"])
		local thePlayer = exports.global:getPlayerFromCharacterID(charID)
		if thePlayer then
			if getElementData(thePlayer, "factionMenu") == 1 then
				triggerClientEvent(thePlayer, "hideFactionMenu", thePlayer)
			end

			local factionInfo = getElementData(thePlayer, "faction")
			factionInfo[factionId].rank = newRank
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "faction", factionInfo, true)
		end	
	end
end


-- Update Rank Permissions
--------------------------->>

addEvent("faction-system.updateRankPermissions", true)
addEventHandler("faction-system.updateRankPermissions", root, function(rankID, permissions, wage, factionID)
	if not hasMemberPermissionTo(client, factionID, "modify_ranks") then
		return false
	end
	
	local factionID = tonumber(factionID)
	local rankName = getRankName(rankID)
	local newWage = math.min(2500, math.max(0, tonumber(wage) or 0))
	setAllRankPermissions(rankID, permissions, newWage, factionID)
	triggerClientEvent("faction-system.cacheRanks", root, FactionRanks)
	outputChatBox("The permissions for '"..rankName.."' have been successfully updated.", client, 255, 100, 100)
end) 

-- Update Rank Order
--------------------->>

addEvent("faction-system.updateRankOrder", true)
addEventHandler("faction-system.updateRankOrder", root, function(rankIDs, factionID)
	if not hasMemberPermissionTo(client, factionID, "modify_ranks") then
		return false
	end
	
	local factionID = tonumber(factionID)
	local theTeam = getFactionFromID(factionID)
	sortFactionRanks(factionID, rankIDs, theTeam)
	getRankInfo(factionID, client)
end)

-- Rank Ordering
----------------->>

function sortFactionRanks(factionID, ranks, theTeam)
	if (not factionID or type(factionID) ~= "number") then return false end
	if (not ranks or type(ranks) ~= "table") then return false end
	ranks = table.concat(ranks, ",")
	dbExec(exports.mysql:getConn("mta"), "UPDATE `factions` SET `rank_order` = '"..ranks.."' WHERE `id` = "..factionID)
	exports.anticheat:setEld(theTeam, "rank_order", ranks, 'all')
	return true
end

function cacheOnPlayerSpawn()
	setTimer(function()
		triggerClientEvent("faction-system.cacheRanks", source, FactionRanks)
	end, 1000, 1)
end
addEventHandler("accounts:character:select", root, cacheOnPlayerSpawn)

function cacheOnPlayerJoin()
	setTimer(function(thePlayer) 
		if isElement(thePlayer) then
			triggerClientEvent("faction-system.cacheRanks", thePlayer, FactionRanks) 
		end
	end, 1000, 1, source)
end
addEventHandler("onCharacterLogin", getRootElement(), cacheOnPlayerJoin)