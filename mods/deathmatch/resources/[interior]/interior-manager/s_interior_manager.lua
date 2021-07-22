--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

local mysql = exports.mysql

function setElementDataEx(source, field, parameter, streamtoall, streamatall)
	exports.anticheat:changeProtectedElementDataEx( source, field, parameter, streamtoall, streamatall)
end

function getAllInts(thePlayer, commandName, ...)
	if exports.integration:isPlayerAdmin( thePlayer ) then
		local interiorsList = {}
		local mQuery1 = nil
		mQuery1 = mysql:query("SELECT factions.name AS fowner, interiors.id AS iID, interiors.type AS type, interiors.name AS name, cost, charactername, cked, locked, address, supplies, safepositionX, disabled, deleted, interiors.createdDate AS iCreatedDate, interiors.creator AS iCreator, DATEDIFF(NOW(), lastused) AS DiffDate, interiors.x, interiors.y, interiors.y FROM interiors LEFT JOIN characters ON interiors.owner = characters.id LEFT JOIN factions ON interiors.faction=factions.id ORDER BY interiors.createdDate DESC")

		while true do
			local row = mysql:fetch_assoc(mQuery1)
			if not row then break end
			table.insert(interiorsList, { row["iID"], row["type"], row["name"], row["cost"], row["charactername"], row["username"], row["cked"], row["DiffDate"], row["locked"], row["supplies"], row["safepositionX"], row["disabled"], row["deleted"], '', row["iCreatedDate"],row["iCreator"], row["`interiors`.`x`"], row["`interiors`.`y`"], row["`interiors`.`z`"], row['fowner'], row['address'] } )
		end
		mysql:free_result(mQuery1)
		triggerClientEvent(thePlayer, "createIntManagerWindow", thePlayer, interiorsList, getElementData( thePlayer, "account:username" ))
	end
end
addCommandHandler("interiors", getAllInts)
addCommandHandler("ints", getAllInts)
addEvent("interiorManager:openit", true)
addEventHandler("interiorManager:openit", root, getAllInts)

function delIntCmd(thePlayer, intID )
	executeCommandHandler ( "delint", thePlayer, intID )
end
addEvent("interiorManager:delint", true)
addEventHandler("interiorManager:delint", root, delIntCmd)

function disableInt(thePlayer, intID )
	executeCommandHandler ( "toggleinterior", thePlayer, intID )
end
addEvent("interiorManager:disableInt", true)
addEventHandler("interiorManager:disableInt", root, disableInt)

function gotoInt(thePlayer, intID )
	executeCommandHandler ( "gotohouse", thePlayer, intID )
end
addEvent("interiorManager:gotoInt", true)
addEventHandler("interiorManager:gotoInt", root, gotoInt)

function restoreInt(thePlayer, intID )
	executeCommandHandler ( "restoreInt", thePlayer, intID )
end
addEvent("interiorManager:restoreInt", true)
addEventHandler("interiorManager:restoreInt", root, restoreInt)

function removeInt(thePlayer, intID )
	executeCommandHandler ( "removeint", thePlayer, intID )
end
addEvent("interiorManager:removeInt", true)
addEventHandler("interiorManager:removeInt", root, removeInt)

function forceSellInt(thePlayer, intID )
	executeCommandHandler ( "fsell", thePlayer, intID )
end
addEvent("interiorManager:forceSellInt", true)
addEventHandler("interiorManager:forceSellInt", root, forceSellInt)

function openAdminNote(thePlayer, intID )
	executeCommandHandler ( "checkint", thePlayer, intID )
end
addEvent("interiorManager:openAdminNote", true)
addEventHandler("interiorManager:openAdminNote", root, openAdminNote)

