--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local mysql = exports.mysql

local migrations = {
	"ALTER TABLE `vehicles` ADD `deletedDate` DATETIME NULL DEFAULT NULL AFTER `deleted`;"
}
addEventHandler('onResourceStart', resourceRoot,
	function ()
		exports.mysql:createMigrations(getResourceName(getThisResource()), migrations)
	end
)

-- USEFUL CLEANUP QUERIES:
-- Clean up vehicles that was deleted more than 30 days ago:
-- DELETE FROM `vehicles` WHERE `deleted` != '0' AND `deleted` IS NOT NULL AND `deletedDate` IS NOT NULL AND (DATEDIFF(NOW(), deletedDate) > 30 );
-- Clean up vehicles that was deleted before we introduced deletedDate:
-- DELETE FROM `vehicles` WHERE `deleted` != '0' AND `deleted` IS NOT NULL AND `deletedDate` IS NULL;

function setElementDataEx(source, field, parameter, streamtoall, streamatall)
	exports.anticheat:changeProtectedElementDataEx( source, field, parameter, streamtoall, streamatall)
end

function getAllVehs(thePlayer, commandName, ...)
	if exports.integration:isPlayerTrialAdmin( thePlayer ) then
		local vehicleList = {}
		local mQuery1 = nil
		mQuery1 = mysql:query("SELECT vehicles.id AS vID, type, name, cost, charactername, characters.account AS username, cked, locked, supplies, safepositionX, disabled, deleted, vehicles.adminnote AS iAdminNote, vehicles.createdDate AS iCreatedDate, vehicles.creator AS iCreator, DATEDIFF(NOW(), lastused) AS DiffDate, vehicles.x, vehicles.y, vehicles.y FROM vehicles LEFT JOIN characters ON vehicles.owner = characters.id ORDER BY vehicles.createdDate DESC")

		while true do
			local row = mysql:fetch_assoc(mQuery1)
			if not row then break end
			table.insert(vehicleList, { row["vID"], row["type"], row["name"], row["cost"], row["charactername"], row["username"], row["cked"], row["DiffDate"], row["locked"], row["supplies"], row["safepositionX"], row["disabled"], row["deleted"], row["iAdminNote"], row["iCreatedDate"],row["iCreator"], row["`vehicles`.`x`"], row["`vehicles`.`y`"], row["`vehicles`.`z`"] } )
		end
		mysql:free_result(mQuery1)
		triggerClientEvent(thePlayer, "createVehManagerWindow", thePlayer, vehicleList, getElementData( thePlayer, "account:username" ))
	end
end
addEvent("vehicleManager:openit", true)
addEventHandler("vehicleManager:openit", getRootElement(), getAllVehs)

function delVehCmd(thePlayer, vehID )
	executeCommandHandler ( "delveh", thePlayer, vehID )
end
addEvent("vehicleManager:delVeh", true)
addEventHandler("vehicleManager:delVeh", getRootElement(), delVehCmd)

function gotoVeh(thePlayer, vehID )
	executeCommandHandler ( "gotocar", thePlayer, vehID )
end
addEvent("vehicleManager:gotoVeh", true)
addEventHandler("vehicleManager:gotoVeh", getRootElement(), gotoVeh)

function restoreVeh(thePlayer, vehID )
	executeCommandHandler ( "restoreveh", thePlayer, vehID )
end
addEvent("vehicleManager:restoreVeh", true)
addEventHandler("vehicleManager:restoreVeh", getRootElement(), restoreVeh)

function removeVeh(thePlayer, vehID )
	executeCommandHandler ( "removeveh", thePlayer, vehID )
end
addEvent("vehicleManager:removeVeh", true)
addEventHandler("vehicleManager:removeVeh", getRootElement(), removeVeh)

function forceSellInt(thePlayer, vehID )
	executeCommandHandler ( "fsell", thePlayer, vehID )
end
addEvent("vehicleManager:forceSellInt", true)
addEventHandler("vehicleManager:forceSellInt", getRootElement(), forceSellInt)

function openAdminNote(thePlayer, vehID )
	executeCommandHandler ( "checkveh", thePlayer, vehID )
