--MAXIME
local mysql = exports.mysql

local function ownsInterior(player, interior)
	local status = getElementData(interior, 'status')

	return status.owner == getElementData(player, 'dbid')
end

function openKeypadInterface(thePad)
	local intID = getElementData(thePad, "itemValue") 
	--outputDebugString(intID)
	if not intID then
		exports.hud:sendBottomNotification(source, "Keyless Digital Door Lock", "System overloaded, try again later.")
		return false
	end
	for i, theInterior in pairs(getElementsByType("interior")) do
		if getElementData(theInterior, "dbid") == intID then
			if isSomeoneElseUsingAnyKeypadOfThis(theInterior) then
				exports.hud:sendBottomNotification(source, "Keyless Digital Door Lock", "System overloaded, try again later.")
			else
				setElementData(source, "padUsing", getElementData(thePad, "id"))
				setElementData(thePad, "playerUsing", getElementData(source, "dbid"))
				triggerClientEvent(source, "openKeypadInterface", source, thePad)
			end
			break
		end
	end
end
addEvent("openKeypadInterface", true)
addEventHandler("openKeypadInterface", root, openKeypadInterface)

function installKeypad(thePad, theInterior)
	if not ownsInterior(source, theInterior) then return end

	if setElementData( theInterior, "keypad_lock", getElementData(thePad, "id"), true) then
		if mysql:query_free("UPDATE `interiors` SET `keypad_lock`='"..getElementData(thePad, "id").."' WHERE `id`='"..getElementData(theInterior, "dbid").."' ") then
			outputDebugString("Keyless Digital Door Lock installation is done.")
		else
			outputDebugString("Keyless Digital Door Lock installation is failed. 1")
		end
	else
		outputDebugString("Keyless Digital Door Lock installation is failed. 2")
	end
end
addEvent("installKeypad", true)
addEventHandler("installKeypad", root, installKeypad)

function uninstallKeypad(thePad, theInterior)
	if not ownsInterior(client, theInterior) then return end

	if getElementData(theInterior, "status").locked then
		triggerClientEvent(source, "keypadRecieveResponseFromServer", source, "uninstallKeypad - failed")
		return false
	end

	if not exports.global:hasSpaceForItem(source, 169, 1) then
		triggerClientEvent(source, "keypadRecieveResponseFromServer", source, "uninstallKeypad - failed 2")
		return false
	end

	if theInterior and isElement(theInterior) and getElementData(theInterior, "keypad_lock") then
		local count = -1
		for key, thePad2 in pairs(getElementsByType("object", getResourceRootElement(getResourceFromName("item-world")))) do
			if getElementData(thePad2, "itemID") == 169 and getElementData(thePad2, "itemValue") == getElementData(theInterior, "dbid") then
				count = count + 1
			end
		end

		if count <= 0 then
			removeElementData(theInterior, "keypad_lock")
			removeElementData(theInterior, "keypad_lock_pw")
			removeElementData(theInterior, "keypad_lock_auto")
			mysql:query_free("UPDATE `interiors` SET `keypad_lock`=NULL, `keypad_lock_pw`=NULL, `keypad_lock_auto`=NULL WHERE `id`='"..getElementData(theInterior, "dbid").."' ")
		end
	end

	triggerEvent("pickupItem", source, thePad)
	triggerClientEvent(source, "closeKeypadInterface", source)
end
addEvent("uninstallKeypad", true)
addEventHandler("uninstallKeypad", root, uninstallKeypad)

function registerNewPasscode(theInterior, passcode)
	if not ownsInterior(client, theInterior) then return end

	dbExec(exports.mysql:getConn('mta'), "UPDATE interiors SET keypad_lock_pw = ? WHERE id = ?", passcode, getElementData(theInterior, 'dbid'))

	triggerClientEvent(source, "keypadRecieveResponseFromServer", source, "registerNewPasscode - ok")
end
addEvent("registerNewPasscode", true)
addEventHandler("registerNewPasscode", root, registerNewPasscode)

