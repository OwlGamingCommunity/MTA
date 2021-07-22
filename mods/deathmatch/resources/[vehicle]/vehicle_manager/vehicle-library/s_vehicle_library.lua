--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

mysql = exports.mysql
RESULT_LIMIT = 250

function getRealDoorType(doortype)
	if doortype == 1 or doortype == 2 then
		return doortype
	end
	return nil
end

function refreshCarShop()
	executeCommandHandler("refreshcarshops", client, "true")
end
addEvent("vehlib:refreshcarshops", true)
addEventHandler("vehlib:refreshcarshops", getRootElement(), refreshCarShop)

function sendLibraryToClient(receiver, ped)
	if client and client ~= receiver then return end

	local vehs = {}
	local mQuery1 = nil
	local preparedQ = "SELECT `spawnto`, `id`, `vehmtamodel`, `vehbrand`, `vehmodel`, `vehyear`, `vehprice`, `vehtax`, `vehicles_shop`.`createdby` AS 'createdby', `createdate`, `vehicles_shop`.`updatedby` AS 'updatedby', `updatedate`, `notes`, `enabled` FROM `vehicles_shop`"
	if ped and isElement(ped) then
		local shopName = getElementData(ped, "carshop")
		if shopName == "grotti" then
			preparedQ = preparedQ.." WHERE `spawnto`='1' and `stock`>0 "
		elseif shopName == "JeffersonCarShop" then
			preparedQ = preparedQ.." WHERE `spawnto`='2' and `stock`>0 "
		elseif shopName == "IdlewoodBikeShop" then
			preparedQ = preparedQ.." WHERE `spawnto`='3' and `stock`>0 "
		elseif shopName == "SandrosCars" then
			preparedQ = preparedQ.." WHERE `spawnto`='4' and `stock`>0 "
		elseif shopName == "IndustrialVehicleShop" then
			preparedQ = preparedQ.." WHERE `spawnto`='5' and `stock`>0 "
		elseif shopName == "BoatShop" then
			preparedQ = preparedQ.." WHERE `spawnto`='6' and `stock`>0 "
		end
	end
	preparedQ = preparedQ.." ORDER BY `updatedate` DESC LIMIT ?"


	local qh = dbQuery(mysql:getConn("mta"), preparedQ, RESULT_LIMIT)
	local vehs = dbPoll(qh, 10000)

	triggerClientEvent(receiver, "vehlib:showLibrary", receiver, vehs, ped)
end
addEvent("vehlib:sendLibraryToClient", true)
addEventHandler("vehlib:sendLibraryToClient", root, sendLibraryToClient)

addEvent("vehlib:fetchMoreLibraryData", true)
addEventHandler("vehlib:fetchMoreLibraryData", root, function(page)
	if not page then 
		return 
	end

	local offset = RESULT_LIMIT * page
	local qh = dbQuery(mysql:getConn("mta"), "SELECT `spawnto`, `id`, `vehmtamodel`, `vehbrand`, `vehmodel`, `vehyear`, `vehprice`, `vehtax`, `vehicles_shop`.`createdby` AS 'createdby', `createdate`, `vehicles_shop`.`updatedby` AS 'updatedby', `updatedate`, `notes`, `enabled` FROM `vehicles_shop` ORDER BY `updatedate` DESC LIMIT ?,?", offset, RESULT_LIMIT)
	local vehs = dbPoll(qh, 10000)

	if vehs and #vehs >= 1 then 
		triggerClientEvent(client, "vehlib:loadPage", client, vehs)
		-- If its the final page.
		if #vehs ~= RESULT_LIMIT then 
			triggerClientEvent(client, "vehlib:hitFinalPage", client)
		end
	else
		dbFree(qh)
	end
end)

addEvent("vehlib:searchLibrary", true)
addEventHandler("vehlib:searchLibrary", root, function(keyword)
	if client and client ~= source then return end

	if not keyword then 
		return
	end
	
	local preparedQuery = "SELECT `spawnto`, `id`, `vehmtamodel`, `vehbrand`, `vehmodel`, `vehyear`, `vehprice`, `vehtax`, `vehicles_shop`.`createdby` AS 'createdby',`createdate`, `vehicles_shop`.`updatedby` AS 'updatedby',`updatedate`, `notes`, `enabled` FROM `vehicles_shop`"

	-- Check if its a GTASA vehicle name being searched
	local model = getVehicleModelFromName(keyword)
	if model then 
		keyword = model 
		preparedQuery = preparedQuery .. "WHERE vehmtamodel = ? ORDER BY updatedate DESC LIMIT ?"
	else
		preparedQuery = preparedQuery .. "WHERE ? IN (id, vehyear, vehbrand, vehmodel) ORDER BY updatedate DESC LIMIT ?"
	end

	local qh = dbQuery(mysql:getConn("mta"), preparedQuery, keyword, RESULT_LIMIT)
	local vehs = dbPoll(qh, 10000)
	if vehs then 
		triggerClientEvent(client, "vehlib:loadPage", client, vehs, true)
	else 
		dbFree(qh)
	end
end)

