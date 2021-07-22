--MAXIME

local usernameCache = {}
local searched = {}
local searched1 = {}
local searched2 = {}
local refreshCacheRate = 10 --Minutes
function getUsername( clue )
	if not clue or string.len(clue) < 1 then
		return false
	end
 
	for i, username in pairs(usernameCache) do
		if username and string.lower(username) == string.lower(clue) then
			return username
		end
	end
	
	for i, player in pairs(getElementsByType("player")) do
		local username = getElementData(player, "account:username")
		if username and string.lower(username) == string.lower(clue) then
			table.insert(usernameCache, username)
			return username
		end
	end
	
	if not searched[clue] or getTickCount() - searched[clue] > refreshCacheRate*1000*60 then
		searched[clue] = getTickCount()
		triggerServerEvent("requestUsernameCacheFromServer", resourceRoot, clue)
	end
	
	return false
end

function getIdFromUsername(username)
	if not username then
		return false
	end
	
	for k,v in pairs(usernameCache) do
		if string.lower(v) == string.lower(username) then
			return k
		end
	end
	
	for i, player in pairs(exports.pool:getPoolElementsByType("player")) do
		if string.lower(username) == string.lower(getElementData(player, "account:username")) then
			usernameCache[getElementData(player, "account:id")] = username
			return getElementData(player, "account:id")
		end
	end

	if not searched2[username] or getTickCount() - searched2[username] > refreshCacheRate*1000*60 then
		searched2[username] = getTickCount()
		triggerServerEvent("requestUsernameCacheFromServer", resourceRoot, username)
	end
	return false
end

function getUsernameFromId(id)
	if not id or not tonumber(id) then
		return false
	else
		id = tonumber(id)
	end

	if usernameCache[id] then
		return usernameCache[id]
	end
	
	for _, player in pairs(exports.pool:getPoolElementsByType("player")) do
		if id == getElementData(player, "account:id") then
			usernameCache[id] = getElementData(player, "account:username")
			return usernameCache[id]
		end
	end

	if not searched1[id] or (getTickCount() - searched1[id]) > refreshCacheRate*1000*60 then
		searched1[id] = getTickCount()
		triggerServerEvent("fetchUsernameFromAccountId", resourceRoot, id)
	end
	return false
end

addEvent("foundUsernameFromAccountId", true)
addEventHandler("foundUsernameFromAccountId", root, function (id, found)
	if found then
		usernameCache[id] = found
	end
end)

function checkUsernameExistance(clue)
	if not clue or string.len(clue) < 1 then
		return false, "Please enter account name."
	end 
	local found = getUsername( clue )
	if found then
		return true, "Account name '"..found.."' is existed and valid!", found
	else
		return false, "Account name '"..clue.."' does not exist."
	end
end

function retrieveUsernameCacheFromServer(clue)
	if clue then
		table.insert(usernameCache, clue)
	end
end
addEvent("retrieveUsernameCacheFromServer", true)
addEventHandler("retrieveUsernameCacheFromServer", root, retrieveUsernameCacheFromServer)