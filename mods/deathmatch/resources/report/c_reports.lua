wReportMain, bClose, lStatus, lVehTheft, lPropBreak, lPapForgery, lVehTheftStatus, lPropBreakStatus, lPapForgeryStatus, bVehTheft, bPropBreak, bPapForgery, bHelp, lPlayerName, tPlayerName, lNameCheck, lReport, tReport, lLengthCheck, bSubmitReport = nil

function resourceStop()
	guiSetInputEnabled(false)
	showCursor(false)
end
addEventHandler("onClientResourceStop", getResourceRootElement(), resourceStop)

function toggleReport()
	executeCommandHandler('report')
	if wHelp then
		guiSetInputEnabled(false)
		showCursor(false)
		destroyElement(wHelp)
		wHelp = nil
	end
end

function checkBinds()
	if ( exports.integration:isPlayerTrialAdmin(getLocalPlayer()) or getElementData( getLocalPlayer(), "account:gmlevel" )  ) then
		if getBoundKeys("ar") or getBoundKeys("acceptreport") then
			--outputChatBox("You had keys bound to accept reports. Please delete these binds.", 255, 0, 0)
			triggerServerEvent("arBind", getLocalPlayer())
		end
	end
end
setTimer(checkBinds, 60000, 0)

local function scale(w)
	local width, height = guiGetSize(w, false)
	local screenx, screeny = guiGetScreenSize()
	local minwidth = math.min(700, screenx)
	if width < minwidth then
		guiSetSize(w, minwidth, height / width * minwidth, false)
		local width, height = guiGetSize(w, false)
		guiSetPosition(w, (screenx - width) / 2, (screeny - height) / 2, false)
	end
end

