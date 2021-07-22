--MAXIME

mysql = exports.mysql
local phoneO = { }

MTAoutputChatBox = outputChatBox
function outputChatBox( text, visibleTo, r, g, b, colorCoded )
	if string.len(text) > 128 then -- MTA Chatbox size limit
		MTAoutputChatBox( string.sub(text, 1, 127), visibleTo, r, g, b, colorCoded  )
		outputChatBox( string.sub(text, 128), visibleTo, r, g, b, colorCoded  )
	else
		MTAoutputChatBox( text, visibleTo, r, g, b, colorCoded  )
	end
end

function getPhoneSettings(phone, doNotCreateNew) --powerOn, ringtone, isSecret, isInPhonebook, boughtById, boughtByName, boughtDate, sms_tone, tone_volume
	-- is this a virtual phone?
	local player, realNumber = resolveVirtualPhoneNumber(phone)
	if player and realNumber then
		return getPhoneSettings(realNumber, doNotCreateNew)
	end

	local callerphoneIsSecretNumber = 0
	local callerphoneIsTurnedOn = 1
	local callerphoneRingTone = 1
	local callerphonePhoneBook = 1
	local callerphoneBoughtBy = -1
	local callerphoneBoughtByName = "N/A"
	local callerphoneBoughtDate = "N/A"
	local sms_tone = 1
	local keypress_tone = 1
	local tone_volume = 10
	local phoneSettings = mysql:query_fetch_assoc("SELECT *, `charactername`, DATE_FORMAT(`bought_date`,'%b %d %Y %h:%i %p') AS `bought_date` FROM `phones` LEFT JOIN `characters` ON `phones`.`boughtby` = `characters`.`id` WHERE `phonenumber`='"..mysql:escape_string(tostring(phone)).."' LIMIT 1")
	if not phoneSettings then
		if doNotCreateNew then
			return false
		else
			mysql:query_free("INSERT INTO `phones` SET `phonenumber`='"..exports.global:toSQL(phone).."'   ")
		end
	else
		callerphoneIsSecretNumber = tonumber(phoneSettings["secretnumber"]) or 0
		callerphoneIsTurnedOn = tonumber(phoneSettings["turnedon"]) or 1
		callerphoneRingTone =  tonumber(phoneSettings["ringtone"]) or 1
		callerphonePhoneBook =  tonumber(phoneSettings["phonebook"]) or 1
		callerphoneBoughtBy =  tonumber(phoneSettings["boughtby"]) or -1
		callerphoneBoughtByName = phoneSettings["charactername"] or "Unknown"
		callerphoneBoughtDate = phoneSettings["bought_date"] or "Unknown"
		sms_tone = tonumber(phoneSettings["sms_tone"]) or 1
		keypress_tone = tonumber(phoneSettings["keypress_tone"]) or 1
		tone_volume = tonumber(phoneSettings['tone_volume']) or 10
	end
	return callerphoneIsTurnedOn, callerphoneRingTone, callerphoneIsSecretNumber, callerphonePhoneBook, callerphoneBoughtById, callerphoneBoughtByName, callerphoneBoughtDate, sms_tone, keypress_tone, tone_volume
end

function initiatePhoneGUI(phone, popOutOnPhoneCall)
	if not phone or not tonumber(phone) or string.len(phone) < 5 then
		triggerClientEvent(source, "phone:slidePhoneOut", source)
		return false
	end
	if popOutOnPhoneCall then
		if tonumber(popOutOnPhoneCall) then
			popOutOnPhoneCall = tonumber(popOutOnPhoneCall)
		else
			popOutOnPhoneCall = "popOutOnPhoneCall"
		end
	end
	triggerClientEvent(source, "phone:updatePhoneGUI", source, popOutOnPhoneCall or "initiate", {phone, getPhoneSettings(phone)})

	phone = tonumber(phone)
	local hasPhone, slot, itemValue, itemIndex, metadata = exports.global:hasItem(source, 2, phone)
	local phoneName
	if metadata then
		phoneName = exports['item-system']:getItemName(2, phone, metadata)
	end
	triggerEvent("phone:applyPhone", source, "phone_in", nil, phoneName)
	return true
