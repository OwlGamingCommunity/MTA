--MAXIME
wPhoneMenu, phoneBackground, gRingtones, ePhoneNumber, bCall, bOK, bCancel, bSettings, gPhoneBook = nil
wNewContact, fName2, fNumber2, bAddContact, bCancelContact, lName1, lName2, lNumber = nil
wDelete, lQuestion, bButtonDeleteYes, bButtonDeleteNo, saveDeleteName, saveDeleteNumber = nil
contactList = {}
sx, sy = guiGetScreenSize()
phone = nil
stopTimer = {}
w,h = 265,552
margin = 10
xoffset = w + margin
posX, posY = sx-w-margin+xoffset, sy-h-100
curX, curY = posX, posY
slidingSpeed = 20
contactListLimit = {}
font1 = guiCreateFont ( ":resources/cartwheel.otf", 12 )
curEditPhoneNumber = ""

function drawPhoneGUI()
	if isPhoneGUICreated() then
		return true
	end
	
	wPhoneMenu = guiCreateStaticImage(posX, posY,w,h,"images/iphone_front.png",false)
	phoneBackground = guiCreateStaticImage(0.085, 0.15, 0.83, 0.71, "images/backgrounds/Mountains.png", true, wPhoneMenu)
	--guiMoveToBack( phoneBackground ) don't use it, because it is will be set the phone apps doesn't click.
	guiSetEnabled( phoneBackground, false )

	local btnW, btnH = 105, 30
	local btnM = 25
	local btnPosY = 495
	
	bHome = guiCreateButton(btnM,btnPosY,btnW,btnH,"Home",false,wPhoneMenu)
	guiSetFont ( bHome, font1 )

	bPowerOn = guiCreateButton(btnM,btnPosY,btnW,btnH,"Power On",false,wPhoneMenu)
	guiSetFont ( bPowerOn, font1 )

	bCancel = guiCreateButton(btnM+btnW+5,btnPosY,btnW,btnH,"Hide",false,wPhoneMenu)
	guiSetFont ( bCancel, font1 )
	addEventHandler("onClientGUIClick", getRootElement(), onGuiClick)
	guiSetEnabled(wPhoneMenu, false)

	if wRingSMS and isElement(wRingSMS) then
		guiSetEnabled(bRingingSMSOK, false)
	    addEventHandler("onClientRender", getRootElement(), slideRingingSMSOut)
	end
	return true
end

function updatePhoneGUI(action, data)
	if isPhoneGUICreated() and action then
		if action == "initiate" then
			if data[1] and tonumber(data[1]) ~= tonumber(phone) then
				slidePhoneOut()
				return false
			end
			toggleOffEverything()
			if data[2] and tonumber(data[2]) == 1 then
				guiSetVisible(bPowerOn, false)
				guiSetVisible(bHome, true)
				drawPhoneHome()
			else
				guiSetVisible(bPowerOn, true)
				guiSetVisible(bHome, false)
			end
			guiSetEnabled(wPhoneMenu, true)
			phone = tonumber(data[1])
			updateClientPhoneSettingsFromServer(phone, data)
		elseif action == "popOutOnPhoneCall" then
			toggleOffEverything()
			guiSetVisible(bPowerOn, false)
			guiSetVisible(bHome, true)
			--outputChatBox(dialingContactFrom)
			startDialing(phone, dialingContactFrom, true)
			guiSetEnabled(bHome, false)
			guiSetEnabled(wPhoneMenu, true)
		elseif tonumber(action) then
			toggleOffEverything()
			guiSetVisible(bPowerOn, false)
			guiSetVisible(bHome, true)
			--outputChatBox(action)
			startDialing(phone, action)
			guiSetEnabled(bHome, false)
			guiSetEnabled(wPhoneMenu, true)
		end
	end
end
addEvent("phone:updatePhoneGUI", true)
addEventHandler("phone:updatePhoneGUI", root, updatePhoneGUI)

