function setPlayerFreecamEnabled(player, x, y, z, dontChangeFixedMode)
	removePedFromVehicle(player)
	setElementData(player, "realinvehicle", 0, false)

	return triggerClientEvent(player,"doSetFreecamEnabled", getRootElement(), x, y, z, dontChangeFixedMode)
end

function setPlayerFreecamDisabled(player, dontChangeFixedMode)
	return triggerClientEvent(player,"doSetFreecamDisabled", getRootElement(), dontChangeFixedMode)
end

function setPlayerFreecamOption(player, theOption, value)
	return triggerClientEvent(player,"doSetFreecamOption", getRootElement(), theOption, value)
end

function isPlayerFreecamEnabled(player)
	return isEnabled(player)
end

--Maxime's rework
function asyncActivateFreecam ()
	if not isEnabled(source) then
		outputDebugString("[FREECAM] asyncActivateFreecam / Ran")
		removePedFromVehicle(source)
		setElementAlpha(source, 0)
		setElementFrozen(source, true)
		if not exports.integration:isPlayerTrialAdmin(source) and not exports.integration:isPlayerScripter(source) then
			exports.global:sendMessageToAdmins("[FREECAM] "..exports.global:getAdminTitle1(source).." has activated temporary /freecam.")
		end
		setElementData(source, "freecam:state", true, false)
		exports.logs:dbLog(source, 4, {source}, "FREECAM")
	end
end
addEvent("freecam:asyncActivateFreecam", true)
addEventHandler("freecam:asyncActivateFreecam", root, asyncActivateFreecam)

function asyncDeactivateFreecam ()
	if true or isEnabled(source) then
		outputDebugString("[FREECAM] asyncDeactivateFreecam / Ran")
		removePedFromVehicle(source)
		setElementAlpha(source, 255)
		setElementFrozen(source, false)
		setElementData(source, "freecam:state", false, false)
	end
end
addEvent("freecam:asyncDeactivateFreecam", true)
addEventHandler("freecam:asyncDeactivateFreecam", root, asyncDeactivateFreecam)
