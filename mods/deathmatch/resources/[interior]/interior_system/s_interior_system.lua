--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local timerLoadAllInteriors = 60*1000
local loading_speed = 100

intTable = {}
mysql = exports.mysql
-- to check:
-- payday

-- to test
-- /sell

--[[
Interior types:
TYPE 0: House
TYPE 1: Business
TYPE 2: Government (Unbuyable)
TYPE 3: Rentable
--]]

-- Small hack
function setElementDataEx(source, field, parameter, streamtoall, streamatall)
	exports.anticheat:changeProtectedElementDataEx( source, field, parameter, streamtoall, streamatall)
end
-- End small hack

function switchGroundSnow( thePlayer, toggle )
	if getResourceFromName( "shader_snow_ground" ) and getResourceState ( getResourceFromName( "shader_snow_ground" ) ) == "running" then
		triggerClientEvent( thePlayer, "switchGoundSnow", thePlayer, toggle)
	end
end

function SmallestID( ) -- finds the smallest ID in the SQL instead of auto increment
	local result = mysql:query_fetch_assoc("SELECT MIN(e1.id+1) AS nextID FROM interiors AS e1 LEFT JOIN interiors AS e2 ON e1.id +1 = e2.id WHERE e2.id IS NULL")
	if result then
		local id = tonumber(result["nextID"]) or 1
		return id
	end
	return false
end

function findProperty(thePlayer, dimension)
	local dbid = dimension or (thePlayer and getElementDimension( thePlayer ) or 0)
	if dbid and tonumber(dbid) and tonumber(dbid) > 0 then
		dbid = tonumber(dbid)
		local foundInterior = exports.pool:getElement("interior", dbid)
		if foundInterior then
			local entrance = getElementData(foundInterior, "entrance")
			local interiorExit = getElementData(foundInterior, "exit")
			local interiorStatus = getElementData(foundInterior, "status")
			return dbid, entrance, interiorExit, interiorStatus.type, foundInterior
		end
	end
	return 0
end

function cleanupProperty( id, donotdestroy)
	if id > 0 then
		if exports.mysql:query_free( "DELETE FROM dancers WHERE dimension = " .. mysql:escape_string(id) ) then
			local res = getResourceRootElement( getResourceFromName( "dancer-system" ) )
			if res then
				for key, value in pairs( getElementsByType( "ped", res ) ) do
					if getElementDimension( value ) == id then
						destroyElement( value )
					end
				end
			end
		end

		if exports.mysql:query_free( "DELETE FROM shops WHERE dimension = " .. mysql:escape_string(id) ) then
			local res = getResourceRootElement( getResourceFromName( "npc" ) )
			if res then
				for key, value in pairs( getElementsByType( "ped", res ) ) do
					if getElementDimension( value ) == id then
						local npcID = getElementData( value, "dbid" )
						exports.mysql:query_free( "DELETE FROM `shop_products` WHERE `npcID` = " .. mysql:escape_string(npcID) )
						destroyElement( value )
					end
				end
			end
		end



		if exports.mysql:query_free( "DELETE FROM atms WHERE dimension = " .. mysql:escape_string(id) ) then
			local res = getResourceRootElement( getResourceFromName( "bank" ) )
			if res then
				for key, value in pairs( getElementsByType( "object", res ) ) do
					if getElementDimension( value ) == id then
						destroyElement( value )
					end
				end
			end
		end	

		local resE = getResourceRootElement( getResourceFromName( "elevator-system" ) )
		if resE then
			call( getResourceFromName( "elevator-system" ), "delElevatorsFromInterior", "MAXIME" , "PROPERTYCLEANUP",  id )
		end

		if not donotdestroy then
			local res1 = getResourceRootElement( getResourceFromName( "object-system" ) )
			if res1 then
				exports['object-system']:removeInteriorObjects(id)
			end
		end

		clearSafe( id, true )

		setTimer ( function ()
			call( getResourceFromName( "item-system" ), "deleteAllItemsWithinInt", id, 0, "CLEANUPINT" )
		end, 3000, 1)

	end
end

function sellProperty(thePlayer, commandName, bla)
	if bla then
		outputChatBox("Use /sell to sell this place to another player.", thePlayer, 255, 0, 0)
		return
	end

	local dbid, entrance, exit, interiorType, interiorElement = findProperty( thePlayer )
	if dbid > 0 then
		if interiorType == 2 then
			outputChatBox("You cannot sell a government property.", thePlayer, 255, 0, 0)
		elseif interiorType ~= 3 and commandName == "unrent" then
			outputChatBox("You do not rent this property.", thePlayer, 255, 0, 0)
		else
			local interiorStatus = getElementData(interiorElement, "status")
			local faction, _ = exports.factions:isPlayerInFaction(thePlayer, interiorStatus.faction)
			local leader = exports.factions:hasMemberPermissionTo(thePlayer, interiorStatus.faction, "manage_interiors")
			if interiorStatus.owner == getElementData(thePlayer, "dbid") or ( leader and faction ) then
				publicSellProperty(thePlayer, dbid, true, not interiorStatus.tokenUsed, false)
				cleanupProperty(dbid, true)
				exports.logs:dbLog(thePlayer, 37, { "in"..tostring(dbid) } , "SELLPROPERTY "..dbid)
				local addLog = mysql:query_free("INSERT INTO `interior_logs` (`intID`, `action`, `actor`) VALUES ('"..tostring(dbid).."', '"..commandName.."', '"..getElementData(thePlayer, "account:id").."')") or false
				if not addLog then
					outputDebugString("Failed to add interior logs.")
				end
			else
				outputChatBox("You do not own this property.", thePlayer, 255, 0, 0)
			end
		end
	else
		outputChatBox("You are not in a property.", thePlayer, 255, 0, 0)
	end
end
addCommandHandler("sellproperty", sellProperty, false, false)
addCommandHandler("unrent", sellProperty, false, false)

local function movePlayerToEntrance(player, entrance)
	setElementInterior(player, entrance.int)
	setCameraInterior(player, entrance.int)
	setElementDimension(player, entrance.dim)
	setElementPosition(player, entrance.x, entrance.y, entrance.z)
	exports.anticheat:changeProtectedElementDataEx(player, "interiormarker", false, false, false)
end

local function moveCharactersOutside(interiorId, onlyOffline)
	if interiorId < 1 then return end

	local dbid, entrance, exit = findProperty(nil, interiorId)

	dbQuery(function (handle)
		local results = dbPoll(handle, 0)
		local offlineCharacterIds = {}
		local playersMoved = {}

		for _, character in ipairs(results) do
			local player = getPlayerFromName(character.charactername)

			if isElement(player) and not onlyOffline then
				movePlayerToEntrance(player, entrance)
				table.insert(playersMoved, character.id, true)
			else
				table.insert(offlineCharacterIds, character.id)
			end
		end

		for _, player in pairs(getElementsByType('player')) do
			if getElementDimension(player) == interiorId and not playersMoved[player] and not onlyOffline then
				movePlayerToEntrance(player, entrance)
			end
		end

		if #offlineCharacterIds > 0 then
			dbExec(
				exports.mysql:getConn('mta'),
				"UPDATE characters SET x = ?, y = ?, z = ?, interior_id = ?, dimension_id = ? WHERE id IN (" .. table.concat(offlineCharacterIds, ', ') .. ")",
				entrance.x,
				entrance.y,
				entrance.z,
				entrance.int,
				entrance.dim
			)
		end

	end, exports.mysql:getConn('mta'), "SELECT id, charactername FROM characters WHERE dimension_id = ?", interiorId)
end

