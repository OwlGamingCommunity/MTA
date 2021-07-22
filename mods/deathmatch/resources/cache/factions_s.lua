--MAXIME
local mysql = exports.mysql
local factionNameCache = {}
local searched = {}
local refreshCacheRate = 60 --Minutes
function getFactionNameFromId( id )
	if not id or not tonumber(id) then
		--outputDebugString("Server cache: id is empty.")
		return false
	else
		id = tonumber(id)
	end
	
	if factionNameCache[id] then
		return factionNameCache[id]
	end

	local faction = exports.factions.getFactionFromID(id)
	if faction then
		factionNameCache[id] = getTeamName(faction)
		return factionNameCache[id]
	end
	
	if not searched[id] or getTickCount() - searched[id] > refreshCacheRate*1000*60 then
		searched[id] = getTickCount()
		local query = mysql:query_fetch_assoc("SELECT `name` FROM `factions` WHERE `id` = '" .. id .. "' LIMIT 1")
		if query and query["name"] and string.len(query["name"]) > 0 then
			local factionName = query["name"]
			factionNameCache[id] = factionName
			return factionNameCache[id]
		end
	else
		return false
	end

	return false
end

function removeFactionNameFromCache(factionId)
	factionNameCache[factionId] = nil
	triggerClientEvent('removeFactionNameFromCache', root, factionId)
end

function requestFactionNameCacheFromServer(id)
	local found = getFactionNameFromId( id )
	triggerClientEvent(client, "retrieveFactionNameCacheFromServer", client, found, id)
end
addEvent("requestFactionNameCacheFromServer", true)
addEventHandler("requestFactionNameCacheFromServer", root, requestFactionNameCacheFromServer)