function updateClientPhoneSettingsFromServer(fromPhone, data)
	outputDebugString("[Phone] updateClientPhoneSettingsFromServer / "..fromPhone)
	if data and #data>0 and tonumber(fromPhone) then
		fromPhone = tonumber(fromPhone)
		setPhoneSettings(fromPhone, "phone", data[1])
		setPhoneSettings(fromPhone, "powerOn", data[2])
		setPhoneSettings(fromPhone, "ringtone", data[3])
		setPhoneSettings(fromPhone, "isSecret", data[4])
		setPhoneSettings(fromPhone, "isInPhonebook", data[5])
		setPhoneSettings(fromPhone, "boughtBy", data[6])
		setPhoneSettings(fromPhone, "boughtByName", data[7])
		setPhoneSettings(fromPhone, "boughtDate", data[8])
		setPhoneSettings(fromPhone, "sms_tone", data[9])
		setPhoneSettings(fromPhone, "keypress_tone", data[10])
		setPhoneSettings(fromPhone, "tone_volume", data[11])
	end
end
addEvent("phone:updateClientPhoneSettingsFromServer", true)
addEventHandler("phone:updateClientPhoneSettingsFromServer", root, updateClientPhoneSettingsFromServer)

function triggerSlidingPhoneIn(thePhoneNumber, popOutOnPhoneCall, callingNumberFromCommand, openToSMSThread)
	outputDebugString("triggerSlidingPhoneIn.."..(popOutOnPhoneCall and "popOutOnPhoneCall" or ""))
	if not canPlayerSlidePhoneIn(localPlayer) then
		outputChatBox("You can not use cellphone at the moment.")
		return false
	end

	if not font1 then
		font1 = guiCreateFont ( ":resources/cartwheel.otf", 12 )
	end

	if thePhoneNumber and tonumber(thePhoneNumber) then
		phone = tonumber(thePhoneNumber)
	end

	if not phone then
		return false
	else
		if not popOutOnPhoneCall and tonumber(phone) ~= tonumber(thePhoneNumber) then
			return false
		end
	end

	if drawPhoneGUI() then
		removeEventHandler("onClientRender", root, slidePhoneOut)
		addEventHandler("onClientRender", root, slidePhoneIn)
		setED(localPlayer, "exclusiveGUI", true)
	end

	local powerOn = getPhoneSettings(thePhoneNumber, "powerOn")
	local ringtone = getPhoneSettings(thePhoneNumber, "ringtone")
	local isSecret = getPhoneSettings(thePhoneNumber, "isSecret")
	local isInPhonebook = getPhoneSettings(thePhoneNumber, "isInPhonebook")
	local boughtBy = getPhoneSettings(thePhoneNumber, "boughtBy")
	local boughtByName = getPhoneSettings(thePhoneNumber, "boughtByName")
	local boughtDate = getPhoneSettings(thePhoneNumber, "boughtDate")
	local sms_tone = getPhoneSettings(thePhoneNumber, "sms_tone")
	local keypress_tone = getPhoneSettings(thePhoneNumber, "keypress_tone")
	local tone_volume = getPhoneSettings(thePhoneNumber, "tone_volume")

	if openToSMSThread then
		updatePhoneGUI(popOutOnPhoneCall and "popOutOnPhoneCall" or tonumber(callingNumberFromCommand) or "initiate", {thePhoneNumber, powerOn, ringtone, isSecret, isInPhonebook, boughtBy, boughtByName, boughtDate, sms_tone, keypress_tone})

		local hasPhone, slot, itemValue, itemIndex, metadata = exports.global:hasItem(localPlayer, 2, phone)
		local phoneName
		if metadata then
			phoneName = exports['item-system']:getItemName(2, phone, metadata)
		end
		triggerServerEvent("phone:applyPhone", localPlayer, "phone_in", nil, phoneName)

		local smsNumber = tonumber(openToSMSThread)
		toggleOffEverything()
		drawOneSMSThread(smsNumber, 0, 0)
	elseif powerOn or popOutOnPhoneCall or tonumber(callingNumberFromCommand) then
		updatePhoneGUI(popOutOnPhoneCall and "popOutOnPhoneCall" or tonumber(callingNumberFromCommand) or "initiate", {thePhoneNumber, powerOn, ringtone, isSecret, isInPhonebook, boughtBy, boughtByName, boughtDate, sms_tone, keypress_tone})

		local hasPhone, slot, itemValue, itemIndex, metadata = exports.global:hasItem(localPlayer, 2, phone)
		local phoneName
		if metadata then
			phoneName = exports['item-system']:getItemName(2, phone, metadata)
		end
		triggerServerEvent("phone:applyPhone", localPlayer, "phone_in", nil, phoneName)
		if not powerOn then
			triggerServerEvent("phone:requestPhoneSettingsFromServer", localPlayer, thePhoneNumber)
		end
	else
		triggerServerEvent("phone:initiatePhoneGUI", getLocalPlayer(), phone,  popOutOnPhoneCall or callingNumberFromCommand, initiatePhoneGUI)
	end