function publicSellProperty(thePlayer, dbid, showmessages, givemoney, CLEANUP)
	local dbid, entrance, exit, interiorType, interiorElement = findProperty( thePlayer, dbid )
	local query = mysql:query_free("UPDATE interiors SET owner=-1, faction=0, locked=1, tokenUsed=0, safepositionX=NULL, safepositionY=NULL, safepositionZ=NULL, safepositionRZ=NULL WHERE id='" .. dbid .. "'")
	if query then
		local interiorStatus = getElementData(interiorElement, "status")

		moveCharactersOutside(dbid)

		clearSafe( dbid, true )

		if interiorType == 0 or interiorType == 1 then
			if interiorType == 1 then
				mysql:query_free("DELETE FROM interior_business WHERE intID='" .. dbid .. "'")
			end

			local gov = exports.factions:getFactionFromID(3)

			if interiorStatus.owner == getElementData(thePlayer, "dbid") then
				local money = math.ceil(interiorStatus.cost * 2/3)
				if givemoney then
					exports.global:giveMoney(thePlayer, money)
					if exports.global:takeMoney(gov, money, true) then
						exports.bank:addBankTransactionLog(-getElementData(gov, "id"), interiorStatus.owner, money, 3 , "Interior sold to Government", getElementData(interiorElement, "name").." (ID: "..getElementData(interiorElement, "dbid")..")" )
					end
				end

				if showmessages then
					if CLEANUP == "FORCESELL" then
						exports.global:sendMessageToAdmins("[INTERIOR]: "..exports.global:getPlayerFullIdentity(thePlayer).." has force-sold interior #"..dbid.." ("..getElementData(interiorElement,"name")..").")
						exports.logs:dbLog(thePlayer, 37, { "in"..tostring(dbid) } , "FORCESELL "..dbid)
						exports["interior-manager"]:addInteriorLogs(dbid, "FORCESELL", thePlayer)
					elseif givemoney then
						outputChatBox("You sold your property for " .. exports.global:formatMoney(money) .. "$.", thePlayer, 0, 255, 0)
					else -- Token
						outputChatBox("You have sold your property in return for $0 due to this being previously purchased by an interior token.", thePlayer, 0, 255, 0)
					end
				end

				-- take all keys
				call( getResourceFromName( "item-system" ), "deleteAll", interiorType == 0 and 4 or 5, dbid )

				--triggerClientEvent(thePlayer, "removeBlipAtXY", thePlayer, interiorType, entrance.x, entrance.y, entrance.z)
			elseif exports.factions:isPlayerInFaction(thePlayer, interiorStatus.faction) then
				local money = math.ceil(interiorStatus.cost * 2/3)
				local faction = exports.factions:getFactionFromID(interiorStatus.faction)
				if givemoney and faction then
					exports.global:giveMoney(faction, money)
					if exports.global:takeMoney(gov, money, true) then
						exports.bank:addBankTransactionLog(-getElementData(gov, "id"), -interiorStatus.faction, money, 3 , "Interior sold to Government", getElementData(interiorElement, "name").." (ID: "..getElementData(interiorElement, "dbid")..")" )
					end
				end

				if showmessages then
					if CLEANUP == "FORCESELL" then
						exports.global:sendMessageToAdmins("[INTERIOR]: "..exports.global:getPlayerFullIdentity(thePlayer).." has force-sold interior #"..dbid.." ("..getElementData(interiorElement,"name")..").")
						exports.logs:dbLog(thePlayer, 37, { "in"..tostring(dbid) } , "FORCESELL "..dbid)
						exports["interior-manager"]:addInteriorLogs(dbid, "FORCESELL", thePlayer)
					elseif faction then
						if givemoney then
							outputChatBox("You sold your property for " .. exports.global:formatMoney(money) .. "$ (Transferred to the bank of '"..getTeamName(faction).."')", thePlayer, 0, 255, 0)
						else
							outputChatBox("You sold your faction property for 0$ as it was bought with a token, then set to faction.", thePlayer, 0, 255, 0)
						end
					end
				end

				-- take all keys
				call( getResourceFromName( "item-system" ), "deleteAll", interiorType == 0 and 4 or 5, dbid )
			else
				if showmessages then
					if CLEANUP == "FORCESELL" then
						exports.global:sendMessageToAdmins("[INTERIOR]: "..exports.global:getPlayerFullIdentity(thePlayer).." has force-sold interior #"..dbid.." ("..getElementData(interiorElement,"name")..").")
						exports.logs:dbLog(thePlayer, 37, { "in"..tostring(dbid) } , "FORCESELL "..dbid)
						exports["interior-manager"]:addInteriorLogs(dbid, "FORCESELL", thePlayer)
					else
						outputChatBox("You set this property to unowned.", thePlayer, 0, 255, 0)
					end
				end
			end
		else
			if showmessages then
				if CLEANUP == "FORCESELL" then
					exports.global:sendMessageToAdmins("[INTERIOR]: "..exports.global:getPlayerFullIdentity(thePlayer).." has force-sold interior #"..dbid.." ("..getElementData(interiorElement,"name")..").")
					exports.logs:dbLog(thePlayer, 37, { "in"..tostring(dbid) } , "FORCESELL "..dbid)
					exports["interior-manager"]:addInteriorLogs(dbid, "FORCESELL", thePlayer)
				else
					outputChatBox("You are no longer renting this property.", thePlayer, 0, 255, 0)
				end
			end
			-- take all keys
			call( getResourceFromName( "item-system" ), "deleteAll", interiorType == 0 and 4 or 5, dbid )
			--triggerClientEvent(thePlayer, "removeBlipAtXY", thePlayer, interiorType, entrance.x, entrance.y, entrance.z)
		end
		realReloadInterior(dbid, {thePlayer})
	else
		outputChatBox("Error 504914 - Report on bugs.owlgaming.net", thePlayer, 255, 0, 0)
	end
end

function unownProperty(intid, reason) --This function is meant to be used by the system or to be triggered from UCP remotely. Works similarly to the publicSellProperty however, it's simplier. / MAXIME / 2015.1.11
	if intid and tonumber(intid) then
		intid = tonumber(intid)
	else
		return false, "Interior is missing or invalid"
	end
	moveCharactersOutside(intid)
	--Existed or not, we take all keys anyway.
	call( getResourceFromName( "item-system" ), "deleteAll", 4 , intid )
	call( getResourceFromName( "item-system" ), "deleteAll", 5 , intid )
	--Clean up NPC, ATMs, dancers, etc in the interior but don't destroy objects if it's a custom interior.
	cleanupProperty(intid, true)
	clearSafe( intid, true )

	--Now we process in database first.
	local int = mysql:query_fetch_assoc("SELECT id, type FROM interiors WHERE id="..intid.." LIMIT 1")
	if int and int.id ~= mysql_null() then
		mysql:query_free("UPDATE interiors SET owner=-1, faction=0, locked=1, safepositionX=NULL, safepositionY=NULL, safepositionZ=NULL, safepositionRZ=NULL WHERE id='" .. intid .. "'")
		if int.type == "1" then -- if it's a business, clean up in other table too.
			mysql:query_free("DELETE FROM interior_business WHERE intID='" .. intid .. "'")
		end
	else
		return false, "Interior does not existed in database."
	end

	--Alright, it's time to give admins some clues of what just happened
	exports.logs:dbLog("SYSTEM", 37, { "in"..intid } , reason and reason or "FORCESELL")
	exports["interior-manager"]:addInteriorLogs(intid, reason and reason or "Forcesold by SYSTEM")

	--Check if interior is loaded in game
	local dbid, entrance, exit, interiorType, interiorElement = findProperty( nil, intid )
	if interiorElement then
		realReloadInterior(intid) --Reload interior and update owner's radar blips.
		return true
	else
		return true, "Interior is not loaded in game so only cleaned up in database."
	end
end