function showReportMainUI()
	local logged = getElementData(getLocalPlayer(), "loggedin")
	--outputDebugString(logged)
	if (logged==1) then
		if (wReportMain==nil)  then
			reportedPlayer = nil
			wReportMain = guiCreateWindow(0.2, 0.2, 0.2, 0.25, "OwlGaming - F2 - Report", true)
			scale(wReportMain)

			-- Controls within the window
			bClose = guiCreateButton(0.85, 0.9, 0.2, 0.1, "Close", true, wReportMain)
			addEventHandler("onClientGUIClick", bClose, clickCloseButton)

			-- Status
			lStatus = guiCreateLabel(0.48, 0.05, 1.0, 0.5, "Status", true, wReportMain)
			guiSetFont(lStatus, "default-bold-small")

			lVehTheft = guiCreateLabel(0.125, 0.1, 1.0, 0.5, "Vehicle Theft", true, wReportMain)
			lPropBreak = guiCreateLabel(0.44, 0.1, 1.0, 0.5, "Property Break-in", true, wReportMain)
			--lPapForgery = guiCreateLabel(0.75, 0.1, 1.0, 0.5, "Paper Forgery", true, wReportMain)

			local vehTheftStatus = getElementData(resourceRoot, "vehtheft")
			local propBreakStatus = getElementData(resourceRoot, "propbreak")
			--local papForgeStatus = getElementData(resourceRoot, "papforg")

			lVehTheftStatus = guiCreateLabel(0.145, 0.15, 1.0, 0.5, vehTheftStatus, true, wReportMain)
			lPropBreakStatus = guiCreateLabel(0.47, 0.15, 1.0, 0.5, propBreakStatus, true, wReportMain)

			local canEditStatus = exports.integration:isPlayerTrialAdmin(getLocalPlayer())

			if canEditStatus then
				bVehTheft = guiCreateButton(0.130, 0.2, 0.10, 0.05, "Toggle", true, wReportMain)
				bPropBreak = guiCreateButton(0.45, 0.2, 0.10, 0.05, "Toggle", true, wReportMain)
				--bPapForgery = guiCreateButton(0.75, 0.2, 0.10, 0.05, "Toggle", true, wReportMain)

				addEventHandler("onClientGUIClick", bVehTheft, toggleVehTheft, false)
				addEventHandler("onClientGUIClick", bPropBreak, togglePropBreak, false)
				--addEventHandler("onClientGUIClick", bPapForgery, togglePaperForg, false)
			end

			guiSetInputEnabled(true)

			bHelp = guiCreateButton(0.025, 0.9, 0.2, 0.1, "View Help/Commands", true, wReportMain)
			guiSetEnabled(bHelp, true)
			addEventHandler("onClientGUIClick", bHelp, clickCloseButton)

			lPlayerName = guiCreateLabel(0.025, 0.28, 1.0, 0.3, "Player you wish to report (Optional):", true, wReportMain)
			guiSetFont(lPlayerName, "default-bold-small")

			tPlayerName = guiCreateEdit(0.025, 0.32, 0.25, 0.08, "Player Partial Name / ID", true, wReportMain)
			addEventHandler("onClientGUIClick", tPlayerName, function()
				guiSetText(tPlayerName,"")
			end, false)

			lNameCheck = guiCreateLabel(0.025, 0.4, 1.0, 0.3, "You're reporting yourself.", true, wReportMain)
			guiSetFont(lNameCheck, "default-bold-small")
			guiLabelSetColor(lNameCheck, 0, 255, 0)
			addEventHandler("onClientGUIChanged", tPlayerName, checkNameExists)

			lReportType = guiCreateLabel(0.4, 0.28, 0.23, 0.3, "Select the option that best\nsuites your report.\n\nThis will send your report\nto the proper staff member.", true, wReportMain)

			cReportType = guiCreateComboBox(0.65, 0.32, 0.3, 0.34, "Report Type", true, wReportMain)
			for key, value in ipairs(reportTypes) do
				guiComboBoxAddItem(cReportType, value[1])
			end
			addEventHandler("onClientGUIComboBoxAccepted", cReportType, canISubmit)
			addEventHandler("onClientGUIComboBoxAccepted", cReportType, function()
				local selected = guiComboBoxGetSelected(cReportType)+1
				guiLabelSetHorizontalAlign( lReportType, "center", true)
				guiSetText(lReportType, reportTypes[selected][7])
				end)

			lReport = guiCreateLabel(0, 0.46, 1.0, 0.3, "~==Report Information==~", true, wReportMain)
			guiLabelSetHorizontalAlign(lReport, "center")
			guiSetFont(lReport, "default-bold-small")
			guiSetFont(lPlayerName, "default-bold-small")

			tReport = guiCreateMemo(0.025, 0.49, 6, 0.3, "", true, wReportMain)
			addEventHandler("onClientGUIChanged", tReport, canISubmit)

			lLengthCheck = guiCreateLabel(0.4, 0.81, 0.4, 0.3, "Length: " .. string.len(tostring(guiGetText(tReport)))-1 .. "/150 Characters.", true, wReportMain)
			guiLabelSetColor(lLengthCheck, 0, 255, 0)
			guiSetFont(lLengthCheck, "default-bold-small")

			bSubmitReport = guiCreateButton(0.4, 0.875, 0.2, 0.1, "Submit Report", true, wReportMain)
			addEventHandler("onClientGUIClick", bSubmitReport, submitReport)
			guiSetEnabled(bSubmitReport, false)

			guiWindowSetSizable(wReportMain, false)
			showCursor(true)

		elseif (wReportMain~=nil) then
			guiSetVisible(wReportMain, false)
			destroyElement(wReportMain)

			wReportMain, bClose, lStatus, lVehTheft, lPropBreak, lPapForgery, lVehTheftStatus, lPropBreakStatus, lPapForgeryStatus, bVehTheft, bPropBreak, bPapForgery, bHelp, lPlayerName, tPlayerName, lNameCheck, lReport, tReport, lLengthCheck, bSubmitReport = nil
			guiSetInputEnabled(false)
			showCursor(false)
		end
	end
end
--addCommandHandler('report', showReportMainUI)

function submitReport(button, state)
	if (source==bSubmitReport) and (button=="left") and (state=="up") then
		triggerServerEvent("clientSendReport", getLocalPlayer(), reportedPlayer or getLocalPlayer(), tostring(guiGetText(tReport)), (guiComboBoxGetSelected(cReportType)+1))

		if (wReportMain~=nil) then
			destroyElement(wReportMain)
		end

		if (wHelp) then
			destroyElement(wHelp)
		end

		wReportMain, bClose, lStatus, lVehTheft, lPropBreak, lPapForgery, lVehTheftStatus, lPropBreakStatus, lPapForgeryStatus, bVehTheft, bPropBreak, bPapForgery, bHelp, lPlayerName, tPlayerName, lNameCheck, lReport, tReport, lLengthCheck, bSubmitReport = nil
		guiSetInputEnabled(false)
		showCursor(false)
	end