end
addEvent("phone:initiatePhoneGUI", true)
addEventHandler("phone:initiatePhoneGUI", root, initiatePhoneGUI)

function powerOn(phone, state)
	if not phone or not tonumber(phone) or string.len(phone) < 5 then
		triggerClientEvent(source, "phone:powerOn:response", source, false, state)
		return false
	end
	return triggerClientEvent(source, "phone:powerOn:response", source, mysql:query_free("UPDATE `phones` SET `turnedon`='"..state.."' WHERE `phonenumber`='"..mysql:escape_string(tostring(phone)).."'"), state)
end
addEvent("phone:powerOn", true)
addEventHandler("phone:powerOn", root, powerOn)

function applyPhone(string, popOutOnPhoneCall, itemName)
	itemName = itemName or "cellphone"
	if not canPlayerCall(source) and string ~= "phone_out" then
		--return false
	end
	local phonestate = getElementData(source, "phonestate") or 0
	outputDebugString("[Phone] applyPhone / phonestate = "..phonestate.. " / action = "..string)
	if string == "phone_in" then
		--outputDebugString("[Phone] "..getPlayerName(source).." / phone_in")
		triggerEvent('sendAme', source, "takes out " .. (getElementData(source, "gender") == 0 and "his" or "her") .. " " .. itemName .. ".")
		if getElementData(source, "phone_anim") ~= "0" then
			if not isElement(phoneO[source]) then
				phoneO[source] = createObject(330, 0, 0, 0)
			end
			setElementDimension(phoneO[source], getElementDimension(source))
			setElementInterior(phoneO[source], getElementInterior(source))
			exports.bone_attach:attachElementToBone(phoneO[source], source, 12, -0.05, 0.02, 0.02, 20, -90, -10)

			setPedAnimation(source, "ped", string, 1, false)
			setPedWeaponSlot(source, 0)

			--[[
			toggleControl( source, "fire", false)
			toggleControl( source, "next_weapon", false )
			toggleControl( source, "previous_weapon", false)
			toggleControl (source,  "aim_weapon", false )
			]]
		else
			if isElement(phoneO[source]) then
				destroyPhone(source)
			end
		end
		if getElementData(source, "cellphoneGUIStateSynced") ~= 1 then
			--exports.anticheat:changeProtectedElementDataEx(source, "cellphoneGUIStateSynced", 1 , true)
		end
		exports.anticheat:changeProtectedElementDataEx(source, "cellphoneGUIStateSynced", 1 , true)
	elseif string == "phone_talk" then
		--outputDebugString("[Phone] "..getPlayerName(source).." / phone_talk")
		if getElementData(source, "phone_anim") ~= "0" then
			if not isElement(phoneO[source]) then
				phoneO[source] = createObject(330, 0, 0, 0)
			end
			setElementDimension(phoneO[source], getElementDimension(source))
			setElementInterior(phoneO[source], getElementInterior(source))

			exports.bone_attach:attachElementToBone(phoneO[element], source, 12, -0.05, 0.02, 0.02, 20, -90, -10)
			setPedAnimation(source, "ped", string, 1, false)
			setPedWeaponSlot(source, 0)

			--[[
			toggleControl( source, "fire", false)
			toggleControl( source, "next_weapon", false )
			toggleControl( source, "previous_weapon", false)
			toggleControl ( source, "aim_weapon", false )
			]]
		else
			if isElement(phoneO[source]) then
				destroyPhone(source)
			end
		end
		if getElementData(source, "cellphoneGUIStateSynced") ~= 1 then
			--exports.anticheat:changeProtectedElementDataEx(source, "cellphoneGUIStateSynced", 1 , true)
		end
		exports.anticheat:changeProtectedElementDataEx(source, "cellphoneGUIStateSynced", 1 , true)
	elseif string == "phone_out" then
		--outputDebugString("[Phone] "..getPlayerName(source).." / phone_out")
		if phonestate > 0 and not popOutOnPhoneCall then
			triggerEvent("phone:cancelPhoneCall", source)
		end
		--resetPhoneState(source)
		if getElementData(source, "cellphoneGUIStateSynced") then
			if not popOutOnPhoneCall then
				triggerEvent('sendAme', source, "puts down "..(getElementData(source, "gender") == 0 and "his" or "her").." " .. itemName .. ".")
			end
			if getElementData(source, "phone_anim") ~= "0" then
				setPedAnimation(source, "ped", string, 1, false)
			end
		end
		exports.anticheat:changeProtectedElementDataEx(source, "cellphoneGUIStateSynced", nil , true)
		if isElement(phoneO[source]) then
			setTimer(destroyPhone, 2000, 1, source)
		end
		--[[
		toggleControl( source, "fire", true)
		toggleControl( source, "next_weapon", true )
		toggleControl( source, "previous_weapon", true)
		toggleControl ( source, "aim_weapon", true )
		]]
		setPedWeaponSlot(source, 0)
	end
