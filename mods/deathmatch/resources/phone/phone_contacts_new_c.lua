--MAXIME
local newContactFromHistory = nil
function guiNewContact(number)
	if isPhoneGUICreated() then
		if gPhoneBook and isElement(gPhoneBook) then
			guiSetEnabled(gPhoneBook, false)
		end

		if number then
			newContactFromHistory = number
		end
		togglePhoneDial(false)
		lName_contacts_new = guiCreateLabel(30,100,50,20, "Name:", false, wPhoneMenu)
		fName_contacts_new = guiCreateEdit(30+50,100,150,20, "", false, wPhoneMenu)
		guiEditSetMaxLength(fName_contacts_new, 50)

		lNumber = guiCreateLabel(30,100+30,50,20, "Number:", false, wPhoneMenu)
		fNumber_contacts_new = guiCreateEdit(30+50,100+30,150,20, number or "", false, wPhoneMenu)
		guiEditSetMaxLength(fNumber_contacts_new, 20)

		local bW, bH = 100, 35
		bAddContact = guiCreateButton(30,100+30*2,bW,bH, "Add", false, wPhoneMenu)
		guiSetEnabled(bAddContact, false)
		bCancelContact = guiCreateButton(30+bW+2,100+30*2,bW,bH, "Cancel", false, wPhoneMenu)

		local function onClientGUIFocus_editbox()
			if source == fName_contacts_new or source == fNumber_contacts_new then
				guiSetInputEnabled(true)
			end
		end
		 
		local function onClientGUIBlur_editbox()
			if source == fName_contacts_new or source == fNumber_contacts_new then
				guiSetInputEnabled(false)
			end
		end

		addEventHandler("onClientGUIFocus", fName_contacts_new, onClientGUIFocus_editbox, true)
		addEventHandler("onClientGUIBlur", fNumber_contacts_new, onClientGUIBlur_editbox, true)
		--Validation
		addEventHandler("onClientGUIChanged", resourceRoot, function() 
			if source == fName_contacts_new or source== fNumber_contacts_new then
				local textName = guiGetText(fName_contacts_new)
				local textNumber = guiGetText(fNumber_contacts_new)
			   	guiSetEnabled(bAddContact, validateContactNameAndNumber(textName, textNumber))
			end
		end)
	end
end

function guiNewContactClose()
	if lName_contacts_new and isElement(lName_contacts_new) then
		destroyElement(lName_contacts_new)
		lName_contacts_new = nil
		destroyElement(fName_contacts_new)
		fName2 = nil
		destroyElement(lNumber)
		lNumber = nil
		destroyElement(fNumber_contacts_new)
		fNumber2 = nil
		destroyElement(bAddContact)
		bAddContact = nil
		destroyElement(bCancelContact)
		bCancelContact = nil
		guiSetEnabled( wPhoneMenu, true )
	end
end

function addContactResponse(id, name, number)
	if id then
		toggleOffEverything()
		if updateClientContactList("insert", id, name, number) then
			openPhoneContacts(contactList[phone])
			if newContactFromHistory then
				newContactFromHistory = nil
				resetHistory(phone)
			end
		end
	else
		if isPhoneGUICreated() then
			guiSetEnabled(wPhoneMenu,true)
		end
	end
end
addEvent("phone:addContactResponse", true)
addEventHandler("phone:addContactResponse", root, addContactResponse)