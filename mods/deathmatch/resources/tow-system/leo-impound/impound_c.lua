--MAXIME

--SERVICE PED
local rtImpounder = createPed( 50, 2738.6001, -2543.2, 13.7 )
setPedRotation( rtImpounder, 90.202 )
setElementDimension( rtImpounder, 0)
setElementInterior( rtImpounder , 0 )
setElementData( rtImpounder, "talk", 1, false )
setElementData( rtImpounder, "name", "Jacob Garcia", false )
setElementFrozen(rtImpounder, true)

local pdImpounder = createPed( 281, 1562.373046875, -1614.27734375, 13.3828125 )
setPedRotation( pdImpounder, 15.378356933594 )
setElementDimension( pdImpounder, 0)
setElementInterior( pdImpounder , 0 )
setElementData( pdImpounder, "talk", 1, false )
setElementData( pdImpounder, "name", "Justin Borunda", false )
setElementFrozen(pdImpounder, true)

local scosaImpounder = createPed( 288, 609.1005859375, -595.35546875, 17.233013153076 )
setPedRotation( scosaImpounder, 218 )
setElementDimension( scosaImpounder, 0)
setElementInterior( scosaImpounder , 0 )
setElementData( scosaImpounder, "talk", 1, false )
setElementData( scosaImpounder, "name", "Bobby Jones", false )
setElementFrozen(scosaImpounder, true)

local pdReleasePed = createPed(280, 1363.1103515625, 1379.642578125, 19.447200775146 )
setPedRotation( pdReleasePed, 272 )
setElementDimension( pdReleasePed, 1985)
setElementInterior( pdReleasePed , 18 )
setElementData( pdReleasePed, "talk", 1, false )
setElementData( pdReleasePed, "name", "Sergeant K. Johnson", false )
setElementFrozen(pdReleasePed, true)

local scosaReleasePed = createPed( 288, 618.712890625, -594.1943359375, 17.233013153076 )
setPedRotation( scosaReleasePed, 270 )
setElementDimension( scosaReleasePed, 0)
setElementInterior( scosaReleasePed , 0)
setElementData( scosaReleasePed, "talk", 1, false )
setElementData( scosaReleasePed, "name", "Robert Dunston", false )
setElementFrozen(scosaReleasePed, true)

local rtReleasePed = createPed(240, 1804.765625, -1382.1474609375, 29.240938186646)
setElementInterior(rtReleasePed, 3)
setElementDimension(rtReleasePed, 14)
setElementRotation(rtReleasePed, 0, 0, 155, "default", true)
--setPedAnimation( rtReleasePed, "FOOD", "FF_Sit_Look", -1, true, false, false )
setElementData( rtReleasePed, "talk", 1, false )
setElementData( rtReleasePed, "name", "Greer Reid", false )
addEventHandler("onClientPedDamage", rtReleasePed, cancelEvent)
setElementFrozen(rtReleasePed, true)

car, wImpound, bClose, bRelease, gCars, lCost, IDcolumn = nil

local gui = {
    edit = {},
    button = {},
    window = {},
    label = {},
    memo = {}
}

local timerClose = nil

