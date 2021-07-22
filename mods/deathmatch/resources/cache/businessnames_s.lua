--MAXIME
local mysql = exports.mysql
local businessNameCache = {}
local searched = {}
local refreshCacheRate = 60 --Minutes
function getBusinessNameFromID( id )
	if not id or not tonumber(id) then
		--outputDebugString("Server cache: id is empty.")
		return false
	else
		id = tonumber(id)
	end
	
	if businessNameCache[id] then
		return businessNameCache[id]
	end
	
	for i, player in pairs(exports.pool:getPoolElementsByType('player')) do
		if id == getElementData(player, "dbid") then
			businessNameCache[id] = exports.global:getPlayerName(player)
			return businessNameCache[id]
		end
	end

	if not searched[id] or getTickCount() - searched[id] > refreshCacheRate*1000*60 then
		searched[id] = getTickCount()
		local query = mysql:query_fetch_assoc("SELECT `title` AS `businessname` FROM `businesses` WHERE `id` = '" .. mysql:escape_string(id) .. "' LIMIT 1")
		if query and query["businessname"] and string.len(query["businessname"]) > 0 then
			local businessName = string.gsub(query["businessname"], "_", " ")
			businessNameCache[id] = businessName
			return businessNameCache[id]
		end
	else 
		return false
	end

	return false
end

function requestBusinessNameCacheFromServer(id)
	local found = getBusinessNameFromID( id )
	triggerClientEvent(client, "retrieveBusinessNameCacheFromServer", client, found, id)
end
addEvent("requestBusinessNameCacheFromServer", true)
addEventHandler("requestBusinessNameCacheFromServer", root, requestBusinessNameCacheFromServer)
