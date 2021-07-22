--MAXIME

local actualSeconds = 0
local actualCountedTime = "00:00"
local calledHotline = nil
local startPressingDialSoundIndex = 0
p_Sound = {}
function drawPhoneDial()
	if isPhoneGUICreated() then
		curEditPhoneNumber = ""
		ePhoneNumber = guiCreateEdit(30,100,204,50,"",false,wPhoneMenu)
		guiEditSetMaxLength(ePhoneNumber, 24)
		guiSetFont ( ePhoneNumber, font1 )
		addEventHandler("onClientGUIChanged", ePhoneNumber, function(element)
		   	if guiGetText(element) == "" or tonumber(guiGetText(element)) then
		   		curEditPhoneNumber = guiGetText(element)
		   	else
		   		guiSetText(element, curEditPhoneNumber)
		   	end
		end)

		local function onClientGUIFocus_editbox()
			if source == ePhoneNumber then
				guiSetInputEnabled(true)
			end
		end

		local function onClientGUIBlur_editbox()
			if source == ePhoneNumber then
				guiSetInputEnabled(false)
			end
		end

		addEventHandler("onClientGUIFocus", ePhoneNumber, onClientGUIFocus_editbox, true)
		addEventHandler("onClientGUIBlur", ePhoneNumber, onClientGUIBlur_editbox, true)

		bCall = guiCreateButton(30,155,102,30,"Call",false,wPhoneMenu)
		guiSetFont ( bCall, font1 )
		bSMSDial = guiCreateButton(30+102,155,102,30,"SMS",false,wPhoneMenu)
		guiSetFont ( bSMSDial, font1 )

		addEventHandler( "onClientGUIAccepted", ePhoneNumber,
		    function( theElement )
		        startDialing(phone, guiGetText(theElement))
		    end
		)
	end
end

function togglePhoneDial(state)
	if isPhoneGUICreated() then
		if ePhoneNumber and isElement(ePhoneNumber) then
			if state then
				guiSetVisible(ePhoneNumber, true)
				guiSetVisible(bCall, true)
				guiSetVisible(bSMSDial, true)
			else
				guiSetVisible(ePhoneNumber, false)
				guiSetVisible(bCall, false)
				guiSetVisible(bSMSDial, false)
			end
		end
	end
end