function interiorSearch(keyword)
	if keyword and keyword ~= "" and keyword ~= "Search..." then
		local interiorsResultList = {}
		local mQuery1 = nil
		mQuery1 = mysql:query("SELECT characters.account AS accID, factions.name AS fowner, interiors.id AS iID, interiors.type AS type, interiors.name AS name, cost, charactername, cked, locked, address, supplies, safepositionX, disabled, deleted, interiors.createdDate AS iCreatedDate, interiors.creator AS iCreator, DATEDIFF(NOW(), lastused) AS DiffDate, interiors.x, interiors.y, interiors.y FROM interiors LEFT JOIN characters ON interiors.owner = characters.id LEFT JOIN factions ON interiors.faction=factions.id WHERE interiors.id LIKE '%"..keyword.."%' OR interiors.name LIKE '%"..keyword.."%' OR factions.name LIKE '%"..keyword.."%' OR cost LIKE '%"..keyword.."%' OR charactername LIKE '%"..keyword.."%' OR interiors.creator LIKE '%"..keyword.."%' ORDER BY interiors.createdDate DESC")
		while true do
			local row = mysql:fetch_assoc(mQuery1)
			if not row then break end
			table.insert(interiorsResultList, { row["iID"], row["type"], row["name"], row["cost"], row["charactername"], row["accID"], row["cked"], row["DiffDate"], row["locked"], row["supplies"], row["safepositionX"], row["disabled"], row["deleted"], '', row["iCreatedDate"],row["iCreator"], row["`interiors`.`x`"], row["`interiors`.`y`"], row["`interiors`.`z`"], row['fowner'], row['address'] } )
		end
		mysql:free_result(mQuery1)
		triggerClientEvent(client, "interiorManager:FetchSearchResults", client, interiorsResultList, getElementData(client, "account:username"))
	end
end
addEvent("interiorManager:Search", true)
addEventHandler("interiorManager:Search", root, interiorSearch)