function sellTo(thePlayer, commandName, targetPlayerName)
	-- only works in dimensions
	local dbid, entrance, exit, interiorType, interiorElement = findProperty( thePlayer )
	if dbid > 0 and not isPedInVehicle( thePlayer ) then
		local interiorStatus = getElementData(interiorElement, "status")
		if interiorStatus.type == 2 then
			outputChatBox("You cannot sell a government property.", thePlayer, 255, 0, 0)
		elseif not targetPlayerName then
			outputChatBox("SYNTAX: /" .. commandName .. " [partial player name / id]", thePlayer, 255, 194, 14)
			outputChatBox("Sells the Property you're in to that Player.", thePlayer, 255, 194, 14)
			outputChatBox("Ask the buyer to use /pay to recieve the money for the Property.", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayerName)
			if targetPlayer and getElementData(targetPlayer, "dbid") then
				local px, py, pz = getElementPosition(thePlayer)
				local tx, ty, tz = getElementPosition(targetPlayer)
				if getDistanceBetweenPoints3D(px, py, pz, tx, ty, tz) < 10 and getElementDimension(targetPlayer) == getElementDimension(thePlayer) then
					if not exports.global:canPlayerBuyInterior(targetPlayer) then
						outputChatBox(targetPlayerName .. " has already too much interiors.", thePlayer, 255, 0, 0)
						outputChatBox((getPlayerName(thePlayer):gsub("_", " ")) .. " tried to sell you an interior, but you have too much interiors already.", targetPlayer, 255, 0, 0)
						return false
					end
					if interiorStatus.tokenUsed then
						outputChatBox("This interior was purchased via a token and therefore cannot be sold to other players. Use /sellproperty instead.", thePlayer, 255, 0, 0)
						return
					end

					if interiorStatus.owner == getElementData(thePlayer, "dbid") or exports.integration:isPlayerAdmin(thePlayer) then
						if getElementData(targetPlayer, "dbid") ~= interiorStatus.owner then
							if exports.global:hasSpaceForItem(targetPlayer, 4, dbid) then
								local query = mysql:query_free("UPDATE interiors SET owner = '" .. getElementData(targetPlayer, "dbid") .. "', faction=0, lastused=NOW() WHERE id='" .. dbid .. "'")
								if query then
									local keytype = 4
									if interiorType == 1 then
										keytype = 5
									end

									moveCharactersOutside(dbid, true)
									call( getResourceFromName( "item-system" ), "deleteAll", 4, dbid )
									call( getResourceFromName( "item-system" ), "deleteAll", 5, dbid )
									exports.global:giveItem(targetPlayer, keytype, dbid)

									--triggerClientEvent(thePlayer, "removeBlipAtXY", thePlayer, interiorType, entrance.x, entrance.y, entrance.z)
									--triggerClientEvent(targetPlayer, "createBlipAtXY", targetPlayer, interiorType, entrance.x, entrance.y, entrance.z)

									if interiorType == 0 or interiorType == 1 then
										outputChatBox("You've successfully sold your property to " .. targetPlayerName .. ".", thePlayer, 0, 255, 0)
										outputChatBox((getPlayerName(thePlayer):gsub("_", " ")) .. " sold you this property.", targetPlayer, 0, 255, 0)
									else
										outputChatBox(targetPlayerName .. " has taken over your rent contract.", thePlayer, 0, 255, 0)
										outputChatBox("You did take over " .. getPlayerName(thePlayer):gsub("_", " ") .. "'s renting contract.",  targetPlayer, 0, 255, 0)
									end
									exports.logs:dbLog(thePlayer, 37, { targetPlayer, "in"..tostring(dbid) } , "SELLPROPERTY "..getPlayerName(thePlayer).." => "..targetPlayerName)
									local adminID = getElementData(thePlayer, "account:id")

									realReloadInterior(dbid, {targetPlayer, thePlayer})
									exports["interior-manager"]:addInteriorLogs(dbid, commandName.." to "..targetPlayerName.."("..getElementData(targetPlayer, "account:username")..")", thePlayer)
								else
									outputChatBox("Error 09002 - Report on Forums.", thePlayer, 255, 0, 0)
								end
							else
								outputChatBox(targetPlayerName .. " has no space for the property keys.", thePlayer, 255, 0, 0)
							end
						else
							outputChatBox("You can't sell your own property to yourself.", thePlayer, 255, 0, 0)
						end
					else
						outputChatBox("This property is not yours.", thePlayer, 255, 0, 0)
					end
				else
					outputChatBox("You are too far away from " .. targetPlayerName .. ".", thePlayer, 255, 0, 0)
				end
			end
		end
	end
end
addCommandHandler("sell", sellTo)

function realReloadInterior( id, updatePlayers )
	exports.interior_load:unload( tonumber(id) )
	exports.interior_load:loadOne( id, updatePlayers )
end

function buyInterior(player, pickup, cost, isHouse, isRentable)
	if not exports.global:canPlayerBuyInterior(player) then
		outputChatBox("You have already had too much interiors.", player, 255, 0, 0)
		return false
	end

	if isRentable then
		local result = mysql:query_fetch_assoc( "SELECT COUNT(*) as 'cntval' FROM `interiors` WHERE `owner` = " .. getElementData(player, "dbid") .. " AND `type` = 3" )
		if result then
			local count = tonumber(result['cntval'])
			if count ~= 0 then
				outputChatBox("You are already renting another house.", player, 255, 0, 0)
				return
			end
		end
	elseif not exports.global:hasSpaceForItem(player, 4, 1) then
		outputChatBox("You do not have the space for the keys.", player, 255, 0, 0)
		return
	end

	if exports.global:takeMoney(player, cost) then
		if (isHouse) then
			outputChatBox("Congratulations! You have just bought this house for $" .. exports.global:formatMoney(cost) .. ".", player, 255, 194, 14)
			exports.global:giveMoney( getTeamFromName("Government of Los Santos"), cost )
		elseif (isRentable) then
			outputChatBox("Congratulations! You are now renting this property for $" .. exports.global:formatMoney(cost) .. ".", player, 255, 194, 14)
		else
			outputChatBox("Congratulations! You have just bought this business for $" .. exports.global:formatMoney(cost) .. ".", player, 255, 194, 14)
			exports.global:giveMoney( getTeamFromName("Government of Los Santos"), cost )
		end

		local charid = getElementData(player, "dbid")
		local pickupid = getElementData(pickup, "dbid")
		mysql:query_free( "UPDATE interiors SET owner='" .. charid .. "', locked=0, tokenUsed=0, lastused=NOW() WHERE id='" .. pickupid .. "'")

		local entrance = getElementData(pickup, "entrance")

		-- make sure it's an unqiue key
		call( getResourceFromName( "item-system" ), "deleteAll", 4, pickupid )
		call( getResourceFromName( "item-system" ), "deleteAll", 5, pickupid )

		if (isHouse) or (isRentable) then
			exports.global:giveItem(player, 4, pickupid)
		else
			exports.global:giveItem(player, 5, pickupid)
		end
		exports.logs:dbLog(thePlayer, 37, { "in"..tostring(pickupid) } , "BUYPROPERTY $"..cost)
		realReloadInterior(tonumber(pickupid), {player})
		exports["interior-manager"]:addInteriorLogs(pickupid, "Bought/rented, $"..exports.global:formatMoney(cost)..", "..getPlayerName(thePlayer), thePlayer)
	else
		outputChatBox("Sorry, you cannot afford to purchase this property.", player, 255, 194, 14)
	end
end

