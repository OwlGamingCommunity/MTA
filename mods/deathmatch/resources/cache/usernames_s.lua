--MAXIME
local mysql = exports.mysql
local refreshCacheRate = 30
local usernameCache = {}
local searched = {}
local searched2 = {}
function getUsername( clue )
	if not clue or string.len(clue) < 1 then
		return false
	end
	
	for i, username in pairs(usernameCache) do
		if username and string.lower(username) == string.lower(clue) then
			return username
		end
	end
	
	for i, player in pairs(exports.pool:getPoolElementsByType("player")) do
		local username = getElementData(player, "account:username")
		if username and string.lower(username) == string.lower(clue) then
			usernameCache[getElementData(player, "account:id")] = username
			return username
		end
	end

	if not searched[clue] or getTickCount() - searched[clue] > refreshCacheRate*1000*60 then
		searched[clue] = getTickCount()
		local qh = dbQuery(exports.mysql:getConn("core"), "SELECT `id`,`username` FROM accounts WHERE `username`=? LIMIT 1", clue)
		local query = dbPoll(qh, 10000)
		if query and #query > 0 then
			usernameCache[tonumber(query[1]["id"])] = query[1]["username"]
			return query["username"]
		else
			dbFree(qh)
		end
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
	
	if searched2[username] then
		return false
	end
	searched2[username] = true

	local qh = dbQuery(exports.mysql:getConn("core"), "SELECT `id` FROM accounts WHERE `username`=? LIMIT 1", username)
	local query = dbPoll(qh, 10000)
	if query and #query > 0 then
		usernameCache[query[1].id] = username
		return query[1].id
	else
		dbFree(qh)
	end

	return false
end

function checkUsernameExistance(clue)
	if not clue or string.len(clue) < 1 then
		return false, "Please enter account name."
	end 
	local found = getUsername( clue )
	if found then
		return true, "Account name '"..found.."' is existed and valid!"
	else
		return false, "Account name '"..clue.."' does not exist."
	end
end

function requestUsernameCacheFromServer(clue)
	local found = getUsername( clue )
	triggerClientEvent(client, "retrieveUsernameCacheFromServer", source, found)
end
addEvent("requestUsernameCacheFromServer", true)
addEventHandler("requestUsernameCacheFromServer", root, requestUsernameCacheFromServer)
--[[
function resourceStart()
	usernameCache = exports.data:load() or {}
end
addEventHandler("onResourceStart", resourceRoot, resourceStart)

function resourceStop()
	exports.data:save(usernameCache)
end
addEventHandler("onResourceStop", resourceRoot, resourceStop)
]]

function getUsernameFromId(id)
	if not id or not tonumber(id) then
		--outputDebugString("Server cache: id is empty.")
		return false
	else
		id = tonumber(id)
	end
	
	if usernameCache[id] then
		return usernameCache[id]
	end
	
	for i, player in pairs(exports.pool:getPoolElementsByType("player")) do
		if id == getElementData(player, "account:id") then
			usernameCache[id] = getElementData(player, "account:username")
			return usernameCache[id]
		end
	end
	
	if searched[id] then
		return false
	end
	searched[id] = true

	local qh = dbQuery(exports.mysql:getConn("core"), "SELECT `username` FROM accounts WHERE `id`=? LIMIT 1", id)
	local query = dbPoll(qh, 10000)
	if query and #query > 0 then
		usernameCache[id] = query[1].username
		return usernameCache[id]
	else
		dbFree(qh)
	end

	return false
end

addEvent('fetchUsernameFromAccountId', true)
addEventHandler('fetchUsernameFromAccountId', root, function (id)
	local found = getUsernameFromId(id)
	triggerClientEvent(client, "foundUsernameFromAccountId", source, id, found)
end)

local accountCache = {}
local accountCacheSearched = {}
function getAccountFromCharacterId(id)
	if id and tonumber(id) then
		id = tonumber(id)
	else
		return false
	end
	if accountCache[id] then
		return accountCache[id]
	end
	for i, player in pairs(getElementsByType("player")) do
		if getElementData(player, "dbid") == id then
			accountCache[id] = {id = getElementData(player, "account:id"), username = getElementData(player, "account:username")}
			return accountCache[id]
		end
	end

	if accountCacheSearched[id] then
		return false
	end
	accountCacheSearched[id] = true

	local user = mysql:query_fetch_assoc("SELECT account AS id FROM characters WHERE id="..id.." LIMIT 1")
	if user and user.id ~= mysql_null() then
		accountCache[id] = {id = tonumber(user.id), username = getUsernameFromId(user.id)}
		return accountCache[id]
	end

	return false
end

function startUp()
	dbQuery( 
		function(qh)
			local result = dbPoll(qh,0)
			for _, row in pairs(result) do
				usernameCache[tonumber(row.id)] = row.username
			end
		end, exports.mysql:getConn("core"), "SELECT id, username FROM accounts")
end
addEventHandler("onResourceStart", resourceRoot, startUp)