--MAXIME
local factionNameCache = {}
local searched = {}
local refreshCacheRate = 10 --Minutes
function getFactionNameFromId( id )
	if not id or not tonumber(id) then
		--outputDebugString("Client cache: id is empty.")
		return false
	else
		id = tonumber(id)
	end
	
	if factionNameCache[id] then
		return factionNameCache[id]
	end
	
	--outputDebugString("Client cache: faction name not found in cache. Searching in all current online factions.")
	local faction = exports.factions.getFactionFromID(id)
	if faction then
		factionNameCache[id] = getTeamName(faction)
		--outputDebugString("Client cache: faction name found in current online factions. - "..factionNameCache[id]) 
		return factionNameCache[id]
	end

	if not searched[id] or getTickCount() - searched[id] > refreshCacheRate*1000*60 then
		searched[id] = getTickCount()
		--outputDebugString("Client cache: Faction name not found in all current online factions. Requesting for server's cache.")
		triggerServerEvent("requestFactionNameCacheFromServer", localPlayer, id)
	else 
		--outputDebugString("Client cache: Previously requested for server's cache but not found. Searching cancelled.")
		return false
	end

	return "Loading.."
end

addEvent("removeFactionNameFromCache", true)
addEventHandler("removeFactionNameFromCache", root, function (factionId)
	factionNameCache[factionId] = nil
end)

function retrieveFactionNameCacheFromServer(factionName, id)
	--outputDebugString("Client cache: Retrieving data from server and adding to client's cache.")
	if factionName and id then
		factionNameCache[id] = factionName
	end
end
addEvent("retrieveFactionNameCacheFromServer", true)
addEventHandler("retrieveFactionNameCacheFromServer", root, retrieveFactionNameCacheFromServer)