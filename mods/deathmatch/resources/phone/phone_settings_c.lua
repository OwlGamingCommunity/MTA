--MAXIME
settings = {}
function setPhoneSettings(fromPhone, index, value)
	fromPhone = tonumber(fromPhone)
	if fromPhone and index and value then
		if not settings[fromPhone] then
			settings[fromPhone] = {}
		end
		settings[fromPhone][index] = value
		-- outputDebugString("[Phone] setPhoneSettings / "..fromPhone.." / "..index.." / "..value)
	end
end

function getPhoneSettings(fromPhone, index)
	fromPhone = tonumber(fromPhone)
	if fromPhone and index and settings[fromPhone] and settings[fromPhone][index] then
		outputDebugString("[Phone] getPhoneSettings / "..fromPhone.." / "..index.." / "..settings[fromPhone][index])
		return settings[fromPhone][index]
	end
end

function cleanSettings(fromPhone)
	fromPhone = tonumber(fromPhone) 
	if fromPhone then
		settings[fromPhone] = nil
	end
end

local settingGuis = {}
function drawSettings(xoffset, yoffset)
	if not isPhoneGUICreated() or (settingGuis.main and isElement(settingGuis.main)) then return false end
	if not xoffset then	xoffset = 0 end
	if not yoffset then	yoffset = 0 end
	
	settingGuis.main = guiCreateScrollPane(30+xoffset, 100+yoffset, 221, 370, false, wPhoneMenu)
    settingGuis[1] = guiCreateLabel(10+xoffset, 10+yoffset, 200, 19, "About", false, settingGuis.main)
    guiSetFont(settingGuis[1], "default-bold-small")
    guiLabelSetVerticalAlign(settingGuis[1], "center")

    guiSetAlpha(guiCreateStaticImage(10+xoffset, 28+yoffset, 200, 1, ":admin-system/images/whitedot.jpg", false, settingGuis.main), 0.1)
    local smallLine = 14
    yoffset = yoffset + 3
    settingGuis[2] = guiCreateLabel(20+xoffset, 30+yoffset, 190, smallLine, "", false, settingGuis.main)
    guiSetFont(settingGuis[2], "default-small")

    --yoffset = yoffset + smallLine
    settingGuis[3] = guiCreateLabel(20+xoffset, 30+yoffset, 190, smallLine, "Carrier: Global Metro Media", false, settingGuis.main)
    guiSetFont(settingGuis[3], "default-small")

    yoffset = yoffset + smallLine
    settingGuis[4] = guiCreateLabel(20+xoffset, 30+yoffset, 190, smallLine, "Subscriber: "..(getPhoneSettings(phone, "boughtByName") or "Unknown"):gsub("_", " "), false, settingGuis.main)
    guiSetFont(settingGuis[4], "default-small")

    yoffset = yoffset + smallLine
    settingGuis[29] = guiCreateLabel(20+xoffset, 30+yoffset, 190, smallLine, "Number: "..phone, false, settingGuis.main)
    guiSetFont(settingGuis[29], "default-small")

    yoffset = yoffset + smallLine
    settingGuis[5] = guiCreateLabel(20+xoffset, 30+yoffset, 190, smallLine, "Registered Date: "..(getPhoneSettings(phone, "boughtDate") or "Unknown"), false, settingGuis.main)
    guiSetFont(settingGuis[5], "default-small")
    

    -----------------------------------------------------
    yoffset = yoffset + 40
    settingGuis[20] = guiCreateLabel(10+xoffset, 10+yoffset, 200, 19, "Calls", false, settingGuis.main)
    guiSetFont(settingGuis[20], "default-bold-small")
    guiLabelSetVerticalAlign(settingGuis[20], "center")
    guiSetAlpha(guiCreateStaticImage(10+xoffset, 28+yoffset, 200, 1, ":admin-system/images/whitedot.jpg", false, settingGuis.main), 0.1)
    yoffset = yoffset + 3
    local spacing = 7
    settingGuis[21] = guiCreateLabel(20+xoffset, 30+yoffset, smallLine*spacing, smallLine, "Hide my caller ID:", false, settingGuis.main)
    guiSetFont(settingGuis[21], "default-small")
    settingGuis[22] = guiCreateButton(20+smallLine*spacing+xoffset, 30+yoffset, 190-smallLine*spacing, smallLine, getPhoneSettings(phone, "isSecret") == 1 and "Enabled" or "Disabled", false, settingGuis.main)
    guiSetFont(settingGuis[22], "default-small")
    yoffset = yoffset + smallLine
    settingGuis[23] = guiCreateLabel(20+xoffset, 30+yoffset, smallLine*spacing, smallLine, "Show on phonebook:", false, settingGuis.main)
    guiSetFont(settingGuis[23], "default-small")
    settingGuis[24] = guiCreateButton(20+smallLine*spacing+xoffset, 30+yoffset, 190-smallLine*spacing, smallLine, (getPhoneSettings(phone, "isInPhonebook") == 1 and getPhoneSettings(phone, "isSecret") == 0) and "Enabled" or "Disabled", false, settingGuis.main)
    guiSetFont(settingGuis[24], "default-small")
    if getPhoneSettings(phone, "isSecret") == 1 then
    	guiSetEnabled(settingGuis[24], false)
    else
    	guiSetEnabled(settingGuis[24], true)
    end
	-----------------------------------------------------
    yoffset = yoffset + 40
    settingGuis[6] = guiCreateLabel(10+xoffset, 10+yoffset, 200, 19, "Sounds", false, settingGuis.main)
    guiSetFont(settingGuis[6], "default-bold-small")
    guiLabelSetVerticalAlign(settingGuis[6], "center")

	guiSetAlpha(guiCreateStaticImage(10+xoffset, 28+yoffset, 200, 1, ":admin-system/images/whitedot.jpg", false, settingGuis.main), 0.1)
    yoffset = yoffset + 3

    settingGuis[10] = guiCreateLabel(20+xoffset, 30+yoffset, 190, smallLine, "Ringtones:", false, settingGuis.main)
    guiSetFont(settingGuis[10], "default-small")
    yoffset = yoffset + smallLine
    settingGuis[7] = guiCreateButton(20+xoffset, 30+yoffset, smallLine, smallLine, "<", false, settingGuis.main)
    guiSetFont(settingGuis[7], "default-small")
    settingGuis[8] = guiCreateButton(20+200-smallLine*2+xoffset, 30+yoffset, smallLine, smallLine, ">", false, settingGuis.main)
    guiSetFont(settingGuis[8], "default-small")
    local currentRingId = getPhoneSettings(phone, "ringtone")
    local ringText = ringtones[currentRingId]
	ringText = "("..currentRingId.."/"..#ringtones..") "..string.sub(ringText, 18,string.len(ringText))
    settingGuis[9] = guiCreateLabel(20+smallLine+xoffset, 30+yoffset, 200-(smallLine*3), smallLine, ringText, false, settingGuis.main)
    guiSetFont(settingGuis[9], "default-small")
    guiLabelSetHorizontalAlign(settingGuis[9], "center")
	
    yoffset = yoffset + smallLine
    settingGuis[11] = guiCreateLabel(20+xoffset, 30+yoffset, 190, smallLine, "SMS tones:", false, settingGuis.main)
    guiSetFont(settingGuis[11], "default-small")
    yoffset = yoffset + smallLine
    settingGuis[12] = guiCreateButton(20+xoffset, 30+yoffset, smallLine, smallLine, "<", false, settingGuis.main)
    guiSetFont(settingGuis[12], "default-small")
    settingGuis[13] = guiCreateButton(20+200-smallLine*2+xoffset, 30+yoffset, smallLine, smallLine, ">", false, settingGuis.main)
    guiSetFont(settingGuis[13], "default-small")
    currentRingId = getPhoneSettings(phone, "sms_tone")
    ringText = ringtones[currentRingId]
	ringText = "("..currentRingId.."/"..#ringtones..") "..string.sub(ringText, 18,string.len(ringText))
    settingGuis[14] = guiCreateLabel(20+smallLine+xoffset, 30+yoffset, 200-(smallLine*3), smallLine, ringText, false, settingGuis.main)
    guiSetFont(settingGuis[14], "default-small")
    guiLabelSetHorizontalAlign(settingGuis[14], "center")

    yoffset = yoffset + smallLine
    settingGuis[25] = guiCreateLabel(20+xoffset, 30+yoffset, 190, smallLine, "Volume:", false, settingGuis.main)
    guiSetFont(settingGuis[25], "default-small")
    yoffset = yoffset + smallLine
    settingGuis[26] = guiCreateButton(20+xoffset, 30+yoffset, smallLine, smallLine, "<", false, settingGuis.main)
    guiSetFont(settingGuis[26], "default-small")
    settingGuis[27] = guiCreateButton(20+200-smallLine*2+xoffset, 30+yoffset, smallLine, smallLine, ">", false, settingGuis.main)
    guiSetFont(settingGuis[27], "default-small")
    settingGuis[28] = guiCreateLabel(20+smallLine+xoffset, 30+yoffset, 200-(smallLine*3), smallLine, "10/10", false, settingGuis.main)
    guiSetFont(settingGuis[28], "default-small")
    guiLabelSetHorizontalAlign(settingGuis[28], "center")

    yoffset = yoffset + smallLine+6
    settingGuis[18] = guiCreateLabel(20+xoffset, 30+yoffset, smallLine*spacing, smallLine, "Keypress tone:", false, settingGuis.main)
    guiSetFont(settingGuis[18], "default-small")
    settingGuis[19] = guiCreateButton(20+smallLine*spacing+xoffset, 30+yoffset, 190-smallLine*spacing, smallLine, getPhoneSettings(phone, "keypress_tone") == 0 and "Disabled" or "Enabled", false, settingGuis.main)
    guiSetFont(settingGuis[19], "default-small")

    -----------------------------------------------------
    yoffset = yoffset + 40
    settingGuis[30] = guiCreateLabel(10+xoffset, 10+yoffset, 200, 19, "Misc", false, settingGuis.main)
    guiSetFont(settingGuis[30], "default-bold-small")
    guiLabelSetVerticalAlign(settingGuis[30], "center")
    guiSetAlpha(guiCreateStaticImage(10+xoffset, 28+yoffset, 200, 1, ":admin-system/images/whitedot.jpg", false, settingGuis.main), 0.1)
	yoffset = yoffset + 3

	yoffset = yoffset
    settingGuis[33] = guiCreateLabel(20+xoffset, 30+yoffset, 190, smallLine+3, "Phone Background:", false, settingGuis.main)
    guiSetFont(settingGuis[33], "default-small")
    yoffset = yoffset + smallLine
	settingGuis[34] = guiCreateButton(20+xoffset, 30+yoffset, smallLine, smallLine, "<", false, settingGuis.main)
	guiSetFont(settingGuis[34], "default-small")
	guiSetEnabled(settingGuis[34], false)
    settingGuis[35] = guiCreateButton(20+200-smallLine*2+xoffset, 30+yoffset, smallLine, smallLine, ">", false, settingGuis.main)
	guiSetFont(settingGuis[35], "default-small")
	guiSetEnabled(settingGuis[35], false)
    currentBackground = "Mountains"
	ringText = "("..currentBackground..") "..string.sub(ringText, 18,string.len(ringText))
    settingGuis[36] = guiCreateLabel(20+smallLine+xoffset, 30+yoffset, 200-(smallLine*3), smallLine, ringText, false, settingGuis.main)
	guiSetFont(settingGuis[36], "default-small")
	guiSetEnabled(settingGuis[36], false)
    guiLabelSetHorizontalAlign(settingGuis[36], "center")
	
    yoffset = yoffset + smallLine+12
    settingGuis[31] = guiCreateLabel(20+xoffset, 30+yoffset, smallLine*spacing, smallLine, "Calls & SMS logging:", false, settingGuis.main)
    guiSetFont(settingGuis[31], "default-small")
    settingGuis[32] = guiCreateButton(20+smallLine*spacing+xoffset, 30+yoffset, 190-smallLine*spacing, smallLine, getElementData(localPlayer, "cellphone_log") == "0" and "Disabled" or "Enabled", false, settingGuis.main)
    guiSetFont(settingGuis[32], "default-small")

	addEventHandler("onClientGUIClick", settingGuis.main, guiSettingClick)
	return true
