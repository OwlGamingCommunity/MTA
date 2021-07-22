--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

function createUniqueVehicle(data, existed)
	if not data then
		outputDebugString("VEHICLE MANAGER / createUniqueVehicle / NO DATA RECIEVED FROM CLIENT")
		return false
	end

	data.doortype = getRealDoorType(data.doortype) or 'NULL'
	
	local vehicle = exports.pool:getElement("vehicle", tonumber(data.id))
	local forumText = [=[
[B]General Information[/B]:
[INDENT]Vehicle ID:   [B]]=] ..tostring(data.id) ..[=[[/B][/INDENT]
[INDENT]Current Owner:   [B]]=] ..tostring(getVehicleOwner(vehicle)) ..[=[[/B][/INDENT]
[INDENT]Edited by:   [B]]=] ..tostring(getElementData(client, "account:username")) ..[=[[/B][/INDENT]
[B]New Vehicle Data[/B]:
[INDENT]Brand:   [B]]=] ..tostring(data.brand) ..[=[[/B][/INDENT]
[INDENT]Model:   [B]]=] ..tostring(data.model) ..[=[[/B][/INDENT]
[INDENT]Year:    [B]]=] ..tostring(data.year) ..[=[[/B][/INDENT]
[INDENT]Price:   [B]]=] ..tostring(data.price) ..[=[[/B][/INDENT]
[INDENT]Tax:     [B]]=] ..tostring(data.tax) ..[=[[/B][/INDENT]
[INDENT]Door Type: [B]]=] ..tostring(data.doortype) ..[=[[/B][/INDENT]
[B]Old Vehicle Data[/B]:
[INDENT]Brand:   [B]]=] ..tostring(getElementData(vehicle, "brand")) ..[=[[/B][/INDENT]
[INDENT]Model:   [B]]=] ..tostring(getElementData(vehicle, "maximemodel")) ..[=[[/B][/INDENT]
[INDENT]Year:    [B]]=] ..tostring(getElementData(vehicle, "year")) ..[=[[/B][/INDENT]
[INDENT]Price:   [B]]=] ..tostring(getElementData(vehicle, "carshop:cost")) ..[=[[/B][/INDENT]
[INDENT]Tax:     [B]]=] ..tostring(getElementData(vehicle, "carshop:taxcost")) ..[=[[/B][/INDENT]
[INDENT]Door Type: [B]]=] ..tostring(getElementData(vehicle, "vDoorType") or 'NULL') ..[=[[/B][/INDENT]]=]

	if not existed then
		dbExec( exports.mysql:getConn('mta'), "REPLACE INTO vehicles_custom SET id=?, brand=?, model=?, year=?, price=?, tax=?, createdby=?, handling=(SELECT s.handling FROM vehicles_shop s WHERE s.id=?), doortype="..data.doortype, data.id, data.brand, data.model, data.year, data.price, data.tax, getElementData(client, "account:id"), getElementData( vehicle, 'vehicle_shop_id' ) )
		outputChatBox("[VEHICLE MANAGER] Unique vehicle created.", client, 0,255,0)
		exports.logs:dbLog(client, 6, { client }, " Created unique vehicle #"..data.id..".")
		exports.global:sendMessageToAdmins("[VEHICLE-MANAGER]: "..getElementData(client, "account:username").." has created new unique vehicle #"..data.id..".")
		exports.vehicle:reloadVehicle(tonumber(data.id))
		local topicLink = createForumThread(getElementData(client, "account:username").." created unique vehicle #"..data.id, forumText)
		addVehicleLogs(tonumber(data.id), 'editveh: ' .. (topicLink or "DB error"), client)
		return true
	else
		dbExec( exports.mysql:getConn('mta'), "UPDATE vehicles_custom SET brand=?, model=?, year=?, price=?, tax=?, updatedby=?, updatedate=NOW(), doortype="..data.doortype.." WHERE id=?", data.brand, data.model, data.year, data.price, data.tax, getElementData(client, "account:id"), data.id )
		outputChatBox("[VEHICLE MANAGER] You have updated unique vehicle #"..data.id..".", client, 0,255,0)
		exports.logs:dbLog(client, 6, { client }, " Updated unique vehicle #"..data.id..".")
		exports.global:sendMessageToAdmins("[VEHICLE-MANAGER]: "..getElementData(client, "account:username").." has updated unique vehicle #"..data.id..".")
		exports.vehicle:reloadVehicle(tonumber(data.id))
		local topicLink = createForumThread(getElementData(client, "account:username").." updated unique vehicle #"..data.id, forumText)
		addVehicleLogs(tonumber(data.id), 'editveh: ' .. (topicLink or "DB Error"), client)
		return true
	end
