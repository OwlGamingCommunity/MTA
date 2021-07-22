--MAXIME
local mysql = exports.mysql
local characterNameCache = {}
local characterIDCache = {}
local searched = {}
local refreshCacheRate = 60 --Minutes
function getCharacterNameFromID( id )
	if not id or not tonumber(id) then
		--outputDebugString("Server cache: id is empty.")
		return false
	else
		id = tonumber(id)
	end
	
	if characterNameCache[id] then
		return characterNameCache[id]
	end
	
	for i, player in pairs(exports.pool:getPoolElementsByType('player')) do
		if id == getElementData(player, "dbid") then
			characterNameCache[id] = exports.global:getPlayerName(player)
			return characterNameCache[id]
		end
	end

	if not searched[id] or getTickCount() - searched[id] > refreshCacheRate*1000*60 then
		searched[id] = getTickCount()
		local query = mysql:query_fetch_assoc("SELECT `charactername` FROM `characters` WHERE `id` = '" .. mysql:escape_string(id) .. "' LIMIT 1")
		if query and query["charactername"] and string.len(query["charactername"]) > 0 then
			local characterName = string.gsub(query["charactername"], "_", " ")
			characterNameCache[id] = characterName
			return characterNameCache[id]
		end
	else 
		return false
	end

	return false
end

function requestCharacterNameCacheFromServer(id)
	local found = getCharacterNameFromID( id )
	triggerClientEvent(client, "retrieveCharacterNameCacheFromServer", client, found, id)
end
addEvent("requestCharacterNameCacheFromServer", true)
addEventHandler("requestCharacterNameCacheFromServer", root, requestCharacterNameCacheFromServer)

function getCharacterIDFromName(name)
	if not name then
		--outputDebugString("Server cache: name is empty.")
		return false
	else
		name = tostring(name):gsub(" ", "_")
	end

	if characterIDCache[name] then
		return characterIDCache[name]
	end
	
	for i, player in pairs(exports.pool:getPoolElementsByType('player')) do
		if name == getPlayerName(player) then
			characterIDCache[name] = tonumber(getElementData(player, "dbid")) or false
			return characterIDCache[name]
		end
	end

	for charID,charName in ipairs(characterNameCache) do
		if name == charName then
			characterIDCache[name] = charID
			return charID
		end
	end
	
	if searched[name] then
		return false
	end

	local query = mysql:query_fetch_assoc("SELECT `id` FROM `characters` WHERE `charactername` = '" .. mysql:escape_string(name) .. "' LIMIT 1")
	if query and query["id"] and string.len(query["id"]) > 0 then
		local characterID = tonumber(query["id"])
		characterIDCache[name] = characterID
		return characterIDCache[name]
	end
	searched[name] = true

	setTimer(function()
		local index = id
		searched[index] = nil
	end, refreshCacheRate*1000*60, 1)

	return false
end

function requestCharacterIDCacheFromServer(name)
	local found = getCharacterIDFromName(name)
	triggerClientEvent(client, "retrieveCharacterIDCacheFromServer", client, found, name)
end
addEvent("requestCharacterIDCacheFromServer", true)
addEventHandler("requestCharacterIDCacheFromServer", root, requestCharacterIDCacheFromServer)