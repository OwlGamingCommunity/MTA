mysql = exports.mysql

addEvent("addFriend", true)
addEventHandler("addFriend", getRootElement(), function(player) new_addFriend(client, player) end)

local function isPlayerNearOther(player, other)
	local x, y, z = getElementPosition(player)
	local otherX, otherY, otherZ = getElementPosition(other)

	return getDistanceBetweenPoints3D(x, y, z, otherX, otherY, otherZ) < 20
end

-- FRISKING
function friskShowItems(player)
	--local items = exports['item-system']:getItems(player)
	--triggerClientEvent(source, "friskShowItems", player, items)
	triggerEvent("subscribeToInventoryChanges",source,player)
	triggerClientEvent(source,"showInventory",source,player, "frisk")
end
addEvent("friskShowItems", true)
addEventHandler("friskShowItems", getRootElement(), friskShowItems)

-- CUFFS
function toggleCuffs(cuffed, player)
	if (cuffed) then
		toggleControl(player, "fire", false)
		toggleControl(player, "sprint", false)
		toggleControl(player, "jump", false)
		toggleControl(player, "next_weapon", false)
		toggleControl(player, "previous_weapon", false)
		toggleControl(player, "accelerate", false)
		toggleControl(player, "brake_reverse", false)
		toggleControl(player, "aim_weapon", false)
	else
		toggleControl(player, "fire", true)
		toggleControl(player, "sprint", true)
		toggleControl(player, "jump", true)
		toggleControl(player, "next_weapon", true)
		toggleControl(player, "previous_weapon", true)
		toggleControl(player, "accelerate", true)
		toggleControl(player, "brake_reverse", true)
		toggleControl(player, "aim_weapon", true)
	end
end

-- RESTRAINING
function restrainPlayer(player, restrainedObj)
	if not isPlayerNearOther(client, player) then
		return
	end

	local username = getPlayerName(client)
	local targetPlayerName = getPlayerName(player)
	local dbid = getElementData( player, "dbid" )
	
	setTimer(toggleCuffs, 200, 1, true, player)
	
	outputChatBox("You have been restrained by " .. username:gsub("_", " ") .. ".", player)
	outputChatBox("You restrained " .. targetPlayerName:gsub("_", " ") .. ".", client)
	exports.anticheat:changeProtectedElementDataEx(player, "restrain", 1, true)
	exports.anticheat:changeProtectedElementDataEx(player, "restrainedObj", restrainedObj, true)
	exports.anticheat:changeProtectedElementDataEx(player, "restrainedBy", getElementData(client, "dbid"), true)
	mysql:query_free("UPDATE characters SET cuffed = 1, restrainedby = " .. mysql:escape_string(getElementData(client, "dbid")) .. ", restrainedobj = " .. mysql:escape_string(restrainedObj) .. " WHERE id = " .. mysql:escape_string(dbid) )
	
	exports.global:takeItem(client, restrainedObj)

	if (restrainedObj==45) then -- If handcuffs.. give the key
		exports['item-system']:deleteAll(47, dbid)
		exports.global:giveItem(client, 47, dbid)
	end
	exports.global:removeAnimation(player)
end
addEvent("restrainPlayer", true)
addEventHandler("restrainPlayer", getRootElement(), restrainPlayer)

function unrestrainPlayer(player, restrainedObj)
	if not isPlayerNearOther(client, player) then
		return
	end

	local username = getPlayerName(client)
	local targetPlayerName = getPlayerName(player)
	
	outputChatBox("You have been unrestrained by " .. username:gsub("_", " ") .. ".", player)
	outputChatBox("You removed " .. targetPlayerName:gsub("_", " ") .. "'s restraints.", client)
	
	setTimer(toggleCuffs, 200, 1, false, player)
	
	exports.anticheat:changeProtectedElementDataEx(player, "restrain", 0)
	exports.anticheat:changeProtectedElementDataEx(player, "restrainedBy")
	exports.anticheat:changeProtectedElementDataEx(player, "restrainedObj")
	
	local dbid = getElementData(player, "dbid")
	if (restrainedObj==45) then -- If handcuffs.. take the key
		exports['item-system']:deleteAll(47, dbid)
	end
	exports.global:giveItem(client, restrainedObj, 1)
	mysql:query_free("UPDATE characters SET cuffed = 0, restrainedby = 0, restrainedobj = 0 WHERE id = " .. mysql:escape_string(dbid) )
	
	exports.global:removeAnimation(player)
end
addEvent("unrestrainPlayer", true)
addEventHandler("unrestrainPlayer", getRootElement(), unrestrainPlayer)

-- BLINDFOLDS
function blindfoldPlayer(player)
	if not isPlayerNearOther(client, player) or not exports.global:takeItem(client, 66) then -- take their blindfold
		return
	end

	local username = getPlayerName(client):gsub("_", " ")
	local targetPlayerName = getPlayerName(player):gsub("_", " ")

	outputChatBox("You have been blindfolded by " .. username .. ".", player)
	outputChatBox("You blindfolded " .. targetPlayerName .. ".", client)

	exports.anticheat:changeProtectedElementDataEx(player, "blindfold", 1)
	mysql:query_free("UPDATE characters SET blindfold = 1 WHERE id = " .. mysql:escape_string(getElementData( player, "dbid" )) )
	fadeCamera(player, false)
end
addEvent("blindfoldPlayer", true)
addEventHandler("blindfoldPlayer", getRootElement(), blindfoldPlayer)

function removeblindfoldPlayer(player)
	local username = getPlayerName(source):gsub("_", " ")
	local targetPlayerName = getPlayerName(player):gsub("_", " ")
	
	outputChatBox("You have had your blindfold removed by " .. username .. ".", player)
	outputChatBox("You removed " .. targetPlayerName .. "'s blindfold.", source)
	
	exports.global:giveItem(source, 66, 1) -- give the remove the blindfold
	exports.anticheat:changeProtectedElementDataEx(player, "blindfold")
	mysql:query_free("UPDATE characters SET blindfold = 0 WHERE id = " .. mysql:escape_string(getElementData( player, "dbid" )) )
	fadeCamera(player, true)
end
addEvent("removeBlindfold", true)
addEventHandler("removeBlindfold", getRootElement(), removeblindfoldPlayer)


-- STABILIZE
function stabilizePlayer(player)
	if not isPlayerNearOther(client, player) then
		return
	end

	local found, slot, itemValue = exports.global:hasItem(client, 70)
	if found then
		if itemValue > 1 then
			exports['item-system']:updateItemValue(client, slot, itemValue - 1)
		else
			exports.global:takeItem(client, 70, itemValue)
		end
		
		local username = getPlayerName(client)
		local targetPlayerName = getPlayerName(player)
	
	
		outputChatBox("You have been stabilized by " .. username .. ".", player)
		outputChatBox("You stabilized " .. targetPlayerName .. ".", client)
		triggerEvent("onPlayerStabilize", player)
	end
end
addEvent("stabilizePlayer", true)
addEventHandler("stabilizePlayer", getRootElement(), stabilizePlayer)