function buypropertyForFaction(interior, cost, isHouse, furniture, factionName)
	local factionId = exports.factions:getFactionIDFromName(factionName)
	local can, reason = exports.global:canPlayerFactionBuyInterior(source, nil, factionId)
	if not can then
		outputChatBox(reason, source, 255, 0, 0)
		return
	end
	local theFaction = can
	if not exports.global:takeMoney(theFaction, cost) then
		outputChatBox("Could not take money from your faction bank.", source, 255, 0, 0)
		return
	end
	local gov = getTeamFromName("Government of Los Santos")
	local intName = getElementData(interior,"name")
	local intId = getElementData(interior, "dbid")
	exports.global:giveMoney( gov, cost )
	exports.bank:addBankTransactionLog(-factionId, -(getElementData(gov, "id")), cost, 3 , "Interior Purchase", intName.." (ID: "..intId..")" )

	if not mysql:query_free( "UPDATE interiors SET owner='-1', faction='"..factionId.."', locked=0, tokenUsed=0, lastused=NOW(), furniture="..(furniture and 1 or 0).." WHERE id='" .. intId .. "'") then
		exports.global:giveMoney(theFaction, cost)
		exports.global:takeMoney( gov, cost )
		outputChatBox("Internal error code 334INT2.", source, 255, 0, 0)
		return false
	end
	local factionName = getTeamName(theFaction):gsub("_", " ")
	outputChatBox("Congratulations! You have just bought this property for your faction '"..factionName.."' for $" .. exports.global:formatMoney(cost) .. ".", source, 255, 194, 14)

	exports['item-system']:deleteAll( isHouse and 4 or 5, intId )
	exports.global:giveItem(source, isHouse and 4 or 5, intId)

	exports.logs:dbLog(source, 37, { "in"..tostring(intId) } , "BUYPROPERTY $"..cost.." FOR FACTION '"..factionName.."'")
	exports["interior-manager"]:addInteriorLogs(intId, "Bought for faction '"..factionName.."', $"..exports.global:formatMoney(cost)..", "..getPlayerName(source), source)

	-- blips
	local entrance = getElementData(interior, "entrance")
	triggerLatentClientEvent(source, "createBlipAtXY", source, entrance.type, entrance.x, entrance.y)

	exports.achievement:playSoundFx(source)

	realReloadInterior(tonumber(intId))
	return true
end
addEvent( "buypropertyForFaction", true )
addEventHandler( "buypropertyForFaction", getRootElement( ), buypropertyForFaction)

function buyInteriorCash(pickup, cost, isHouse, isRentable, furniture)
	if not exports.global:canPlayerBuyInterior(client) then
		outputChatBox("You have already reached the maximum number of interiors. You can extend your max interiors in F10 -> Premium Features.", client, 255, 0, 0)
		return
	end

	if isRentable then
		local result = mysql:query_fetch_assoc( "SELECT COUNT(*) as 'cntval' FROM `interiors` WHERE `owner` = " .. getElementData(client, "dbid") .. " AND `type` = 3" )
		if result then
			local count = tonumber(result['cntval'])
			if count ~= 0 then
				outputChatBox("You are already renting another house.", client, 255, 0, 0)
				return
			end
		end
	elseif not exports.global:hasSpaceForItem(client, 4, 1) then
		outputChatBox("You do not have the space for the keys.", client, 255, 0, 0)
		return
	end

	if exports.global:takeMoney(client, cost) then
		local charid = getElementData(client, "dbid")
		local pickupid = getElementData(pickup, "dbid")
		local intName = getElementData(pickup, "name")
		local gov = getTeamFromName("Government of Los Santos")
		if (isHouse) then
			outputChatBox("Congratulations! You have just bought this house for $" .. exports.global:formatMoney(cost) .. ".", client, 255, 194, 14)
			exports.global:giveMoney( gov, cost )
			exports.bank:addBankTransactionLog(charid, -(getElementData(gov, "id")), cost, 5 , "Interior Purchase", intName.." (ID: "..pickupid..")" )
		elseif (isRentable) then
			outputChatBox("Congratulations! You are now renting this property for $" .. exports.global:formatMoney(cost) .. ".", client, 255, 194, 14)
		else
			outputChatBox("Congratulations! You have just bought this business for $" .. exports.global:formatMoney(cost) .. ".", client, 255, 194, 14)
			exports.global:giveMoney( getTeamFromName("Government of Los Santos"), cost )
			exports.bank:addBankTransactionLog(charid, -(getElementData(gov, "id")), cost, 5 , "Interior Purchase", intName.." (ID: "..pickupid..")" )
		end

		mysql:query_free( "UPDATE interiors SET owner='" .. charid .. "', locked=0, tokenUsed=0, lastused=NOW(), furniture="..(furniture and 1 or 0).." WHERE id='" .. pickupid .. "'")

		exports['item-system']:deleteAll( isHouse and 4 or 5, pickupid )
		exports.global:giveItem(client, isHouse and 4 or 5, pickupid)

		exports.logs:dbLog(client, 37, { "in"..tostring(pickupid) } , "BUYPROPERTY $"..cost)

		exports["interior-manager"]:addInteriorLogs(pickupid, "Bought/rented, $"..exports.global:formatMoney(cost)..", "..getPlayerName(client), client)
		-- blips.
		local entrance = getElementData(pickup, "entrance")
		triggerLatentClientEvent(client, "createBlipAtXY", client, entrance.type, entrance.x, entrance.y)

		realReloadInterior(tonumber(pickupid), {client})
	else
		outputChatBox("Sorry, you cannot afford to purchase this property.", client, 255, 194, 14)
	end
end
addEvent( "buypropertywithcash", true )
addEventHandler( "buypropertywithcash", getRootElement( ), buyInteriorCash)

function buyInteriorBank(pickup, cost, isHouse, isRentable, furniture)
	if not exports.global:canPlayerBuyInterior(client) then
		outputChatBox("You have already reached the maximum number of interiors. You can extend your max interiors in F10 -> Premium Features.", client, 255, 0, 0)
		return
	end


	if isRentable then
		local result = mysql:query_fetch_assoc( "SELECT COUNT(*) as 'cntval' FROM `interiors` WHERE `owner` = " .. getElementData(client, "dbid") .. " AND `type` = 3" )
		if result then
			local count = tonumber(result['cntval'])
			if count ~= 0 then
				outputChatBox("You are already renting another house.", client, 255, 0, 0)
				return
			end
		end
	elseif not exports.global:hasSpaceForItem(client, 4, 1) then
		outputChatBox("You do not have the space for the keys.", client, 255, 0, 0)
		return
	end

	if not exports.bank:takeBankMoney(client, cost) then
		outputChatBox( "You lack the money in your bank to buy this property", client, 255, 0, 0 )
	else
		local charid = getElementData(client, "dbid")
		local pickupid = getElementData(pickup, "dbid")
		local gov = getTeamFromName("Government of Los Santos")
		local intName = getElementData(pickup, "name")
		if (isHouse) then
			outputChatBox("Congratulations! You have just bought this house for $" .. exports.global:formatMoney(cost) .. ".", client, 255, 194, 14)
			exports.global:giveMoney( gov, cost )
		elseif (isRentable) then
			outputChatBox("Congratulations! You are now renting this property for $" .. exports.global:formatMoney(cost) .. ".", client, 255, 194, 14)
		else
			outputChatBox("Congratulations! You have just bought this business for $" .. exports.global:formatMoney(cost) .. ".", client, 255, 194, 14)
			exports.global:giveMoney( gov, cost )
		end

		exports.bank:addBankTransactionLog(charid, -(getElementData(gov, "id")), cost, 2 , "Interior Purchase", intName.." (ID: "..pickupid..")" )
		mysql:query_free( "UPDATE interiors SET owner='" .. charid .. "', locked=0, lastused=NOW(), tokenUsed=0, furniture="..(furniture and 1 or 0).." WHERE id='" .. pickupid .. "'")

		exports['item-system']:deleteAll( isHouse and 4 or 5, pickupid )
		exports.global:giveItem(client, isHouse and 4 or 5, pickupid)

		exports.logs:dbLog(client, 37, { "in"..tostring(pickupid) } , "BUYPROPERTY $"..cost)
		exports["interior-manager"]:addInteriorLogs(pickupid, "Bought/rented, $"..exports.global:formatMoney(cost)..", "..getPlayerName(client), client)

		-- create client blip.
		local entrance = getElementData( pickup, "entrance" )
		triggerLatentClientEvent(client, "createBlipAtXY", client, entrance.type, entrance.x, entrance.y)

		realReloadInterior(tonumber(pickupid), {client})
	end
