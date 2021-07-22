--MAXIME
--NOTES
--[[
phonestate = 1 / caller, started dialing
phonestate = 2 / caller, started dialing and target is ringing.
phonestate = 3 / called, is being rang
phonestate = 4 /
]]
local dialingTimers = {}

function addDialingTimer(key, value)
	key = tonumber(key)

	if not dialingTimers[key] then
		dialingTimers[key] = {}
	end

	table.insert(dialingTimers[key], value)
end

local tmpElement = {}
function startDialing(to, from)
	local displayedFrom = from
	local owningPlayer, realFrom = resolveVirtualPhoneNumber(from)
	if owningPlayer and displayedFrom and exports.global:hasItem(source, 2) then
		-- virtual phone number; ignore not having the particular phone
		from = realFrom
	elseif not exports.global:hasItem(source, 2, tonumber(from)) then
		outputDebugString("[Phone] "..getPlayerName(source).." started calling from "..from.." to "..to.." without a phone.")
		outputChatBox("Error Code x0EDSCVF23. Please report on http://bugs.owlgaming.net", source, 255,0,0)
		triggerClientEvent(source, "phone:slidePhoneOut", source)
		return false
	end

	local powerOn, ringtone, isSecret, isInPhonebook, boughtBy  = getPhoneSettings(from)
	if powerOn == 0 then
		outputChatBox("Your phone is off.", source, 255,0,0)
		triggerClientEvent(source, "phone:slidePhoneOut", source)
		return false
	end

	if not canPlayerCall(source) then
		outputChatBox("You can not use cellphone at the moment.", source, 255,0,0)
		triggerClientEvent(source, "phone:slidePhoneOut", source)
		return false
	end

	setEDX(source, "phonestate", 1, false) -- caller, started dialing
	setEDX(source, "callingwith", tonumber(displayedFrom), false)
	local delay = math.random(3000, 5000)
	if not dialingTimers[tonumber(from)] then
		dialingTimers[tonumber(from)] = {}
	end
	local hotlineName = getHotlineName(tonumber(to))
	local contact = {}
	if hotlineName then
		contact = { ["entryNumber"] = to,  ["entryName"] = hotlineName }
		triggerClientEvent(source, "phone:updateDialingScreen", source, "start_dialing_tone", contact, true)
		setEDX(source, "phonestate", 2, false)
		killDialingTimers(from)
		local timer1 = setTimer(setEDX, delay, 1, source, "calling", tonumber(contact.entryNumber), false)
		local timer2 = setTimer(setEDX, delay, 1, source, "phonestate", 4, false)
		local timer3 = setTimer(handleEasyHotlines, delay, 1, { element = source, phone = tonumber(from), called = tonumber(contact.entryNumber)}, tonumber(contact.entryNumber), true, "")
		local timer4 = setTimer(triggerClientEvent, delay, 1, source, "phone:updateDialingScreen", source, "connected", contact)
		local timer5 = setTimer(writeCellphoneLog, delay+50, 1, source, nil, "Calls", nil, true )
		table.insert(dialingTimers[tonumber(from)], timer1)
		table.insert(dialingTimers[tonumber(from)], timer2)
		table.insert(dialingTimers[tonumber(from)], timer3)
		table.insert(dialingTimers[tonumber(from)], timer4)
		table.insert(dialingTimers[tonumber(from)], timer5)
		addPhoneHistory(displayedFrom, to, 1, isSecret)

		return true
	end

	local contact = getPhoneContact(to, from)
	if not contact then
		if not tonumber(to) then
			--Provided name but not found in contacts.
			triggerClientEvent(source, "phone:updateDialingScreen", source, "start_invalid_or_busy_tone" , "not_existed")
			local timer1 = setTimer(triggerEvent,delay, 1, "phone:cancelPhoneCall", source, "not_existed")
			table.insert(dialingTimers[tonumber(from)], timer1)
			return false
		end
		contact = { ["entryNumber"] = to }
	end
	local displayedTo = contact.entryNumber
	local _, realTo = resolveVirtualPhoneNumber(contact.entryNumber)
	realTo = realTo or contact.entryNumber

	exports.anticheat:changeProtectedElementDataEx(source, "callingContact", contact, false)

	local t_powerOn, t_ringtone, t_isSecret, t_isInPhonebook, t_boughtBy, boughtByName, boughtDate, sms_tone, tone_volume = getPhoneSettings(realTo, true)
	if not t_powerOn then --not existed
		triggerClientEvent(source, "phone:updateDialingScreen", source, "start_invalid_or_busy_tone" , "not_existed")
		local timer1 = setTimer(triggerEvent,delay, 1, "phone:cancelPhoneCall", source, "not_existed")
		table.insert(dialingTimers[tonumber(from)], timer1)
		addPhoneHistory(displayedFrom, displayedTo, 2, isSecret)
		return false
	elseif t_powerOn ~= 1 then --turned off
		triggerClientEvent(source, "phone:updateDialingScreen", source, "start_invalid_or_busy_tone", "out_of_service")
		local timer1 = setTimer(triggerEvent,delay, 1, "phone:cancelPhoneCall", source, "out_of_service")
		table.insert(dialingTimers[tonumber(from)], timer1)
		addPhoneHistory(displayedFrom, displayedTo, 2, isSecret)
		return false
	else
		local foundInGame, targetPlayer = searchForPhone(to)
		if not foundInGame then
			triggerClientEvent(source, "phone:updateDialingScreen", source, "start_invalid_or_busy_tone", "out_of_service")
			local timer1 = setTimer(triggerEvent,delay, 1, "phone:cancelPhoneCall", source, "out_of_service")
			table.insert(dialingTimers[tonumber(from)], timer1)
			addPhoneHistory(displayedFrom, displayedTo, 2, isSecret)
			return false
		else
			if not dialingTimers[tonumber(contact.entryNumber)] then
				dialingTimers[tonumber(contact.entryNumber)] = {}
			end
			if not canPlayerPhoneRing(targetPlayer) then
				triggerClientEvent(source, "phone:updateDialingScreen", source, "start_invalid_or_busy_tone", "out_of_service")
				local timer1 = setTimer(triggerEvent,delay, 1, "phone:cancelPhoneCall", source, "out_of_service")
				table.insert(dialingTimers[tonumber(from)], timer1)
				addPhoneHistory(displayedFrom, displayedTo, 2, isSecret)
				return false
			end
			addPhoneHistory(displayedFrom, displayedTo, 1, isSecret)
			-- make sure the target phone is slided out before ringing him.
			if getElementData(targetPlayer, "cellphoneGUIStateSynced") then
				local hasPhone, slot, itemValue, itemIndex, metadata = exports.global:hasItem(targetPlayer, 2, realTo)
				local phoneName
				if metadata then
					phoneName = exports['item-system']:getItemName(2, realTo, metadata)
				end

				triggerEvent("phone:applyPhone", targetPlayer, "phone_out", nil, phoneName)
				triggerClientEvent(targetPlayer, "phone:slidePhoneOut", targetPlayer, true)
			end

			-- Note down some needed details.
			exports.anticheat:changeProtectedElementDataEx(source, "call.col", publicphone, false)
			exports.anticheat:changeProtectedElementDataEx(source, "calling", tonumber(realTo), false)
			exports.anticheat:changeProtectedElementDataEx(targetPlayer, "calling", tonumber(from), false)
			exports.anticheat:changeProtectedElementDataEx(targetPlayer, "callingwith", tonumber(realTo), false)
			exports.anticheat:changeProtectedElementDataEx(source, "called", false, false)
			exports.anticheat:changeProtectedElementDataEx(targetPlayer, "called", true, false)
			exports.anticheat:changeProtectedElementDataEx(source, "phonestate", 2, false)
			exports.anticheat:changeProtectedElementDataEx(targetPlayer, "phonestate", 3, false)

			killDialingTimers(from)

			contact.entryNumber = to
			triggerClientEvent(source, "phone:updateDialingScreen", source, "start_dialing_tone", contact)
			--Start ringing the phone.
			if t_ringtone > 1 and tone_volume > 0 then
				for _,nearbyPlayer in ipairs(exports.global:getNearbyElements(targetPlayer, "player"), 10) do
					triggerClientEvent(nearbyPlayer, "startRinging", targetPlayer, 1, t_ringtone, tone_volume)
				end
				--outputChatBox(contact.entryNumber)

				local displayedNumber = "#" .. displayedFrom
				if isSecret == 1 then
					displayedNumber = "Private Number"
				else
					local reverseContact = getPhoneContact(displayedFrom, realTo)
					if reverseContact then
						displayedNumber = reverseContact.entryName or displayedFrom
					end
				end

				triggerClientEvent(targetPlayer, "phone:startRingingOwner", targetPlayer, realTo, canPlayerAnswerCall(targetPlayer), isSecret == 1 and "Private" or displayedFrom, displayedNumber, displayedTo)
				if t_ringtone > 2 then
					triggerEvent('sendAme', targetPlayer, "'s cellphone starts to ring.")
				end
			end


			local timer7 = setTimer(triggerEvent, 15000, 1, "phone:cancelPhoneCall", source) --Timer to make sure ringing will be killed at all the exceptional cases server sided
			local timer8 = setTimer(triggerEvent, 15000, 1, "phone:cancelPhoneCall", targetPlayer)
			table.insert(dialingTimers[tonumber(from)], timer7)
			table.insert(dialingTimers[tonumber(contact.entryNumber)], timer8)

			exports['logs']:dbLog(source, 29, { source, "ph"..tostring(from), targetPlayer, "ph"..tostring(contact.entryNumber) }, "**Starting call - " .. (contact.entryName or contact.entryNumber) .. "**")
			return true

		end
	end
	return false