function checkInt(thePlayer, commandName, intID)
	if exports.integration:isPlayerTrialAdmin( thePlayer ) or exports.integration:isPlayerSupporter(thePlayer) then
		if not tonumber(intID) or (tonumber(intID) <= 0 ) or (tonumber(intID) % 1 ~= 0 ) then
			intID = getElementDimension(thePlayer)
			if intID == 0 then
				outputChatBox( "You must be inside an interior.", thePlayer, 255, 194, 14)
				outputChatBox("Or use SYNTAX: /"..commandName.." [Interior ID]", thePlayer, 255, 194, 14)
				return false
			end
		end
		local mQuery1 = mysql:query("SELECT characters.account AS accID, factions.name AS fowner, interiors.id AS iID, interiors.type AS type, interiors.name AS name, cost, charactername, cked, locked, address, safepositionX,safepositionY, safepositionZ, disabled, deleted, tokenUsed, interiors.createdDate AS iCreatedDate, interiors.creator AS iCreator, DATEDIFF(NOW(), lastused) AS DiffDate, interiors.x, interiors.y, interiors.y FROM interiors LEFT JOIN characters ON interiors.owner = characters.id LEFT JOIN factions ON interiors.faction=factions.id WHERE interiors.id = '"..intID.."' ORDER BY interiors.createdDate DESC") or false
		if mQuery1 then
			local result = {}
			local row = mysql:fetch_assoc(mQuery1) or false
			mysql:free_result(mQuery1)
			if not row then
				outputChatBox("Interior ID doesn't exist!", thePlayer, 255, 0, 0)
				return
			end -- 			
			table.insert(result, { row["iID"], row["type"], row["name"], row["cost"], row["charactername"], row["accID"], row["cked"], row["DiffDate"], row["locked"], nil, row["safepositionX"], row["safepositionY"], row["safepositionZ"], row["disabled"], row["deleted"], '', row["iCreatedDate"],row["iCreator"], row["`interiors`.`x`"], row["`interiors`.`y`"], row["`interiors`.`z`"], row['fowner'], row['tokenUsed'], row['address'] } )
			
			local mQuery2 = mysql:query("SELECT `interior_logs`.`date` AS `date`, `interior_logs`.`intID` as `intID`, `interior_logs`.`action` AS `action`, `interior_logs`.`actor` AS `admin`, `interior_logs`.`log_id` AS `logid` FROM `interior_logs` WHERE `interior_logs`.`intID` = '"..intID.."' ORDER BY `interior_logs`.`date` DESC") or false
			local result2 = {}
			while mQuery2 do
				local row2 = mysql:fetch_assoc(mQuery2) or false
				if row2 then
					table.insert(result2, { row2["date"], row2["action"], exports.cache:getUsernameFromId(row2["admin"]) or "N/A", row2["logid"], row2["intID"]} )
				else
					break
				end
			end
			mysql:free_result(mQuery2)

			local notes = {}
			mQuery2 = mysql:query("SELECT n.id, n.note, n.date, n.creator FROM interior_notes n WHERE n.intid="..intID.." ORDER BY n.date DESC")
			while mQuery2 do
				local row2 = mysql:fetch_assoc(mQuery2)
				if not row2 then break end
				row2.creatorname = formatCreator(exports.cache:getUsernameFromId(row2.creator), row2.creator)
				table.insert(notes, row2 )
			end
			mysql:free_result(mQuery2)
			
			local players = {}
			mQuery3 = mysql:query("SELECT characters.account AS accID, characters.charactername AS charactername, characters.lastlogin AS lastlogin FROM characters WHERE characters.dimension_id = " .. intID)
			while mQuery3 do
				local row2 = mysql:fetch_assoc(mQuery3)
				if not row2 then break end
				table.insert(players, { exports.cache:getUsernameFromId(row2.accID), row2.charactername, row2.lastlogin })
			end
			mysql:free_result(mQuery3)
			
			triggerClientEvent(thePlayer, "createCheckIntWindow", thePlayer, result, exports.global:getPlayerAdminTitle(thePlayer), result2, notes, players)
		else
			outputChatBox("Database Error!", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("checkint", checkInt)
addCommandHandler("checkinterior", checkInt)
addEvent("interiorManager:checkint", true)
addEventHandler("interiorManager:checkint", root, checkInt)

function formatCreator(creator, creatorId)
	if creator and creatorId then
		if creator == mysql_null() then
			if creatorId == "0" then
				return "SYSTEM"
			else
				return "N/A"
			end
		else
			return creator
		end
	else
		return "N/A"
	end
end

function saveAdminNote(intID, adminNote, noteId )
	if not exports.integration:isPlayerTrialAdmin(client) then
		return
	end

	if not intID or not adminNote then
		outputChatBox("Internal Error!", source, 255,0,0)
		return false
	end

	if string.len(adminNote) > 500 then
		outputChatBox("Admin note has failed to add. Reason: Exceeded 500 characters.", source, 255, 0, 0)
		return false
	end

	if noteId then
		if mysql:query_free("UPDATE interior_notes SET note='"..mysql:escape_string(adminNote).."', creator="..getElementData(source, "account:id").." WHERE id ="..noteId.." AND intid="..intID) then
			outputChatBox("You have successfully updated admin note entry #"..noteId.." on interior #"..intID..".", source, 0, 255,0)
			addInteriorLogs(intID, "Modified admin note entry #"..noteId, source)
			return true
		end
	else
		--outputChatBox("INSERT INTO interior_notes SET note='"..mysql:escape_string(adminNote).."', creator="..getElementData(source, "account:id")..", intid="..intID )
		local insertedId = mysql:query_insert_free("INSERT INTO interior_notes SET note='"..mysql:escape_string(adminNote).."', creator="..getElementData(source, "account:id")..", intid="..intID )
		if insertedId then
			outputChatBox("You have successfully added a new admin note entry #"..insertedId.." to interior #"..intID..".", source, 0, 255,0)
			addInteriorLogs(intID, "Added new admin note entry #"..insertedId, source)
			return true
		end
	end
end
addEvent("interiorManager:saveAdminNote", true)
addEventHandler("interiorManager:saveAdminNote", root, saveAdminNote)

function setInteriorFaction(thePlayer, cmd, ...)
	if exports.integration:isPlayerAdmin(thePlayer) then

		if not (...) then
			outputChatBox("SYNTAX: /" .. cmd .. " [Faction Name or Faction ID]", thePlayer, 255, 194, 14 )
			return
		end

		local dim = getElementDimension(thePlayer)
		if dim < 1 then
			outputChatBox("You must be inside an interior to perform this action.", thePlayer, 255, 0, 0 )
			return
		end

		local clue = table.concat({...}, " ")
		local theFaction = nil
		if tonumber(clue) then
			theFaction = exports.pool:getElement("team", tonumber(clue))
		else
			theFaction = exports.factions:getFactionFromName(clue)
		end

		if not theFaction then
			outputChatBox("No faction found.", thePlayer, 255, 0, 0 )
			return
		end

		local dbid, entrance, exit, interiorType, interiorElement = exports.interior_system:findProperty( thePlayer )
		if not isElement(interiorElement) then
			outputChatBox("No interior found here.", thePlayer, 255, 0, 0 )
			return
		end

		local can , reason = exports.global:canFactionBuyInterior(theFaction)
		if not can then
			outputChatBox(reason, thePlayer, 255, 0, 0 )
			return
		end

		local factionId = getElementData(theFaction, "id")
		local factionName = getTeamName(theFaction)
		local intName = getElementData(interiorElement, "name")

		if not mysql:query_free( "UPDATE interiors SET owner='-1', faction='"..factionId.."', locked=0 WHERE id='" .. dbid .. "'") then
			outputChatBox("Internal Error.", thePlayer, 255, 0, 0 )
			return
		end

		call( getResourceFromName( "item-system" ), "deleteAll", interiorType == 1 and 5 or 4, dbid )
		exports.global:giveItem(thePlayer, interiorType == 1 and 5 or 4, dbid)

		exports.logs:dbLog(thePlayer, 37, { "in"..tostring(dbid) } , "SETINTFACTION INTERIOR ID#"..dbid.." TO FACTION '"..factionName.."'")
		exports.interior_system:realReloadInterior(tonumber(dbid))
		triggerClientEvent(thePlayer, "createBlipAtXY", thePlayer, entrance.type, entrance.x, entrance.y)
		exports.global:sendMessageToAdmins("[INTERIOR] "..exports.global:getPlayerFullIdentity(thePlayer).." transferred the ownership of interior '"..intName.."' ID #"..dbid.." to faction '"..factionName.."'.")
		return true
	end
end
addCommandHandler("setintfaction", setInteriorFaction, false, false)

function setInteriorToMyFaction(thePlayer, cmd, fID)
	fID = tonumber(fID)
	
	if not fID then
		outputChatBox("SYNTAX: /" .. cmd .. " [Faction ID]", thePlayer, 255, 194, 14)
		return
	end

	local faction, _ = exports.factions:isPlayerInFaction(thePlayer, fID)
	local leader = exports.factions:hasMemberPermissionTo(thePlayer, fID, "manage_interiors")

	if not faction or not leader then
		outputChatBox("You must be a faction leader to perform this action.", thePlayer, 255, 0, 0 )
		return
	end

	local dim = getElementDimension(thePlayer)
	if dim < 1 then
		outputChatBox("You must be inside an interior to perform this action.", thePlayer, 255, 0, 0 )
		return
	end

	local theFaction = exports.pool:getElement("team", fID)
	if not theFaction then
		outputChatBox("No faction found.", thePlayer, 255, 0, 0 )
		return
	end

	local dbid, entrance, exit, interiorType, interiorElement = exports.interior_system:findProperty( thePlayer )
	if not isElement(interiorElement) then
		outputChatBox("No interior found here.", thePlayer, 255, 0, 0 )
		return
	end

	local charId = getElementData(thePlayer, "dbid")
	local intStatus = getElementData(interiorElement, "status")
	local intName = getElementData(interiorElement, "name")
	local factionName = getTeamName(theFaction)

	if intStatus.owner ~= charId then
		outputChatBox("You must own this interior to perform this action.", thePlayer, 255, 0, 0 )
		return
	end

	local can , reason = exports.global:canPlayerFactionBuyInterior( thePlayer, nil, fID )
	if not can then
		outputChatBox( reason, thePlayer, 255, 0, 0 )
		return
	end

	if not mysql:query_free( "UPDATE interiors SET owner='-1', faction='"..fID.."', locked=0 WHERE id='" .. dbid .. "'") then
		outputChatBox("Internal Error.", thePlayer, 255, 0, 0 )
		return
	end

	call( getResourceFromName( "item-system" ), "deleteAll", interiorType == 1 and 5 or 4, dbid )
	exports.global:giveItem(thePlayer, interiorType == 1 and 5 or 4, dbid)

	exports.logs:dbLog(thePlayer, 37, { "in"..tostring(dbid) } , "SETINTTOMYFACTION INTERIOR ID#"..dbid.." TO FACTION '"..factionName.."'")
	exports.interior_system:realReloadInterior(tonumber(dbid))
	triggerClientEvent(thePlayer, "createBlipAtXY", thePlayer, entrance.type, entrance.x, entrance.y)
	exports.global:sendMessageToAdmins("[INTERIOR] "..exports.global:getPlayerFullIdentity(thePlayer).." transferred the ownership of interior '"..intName.."' ID #"..dbid.." to his faction '"..factionName.."'.")
	outputChatBox("You've set this interior to faction " .. factionName .. ".", thePlayer, 0, 255, 0)
	return true
end
addCommandHandler("setinttomyfaction", setInteriorToMyFaction, false, false)

function cloneNote(player)
	if getElementData(player, "account:id") ~= 1 then
		return
	end
	local q = mysql:query("SELECT adminnote, id FROM interiors WHERE adminnote IS NOT NULL AND adminnote != '' AND adminnote != '\n' ")
	while q do
		local int = mysql:fetch_assoc(q)
		if not int then break end
		if mysql:query_free("INSERT INTO interior_notes SET note='"..mysql:escape_string(int.adminnote).."', intid="..int.id) then
			outputChatBox(int.id.." - "..int.adminnote, player)
		end
	end
	outputChatBox("done", player)
end
--addCommandHandler("clonenote", cloneNote, false, false)