end
addEvent( "buypropertywithbank", true )
addEventHandler( "buypropertywithbank", getRootElement( ), buyInteriorBank)

function buyInteriorToken(pickup, furniture)
	if not exports.global:canPlayerBuyInterior(client) then
		outputChatBox("You have already reached the maximum number of interiors. You can extend your max interiors in F10 -> Premium Features.", client, 255, 0, 0)
		return
	end


	if not exports.global:hasSpaceForItem(client, 4, 1) then
		outputChatBox("You do not have the space for the keys.", client, 255, 0, 0)
		return
	end

	if not exports.global:takeItem(client, 262) then
		outputChatBox( "You do not have a token to buy this property", client, 255, 0, 0 )
	else
		local charid = getElementData(client, "dbid")
		local pickupid = getElementData(pickup, "dbid")
		outputChatBox("Congratulations! You have just used a token to purchase this house, remember this house holds no cash value and you cannot sell it to friends.", client, 255, 194, 14)

		mysql:query_free( "UPDATE interiors SET owner='" .. charid .. "', locked=0, lastused=NOW(), furniture="..(furniture and 1 or 0).." , tokenUsed=1 WHERE id='" .. pickupid .. "'")

		exports['item-system']:deleteAll(4, pickupid )
		exports.global:giveItem(client, 4, pickupid)

		exports.logs:dbLog(client, 37, { "in"..tostring(pickupid) } , "BUYPROPERTY TOKEN USED")
		exports["interior-manager"]:addInteriorLogs(pickupid, "Bought - TOKEN, "..getPlayerName(client), client)

		-- create client blip.
		local entrance = getElementData( pickup, "entrance" )
		triggerLatentClientEvent(client, "createBlipAtXY", client, entrance.type, entrance.x, entrance.y)

		realReloadInterior(tonumber(pickupid), {client})
	end
end
addEvent( "buypropertywithtoken", true )
addEventHandler( "buypropertywithtoken", getRootElement( ), buyInteriorToken)
--[[
function vehicleStartEnter(thePlayer)
	local marker = getElementData(thePlayer, "interiormarker")
	local x, y, z = getElementPosition(thePlayer)
	if marker then
		cancelEvent()
	end
end
addEventHandler("onVehicleStartEnter", root, vehicleStartEnter)
addEventHandler("onVehicleStartExit", root, vehicleStartEnter)]]

-- I guess I'll test this on my local server before we put it in, make sure miniguns dont fall from the sky and everyone turns into a clown. -Bean
--[[function vehicleStartEnter(thePlayer)
	local marker = getElementData(thePlayer, "interiormarker")
	local x, y, z = getElementPosition(thePlayer)
	local lastDistance = 1 -- This is the distanceBetweenPoints3D, I'm sure we could make it less, but this should do if they are on the interior marker, right?
	for _, interior in ipairs(possibleInteriors) do
		local entrance = getElementData(interior, "entrance")
		local interiorExit = getElementData(interior, "exit")
		local posX, posY, posZ = getElementPosition(thePlayer)
		local dimension = getElementDimension(thePlayer)
		for _, point in ipairs( { entrance, interiorExit } ) do
			if (point[5] == dimension) then
				local distance = getDistanceBetweenPoints3D(posX, posY, posZ, point[1], point[2], point[3])
				if (distance < lastDistance) then
					found = interior -- Set it to the interior ID so that it knows there's something there.
					lastDistance = distance
				end
			end
		end
	end
	if marker and found then -- If it's there, then you cancel, not just because the event wants us to.
		cancelEvent()
	else
		exports.anticheat:changeProtectedElementDataEx(thePlayer, "interiormarker", nil, nil, nil) -- If it's not found, then let them enter the car, and clear the element data so it's not there anymore.
	end
end
addEventHandler("onVehicleStartEnter", root, vehicleStartEnter)
addEventHandler("onVehicleStartExit", root, vehicleStartEnter)]]


function enterInterior(  )

	if source and client then
		local canEnter, errorCode, errorMsg = canEnterInterior(source)	-- Checks for disabled and locked ints.
		if canEnter then
			setPlayerInsideInterior( source, client )
		elseif isInteriorForSale(source) then
			local interiorStatus = getElementData(source, "status")
			local cost = interiorStatus.cost
			local isHouse = interiorStatus.type == 0
			local isRentable = interiorStatus.type == 3
			local neighborhood = exports.global:getElementZoneName(source)
			triggerClientEvent(client, "openPropertyGUI", client, source, cost, isHouse, isRentable, neighborhood)
			--buyInterior(client, source, cost, isHouse, isRentable)
		else
			outputChatBox(errorMsg, client, 255, 0, 0)
		end
	end

end
addEvent("interior:enter", true)
addEventHandler("interior:enter", root, enterInterior)

local interiorTimer = {}
function setPlayerInsideInterior(theInterior, thePlayer, teleportTo, sameInt, elevator)
	if interiorTimer[thePlayer] or not theInterior then
		return false
	end
	interiorTimer[thePlayer] = true
	local enter = true
	if not teleportTo then
		local pedCurrentDimension = getElementDimension( thePlayer )
		local entrance = getElementData(theInterior, "entrance")
		local interiorExit = getElementData(theInterior, "exit")
		if ((entrance.dim or entrance[INTERIOR_DIM]) == pedCurrentDimension) then
			teleportTo = interiorExit
			enter = true
		else
			teleportTo = entrance
			enter = false
		end
	end
	if ( teleportTo.dim or teleportTo[INTERIOR_DIM] ) ~= 0 then
		furniture = getElementData(theInterior, "status").furniture
		switchGroundSnow(thePlayer, false )
	else
		switchGroundSnow(thePlayer, true)
	end

	if isElement(elevator) and getElementType(elevator) == "elevator" then
		doorGoThru(elevator, thePlayer)
	else
		doorGoThru(theInterior, thePlayer)
	end

	teleportTo = tempFix( teleportTo )

	triggerClientEvent(thePlayer, "CantFallOffBike", thePlayer)
	triggerClientEvent(thePlayer, "setPlayerInsideInterior", theInterior, teleportTo, theInterior, furniture)
	setElementInterior(thePlayer, teleportTo.int)
	setElementDimension(thePlayer, teleportTo.dim)
	if teleportTo.rot then
		setElementRotation(thePlayer, 0, 0, teleportTo.rot)
	end
	setElementPosition(thePlayer, teleportTo.x, teleportTo.y, teleportTo.z, true)
	
	if sameInt and interiorTimer[thePlayer] then
		interiorTimer[thePlayer] = false
	end

	local dbid = getElementData(theInterior, "dbid")
	mysql:query_free("UPDATE `interiors` SET `lastused`=NOW() WHERE `id`='" .. mysql:escape_string(dbid) .. "'")
	setElementData(theInterior, "lastused", exports.datetime:now(), true)

	--Alright, it's time to give admins some clues of what just happened
	exports.logs:dbLog(thePlayer, 31, { theInterior, thePlayer } , enter and "ENTERED" or "EXITED")
	exports["interior-manager"]:addInteriorLogs(dbid, enter and "Entered" or "Exited", thePlayer)
	return true
end

addEventHandler("onPlayerInteriorChange", getRootElement( ),
	function( toInterior, toDimension)
		setElementAlpha(client, getElementData(client, "invisible") and 0 or 255)
		interiorTimer[client] = false
	end
)