end
addEvent("phone:slidePhoneIn", true)
addEventHandler("phone:slidePhoneIn", root, triggerSlidingPhoneIn)

function slidePhoneIn()
	if isPhoneGUICreated() then
		if guiSetPosition(wPhoneMenu, curX, curY, false) and canSlideIn()  then
			--outputDebugString("slidePhoneIn.."..tostring(curX < posX)..curX)
			curX = curX - slidingSpeed
		else
			removeEventHandler("onClientRender", root, slidePhoneIn)
		end
	else
		removeEventHandler("onClientRender", root, slidePhoneIn)
	end
end

function slidePhoneOut()
	if isPhoneGUICreated() then
		if guiSetPosition(wPhoneMenu, curX, curY, false) and canSlideOut() then
			--outputDebugString("slidePhoneOut.."..tostring(curX < posX)..curX)
			curX = curX + slidingSpeed
		else
			removeEventHandler("onClientRender", root, slidePhoneOut)
			hidePhoneGUI()
		end
	else
		removeEventHandler("onClientRender", root, slidePhoneOut)
	end
end
function triggerSlidingPhoneOut(DontTriggerApplyPhone)
	outputDebugString("triggerSlidingPhoneOut.."..(DontTriggerApplyPhone and "DontTriggerApplyPhone" or "TriggerApplyPhone"))
	if drawPhoneGUI() then
		removeEventHandler("onClientRender", root, slidePhoneIn)
		addEventHandler("onClientRender", root, slidePhoneOut)
		setED(localPlayer, "exclusiveGUI", false)
	end
	
	finishPhoneCall()
	
	if not DontTriggerApplyPhone then
		local hasPhone, slot, itemValue, itemIndex, metadata = exports.global:hasItem(localPlayer, 2, phone)
		local phoneName
		if metadata then
			phoneName = exports['item-system']:getItemName(2, phone, metadata)
		end
		triggerServerEvent("phone:applyPhone", localPlayer, "phone_out", nil, phoneName)
	end
end
addEvent("phone:slidePhoneOut", true)
addEventHandler("phone:slidePhoneOut", root, triggerSlidingPhoneOut)

function canSlideIn()
	return curX > posX-xoffset
end

function canSlideOut()
	return curX < posX
end

function initiatePhoneGUI(thePhoneNumber)
	
end


addEvent("phone:initiatePhoneGUI", true)
addEventHandler("phone:initiatePhoneGUI", getRootElement(), initiatePhoneGUI)

function drawPhoneHome()
	if isPhoneGUICreated() then
		drawPhoneDial()
		if not togglePanesOfApps(true) then
			drawAllPaneOfApps(-2,90)
		end
	end
end

function togglePhoneHome(state)
	if isPhoneGUICreated() then
		if ePhoneNumber and isElement(ePhoneNumber) then
			togglePhoneDial(state)
		else
			if state then
				drawPhoneHome()
			end
		end
		if not togglePanesOfApps(state) then
			if state then
				drawAllPaneOfApps(-2,90)
			end
		end
	end
end

function toggleOffEverything()
	togglePhoneHome(false)
	togglePhoneContacts(false)
	toggleHistory(false)
	guiNewContactClose()
	closeContactDetails()
	togglePanesOfApps(false)
	toggleSettingsGUI(false)
	closeDialing()
	exports.OwlGamingLogs:closeInfoBox()
	toggleHotlines(false)
	exports["computers-system"]:closeBrowser()
	triggerEvent("hideBankUI", localPlayer)
	closeSMSThreads()
end

