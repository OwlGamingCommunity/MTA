--MAXIME
function canPlayerViewShop(thePlayer, theShop)
	local faction_access = getElementData(theShop, "faction_access") or 0
	if faction_access <= 0 then
		return isPlayerHeadAdmin(thePlayer)
	end
	local faction_belong = getElementData(theShop, "faction_belong") or 0
	local player_faction = getElementData(thePlayer, "faction")
	if player_faction[faction_belong] then
		if faction_access == 2 then
			return true
		elseif faction_access == 1 then
			local player_faction_leader = player_faction[faction_belong].leader
			outputDebugString("player_faction_leader = "..tostring(player_faction_leader))
			if player_faction_leader then
				return true
			else
				return isPlayerHeadAdmin(thePlayer)
			end
		else
			return isPlayerHeadAdmin(thePlayer)
		end
	else
		return isPlayerHeadAdmin(thePlayer)
	end
	return false
end

function isPlayerHeadAdmin(thePlayer)
	if exports.integration:isPlayerLeadAdmin(thePlayer) then
		--outputChatBox("[SHOP] You have by-passed a security check. Reason: Lead Admin status", thePlayer, 255, 0 , 0)
		return true
	else
		return false
	end
end

function canPlayerAdminShop(thePlayer)
	return exports.integration:isPlayerLeadAdmin(thePlayer)
end

function getFactionNameFromID(id)
	if not id or not tonumber(id) then
		return false
	end
	for i, faction in pairs(getElementsByType("team")) do
		if getElementData(faction, "id") == tonumber(id) then
			return getTeamName(faction)
		end
	end
	return false
end

function getFactionID(factionName)
	if factionName and isElement(factionName) and getElementType(factionName) == "team" then
		return getTeamName(faction)
	end
	
	for i, faction in pairs(getElementsByType("team")) do
		if getElementData(faction, "id") == tonumber(id) then
			return getTeamName(faction)
		end
	end
	return false
end

function getComboIndexFromFactionID(comboIndex, factionID)
	for i = 0, #comboIndex do
		if comboIndex[i][2] == factionID then
			return i
		end
	end
	return 0
end