function openVehlib(thePlayer)
	if exports.integration:isPlayerVCTMember(thePlayer) or exports.integration:isPlayerSupporter(thePlayer) or exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) or exports.integration:isPlayerVehicleConsultant(thePlayer) then
		sendLibraryToClient(thePlayer)
	end
end
addCommandHandler("vehlib",openVehlib )
addCommandHandler("vehiclelibrary",openVehlib)

function createVehicleRecord(data)
	if not exports.integration:isPlayerVehicleConsultant(client) and not exports.integration:isPlayerLeadAdmin(client) then
		return
	end

	if not data then
		outputDebugString("VEHICLE MANAGER / VEHICLE LIB / createVehicleRecord / NO DATA RECIEVED FROM CLIENT")
		return false
	end

	local enabled = "0"
	if data.enabled then
		enabled = "1"
	end

	data.doortype = getRealDoorType(data.doortype) or 'NULL'
	data.rate = data.rate or 'NULL'
	data.stock = data.stock or 'NULL'

	if not data.update then
		local mQuery1 = mysql:query_insert_free("INSERT INTO vehicles_shop SET vehmtamodel='"..toSQL(data["mtaModel"]).."', vehbrand='"..toSQL(data["brand"]).."', vehmodel='"..toSQL(data["model"]).."', vehyear='"..toSQL(data["year"]).."', vehprice='"..toSQL(data["price"]).."', vehtax='"..toSQL(data["tax"]).."', createdby='"..toSQL(getElementData(client, "account:id")).."', notes='"..toSQL(data["note"]).."', enabled='"..toSQL(enabled).."', `spawnto`='"..toSQL(data["spawnto"]).."', `doortype` = " .. data.doortype ..", `stock`= "..data.stock..", `spawn_rate`= "..data.rate)
		if not mQuery1 then
			outputDebugString("VEHICLE MANAGER / VEHICLE LIB / createVehicleRecord / DATABASE ERROR")
			outputChatBox("[VEHICLE MANAGER] Failed to create new vehicle #"..mQuery1.." in library.", client, 255,0,0)
			return false
		end
		sendLibraryToClient(client)
		outputChatBox("[VEHICLE MANAGER] New vehicle #"..mQuery1.." created in library.", client, 0,255,0)
		exports.logs:dbLog(client, 6, { client }, " Created new vehicle #"..mQuery1.." in library.")
		--exports.global:sendMessageToAdmins("[VEHICLE-MANAGER]: "..getElementData(client, "account:username").." has created new vehicle #"..mQuery1.." in library.")
		return true
	else
		if data.copy then
			local mQuery1 = mysql:query_insert_free("INSERT INTO vehicles_shop SET vehmtamodel='"..toSQL(data["mtaModel"]).."', vehbrand='"..toSQL(data["brand"]).."', vehmodel='"..toSQL(data["model"]).."', vehyear='"..toSQL(data["year"]).."', vehprice='"..toSQL(data["price"]).."', vehtax='"..toSQL(data["tax"]).."', createdby='"..toSQL(getElementData(client, "account:id")).."', notes='"..toSQL(data["note"]).."', enabled='"..toSQL(enabled).."', `spawnto`='"..toSQL(data["spawnto"]).."', `doortype` = " .. data.doortype.. ", `stock`="..data.stock..", `spawn_rate`="..data.rate)
			if not mQuery1 then
				outputDebugString("VEHICLE MANAGER / VEHICLE LIB / createVehicleRecord / DATABASE ERROR")
				outputChatBox("[VEHICLE MANAGER] Failed to create new vehicle #"..mQuery1.." in library.", client, 255,0,0)
				return false
			end
			sendLibraryToClient(client)
			outputChatBox("[VEHICLE MANAGER] New vehicle #"..mQuery1.." created in library.", client, 0,255,0)
			exports.logs:dbLog(client, 6, { client }, " Created new vehicle #"..mQuery1.." in library.")
			--exports.global:sendMessageToAdmins("[VEHICLE-MANAGER]: "..getElementData(client, "account:username").." has created new vehicle #"..mQuery1.." in library.")
			return true
		else
			local mQuery1 = mysql:query_free("UPDATE vehicles_shop SET vehmtamodel='"..toSQL(data["mtaModel"]).."', vehbrand='"..toSQL(data["brand"]).."', vehmodel='"..toSQL(data["model"]).."', vehyear='"..toSQL(data["year"]).."', vehprice='"..toSQL(data["price"]).."', vehtax='"..toSQL(data["tax"]).."', updatedby='"..toSQL(getElementData(client, "account:id")).."', notes='"..toSQL(data["note"]).."', updatedate=NOW(), enabled='"..toSQL(enabled).."', `spawnto`='"..toSQL(data["spawnto"]).."',`doortype` = " .. data.doortype .. ", `stock`="..data.stock..", `spawn_rate`="..data.rate.." WHERE id='"..toSQL(data["id"]).."' ")
			if not mQuery1 then
				outputDebugString("VEHICLE MANAGER / VEHICLE LIB / UPDATEVEHICLE / DATABASE ERROR")
				outputChatBox("[VEHICLE MANAGER] Update vehicle #"..data.id.." from vehicle library failed.", client, 255,0,0)
				return false
			end
			sendLibraryToClient(client)
			outputChatBox("[VEHICLE MANAGER] You have updated vehicle #"..data.id.." from vehicle library.", client, 0,255,0)
			exports.logs:dbLog(client, 6, { client }, " Updated vehicle #"..data.id.." from library.")
			--exports.global:sendMessageToAdmins("[VEHICLE-MANAGER]: "..getElementData(client, "account:username").." has updated vehicle #"..data.id.." in library.")
			return true
		end
	end