hotlineIndexes = {}
function drawHomeMidBlock()
	if isPhoneGUICreated() then
		cHotlines = guiCreateComboBox ( 30,155+40+5,204,20, "Most Common Hotlines", false, wPhoneMenu )
		guiComboBoxAddItem(cHotlines, "Most Common Hotlines")
		selectedHotline = ""
		for hotline, hName in pairs(getHotlines()) do
			local text = hName.." ("..hotline..")"
			guiComboBoxAddItem(cHotlines, text )
			hotlineIndexes[text] = hotline
		end
		exports.global:guiComboBoxAdjustHeight(cHotlines, 12)

		addEventHandler ( "onClientGUIComboBoxAccepted", guiRoot,
		    function ( comboBox )
		        if ( comboBox == cHotlines ) and ePhoneNumber and isElement(ePhoneNumber) then
		            local item = guiComboBoxGetSelected ( cHotlines )
		            local text = tostring ( guiComboBoxGetItemText ( cHotlines , item ) )
		            if ( text ~= "" and text ~= "Most Common Hotlines") then
		                 guiSetText ( ePhoneNumber , hotlineIndexes[text] )
		            end
		        end
		    end
		)
		local rawSize = 128*0.5
		iPowerOff = guiCreateStaticImage( 100,155+40*2+5,rawSize,rawSize, "images/power_off.png", false, wPhoneMenu )
		--guiSetAlpha(iPowerOff, 0.5)
		bPowerOff = guiCreateButton( 100,155+40*2+5,rawSize,rawSize, "", false, wPhoneMenu )
		guiSetAlpha(bPowerOff, 0.2)
	end
end

function toggleHomeMidBlock(state)
	if cHotlines and isElement(cHotlines) then
		guiSetVisible(cHotlines, state)
		guiSetVisible(iPowerOff, state)
		guiSetVisible(bPowerOff, state)
	end
end


function drawPhoneIcons(yOffset)
	if isPhoneGUICreated() then
		

		iContacts = guiCreateStaticImage(posX,posY,iconSize,iconSize,"images/contacts.png",false,wPhoneMenu)
		btnContacts = guiCreateButton(posX,posY,iconSize,iconSize,"",false,wPhoneMenu)
		guiSetAlpha(btnContacts, btnAlpha)
		posX = posX + iconSize+iconSpacing

		iMessages = guiCreateStaticImage(posX,posY,iconSize,iconSize,"images/messages.png",false,wPhoneMenu)
		btnMessages = guiCreateButton(posX,posY,iconSize,iconSize,"",false,wPhoneMenu)
		guiSetAlpha(btnMessages, btnAlpha)
		posX = posX + iconSize+iconSpacing

		posY = posY + iconSize + iconSpacing
		posX = 30

		iMusic = guiCreateStaticImage(posX,posY,iconSize,iconSize,"images/music.png",false,wPhoneMenu)
		btnMusic = guiCreateButton(posX,posY,iconSize,iconSize,"",false,wPhoneMenu)
		guiSetAlpha(btnMusic, btnAlpha)
		posX = posX + iconSize+iconSpacing

		iWeather = guiCreateStaticImage(posX,posY,iconSize,iconSize,"images/weather.png",false,wPhoneMenu)
		btnWeather = guiCreateButton(posX,posY,iconSize,iconSize,"",false,wPhoneMenu)
		guiSetAlpha(btnWeather, btnAlpha)
		posX = posX + iconSize+iconSpacing

		iSettings = guiCreateStaticImage(posX,posY,iconSize,iconSize,"images/settings.png",false,wPhoneMenu)
		btnSettings = guiCreateButton(posX,posY,iconSize,iconSize,"",false,wPhoneMenu)
		guiSetAlpha(btnSettings, btnAlpha)
		posX = posX + iconSize+iconSpacing
	end
end