local dialingTimers = {}
local dialingSounds = {}
function startDialing(from, to, popOutOnPhoneCall)
	if from and to and string.len(to) > 0 then
		resetHistory(from)
		local yoffset = 140
		if not yoffset then yoffset = 0 end
		local callingTo = nil
		if contactList[phone] then
			for i, contact in pairs(contactList[phone]) do
				if tostring(contact.entryName) == tostring(to) or tostring(contact.entryNumber) == tostring(to) then
					callingTo = {contact.entryNumber, contact.entryName}
					break
				end
			end
		end
		if not callingTo then
			if not tonumber(to) and to ~= "Private" then
				return false
			end
			callingTo = {to, nil}
		end
		if not popOutOnPhoneCall then
			killDialingSounds()
			killDialingTimers()
			--local sound = playSound("sounds/touch_tone.mp3")
			--setSoundVolume(sound, 0.3)
			--table.insert(dialingSounds, sound)
			startPressingDialSoundIndex = 0
			local startPressing = setTimer(startPressingDialSound, 200, string.len(to), to)
			table.insert(dialingTimers, startPressing)

			local timer = setTimer(triggerServerEvent, 3000, 1, "phone:startDialing", localPlayer, to, from)
			table.insert(dialingTimers, timer)
		end
		toggleOffEverything()

		local posY = 100+yoffset
		local margin = 30
		local lineH, lineW = margin, 200
		local lineW2 = 150

		if not font2 then
			font2 = guiCreateFont ( ":resources/nametags0.ttf", 17 )
		end

		lCallingTo = guiCreateLabel(margin,posY-10,lineW,40, callingTo[1], false, wPhoneMenu)
		guiSetFont(lCallingTo, font2)
		guiLabelSetHorizontalAlign(lCallingTo, "center")
		posY = posY + lineH

		lCallingText = guiCreateLabel(margin,posY-10,lineW,100, "Calling..." , false, wPhoneMenu)
		guiLabelSetHorizontalAlign(lCallingText, "center")
		posY = posY + lineH*4+10

		local bW,bH = 200, 30

		bSpeaker = guiCreateButton(margin+2,posY,bW,bH, "Loudspeaker", false, wPhoneMenu)
		posY = posY + bH + 2

		addEventHandler('onClientGUIClick', bSpeaker, function()
			if source == bSpeaker then
				triggerServerEvent('phone:loudspeaker', localPlayer, localPlayer, 'loudspeaker')
			end
		end, false
		)

		bEndCall = guiCreateButton(margin+2,posY,bW,bH, "End", false, wPhoneMenu)

		posY = posY + bH + 2

		addEventHandler("onClientGUIClick", bEndCall, function()
			if source == bEndCall then
				endPhoneCall()
			end
		end)


		if not popOutOnPhoneCall then
			--killDialingTimers() --already killed above, shouldn't kill again
			local subscriberOutOfService = setTimer(finishPhoneCall, 20000, 1, "out_of_service")
			table.insert(dialingTimers, subscriberOutOfService)
		end

		actualCountedTime = 0
		actualCountedTime = "00:00"

		if popOutOnPhoneCall then
			guiSetText(lCallingTo, callingTo[2] or callingTo[1])
			guiSetText(lCallingText, "Connected!")
			startCounting()
			calledHotline = true
			guiSetEnabled(bEndCall, true)
			guiSetEnabled(bSpeaker, true)
			if dialingTone and isElement(dialingTone) then
				destroyElement(dialingTone)
				dialingTone = nil
			end
			playSound("sounds/ringtones/viberate.mp3")
			guiSetEnabled(wPhoneMenu, true)
		else
			guiSetEnabled(wPhoneMenu, false)
		end
	end
end

function endPhoneCall()
	triggerServerEvent("phone:cancelPhoneCall", localPlayer, getPhoneCallCost())
	if isPhoneGUICreated() then
		guiSetEnabled(wPhoneMenu, true)
	end
end

function finishPhoneCall(reason)
	killDialingSounds()
	killDialingTimers()
	playSound("sounds/hangup.mp3")
	local reasonText = "End"
	if reason == "out_of_service" then
		reasonText = "The subscriber you have dialed\n is not in service"
	elseif reason == "cant_afford" then
		reasonText = "You can not afford this phone call.\nPlease deposit money"
	elseif reason == "declined" then
		reasonText = "Subscriber has rejected your call"
	elseif reason == "not_existed" then
		reasonText = "The number you have dialed\n does not exist"
	elseif isQuitType(reason) then
		reasonText = "Signal was lost, disconnected! \n(("..reason.."))"
	else
		reasonText = "End"
	end
	local callingCost = getPhoneCallCost()
	if lCallingText and isElement(lCallingText) then
		guiSetText(lCallingText, reasonText..".\n\nDuration: "..actualCountedTime.."\nCost: $"..exports.global:formatMoney(callingCost))
		if isPhoneGUICreated() then
			guiSetEnabled(wPhoneMenu, true)
		end
	end

	if isPhoneGUICreated() and bEndCall and isElement(bEndCall) then
		guiSetEnabled(bEndCall, false)
		guiSetEnabled(bSpeaker, false)
		guiSetEnabled(bHome, true)
	end

	if not calledHotline and callingCost > 0 then
		outputDebugString("[Phone] takeCallCost / "..getPlayerName(localPlayer).." / "..actualCountedTime.." / $"..callingCost)
		triggerServerEvent("phone:takeCallCost", localPlayer, callingCost, phone, actualCountedTime)
		actualSeconds = 0
	end
end

function getPhoneCallCost()
    if calledHotline then
        return 0
    elseif actualSeconds < 1 then 
        return 0 
    else
        local cost = math.ceil(actualSeconds*0.305)
        return cost < 5000 and cost or 5000 --Max 5k.
    end
end