-- NOT CONVERTED
function setPlayerInsideInterior2(theInterior, thePlayer)
	local teleportTo = nil
	-- does the player want to go in?
	local pedCurrentDimension = getElementDimension( thePlayer )
	local entrance = getElementData(theInterior, "entrance")
	local interiorExit = getElementData(theInterior, "exit")
	local interiorStatus = getElementData(theInterior, "status")
	if (entrance.dim == pedCurrentDimension) then
		-- We've passed the feecheck, yet we still want to go inside.
		teleportTo = interiorExit
	else
		-- We'd like to leave this building, kthxhopefullybye.
		teleportTo = entrance
	end

	if teleportTo then
		triggerClientEvent(thePlayer, "setPlayerInsideInterior2", theInterior, teleportTo, theInterior, interiorStatus.furniture)
		if teleportTo.dim == 0 then
			switchGroundSnow(thePlayer, true)
		else
			switchGroundSnow(thePlayer, false)
		end

		setElementInterior(thePlayer, teleportTo.int)
		setElementDimension(thePlayer, teleportTo.dim)

		doorGoThru(theInterior, thePlayer)
		local dbid = getElementData(theInterior, "dbid")
		mysql:query_free("UPDATE `interiors` SET `lastused`=NOW() WHERE `id`='" .. mysql:escape_string(dbid) .. "'")
		setElementData(theInterior, "lastused", exports.datetime:now(), true)
	end
end

--Altered version to work with vehicle interiors and multi-floor elevators.
function setPlayerInsideInterior3(theInterior, thePlayer, teleportTo, sameInt, elevator, camerafade)
	if interiorTimer[thePlayer] then
		return false
	end
	interiorTimer[thePlayer] = true
	local enter = true
	if not teleportTo then
		return false
	end
	local dbid

	if camerafade then
		fadeCamera(thePlayer, false)
	end

	if teleportTo.int > 0 and teleportTo.dim > 0 then
		if teleportTo.dim > 20000 then --vehicle interior
			if not theVehicle then
				theVehicle = exports.pool:getElement("vehicle", teleportTo.dim-20000) or false
			end
			dbid = teleportTo.dim - 20000
			mysql:query_free("UPDATE `vehicles` SET `lastUsed`=NOW() WHERE `id`='" .. mysql:escape_string(dbid) .. "'")
			if theVehicle then
				setElementData(theVehicle, "lastused", exports.datetime:now(), true)
			end
		else
			if not theInterior then
				theInterior = exports.pool:getElement("interior", teleportTo.dim) or false
			end
			dbid = teleportTo.dim
			mysql:query_free("UPDATE `interiors` SET `lastused`=NOW() WHERE `id`='" .. mysql:escape_string(dbid) .. "'")
			if theInterior then
				setElementData(theInterior, "lastused", exports.datetime:now(), true)
			end
		end
	else
		theInterior = false
		theVehicle = false
	end
	-- If they are leaving an interior, mark that inteiror as active
	local playerDim = getElementDimension(thePlayer)
	if playerDim ~= 0 then
		if playerDim > 20000 then
			local playerInterior = exports.pool:getElement("vehicle", teleportTo.dim-20000) or false
			mysql:query_free("UPDATE `vehicles` SET `lastused`=NOW() WHERE `id`='" .. mysql:escape_string(playerDim-20000) .. "'")
			if playerInterior then
				setElementData(playerInterior, "lastused", exports.datetime:now(), true)
			end
		else
			local playerInterior = exports.pool:getElement("interior", playerDim) or false
			mysql:query_free("UPDATE `interiors` SET `lastused`=NOW() WHERE `id`='" .. mysql:escape_string(playerDim) .. "'")
			if playerInterior then
				setElementData(playerInterior, "lastused", exports.datetime:now(), true)
			end
		end
	end

	if theInterior then
		furniture = getElementData(theInterior, "status").furniture
		switchGroundSnow(thePlayer, false)
	else
		if theVehicle then
			switchGroundSnow(thePlayer, false)
		else
			switchGroundSnow(thePlayer, true)
		end
	end

	triggerClientEvent(thePlayer, "CantFallOffBike", thePlayer)
	triggerClientEvent(thePlayer, "setPlayerInsideInterior", thePlayer, teleportTo, theInterior, furniture, camerafade)
	setElementInterior(thePlayer, teleportTo.int)
	setElementDimension(thePlayer, teleportTo.dim)
	if teleportTo.rot then
		setElementRotation(thePlayer, 0, 0, teleportTo.rot)
	end
	setElementPosition(thePlayer, teleportTo.x, teleportTo.y, teleportTo.z, true)

	--Alright, it's time to give admins some clues of what just happened
	if theInterior and dbid then
		exports.logs:dbLog(thePlayer, 31, { theInterior, thePlayer } , enter and "ENTERED" or "EXITED")
		exports["interior-manager"]:addInteriorLogs(dbid, enter and "Entered" or "Exited", thePlayer)
	end
	return true
end

function moveSafe ( thePlayer, commandName )
	local x,y,z = getElementPosition( thePlayer )
	local rotz = getPedRotation( thePlayer )
	local dbid = getElementDimension( thePlayer )
	local interior = getElementInterior( thePlayer )
	if (dbid < 19000 and (exports.global:hasItem( thePlayer, 5, dbid ) or exports.global:hasItem( thePlayer, 4, dbid))) or (dbid >= 20000 and exports.global:hasItem(thePlayer, 3, dbid - 20000)) then
		if getPedContactElement(thePlayer) == safeTable[dbid] or getPedContactElement(thePlayer) == exports.vehicle:getSafe(dbid-20000) then
            outputChatBox("Please move to a new position before repositioning a safe.", thePlayer, 255, 0, 0)
        else
			z = z - 0.5
			rotz = rotz + 180
			if dbid >= 20000 and exports.vehicle:getSafe(dbid-20000) then
				local safe = exports.vehicle:getSafe(dbid-20000)
				exports.mysql:query_free("UPDATE vehicles SET safepositionX='" .. x .. "', safepositionY='" .. y .. "', safepositionZ='" .. z .. "', safepositionRZ='" .. rotz .. "' WHERE id='" .. (dbid-20000) .. "'")
				setElementPosition(safe, x, y, z)
				setObjectRotation(safe, 0, 0, rotz)
			elseif dbid > 0 and getSafe( dbid ) then
				if not updateSafe( dbid, { x, y, z }, rotz ) then
					outputChatBox("Errors occurred while moving safe.", thePlayer, 255, 0, 0)
				end
			else
				outputChatBox("You need a safe to move!", thePlayer, 255, 0, 0)
			end
		end
	else
		outputChatBox("You need the keys of this interior to move the Safe.", thePlayer, 255, 0, 0)
	end
	outputChatBox("WARNING: These types of Safes are deprecated. You can buy a Storage Generic Safe from any Electronic stores.", thePlayer, 255, 0, 0)
end
addCommandHandler("movesafe", moveSafe)


local function hasKey( source, key )
	if exports.global:hasItem(source, 4, key) or exports.global:hasItem(source, 5,key) then
		return true, false
	else
		if getElementData(source, "duty_admin") == 1 then
			return true, true
		else
			return false, false
		end
	end
	return false, false
end