end
addEvent("phone:applyPhone", true)
addEventHandler("phone:applyPhone", root, applyPhone)

function destroyPhone(element)
	if canPlayerCall(element) then
		exports.global:removeAnimation(element)
	end
	if isElement(phoneO[element]) then
		exports.bone_attach:detachElementFromBone(phoneO[element])
		destroyElement(phoneO[element])
		phoneO[element] = nil
	end
end

function callSomeone(thePlayer, commandName, phoneNumber, withNumber)
	local logged = getElementData(thePlayer, "loggedin")
	if logged ~= 1 then
		return
	end

	withNumber = tonumber(withNumber)
	local outboundPhoneNumber = -1
	local publicphone = nil
	for k, v in pairs( getElementsByType( "colshape", getResourceRootElement( ) ) ) do
		if isElementWithinColShape( thePlayer, v ) then
			for kx, vx in pairs( getElementsByType( "player" ) ) do
				if getElementData( vx, "call.col" ) == v then
					outputChatBox( "Someone else is already using this phone.", thePlayer, 255, 0, 0 )
					return
				end
			end
			publicphone = v
			break
		end
	end

	-- Determine the outbound number, -1 is secret
	if publicphone then
		outboundPhoneNumber = math.random(51111510, 58111510)
	elseif withNumber and withNumber > 10 then
		if exports.global:hasItem(thePlayer, 2, tonumber(withNumber))  then
			outboundPhoneNumber = tonumber(withNumber)
		else
			local fPhone = getElementData(thePlayer, "factionphone")
			if fPhone then
				for k,v in pairs(getElementData(thePlayer, "faction")) do
					local factionPhone = getElementData(exports.factions:getFactionFromID(k), "phone")
					if factionPhone then
						num = string.format("%02d%02d", factionPhone, fPhone)
						if tostring(withNumber) == num then
							outboundPhoneNumber = tonumber(withNumber)
							break
						end
					end
				end
			end
		end
	end

	if not outboundPhoneNumber or outboundPhoneNumber == -1 then
		outputChatBox("Believe it or not, it's hard to dial on a cellphone you do not have.", thePlayer, 255, 0, 0)
		return
	end

	if not (phoneNumber) then
		outputChatBox("Press 'i' and click the phone you want to use, please.", thePlayer)
		return
		--requestPhoneGUI(1, thePlayer)
	end

	if not tonumber(phoneNumber) then
		local result = mysql:query_fetch_assoc("SELECT entryNumber FROM phone_contacts WHERE entryName='" .. exports.mysql:escape_string(tostring(phoneNumber)) .. "' AND phone='" .. exports.mysql:escape_string(tostring(outboundPhoneNumber)) .."' LIMIT 1")
		if result then
			numberName = phoneNumber
			phoneNumber = tonumber(result["entryNumber"])
		else
			outputChatBox("Couldn't find a number/number for the contact name specified.", thePlayer, 255, 0, 0)
			return
		end
	end

	if not tonumber(phoneNumber) then
		outputChatBox("Invalid phonenumber.", thePlayer)
		return
	end

	local callerphoneIsSecretNumber = 1
	local callerphoneIsTurnedOn = 1
	local callerphoneRingTone = 1
	local callerphonePhoneBook = 1
	local callerphoneBoughtBy = -1

	if not publicphone then
		local testNumber = tostring(outboundPhoneNumber)
		if #testNumber == 4 then
			testNumber = fetchFirstPhoneNumber(thePlayer)
		end

		local phoneSettings = mysql:query_fetch_assoc("SELECT * FROM `phones` WHERE `phonenumber`='"..mysql:escape_string(tostring(testNumber)).."'")
		if not phoneSettings then
			mysql:query_free("INSERT INTO `phones` (`phonenumber`) VALUES ('".. mysql:escape_string(tostring(testNumber)) .."')")
			callerphoneIsSecretNumber = 0
			callerphoneIsTurnedOn = 1
			callerphoneRingTone = 1
			callerphonePhoneBook = 1
			callerphoneBoughtBy = -1
		else
			callerphoneIsSecretNumber = tonumber(phoneSettings["secretnumber"]) or 0
			callerphoneIsTurnedOn = tonumber(phoneSettings["turnedon"]) or 1
			callerphoneRingTone =  tonumber(phoneSettings["ringtone"]) or 1
			callerphonePhoneBook =  tonumber(phoneSettings["phonebook"]) or 1
			callerphoneBoughtBy =  tonumber(phoneSettings["boughtby"]) or -1
		end
	end

	if callerphoneIsTurnedOn == 0 then
		outputChatBox("Your phone is off.", thePlayer, 255, 0, 0)
	else
		local calling = getElementData(thePlayer, "calling")

		if (calling) then -- Using phone already
			outputChatBox("You are already using a phone.", thePlayer, 255, 0, 0)
		elseif getElementData(thePlayer, "injuriedanimation") then
			outputChatBox("You can't use your phone while knocked out.", thePlayer, 255, 0, 0)
		else
			-- /me it
			if publicphone then
				triggerEvent('sendAme', thePlayer, "reaches for the public phone.")
			end

			-- If the number is a hotline aka automated machine, then..
			if isNumberAHotline(phoneNumber) then
				exports.anticheat:changeProtectedElementDataEx(thePlayer, "call.col", publicphone, false)
				exports.anticheat:changeProtectedElementDataEx(thePlayer, "phonestate", 4, false) -- changed from 1 to 4
				exports.anticheat:changeProtectedElementDataEx(thePlayer, "calling", phoneNumber, false)
				exports.anticheat:changeProtectedElementDataEx(thePlayer, "callingwith", outboundPhoneNumber, false)
				handleEasyHotlines({ element = thePlayer, phone = tonumber(outboundPhoneNumber), called = tonumber(phoneNumber)}, tonumber(phoneNumber), true, "")
				--applyPhone(thePlayer, 1, "phone_talk")

			-- Otherwise find a fool to answer it
			else
				-- Search for the phone
				local found, foundElement = searchForPhone(phoneNumber)

				-- Some basic checks.
				-- Can we afford it?
				local bankMoney = getElementData(thePlayer, "bankmoney") -- done by Anthony to take money from bank instead
				if bankMoney >= 1 then
					if not exports.donators:hasPlayerPerk(thePlayer, 6) and not exports.anticheat:changeProtectedElementDataEx(thePlayer, "bankmoney", tonumber(bankMoney) - 1, false) then
						outputChatBox("You cannot afford a call.", thePlayer, 255, 0, 0)
						return
					end
				else
					outputChatBox("You cannot afford a call.", thePlayer, 255, 0, 0)
					return
				end

				-- Yes, Is the target phone online or found at all?
				if not found then
					outputChatBox("You get a dead tone...", thePlayer, 255, 194, 14)
					return
				end

				local from = outboundPhoneNumber
				local displayedFrom = outboundPhoneNumber
				local to = phoneNumber
				local contact = getPhoneContact(to, from)
				if not contact then
					if not tonumber(to) then
						return false
					end
					contact = { ["entryNumber"] = to }
				end
				local displayedTo = contact.entryNumber
				local _, realTo = resolveVirtualPhoneNumber(contact.entryNumber)
				realTo = realTo or contact.entryNumber

				exports.anticheat:changeProtectedElementDataEx(thePlayer, "callingContact", contact, false)

				local t_powerOn, t_ringtone, t_isSecret, t_isInPhonebook, t_boughtBy, boughtByName, boughtDate, sms_tone, tone_volume = getPhoneSettings(phoneNumber, true)
				if not t_powerOn then --not existed
					outputChatBox("You get a dead tone...", thePlayer, 255, 194, 14)
					addPhoneHistory(displayedFrom, displayedTo, 2, isSecret)
					return false
				elseif t_powerOn ~= 1 then --turned off
					outputChatBox("You get a dead tone...", thePlayer, 255, 194, 14)
					addPhoneHistory(displayedFrom, displayedTo, 2, isSecret)
					return false
				else
					local foundInGame, targetPlayer = searchForPhone(to)
					if not foundInGame then
						outputChatBox("You get a dead tone...", thePlayer, 255, 194, 14)
						addPhoneHistory(displayedFrom, displayedTo, 2, isSecret)
						return false
					else
						if not canPlayerPhoneRing(targetPlayer) then
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
						exports.anticheat:changeProtectedElementDataEx(thePlayer, "call.col", publicphone, false)
						exports.anticheat:changeProtectedElementDataEx(thePlayer, "payphone.number", outboundPhoneNumber, false)
						exports.anticheat:changeProtectedElementDataEx(thePlayer, "calling", tonumber(realTo), false)
						exports.anticheat:changeProtectedElementDataEx(thePlayer, "callingwith", tonumber(outboundPhoneNumber), false)
						exports.anticheat:changeProtectedElementDataEx(targetPlayer, "calling", tonumber(outboundPhoneNumber), false)
						exports.anticheat:changeProtectedElementDataEx(targetPlayer, "callingwith", tonumber(realTo), false)
						exports.anticheat:changeProtectedElementDataEx(thePlayer, "called", false, false)
						exports.anticheat:changeProtectedElementDataEx(targetPlayer, "called", true, false)
						exports.anticheat:changeProtectedElementDataEx(thePlayer, "phonestate", 2, false)
						exports.anticheat:changeProtectedElementDataEx(targetPlayer, "phonestate", 3, false)

						killDialingTimers(from)

						contact.entryNumber = to
						--Start ringing the phone.
						if t_ringtone > 1 and tone_volume > 0 then
							for _,nearbyPlayer in ipairs(exports.global:getNearbyElements(targetPlayer, "player"), 10) do
								triggerClientEvent(nearbyPlayer, "startRinging", targetPlayer, 1, t_ringtone, tone_volume)
							end

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
						addDialingTimer(from, timer7)
						addDialingTimer(contact.entryNumber, timer8)

						exports['logs']:dbLog(source, 29, { source, "ph"..tostring(from), targetPlayer, "ph"..tostring(contact.entryNumber) }, "**Starting call - " .. (contact.entryName or contact.entryNumber) .. "**")
						return true
					end
				end
			end
		end
	end