function closeDialing()
	if isPhoneGUICreated() and lCallingTo and isElement(lCallingTo) then
		destroyElement(lCallingTo)
		lCallingTo = nil
		destroyElement(lCallingText)
		lCallingText = nil
		destroyElement(bSpeaker)
		bSpeaker = nil
		destroyElement(bEndCall)
		bEndCall = nil
		killDialingSounds()
		killDialingTimers()
	end
end

function updateDialingScreen(action, data, calledHotline1)
	outputDebugString("[Phone] updateDialingScreen / Client/ "..(action and action))
	if isPhoneGUICreated() and lCallingTo and isElement(lCallingTo) then
		if action then
			if action == "caller, started dialing but canceled" then
				finishPhoneCall()
			elseif action == "caller, started dialing and target is ringing. but canceled" then
				finishPhoneCall()
			elseif action == "called, started ringing .but they canceled" then
				finishPhoneCall("declined")
			elseif action == "start_dialing_tone" then
				if data then
					calledHotline = calledHotline1 or exports.donators:hasPlayerPerk(localPlayer, 6)
					killDialingTimers()
					killDialingSounds()
					guiSetText(lCallingTo, data.entryName or data.entryNumber)
					local dialingTone = playSound("sounds/dialing_tone.mp3", true)
					local timer1 = setTimer(destroyElement, 20000, 1, dialingTone)
					table.insert(dialingSounds, dialingTone)
					table.insert(dialingTimers, timer1)
					guiSetEnabled(bEndCall, true)
					guiSetEnabled(bSpeaker, true)
					guiSetEnabled(bHome, false)
				end
			elseif action == "called, started ringing but timed out" then
				finishPhoneCall()
			elseif action == "start_invalid_or_busy_tone" then
				finishPhoneCall(data)
				if data == "not_existed" then
					local sound1 = playSound("sounds/invalid_tone.mp3")
					setSoundVolume(sound1, 0.2)
					table.insert(dialingSounds, sound1)
				elseif data == "out_of_service" then
					local sound1 = playSound("sounds/busy_tone.mp3", true)
					setSoundVolume(sound1, 0.7)
					table.insert(dialingSounds, sound1)
					local timer1 = setTimer(destroyElement, 5000, 1, sound1)
					table.insert(dialingTimers, timer1)
				end
			elseif action == "connected" then
				if data then
					killDialingTimers()
					killDialingSounds()
					local sound1 = playSound("sounds/ringtones/viberate.mp3")
					table.insert(dialingSounds, sound1)

					guiSetText(lCallingTo, data.entryName or data.entryNumber)
					guiSetText(lCallingText, "Connected!")
					startCounting()
					guiSetEnabled(bEndCall, true)
					guiSetEnabled(bSpeaker, true)
				end
			elseif isQuitType(action) then
				finishPhoneCall(action)
			elseif action == "called, answered but they canceled" then
				finishPhoneCall()
			elseif action == "caller, connected, canceled" then
				finishPhoneCall()
			elseif action == "cant_afford" then
				finishPhoneCall("cant_afford")
			else
				finishPhoneCall()
			end
		end
		guiSetEnabled(wPhoneMenu, true)
	end
end
addEvent("phone:updateDialingScreen", true)
addEventHandler("phone:updateDialingScreen", root, updateDialingScreen)

function startCounting()
	actualSeconds = 0
	local seconds = 0
	local minutes = 0
	killDialingTimers()
	dialingTimers.countingClock = setTimer(function()
		--outputDebugString(getElementData(localPlayer, "bankmoney"))
		--outputDebugString(getPhoneCallCost())
		if not exports.bank:hasBankMoney(localPlayer, getPhoneCallCost()) then
			triggerServerEvent("phone:cancelPhoneCall", getLocalPlayer(), "cant_afford")
			setTimer(finishPhoneCall, 1000, 1, "cant_afford")
			--finishPhoneCall("cant_afford")
			return false
		end

		actualCountedTime = string.format("%02d:%02d", minutes, seconds)
		guiSetText(lCallingText, actualCountedTime)
		actualSeconds = actualSeconds + 1
		seconds = seconds + 1
		if seconds >= 60 then
			minutes = minutes + 1
			seconds = 0
		end
	end, 1000, 0)