function lockUnlockHouseEvent(player, checkdistance)
	if (player) then
		source = player
	end
	local itemValue = nil
	local found = nil
	local foundpoint = nil
	local minDistance = 2
	local interiorName = ""
	local pPosX, pPosY, pPosZ = getElementPosition(source)
	local dimension = getElementDimension(source)

	local canEnter, byAdmin = nil

	local possibleInteriors = exports.pool:getPoolElementsByType("interior")
	for _, interior in ipairs(possibleInteriors) do
		local entrance = getElementData(interior, "entrance")
		local interiorExit = getElementData(interior, "exit")
		for _, point in ipairs( { entrance, interiorExit } ) do
			if (point.dim == dimension) then
				local distance = getDistanceBetweenPoints3D(pPosX, pPosY, pPosZ, point.x, point.y, point.z) or 20
				if (distance < minDistance) then
					local interiorID = getElementData(interior, "dbid")
					canEnter, byAdmin = hasKey(source, interiorID)
					if canEnter then -- house found
						found = interior
						foundpoint = point
						itemValue = interiorID
						minDistance = distance
						interiorName = getElementData(interior, "name")
					end
				end
			end
		end
	end

	-- For elevators already
	local possibleElevators = exports.pool:getPoolElementsByType("elevator")
	for _, elevator in ipairs(possibleElevators) do
		local elevatorEntrance = tempFix( getElementData(elevator, "entrance") )
		local elevatorExit = tempFix( getElementData(elevator, "exit") )

		for _, point in ipairs( { elevatorEntrance, elevatorExit } ) do
			if (point.dim == dimension) then
				local distance = getDistanceBetweenPoints3D(pPosX, pPosY, pPosZ, point.x, point.y, point.z)
				if (distance < minDistance) then
					if hasKey(source, elevatorEntrance.dim) and elevatorEntrance.dim ~= 0 then
						found = elevator
						foundpoint = point
						itemValue = elevatorEntrance.dim
						minDistance = distance
					elseif hasKey(source, elevatorExit.dim) and elevatorExit.dim ~= 0  then
						found = elevator
						foundpoint = point
						itemValue = elevatorExit.dim
						minDistance = distance
					end
				end
			end
		end
	end

	if (checkdistance) then
		return found, minDistance
	end

	if found and itemValue then
		local dbid, entrance, exit, interiorType, interiorElement = findProperty( source, itemValue )
		local playSoundAt = getElementType(found) == "elevator" and found or interiorElement

		if getElementData(interiorElement, "keypad_lock") then
			if not (exports.integration:isPlayerTrialAdmin(source) and getElementData(source, "duty_admin") == 1) then
				exports.hud:sendBottomNotification(source, "Keyless Digital Door Lock", "This door is keyless, you must use the keypad to access it.")
				return false
			end
		end


		local interiorStatus = getElementData(interiorElement, "status")
		local locked = interiorStatus.locked and 1 or 0

		locked = 1 - locked -- Invert status


		local newRealLockedValue = false
		mysql:query_free("UPDATE interiors SET locked='" .. mysql:escape_string(locked) .. "'  WHERE id='" .. mysql:escape_string(itemValue) .. "' LIMIT 1")
		if locked == 0 then
			doorUnlockSound(playSoundAt, source)
			if byAdmin then
				if getElementData(source, "hiddenadmin") == 0 then
					local adminTitle = exports.global:getPlayerAdminTitle(source)
					local adminUsername = getElementData(source, "account:username")
					exports.global:sendMessageToAdmins("[INTERIOR]: "..adminTitle.." ".. getPlayerName(source):gsub("_", " ").. " ("..adminUsername..") has unlocked Interior ID #"..itemValue.." without key.")
					exports.global:sendLocalText(source, " * The door should now be open. *", 255, 51, 102, 30, {}, true)
					exports["interior-manager"]:addInteriorLogs(itemValue, "unlock without key", source)
				end
			else
				triggerEvent('sendAme', source, "puts the key in the door to unlock it.")
			end
			exports.logs:dbLog(source, 31, {  "in"..tostring(itemValue) }, "UNLOCK INTERIOR")
		else --shit
			doorLockSound(playSoundAt, source)
			newRealLockedValue = true
			if byAdmin then
				if getElementData(source, "hiddenadmin") == 0 then
					local adminTitle = exports.global:getPlayerAdminTitle(source)
					local adminUsername = getElementData(source, "account:username")
					exports.global:sendMessageToAdmins("[INTERIOR]: "..adminTitle.." ".. getPlayerName(source):gsub("_", " ").. " ("..adminUsername..") has locked Interior ID #"..itemValue.." without key.")
					exports.global:sendLocalText(source, " * The door should now be locked. *", 255, 51, 102, 30, {}, true)
					exports["interior-manager"]:addInteriorLogs(itemValue, "lock without key", source)
				end
			else
				triggerEvent('sendAme', source, "puts the key in the door to lock it.")
			end
			exports.logs:dbLog(source, 31, {  "in"..tostring(itemValue) }, "LOCK INTERIOR")
		end

		interiorStatus.locked = newRealLockedValue
		exports.anticheat:changeProtectedElementDataEx(interiorElement, "status", interiorStatus, true)
	else
		cancelEvent( )
	end
end
addEvent( "lockUnlockHouse",false )
addEventHandler( "lockUnlockHouse", root, lockUnlockHouseEvent)

addEvent( "lockUnlockHouseID",true )
addEventHandler( "lockUnlockHouseID", root,
	function( id, usingKeypad, playSoundAt )
		local hasKey1, byAdmin = hasKey(source, id)
		if id and tonumber(id) and (hasKey1 or usingKeypad) then
			local result = mysql:query_fetch_assoc( "SELECT 1-locked as 'val' FROM interiors WHERE id = " .. id)
			local locked = 0
			if result then
				locked = tonumber( result["val"] )
			end
			local newRealLockedValue = false
			mysql:query_free("UPDATE interiors SET locked='" .. locked .. "' WHERE id='" .. id .. "' LIMIT 1")

			if not usingKeypad then
				local dbid, entrance, exit, interiorType, interiorElement = findProperty( source, id )
				if not isElement(playSoundAt) or getElementType(playSoundAt) ~= "elevator" then
					playSoundAt = interiorElement
				end

				--outputDebugString(getElementData(interiorElement, "keypad_lock"))
				if getElementData(interiorElement, "keypad_lock") then
					if not (exports.integration:isPlayerTrialAdmin(source) and getElementData(source, "duty_admin") == 1) then
						exports.hud:sendBottomNotification(source, "Keyless Digital Door Lock", "This door is keyless, you must use the keypad to access it.")
						return false
					end
				end

				if locked == 0 then
					if byAdmin then
						if getElementData(source, "hiddenadmin") == 0 then
							local adminTitle = exports.global:getPlayerAdminTitle(source)
							local adminUsername = getElementData(source, "account:username")
							exports.global:sendMessageToAdmins("[INTERIOR]: "..adminTitle.." ".. getPlayerName(source):gsub("_", " ").. " ("..adminUsername..") has unlocked Interior ID #"..id.." without key.")
							exports.global:sendLocalText(source, " * The door should now be open. *", 255, 51, 102, 30, {}, true)
							exports["interior-manager"]:addInteriorLogs(id, "unlock without key", source)
						end
					else
						triggerEvent('sendAme', source, "puts the key in the door to unlock it.")
					end
					exports.logs:dbLog(source, 31, {  "in"..tostring(id) }, "UNLOCK INTERIOR")
				else
					newRealLockedValue = true
					if byAdmin then
						if getElementData(source, "hiddenadmin") == 0 then
							local adminTitle = exports.global:getPlayerAdminTitle(source)
							local adminUsername = getElementData(source, "account:username")
							exports.global:sendMessageToAdmins("[INTERIOR]: "..adminTitle.." ".. getPlayerName(source):gsub("_", " ").. " ("..adminUsername..") has locked Interior ID #"..id.." without key.")
							exports.global:sendLocalText(source, " * The door should now be locked. *", 255, 51, 102, 30, {}, true)
							exports["interior-manager"]:addInteriorLogs(id, "lock without key", source)
						end
					else
						triggerEvent('sendAme', source, "puts the key in the door to lock it.")
					end
					exports.logs:dbLog(source, 31, {  "in"..tostring(id) }, "LOCK INTERIOR")
				end

				if interiorElement then
					local interiorStatus = getElementData(interiorElement, "status")
					interiorStatus.locked = newRealLockedValue
					exports.anticheat:changeProtectedElementDataEx(interiorElement, "status", interiorStatus, true)
					if newRealLockedValue then
						doorLockSound(playSoundAt, source)
					else
						doorUnlockSound(playSoundAt, source)
					end
				end
			else
				if locked == 0 then
					triggerEvent('sendAme', source, "unlocks the door.")
					exports.logs:dbLog(source, 31, {  "in"..tostring(id) }, "UNLOCK INTERIOR")
				else
					newRealLockedValue = true
					triggerEvent('sendAme', source, "locks the door.")
					exports.logs:dbLog(source, 31, {  "in"..tostring(id) }, "LOCK INTERIOR")
				end

				local dbid, entrance, exit, interiorType, interiorElement = findProperty( source, id )
				if not isElement(playSoundAt) or getElementType(playSoundAt) ~= "elevator" then
					playSoundAt = interiorElement
				end

				if interiorElement then
					local interiorStatus = getElementData(interiorElement, "status")
					interiorStatus.locked = newRealLockedValue
					exports.anticheat:changeProtectedElementDataEx(interiorElement, "status", interiorStatus, true)
					if newRealLockedValue then
						doorLockSound(playSoundAt, source)
					else
						doorUnlockSound(playSoundAt, source)
					end
				end
				triggerClientEvent(source, "keypadRecieveResponseFromServer", source, locked == 0 and "unlocked" or "locked", false)
			end
		else
			cancelEvent( )
		end
	end
)