function togglePhoneIcons(state)
	if isPhoneGUICreated() and iHistory and isElement(iHistory) then
		if state then
			guiSetVisible(iHistory, true)
			guiSetVisible(btnHistory, true)
			guiSetVisible(iContacts, true)
			guiSetVisible(btnContacts, true)
			guiSetVisible(iMessages, true)
			guiSetVisible(btnMessages, true)
			guiSetVisible(iMusic, true)
			guiSetVisible(btnMusic, true)
			guiSetVisible(iWeather, true)
			guiSetVisible(btnWeather, true)
			guiSetVisible(iSettings, true)
			guiSetVisible(btnSettings, true)
		else
			guiSetVisible(iHistory, false)
			guiSetVisible(btnHistory, false)
			guiSetVisible(iContacts, false)
			guiSetVisible(btnContacts, false)
			guiSetVisible(iMessages, false)
			guiSetVisible(btnMessages, false)
			guiSetVisible(iMusic, false)
			guiSetVisible(btnMusic, false)
			guiSetVisible(iWeather, false)
			guiSetVisible(btnWeather, false)
			guiSetVisible(iSettings, false)
			guiSetVisible(btnSettings, false)
		end
	end
end




function hidePhoneGUI()
	guiConfirmDeleteClose()
	guiNewContactClose()
	if isPhoneGUICreated() then
		toggleOffEverything()
		destroyElement(wPhoneMenu)
		wPhoneMenu = nil
		showCursor(false)
		guiSetInputEnabled(false)
		
		removeEventHandler("onClientGUIClick", getRootElement(), onGuiClick)
		setElementData(localPlayer, "exclusiveGUI", false, false)
		setElementData(localPlayer, "cellphoneGUIState", "slidedOut", false)
	end
	closeConfirmBox()
	killSettingSounds()
	exports.OwlGamingLogs:closeInfoBox()
end


function guiConfirmDelete(name, number)
	guiSetEnabled( wPhoneMenu, false )
	local sx, sy = guiGetScreenSize() 
	wDelete = guiCreateWindow(sx/2 - 150,sy/2 - 50,300,100,"Delete entry", false)
	lQuestion = guiCreateLabel(0.05,0.25,0.9,0.3, "Are you sure you want to delete '"..name.."' from your contacts list?",true,wDelete)
	guiLabelSetHorizontalAlign (lQuestion,"center",true)
	bButtonDeleteYes = guiCreateButton(0.1,0.65,0.37,0.23,"Yes",true,wDelete)
	bButtonDeleteNo = guiCreateButton(0.53,0.65,0.37,0.23,"No",true,wDelete)
	saveDeleteName = name
	saveDeleteNumber = number
end


function guiConfirmDeleteClose()
	if wDelete and isElement(wDelete) then
		destroyElement(wDelete)
	end
	if isPhoneGUICreated() then
		guiSetEnabled( wPhoneMenu, true )
	end
end

function onGuiClick(button)
	if button == "left" then
		if p_Sound["playing"] then
			stopSound(p_Sound["playing"])
		end
		if source == bCall then
			startDialing(phone, guiGetText(ePhoneNumber))
		elseif source == bSMSDial then
			if tonumber(guiGetText(ePhoneNumber)) then
				toggleOffEverything()
				drawOneSMSThread(tonumber(guiGetText(ePhoneNumber)))
			end
		elseif source == bPowerOn then
			powerOnPhone()
		elseif source ==  bHome then
			toggleOffEverything()
			togglePhoneHome(true)
		elseif source == bCancel2 then -- Cancel contact details
			toggleOffEverything()
			togglePhoneContacts(true)
		elseif source == bAddContact then
			if isPhoneGUICreated() then
				guiSetEnabled(wPhoneMenu, false)
				local name = guiGetText(fName_contacts_new)
				local phoneNumber = guiGetText(fNumber_contacts_new)
				triggerServerEvent("phone:addContact", localPlayer, name, phoneNumber, phone or "-1")
			end
		elseif source == gRingtones then
			if guiGridListGetSelectedItem(gRingtones) ~= -1 then
				p_Sound["playing"] = playSound(ringtones[guiGridListGetSelectedItem(gRingtones)])
			end
		elseif source == bCancel then
			triggerSlidingPhoneOut()
		elseif source == bOK then
			if guiGridListGetSelectedItem(gRingtones) ~= -1 then
				triggerServerEvent("saveRingtone", getLocalPlayer(), guiGridListGetSelectedItem(gRingtones), tonumber(phone) or 1)
			end
			hidePhoneGUI()
		elseif source == bButtonDeleteYes then
			triggerServerEvent("phone:deleteContact", getLocalPlayer(), saveDeleteName, saveDeleteNumber, tonumber(phone) or 1)
			guiConfirmDeleteClose()
		elseif source == bButtonDeleteNo then
			guiConfirmDeleteClose()
		elseif source == bCancelContact then
			guiNewContactClose()
			togglePhoneContacts(true)
			if isPhoneGUICreated() then
				guiSetEnabled(wPhoneMenu, true)
			end
			if gPhoneBook and isElement(gPhoneBook) then
				guiSetEnabled(gPhoneBook, true)
			end
		end
		if source ~= wPhoneMenu and source ~= bEndCall and source ~=wHistory then
			playToggleSound()
		end
	end
