--MAXIME
addEvent("phone:requestShowPhoneGUI", true)
function requestPhoneGUI(itemValue, newSource)
	--[[
	if newSource then
		client = newSource
	end

	local contactList = { }
	local ownCellnumber = tonumber (itemValue)

	if not ownCellnumber or ownCellnumber < 10 then
		return
	end
	
	local phoneSettings = mysql:query_fetch_assoc("SELECT * FROM `phone_settings` WHERE `phonenumber`='"..mysql:escape_string(tostring(ownCellnumber)).."'")
	if not phoneSettings then
		mysql:query_free("INSERT INTO `phone_settings` (`phonenumber`) VALUES ('".. mysql:escape_string(tostring(ownCellnumber)) .."')")
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
	
	if callerphoneIsTurnedOn == 0 then
		outputChatBox("You take your phone out, but notice it is turned off.", client, 255,0,0)
		outputChatBox("((/togglephone "..ownCellnumber.." to turn it on))", client, 255,0,0)
		return
	end
	
	local mQuery1 = mysql:query("SELECT `entryName`, `entryNumber` from `phone_contacts` WHERE `phone`='".. mysql:escape_string( ownCellnumber ) .."'")
	while true do
		local row = mysql:fetch_assoc(mQuery1)
		if not row then break end
		table.insert(contactList, { row["entryName"], tostring(row["entryNumber"]) } )
	end
	mysql:free_result(mQuery1)
	triggerClientEvent(client, "phone:showPhoneGUI", client, tostring(ownCellnumber), contactList)
	]]
end
addEventHandler("phone:requestShowPhoneGUI", getRootElement(), requestPhoneGUI)
--

function getContacts(fromNumber)
	local contacts = {}
	local limit = false
	if fromNumber and tonumber(fromNumber) then
		local phoneSettings = mysql:query_fetch_assoc("SELECT * FROM `phones` WHERE `phonenumber`='"..mysql:escape_string(fromNumber).."' LIMIT 1")
		if not phoneSettings then
			mysql:query_free("INSERT INTO `phones` (`phonenumber`) VALUES ('".. mysql:escape_string(fromNumber) .."')")
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
		
		local mQuery1 = mysql:query("SELECT * from `phone_contacts` WHERE `phone`='".. mysql:escape_string( fromNumber ) .."' ORDER BY `entryName` ")
		while true do
			local row = mysql:fetch_assoc(mQuery1)
			if not row then break end
			--outputDebugString(row["entryName"])
			table.insert(contacts, row )
		end
		mysql:free_result(mQuery1)
		limit = mysql:query_fetch_assoc("SELECT `contact_limit` FROM `phones` WHERE `phonenumber`='"..mysql:escape_string(fromNumber).."' LIMIT 1")
		if limit and limit["contact_limit"] then
			limit = tonumber(limit["contact_limit"])
		end
	end
	return contacts, limit
end
function requestContacts(fromNumber)
	triggerClientEvent(source, "phone:receiveContacts", source, getContacts(fromNumber))
end
addEvent("phone:requestContacts", true)
addEventHandler("phone:requestContacts", root, requestContacts)

function forceUpdateContactList(player, fromPhone)
	if player then
		source = player
	end
	triggerClientEvent(source, "phone:forceUpdateContactList", source, getContacts(fromPhone))
end
addEvent("phone:forceUpdateContactList", true)
addEventHandler("phone:forceUpdateContactList", root, forceUpdateContactList)

--
addEvent("phone:deleteContact", true)
function deletePhoneContact(name, number, phoneBookPhone)
	if (client) then
		if not phoneBookPhone then
			return
		end
		
		if not exports.global:hasItem(client,2, tonumber(phoneBookPhone)) then
			return
		end
		if name and number then
			if tonumber(number) then
				local result = mysql:query_free("DELETE FROM `phone_contacts` WHERE `phone`='" ..  mysql:escape_string(phoneBookPhone).."' AND `entryName`='".. mysql:escape_string(name) .."' AND `entryNumber`='".. mysql:escape_string(number) .."'")
				if result then
					requestPhoneGUI(phoneBookPhone, client)
					return
				end
			end
		end
		outputChatBox("Error, please try it again.", client, 255,0,0)
	end
end
addEventHandler("phone:deleteContact", getRootElement(), deletePhoneContact)

function saveCurrentRingtone(itemValue, phoneBookPhone)
	if client and itemValue then
		if not phoneBookPhone then
			outputChatBox("one")
			return
		end
		
		if not exports.global:hasItem(client,2, tonumber(phoneBookPhone)) then
			--outputChatBox("two")
			return
		end
		
		if not tonumber(itemValue) then
			outputChatBox("three")
			return
		end

		local result = mysql:query_free("UPDATE `phones` SET `ringtone`='" ..  mysql:escape_string(itemValue).."' WHERE `phonenumber`='"..mysql:escape_string(phoneBookPhone).."'")
		if not result then
			outputChatBox("Error, please try it again.", client, 255,0,0)
			return
		end
	end
end
addEvent("saveRingtone", true)
addEventHandler("saveRingtone", getRootElement(), saveCurrentRingtone)