end
addEvent("vehlib:handling:createUniqueVehicle", true)
addEventHandler("vehlib:handling:createUniqueVehicle", getRootElement(), createUniqueVehicle)

function resetUniqueVehicle(vehID)
	if not vehID or not tonumber(vehID) then
		outputDebugString("VEHICLE MANAGER / resetUniqueVehicle / NO DATA RECIEVED FROM CLIENT")
		return false
	end
	
	local mQuery1 = mysql:query_free("DELETE FROM `vehicles_custom` WHERE `id`='"..toSQL(vehID).."' ")
	if not mQuery1 then
		outputDebugString("VEHICLE MANAGER / VEHICLE LIB / resetUniqueVehicle / DATABASE ERROR")
		outputChatBox("[VEHICLE MANAGER] Remove unique vehicle #"..vehID.." failed.", client, 255,0,0)
		return false
	end
	outputChatBox("[VEHICLE MANAGER] You have removed unique vehicle #"..vehID..".", client, 0,255,0)
	exports.logs:dbLog(client, 6, { client }, " Removed unique vehicle #"..vehID..".")
	exports.global:sendMessageToAdmins("[VEHICLE-MANAGER]: "..getElementData(client, "account:username").." has removed unique vehicle #"..vehID..".")
	exports.vehicle:reloadVehicle(tonumber(vehID))

	local vehicle = exports.pool:getElement("vehicle", tonumber(vehID))
	local forumText = [=[
		[INDENT]Vehicle ID:   [B]]=] ..tostring(vehID) ..[=[[/B][/INDENT]
		[INDENT]Current Owner:   [B]]=] ..tostring(getVehicleOwner(vehicle)) ..[=[[/B][/INDENT]
		[INDENT]Edited by:   [B]]=] ..tostring(getElementData(client, "account:username")) ..[=[[/B][/INDENT]]=]
	local topicLink = createForumThread(getElementData(client, "account:username").." reset unique vehicle #"..vehID, forumText)
	addVehicleLogs(tonumber(vehID), 'editveh reset: ' .. ( topicLink or "DB Error"), client)
	return true
end
addEvent("vehlib:handling:resetUniqueVehicle", true)
addEventHandler("vehlib:handling:resetUniqueVehicle", getRootElement(), resetUniqueVehicle)

---HANDLINGS
function openUniqueHandling(vehdbid, existed)
	if exports.integration:isPlayerVehicleConsultant(client) or exports.integration:isPlayerLeadAdmin(client) then
		local theVehicle = getPedOccupiedVehicle(client) or false
		if not theVehicle then
			outputChatBox( "You must be in a vehicle.", client, 255, 194, 14)
			return false
		end
		
		local vehID = getElementData(theVehicle, "dbid") or false
		if not vehID or vehID < 0 then	
			outputChatBox("This vehicle can not have custom properties.", client, 255, 194, 14)
			return false
		end
		
		if existed then
			local row = mysql:query_fetch_assoc("SELECT `handling` FROM `vehicles_custom` WHERE `id` = '" .. mysql:escape_string(vehdbid) .. "' LIMIT 1" ) or false
			if not row then
				outputChatBox( "[VEHICLE-MANAGER] Failed to retrieve current handlings from SQL.", client, 255, 194, 14)
				outputDebugString("VEHICLE MANAGER / openUniqueHandling / DATABASE ERROR")
				return false
			end
			triggerClientEvent(client, "veh-manager:handling:edithandling", client, 1)
		else
			triggerClientEvent(client, "veh-manager:handling:edithandling", client, 1)
		end
		
		return true
	end
end
addEvent("vehlib:handling:openUniqueHandling", true)
addEventHandler("vehlib:handling:openUniqueHandling", getRootElement(), openUniqueHandling)