end

function showSettingsGui(itemValue)
	addEventHandler("onClientGUIClick", getRootElement(), onGuiClick)
	showCursor(true)

	wPhoneMenu = guiCreateWindow(sx/2 - 125,sy/2 - 175,250,310,"Phone Settings Menu",false)
	gRingtones = guiCreateGridList(0.0381,0.1977,0.9153,0.6706,true,wPhoneMenu)
	guiGridListAddColumn(gRingtones,"ringtones",0.85)
	guiGridListSetItemText(gRingtones, guiGridListAddRow(gRingtones), 1, "vibrate mode", false, false)
	for i, filename in ipairs(ringtones) do
		guiGridListSetItemText(gRingtones, guiGridListAddRow(gRingtones), 1, filename:sub(1,-5), false, false)
	end
	guiGridListSetSelectedItem(gRingtones, itemValue, 1)
	bOK = guiCreateButton(0.0381,0.8821,0.4492,0.0742,"OK",true,wPhoneMenu)
	bCancel = guiCreateButton(0.5212,0.8821,0.4322,0.0742,"Cancel",true,wPhoneMenu)
end

function radioDispatchBeep()
	playSound("sounds/dispatch.mp3", false)
end
addEvent("phones:radioDispatchBeep", true)
addEventHandler("phones:radioDispatchBeep", getRootElement(), radioDispatchBeep)
local turningOn = 1
function powerOnPhone()
	if isPhoneGUICreated() then
		turningOn = 1
		local ratio = 0.8
		local rawW, rawH = 257*ratio, 120*ratio
		alphaTmp = nil
		powerOnPhone_logo = guiCreateStaticImage(30, 200, rawW, rawH, ":resources/OGLogo.png", false, wPhoneMenu)
		--guiSetAlpha(logo, alpha)
		powerOnPhone_text = guiCreateLabel(80, 180+rawH+5, rawW, rawH, "Starting up...0%", false, wPhoneMenu)
		--guiSetAlpha(text, alpha)
		guiSetEnabled(wPhoneMenu, false)
		addEventHandler("onClientRender", root, fadeInLogo)
	end
end

function powerOffPhone()
	if isPhoneGUICreated() then
		turningOn = 0
		toggleOffEverything()
		local ratio = 0.8
		local rawW, rawH = 257*ratio, 120*ratio
		alphaTmp = nil
		powerOnPhone_logo = guiCreateStaticImage(30, 200, rawW, rawH, ":resources/OGLogo.png", false, wPhoneMenu)
		--guiSetAlpha(logo, alpha)
		powerOnPhone_text = guiCreateLabel(80, 180+rawH+5, rawW, rawH, "Starting up...0%", false, wPhoneMenu)
		--guiSetAlpha(text, alpha)
		guiSetEnabled(wPhoneMenu, false)
		addEventHandler("onClientRender", root, fadeInLogo)
	end
end

function fadeInLogo()
	if isPhoneGUICreated() then
		if powerOnPhone_logo and isElement(powerOnPhone_logo) then
			if not alphaTmp then
				alphaTmp = 0
			end
			if alphaTmp <= 1 then
				guiSetAlpha(powerOnPhone_logo, alphaTmp)
				alphaTmp = alphaTmp + 0.01
				guiSetText(powerOnPhone_text, (turningOn == 1 and "Starting up" or "Shutting down").."..."..(alphaTmp*100).."%")
			else
				removeEventHandler("onClientRender", root, fadeInLogo)
				triggerServerEvent("phone:powerOn", localPlayer, phone, turningOn)
			end
		end
	end
end