end

local settingSounds = {}
function guiSettingClick()
	local ps = playSound
	local playSound = function(tone, loop)
		if tone ~= "sounds/ringtones/quiet" then
			local sound = ps(tone, loop)
			setSoundVolume ( sound, 0.4*getPhoneSettings(phone, "tone_volume")/10)
			table.insert(settingSounds, sound)
			return sound
		end
	end
	killSettingSounds()
	if source == settingGuis[22] then --hide caller id
		if guiGetText(settingGuis[22]) == "Disabled" then
			--local perk = exports.donators:getPerks(33)
			--showConfirmBox("Cellphone Private Number", perk[2])
			triggerServerEvent("phone:activatePrivateNumber", localPlayer, phone, 0)
    		--cleanSettings(phone)
    		--triggerSlidingPhoneOut()
			setPhoneSettings(phone, "isSecret", 1)
			guiSetText(settingGuis[22], "Enabled")

			guiSetEnabled(settingGuis[24], false)
			guiSetText(settingGuis[24], "Disabled")
		else
			setPhoneSettings(phone, "isSecret", 0)
			guiSetText(settingGuis[22], "Disabled")

			guiSetText(settingGuis[24], getPhoneSettings(phone, "isInPhonebook") == 1 and "Enabled" or "Disabled")
			guiSetEnabled(settingGuis[24], true)

			triggerServerEvent("phone:updatePhoneSetting", localPlayer, phone, "secretnumber", 0)
		end
	elseif source == settingGuis[24] then --show on phonebook
		if guiGetText(settingGuis[24]) == "Disabled" then
			setPhoneSettings(phone, "isInPhonebook", 1)
			guiSetText(settingGuis[24], "Enabled")
			triggerServerEvent("phone:updatePhoneSetting", localPlayer, phone, "phonebook", 1)
		else
			setPhoneSettings(phone, "isInPhonebook", 0)
			guiSetText(settingGuis[24], "Disabled")
			triggerServerEvent("phone:updatePhoneSetting", localPlayer, phone, "phonebook", 0)
		end
	elseif source == settingGuis[7] then --previous ringtone
		local oldTone = getPhoneSettings(phone, "ringtone")
		local index, name = scrollRingtones("ringtone", false)
		if index and name then
			playSound("sounds/ringtones/"..name, true)
			setPhoneSettings(phone, "ringtone", index)
			guiSetText(settingGuis[9], "("..index.."/"..#ringtones..") "..name)
			if oldTone ~= index then
				triggerServerEvent("phone:updatePhoneSetting", localPlayer, phone, "ringtone", index)
			end
		end
	elseif source == settingGuis[8] then --next ringtone
		local oldTone = getPhoneSettings(phone, "ringtone")
		local index, name = scrollRingtones("ringtone", true)
		if index and name then
			playSound("sounds/ringtones/"..name, true)
			setPhoneSettings(phone, "ringtone", index)
			guiSetText(settingGuis[9], "("..index.."/"..#ringtones..") "..name)
			if oldTone ~= index then
				triggerServerEvent("phone:updatePhoneSetting", localPlayer, phone, "ringtone", index)
			end
		end
	elseif source == settingGuis[12] then --previous sms_tone
		local oldTone = getPhoneSettings(phone, "sms_tone")
		local index, name = scrollRingtones("sms_tone", false)
		if index and name then
			playSound("sounds/ringtones/"..name)
			setPhoneSettings(phone, "sms_tone", index)
			guiSetText(settingGuis[14], "("..index.."/"..#ringtones..") "..name)
			if oldTone ~= index then
				triggerServerEvent("phone:updatePhoneSetting", localPlayer, phone, "sms_tone", index)
			end
		end
	elseif source == settingGuis[13] then --next sms_tone
		local oldTone = getPhoneSettings(phone, "sms_tone")
		local index, name = scrollRingtones("sms_tone", true)
		if index and name then
			playSound("sounds/ringtones/"..name)
			setPhoneSettings(phone, "sms_tone", index)
			guiSetText(settingGuis[14], "("..index.."/"..#ringtones..") "..name)
			if oldTone ~= index then
				triggerServerEvent("phone:updatePhoneSetting", localPlayer, phone, "sms_tone", index)
			end
		end
	elseif source == settingGuis[26] then --previous tone_volume
		local oldVol = getPhoneSettings(phone, "tone_volume")
		local newVol = scrollRingtones("tone_volume", false)
		if newVol then
			setPhoneSettings(phone, "tone_volume", newVol)
			playSound("sounds/beeps/8.mp3")
			guiSetText(settingGuis[28], newVol.."/"..10)
			if oldVol ~= newVol then
				triggerServerEvent("phone:updatePhoneSetting", localPlayer, phone, "tone_volume", newVol)
			end
		end
	elseif source == settingGuis[27] then --next tone_volume
		local oldVol = getPhoneSettings(phone, "tone_volume")
		local newVol = scrollRingtones("tone_volume", true)
		if newVol then
			setPhoneSettings(phone, "tone_volume", newVol)
			playSound("sounds/beeps/8.mp3")
			guiSetText(settingGuis[28], newVol.."/"..10)
			if oldVol ~= newVol then
				triggerServerEvent("phone:updatePhoneSetting", localPlayer, phone, "tone_volume", newVol)
			end
		end
	elseif source == settingGuis[32] then
		if guiGetText(settingGuis[32]) == "Enabled" then
			triggerEvent("accounts:settings:updateAccountSettings", localPlayer, "cellphone_log", "0")
			guiSetText(settingGuis[32], "Disabled")
		else
			triggerEvent("accounts:settings:updateAccountSettings", localPlayer, "cellphone_log", "1")
			guiSetText(settingGuis[32], "Enabled")
			exports.OwlGamingLogs:drawInfoBox()
		end
	elseif source == settingGuis[19] then
		if guiGetText(settingGuis[19]) == "Enabled" then
			setPhoneSettings(phone, "keypress_tone", 0)
			guiSetText(settingGuis[19], "Disabled")
			triggerServerEvent("phone:updatePhoneSetting", localPlayer, phone, "keypress_tone", 0)
		else
			setPhoneSettings(phone, "keypress_tone", 1)
			guiSetText(settingGuis[19], "Enabled")
			triggerServerEvent("phone:updatePhoneSetting", localPlayer, phone, "keypress_tone", 1)
		end
	end 
end
function killSettingSounds()
	for i, sound in pairs(settingSounds) do
		if sound then
			if isElement(sound) then
				destroyElement(sound)
				timer = nil
			end
		end
	end
end

function scrollRingtones(type, next)
	local current = getPhoneSettings(phone, type)
	if next then
		current = current + 1
	else
		current = current - 1
	end

	if type == "tone_volume" then
		if current >=1 and current <= 10 then
			return current
		end
	else
		local ringText = ringtones[current]
		if ringText then
			return current, string.sub(ringText, 18,string.len(ringText))
		end
	end
end

local GUIEditor = {
	button = {},
	window = {},
	label = {}
}
function showConfirmBox(perkName, perkCost)
    GUIEditor.window[1] = guiCreateWindow(621, 364, 455, 104, "Premium Features", false)
    guiWindowSetSizable(GUIEditor.window[1], false)
    exports.global:centerWindow(GUIEditor.window[1])
    GUIEditor.label[1] = guiCreateLabel(11, 28, 429, 36, "You're about to activate \""..perkName.."\" perk which costs "..perkCost.." GC(s).\nAre you sure you want to continue?", false, GUIEditor.window[1])
    guiLabelSetHorizontalAlign(GUIEditor.label[1], "center", false)
    GUIEditor.button[1] = guiCreateButton(11, 64, 217, 30, "Yes, please!", false, GUIEditor.window[1])
    GUIEditor.button[2] = guiCreateButton(228, 64, 217, 30, "No, thanks.", false, GUIEditor.window[1])  
    addEventHandler("onClientGUIClick", GUIEditor.window[1], function()
    	if source == GUIEditor.button[1] then
    		triggerServerEvent("phone:activatePrivateNumber", localPlayer, phone, perkCost)
    		cleanSettings(phone)
    		triggerSlidingPhoneOut()
    		closeConfirmBox()
    	elseif source == GUIEditor.button[2] then
    		closeConfirmBox()
    	end
    end)
end

function closeConfirmBox()
	if GUIEditor.window[1] and isElement(GUIEditor.window[1]) then
		destroyElement(GUIEditor.window[1])
		GUIEditor.window[1] = nil
	end
end

function toggleSettingsGUI(state)
	killSettingSounds()
	if settingGuis.main and isElement(settingGuis.main) then
		return guiSetVisible(settingGuis.main , state)
	else
		if state then
			return drawSettings()
		end
	end
end

function updatePhoneSettings(updates, customPhone)
	triggerServerEvent("phone:updatePhoneSettings", localPlayer, customPhone or phone, updates)
end