function togKeypadAutoLock(theInt)
	if not ownsInterior(client, theInt) then return end

	local currentState = getElementData(theInt, "keypad_lock_auto") or false
	local intID = getElementData(theInt, "dbid")
	local allDone = true
	if currentState then
		if removeElementData(theInt, "keypad_lock_auto") and mysql:query_free("UPDATE `interiors` SET `keypad_lock_auto`=NULL WHERE `id`='"..intID.."' ") then
			triggerClientEvent(source, "keypadRecieveResponseFromServer", source, "togKeypadAutoLock - off")
		else
			allDone = false
		end
	else
		if setElementData(theInt, "keypad_lock_auto", not currentState) and mysql:query_free("UPDATE `interiors` SET `keypad_lock_auto`='1' WHERE `id`='"..intID.."' ") then
			triggerClientEvent(source, "keypadRecieveResponseFromServer", source, "togKeypadAutoLock - on")
		else
			allDone = false
		end
	end

	if not allDone then
		triggerClientEvent(source, "keypadRecieveResponseFromServer", source, false)
	end
end
addEvent("togKeypadAutoLock", true)
addEventHandler("togKeypadAutoLock", root, togKeypadAutoLock)

function resourceStop()
	local theResource = getResourceFromName(tostring("item-system"))
	if theResource then
		--restartResource(theResource)
	end

	if getResourceFromName(tostring("item-world")) then
		for key, thePad in pairs(getElementsByType("object", getResourceRootElement(getResourceFromName("item-world")))) do
			if getElementData(thePad, "itemID") == 169 and getElementData(thePad, "playerUsing") then
				removeElementData(thePad, "playerUsing")
			end
		end
	end

	for key, thePlayer in pairs(getElementsByType("player")) do
		if getElementData(thePlayer, "padUsing") then
			removeElementData(thePlayer, "padUsing")
		end
	end
end
addEventHandler("onResourceStop", resourceRoot, resourceStop)

function playerQuit()
	--keypad door lock / maxime
	local padID = getElementData(source, "padUsing")
	if padID then
		for i, thePad in pairs(getElementsByType("object", getResourceRootElement(getResourceFromName("item-world")))) do
			if getElementData(thePad, "id") == padID then
				removeElementData(thePad, "playerUsing")
				break
			end
		end
	end
end
addEventHandler("onPlayerQuit", root, playerQuit)

function isSomeoneElseUsingAnyKeypadOfThis(theInterior)
	if not theInterior or not isElement(theInterior) then
		return false
	end

	local intID = getElementData(theInterior, "dbid")

	if not intID then
		return false
	end

	for key, thePad in pairs(getElementsByType("object", getResourceRootElement(getResourceFromName("item-world")))) do
		if getElementData(thePad, "itemID") == 169 and getElementData(thePad, "itemValue") == intID and getElementData(thePad, "playerUsing") then
			outputDebugString("playerUsing found in thePad - ".. getElementData(thePad, "playerUsing"))
			for key, thePlayer in pairs(getElementsByType("player")) do
				if getElementData(thePlayer, "dbid") == getElementData(thePad, "playerUsing") then
					outputDebugString("Online player id matched - ".. getPlayerName(thePlayer))
					return true
				end
			end
		end
	end
	return false
end

function keypadFreeUsingSlots(thePad)
	outputDebugString("triggered - keypadFreeUsingSlots")
	if getElementData(thePad, "playerUsing") then
		removeElementData(thePad, "playerUsing")
	end

	if getElementData(source, "padUsing") then
		removeElementData(source, "padUsing")
	end
end
addEvent("keypadFreeUsingSlots", true)
addEventHandler("keypadFreeUsingSlots", root, keypadFreeUsingSlots)

function playSyncedSound(code, thePad)
	triggerClientEvent("playSyncedSound", source, code, thePad)
end
addEvent("playSyncedSound", true)
addEventHandler("playSyncedSound", root, playSyncedSound)