function openImpGui(dep, vehid, first, last, vehName, plate, vin, laneData)
	closeImpGui()
	showCursor(true)
	guiSetInputEnabled(true)

	gui.window[1] = guiCreateWindow(642, 140, 804, 405, dep.." Impound Lot ((Vehicle ID "..vehid.."))", false)
	guiWindowSetSizable(gui.window[1], false)
	exports.global:centerWindow(gui.window[1])

	gui.label[1] = guiCreateLabel(14, 29, 365, 18, dep == "RT" and "Staff Imformation" or "Officer Information", false, gui.window[1])
	guiSetFont(gui.label[1], "default-bold-small")
	gui.label[2] = guiCreateLabel(31, 58, 82, 25, "First Name:", false, gui.window[1])
	guiLabelSetVerticalAlign(gui.label[2], "center")
	gui.edit[1] = guiCreateEdit(113, 57, 266, 26, first or "", false, gui.window[1])
	guiEditSetMaxLength(gui.edit[1], 200)
	gui.label[3] = guiCreateLabel(31, 87, 82, 25, "Last Name:", false, gui.window[1])
	guiLabelSetVerticalAlign(gui.label[3], "center")
	gui.edit[2] = guiCreateEdit(113, 87, 266, 26, last or "", false, gui.window[1])
	guiEditSetMaxLength(gui.edit[2], 200)
	gui.label[4] = guiCreateLabel(31, 117, 82, 25, "Badge: ", false, gui.window[1])
	guiLabelSetVerticalAlign(gui.label[4], "center")
	gui.edit[3] = guiCreateEdit(113, 117, 266, 26, "", false, gui.window[1])
	guiEditSetMaxLength(gui.edit[3], 200)
	gui.edit[4] = guiCreateEdit(113, 147, 266, 26, "", false, gui.window[1])
	guiEditSetMaxLength(gui.edit[4], 200)
	gui.label[5] = guiCreateLabel(31, 147, 82, 25, "Rank:", false, gui.window[1])
	guiLabelSetVerticalAlign(gui.label[5], "center")
	gui.label[6] = guiCreateLabel(14, 191, 365, 18, "Vehicle Information", false, gui.window[1])
	guiSetFont(gui.label[6], "default-bold-small")
	gui.edit[5] = guiCreateEdit(113, 219, 266, 26, vehName or "", false, gui.window[1])
	guiEditSetMaxLength(gui.edit[5], 200)
	gui.label[7] = guiCreateLabel(31, 219, 82, 25, "Model:", false, gui.window[1])
	guiLabelSetVerticalAlign(gui.label[7], "center")
	gui.edit[6] = guiCreateEdit(113, 249, 266, 26, plate or "", false, gui.window[1])
	guiEditSetMaxLength(gui.edit[6], 200)
	gui.label[8] = guiCreateLabel(31, 249, 82, 25, "Plate:", false, gui.window[1])
	guiLabelSetVerticalAlign(gui.label[8], "center")
	gui.label[9] = guiCreateLabel(31, 279, 82, 25, "VIN:", false, gui.window[1])
	guiLabelSetVerticalAlign(gui.label[9], "center")
	gui.edit[7] = guiCreateEdit(113, 279, 266, 26, vin or "", false, gui.window[1])
	guiEditSetMaxLength(gui.edit[7], 200)
	gui.label[10] = guiCreateLabel(406, 29, 365, 18, "Impound Information", false, gui.window[1])
	guiSetFont(gui.label[10], "default-bold-small")
	gui.edit[8] = guiCreateEdit(505, 57, 266, 26, "", false, gui.window[1])
	guiEditSetMaxLength(gui.edit[8], 200)
	gui.label[11] = guiCreateLabel(423, 57, 82, 25, "Violation(s):", false, gui.window[1])
	guiLabelSetVerticalAlign(gui.label[11], "center")
	gui.edit[9] = guiCreateEdit(505, 87, 266, 26, "", false, gui.window[1])
	guiEditSetMaxLength(gui.edit[9], 200)
	gui.label[12] = guiCreateLabel(423, 88, 82, 25, "From Location:", false, gui.window[1])
	guiLabelSetVerticalAlign(gui.label[12], "center")
	gui.label[1] = guiCreateLabel(423, 118, 119, 25, "Lane Number:", false, gui.window[1])
	guiLabelSetVerticalAlign(gui.label[1], "center")
	gui.edit[10] = guiCreateEdit(542, 118, 142, 25, laneData[1].lane or "FULL", false, gui.window[1])
	guiEditSetMaxLength(gui.edit[10], 200)
	gui.label[2] = guiCreateLabel(694, 118, 77, 25, laneData[2].."/"..laneData[3], false, gui.window[1])
	guiLabelSetVerticalAlign(gui.label[2], "center")
	gui.label[13] = guiCreateLabel(423, 148, 119, 25, "Is up for release in:", false, gui.window[1])
	guiLabelSetVerticalAlign(gui.label[13], "center")
	gui.edit[11] = guiCreateEdit(542, 148, 142, 25, dep == "RT" and "Irrelevant" or "1", false, gui.window[1])
	guiEditSetMaxLength(gui.edit[11], 200)
	gui.label[14] = guiCreateLabel(694, 148, 85, 25, "0 day = seized", false, gui.window[1])
	guiLabelSetVerticalAlign(gui.label[14], "center")
	gui.label[15] = guiCreateLabel(413, 217, 365, 18, "Additional Information", false, gui.window[1])
	guiSetFont(gui.label[15], "default-bold-small")
	gui.memo[1] = guiCreateMemo(423, 242, 348, 63, "", false, gui.window[1])
	gui.button[1] = guiCreateButton(21, 338, 368, 41, "Cancel", false, gui.window[1])
	gui.button[2] = guiCreateButton(413, 338, 368, 41, "Impound", false, gui.window[1])
	gui.label[3] = guiCreateLabel(423, 178, 119, 25, "Fine in dollars:", false, gui.window[1])
	guiLabelSetVerticalAlign(gui.label[3], "center")
	gui.edit[12] = guiCreateEdit(542, 178, 142, 25, dep == "RT" and "Irrelevant" or "0", false, gui.window[1])
	guiEditSetMaxLength(gui.edit[1], 200)

	guiSetEnabled(gui.label[3], dep ~= "RT")
	guiSetEnabled(gui.label[14], dep ~= "RT")
	guiSetEnabled(gui.label[13], dep ~= "RT")
	guiSetEnabled(gui.edit[11], dep ~= "RT")
	guiSetEnabled(gui.edit[12], dep ~= "RT")

	addEventHandler("onClientGUIClick", gui.window[1], function ()
		if source == gui.button[1] then
			closeImpGui()
		elseif source == gui.button[2] then
			local pedName = "Justin Borunda"
			if dep == "SCoSA" then
				pedName = "Bobby Jones"
			elseif dep == "LSPD" then
				pedName = "Justin Borunda"
			elseif dep == "RT" then
				pedName = "Jacob Garcia"
			end

			local laneNumber = guiGetText(gui.edit[10])
			if not laneNumber or not tonumber(laneNumber) or tonumber(laneNumber) < 1 then
				return triggerServerEvent("tow:pedSay", localPlayer, pedName, "invalid_lanes")
			end
			local days = tonumber(guiGetText(gui.edit[11])) or 0
			if dep ~= "RT" and (not days or not tonumber(days) or tonumber(days) < 0 or tonumber(days) > 500) then
				return triggerServerEvent("tow:pedSay", localPlayer, pedName, "invalid_days")
			end
			local other = guiGetText(gui.memo[1])
			if string.len(other) > 1000 then
				return triggerServerEvent("tow:pedSay", localPlayer, pedName, "too_long_info")
			end
			local fine = guiGetText(gui.edit[12])
			if dep ~= "RT" and (not fine or not tonumber(fine) or tonumber(fine) < 0 or tonumber(fine) > 50000) then
				return triggerServerEvent("tow:pedSay", localPlayer, pedName, "invalid_fine")
			end
			fine = math.floor(tonumber(fine) or 0)
			local first = guiGetText(gui.edit[1])
			local last = guiGetText(gui.edit[2])
			local badge = guiGetText(gui.edit[3])
			local rank = guiGetText(gui.edit[4])
			local vehName = guiGetText(gui.edit[5])
			local plate = guiGetText(gui.edit[6])
			local vin = guiGetText(gui.edit[7])
			local volations = guiGetText(gui.edit[8])
			local location = guiGetText(gui.edit[9])
			triggerServerEvent("tow:leoStartImpounding", localPlayer, dep, vehid, laneNumber, days, fine, first, last, badge, rank, vehName, plate, vin, volations, location, other)
			guiSetText(gui.button[2], "Impounding")
			guiSetEnabled(gui.window[1], false)
			if timerClose and isTimer(timerClose) then
				killTimer(timerClose)
			end
			timerClose = setTimer(closeImpGui, 1000*10, 1) -- 10 seconds
		end
	end)
	exports["item-system"]:playSoundInvOpen()