end

function killDialingTimers()
	for i, timer in pairs(dialingTimers) do
		if timer then
			if isTimer(timer) then
				if killTimer(timer) then
					outputDebugString("[Phone] Client / killDialingTimers")
				end
			end
			timer = nil
		end
	end
end

function killDialingSounds()
	for i, sound in pairs(dialingSounds) do
		if sound then
			if isElement(sound) then
				destroyElement(sound)
				timer = nil
			end
		end
	end
end

local ringOffSetOut = sx
local ringOffSetIn = nil
local ringOffSetY = nil
function drawRinging(phoneToDisplay, numberToDisplay)
	--outputChatBox(phoneRinging)
	local margin = 18
	local w, h = 257, 93
	local x, y = sx-w-margin+20, sy-h-margin*1.5
	ringOffSetIn = x
	ringOffSetY = y
	setElementData(localPlayer, "phoneRingingShowing", true, false)
	if wRing and isElement(wRing) then
		destroyElement(wRing)
	end
	wRing = guiCreateWindow(ringOffSetOut,y,w,h, "Your phone #"..phoneToDisplay.." is ringing!", false)
    guiWindowSetMovable(wRing, false)
    guiWindowSetSizable(wRing, false)

	local lFrom = guiCreateLabel(10, 25, w  - 20, 20, "Call from " .. numberToDisplay .. ".", false, wRing)
	guiLabelSetHorizontalAlign(lFrom, "center", false)

    bRingingAnswer = guiCreateButton(10, 48, 117, 35, "Answer", false, wRing)
    bRingingDecline = guiCreateButton(129, 48, 118, 35, "Decline", false, wRing)
    addEventHandler("onClientGUIClick", bRingingDecline, function()
    	if source == bRingingDecline then
	    	declinePhoneCall()
    	end
    end)

    addEventHandler("onClientGUIClick", bRingingAnswer, function()
    	if source == bRingingAnswer then
    		answerToPhoneCall()
    	end
    end)
    return true
end

function answerToPhoneCall()
	if canPlayerAnswerCall(localPlayer) then
		guiSetEnabled(bRingingAnswer, false)
		guiSetEnabled(bRingingDecline, false)
		triggerServerEvent("phone:acceptPhoneCall", localPlayer)
	else
		outputDebugString("You can not use cellphone at the moment.", 255,0,0)
	end
end
addCommandHandler("pickup", answerToPhoneCall)

function declinePhoneCall()
	if canPlayerAnswerCall(localPlayer) and bRingingAnswer and isElement(bRingingAnswer) then
		guiSetEnabled(bRingingAnswer, false)
		guiSetEnabled(bRingingDecline, false)
		triggerServerEvent("phone:cancelPhoneCall", localPlayer)
	elseif bEndCall and isElement(bEndCall) then
		endPhoneCall()
	elseif getElementData(localPlayer, "call.col") then -- public phone
		endPhoneCall()
	end
end
addCommandHandler("hangup", declinePhoneCall)

function closeRinging()
	if wRing and isElement(wRing) then
		destroyElement(wRing)
		wRing = nil
		setElementData(localPlayer, "phoneRingingShowing", nil, false)
	end
end

function slideRingingOut()
	if wRing and isElement(wRing) then
		if guiSetPosition(wRing, ringOffSetOut, ringOffSetY, false) and ringOffSetOut < sx then
			ringOffSetOut = ringOffSetOut + slidingSpeed
		else
			removeEventHandler("onClientRender", getRootElement(), slideRingingOut)
		end
	else
		closeRinging()
		removeEventHandler("onClientRender", getRootElement(), slideRingingOut)
	end