function powerOnResponse(success, turnedOn)
	if isPhoneGUICreated() then
		if turnedOn == 1 then
			if success then
				destroyElement(powerOnPhone_logo)
				powerOnPhone_logo = nil
				destroyElement(powerOnPhone_text)
				powerOnPhone_text = nil
				drawPhoneHome()
				guiSetVisible(bPowerOn, false)
				guiSetVisible(bHome, true)
				--outputChatBox(phone.."-"..turnedOn)
				setPhoneSettings(phone, "powerOn", turnedOn)
			else
				guiSetText(powerOnPhone_text, "Starting up...Failed!")
			end
		else
			if success then
				destroyElement(powerOnPhone_logo)
				powerOnPhone_logo = nil
				destroyElement(powerOnPhone_text)
				powerOnPhone_text = nil
				toggleOffEverything()
				guiSetVisible(bPowerOn, true)
				guiSetVisible(bHome, false)
				--outputChatBox(phone.."-"..turnedOn)
				setPhoneSettings(phone, "powerOn", turnedOn)
			else
				guiSetText(powerOnPhone_text, "Shutting down...Failed!")
			end
		end
		guiSetEnabled(wPhoneMenu, true)
	end
end
addEvent("phone:powerOn:response", true)
addEventHandler("phone:powerOn:response", getRootElement(), powerOnResponse)


--------------------------------------------------------------------------------------------
function isPhoneGUICreated()
	if wPhoneMenu and isElement(wPhoneMenu) then
		return true
	else
		return false
	end
end

function validateContactNameAndNumber(name, number, id)
	if #contactList[phone] >= contactListLimit[phone] then
		return false
	end 
	if (string.len(name) > 1 and name ~= "New contact") and (string.len(number) > 1 and tonumber(number)) then
		for i, contact in pairs(contactList[phone]) do
			if not id then
				if (contact.entryName and string.lower(contact.entryName) == string.lower(name)) or ( contact.entryNumber and tonumber(contact.entryNumber) == tonumber(number)) then
					return false
				end
			else
				if (tonumber(id) ~= tonumber(contact.id)) then
					if (contact.entryName and string.lower(contact.entryName) == string.lower(name)) or ( contact.entryNumber and tonumber(contact.entryNumber) == tonumber(number)) then
						return false
					end
				end
			end
		end
   		return true
   	else
   		return false
   	end
end

function playToggleSound()
	if getPhoneSettings(phone, "keypress_tone") == 0 then
		return false
	end
	playSound(":resources/toggle.mp3")
end

function cleanUp()
	setElementData(localPlayer, "exclusiveGUI", false, false)
	setElementData(localPlayer, "cellphoneGUIState", "slidedOut", false)
	setElementData(localPlayer, "phoneRingingShowing", nil, false)
end
addEventHandler("onClientResourceStart", resourceRoot, cleanUp)

function clearAllCaches(fromPhone)
	--outputDebugString("[Phone] clearAllCaches / "..(fromPhone or ""))
	fromPhone = tonumber(fromPhone)
	if fromPhone then
		outputDebugString("[Phone] clearAllCaches / "..(fromPhone or ""))
		resetHistory(fromPhone)
		if contactList[fromPhone] then
			contactList[fromPhone] = nil
		end
		cleanSettings(fromPhone)
		resetSMSThreads(fromPhone)
		smsComposerCache[fromPhone] = nil
	end
end
addEvent("phone:clearAllCaches", true)
addEventHandler("phone:clearAllCaches", root, clearAllCaches)

function noWeaponsDuringPhoneUse(a,b) -- Maxime
	if tonumber(getElementData(localPlayer, 'cellphoneGUIStateSynced') or 0) > 0 then
		--outputChatBox("cancled")
		if b ~= 0 then 
			cancelEvent()
		end
	end
end
addEventHandler("onClientPedWeaponFire", localPlayer, noWeaponsDuringPhoneUse)
addEventHandler("onClientPlayerWeaponFire", localPlayer, noWeaponsDuringPhoneUse)
addEventHandler("onClientPlayerWeaponSwitch", localPlayer, noWeaponsDuringPhoneUse)
addEventHandler("onClientPlayerTarget", localPlayer, noWeaponsDuringPhoneUse)