end

function cancelCall(phoneNumbers)
	for _, phoneNumber in ipairs(phoneNumbers) do
		local found, foundElement = searchForPhone(phoneNumber)
		if found and foundElement and isElement(foundElement) then
			local phoneState = getElementData(foundElement, "phonestate")

			if (phoneState==0) then
				exports.anticheat:changeProtectedElementDataEx(foundElement, "calling", nil, false)
				exports.anticheat:changeProtectedElementDataEx(foundElement, "called", nil, false)
				exports.anticheat:changeProtectedElementDataEx(foundElement, "call.col", nil, false)
			end
		end
	end
end
--[[
function answerPhone(thePlayer, commandName)
	local logged = getElementData(thePlayer, "loggedin")

	if (logged==1) then
		if (exports.global:hasItem(thePlayer, 2)) then
			local phoneState = getElementData(thePlayer, "phonestate")
			local calling = getElementData(thePlayer, "calling")

			if getElementData(thePlayer, "called") then
				outputChatBox("You're the one calling someone else, smart-ass.", thePlayer, 255, 0, 0)
			elseif (calling) then
				if isPedDead(thePlayer) then
					outputChatBox("You're unable to make phone call at the moment.", thePlayer, 255,0,0)
					return false
				end

				if (phoneState==0) then
					local found, foundElement = searchForPhone(calling)
					--local target = calling
					outputChatBox("You picked up the phone. (( /p to talk ))", thePlayer)
					if not found then
						outputChatBox("You can't hear anything on the other side of the line", thePlayer)
						executeCommandHandler( "hangup", thePlayer )
					else
						outputChatBox("They picked up the phone.", foundElement)
						triggerEvent('sendAme', thePlayer, "takes out a cell phone.")
						exports.anticheat:changeProtectedElementDataEx(thePlayer, "phonestate", 1, false)
						exports.anticheat:changeProtectedElementDataEx(foundElement, "phonestate", 1, false)
						exports.anticheat:changeProtectedElementDataEx(foundElement, "called", nil, false)
						triggerEvent('sendAme', thePlayer, "answers their cellphone.")


						--applyPhone(thePlayer, 2, "phone_talk")

						if getElementData(foundElement, "forcedanimation")~=1 and tonumber(getElementData(foundElement, "phone_anim"))==1 then
							setPedAnimation(foundElement, "ped", "phone_talk", 1, false)
						end

						local ownPhoneNo = getElementData(foundElement, "calling")
						exports['logs']:dbLog(thePlayer, 29, { thePlayer, "ph"..tostring(ownPhoneNo), foundElement, "ph"..tostring(calling) }, "**Picked up phone**")
					end

					triggerClientEvent("stopRinging", thePlayer)
				end
			elseif not (calling) then
				outputChatBox("Your phone is not ringing.", thePlayer, 255, 0, 0)
			elseif (phoneState==1) or (phoneState==2) then
				outputChatBox("Your phone is already in use.", thePlayer, 255, 0, 0)
			end
		else
			outputChatBox("Believe it or not, it's hard to use a cellphone you do not have.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("pickup", answerPhone)
]]

addEventHandler("savePlayer", root,
	function(reason)
		if reason == "Change Character" then
			triggerEvent("phone:cancelPhoneCall", source)
		end
	end)


addEventHandler( "onColShapeLeave", getResourceRootElement(),
	function( thePlayer )
		if getElementData( thePlayer, "call.col" ) == source then
			executeCommandHandler( "hangup", thePlayer )
		end
	end
)
addEventHandler( "onPlayerQuit", getRootElement(),
	function( )
		local calling = getElementData( source, "calling" )
		if isElement( calling ) then
			executeCommandHandler( "hangup", source )
		end
	end
)


function phoneBook(thePlayer, commandName, partialNick)
	local logged = getElementData(thePlayer, "loggedin")

	if (logged==1) then
		if (exports.global:hasItem(thePlayer, 7)) then
			if not (partialNick) then
				outputChatBox("SYNTAX: /phonebook [Partial Subscriber Name / Number]", thePlayer, 255, 194, 14)
			else
				triggerEvent('sendAme', thePlayer, "looks into their phonebook.")
				local result = mysql:query("SELECT `charactername`, `phonenumber` FROM `phones` LEFT JOIN `characters` ON `phones`.`boughtby`=`characters`.`id` WHERE `phonebook`=1 AND (`charactername` LIKE '%" .. mysql:escape_string(partialNick) .. "%' OR `phonenumber` LIKE '%" .. mysql:escape_string(partialNick) .. "%') AND `secretnumber` = 0 AND `boughtby` > 0 LIMIT 20")
				if (mysql:num_rows(result)>10) then
					outputChatBox("Too many results.", thePlayer, 255, 194, 14)
				elseif (mysql:num_rows(result)>0) then
					local continue = true
					while true do
						local row = mysql:fetch_assoc(result)
						if not row then break end
						local phoneNumber = tonumber(row["phonenumber"])
						local username = tostring(row["charactername"]):gsub("_", " ")

						outputChatBox(username .. " - #" .. phoneNumber .. ".", thePlayer)
					end
				else
					outputChatBox("You find no one with that name.", thePlayer, 255, 194, 14)
				end
				mysql:free_result(result)
			end
		else
			outputChatBox("Believe it or not, it's hard to use a phonebook you do not have.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("phonebook", phoneBook)

function togglePhone(thePlayer, commandName, phoneNumber)
	local logged = getElementData(thePlayer, "loggedin")

	if logged == 1 then
		if not phoneNumber then
			local foundPhone,_,foundPhoneNumber = exports.global:hasItem(thePlayer, 2)
			if foundPhone and foundPhoneNumber then
				phoneNumber = foundPhoneNumber
			end
		elseif tonumber(phoneNumber) < 10 then
			local count = 0
			local items = exports['item-system']:getItems(thePlayer)
			for k, v in ipairs(items) do
				if v[1] == 2 then
					count = count + 1
					if count == phoneNumber then
						phoneNumber = v[2]
						break
					end
				end
			end
		else
			if not (exports.global:hasItem(thePlayer, 2, tonumber(phoneNumber))) then
				outputChatBox("You don't own this phone number", thePlayer, 255, 0, 0)
				return
			end
		end
		local calledphoneIsTurnedOn = 0
		local phoneSettings = mysql:query_fetch_assoc("SELECT * FROM `phones` WHERE `phonenumber`='"..mysql:escape_string(tostring(phoneNumber)).."'")
		if not phoneSettings then
			mysql:query_free("INSERT INTO `phones` (`phonenumber`) VALUES ('".. mysql:escape_string(tostring(phoneNumber)) .."')")
		else
			calledphoneIsTurnedOn = tonumber(phoneSettings["turnedon"]) or 0
		end
		if getElementData( thePlayer, "calling" ) then
			outputChatBox("You are using your phone!", thePlayer, 255, 0, 0)
		else
			if calledphoneIsTurnedOn == 0 then
				outputChatBox("You switched your phone with number '"..tostring(phoneNumber).."' on.", thePlayer, 0, 255, 0)
			else
				outputChatBox("You switched your phone with number '"..tostring(phoneNumber).."' off.", thePlayer, 255, 0, 0)
			end
			mysql:query_free( "UPDATE `phones` SET `turnedon`='"..( 1 - calledphoneIsTurnedOn ) .."' WHERE `phonenumber`='".. mysql:escape_string(tostring(phoneNumber)) .."'")
		end
	end
end
addCommandHandler("togglephone", togglePhone)

function setPhoneBook(thePlayer, commandName, phoneNumber, ...)
	local logged = getElementData(thePlayer, "loggedin")

	if logged == 1 then
		if not phoneNumber then
			outputChatBox("Usage: /" .. commandName .. " [phone no.] [text to be found under via /phonebook]", thePlayer, 255, 194, 14)
			return
		end

		if tonumber(phoneNumber) < 10 then
			local count = 0
			local items = exports['item-system']:getItems(thePlayer)
			for k, v in ipairs(items) do
				if v[1] == 2 then
					count = count + 1
					if count == phoneNumber then
						phoneNumber = v[2]
						break
					end
				end
			end
		else
			if not (exports.global:hasItem(thePlayer, 2, tonumber(phoneNumber))) then
				outputChatBox("You don't own this phone number", thePlayer, 255, 0, 0)
				return
			end
		end

		local phoneSettings = mysql:query_fetch_assoc("SELECT * FROM `phones` WHERE `phonenumber`='"..mysql:escape_string(tostring(phoneNumber)).."'")
		if not phoneSettings then
			mysql:query_free("INSERT INTO `phones` (`phonenumber`) VALUES ('".. mysql:escape_string(tostring(phoneNumber)) .."')")
		end

		local name = (...) and table.concat({...}, " ") or nil
		local success = false
		if name then
			name = name:sub(1, 40)
			success = mysql:query_free( "UPDATE `phones` SET `phonebook`='"..mysql:escape_string(name) .."' WHERE `phonenumber`='".. mysql:escape_string(tostring(phoneNumber)) .."'")
			outputChatBox("You've set your phonebook entry to '" .. name .. "'.", thePlayer, 0, 255, 0)
		else
			success = mysql:query_free( "UPDATE `phones` SET `phonebook`=NULL WHERE `phonenumber`='".. mysql:escape_string(tostring(phoneNumber)) .."'")
			outputChatBox("You've removed your phonebook entry.", thePlayer, 0, 255, 0)
		end
	end
end
addCommandHandler("setphonebook", setPhoneBook)
addCommandHandler("setphonebookname", setPhoneBook)
addCommandHandler("setpbname", setPhoneBook)

function searchForPhone(phoneNumber)
	phoneNumber = tonumber(phoneNumber)
	if phoneNumber then
		if phoneNumber >= 10000 then
			for key, value in ipairs(exports.pool:getPoolElementsByType("player")) do
				local logged = getElementData(value, "loggedin")
				if (logged==1) then
					-- Check the new system way, phoneNumber in value
					local foundPhone,_,foundPhoneNumber = exports.global:hasItem(value, 2, tonumber(phoneNumber))
					if foundPhone then
						return true, value
					end

					if getElementData(value, "payphone.number") == tonumber(phoneNumber) then
						return true, value
					end
				end
			end
		else
			local player = resolveVirtualPhoneNumber(phoneNumber)
			if player then
				return true, player
			end
		end
	end
	return false, nil
end

--- Resolves a virtual phone number to a real phone.
-- @param phoneNumber
-- @returns player, realphonenumber
function resolveVirtualPhoneNumber(phoneNumber)
	phoneNumber = tonumber(phoneNumber)
	if phoneNumber >= 1000 and phoneNumber < 10000 then
		-- faction phone
		local globalFactionPhones = exports.factions:getAllFactionPhoneNumbers()
		for _, player in ipairs(exports.pool:getPoolElementsByType("player")) do
			local foundPhone,_,foundPhoneNumber =  exports.global:hasItem(player, 2)
			for k, v in pairs(getElementData(player, "faction") or {}) do
				if globalFactionPhones[k] and foundPhone and v.phone then
					local num = string.format("%02d%02d", globalFactionPhones[k], v.phone)
					if tostring(phoneNumber) == tostring(num) then
						return player, foundPhoneNumber
					end
				end
			end
		end
	end
	return nil
end

function fetchFirstPhoneNumber(target)
	local foundPhone,_,foundPhoneNumber = exports.global:hasItem(target, 2, tonumber(phoneNumber))
	return foundPhoneNumber
end

function setEDX(thePlayer, index, newvalue, sync, nosyncatall)
	return exports.anticheat:changeProtectedElementDataEx(thePlayer, index, newvalue, sync, nosyncatall)
end

function cleanUp()
	for i, player in pairs(getElementsByType("player")) do
		cleanUpOnePlayer(player)
	end
end
addEventHandler("onResourceStop", resourceRoot, cleanUp)

function cleanUpOnePlayer(player)
	--if source then player = source end
	resetPhoneState(player)
	exports.anticheat:changeProtectedElementDataEx(player, "cellphoneGUIStateSynced", nil, true)
end
--addEventHandler("accounts:characters:change", root, cleanUpOnePlayer)

addEventHandler("onPlayerWasted", root, 
function()
    if getElementData(source, "phonestate") == 4 or getElementData(source, "phonestate") == 5 then
        triggerEvent("phone:cancelPhoneCall", source)
    end
end)