end
addEvent("vehicleManager:openAdminNote", true)
addEventHandler("vehicleManager:openAdminNote", getRootElement(), openAdminNote)

function vehiclesearch(thePlayer, keyword )
	if keyword and keyword ~= "" and keyword ~= "Search..." then
		local vehiclesResultList = {}
		local mQuery1 = nil
		mQuery1 = mysql:query("SELECT *, v.id AS id, TO_SECONDS(lastUsed) AS lastused_sec FROM vehicles v LEFT JOIN vehicles_shop s ON v.vehicle_shop_id=s.id LEFT JOIN characters c ON v.owner=c.id LEFT JOIN factions f ON v.faction=f.id WHERE v.id LIKE '%"..keyword.."%'  OR vehmtamodel LIKE '%"..keyword.."%' OR vehbrand LIKE '%"..keyword.."%' OR vehyear LIKE '%"..keyword.."%' OR c.charactername LIKE '%"..keyword.."%' OR f.name LIKE '%"..keyword.."%' OR f.name LIKE '%"..keyword.."%' ORDER BY v.id DESC")
		while true do
			local row = mysql:fetch_assoc(mQuery1)
			if not row then break end
			table.insert(vehiclesResultList, row )
		end
		mysql:free_result(mQuery1)
		triggerClientEvent(thePlayer, "vehicleManager:FetchSearchResults", thePlayer, vehiclesResultList, getElementData( thePlayer, "account:username" ))
	end
end
addEvent("vehicleManager:Search", true)
addEventHandler("vehicleManager:Search", getRootElement(), vehiclesearch)