end
addEvent("phone:startDialing", true)
addEventHandler("phone:startDialing", root, startDialing)

function makeCall(thePlayer, commandName, phoneNumber)
	if not (phoneNumber) then
		outputChatBox("SYNTAX /" .. commandName .. " [Phone Number / Contact name]", thePlayer, 255, 194, 14)
	else
		if not canPlayerCall(thePlayer) then
			outputChatBox("You're unable to make phone call at the moment.", thePlayer, 255,0,0)
			return false
		end

		for k, v in ipairs( getElementsByType( "colshape", resourceRoot ) ) do
			if isElementWithinColShape( thePlayer, v ) then
				callSomeone(thePlayer, commandName, phoneNumber, -1)
				return
			end
		end

		local hasCellphone, itemKey, itemValue, itemID = exports.global:hasItem(thePlayer, 2)
		if itemValue then
			triggerClientEvent(thePlayer, "phone:slidePhoneIn", thePlayer, itemValue, nil, phoneNumber)
			--triggerEvent("phone:startDialing", thePlayer, phoneNumber, itemValue )
		else
			outputChatBox("You don't have a phone.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("call", makeCall)


function makeFCall(thePlayer, commandName, from, to)
	from = tonumber(from)
	to = tonumber(to)

	if from and to then
		local owningPlayer, realNumber = resolveVirtualPhoneNumber(from)
		if owningPlayer == thePlayer then
			if not canPlayerCall(thePlayer) then
				outputChatBox("You're unable to make phone call at the moment.", thePlayer, 255,0,0)
			else
				triggerClientEvent(thePlayer, "phone:slidePhoneIn", thePlayer, realNumber, nil, to)
				triggerEvent("phone:startDialing", thePlayer, to, from)
			end
		else
			outputChatBox("SYNTAX /" .. commandName .. " [Your Number] [Phone Number]", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox("SYNTAX /" .. commandName .. " [Your Number] [Phone Number]", thePlayer, 255, 194, 14)
	end
end
addCommandHandler("fcall", makeFCall)


--[[
phonestate = 1 / caller, started dialing
phonestate = 2 / caller, started dialing and target is ringing.
phonestate = 3 / called, is being rang
phonestate = 4 / caller, connected.
phonestate = 5 / called, connected.
]]
function cancelPhoneCall(reason)
	local col = getElementData(source, "call.col")
	local caller2col  = nil
	local phonestate = getElementData(source, "phonestate") or 0
	outputDebugString("[Phone] "..getPlayerName(source).." triggered cancelPhoneCall / "..(reason and reason or "").." / "..phonestate)
	local caller1 = source
	local caller2 = nil

	local caller1No = tonumber(getElementData(caller1, "callingwith"))
	local caller2No = tonumber(getElementData(caller1, "calling"))

	local caller1Called = getElementData(caller1, "called")
	local caller2Called = nil

	local caller1Phonestate = phonestate
	local caller2Phonestate = 0

	if caller1No then
		killDialingTimers(caller1No)
	end
	if caller2No then
		killDialingTimers(caller2No)
	end

	if col then
		outputChatBox("You hung up.", caller1, 155, 155, 255)
		setElementData(source, "cellphoneGUIStateSynced", 0)
	end

	if caller2No then
		local found, caller = searchForPhone(caller2No)
		if found and tonumber(getElementData(caller, "calling")) == tonumber(caller1No) then
			caller2 = caller
			caller2Called = getElementData(caller2, "called")
			caller2Phonestate = getElementData(caller2, "phonestate")
			caller2col = getElementData(caller2, "call.col")
		end
	end

	if caller2col then
		outputChatBox("They hung up.", caller2, 155, 155, 255)
		setElementData(caller2, "cellphoneGUIStateSynced", 0)
	end

	if caller1Called then
		writeCellphoneLogToClient(caller1)
		resetPhoneState(caller1)
		if caller1Phonestate == 3 then
			triggerClientEvent("stopRinging", caller1)
		elseif caller1Phonestate == 5 then
			triggerClientEvent(caller1, "phone:updateDialingScreen", caller1, isQuitType(reason) and reason or "called, answered but they canceled")
		end

		if caller2 then
			writeCellphoneLogToClient(caller2)
			resetPhoneState(caller2)
			if caller2Phonestate == 1 then
				if reason then
					local timer = setTimer(triggerClientEvent, 5000,1 ,caller2, "phone:updateDialingScreen", caller2, reason)
					table.insert(dialingTimers[tonumber(caller2No)], timer)
				else
					triggerClientEvent(caller2, "phone:updateDialingScreen", caller2, isQuitType(reason) and reason or "caller, started dialing but canceled")
				end
			elseif caller2Phonestate == 2 then
				triggerClientEvent(caller2, "phone:updateDialingScreen", caller2, isQuitType(reason) and reason or "caller, started dialing and target is ringing. but canceled")
			elseif caller2Phonestate == 4 then
				triggerClientEvent(caller2, "phone:updateDialingScreen", caller2, isQuitType(reason) and reason or "called, answered but they canceled")
			end
		end
	else
		writeCellphoneLogToClient(caller1)
		resetPhoneState(caller1)
		if caller1Phonestate == 1 then
			if reason then
				local timer = setTimer(triggerClientEvent, 5000,1 ,caller1, "phone:updateDialingScreen", caller1, reason)
				table.insert(dialingTimers[tonumber(caller1No)], timer)
			else
				triggerClientEvent(caller1, "phone:updateDialingScreen", caller1, isQuitType(reason) and reason or "caller, started dialing but canceled")
			end
		elseif caller1Phonestate == 2 then
			triggerClientEvent(caller1, "phone:updateDialingScreen", caller1, isQuitType(reason) and reason or "caller, started dialing and target is ringing. but canceled")
		elseif caller1Phonestate == 4 then
			triggerClientEvent(caller1, "phone:updateDialingScreen", caller1, isQuitType(reason) and reason or "called, answered but they canceled")
		end

		if caller2 then
			writeCellphoneLogToClient(caller2)
			resetPhoneState(caller2)
			if caller2Phonestate == 3 then
				triggerClientEvent("stopRinging", caller2)
			elseif caller2Phonestate == 4 or caller2Phonestate == 5 then
				triggerClientEvent(caller2, "phone:updateDialingScreen", caller2, isQuitType(reason) and reason or "called, answered but they canceled")
			end
		end
	end

	return true
end
addEvent("phone:cancelPhoneCall", true)
addEventHandler("phone:cancelPhoneCall", root, cancelPhoneCall)
addEventHandler("accounts:characters:change", root, cancelPhoneCall)
addEventHandler("onPlayerQuit", root, cancelPhoneCall)

function acceptPhoneCall()
	if not canPlayerAnswerCall(source) then
		outputChatBox("You can not use cellphone at the moment.", source, 255,0,0)
		triggerClientEvent("stopRinging", source)
		return false
	end
	local phonestate = getElementData(source, "phonestate") or 0
	if phonestate ~= 3 then
		outputChatBox("You phone is not ringing.", source, 255,0,0)
		triggerClientEvent("stopRinging", source)
		return false
	end

	triggerClientEvent("stopRinging", source)

	local calledNo = tonumber(getElementData(source, "callingwith"))
	local callerNo = tonumber(getElementData(source, "calling"))
	killDialingTimers(calledNo)
	killDialingTimers(callerNo)
	triggerClientEvent(source,"phone:slidePhoneIn", source, calledNo, true)
	local found, caller = searchForPhone(callerNo)
	if not getElementData(caller, "call.col") then
		triggerClientEvent(caller, "phone:updateDialingScreen", caller, "connected", getElementData(caller,"callingContact"))
	else
		outputChatBox("They picked up the phone.", caller, 155, 155, 255)
	end
	exports.anticheat:changeProtectedElementDataEx(caller, "phonestate", 4, false)
	exports.anticheat:changeProtectedElementDataEx(source, "phonestate", 5, false)
	updatePhoneHistoryState(calledNo, 3)
	writeCellphoneLog(caller, source, "Calls", nil, true )
	return true
end
addEvent("phone:acceptPhoneCall", true)
addEventHandler("phone:acceptPhoneCall", root, acceptPhoneCall)


function takeCallCost(cost, fromNumber, duration)
	if cost > 0 then
		if exports.bank:takeBankMoney(source, cost) then
			local foundFaction = nil
			for _, faction in pairs(getElementsByType("team")) do
				--outputDebugString(tonumber(getElementData(faction, "id")) )
				if tonumber(getElementData(faction, "id")) == 20 then --LSN
					foundFaction = faction
					break
				end
			end

			if not foundFaction then
				outputDebugString ("phone / takeCallCost / didn't find the faction from id ")
				return false
			end

			if exports.global:giveMoney(foundFaction, cost) then
				return exports.bank:addBankTransactionLog(getElementData(source, "dbid"), -20, cost, 2, "Cellphone's phone call fee", "Call made from #"..fromNumber..", duration: "..duration, nil, nil)
			end
		end
	end
	return false
end
addEvent("phone:takeCallCost", true)
addEventHandler("phone:takeCallCost", root, takeCallCost)


function loudSpeaker(thePlayer, commandName)
	local logged = getElementData(thePlayer, "loggedin")

	if (logged==1) then
		if (exports.global:hasItem(thePlayer, 2)) or getElementData(thePlayer, "call.col") then -- 2 = Cell phone item
			local phonestate = getElementData(thePlayer, "phonestate") or 0
			if phonestate == 4 or phonestate == 5 then
				local loudspeaker = getElementData(thePlayer, "call.loudspeaker")
				if (not loudspeaker) then
					triggerEvent('sendAme', thePlayer, "turns on loudspeaker on the phone.")
					outputChatBox("You flick your phone onto loudspeaker.", thePlayer)
					exports.anticheat:changeProtectedElementDataEx(thePlayer, "call.loudspeaker", true, false)
				else
					triggerEvent('sendAme', thePlayer, "turns off loudspeaker on the phone.")
					outputChatBox("You flick your phone off of loudspeaker.", thePlayer)
					exports.anticheat:changeProtectedElementDataEx(thePlayer, "call.loudspeaker", false, false)
				end
			end
		end
	end
end
addCommandHandler("loudspeaker", loudSpeaker)
addEvent('phone:loudspeaker', true)
addEventHandler('phone:loudspeaker', root, loudSpeaker)

--- filter people by vehicles with window states
function sendLocalText(sender, message, r, g, b, distance, exclude, useFocusColors, ignoreDeaths)
	local senderVehicle = getPedOccupiedVehicle(sender)
	exclude = exclude or {}

	if senderVehicle and exports.vehicle:isVehicleWindowUp(senderVehicle) then
		-- you're in a vehicle with windows up
		local nearbyPlayers = exports.global:getNearbyElements(sender, 'player', distance or 20)
		for _, player in ipairs(nearbyPlayers) do
			if getPedOccupiedVehicle(player) ~= senderVehicle then
				exclude[player] = true
			end
		end
	elseif not senderVehicle then
		-- you're not in a vehicle
		local nearbyPlayers = exports.global:getNearbyElements(sender, 'player', distance or 20)
		for _, player in ipairs(nearbyPlayers) do
			local playerVehicle = getPedOccupiedVehicle(player)
			if playerVehicle and exports.vehicle:isVehicleWindowUp(playerVehicle) then
				exclude[player] = true
			end
		end
	end

	exports.global:sendLocalText(sender, message, r, g, b, distance, exclude, useFocusColors, ignoreDeaths)
end

function talkPhone(thePlayer, commandName, ...)
	local affected = { }
	local logged = getElementData(thePlayer, "loggedin")

	if logged ~= 1 then
		return
	end

	if not exports.global:hasItem(thePlayer, 2) and not getElementData(thePlayer, "call.col") then
		outputChatBox("Believe it or not, it's hard to use a cellphone you do not have.", thePlayer, 255, 0, 0)
		return
	end

	if not (...) then
		outputChatBox("SYNTAX: /p [Message]", thePlayer, 255, 194, 14)
		return
	end

	if getElementData(thePlayer, "injuriedanimation")  then
		outputChatBox("You can't use your phone while knocked out.", thePlayer, 255, 0, 0)
		return
	end
		
	local phoneState = getElementData(thePlayer, "phonestate")
	if not (phoneState == 4 or phoneState == 5) then
		outputChatBox("You are not on a call.", thePlayer, 255, 0, 0)
		return
	end

	local message = table.concat({...}, " ")
	local username = getPlayerName(thePlayer):gsub("_", " ")
	local languageslot = getElementData(thePlayer, "languages.current") or 1
	local language = getElementData(thePlayer, "languages.lang" .. languageslot)
	local languagename = call(getResourceFromName("language-system"), "getLanguageName", language)
	local callingNumber = getElementData(thePlayer, "calling")
	local callingNumberWith = getElementData(thePlayer, "callingwith")

	table.insert(affected, thePlayer)
	table.insert(affected, "ph"..tostring(callingNumberWith))
	local found, target = searchForPhone(callingNumber)
	if not (found and target and isElement(target) and (getElementData(target, "loggedin") == 1)) and not isNumberAHotline(callingNumber) then
		triggerEvent("phone:cancelPhoneCall", found or target)
		return
	end

	table.insert(affected, target)
	table.insert(affected, "ph"..tostring(callingNumber))

	message = call( getResourceFromName( "chat-system" ), "trunklateText", thePlayer, message )
	local theVehicle = getPedOccupiedVehicle(thePlayer)
	distance = 40
	local callprogress = getElementData(thePlayer, "callprogress")
	if (callprogress) then
		triggerEvent("phone:applyPhone", thePlayer, "phone_talk")
		-- Send it to nearby players of the speaker
		if commandName == "plow" then
			distance = 5
			if not theVehicle or not exports.vehicle:isVehicleWindowUp(theVehicle) then
				exports.global:sendLocalText(thePlayer, "[" .. languagename .. "] " .. username .. " whispers [Phone]: " .. message, nil, nil, nil, 3, {[thePlayer] = true})
			end	
			outputChatBox("[" .. languagename .. "] " .. username .. " whispers [Phone]: " .. message, thePlayer, 200, 255, 200)
			triggerEvent("sendAme", thePlayer, "whispers into their phone.") 
		else
			if not theVehicle or not exports.vehicle:isVehicleWindowUp(theVehicle) then
				exports.global:sendLocalText(thePlayer, username .. " [Phone]: " .. message, nil, nil, nil, 10, {[thePlayer] = true})
			end	
			outputChatBox("[" .. languagename .. "] " .. username .. " [Phone]: " ..message, thePlayer, 200, 255, 200)
		end

		if isNumberAHotline(callingNumber) then
			writeCellphoneLog(thePlayer, nil, "Calls", message )
			exports.logs:dbLog(thePlayer, 29, affected, "[" .. languagename .. "] " ..message)
			handleEasyHotlines({ element = thePlayer, phone = tonumber(callingNumberWith), called = tonumber(callingNumber)}, tonumber(callingNumber), false, message)
			return
		end
	end

	local translatedMessage = call(getResourceFromName("language-system"), "applyLanguage", thePlayer, target, call( getResourceFromName( "chat-system" ), "trunklateText", target, message ), language)
	if commandName == "plow" then
		outputChatBox("[" .. languagename .. "] " .. username .. " whispers [Phone]: " .. translatedMessage, target)
		outputChatBox("[" .. languagename .. "] " .. username .. " whispers [Phone]: " ..message, thePlayer)
		if not theVehicle or not exports.vehicle:isVehicleWindowUp(theVehicle) then
			sendLocalText(thePlayer, "[" .. languagename .. "] " .. username .. " whispers [Phone]: " .. translatedMessage, nil, nil, nil, 3, {[thePlayer] = true})
		end	
		triggerEvent("sendAme", thePlayer, "whispers into their phone.")
	else
		outputChatBox("[" .. languagename .. "] " .. username .. " [Phone]: " .. translatedMessage, target, 200, 255, 200)
		outputChatBox("[" .. languagename .. "] " .. username .. " [Phone]: " ..message, thePlayer, 200, 255, 200)
		if not theVehicle or not exports.vehicle:isVehicleWindowUp(theVehicle) then
			sendLocalText(thePlayer, "[" .. languagename .. "] " .. username .. " [Phone]: " .. translatedMessage, nil, nil, nil, 10, {[thePlayer] = true})
		end	
	end
	triggerEvent("phone:applyPhone", target, "phone_talk")
	-- Send the message to the person on the other end of the line
	triggerEvent("phone:applyPhone", thePlayer, "phone_talk")
	-- Send it to nearby players of the speaker

	local loudspeaker = getElementData(target, "call.loudspeaker")
	-- Send it to the listener, if they have loud speaker
	if (loudspeaker) then -- Loudspeaker
		local x, y, z = getElementPosition(target)
		local username = exports.global:getPlayerName(target)
		local pveh = getPedOccupiedVehicle(target)
		for index, nearbyPlayer in ipairs(getElementsByType("player")) do
			if isElement(nearbyPlayer) and nearbyPlayer ~= target and getDistanceBetweenPoints3D(x, y, z, getElementPosition(nearbyPlayer)) < distance and getElementDimension(nearbyPlayer) == getElementDimension(target) then

				if pveh then
					if (exports.vehicle:isVehicleWindowUp(pveh)) then
						local affectedElements = {}
						for i = 0, getVehicleMaxPassengers(pveh) do
							local lp = getVehicleOccupant(pveh, i)

							if (lp) and (lp~=source) then
								outputChatBox(" [" .. languagename .. "] " .. username .. " ((In Car)) says: " .. translatedMessage, lp)
								table.insert(affectedElements, lp)
								--icChatsToVoice(lp, translatedMessage, source)
							end
						end
						table.insert(affectedElements, pveh)
						exports.logs:dbLog(source, 7, affectedElements, languagename..": INCAR ".. message)
						exports['freecam-tv']:add(affectedElements)
						break
					else
						local translatedMessage = call(getResourceFromName("language-system"), "applyLanguage", thePlayer, nearbyPlayer, call( getResourceFromName( "chat-system" ), "trunklateText", target, message ), language)
						outputChatBox("[" .. languagename .. "] " .. username .. "'s Cellphone Loudspeaker: " .. translatedMessage, nearbyPlayer)
						table.insert(affected, nearbyPlayer)
					end
				else
					local translatedMessage = call(getResourceFromName("language-system"), "applyLanguage", thePlayer, nearbyPlayer, call( getResourceFromName( "chat-system" ), "trunklateText", target, message ), language)
					outputChatBox("[" .. languagename .. "] " .. username .. "'s Cellphone Loudspeaker: " .. translatedMessage, nearbyPlayer)
					table.insert(affected, nearbyPlayer)
				end
			end
		end
	end
	writeCellphoneLog(thePlayer, target, "Calls", message )
	exports['logs']:dbLog(thePlayer, 29, affected, "[" .. languagename .. "] " ..message)
end
addCommandHandler("p", talkPhone)
addCommandHandler("plow", talkPhone)





--Functions
function getPhoneContact(clue, fromPhone)
	if not clue or string.len(clue) < 1 or not fromPhone or string.len(fromPhone) < 1 then return false end

	local result = mysql:query_fetch_assoc("SELECT * FROM `phone_contacts` WHERE `entryName`='" .. exports.mysql:escape_string(tostring(clue)) .. "' OR `entryNumber`='" .. exports.mysql:escape_string(tostring(clue)) .. "' AND `phone`='" .. exports.mysql:escape_string(tostring(fromPhone)) .."' LIMIT 1")
	if not result then
		return false
	end
	return result
end

function killDialingTimers(phone)
	phone = tonumber(phone)
	if dialingTimers[phone] then
		for i, timer in pairs(dialingTimers[phone]) do
			if isTimer(timer) then
				if killTimer(timer) then
					timer = nil
					outputDebugString("[Phone] killDialingTimers killed.")
				end
			end
		end
	else
		dialingTimers[phone] = {}
	end
end

function resetPhoneState(thePlayer)
	exports.anticheat:changeProtectedElementDataEx(thePlayer, "callingwith", nil, false)
	exports.anticheat:changeProtectedElementDataEx(thePlayer, "calling", nil, false)
	exports.anticheat:changeProtectedElementDataEx(thePlayer, "called", nil, false)
	exports.anticheat:changeProtectedElementDataEx(thePlayer, "phonestate", nil, false)
	exports.anticheat:changeProtectedElementDataEx(thePlayer, "calltimer", nil, false)
	exports.anticheat:changeProtectedElementDataEx(thePlayer, "callingContact", nil, false)

	exports.anticheat:changeProtectedElementDataEx(thePlayer, "call.col", nil, false)
	exports.anticheat:changeProtectedElementDataEx(thePlayer, "callprogress", false)
	exports.anticheat:changeProtectedElementDataEx(thePlayer, "call.situation", false)
	exports.anticheat:changeProtectedElementDataEx(thePlayer, "call.location", false)
	exports.anticheat:changeProtectedElementDataEx(thePlayer, "call.loudspeaker", false)
end

function playerQuit()
	local callingNumber = getElementData(source, "calling")
	if callingNumber then
		triggerEvent("phone:calledCancelCall", source)
	end
end
addEventHandler("onPlayerQuit", root, playerQuit)

function outputChange(dataName,oldValue)
	if getElementType(source) == "player" and dataName == "phonestate"  then -- check if the element is a player
		local newValue = getElementData(source,dataName) -- find the new value
		outputDebugString("[Phone] "..getPlayerName(source).."'s "..tostring(dataName).."' has changed from '"..tostring(oldValue).."' to '"..tostring(newValue).."'") -- output the change for the affected player
	end
end
--addEventHandler("onElementDataChange",getRootElement(),outputChange)