end

function checkReportLength(theEditBox)
	guiSetText(lLengthCheck, "Length: " .. string.len(tostring(guiGetText(tReport)))-1 .. "/150 Characters.")

	if (tonumber(string.len(tostring(guiGetText(tReport))))-1>150) then
		guiLabelSetColor(lLengthCheck, 255, 0, 0)
		return false
	elseif (tonumber(string.len(tostring(guiGetText(tReport))))-1<3) then
		guiLabelSetColor(lLengthCheck, 255, 0, 0)
		return false
	elseif (tonumber(string.len(tostring(guiGetText(tReport))))-1>130) then
		guiLabelSetColor(lLengthCheck, 255, 255, 0)
		return true
	else
		guiLabelSetColor(lLengthCheck,0, 255, 0)
		return true
	end
end

function canISubmit()
	local rReportLength = checkReportLength()
	local reportnum = getElementData(getLocalPlayer(), "reportNum")
	if rReportLength then
		if reportnum then
			guiSetText(wReportMain, "Your report ID #" .. (reportnum[8] or "").. " is still pending. Please wait or /er before submitting another.")
		else
			guiSetEnabled(bSubmitReport, true)
		end
	else
		guiSetEnabled(bSubmitReport, false)
		if err then
			guiSetText(wReportMain, err)
		end
	end
end

function checkNameExists(theEditBox)
	local found = nil
	local count = 0


	local text = guiGetText(theEditBox)
	if text and #text > 0 then
		local players = getElementsByType("player")
		if tonumber(text) then
			local id = tonumber(text)
			for key, value in ipairs(players) do
				if getElementData(value, "playerid") == id then
					found = value
					count = 1
					break
				end
			end
		else
			for key, value in ipairs(players) do
				local username = string.lower(tostring(getPlayerName(value)))
				if string.find(username, string.lower(text)) then
					count = count + 1
					found = value
					break
				end
			end
		end
	end

	if (count>1) then
		guiSetText(lNameCheck, "Multiple Found - Will take yourself to submit.")
		guiLabelSetColor(lNameCheck, 255, 255, 0)
	elseif (count==1) then
		guiSetText(lNameCheck, "Player Found: " .. getPlayerName(found) .. " (ID #" .. getElementData(found, "playerid") .. ")")
		guiLabelSetColor(lNameCheck, 0, 255, 0)
		reportedPlayer = found
	elseif (count==0) then
		guiSetText(lNameCheck, "Player not found - Will take yourself to submit.")
		guiLabelSetColor(lNameCheck, 255, 0, 0)
	end
end

-- Close button
function clickCloseButton(button, state)
	if (source==bClose) and (button=="left") and (state=="up") then
		if (wReportMain~=nil) then
			destroyElement(wReportMain)
		end

		if (wHelp) then
			destroyElement(wHelp)
		end

		wReportMain, bClose, lStatus, lVehTheft, lPropBreak, lPapForgery, lVehTheftStatus, lPropBreakStatus, lPapForgeryStatus, bVehTheft, bPropBreak, bPapForgery, bHelp, lPlayerName, tPlayerName, lNameCheck, lReport, tReport, lLengthCheck, bSubmitReport = nil
		guiSetInputEnabled(false)
		showCursor(false)
	elseif (source==bHelp) and (button=="left") and (state=="up") then
		if (wReportMain~=nil) then
			destroyElement(wReportMain)
		end

		wReportMain, bClose, lStatus, lVehTheft, lPropBreak, lPapForgery, lVehTheftStatus, lPropBreakStatus, lPapForgeryStatus, bVehTheft, bPropBreak, bPapForgery, bHelp, lPlayerName, tPlayerName, lNameCheck, lReport, tReport, lLengthCheck, bSubmitReport = nil
		guiSetInputEnabled(false)
		showCursor(false)

		triggerEvent("viewF1Help", getLocalPlayer())
	end
end

addEvent('report:new-report', true)
addEventHandler('report:new-report', root, function (reportingPlayer, reportedPlayer, reportedReason, reportType)
	local priorityReportType = 1

	if reportType == 1 and getElementData(source, 'incoming_priority_report_sound') == '1' then
		playSound('audio/beep-09.mp3')
	elseif getElementData(source, 'incoming_report_sound') == '1' then
		playSound('audio/beep-07.mp3')
	end
end)
