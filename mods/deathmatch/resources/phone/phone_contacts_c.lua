--MAXIME
function openPhoneContacts(contacts, contactListLimitFromServer)
	if contacts then
		contactList[phone] = contacts
	end

	if not contactList[phone] then
		contactList[phone] = {}
	end

	if contactListLimitFromServer then
		contactListLimit[phone] = contactListLimitFromServer
	end

	if not contactListLimit[phone] then
		contactListLimit[phone] = 10
	end

	if isPhoneGUICreated() then
		toggleOffEverything()
		togglePhoneHome(false)
		guiSetEnabled(wPhoneMenu, true)
		togglePhoneDial(true)

		gPhoneBook = guiCreateGridList(30,200,204,265,false,wPhoneMenu)
		local colName = guiGridListAddColumn(gPhoneBook,"Name",0.5)
		local colNumber = guiGridListAddColumn(gPhoneBook,"Number",0.4)
		
		local row = guiGridListAddRow(gPhoneBook)
		guiGridListSetItemText(gPhoneBook, row, colName, "New contact", false, false)
		guiGridListSetItemText(gPhoneBook, row, colNumber, #contactList[phone].."/"..contactListLimit[phone], false, false)
		
		if (contactList[phone]) then
			local favorites = {}
			local acquaintances = {}
			for _, contact in pairs(contactList[phone]) do
				if tonumber(contact.entryFavorited) == 1 then
					table.insert(favorites, contact)
				else
					table.insert(acquaintances, contact)
				end
			end

			if (#favorites > 0) then
				guiGridListSetItemText( gPhoneBook, guiGridListAddRow(gPhoneBook), colName, "Favorites", true, false )
				for i = 1, #favorites do
					local row = guiGridListAddRow(gPhoneBook)
					guiGridListSetItemText(gPhoneBook, row, colName, favorites[i].entryName, false, false)
					guiGridListSetItemText(gPhoneBook, row, colNumber, favorites[i].entryNumber, false, false)
				end
			end

			if (#acquaintances > 0) then
				if (#favorites > 0) then 
					guiGridListSetItemText( gPhoneBook, guiGridListAddRow(gPhoneBook), colName, "Acquaintances", true, false )
				end
				for i = 1, #acquaintances do
					local row = guiGridListAddRow(gPhoneBook)
					guiGridListSetItemText(gPhoneBook, row, colName, acquaintances[i].entryName, false, false)
					guiGridListSetItemText(gPhoneBook, row, colNumber, acquaintances[i].entryNumber, false, false)
				end
			end
		end

		addEventHandler( "onClientGUIClick", gPhoneBook,
			function( button )
				if button == "left" then
					local row, col = guiGridListGetSelectedItem( gPhoneBook )
					if row ~= -1 and col ~= -1 then
						local name = guiGridListGetItemText( source , row, 1 )
						local number = guiGridListGetItemText( source , row, 2 )
						if name == "New contact" then
							guiNewContact()
						else
							guiSetText(ePhoneNumber, number)
						end
					end
				end
			end,
			false
		)
		addEventHandler("onClientGUIDoubleClick", gPhoneBook, 
			function ( button )
				if button == "left" then
					local row, col = guiGridListGetSelectedItem( gPhoneBook )
					if row ~= -1 and col ~= -1 then
						local name = guiGridListGetItemText( source , row, 1 )
						local number = guiGridListGetItemText( source , row, 2 )
						if name ~= "New contact" then
							openContactDetails(name, number, 10)
						end
					end
				end
			end,
			false
		)
	end
end
addEvent("phone:receiveContacts", true)
addEventHandler("phone:receiveContacts", root, openPhoneContacts)

function togglePhoneContacts(state)
	if isPhoneGUICreated() and gPhoneBook and isElement (gPhoneBook) then
		togglePhoneDial(state)
		guiSetVisible(gPhoneBook, state)
	end
end

function updateClientContactList(action, id, name, number, email, address, favo)
	if action == "delete" then
		for i = 1, #contactList[phone] do
			if contactList[phone][i] ~= nil and (tonumber(contactList[phone][i].id) == tonumber(id)) then
				contactList[phone][i] = nil
				return true
			end
		end
	elseif action == "update" then
		for i = 1, #contactList[phone] do
			if contactList[phone][i] ~= nil and (tonumber(contactList[phone][i].id) == tonumber(id)) then
				contactList[phone][i] = {
					["id"] = id,
					["entryName"] = name,
					["entryNumber"]	= number,
					["entryEmail"] = email,
					["entryFavorited"] = favo,
				}
				return true
			end
		end
	elseif action == "insert" or action == "add" then
		local record = {
					["id"] = id,
					["entryName"] = name,
					["entryNumber"]	= number,
					["entryEmail"] = "",
					["entryFavorited"] = "0",
				}
		table.insert(contactList[phone], record)
		return true
	end
	return false
end

function getContactNameFromContactNumber(phoneNumber, fromPhone)
	local curContactList = contactList[fromPhone]
	local found = nil
	if curContactList then
		for i, contact in pairs(curContactList) do
			if tonumber(contact.entryNumber) == tonumber(phoneNumber) then
				return contact.entryName
			end
		end
	end
	return getHotlineName(phoneNumber)
end

function forceUpdateContactList(contacts, contactListLimitFromServer)
	if contacts then
		contactList[phone] = contacts
	end

	if not contactList[phone] then
		contactList[phone] = {}
	end

	if contactListLimitFromServer then
		contactListLimit[phone] = contactListLimitFromServer
	end

	if not contactListLimit[phone] then
		contactListLimit[phone] = 10
	end
end
addEvent("phone:forceUpdateContactList", true)
addEventHandler("phone:forceUpdateContactList", root, forceUpdateContactList)

