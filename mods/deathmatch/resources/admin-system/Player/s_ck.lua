--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]
 
 addEvent("admin:cked", false)

function ckPlayer(thePlayer, commandName, targetPlayer, ...)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		if not (targetPlayer) or not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID] [Cause of Death]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)

			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")

				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				elseif (logged==1) then
					info = table.concat({...}, " ")
					local query = mysql:query_free("UPDATE `characters` SET `cked`='1', `ck_info`='" .. mysql:escape_string(tostring(info)) .. "', `death_date`=NOW() WHERE `id` = " .. mysql:escape_string(getElementData(targetPlayer, "dbid"))) --Maxime

					local x, y, z = getElementPosition(targetPlayer)
					local skin = getPedSkin(targetPlayer)
					local rotation = getPedRotation(targetPlayer)
					local look = getElementData(targetPlayer, "look")
					local desc = look[5]
					call( getResourceFromName( "realism" ), "addCharacterKillBody", x, y, z, rotation, skin, getElementData(targetPlayer, "dbid"), targetPlayerName, getElementInterior(targetPlayer), getElementDimension(targetPlayer), getElementData(targetPlayer, "age"), getElementData(targetPlayer, "race"), getElementData(targetPlayer, "weight"), getElementData(targetPlayer, "height"), desc, info, getElementData(targetPlayer, "gender"))

					-- send back to change char screen
					local id = getElementData(targetPlayer, "account:id")
					showCursor(targetPlayer, false)
					--triggerEvent("accounts:characters:change", targetPlayer, "Change Character")
					--exports.anticheat:changeProtectedElementDataEx(targetPlayer, "loggedin", 0, false)
					outputChatBox("Your character was CK'ed by " .. getPlayerName(thePlayer) .. ".", targetPlayer, 255, 194, 14)
					showChat(targetPlayer, false)
					outputChatBox("You have CK'ed ".. targetPlayerName ..".", thePlayer, 255, 194, 1)
					exports.logs:dbLog(thePlayer, 4, targetPlayer, "CK with reason: "..mysql:escape_string(tostring(info)))
					--exports.anticheat:changeProtectedElementDataEx(targetPlayer, "dbid", 0, false)
					--local port = getServerPort()
					--local password = getServerPassword()
					--redirectPlayer(targetPlayer, "199.19.109.40", tonumber(port), password)
					triggerEvent("admin:cked", targetPlayer)
					triggerClientEvent("showCkWindow", targetPlayer)
				end
			end
		end
	end
end
addCommandHandler("ck", ckPlayer)

-- /UNCK
function unckPlayer(thePlayer, commandName, ...)
	if (exports.integration:isPlayerAdmin(thePlayer)) then
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Full Player Name]", thePlayer, 255, 194, 14)
		else
			local targetPlayer = table.concat({...}, "_")
			local result = mysql:query("SELECT id, account FROM characters WHERE charactername='" .. mysql:escape_string(tostring(targetPlayer)) .. "' AND cked > 0")

			if (mysql:num_rows(result)>1) then
				outputChatBox("Too many results - Please enter a more exact name.", thePlayer, 255, 0, 0)
			elseif (mysql:num_rows(result)==0) then
				outputChatBox("Player does not exist or is not CK'ed.", thePlayer, 255, 0, 0)
			else
				local row = mysql:fetch_assoc(result)
				local dbid = tonumber(row["id"]) or 0
				local account = tonumber(row["account"])
				mysql:query_free("UPDATE characters SET cked='0' WHERE id = " .. dbid .. " LIMIT 1")

				-- delete all peds for him
				for key, value in pairs( getElementsByType( "ped" ) ) do
					if isElement( value ) and getElementData( value, "ckid" ) then
						if getElementData( value, "ckid" ) == dbid then
							destroyElement( value )
						end
					end
				end

				-- check to see if the player is online and fix his character
				for _, player in ipairs(getElementsByType("player")) do
					local accountID = getElementData(player, "account:id")
					if accountID == account then
						triggerEvent("updateCharacters", player)
						break
					end
				end

				outputChatBox(targetPlayer .. " is no longer CK'ed.", thePlayer, 0, 255, 0)
				exports.logs:dbLog(thePlayer, 4, "ch"..row["id"], "UNCK")
			end
			mysql:free_result(result)
		end
	end
end
addCommandHandler("unck", unckPlayer)