end
addEvent("vehlib:createVehicle", true)
addEventHandler("vehlib:createVehicle", getRootElement(), createVehicleRecord)

function getCurrentVehicleRecord(id)
	local row = mysql:query_fetch_assoc("SELECT * FROM vehicles_shop WHERE id = '" .. mysql:escape_string(id) .. "' LIMIT 1" ) or false
	if row then
		local veh = {}
		veh.id = row.id
		veh.mtaModel = row.vehmtamodel
		veh.brand = row.vehbrand
		veh.model = row.vehmodel
		veh.price = row.vehprice
		veh.tax = row.vehtax
		veh.year = row.vehyear
		veh.enabled = row.enabled
		veh.update = true
		veh.spawnto = row.spawnto
		veh.doortype = getRealDoorType(tonumber(row.doortype))
		veh.stock = row.stock
		veh.spawn_rate = row.spawn_rate
		triggerClientEvent(client, "vehlib:showEditVehicleRecord", client, veh)
	end
end
addEvent("vehlib:getCurrentVehicleRecord", true)
addEventHandler("vehlib:getCurrentVehicleRecord", getRootElement(), getCurrentVehicleRecord)

function deleteVehicleFromLibraby(id)
	if not id then
		outputDebugString("VEHICLE MANAGER / VEHICLE LIB / DELETEVEHICLE / NO DATA RECIEVED FROM CLIENT")
		return false
	end

	local mQuery1 = mysql:query_free("DELETE FROM vehicles_shop WHERE id='"..toSQL(id).."' ")
	if not mQuery1 then
		outputDebugString("VEHICLE MANAGER / VEHICLE LIB / DELETEVEHICLE / DATABASE ERROR")
		outputChatBox("[VEHICLE MANAGER] Deleted vehicle #"..id.." from vehicle library failed.", client, 255,0,0)
		return false
	end
	outputChatBox("[VEHICLE MANAGER] You have deleted vehicle #"..id.." from vehicle library.", client, 0,255,0)
	sendLibraryToClient(client)
	return true
