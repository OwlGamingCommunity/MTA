local onHandlePINChange_data = nil

local GUIEditor_Button = {}
local GUIEditor_Label = {}
local GUIEditor_Image = {}
--local ledFont = guiCreateFont( "fonts/led_board-7.ttf", 15 )
local ledFont = guiCreateFont( "fonts/digi.ttf", 18 )
--local ledFont = guiCreateFont( "fonts/failed_attempt.ttf", 15 )
--local ledFont = guiCreateFont( "fonts/led_sas.ttf", 15 ) or "default-bold-small"
local numFont = guiCreateFont( ":resources/nametags0.ttf", 20 ) or "default-bold-small"
local currentPad = nil
local currentInt = nil
local passcode = "____"
local errorCode = "not installed"
local isOwner = nil
function openKeypadInterface(thePad)
	passcode = "____"
	isIntLocked = true
	if getElementData(localPlayer, "exclusiveGUI") then
		--
		return false
	end

	errorCode = "not installed"
	isOwner = nil
	setElementData(localPlayer, "pressedAutoLock", nil, false)

	local screenText = "Enter passcode:\n"..passcode
	if not thePad or not isElement(thePad) or not isElement(thePad) then
		screenText = "Fatal Error!"
		exports.hud:sendBottomNotification(localPlayer, "Keyless Digital Door Lock - Fatal Error!", "System was not installed properly, please reinstall the device.")
	else
		currentPad = thePad
		currentInt = getInteriorFromId(getElementData(thePad, "itemValue"))
		if not currentInt then
			errorCode = "out of order"
			playSoundBtn("warning", thePad)
			screenText = "out of order ((#1))"
		else
			setElementData(localPlayer, "exclusiveGUI", true, false)
			local stt = getElementData( currentInt, 'status' )
			if getElementData( currentInt, "keypad_lock" ) and ( stt.type == 0 or stt.type == 1 or stt.type == 3 ) then
				errorCode = "installed but not logged in"
			else
				errorCode = "out of order"
				screenText = "out of order ((#2))"
				playSoundBtn("warning", thePad)
			end
			isIntLocked = stt.locked
			isOwner = stt.owner == getElementData(localPlayer, "dbid")
		end
	end
	--[[
	errorCode = "out of order"
	screenText = "out of order"
	playSoundBtn("warning", thePad)
	]]
	if errorCode == "installed but not logged in" then
		playSoundBtn("enter_password", thePad)
	end

	local savedPw = false
	if errorCode ~= "not installed" and errorCode ~= "out of order" and (not currentInt or not getElementData(currentInt, "keypad_lock_pw")) then
		errorCode = "new passcode"
		passcode = "____"
		screenText = "Enter new passcode:\n"..passcode
	else
		savedPw = currentInt and getElementData(currentInt, "keypad_lock_pw") or false
	end

	closeKeypadInterface()
	showCursor(true)
	exports["item-system"]:playSoundInvOpen()

	local r, g, b = 233, 233, 233
	GUIEditor_Image[1] = guiCreateStaticImage(619,163,280,400,"images/keypad.png",false)
	exports.global:centerWindow(GUIEditor_Image[1])

	GUIEditor_Image["lockState"] = guiCreateStaticImage(41,46,25,29,"images/keypad_"..(isIntLocked and "locked" or "unlocked")..".png",false,GUIEditor_Image[1])

	GUIEditor_Label[1] = guiCreateLabel(41,46,197,97,screenText,false,GUIEditor_Image[1])
	guiLabelSetVerticalAlign(GUIEditor_Label[1],"center")
	guiLabelSetHorizontalAlign(GUIEditor_Label[1],"center",true)
	guiSetFont(GUIEditor_Label[1],ledFont)
	GUIEditor_Label[2] = guiCreateLabel(109,204,44,36,"1",false,GUIEditor_Image[1])
	guiSetFont(GUIEditor_Label[2],numFont)
	guiLabelSetColor(GUIEditor_Label[2], r, g, b )
	GUIEditor_Label[3] = guiCreateLabel(159,204,44,36,"2",false,GUIEditor_Image[1])
	guiSetFont(GUIEditor_Label[3],numFont)
	guiLabelSetColor(GUIEditor_Label[3], r, g, b )
	GUIEditor_Label[4] = guiCreateLabel(208,205,44,36,"3",false,GUIEditor_Image[1])
	guiSetFont(GUIEditor_Label[4],numFont)
	guiLabelSetColor(GUIEditor_Label[4], r, g, b )
	GUIEditor_Label[5] = guiCreateLabel(109,245,44,36,"4",false,GUIEditor_Image[1])
	guiSetFont(GUIEditor_Label[5],numFont)
	guiLabelSetColor(GUIEditor_Label[5], r, g, b )
	GUIEditor_Label[6] = guiCreateLabel(159,245,44,36,"5",false,GUIEditor_Image[1])
	guiSetFont(GUIEditor_Label[6],numFont)
	guiLabelSetColor(GUIEditor_Label[6], r, g, b )
	GUIEditor_Label[7] = guiCreateLabel(208,245,44,36,"6",false,GUIEditor_Image[1])
	guiSetFont(GUIEditor_Label[7],numFont)
	guiLabelSetColor(GUIEditor_Label[7], r, g, b )
	GUIEditor_Label[8] = guiCreateLabel(109,286,44,36,"7",false,GUIEditor_Image[1])
	guiSetFont(GUIEditor_Label[8],numFont)
	guiLabelSetColor(GUIEditor_Label[8], r, g, b )
	GUIEditor_Label[9] = guiCreateLabel(159,286,44,36,"8",false,GUIEditor_Image[1])
	guiSetFont(GUIEditor_Label[9],numFont)
	guiLabelSetColor(GUIEditor_Label[9], r, g, b )
	GUIEditor_Label[10] = guiCreateLabel(208,286,44,36,"9",false,GUIEditor_Image[1])
	guiSetFont(GUIEditor_Label[10],numFont)
	guiLabelSetColor(GUIEditor_Label[10], r, g, b )
	GUIEditor_Label[11] = guiCreateLabel(158,327,44,36,"0",false,GUIEditor_Image[1])
	guiSetFont(GUIEditor_Label[11],numFont)
	guiLabelSetColor(GUIEditor_Label[11], r, g, b )
	GUIEditor_Label[12] = guiCreateLabel(109,326,44,36,"*",false,GUIEditor_Image[1])
	guiSetFont(GUIEditor_Label[12],numFont)
	guiLabelSetColor(GUIEditor_Label[12], r, g, b )
	GUIEditor_Label[13] = guiCreateLabel(207,326,44,36,"#",false,GUIEditor_Image[1])
	guiSetFont(GUIEditor_Label[13],numFont)
	guiLabelSetColor(GUIEditor_Label[13], r, g, b )
	GUIEditor_Label[14] = guiCreateLabel(38,163,71,25,"Login",false,GUIEditor_Image[1])
	guiLabelSetVerticalAlign(GUIEditor_Label[14],"center")
	guiLabelSetColor(GUIEditor_Label[14], r, g, b )
	guiLabelSetHorizontalAlign(GUIEditor_Label[14],"right",false)
	guiSetFont(GUIEditor_Label[14],"default-bold-small")
	GUIEditor_Label[15] = guiCreateLabel(149,164,59,24,"Auto-Lock",false,GUIEditor_Image[1])
	guiLabelSetVerticalAlign(GUIEditor_Label[15],"center")
	guiLabelSetColor(GUIEditor_Label[15], r, g, b )
	guiLabelSetHorizontalAlign(GUIEditor_Label[15],"right",false)
	guiSetFont(GUIEditor_Label[15],"default-bold-small")
	GUIEditor_Label[16] = guiCreateLabel(62,336,43,27,"Exit",false,GUIEditor_Image[1])
	guiLabelSetVerticalAlign(GUIEditor_Label[16],"center")
	guiLabelSetColor(GUIEditor_Label[16], r, g, b )
	GUIEditor_Label[17] = guiCreateLabel(62,292,43,27,"Uninstall",false,GUIEditor_Image[1])
	guiLabelSetVerticalAlign(GUIEditor_Label[17],"center")
	guiLabelSetColor(GUIEditor_Label[17], r, g, b )
	GUIEditor_Label[18] = guiCreateLabel(62,250,43,27,"Police",false,GUIEditor_Image[1])
	guiLabelSetVerticalAlign(GUIEditor_Label[18],"center")
	guiLabelSetColor(GUIEditor_Label[18], r, g, b )
	GUIEditor_Label[19] = guiCreateLabel(62,205,43,27,isIntLocked and "Unlock" or "Lock",false,GUIEditor_Image[1])
	guiLabelSetVerticalAlign(GUIEditor_Label[19],"center")
	guiLabelSetColor(GUIEditor_Label[19], r, g, b )

	GUIEditor_Button[1] = guiCreateButton(215,163,32,29,"Auto-Lock",false,GUIEditor_Image[1])
	GUIEditor_Button[2] = guiCreateButton(117,163,32,29,"Login",false,GUIEditor_Image[1])
	GUIEditor_Button[3] = guiCreateButton(25,205,32,29,isIntLocked and "Unlock" or "Lock",false,GUIEditor_Image[1])
	GUIEditor_Button[4] = guiCreateButton(25,250,32,29,"Police",false,GUIEditor_Image[1])
	GUIEditor_Button[5] = guiCreateButton(25,293,32,29,"Uninstall",false,GUIEditor_Image[1])
	GUIEditor_Button[6] = guiCreateButton(25,336,32,29,"Exit",false,GUIEditor_Image[1])
	addEventHandler( "onClientGUIClick", GUIEditor_Button[6],
			function( button )
				if source == GUIEditor_Button[6] then
					closeKeypadInterface()
				end
			end
	)
	local alpha = 0.2
	guiSetAlpha(GUIEditor_Button[1], alpha)
	guiSetAlpha(GUIEditor_Button[2], alpha)
	guiSetAlpha(GUIEditor_Button[3], alpha)
	guiSetAlpha(GUIEditor_Button[4], alpha)
	guiSetAlpha(GUIEditor_Button[5], alpha)
	guiSetAlpha(GUIEditor_Button[6], alpha)

	--Hover effects
	local hR, hG, hB = 88, 127, 138
	addEventHandler( "onClientMouseEnter",GUIEditor_Image[1],function()
		if source == GUIEditor_Label[2] then
			guiLabelSetColor(GUIEditor_Label[2], hR, hG, hB )
		elseif source == GUIEditor_Label[3] then
			guiLabelSetColor(GUIEditor_Label[3], hR, hG, hB )
		elseif source == GUIEditor_Label[4] then
			guiLabelSetColor(GUIEditor_Label[4], hR, hG, hB )
		elseif source == GUIEditor_Label[5] then
			guiLabelSetColor(GUIEditor_Label[5], hR, hG, hB )
		elseif source == GUIEditor_Label[6] then
			guiLabelSetColor(GUIEditor_Label[6], hR, hG, hB )
		elseif source == GUIEditor_Label[7] then
			guiLabelSetColor(GUIEditor_Label[7], hR, hG, hB )
		elseif source == GUIEditor_Label[8] then
			guiLabelSetColor(GUIEditor_Label[8], hR, hG, hB )
		elseif source == GUIEditor_Label[9] then
			guiLabelSetColor(GUIEditor_Label[9], hR, hG, hB )
		elseif source == GUIEditor_Label[10] then
			guiLabelSetColor(GUIEditor_Label[10], hR, hG, hB )
		elseif source == GUIEditor_Label[11] then
			guiLabelSetColor(GUIEditor_Label[11], hR, hG, hB )
		elseif source == GUIEditor_Label[12] then
			guiLabelSetColor(GUIEditor_Label[12], hR, hG, hB )
		elseif source == GUIEditor_Label[13] then
			guiLabelSetColor(GUIEditor_Label[13], hR, hG, hB )
		end
	end)
	addEventHandler( "onClientMouseLeave",GUIEditor_Image[1],function()
		if source == GUIEditor_Label[2] then
			guiLabelSetColor(GUIEditor_Label[2], r, g, b )
		elseif source == GUIEditor_Label[3] then
			guiLabelSetColor(GUIEditor_Label[3], r, g, b )
		elseif source == GUIEditor_Label[4] then
			guiLabelSetColor(GUIEditor_Label[4], r, g, b )
		elseif source == GUIEditor_Label[5] then
			guiLabelSetColor(GUIEditor_Label[5], r, g, b )
		elseif source == GUIEditor_Label[6] then
			guiLabelSetColor(GUIEditor_Label[6], r, g, b )
		elseif source == GUIEditor_Label[7] then
			guiLabelSetColor(GUIEditor_Label[7], r, g, b )
		elseif source == GUIEditor_Label[8] then
			guiLabelSetColor(GUIEditor_Label[8], r, g, b )
		elseif source == GUIEditor_Label[9] then
			guiLabelSetColor(GUIEditor_Label[9], r, g, b )
		elseif source == GUIEditor_Label[10] then
			guiLabelSetColor(GUIEditor_Label[10], r, g, b )
		elseif source == GUIEditor_Label[11] then
			guiLabelSetColor(GUIEditor_Label[11], r, g, b )
		elseif source == GUIEditor_Label[12] then
			guiLabelSetColor(GUIEditor_Label[12], r, g, b )
		elseif source == GUIEditor_Label[13] then
			guiLabelSetColor(GUIEditor_Label[13], r, g, b )
		end
	end)

	--Clicks
	addEventHandler( "onClientGUIClick",GUIEditor_Image[1],function()
		--keys from 1~9, 0 , * and #
		if source == GUIEditor_Label[2] then
			if errorCode == "installed but not logged in" then
				playSoundBtn()
				passcode = passcode.."1"
				passcode = string.sub(passcode, string.len(passcode)-3,string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Enter Passcode:\n"..passcode)
			elseif errorCode == "new passcode" then
				playSoundBtn()
				passcode = passcode.."1"
				passcode = string.sub(passcode, string.len(passcode)-3,string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Enter new passcode:\n"..passcode)
			end
		elseif source == GUIEditor_Label[3] then
			if errorCode == "installed but not logged in" then
				playSoundBtn()
				passcode = passcode.."2"
				passcode = string.sub(passcode, string.len(passcode)-3,string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Enter Passcode:\n"..passcode)
			elseif errorCode == "new passcode" then
				playSoundBtn()
				passcode = passcode.."2"
				passcode = string.sub(passcode, string.len(passcode)-3,string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Enter new passcode:\n"..passcode)
			end
		elseif source == GUIEditor_Label[4] then
			if errorCode == "installed but not logged in" then
				playSoundBtn()
				passcode = passcode.."3"
				passcode = string.sub(passcode, string.len(passcode)-3,string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Enter Passcode:\n"..passcode)
			elseif errorCode == "new passcode" then
				playSoundBtn()
				passcode = passcode.."3"
				passcode = string.sub(passcode, string.len(passcode)-3,string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Enter new passcode:\n"..passcode)
			end
		elseif source == GUIEditor_Label[5] then
			if errorCode == "installed but not logged in" then
				playSoundBtn()
				passcode = passcode.."4"
				passcode = string.sub(passcode, string.len(passcode)-3,string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Enter Passcode:\n"..passcode)
			elseif errorCode == "new passcode" then
				playSoundBtn()
				passcode = passcode.."4"
				passcode = string.sub(passcode, string.len(passcode)-3,string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Enter new passcode:\n"..passcode)
			end
		elseif source == GUIEditor_Label[6] then
			if errorCode == "installed but not logged in" then
				playSoundBtn()
				passcode = passcode.."5"
				passcode = string.sub(passcode, string.len(passcode)-3,string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Enter Passcode:\n"..passcode)
			elseif errorCode == "new passcode" then
				playSoundBtn()
				passcode = passcode.."5"
				passcode = string.sub(passcode, string.len(passcode)-3,string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Enter new passcode:\n"..passcode)
			end
		elseif source == GUIEditor_Label[7] then
			if errorCode == "installed but not logged in" then
				playSoundBtn()
				passcode = passcode.."6"
				passcode = string.sub(passcode, string.len(passcode)-3,string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Enter Passcode:\n"..passcode)
			elseif errorCode == "new passcode" then
				playSoundBtn()
				passcode = passcode.."6"
				passcode = string.sub(passcode, string.len(passcode)-3,string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Enter new passcode:\n"..passcode)
			end
		elseif source == GUIEditor_Label[8] then
			if errorCode == "installed but not logged in" then
				playSoundBtn()
				passcode = passcode.."7"
				passcode = string.sub(passcode, string.len(passcode)-3,string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Enter Passcode:\n"..passcode)
			elseif errorCode == "new passcode" then
				playSoundBtn()
				passcode = passcode.."7"
				passcode = string.sub(passcode, string.len(passcode)-3,string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Enter new passcode:\n"..passcode)
			end
		elseif source == GUIEditor_Label[9] then
			if errorCode == "installed but not logged in" then
				playSoundBtn()
				passcode = passcode.."8"
				passcode = string.sub(passcode, string.len(passcode)-3,string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Enter Passcode:\n"..passcode)
			elseif errorCode == "new passcode" then
				playSoundBtn()
				passcode = passcode.."8"
				passcode = string.sub(passcode, string.len(passcode)-3,string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Enter new passcode:\n"..passcode)
			end
		elseif source == GUIEditor_Label[10] then
			if errorCode == "installed but not logged in" then
				playSoundBtn()
				passcode = passcode.."9"
				passcode = string.sub(passcode, string.len(passcode)-3,string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Enter Passcode:\n"..passcode)
			elseif errorCode == "new passcode" then
				playSoundBtn()
				passcode = passcode.."9"
				passcode = string.sub(passcode, string.len(passcode)-3,string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Enter new passcode:\n"..passcode)
			end
		elseif source == GUIEditor_Label[12] then
		elseif source == GUIEditor_Label[11] then
			if errorCode == "installed but not logged in" then
				playSoundBtn()
				passcode = passcode.."0"
				passcode = string.sub(passcode, string.len(passcode)-3,string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Enter Passcode:\n"..passcode)
			elseif errorCode == "new passcode" then
				playSoundBtn()
				passcode = passcode.."0"
				passcode = string.sub(passcode, string.len(passcode)-3,string.len(passcode))
				guiSetText(GUIEditor_Label[1], "Enter new passcode:\n"..passcode)
			end
		elseif source == GUIEditor_Button[3] then -- Lock / unlock
			outputDebugString(errorCode)
			if errorCode == "logged in" then
				togKeypad(false)
				playSoundBtn("processing", thePad)
				guiSetText(GUIEditor_Label[1], "Processing...")
				setTimer(function()
					local intID = getElementData(thePad, "itemValue")
					triggerServerEvent("lockUnlockHouseID", localPlayer, intID, true)
					autoLockThisInterior(intID, currentPad)
				end, 1000, 1)
			else
				
			end
			playSoundBtn()
		elseif source == GUIEditor_Button[1] then -- auto lock
			outputDebugString(errorCode)
			if errorCode == "logged in" and isOwner then
				if #findPadElementFromIntID(getElementData(currentInt, "dbid")) > 1 then
					if not getElementData(localPlayer, "pressedAutoLock") then
						guiSetText(GUIEditor_Label[1], "Auto-Lock - "..(getElementData(currentInt, "keypad_lock_auto") and "ON" or "OFF").."\nPress again to toggle")
						setElementData(localPlayer, "pressedAutoLock", true, false)
					else
						setElementData(localPlayer, "pressedAutoLock", nil, false)
						togKeypad(false)
						playSoundBtn("processing", thePad)
						guiSetText(GUIEditor_Label[1], "processing...")
						setTimer(function()
							triggerServerEvent("togKeypadAutoLock", localPlayer, currentInt)
						end, 1000, 1)
					end
				else
					setElementData(localPlayer, "pressedAutoLock", nil, false)
					playSoundBtn("aborted", thePad)
					guiSetText(GUIEditor_Label[1], "Aborted!\nTwo keypads required\nfor autolocking.")
					setElementData(localPlayer, "pressedAutoLock", true, false)
				end
			else
				
			end
			playSoundBtn()
		elseif source == GUIEditor_Button[2] then --enter
			outputDebugString(errorCode)
			if errorCode == "installed but not logged in" then
				if isPasscodeMatched(currentInt, passcode) then
					playSoundBtn("granted", thePad)
					guiSetText(GUIEditor_Label[1], "Access granted!")
					errorCode = "logged in"

					if onHandlePINChange_data then
						onHandlePINChange_data.buttons.enter = GUIEditor_Button[3]
					end
				else
					togKeypad(false)
					playSoundBtn("denied", thePad)
					passcode = "____"
					guiSetText(GUIEditor_Label[1], "Access denied!")
					setTimer(function()
						guiSetText(GUIEditor_Label[1], "Enter Passcode:\n"..passcode)
						--playSoundBtn("enter_password", thePad)
						togKeypad(true)
					end, 1500,1)
				end
			elseif errorCode == "new passcode" then
				if string.len(passcode) == 4 and tonumber(passcode) then
					if not currentInt or not isElement(currentInt) then
						playSoundBtn("warning", thePad)
						passcode = "____"
						guiSetText(GUIEditor_Label[1], "WARNING!")
						exports.hud:sendBottomNotification(localPlayer, "Keyless Digital Door Lock - Fatal Error!", "System was not installed properly, please reinstall the device.")
					else
						local encryptPW = encryptPW(passcode)
						togKeypad(false)
						playSoundBtn("processing", thePad)
						guiSetText(GUIEditor_Label[1], "Processing...")
						setTimer(function()
							if setElementData(currentInt, "keypad_lock_pw", encryptPW, true) then
								triggerServerEvent("registerNewPasscode", localPlayer, currentInt, encryptPW)
							else
								togKeypad(true)
								playSoundBtn("warning", thePad)
								passcode = "____"
								guiSetText(GUIEditor_Label[1], "WARNING!")
								exports.hud:sendBottomNotification(localPlayer, "Keyless Digital Door Lock - Fatal Error!", "System was not installed properly, please reinstall the device.")
							end
						end, 1000, 1)
					end
				else
					playSoundBtn("enter_password", thePad)
					passcode = "____"
					guiSetText(GUIEditor_Label[1], "Enter new Passcode:\n"..passcode)
					togKeypad(false)
					setTimer(function()
						togKeypad(true)
					end, 1500, 1)
				end
			else
				playSoundBtn()
			end
		elseif source == GUIEditor_Button[5] then --uninstall
			playSoundBtn()
			if isOwner then
				togKeypad(false)
				playSoundBtn("processing", thePad)
				guiSetText(GUIEditor_Label[1], "Processing...")
				
				setTimer(function()
					playSoundBtn("deactivating", thePad)
					guiSetText(GUIEditor_Label[1], "deactivating...")
				end, 5000, 1)
				setTimer(function()
					togKeypad(true)
					triggerServerEvent("uninstallKeypad", localPlayer, thePad, currentInt)
				end, 5000*2, 1)
			end
		end
	end)

	addEventHandler("onClientKey", root, onHandlePINChange)
	onHandlePINChange_data = { buttons = { GUIEditor_Label[2], GUIEditor_Label[3], GUIEditor_Label[4], GUIEditor_Label[5], GUIEditor_Label[6], GUIEditor_Label[7], GUIEditor_Label[8], GUIEditor_Label[9], GUIEditor_Label[10], [0] = GUIEditor_Label[11], enter = GUIEditor_Button[2] } }
end
addEvent("openKeypadInterface", true)
addEventHandler("openKeypadInterface", localPlayer, openKeypadInterface)

function closeKeypadInterface()
	if GUIEditor_Image[1] and isElement(GUIEditor_Image[1]) then
		destroyElement(GUIEditor_Image[1])
		showCursor(false)
		exports["item-system"]:playSoundInvClose()
		setElementData(localPlayer, "exclusiveGUI", false, false)
		if currentPad and isElement(currentPad) then
			triggerServerEvent("keypadFreeUsingSlots", localPlayer, currentPad)
		end
		currentInt = nil
		currentPad = nil
		isOwner = nil

		if onHandlePINChange_data then
			removeEventHandler("onClientKey", root, onHandlePINChange)
			onHandlePINChange_data = nil
		end
	end
end
addEvent("closeKeypadInterface", true)
addEventHandler("closeKeypadInterface", localPlayer, closeKeypadInterface)

function autoLockThisInterior(intID, thePad)
	local foundInt = nil
	local tmpPad = thePad
	for i, theInterior in pairs(getElementsByType("interior")) do
		if getElementData(theInterior, "dbid") == intID then
			foundInt = theInterior
			break
		end
	end
	if foundInt then
		setTimer(function()
			if getElementData(foundInt, "keypad_lock_auto") and not getElementData(foundInt, "status")[3] then
				triggerServerEvent("lockUnlockHouseID", localPlayer, intID, true)
			end
		end, 5000, 1)
	end
end


function togKeypad(state)
	if GUIEditor_Image[1] and isElement(GUIEditor_Image[1]) then
		guiSetEnabled(GUIEditor_Image[1], state and true or false)
	end
end

function playSoundBtn(code, thePad)
	if not code then
		playSoundFrontEnd(5)
	elseif thePad then
		local x, y, z = getElementPosition(thePad)
		local int, dim = getElementInterior(thePad), getElementDimension(thePad)
		triggerServerEvent("playSyncedSound", localPlayer, code, {x, y, z, int, dim})
	end
end

function playSyncedSound(code, thePad)
	if code == "doorLockSound" or code == "doorUnlockSound" then
		local sound = playSound3D(":interior_system/"..code..".mp3", thePad[1], thePad[2], thePad[3])
		--setSoundVolume(sound, 0.3)
		setElementInterior(sound, thePad[4])
		setElementDimension(sound, thePad[5])
	else
		local sound = playSound3D("sounds/"..code..".mp3", thePad[1], thePad[2], thePad[3])
		setSoundVolume(sound, 0.3)
		setElementInterior(sound, thePad[4])
		setElementDimension(sound, thePad[5])
	end
end
addEvent("playSyncedSound", true)
addEventHandler("playSyncedSound", root, playSyncedSound)

function keypadRecieveResponseFromServer(code, data)
	if code == "locked" then
		closeKeypadInterface()
	elseif code == "unlocked" then
		closeKeypadInterface()
	elseif code == "registerNewPasscode - ok" then
		togKeypad(false)
		playSoundBtn("all_system_actived", currentPad)
		passcode = "____"
		guiSetText(GUIEditor_Label[1], "Login authorized!")
		errorCode = "logged in"
		setTimer(function()
			playSoundBtn("granted", currentPad)
			guiSetText(GUIEditor_Label[1], "Access granted!")
			togKeypad(true)

			if onHandlePINChange_data then
				onHandlePINChange_data.buttons.enter = GUIEditor_Button[3]
			end
		end, 1500, 1)
	elseif code == "uninstallKeypad - failed" then
		togKeypad(true)
		playSoundBtn("aborted", currentPad)
		passcode = "____"
		guiSetText(GUIEditor_Label[1], "Aborted!\nUnlock First.")
	elseif code == "uninstallKeypad - failed 2" then
		togKeypad(true)
		playSoundBtn("aborted", currentPad)
		passcode = "____"
		guiSetText(GUIEditor_Label[1], "Aborted!\nInventory full.")
	elseif code == "togKeypadAutoLock - on" then
		togKeypad(true)
		guiSetText(GUIEditor_Label[1], "Auto-Lock - ON\nPress again to toggle")
	elseif code == "togKeypadAutoLock - off" then
		togKeypad(true)
		guiSetText(GUIEditor_Label[1], "Auto-Lock - OFF\nPress again to toggle")
	else
		togKeypad(true)
		playSoundBtn("system_overloaded", currentPad)
		guiSetText(GUIEditor_Label[1], "System overloaded!")
	end
end
addEvent("keypadRecieveResponseFromServer", true)
addEventHandler("keypadRecieveResponseFromServer", localPlayer, keypadRecieveResponseFromServer)



function onHandlePINChange(button, pressOrRelease)
	-- we're pressing the button
	if onHandlePINChange_data and pressOrRelease == true then
		if not isElement(GUIEditor_Image[1]) then
			return
		end

		for name, guiElement in pairs(onHandlePINChange_data.buttons) do
			name = tostring(name)
			if isElement(guiElement) then
				if button == name or button == ("num_" .. name) then
					triggerEvent("onClientGUIClick", guiElement, "left", "down")
					cancelEvent() -- prevent default keybinds from triggering
				end
			else
				outputDebugString("Keypad: button for " .. tostring(name) .. " went away")
			end
		end
	end
end