-- /BURY
function buryPlayer(thePlayer, commandName, ...)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Full Player Name]", thePlayer, 255, 194, 14)
		else
			local targetPlayer = table.concat({...}, "_")
			local result = mysql:query("SELECT id, cked FROM characters WHERE charactername='" .. mysql:escape_string(tostring(targetPlayer)) .. "'")

			if (mysql:num_rows(result)>1) then
				outputChatBox("Too many results - Please enter a more exact name.", thePlayer, 255, 0, 0)
			elseif (mysql:num_rows(result)==0) then
				outputChatBox("Player does not exist.", thePlayer, 255, 0, 0)
			else
				local row = mysql:fetch_assoc(result)
				local dbid = tonumber(row["id"]) or 0
				local cked = tonumber(row["cked"]) or 0
				if cked == 0 then
					outputChatBox("Player is not CK'ed.", thePlayer, 255, 0, 0)
				elseif cked == 2 then
					outputChatBox("Player is already buried.", thePlayer, 255, 0, 0)
				else
					mysql:query_free("UPDATE `characters` SET `cked`='2' WHERE `id` = " .. dbid .. " LIMIT 1")

					-- delete all peds for him
					for key, value in pairs( exports.pool:getPoolElementsByType("ped") ) do
						if isElement( value ) and getElementData( value, "ckid" ) then
							if getElementData( value, "ckid" ) == dbid then
								destroyElement( value )
								break
							end
						end
					end

					outputChatBox(targetPlayer .. " was buried.", thePlayer, 0, 255, 0)
					exports.logs:dbLog(thePlayer, 4, "ch"..row["id"], "CK-BURY")
				end
			end
			mysql:free_result(result)
		end
	elseif exports.factions:isInFactionType(thePlayer, 4) and not exports.integration:isPlayerTrialAdmin(thePlayer) then -- LSFD Bury
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Full Player Name]", thePlayer, 255, 194, 14)
		else
			local targetPlayer = table.concat({...}, "_")
			local result = mysql:query("SELECT id, cked FROM characters WHERE charactername='" .. mysql:escape_string(tostring(targetPlayer)) .. "'")

			if (mysql:num_rows(result)>1) then
				outputChatBox("Too many results - Please enter a more exact name.", thePlayer, 255, 0, 0)
			elseif (mysql:num_rows(result)==0) then
				outputChatBox("Player does not exist.", thePlayer, 255, 0, 0)
			else
				local row = mysql:fetch_assoc(result)
				local dbid = tonumber(row["id"]) or 0
				local cked = tonumber(row["cked"]) or 0
				if cked == 0 then
					outputChatBox("Player is not CK'ed.", thePlayer, 255, 0, 0)
				elseif cked == 2 then
					outputChatBox("Player is already buried.", thePlayer, 255, 0, 0)
				else
					mysql:query_free("UPDATE characters SET cked='2' WHERE id = " .. dbid .. " LIMIT 1")

					-- delete the ped for him
					for key, value in pairs( exports.pool:getPoolElementsByType("ped") ) do
						if isElement( value ) and getElementData( value, "ckid" ) then
							if getElementData( value, "ckid" ) == dbid then
								destroyElement( value )
								break
							end
						end
					end
					triggerEvent('sendAme', thePlayer, "puts ".. tostring(targetPlayer) .." to rest.")
					outputChatBox(targetPlayer .. " was buried.", thePlayer, 0, 255, 0)
					exports.logs:dbLog(thePlayer, 4, "ch"..row["id"], "CK-BURY-LSES")
				end
			end
			mysql:free_result(result)
		end
	end
end
addCommandHandler("bury", buryPlayer)

-- /Move CK
function movePlayer(thePlayer, commandName, ...)
	local isIn = exports.factions:isInFactionType(thePlayer, 4)
	if exports.integration:isPlayerTrialAdmin(thePlayer) or (isIn) then
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Full Player Name]", thePlayer, 255, 194, 14)
		else
			local targetPlayer = table.concat({...}, "_")
			local result1 = mysql:query("SELECT id, cked, skin, charactername, age, skincolor, weight, height, description, ck_info, gender FROM characters WHERE charactername='" .. mysql:escape_string(tostring(targetPlayer)) .. "'")
			if (mysql:num_rows(result1)==0) then
				outputChatBox("Player does not exist.", thePlayer, 255, 0, 0)
			else
				local row = mysql:fetch_assoc(result1)
				local dbid = tonumber(row["id"]) or 0
				local cked = tonumber(row["cked"]) or 0
				if cked == 0 then
					outputChatBox("Player is not CK'ed.", thePlayer, 255, 0, 0)
				elseif cked == 2 then
					outputChatBox("You cannot move someone who is already buried.", thePlayer, 255, 0, 0)
				else

					local x,y,z = getElementPosition(thePlayer)
					local r1, r2, r3 = getElementRotation(thePlayer)
					local dimension = getElementDimension(thePlayer)
					local interior = getElementInterior(thePlayer)
					local theBody

					mysql:query_free("UPDATE characters SET x ="..x..", y ="..y..", z ="..z..", rotation ="..r1..", dimension_id ="..dimension..", interior_id ="..interior.." WHERE id = " .. dbid .. " LIMIT 1")
					for key, value in pairs( exports.pool:getPoolElementsByType("ped") ) do
						if isElement( value ) and getElementData( value, "ckid" ) then
							if getElementData( value, "ckid" ) == dbid then
								theBody = value
								if(getElementDimension(theBody) ~= dimension or getElementInterior(theBody) ~= interior) then
									--setElementDimension and setElementInterior don't work on dead peds, so we need to respawn the ped
									destroyElement(theBody)
									theBody = exports.realism:addCharacterKillBody(x, y, z, r1, tonumber(row["skin"]), dbid, row["charactername"], interior, dimension, tonumber(row["age"]), tonumber(row["skincolor"]), tonumber(row["weight"]), tonumber(row["height"]), row["description"], row["ck_info"], tonumber(row["gender"]))
								else
									setElementPosition(theBody, x, y, z)
									setElementRotation(theBody, r1, r2, r3)
								end
							end
						end
					end

					if isIn and not exports.integration:isPlayerTrialAdmin(thePlayer) then
						triggerEvent('sendAme', thePlayer, "moves ".. tostring(targetPlayer) .." corpse.")
						outputChatBox(targetPlayer .. " was moved.", thePlayer, 0, 255, 0)
						exports.logs:dbLog(thePlayer, 4, "ch"..dbid, "CK-MOVE-LSES")
					else
						outputChatBox(targetPlayer .. " was moved.", thePlayer, 0, 255, 0)
						exports.logs:dbLog(thePlayer, 4, "ch"..dbid, "CK-MOVE")
					end
				end
			end
			mysql:free_result(result1)
		end
	end
end
addCommandHandler("moveck", movePlayer)
addCommandHandler("movebody", movePlayer)