function checkVeh(thePlayer, commandName, vehID)
	if exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer) or exports.integration:isPlayerVehicleConsultant( thePlayer ) then
		if not tonumber(vehID) or (tonumber(vehID) <= 0 ) or (tonumber(vehID) % 1 ~= 0 ) then
			local veh = getPedOccupiedVehicle(thePlayer) or false
			vehID = isElement(veh) and getElementData(veh, "dbid") or false
			if not vehID then
				outputChatBox( "You must be in a vehicle.", thePlayer, 255, 194, 14)
				outputChatBox("Or use SYNTAX: /"..commandName.." [Vehicle ID]", thePlayer, 255, 194, 14)
				return false
			elseif vehID <= 0 then
				outputChatBox( "You can't /checkveh on temp vehicle.", thePlayer, 255, 0, 0)
				return false
			end
		end

		local mQuery1 = mysql:query("SELECT `vehicles`.`job` AS `vjob`,`vehicles`.`id` AS `vID`, `vehicles`.`model` AS `vModel`, `vehicles`.`currx` AS `vPosX`, `vehicles`.`curry` AS `vPosY`, `vehicles`.`currz` AS `vPosZ`, `vehicles`.`fuel` AS `vFuel`, `vehicles`.`paintjob` AS `vPaintjob`,	`vehicles`.`hp` AS `vHp`, `factions`.`name` AS `fFactionName`, `characters`.`charactername` AS `cOwner`, `vehicles`.`job` AS `vJob`, `vehicles`.`tintedwindows` AS `vTintedwindows`,	`vehicles`.`currdimension` AS `vCurrdimension`,	`vehicles`.`currinterior` AS `vCurrInterior`, `vehicles`.`impounded` AS `vImpounded`, `vehicles`.`plate` AS `vPlate`, `vehicles`.`registered` AS `registered`, `vehicles`.`odometer` AS `vOdometer`, `vehicles`.`suspensionLowerLimit` AS `vSuspensionLowerLimit`,	`vehicles`.`driveType` AS `vDriveType`,	`vehicles`.`deleted` AS `vDeleted`,	`vehicles`.`chopped` AS `vChopped`,	`vehicles`.`stolen` AS `vStolen`,	DATEDIFF(NOW(), `vehicles`.`lastUsed`) AS `vLastUsed`,	`vehicles`.`creationDate` AS `vCreationDate`, `vehicles`.`tokenUsed`,	`vehicles`.`createdBy` AS `aCreator` FROM `vehicles` LEFT JOIN `characters` ON `vehicles`.`owner`=`characters`.`id` LEFT JOIN `factions` ON`vehicles`.`faction`=`factions`.`id` WHERE `vehicles`.`id`='"..vehID.."' ORDER BY `vehicles`.`creationDate` DESC") or false
		if mQuery1 then
			local result = {}
			local row = mysql:fetch_assoc(mQuery1) or false
			mysql:free_result(mQuery1)
			if not row then
				outputChatBox("Vehicle ID #"..vehID.." doesn't exist!", thePlayer, 255, 0, 0)
				return false
			end

			if row["vjob"] ~= "-1" then
				outputChatBox("You can't /checkveh on a city hall job's vehicle.", thePlayer, 255, 0, 0)
				return false
			end

			--                            1            2              3            4             5             6              7
			table.insert(result, { row["vID"], row["vModel"], row["vPosX"], row["vPosY"], row["vPosZ"], row["vFuel"], row["vPaintjob"],
			--   8              9				10					11   				12					13						14
			row["vHp"], row["vPlate"], row["fFactionName"], row["cOwner"], row["vCurrdimension"], row["vCurrInterior"], row["vImpounded"],
			--		15				16				17						18						19					20
			row["aCreator"],row["vPlate"], row["vOdometer"],  row["vSuspensionLowerLimit"], row["vDriveType"], row["vNote"],
			--		21				22					23			24					25					26					27
			row["vDeleted"], row["vChopped"],row["vStolen"], row["vLastUsed"], row["vCreationDate"], row["registered"], row["tokenUsed"] } )

			local mQuery2 = mysql:query("SELECT `vehicle_logs`.`date` AS `date`, `vehicle_logs`.`vehID` as `vehID`, `vehicle_logs`.`action` AS `action`, `vehicle_logs`.`actor` AS `adminname`, `vehicle_logs`.`log_id` AS `logid` FROM `vehicle_logs` WHERE `vehicle_logs`.`vehID` = '"..vehID.."' ORDER BY `vehicle_logs`.`date` DESC") or false
			local result2 = {}
			while mQuery2 do
				local row2 = mysql:fetch_assoc(mQuery2) or false
				if row2 then
					table.insert(result2, { row2["date"], row2["action"], row2["adminname"], row2["logid"], row2["vehID"]} )
				else
					break
				end
			end
			mysql:free_result(mQuery2)

			local notes = {}
			mQuery2 = mysql:query("SELECT n.id, n.note, n.date, n.creator FROM vehicle_notes n WHERE n.vehid="..vehID.." ORDER BY n.date DESC")
			while mQuery2 do
				local row2 = mysql:fetch_assoc(mQuery2)
				if not row2 then break end
				row2.creatorname = row2.creator
				table.insert(notes, row2 )
			end
			mysql:free_result(mQuery2)
			triggerClientEvent(thePlayer, "createCheckVehWindow", thePlayer, result, exports.global:getPlayerAdminTitle(thePlayer), result2, notes)
		else
			outputChatBox("Database Error!", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("checkveh", checkVeh)
addCommandHandler("checkvehicle", checkVeh)
addEvent("vehicleManager:checkveh", true)
addEventHandler("vehicleManager:checkveh", getRootElement(), checkVeh)

function saveAdminNote(vehID, adminNote, noteId)
	if not vehID or not adminNote then
		outputChatBox("Internal Error!", source, 255,0,0)
		return false
	end

	if string.len(adminNote) > 500 then
		outputChatBox("Admin note has failed to add. Reason: Exceeded 500 characters.", source, 255, 0, 0)
		return false
	end

	if noteId then
		if mysql:query_free("UPDATE vehicle_notes SET note='"..mysql:escape_string(adminNote).."', creator="..getElementData(source, "account:id").." WHERE id ="..noteId.." AND vehid="..vehID) then
			outputChatBox("You have successfully updated admin note entry #"..noteId.." on vehicle #"..vehID..".", source, 0, 255,0)
			addVehicleLogs(vehID, "Modified admin note entry #"..noteId, source)
			return true
		end
	else
		--outputChatBox("INSERT INTO vehicle_notes SET note='"..mysql:escape_string(adminNote).."', creator="..getElementData(source, "account:id")..", vehid="..vehID )
		local insertedId = mysql:query_insert_free("INSERT INTO vehicle_notes SET note='"..mysql:escape_string(adminNote).."', creator="..getElementData(source, "account:id")..", vehid="..vehID )
		if insertedId then
			outputChatBox("You have successfully added a new admin note entry #"..insertedId.." to vehicle #"..vehID..".", source, 0, 255,0)
			addVehicleLogs(vehID, "Added new admin note entry #"..insertedId, source)
			return true
		end
	end
end
addEvent("vehicleManager:saveAdminNote", true)
addEventHandler("vehicleManager:saveAdminNote", getRootElement(), saveAdminNote)

function getVehicleWeight (thePlayer, commandName, specifiedVehicle)
	if exports.integration:isPlayerVehicleConsultant(thePlayer) or exports.integration:isPlayerAdmin(thePlayer) or exports.integration:isPlayerVCTMember(thePlayer) then
		if not specifiedVehicle then
			local vehicle = getPedOccupiedVehicle(thePlayer) or false
			if not vehicle then
				outputChatBox("You need to be sitting in a vehicle in order to use this command, or you can use /getvehweight <veh ID>.", thePlayer, 255, 194, 14)
				return false
			else
				local mass = getVehicleHandling(vehicle).mass or false
				if not mass then
					outputChatBox("ERROR: Please contact a scripter or a VCT member. Code: 824jS", thePlayer, 255, 0, 0)
					return false
				else
					outputChatBox("Vehicle weight: #7CFC00"..mass.."kg. #FFFFFFAutomated calculation (mass x 3) for chopshop: #01C5BB"..(tonumber(mass) * 3).."$", thePlayer, 255, 255, 255, true)
				end
			end
		elseif tonumber(specifiedVehicle) and tonumber(specifiedVehicle) > 0 then
			local exists = exports.pool:getElement("vehicle", tonumber(specifiedVehicle)) or false
			if not exists then
				outputChatBox("This vehicle ID does not exist.", thePlayer, 255, 194, 14)
				return false
			else
				local mass = getVehicleHandling(exists).mass or false
				if not mass then
					outputChatBox("ERROR: Please contact a scripter or a VCT member. Code: 823jS", thePlayer, 255, 0, 0)
					return false
				else
					outputChatBox("Vehicle weight: #7CFC00"..mass.."kg. #FFFFFFAutomated calculation (mass x 3) for chopshop: #01C5BB"..(tonumber(mass) * 3).."$", thePlayer, 255, 255, 255, true)
				end
			end
		else
			outputChatBox("ERROR: Please contact a scripter. Code: 822jS", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("getvehweight", getVehicleWeight)

function systemDeleteVehicle(vehid, reason) --This function is meant to be used by the system or to be triggered from UCP remotely. Works similarly to the delveh however, it's simplier and doesn't use mta elements. / MAXIME / 2015.1.11
	if vehid and tonumber(vehid) then
		vehid = tonumber(vehid)
	else
		return false, "veh id is missing or invalid"
	end
	--Existed or not, we take all keys anyway.
	call( getResourceFromName( "item-system" ), "deleteAll", 3 , vehid )

	-- Updated to use MTA's Native MySQL. Here is where the database stuff is processed.
	local query = dbQuery(exports.mysql:getConn("mta"), "SELECT id FROM vehicles WHERE id=? LIMIT 1", vehid)
	local veh = dbPoll(query, 1000)
	
	if veh and veh.id ~= mysql_null() then
		dbExec(exports.mysql:getConn("mta"), "UPDATE vehicles SET deleted=-1, deletedDate=NOW() WHERE id=?", vehid)
	else
		return false, "veh does not existed in database."
	end

	--Alright, it's time to give admins some clues of what just happened
	exports.logs:dbLog("SYSTEM", 6, { "ve"..vehid } , reason and reason or "DELETED")
	addVehicleLogs(vehid, reason and reason or "DELETED BY SYSTEM")

	--Check if vehicle is loaded in game
	local theVehicle = exports.pool:getElement("vehicle", vehid)
	if theVehicle then
		destroyElement(theVehicle)
		return true
	else
		return true, "vehicle is not loaded in game so only cleaned up in database."
	end
end
