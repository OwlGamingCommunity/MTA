--Interior settings //Exciter

local migrations = {
	"ALTER TABLE `interiors` ADD `settings` TEXT NULL DEFAULT NULL;",
	"ALTER TABLE `vehicles` ADD `settings` TEXT NULL DEFAULT NULL;",
	"ALTER TABLE `interiors` ADD `deletedDate` DATETIME NULL DEFAULT NULL AFTER `deleted`;"
}
addEventHandler('onResourceStart', resourceRoot,
	function ()
		exports.mysql:createMigrations(getResourceName(getThisResource()), migrations)
	end
)

-- USEFUL CLEANUP QUERIES:
-- Clean up interiors that was deleted more than 30 days ago:
-- DELETE FROM `interiors` WHERE `deleted` != '0' AND `deleted` IS NOT NULL AND `deletedDate` IS NOT NULL AND (DATEDIFF(NOW(), deletedDate) > 30 );
-- Clean up interiors that was deleted before we introduced deletedDate:
-- DELETE FROM `interiors` WHERE `deleted` != '0' AND `deleted` IS NOT NULL AND `deletedDate` IS NULL;

--exported
function getInteriorSetting(interiorID, key)
	if interiorID and interiorID > 0 then
		if(interiorID > 20000) then
			vehicleID = interiorID - 20000
			local vehicleElement = exports.pool:getElement("vehicle", vehicleID)
			if vehicleElement then
				local data = getElementData(vehicleElement, "settings") or {}
				return data[tostring(key)]
			else
				return false
			end
		else
			local interiorElement = exports.pool:getElement("interior", interiorID)
			if interiorElement then
				local data = getElementData(interiorElement, "settings") or {}
				return data[tostring(key)]
			else
				return false
			end
		end
	end
	return false
end

function saveInteriorSettings(element, interiorID, isVehicleInterior, data)
	if interiorID and data then
		if isVehicleInterior then
			vehicleID = interiorID - 20000
			if not element then
				element = exports.pool:getElement("vehicle", vehicleID)
			end
			if element then
				dbExec(exports.mysql:getConn("mta"), "UPDATE `vehicles` SET `settings` = ? WHERE `id` = ? LIMIT 1;", toJSON(data), vehicleID)
				exports.anticheat:changeProtectedElementData(element, "settings", data)
			end
		else
			if not element then
				element = exports.pool:getElement("interior", interiorID)
			end
			if element then
				dbExec(exports.mysql:getConn("mta"), "UPDATE `interiors` SET `settings` = ? WHERE `id` = ?", toJSON(data), interiorID)
				exports.anticheat:changeProtectedElementData(element, "settings", data)
			end
		end
		if client and data.time then
			exports['realtime-system']:refreshClientTime(getElementInterior(client), interiorID, client)
		end
	end
end
addEvent("interior:saveSettings", true)
addEventHandler("interior:saveSettings", resourceRoot, saveInteriorSettings)

function openInteriorSettings(thePlayer, cmd)
	local playerInterior = getElementInterior(thePlayer)
	local playerDimension = getElementDimension(thePlayer)
	if(playerInterior > 0 and playerDimension > 0) then --is valid interior
		local interiorID = playerDimension
		--check access
		if (interiorID < 20000 and exports.global:hasItem(thePlayer, 4, interiorID)) or (interiorID < 20000 and exports.global:hasItem(thePlayer, 5, interiorID)) or (interiorID > 20000 and exports.global:hasItem(thePlayer, 3, interiorID-20000)) or (exports.integration:isPlayerAdmin(thePlayer) and exports.global:isAdminOnDuty(thePlayer)) or (exports.integration:isPlayerScripter(thePlayer) and exports.global:isStaffOnDuty(thePlayer)) then
			if(interiorID > 20000) then
				vehicleID = interiorID - 20000
				local vehicleElement = exports.pool:getElement("vehicle", vehicleID)
				if vehicleElement then
					local data = getElementData(vehicleElement, "settings") or {}
					triggerClientEvent(thePlayer, "interior:settingsGui", vehicleElement, playerInterior, playerDimension, data)
				else
					return false
				end
			else
				local interiorElement = exports.pool:getElement("interior", interiorID)
				if interiorElement then
					local data = getElementData(interiorElement, "settings") or {}
					local result = triggerClientEvent(thePlayer, "interior:settingsGui", thePlayer, interiorElement, playerInterior, playerDimension, data)
				else
					return false
				end
			end
		end
	end
end
addCommandHandler("intsettings", openInteriorSettings)
addCommandHandler("interiorsettings", openInteriorSettings)
addCommandHandler("intset", openInteriorSettings)
