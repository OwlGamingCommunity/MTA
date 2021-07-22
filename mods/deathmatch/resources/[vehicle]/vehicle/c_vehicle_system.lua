--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local gui = {}

function build_SaleGUI(itemValue)

	if gui["_root"] and isElement(gui["_root"]) then destroyElement(gui["_root"]) end

	guiSetInputMode("no_binds_when_editing")
	showCursor(true)

	gui._placeHolders = {}

	local screenWidth, screenHeight = guiGetScreenSize()
	local windowWidth, windowHeight = 400, 252
	local left = screenWidth/2 - windowWidth/2
	local top = screenHeight/2 - windowHeight/2
	gui["_root"] = guiCreateWindow(left, top, windowWidth, windowHeight, "Department of Motor Vehicles", false)
	guiWindowSetSizable(gui["_root"], false)

	gui["label"] = guiCreateLabel(170, 25, 70, 45, "Vehicle Sale", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["label"], "left", false)
	guiLabelSetVerticalAlign(gui["label"], "center")

	gui["label_2"] = guiCreateLabel(30, 75, 331, 21, "By signing this document, I agree to grant all ownership", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["label_2"], "left", false)
	guiLabelSetVerticalAlign(gui["label_2"], "center")

	gui["label_3"] = guiCreateLabel(30, 95, 331, 21, "rights of this motor vehicle to this mentioned person.", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["label_3"], "left", false)
	guiLabelSetVerticalAlign(gui["label_3"], "center")

	gui["lineEdit"] = guiCreateEdit(30, 155, 231, 21, "", false, gui["_root"])
	guiEditSetMaxLength(gui["lineEdit"], 32767)

	gui["label_4"] = guiCreateLabel(30, 135, 150, 16, "New owner's name", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["label_4"], "left", false)
	guiLabelSetVerticalAlign(gui["label_4"], "center")

	gui["pushButton"] = guiCreateButton(180, 195, 91, 31, "Sell", false, gui["_root"])
	addEventHandler("onClientGUIClick", gui["pushButton"], function ()
			triggerServerEvent("sellVehiclePapers", getResourceRootElement(), localPlayer, "sell", guiGetText(gui["lineEdit"]), itemValue)
		end, false)


	gui["pushButton_2"] = guiCreateButton(290, 195, 91, 31, "Close", false, gui["_root"])
	addEventHandler("onClientGUIClick", gui["pushButton_2"], function ()
			destroyElement(gui["_root"])
			showCursor(false)
			guiSetInputMode("allow_binds")
		end, false)

	return gui, windowWidth, windowHeight
end
addEvent("build_carsale_gui", true)
addEventHandler("build_carsale_gui", localPlayer, build_SaleGUI)

addEvent("close:build_carsale_gui", true)
addEventHandler("close:build_carsale_gui", localPlayer, function()
	if isElement(gui["_root"]) then
		destroyElement(gui["_root"])
		showCursor(false)
		guiSetInputMode("allow_binds")
	end
end)


--Maxime / 2015.2.10
GUIEditor = {
    button = {},
    window = {},
    edit = {},
    label = {}
}

function openVehSales(cmd, ...)
	closeVehSales()
	local veh = getPedOccupiedVehicle(localPlayer)
	if veh then
		local faction, _ = exports.factions:isPlayerInFaction(localPlayer, getElementData(veh, "faction"))
		local leader = exports.factions:hasMemberPermissionTo(localPlayer, getElementData(veh, "faction"), "respawn_vehs")
		if (exports.integration:isPlayerAdmin(localPlayer) and getElementData(localPlayer, "duty_admin") == 1 ) or (getElementData(veh, "owner") == getElementData(localPlayer, "dbid")) or (leader and faction) then
			if not (...) then
				return outputChatBox("SYNTAX: /" .. cmd .. " [partial player name / id]", 255, 194, 14)
			end

			exports['item-system']:playSoundInvOpen()

			GUIEditor.window[1] = guiCreateWindow(1107, 377, 391, 181, "Vehicle Ownership Transfer", false)
			guiWindowSetSizable(GUIEditor.window[1], false)
			exports.global:centerWindow(GUIEditor.window[1])

			GUIEditor.label[1] = guiCreateLabel(35, 36, 323, 79, "You're about to sell vehicle ID# () to player.\n\nTo prevent OOC Vehicle Scam, please input an amount of money that you have agreed with them to start selling:", false, GUIEditor.window[1])
			guiLabelSetHorizontalAlign(GUIEditor.label[1], "left", true)
			GUIEditor.label[2] = guiCreateLabel(20, 131, 21, 25, "$", false, GUIEditor.window[1])
			guiLabelSetHorizontalAlign(GUIEditor.label[2], "center", false)
			guiLabelSetVerticalAlign(GUIEditor.label[2], "center")
			GUIEditor.edit[1] = guiCreateEdit(41, 131, 176, 25, "sdwd23dsdsdad", false, GUIEditor.window[1])
			GUIEditor.button[1] = guiCreateButton(221, 131, 70, 25, "Sell", false, GUIEditor.window[1])
			GUIEditor.button[2] = guiCreateButton(291, 131, 70, 25, "Close", false, GUIEditor.window[1])
			addEventHandler("onClientGUIClick", GUIEditor.window[1], function ()
				if source == GUIEditor.button[1] then

				elseif source == GUIEditor.button[2] then
					closeVehSales()
				end
			end)
			addEventHandler("onClientPlayerVehicleExit", localPlayer, sellCheck)
		else
			return outputChatBox("You do not own this vehicle or you're not a leader of the faction that owns this vehicle.", 255, 0, 0)
		end
	end
end
--addCommandHandler("sell", openVehSales)

function closeVehSales()
	if GUIEditor.window[1] and isElement(GUIEditor.window[1]) then
		destroyElement(GUIEditor.window[1])
		GUIEditor.window[1] = nil
		exports['item-system']:playSoundInvClose()
		removeEventHandler("onClientPlayerVehicleExit", localPlayer, sellCheck)
	end
end

function sellCheck()
	if localPlayer == source then
		closeVehSales()
	end
end

addEvent('onClientElementDataChange', true)
addEventHandler('onClientElementDataChange', root,
    function(dataName, oldValue)
        if dataName == "vehicle:windowstat" and getElementType(source) == "vehicle" then
			for _,window in ipairs({2,3,4,5}) do
				setVehicleWindowOpen(source, window, getElementData(source, "vehicle:windowstat") == 1)
			end
		end
    end)
	
-- basic detection system to check if a player fell off a bike

local clientStartExit = false

addEventHandler("onClientVehicleStartExit", getRootElement(), function(thePlayer)
	if thePlayer == localPlayer and (getVehicleType(source) == "Bike" or getVehicleType(source) == "BMX") then
		clientStartExit = true
	else
		clientStartExit = false
	end
end)

addEventHandler("onClientVehicleExit", getRootElement(), function(thePlayer)
	if thePlayer == localPlayer and (getVehicleType(source) == "Bike" or getVehicleType(source) == "BMX") and not clientStartExit then
		-- The player fell off the bike because onClientVehicleStartExit was not triggered.
		if isVehicleLocked(source) then
			triggerServerEvent("lockUnlockOutsideVehicle", thePlayer, source)
			outputChatBox("Your bike has been automatically unlocked because you fell off.", 255, 0, 0)
		end
		clientStartExit = false
		triggerServerEvent("vehicle:realinvehicle", resourceRoot, thePlayer, 0)
	end
end)
