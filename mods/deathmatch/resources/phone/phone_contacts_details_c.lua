--MAXIME

function openContactDetails(name, number, yoffset)
	if isPhoneGUICreated() then
		if not yoffset then yoffset = 0 end
		local theContact2 = nil
		for _, contact in pairs(contactList[phone]) do
			if contact.entryName == name and contact.entryNumber == number then
				theContact2 = contact
				break
			end
		end
		if not theContact2 then
			return false
		end
		toggleOffEverything()

		local posY = 100+yoffset
		local margin = 30
		local lineH, lineW = margin, 50
		local lineW2 = 150

		local function onClientGUIFocus_editbox()
			if source == fName_contact_details or source == fNumber_contact_details or source == fEmail_contact_details or source == fAddress_contact_details then
				guiSetInputEnabled(true)
			end
		end
		 
		local function onClientGUIBlur_editbox()
			if source == fName_contact_details or source == fNumber_contact_details or source == fEmail_contact_details or source == fAddress_contact_details then
				guiSetInputEnabled(false)
			end
		end

		lName_contact_details = guiCreateLabel(margin,posY,lineW,20, "Name:", false, wPhoneMenu)
		fName_contact_details = guiCreateEdit(30+lineW,100+yoffset,lineW2,20, theContact2.entryName or "", false, wPhoneMenu)
		guiEditSetMaxLength(fName_contact_details, 50)
		addEventHandler("onClientGUIFocus", fName_contact_details, onClientGUIFocus_editbox, true)
		addEventHandler("onClientGUIBlur", fName_contact_details, onClientGUIBlur_editbox, true)
		posY = posY + lineH

		lNumber_contact_details = guiCreateLabel(margin,posY,lineW,20, "Number:", false, wPhoneMenu)
		fNumber_contact_details = guiCreateEdit(30+lineW,posY,lineW2,20, theContact2.entryNumber or "", false, wPhoneMenu)
		guiEditSetMaxLength(fNumber_contact_details, 20)
		addEventHandler("onClientGUIFocus", fNumber_contact_details, onClientGUIFocus_editbox, true)
		addEventHandler("onClientGUIBlur", fNumber_contact_details, onClientGUIBlur_editbox, true)
		posY = posY + lineH

		lEmail_contact_details = guiCreateLabel(margin,posY,lineW,20, "Email:", false, wPhoneMenu)
		fEmail_contact_details = guiCreateEdit(margin+lineW,posY,lineW2,20, theContact2.entryEmail or "", false, wPhoneMenu)
		guiEditSetMaxLength(fEmail_contact_details, 60)
		addEventHandler("onClientGUIFocus", fEmail_contact_details, onClientGUIFocus_editbox, true)
		addEventHandler("onClientGUIBlur", fEmail_contact_details, onClientGUIBlur_editbox, true)
		posY = posY + lineH

		lAddress_contact_details = guiCreateLabel(margin,posY,lineW,20, "Address:", false, wPhoneMenu)
		fAddress_contact_details = guiCreateEdit(margin+lineW,posY,lineW2,20, theContact2.entryEmail or "", false, wPhoneMenu)
		guiEditSetMaxLength(fEmail_contact_details, 100)
		addEventHandler("onClientGUIFocus", fAddress_contact_details, onClientGUIFocus_editbox, true)
		addEventHandler("onClientGUIBlur", fAddress_contact_details, onClientGUIBlur_editbox, true)
		posY = posY + lineH

		lFavo_contact_details = guiCreateLabel(margin,posY,lineW,20, "Favorite:", false, wPhoneMenu)
		fFavo_contact_details = guiCreateCheckBox ( margin+lineW,posY,20,20, "", tonumber(theContact2.entryFavorited) == 1 , false, wPhoneMenu)
		
		local bW, bH = 100, 30
		bUpdate_contact_details = guiCreateButton(margin+bW,posY,bW,bH, "Update", false, wPhoneMenu)
		guiSetEnabled(bUpdate_contact_details, false)
		posY = posY + lineH
		
		bCall1_contact_details = guiCreateButton(margin,posY,bW,bH, "Call", false, wPhoneMenu)
		bSMS_contact_details = guiCreateButton(margin+bW+2,posY,bW,bH, "Send Message", false, wPhoneMenu)
		--guiSetEnabled(bSMS_contact_details, false)
		posY = posY + bH + 2

		bDelete_contact_details = guiCreateButton(margin,posY,bW,bH, "Delete", false, wPhoneMenu)
		bCancel2_contact_details = guiCreateButton(margin+bW+2,posY,bW,bH, "Cancel", false, wPhoneMenu)
		posY = posY + bH + 2
		

		--Validation
		addEventHandler("onClientGUIChanged", resourceRoot, function() 
			if source == fName_contact_details or source== fNumber_contact_details or source == fEmail_contact_details or source == fAddress_contact_details then
				local textName = guiGetText(fName_contact_details)
				local textNumber = guiGetText(fNumber_contact_details)
			   	guiSetEnabled(bUpdate_contact_details, validateContactNameAndNumber(textName, textNumber, theContact2.id))
			end
		end)
		
		addEventHandler("onClientGUIClick", fFavo_contact_details, function()
			local textName = guiGetText(fName_contact_details)
			local textNumber = guiGetText(fNumber_contact_details)
			guiSetEnabled(bUpdate_contact_details, validateContactNameAndNumber(textName, textNumber, theContact2.id))
		end, false)

		addEventHandler("onClientGUIClick", bUpdate_contact_details, function()
			local textName = guiGetText(fName_contact_details)
			local textNumber = guiGetText(fNumber_contact_details)
			local textEmail = guiGetText(fEmail_contact_details)
			local textAddress = guiGetText(fAddress_contact_details)
			local favorited = guiCheckBoxGetSelected(fFavo_contact_details) and 1 or 0
			if isPhoneGUICreated() then
				guiSetEnabled(wPhoneMenu, false)
			end
			triggerServerEvent("phone:contacts:details:update", localPlayer, theContact2.id, textName, textNumber,textAddress, textAddress, favorited)
		end, false)
		addEventHandler("onClientGUIClick", bDelete_contact_details, function()
			if isPhoneGUICreated() then
				guiSetEnabled(wPhoneMenu, false)
			end
			triggerServerEvent("phone:contacts:details:delete", localPlayer, theContact2.id)
		end, false)

		addEventHandler("onClientGUIClick", bCall1_contact_details, function()
			startDialing(phone,theContact2.entryNumber)
		end, false)

		

		addEventHandler("onClientGUIClick", bCancel2_contact_details, function()
			if isPhoneGUICreated() then
				closeContactDetails()
				openPhoneContacts(contactList[phone])
			end
		end, false)

		addEventHandler("onClientGUIClick", bSMS_contact_details, function()
			if isPhoneGUICreated() then
				toggleOffEverything()
				drawOneSMSThread(theContact2.entryNumber, nil)
			end
		end, false)
	end