end
addEvent("tow:openImpGui", true)
addEventHandler("tow:openImpGui", root, openImpGui)

function closeImpGui()
	if gui.window[1] and isElement(gui.window[1]) then
		destroyElement(gui.window[1])
		showCursor(false)
		guiSetInputEnabled(false)
		exports["item-system"]:playSoundInvClose()
		if timerClose and isTimer(timerClose) then
			killTimer(timerClose)
		end
	end
end

function reEnableImpGui(justCloseGUI)
	if gui.window[1] and isElement(gui.window[1]) then
		if timerClose and isTimer(timerClose) then
			killTimer(timerClose)
		end
		if justCloseGUI then
			closeImpGui()
			playSFX("script", 20, 2, false)
		else
			guiSetText(gui.button[2], "Impound")
			guiSetEnabled(gui.window[1], true)
		end
	end
end
addEvent("tow:reEnableImpGui", true)
addEventHandler("tow:reEnableImpGui", root, reEnableImpGui)

--openImpGui()
rgui = {
    gridlist = {},
    window = {},
    button = {},
    label = {}
}

function formatDays(days)
	days = tonumber(days)
	if days == 0 then
		return "Today"
	elseif days == 1 then
		return "Yesterday"
	else
		return days.." days ago"
	end
end
function openReleaseGUI(factionId, vehs)
	closeRgui()
	showCursor(true)
	local pedName = "Sergeant K. Johnson"
	local factionName = "LSPD"
	if factionId == 59 then
		pedName = "Robert Dunston"
		factionName = "SCoSA"
	elseif factionId == 1 then
		pedName = "Sergeant K. Johnson"
		factionName = "LSPD"
	elseif factionId == 4 then
		pedName = "Greer Reid"
		factionName = "RT"
	end

	local cost = 75
	if factionId == 4 then
		cost = 125
	end
	local costPerDay = cost
	rgui.window[1] = guiCreateWindow(587, 335, 749, 326, factionName.." Impound Lot | Help Desk", false)
	guiWindowSetSizable(rgui.window[1], false)
	exports.global:centerWindow(rgui.window[1])

	rgui.label[1] = guiCreateLabel(27, 40, 696, 35, "To release your vehicle, you will have to pay for the tow and daily storage fees of $"..exports.global:formatMoney(costPerDay).." a day. You may also have to pay in extra if there's any fine issued on your vehicle.", false, rgui.window[1])
	guiLabelSetHorizontalAlign(rgui.label[1], "left", true)
	rgui.gridlist[1] = guiCreateGridList(27, 95, 696, 162, false, rgui.window[1])
	rgui.col_vin = guiGridListAddColumn(rgui.gridlist[1], "VIN", 0.1)
	rgui.col_mod = guiGridListAddColumn(rgui.gridlist[1], "Model", 0.4)
	rgui.col_days = guiGridListAddColumn(rgui.gridlist[1], "Impounded", 0.15)
	rgui.col_fine = guiGridListAddColumn(rgui.gridlist[1], "Fine ($)", 0.1)
	rgui.col_date = guiGridListAddColumn(rgui.gridlist[1], "Release Date", 0.2)

	for vin, veh in pairs(vehs) do
		local row = guiGridListAddRow ( rgui.gridlist[1] )
		guiGridListSetItemText( rgui.gridlist[1], row, rgui.col_vin, vin, false, true )
		guiGridListSetItemText( rgui.gridlist[1], row, rgui.col_mod, veh.model, false, false )
		local days = tonumber(veh.impounded) <= 0 and 75 or tonumber(veh.impounded)
		guiGridListSetItemText( rgui.gridlist[1], row, rgui.col_days, formatDays(veh.impounded), false, true )
		guiGridListSetItemText( rgui.gridlist[1], row, rgui.col_fine, veh.lane and veh.lane.fine or 0, false, true )
		local releasteDate = (veh.lane and veh.lane.release_date) and veh.lane.release_date or "Seized"
		if factionId == 4 then
			releasteDate = "Anytime"
		end
		guiGridListSetItemText( rgui.gridlist[1], row, rgui.col_date, releasteDate , false, false )
	end

	rgui.label[2] = guiCreateLabel(37, 271, 188, 34, "Total: --", false, rgui.window[1])
	guiSetFont(rgui.label[2], "default-bold-small")
	guiLabelSetColor(rgui.label[2], 0, 255, 0)
	guiLabelSetVerticalAlign(rgui.label[2], "center")
	rgui.button[1] = guiCreateButton(621, 275, 102, 31, "Pay & Release", false, rgui.window[1])
	rgui.button[2] = guiCreateButton(514, 275, 102, 31, "Close", false, rgui.window[1])
	guiSetEnabled(rgui.button[1], false)

	addEventHandler("onClientGUIClick", rgui.window[1], function()
		local selectedRow, selectedCol = guiGridListGetSelectedItem( rgui.gridlist[1] )
		local selectedvin = tonumber(guiGridListGetItemText( rgui.gridlist[1], selectedRow, rgui.col_vin ))
		if source == rgui.button[1] then
			if selectedRow == -1 or selectedCol == -1 then
				triggerServerEvent("tow:pedSay", localPlayer, pedName, "select_to_release")
			else
				if exports.global:hasMoney(localPlayer, cost) then
					triggerServerEvent("tow:release", localPlayer, pedName, selectedvin, cost)
					closeRgui()
					exports.global:playSoundSuccess()
				else
					triggerServerEvent("tow:pedSay", localPlayer, pedName, "May I have $"..exports.global:formatMoney(cost).." please?")
				end
			end
		elseif source == rgui.button[2] then
			closeRgui()
		elseif source == rgui.gridlist[1] then
			if selectedvin then
				local veh = vehs[selectedvin]
				cost = 0
				cost = tonumber(veh.impounded)*costPerDay
				if cost == 0 then cost = costPerDay end
				cost = cost + tonumber(veh.lane and veh.lane.fine or 0)
				guiSetText(rgui.label[2], "Total: $"..exports.global:formatMoney(cost))
				guiSetEnabled(rgui.button[1], true)
			else
				guiSetEnabled(rgui.button[1], false)
			end
		end
	end)
	exports['item-system']:playSoundInvOpen()
end
addEvent("tow:openReleaseGUI", true)
addEventHandler("tow:openReleaseGUI", root, openReleaseGUI)

function closeRgui()
	if rgui.window[1] and isElement(rgui.window[1]) then
		destroyElement(rgui.window[1])
		exports['item-system']:playSoundInvClose()
		showCursor(false)
	end
end