function findParent( element, dimension )
	local dbid, entrance, exit, type, interiorElement = findProperty( element, dimension )
	return interiorElement
end

function client_requestHUDinfo()
	-- Client = client
	-- Source = interior element
	if not isElement(source) or (getElementType(source) ~= "interior" and getElementType(source) ~= "elevator") then
		return false
	end

	local theVehicle = getPedOccupiedVehicle(client)
	if theVehicle and (getVehicleOccupant ( theVehicle, 0 ) ~= client) then
		return false
	end

	exports.anticheat:changeProtectedElementDataEx( client, "interiormarker", true, false, false )

	local interiorID, interiorName, interiorStatus, entrance, interiorExit = nil
	if getElementType(source) == "elevator" then
		local playerDimension = getElementDimension(client)
		local elevatorEntranceDimension = getElementData(source, "entrance").dim
		local elevatorExitDimension = getElementData(source, "exit").dim
		if playerDimension ~= elevatorEntranceDimension and elevatorEntranceDimension ~= 0 then
			local dbid, entrance, exit, type, interiorElement = findProperty( client, elevatorEntranceDimension )
			if dbid and interiorElement then
				interiorID = getElementData(interiorElement, "dbid")
				interiorName = getElementData(interiorElement,"name")
				interiorStatus = getElementData(interiorElement, "status")
				entrance = getElementData(interiorElement, "entrance")
				interiorExit = getElementData(interiorElement, "exit")
			end
		elseif elevatorExitDimension ~= 0 then
			local dbid, entrance, exit, type, interiorElement = findProperty( client, elevatorExitDimension )
			if dbid and interiorElement then
				interiorID = getElementData(interiorElement, "dbid")
				interiorName = getElementData(interiorElement,"name")
				interiorStatus = getElementData(interiorElement, "status")
				entrance = getElementData(interiorElement, "entrance")
				interiorExit = getElementData(interiorElement, "exit")
			end
		end
		if not dbid then
			interiorID = -1
			interiorName = "None"
			interiorStatus = { }
			entrance = { }
			interiorStatus.type = 2
			interiorStatus.cost = 0
			interiorStatus.owner = -1
			entrance.fee = 0
		end
	else
		interiorName = getElementData(source,"name")
		interiorStatus = getElementData(source, "status")
		entrance = getElementData(source, "entrance")
		interiorExit = getElementData(source, "exit")
	end

	local interiorOwnerName = exports['cache']:getCharacterName(interiorStatus.owner) or "None"
	local interiorType = interiorStatus.type or 2
	local interiorCost = interiorStatus.cost or 0
	local interiorBizNote = getElementData(source, "business:note") or false

	triggerClientEvent(client, "displayInteriorName", source, interiorName or "Elevator", interiorOwnerName, interiorType or 2, interiorCost or 0, interiorID or -1, interiorBizNote)
	--INTERIOR PREVIEW / MAXIME
	--[[
	if interiorName == "None" and (interiorType == 3 or interiorType <2) then -- IF FOR SALE INT
		setElementData(client, "official-interiors:showIntPreviewer", true, true)
		setElementData(client, "official-interiors:showIntPreviewer:ForSale", true, true)
	end
	]]
end
addEvent("interior:requestHUD", true)
addEventHandler("interior:requestHUD", root, client_requestHUDinfo)

addEvent("int:updatemarker", true)
addEventHandler("int:updatemarker", root,
	function( newState )
		exports.anticheat:changeProtectedElementDataEx(client, "interiormarker", newState, false, true) -- No sync at all: function is only called from client thusfar has the actual state itself
	end
)


--
-- Previewing interiors
--

local interiorPreviews = {}

function timedInteriorView(houseID)
	local dbid, entrance, exit, type, interiorElement = findProperty( client, houseID )
	if entrance then
		if interiorPreviews[client] then
			endTimedInteriorView(client)
		end

		setPlayerInsideInterior(interiorElement, client)
		outputChatBox( "You are now viewing this property. You will be unable to drop any items. You may exit your viewing by leaving the interior, or wait for the 60 second timer.", client, 0, 255, 0)

		-- this is mainly used for saving the position correctly if the player logs out; and is used in s_saveplayer_system.lua.
		setElementData(client, "viewingInterior", { getElementDimension(client), getElementInterior(client), getElementPosition(client)}, true)

		if getElementDimension(client) > 0 then
			setElementData(client, "canFly", true)
			outputChatBox( "If you'd like to see the interior from more angles, use /freecam for a better view.", client, 0, 255, 0 )
		end

		interiorPreviews[client] = {
			timer = setTimer(function(player)
				endTimedInteriorView(player)
			end, 60000, 1, client),
			houseID = houseID
		}
	else
		outputChatBox( "Invalid House.", client, 255, 0, 0 )
	end
end
addEvent("viewPropertyInterior", true)
addEventHandler("viewPropertyInterior", root, timedInteriorView)

function endTimedInteriorView(thePlayer, changedCharacter )
	if client and thePlayer ~= client then return end

	local info = interiorPreviews[thePlayer]
	local pos = getElementData(thePlayer, "viewingInterior")

	if info and isTimer(info.timer) then
		killTimer(info.timer)
	end

	-- if we logged out inbetween, pos would be not set.
	if info and pos then
		local houseID = info.houseID
		local dbid, entrance, exit, type, interiorElement = findProperty( thePlayer, houseID )
		if entrance then
			if not changedCharacter then
				setPlayerInsideInterior(interiorElement, thePlayer)
			end
			
			setElementData(thePlayer, "canFly", false)
			setElementData(thePlayer, "superman:flying", false)
			if exports.freecam:isPlayerFreecamEnabled(thePlayer) then
				exports.freecam:setPlayerFreecamDisabled(thePlayer)
				setElementFrozen(thePlayer, false)
			end

			outputChatBox( "Your timed viewing has ended.", thePlayer, 0, 255, 0 )
		else
			outputChatBox( "Invalid House.", thePlayer, 255, 0, 0 )
		end
	end

	interiorPreviews[thePlayer] = nil
	removeElementData( thePlayer, "viewingInterior" )
end
addEvent("endViewPropertyInterior", true)
addEventHandler("endViewPropertyInterior", root, endTimedInteriorView)

addEventHandler("onPlayerQuit", root, function()
	-- currently previewing an interior?
	if interiorPreviews[source] then
		killTimer(interiorPreviews[source].timer)
		interiorPreviews[source] = nil
	end
end)