end

function closeContactDetails()
	if isPhoneGUICreated() then
		if lName_contact_details and isElement (lName_contact_details) then
			destroyElement(lName_contact_details)
			destroyElement(fName_contact_details)
			destroyElement(lNumber_contact_details)
			destroyElement(fNumber_contact_details)
			destroyElement(lEmail_contact_details)
			destroyElement(fEmail_contact_details)
			destroyElement(lAddress_contact_details)
			destroyElement(fAddress_contact_details)
			destroyElement(bCall1_contact_details)
			destroyElement(bSMS_contact_details)
			destroyElement(bUpdate_contact_details)
			destroyElement(bDelete_contact_details)
			destroyElement(bCancel2_contact_details)
			destroyElement(lFavo_contact_details)
			destroyElement(fFavo_contact_details)
		end
	end
end

function contactDetailsUpdateResponse(id, name, number, email, address, favo)
	if id then
		if updateClientContactList("update", id, name, number, email, address, favo) then
			--outputDebugString(id)
			openPhoneContacts(contactList[phone])
		end
	end
	if isPhoneGUICreated() then
		guiSetEnabled(wPhoneMenu, true)
	end
end
addEvent("phone:contacts:details:update:response", true)
addEventHandler("phone:contacts:details:update:response", root, contactDetailsUpdateResponse)

function contactDetailsDeleteResponse(id)
	if id then
		if updateClientContactList("delete", id) then
			openPhoneContacts(contactList[phone])
		end
	end
	if isPhoneGUICreated() then
		guiSetEnabled(wPhoneMenu, true)
	end
end
addEvent("phone:contacts:details:delete:response", true)
addEventHandler("phone:contacts:details:delete:response", root, contactDetailsDeleteResponse)