end
addEvent("vehlib:deleteVehicle", true)
addEventHandler("vehlib:deleteVehicle", getRootElement(), deleteVehicleFromLibraby)
	--[[local handlings = {
		[1]={"mass", mass},
		[2]={"turnMass", turnMass},
		[3]={"dragCoeff", dragCoeff},
		[4]={"centerOfMass", centerOfMass, true},
		[5]={"percentSubmerged", percentSubmerged},
		[6]={"tractionMultiplier", tractionMultiplier},
		[7]={"tractionLoss", tractionLoss},
		[8]={"tractionBias", tractionBias},
		[9]={"numberOfGears", numberOfGears},
		[10]={"maxVelocity", maxVelocity},
		[11]={"engineAcceleration", engineAcceleration},
		[12]={"engineInertia", engineInertia},
		[13]={"driveType", driveType, false, true},
		[14]={"engineType", engineType, false, true},
		[14]={"engineType", engineType, false, true},
		[15]={"brakeDeceleration", brakeDeceleration},
		[16]={"brakeBias", brakeBias},
		[17]={"ABS", ABS},
		[18]={"steeringLock", steeringLock},
		[19]={"suspensionForceLevel", suspensionForceLevel},
		[20]={"suspensionDamping", suspensionDamping},
		[21]={"suspensionHighSpeedDamping", suspensionHighSpeedDamping},
		[22]={"suspensionUpperLimit", suspensionUpperLimit},
		[23]={"suspensionLowerLimit", suspensionLowerLimit},
		[24]={"suspensionFrontRearBias", suspensionFrontRearBias},
		[25]={"suspensionAntiDiveMultiplier", suspensionAntiDiveMultiplier},
		[26]={"seatOffsetDistance", seatOffsetDistance},
		[27]={"collisionDamageMultiplier", collisionDamageMultiplier},
		[28]={"monetary", monetary},
		[29]={"modelFlags", modelFlags},
		[30]={"handlingFlags", handlingFlags},
		[31]={"headLight", headLight, false, true},
		[32]={"tailLight", tailLight, false, true},
		[33]={"animGroup", animGroup}
	}]]

local function setCustomVehProperties( theVehicle, toBeSet )
	if toBeSet and toBeSet.brand then
		-- element data.
		exports.anticheat:setEld( theVehicle, "brand", toBeSet.brand, 'all' )
		exports.anticheat:setEld( theVehicle, "maximemodel", toBeSet.model, 'all' )
		exports.anticheat:setEld( theVehicle, "year", toBeSet.year, 'all' )
		exports.anticheat:setEld( theVehicle, "carshop:cost", toBeSet.price, 'all' )
		exports.anticheat:setEld( theVehicle, "carshop:taxcost", toBeSet.tax, 'all' )
		exports.anticheat:setEld( theVehicle, "vDoorType", toBeSet.doortype, 'all' )

		-- handlings.
		if toBeSet.handling and type(toBeSet.handling) == "string" then
			local h = fromJSON(toBeSet.handling)
			if h then
				for i = 1, #handlings do
					if i ~= 29 then -- I don't know why this isn't working in 1.4. Temporarily disable this stat / Maxime
						setVehicleHandling(theVehicle, handlings[i][1], h[i] or h[tostring(i)])
					end
				end
			end
		end
	end
end

function loadCustomVehProperties( theVehicle )
	if theVehicle and isElement( theVehicle ) then
		dbQuery( function( qh, theVehicle )
			local res, rows, err = dbPoll( qh,0 )
			if res and rows > 0 then
				local toBeSet = res[1]
				toBeSet.doortype = getRealDoorType(tonumber(toBeSet.doortype))
				setCustomVehProperties( theVehicle, toBeSet )
				if not getElementData( theVehicle, 'unique' ) then
					exports.anticheat:setEld( theVehicle, "unique", true, 'all' )
				end
			else
				local sid = getElementData( theVehicle, "vehicle_shop_id" )
				if sid and sid > 0 then
					dbQuery( function( qh, sid, theVehicle )
						local res, rows, err = dbPoll( qh,0 )
						if res and rows > 0 then
							local toBeSet = res[1]
							toBeSet.brand = toBeSet.vehbrand
							toBeSet.model = toBeSet.vehmodel
							toBeSet.year = toBeSet.vehyear
							toBeSet.price = toBeSet.vehprice
							toBeSet.tax = toBeSet.vehtax
							toBeSet.doortype = getRealDoorType(tonumber(toBeSet.doortype))
							setCustomVehProperties( theVehicle, toBeSet )
							if getElementData( theVehicle, 'unique' ) then
								removeElementData( theVehicle, 'unique' )
							end
						end
					end, { sid, theVehicle }, exports.mysql:getConn('mta'), "SELECT * FROM vehicles_shop WHERE enabled=1 AND id=? ", sid )
				end
			end
		end, { theVehicle }, exports.mysql:getConn('mta'), "SELECT * FROM vehicles_custom WHERE id=? ", getElementData( theVehicle, 'dbid') )
		return true
	end
