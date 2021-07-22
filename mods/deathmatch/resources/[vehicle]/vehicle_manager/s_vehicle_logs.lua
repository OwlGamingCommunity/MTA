--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

function addVehicleLogs(vehID, action, actor, clearPreviousLogs)
	if vehID and action then
		if clearPreviousLogs then
			dbExec( exports.mysql:getConn('mta'), "DELETE FROM `vehicle_logs` WHERE `vehID`=?", vehID)
		end

		local adminID = nil
		if actor and isElement(actor) and getElementType(actor) == "player" then
		 	adminID = getElementData(actor, "account:id")
		elseif tonumber(actor) then
			adminID = tonumber(actor)
		end

		return dbExec( exports.mysql:getConn('mta'), "INSERT INTO `vehicle_logs` SET `vehID`=?, `action`=? "..(adminID and (", `actor`="..adminID) or ""), vehID, action )
	else
		outputDebugString("[VEHICLE MANAGER] Lack of agruments #1 or #2 for the function addVEHICLELogs().")
		return false
	end
end

function getVehicleOwner(vehicle)
	local faction = tonumber(getElementData(vehicle, 'faction')) or 0
	if faction > 0 then
		return getTeamName(exports.pool:getElement('team', faction))
	else
		return call(getResourceFromName("cache"), "getCharacterName", getElementData(vehicle, "owner")) or "N/A"
	end
end

function createForumThread(fTitle, fContent)
	if true then return end
	return exports["integration"]:createForumThread(nil, 300, fTitle, fContent)
end
