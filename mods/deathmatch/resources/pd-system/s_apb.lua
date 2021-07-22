function showAPB(thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then		
		if (exports.factions:isInFactionType(thePlayer, 2) or exports.factions:isInFactionType(thePlayer, 3)) then
			local found = false
			outputChatBox(" ", thePlayer)
			mysql:query("DELETE FROM `apb` WHERE `time` < (NOW() - interval 49 hour)")
			local mQuery = mysql:query("SELECT `id`, `description`, `doneby`, `time` - INTERVAL 1 hour as 'newtime'  FROM `apb` ORDER BY `id` ASC")
			while true do
				local row = mysql:fetch_assoc( mQuery )
					if not row then break end
					local issuerName = exports['cache']:getCharacterName(row["doneby"])
					if issuerName == false then
						issuerName = "Unknown"
					end
					outputChatBox("> "..row["description"], thePlayer)
					outputChatBox("ID: "..tostring(row["id"]).." Issued by "..issuerName.." at "..row["newtime"], thePlayer)
					outputChatBox(" ", thePlayer)
				end
			mysql:free_result(mQuery)
			
			outputChatBox("> End of APB's.", thePlayer)
		end
	end
end
addCommandHandler("apb", showAPB)

function newAPB(thePlayer, commandName, ...)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		local faction = exports.factions:getCurrentFactionDuty(thePlayer) or -1
		local theTeam = exports.factions:getFactionFromID(faction)
		local ftype = getElementData(theTeam, "type")
		
		if (factionType==2) or (factionType==3) then
			if not  (...) then
				outputChatBox("Syntax: /"..commandName.." [Description]", thePlayer)
			else
				local description = table.concat( { ... }, " " )
				mysql:query_free("INSERT INTO `apb` (`description`, `doneby`, `time`) VALUES ('".. mysql:escape_string(description) .."', "..getElementData(thePlayer, "account:character:id")..", NOW() - interval 1 hour)")
				outputChatBox("> Record succesfully added.", thePlayer)
				local teamPlayers = exports.factions:getPlayersInFaction(faction)
				local username  = getPlayerName(thePlayer):gsub("_", " ")

				local factionRank = exports.factions:getPlayerFactionRank(thePlayer, faction)

				local factionRanks = getElementData(theTeam, "ranks")
				local factionRankTitle = factionRanks[factionRank]
											
				for key, value in ipairs(teamPlayers) do
					outputChatBox("" .. factionRankTitle .. " " .. username .." has just added a new APB.", value, 0, 102, 255)
				end
			end
		end
	end
end
addCommandHandler("newapb", newAPB)

function delAPB(thePlayer, commandName, id)
	local logged = getElementData(thePlayer, "loggedin")
	
	if (logged==1) then
		local faction = exports.factions:getCurrentFactionDuty(thePlayer) or -1
		local theTeam = exports.factions:getFactionFromID(faction)
		local ftype = getElementData(theTeam, "type")
		
		if ftype == 3 or ftype == 2 then
			if not id or not (tonumber(id)) or (tonumber(id) < 2) then
				outputChatBox("Syntax: /"..commandName.." [ID]", thePlayer)
			else
				mysql:query_free("DELETE  FROM `apb` WHERE `id`='"..mysql:escape_string(id).."'")
				outputChatBox("> Record succesfully deleted.", thePlayer)
				local teamPlayers = exports.factions:getPlayersInFaction(faction)
				local username  = getPlayerName(thePlayer):gsub("_", " ")

				local factionRank = exports.factions:getPlayerFactionRank(thePlayer, faction)
																		
				local factionRanks = getElementData(theTeam, "ranks")
				local factionRankTitle = factionRanks[factionRank]
											
				for key, value in ipairs(teamPlayers) do
					outputChatBox("" .. factionRankTitle .. " " .. username .." has just deleted APB " .. mysql:escape_string(id) .. ".", value, 0, 102, 255)
				end
			end
		end
	end
end
addCommandHandler("delapb", delAPB)