end

function toSQL(stuff)
	return mysql:escape_string(stuff)
end

function SmallestID( ) -- finds the smallest ID in the SQL instead of auto increment
	local result = mysql:query_fetch_assoc("SELECT MIN(e1.id+1) AS nextID FROM vehicles_shop AS e1 LEFT JOIN vehicles_shop AS e2 ON e1.id +1 = e2.id WHERE e2.id IS NULL")
	if result then
		local id = tonumber(result["nextID"]) or 1
		return id
	end
	return false
end

function giveTempVctAccess(thePlayer, commandName, targetPlayer)
	if exports.integration:isPlayerLeadAdmin(thePlayer) or exports.integration:isPlayerVehicleConsultant(thePlayer) then
		if not targetPlayer then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID] - Give player temporary VCT Admin.", thePlayer, 255, 194, 14)
			outputChatBox("Execute the cmd again to revoke the abilities. Abilities will be automatically gone after player relogs.", thePlayer, 200, 150, 0)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if not targetPlayer then
				outputChatBox("Player not found.",thePlayer, 255,0,0)
				return false
			end
			local logged = getElementData(targetPlayer, "loggedin")
            if (logged==0) then
				outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				return false
			end

			if not exports.integration:isPlayerVCTMember(targetPlayer) and not exports.integration:isPlayerLeadAdmin(thePlayer) then
				outputChatBox("You can grant temporary VCT admin to a VCT member only.", thePlayer, 255, 0 , 0)
				return false
			end

			local dbid = getElementData(targetPlayer, "dbid")
			local hasVctAdmin = getElementData(targetPlayer, "hasVctAdmin")
			local thePlayerIdentity = exports.global:getPlayerFullIdentity(thePlayer)
			local targetPlayerIdentity = exports.global:getPlayerFullIdentity(targetPlayer)

			if not hasVctAdmin then
				if not (exports.integration:isPlayerLeadAdmin(thePlayer) or exports.integration:isPlayerVehicleConsultant(thePlayer)) then
					outputChatBox("You can only revoke temporary VCT admin from someone, only Lead Admin and VCT Leader can grant someone this access.", thePlayer, 255, 0 , 0)
					return false
				end
				if setElementData(targetPlayer, "hasVctAdmin", true) then
					outputChatBox("You have given "..targetPlayerIdentity.." temporary VCT admin.", thePlayer, 0, 255, 0)
					outputChatBox(thePlayerIdentity.." has given you temporary VCT admin.", targetPlayer, 0, 255, 0)
					outputChatBox("TIP: VCT Admin grants you full access to perform all tasks in VCT.", targetPlayer, 255, 255, 0)
					exports.global:sendMessageToAdmins("[VCT] "..thePlayerIdentity.." has given " ..targetPlayerIdentity.. " temporary VCT admin.")
					exports.logs:dbLog(thePlayer, 4, targetPlayer, commandName)
				end
			else
				if setElementData(targetPlayer, "hasVctAdmin", false) then
					outputChatBox("You have revoked from "..targetPlayerIdentity.." temporary VCT admin.", thePlayer, 255, 0, 0)
					outputChatBox(thePlayerIdentity.." has revoked from you temporary VCT admin.", targetPlayer, 255, 0, 0)
					exports.global:sendMessageToAdmins("[VCT] "..thePlayerIdentity.." has revoked from " .. targetPlayerIdentity .. " temporary VCT admin.")
				end
			end
		end
	end
end
addCommandHandler ( "givevctadmin", giveTempVctAccess )


function setMyEngineType(thePlayer, commandName, value)
	local vehicle = getPedOccupiedVehicle(thePlayer)
	if not vehicle then
		outputChatBox("You are not in a vehicle", thePlayer, 255, 0, 0)
		return
	end
	local result = setVehicleHandling(vehicle, "engineType", tostring(value))
	outputChatBox("Result = "..tostring(result), thePlayer)
end
addCommandHandler ( "setenginetype", setMyEngineType )

function getMyEngineType(thePlayer, commandName)
	local vehicle = getPedOccupiedVehicle(thePlayer)
	if not vehicle then
		outputChatBox("You are not in a vehicle", thePlayer, 255, 0, 0)
		return
	end
	local handling = getVehicleHandling(vehicle)
	outputChatBox(tostring(handling.engineType), thePlayer)
end
addCommandHandler ( "getenginetype", getMyEngineType )
