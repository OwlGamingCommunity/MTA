function getPlayersInFaction(factionID, leaderOnly)
	users = {}
	local factionID = tonumber(factionID)
	for k,v in ipairs(getElementsByType("player")) do
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