end
dialingContactFrom = nil
function startRingingOwner(phoneRinging, canPickUp, dialingContactFrom1, nameFrom, phoneToDisplay)
	--outputChatBox(phoneRinging)
	resetHistory(phoneRinging)
	dialingContactFrom = dialingContactFrom1
	if drawRinging(phoneToDisplay, nameFrom) then
		--triggerSlidingPhoneOut()
		guiSetEnabled(bRingingAnswer,canPickUp)
		guiSetEnabled(bRingingDecline,canPickUp)

		removeEventHandler("onClientRender", getRootElement(), slideRingingOut)
		addEventHandler("onClientRender", getRootElement(), slideRingingIn)
		setElementData(localPlayer, "exclusiveGUI", true, false)
	end
end
addEvent("phone:startRingingOwner", true)
addEventHandler("phone:startRingingOwner", root, startRingingOwner)

function slideRingingIn()
	if wRing and isElement(wRing) then
		if guiSetPosition(wRing, ringOffSetOut, ringOffSetY, false) and ringOffSetOut > ringOffSetIn then
			ringOffSetOut = ringOffSetOut - slidingSpeed
		else
			removeEventHandler("onClientRender", getRootElement(), slideRingingIn)
		end
	else
		removeEventHandler("onClientRender", getRootElement(), slideRingingIn)
	end
end

local ringingTimer = nil
function startPhoneRinging(ringType, ringtone, volume)
	if ringtone > 1 then
		volume = volume/10
		local x, y, z = getElementPosition(source)
		if ringType == 1 then -- phone call
			if not ringtone or ringtone < 0 then ringtone = 4 end
			p_Sound[source] = playSound3D(ringtones[ringtone], x, y, z , true)
			setSoundVolume(p_Sound[source], 0.4*volume)
			setSoundMaxDistance(p_Sound[source], 20)
			setElementDimension(p_Sound[source], getElementDimension(source))
			setElementInterior(p_Sound[source], getElementInterior(source))
			if isTimer(ringingTimer) then
				killTimer(ringingTimer)
			end
			ringingTimer = setTimer(triggerEvent, 15000, 1, "stopRinging", source) --Timer to make sure ringing will be killed at all the exceptional cases client sided
		elseif ringType == 2 then -- sms
			if not ringtone or ringtone < 0 then ringtone = 8 end
			p_Sound[source] = playSound3D(ringtones[ringtone], x, y, z)
			setSoundVolume(p_Sound[source], 0.4*volume)
			setSoundMaxDistance(p_Sound[source], 20)
			setElementDimension(p_Sound[source], getElementDimension(source))
			setElementInterior(p_Sound[source], getElementInterior(source))
			if isTimer(ringingTimer) then
				killTimer(ringingTimer)
			end
			ringingTimer = setTimer(triggerEvent, 15000, 1, "stopRinging", source)
		else
			outputDebugString("Ring type "..tostring(ringType).. " doesn't exist!", 2)
		end
		attachElements(p_Sound[source], source)
	end
end
addEvent("startRinging", true)
addEventHandler("startRinging", getRootElement(), startPhoneRinging)

function stopPhoneRinging()
	if p_Sound[source] and isElement(p_Sound[source]) then
		destroyElement(p_Sound[source])
		p_Sound[source] = nil
	end
	if stopTimer[source] and isTimer(stopTimer[source]) then
		killTimer(stopTimer[source])
		stopTimer[source] = nil
	end
	if source == localPlayer then
		removeEventHandler("onClientRender", getRootElement(), slideRingingIn)
		addEventHandler("onClientRender", getRootElement(), slideRingingOut)
		setElementData(localPlayer, "exclusiveGUI", false, false)
	end
end
addEvent("stopRinging", true)
addEventHandler("stopRinging", getRootElement(), stopPhoneRinging)

function startPressingDialSound(numbers)
	if numbers and tonumber(numbers) then
		startPressingDialSoundIndex = startPressingDialSoundIndex + 1
		local soundToPlay = string.sub(numbers, startPressingDialSoundIndex, startPressingDialSoundIndex)
		if soundToPlay then
			local sound = playSound("sounds/beeps/"..soundToPlay..".mp3")
			table.insert(dialingSounds, sound)
		else
			startPressingDialSoundIndex = 0
		end
	end
end
