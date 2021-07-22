function reloadUserPerks( userID )
	if (userID) then
		local found = false
		local foundElement = nil
		for key, value in ipairs(exports.pool:getPoolElementsByType("player")) do
			local accid = tonumber(getElementData(value, "account:id"))
			if (accid) then
				if (accid==tonumber(userID)) then
					found = true
					foundElement = value
					break
				end
			end
		end

		if (found) then
			exports.donators:loadAllPerks(foundElement)
			outputDebugString("->call('reloadUserPerks', '".. tostring(userID) .."')=200 OK")
		else
			outputDebugString("->call('reloadUserPerks', '".. tostring(userID) .."')=402 USER NOT ONLINE")
		end
	end
end

function isPlayerOnline( userID )
	local found = false
	if (userID) then

		for key, value in ipairs(exports.pool:getPoolElementsByType("player")) do
			local accid = tonumber(getElementData(value, "account:id"))
			if (accid) then
				if (accid==tonumber(userID)) then
					found = true
					break
				end
			end
		end
	end
	return found
end

function getPerks()
	all = exports.donators:getPerks()
	availableTable = {}
	for perkID = 1, #all do
		local perkArr = all[perkID]
		if perkArr then
			if perkArr[3] >= 1 then
				table.insert(availableTable, perkArr)
			end
		end
	end

	return availableTable
end

function getServerStats()
	local serverName = getServerName()
	local serverPort = getServerPort()
	local mtaServerVersion = getVersion ()
	local numPlayers = getPlayerCount()
	local maxPlayers = getMaxPlayers()
	local fpsLimit = getFPSLimit()
	local mapName = getMapName()
	local gameType = getGameType()
	local scriptVersion = exports.global:getScriptVersion()
	return serverName, serverPort, mtaServerVersion, numPlayers, maxPlayers, fpsLimit, mapName, gameType, scriptVersion
end

function deleteItem(itemID, itemValue)
	if not (itemID) then
		return false
	end

	if not (itemValue) then
		return false
	end

	exports['item-system']:deleteAll(itemID, itemValue)
end

function statTransfer(username, fromCharacterID, toCharacterID, userID)
	if (username) and (fromCharacterID) and (toCharacterID) then
		local fromCharacterName = exports.cache:getCharacterName(fromCharacterID)
		local toCharacterName = exports.cache:getCharacterName(toCharacterID)
		exports.global:sendMessageToAdmins("[UCP] Player "..tostring(username).." has successfully stat-transferred from " .. fromCharacterName:gsub("_", " ") .. " to ".. toCharacterName:gsub("_", " "))

		-- reload vehicles
		for key, value in ipairs(exports.pool:getPoolElementsByType("vehicle")) do
		local owner = getElementData(value, "owner")

			if (owner) then
				if (tonumber(owner)==tonumber(fromCharacterID)) or (tonumber(owner)==tonumber(toCharacterID)) then
					local id = getElementData(value, "dbid")
					outputDebugString("* Reloading vehicle ".. tostring(id))
					exports.vehicle:reloadVehicle(id)
				end
			end
		end

		-- reload interiors
		for key, value in ipairs( getElementsByType("interior") ) do
			local interiorStatus = getElementData(value, "status")
			local owner = interiorStatus.owner
			if (owner) then
				if (tonumber(owner)==tonumber(fromCharacterID)) or (tonumber(owner)==tonumber(toCharacterID)) then
					local id = getElementData(value, "dbid")
					outputDebugString("* Reloading interior ".. tostring(id))
					exports.interior_system:realReloadInterior(id)
				end
			end
		end
		outputDebugString("* Stat transfer processed")

		--Kicking player out of game
		kickPlayerByUserId(userID)
	end
end

function kickPlayerByUserId(userID)
	for key, player in ipairs( getElementsByType("player") ) do
		if getElementData(player, "account:id") == tonumber(userID) then
			kickPlayer(player, "Assets transferr forced you to logout!")
		end
	end
	return true
end

function retrieveWeaponDetails(serialNumber)
	return exports.global:retrieveWeaponDetails( serialNumber )
end

function sendMessageToAdmins(msg)
	if msg then
		exports.global:sendMessageToAdmins("[UCP] "..msg)
	end
end

addEventHandler("onResourceStart", resourceRoot, function()
	local new_pass = tostring(get("website_pass"))
	local aclAccount = getAccount("website")
	if not aclAccount then 
		addAccount("website", new_pass)
	end
end)
