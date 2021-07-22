-- by anumaz
-- for owlgaming 2015-03-04

-- This is the main window GUI.
main = {
    button = {},
    window = {},
    staticimage = {},
    label = {}
}
function mainGUI()
	-- to prevent double
	if isElement(main.window[1]) then return false end

	-- to center the gui window
	local screenX, screenY = guiGetScreenSize()
	local width = 482
	local height = 329
	local x = ( screenX - width ) / 2
	local y = ( screenY - height ) / 2

	-- parameters
	local isFAA, rankFAA = exports.factions:isPlayerInFaction(getLocalPlayer(), 47)
	local isLeader = exports.factions:hasMemberPermissionTo(getLocalPlayer(), 47, "add_member")
	local fullname = string.gsub(getPlayerName(getLocalPlayer()), "_", " ")
	local clearance = "(guest)"
	if isFAA then clearance = "(staff)"	end
	if isLeader then clearance = "(admin)" end

	-- building the gui
	main.window[1] = guiCreateWindow(x, y, width, height, "http://faa.gov", false)
	guiWindowSetSizable(main.window[1], false)

	main.staticimage[1] = guiCreateStaticImage(0.02, 0.08, 0.17, 0.21, ":sfia/faadevice/faalogo.png", true, main.window[1])
	main.label[1] = guiCreateLabel(0.20, 0.11, 0.40, 0.12, "Federal Aviation Administration\nSan Andreas region", true, main.window[1])
	guiSetFont(main.label[1], "default-bold-small")
	main.label[2] = guiCreateLabel(0.62, 0.11, 0.45, 0.19, "You have logged in as:\n"..fullname.." "..clearance, true, main.window[1])
	guiLabelSetHorizontalAlign(main.label[2], "left", true)
	main.label[3] = guiCreateLabel(0.00, 0.30, 1.11, 0.11, "__________________________________________________________________________________________________", true, main.window[1])
	main.label[4] = guiCreateLabel(0.02, 0.43, 0.47, 0.07, "Here are your options:", true, main.window[1])

	main.button[1] = guiCreateButton(-1, 31, 88, 44, "", false, main.label[4])
	guiSetProperty(main.button[1], "NormalTextColour", "FFAAAAAA")

	main.button[2] = guiCreateButton(0.02, 0.52, 0.25, 0.12, "Consult Landing Areas", true, main.window[1])
	guiSetProperty(main.button[2], "NormalTextColour", "FFAAAAAA")
	main.button[3] = guiCreateButton(0.30, 0.52, 0.25, 0.12, "Manage Landing Areas", true, main.window[1])
	guiSetProperty(main.button[3], "NormalTextColour", "FFAAAAAA")
	main.button[4] = guiCreateButton(0.02, 0.67, 0.25, 0.12, "Submit application - Error 404", true, main.window[1])
	guiSetProperty(main.button[4], "NormalTextColour", "FFAAAAAA")
	main.button[5] = guiCreateButton(0.30, 0.67, 0.25, 0.12, "Manage applications - Error 404", true, main.window[1])
	guiSetProperty(main.button[5], "NormalTextColour", "FFAAAAAA")
	main.button[6] = guiCreateButton(0.02, 0.81, 0.25, 0.12, "Airport Map Book", true, main.window[1])
	guiSetProperty(main.button[6], "NormalTextColour", "FFAAAAAA")
	main.button[7] = guiCreateButton(0.76, 0.26, 0.22, 0.07, "Shut down", true, main.window[1])
	guiSetProperty(main.button[7], "NormalTextColour", "FFAAAAAA")
	main.button[8] = guiCreateButton(0.58, 0.52, 0.25, 0.12, "Landing Areas Map", true, main.window[1])
	guiSetProperty(main.button[3], "NormalTextColour", "FFAAAAAA")

	if not isFAA then
		guiSetVisible(main.button[3], false)
		guiSetVisible(main.button[5], false)
	end

	-- shut down / close button
	addEventHandler("onClientGUIClick", main.button[7], function ()
			if isElement(main.window[1]) then destroyElement(main.window[1]) end
		end, false)

	-- Map book button
	addEventHandler("onClientGUIClick", main.button[6], function ()
			triggerServerEvent("startFAAmapGUI", getLocalPlayer())
			if isElement(main.window[1]) then destroyElement(main.window[1]) end
		end, false)

	-- manage landing areas
	addEventHandler("onClientGUIClick", main.button[3], function ()
			landingGUI()
			if isElement(main.window[1]) then destroyElement(main.window[1]) end
		end, false)

	-- consult landing areas
	addEventHandler("onClientGUIClick", main.button[2], function ()
			consultGUI()
			if isElement(main.window[1]) then destroyElement(main.window[1]) end
		end, false)

	-- Landing Areas Map button
	addEventHandler("onClientGUIClick", main.button[8], function ()
			mapGUI()
			if isElement(main.window[1]) then destroyElement(main.window[1]) end
		end, false)

end

-- This is the GUI to manage landing areas
landing = {
    button = {},
    window = {},
    staticimage = {},
    label = {},
    gridlist = {},
    column = {}
}
function landingGUI()
	-- to prevent double
	if isElement(landing.window[1]) then return false end

	-- to center the gui window
	local screenX, screenY = guiGetScreenSize()
	local width = 482
	local height = 329
	local x = ( screenX - width ) / 2
	local y = ( screenY - height ) / 2

	-- parameters
	local isFAA, rankFAA = exports.factions:isPlayerInFaction(getLocalPlayer(), 47)
	local isLeader = exports.factions:hasMemberPermissionTo(getLocalPlayer(), 47, "add_member")
	local fullname = string.gsub(getPlayerName(getLocalPlayer()), "_", " ")
	local clearance = "(guest)"
	if isFAA then clearance = "(staff)"	end
	if isLeader then clearance = "(admin)" end

	-- building the gui
	landing.window[1] = guiCreateWindow(x, y, width, height, "http://faa.gov - Landing Areas Registry", false)
	guiWindowSetSizable(landing.window[1], false)

	landing.staticimage[1] = guiCreateStaticImage(0.02, 0.08, 0.17, 0.21, ":sfia/faadevice/faalogo.png", true, landing.window[1])
	landing.label[1] = guiCreateLabel(0.20, 0.11, 0.40, 0.12, "Federal Aviation Administration\nSan Andreas region", true, landing.window[1])
	guiSetFont(landing.label[1], "default-bold-small")
	landing.label[2] = guiCreateLabel(0.62, 0.11, 0.45, 0.19, "You have logged in as:\n"..fullname.." "..clearance, true, landing.window[1])
	guiLabelSetHorizontalAlign(landing.label[2], "left", true)
	landing.label[3] = guiCreateLabel(0.00, 0.30, 1.11, 0.11, "__________________________________________________________________________________________________", true, landing.window[1])
	landing.button[1] = guiCreateButton(0.87, 0.26, 0.11, 0.07, "Close", true, landing.window[1])
	guiSetProperty(landing.button[1], "NormalTextColour", "FFAAAAAA")
	landing.button[3] = guiCreateButton(0.76, 0.26, 0.11, 0.07, "Back", true, landing.window[1])
	guiSetProperty(landing.button[3], "NormalTextColour", "FFAAAAAA")
	if isFAA then
		landing.button[2] = guiCreateButton(0.54, 0.26, 0.22, 0.07, "Add entry", true, landing.window[1])
		guiSetProperty(landing.button[2], "NormalTextColour", "FFAAAAAA")
	end

	landing.gridlist[1] = guiCreateGridList(0.00, 0.35, 0.98, 1, true, landing.window[1])
	guiGridListSetSortingEnabled(landing.gridlist[1], false)
	landing.column[1] = guiGridListAddColumn(landing.gridlist[1], "Code", 0.3)
	landing.column[2] = guiGridListAddColumn(landing.gridlist[1], "Ownership", 0.3)
	landing.column[3] = guiGridListAddColumn(landing.gridlist[1], "Condition", 0.3)

	-- filling the gridlist
	local t = getElementData(resourceRoot, "faa:registrytable")
	for k,v in pairs(t) do
		local row = guiGridListAddRow(landing.gridlist[1])
		guiGridListSetItemText( landing.gridlist[1], row, landing.column[1], k, false, false)
		guiGridListSetItemText( landing.gridlist[1], row, landing.column[2], v["owner"] or "None", false, false)
		guiGridListSetItemText( landing.gridlist[1], row, landing.column[3], v["condition"] or "None", false, false)
	end

	-- close button shut down
	addEventHandler("onClientGUIClick", landing.button[1], function ()
			if isElement(landing.window[1]) then destroyElement(landing.window[1]) end
		end, false)

	-- the 'add entry' button
	addEventHandler("onClientGUIClick", landing.button[2], function ()
			addNewLandingEntry()
			if isElement(landing.window[1]) then destroyElement(landing.window[1]) end
		end, false)

	-- the back button
	addEventHandler("onClientGUIClick", landing.button[3], function ()
			mainGUI()
			if isElement(landing.window[1]) then destroyElement(landing.window[1]) end
		end, false)

	-- double clicking a row on gridlist
	addEventHandler("onClientGUIDoubleClick", landing.gridlist[1], function ()
			local selectedRow = guiGridListGetSelectedItem(landing.gridlist[1])
			if selectedRow == -1 then return false end
			local getCode = guiGridListGetItemText(landing.gridlist[1], selectedRow, 1)
			if getCode then
				registryitemGUI(tonumber(getCode))
				if isElement(landing.window[1]) then destroyElement(landing.window[1]) end
			end
		end, false)
end



-- GUI to add a new helipad registry
landing_new = {
    button = {},
    window = {},
    staticimage = {},
    label = {},
    gridlist = {},
    column = {},
    edit = {}
}
function addNewLandingEntry()
	-- to prevent double
	if isElement(landing_new.window[1]) then return false end

	-- to center the gui window
	local screenX, screenY = guiGetScreenSize()
	local width = 482
	local height = 329
	local x = ( screenX - width ) / 2
	local y = ( screenY - height ) / 2

	-- parameters
	local isFAA, rankFAA = exports.factions:isPlayerInFaction(getLocalPlayer(), 47)
	local isLeader = exports.factions:hasMemberPermissionTo(getLocalPlayer(), 47, "add_member")
	local fullname = string.gsub(getPlayerName(getLocalPlayer()), "_", " ")
	local clearance = "(guest)"
	if isFAA then clearance = "(staff)"	end
	if isLeader then clearance = "(admin)" end

	-- disable mta keys
	guiSetInputMode("no_binds_when_editing")

	-- building the gui
	landing_new.window[1] = guiCreateWindow(x, y, width, height, "http://faa.gov - Add a new Landing Areas Registry", false)
	guiWindowSetSizable(landing_new.window[1], false)

	landing_new.staticimage[1] = guiCreateStaticImage(0.02, 0.08, 0.17, 0.21, ":sfia/faadevice/faalogo.png", true, landing_new.window[1])
	landing_new.label[1] = guiCreateLabel(0.20, 0.11, 0.40, 0.12, "Federal Aviation Administration\nSan Andreas region", true, landing_new.window[1])
	guiSetFont(landing_new.label[1], "default-bold-small")
	landing_new.label[2] = guiCreateLabel(0.62, 0.11, 0.45, 0.19, "You have logged in as:\n"..fullname.." "..clearance, true, landing_new.window[1])
	guiLabelSetHorizontalAlign(landing_new.label[2], "left", true)
	landing_new.label[3] = guiCreateLabel(0.00, 0.30, 1.11, 0.11, "__________________________________________________________________________________________________", true, landing_new.window[1])
	landing_new.button[1] = guiCreateButton(0.87, 0.26, 0.11, 0.07, "Close", true, landing_new.window[1])
	guiSetProperty(landing_new.button[1], "NormalTextColour", "FFAAAAAA")
	landing_new.button[3] = guiCreateButton(0.76, 0.26, 0.11, 0.07, "Back", true, landing_new.window[1])
	guiSetProperty(landing_new.button[3], "NormalTextColour", "FFAAAAAA")

	landing_new.label[4] = guiCreateLabel(0.05, 0.45, 0.20, 0.12, "Unique code:", true, landing_new.window[1])
	landing_new.label[5] = guiCreateLabel(0.05, 0.55, 0.20, 0.12, "Owner:", true, landing_new.window[1])
	landing_new.label[6] = guiCreateLabel(0.05, 0.65, 0.20, 0.12, "Condition:", true, landing_new.window[1])
	landing_new.label[7] = guiCreateLabel(0.05, 0.75, 0.20, 0.12, "Location:", true, landing_new.window[1])

	landing_new.edit[1] = guiCreateEdit(0.3, 0.45, 0.40, 0.10, "", true, landing_new.window[1])
	landing_new.edit[2] = guiCreateEdit(0.3, 0.55, 0.40, 0.10, "", true, landing_new.window[1])
	landing_new.edit[3] = guiCreateEdit(0.3, 0.65, 0.40, 0.10, "", true, landing_new.window[1])
	landing_new.edit[4] = guiCreateEdit(0.3, 0.75, 0.40, 0.10, "", true, landing_new.window[1])

	landing_new.button[2] = guiCreateButton(0.76, 0.56, 0.22, 0.20, "Submit", true, landing_new.window[1])
	guiSetProperty(landing_new.button[2], "NormalTextColour", "FFAAAAAA")

	-- shut down button close
	addEventHandler("onClientGUIClick", landing_new.button[1], function ()
			if isElement(landing_new.window[1]) then destroyElement(landing_new.window[1]) end
			guiSetInputMode("allow_binds")
		end, false)

	-- home button
	addEventHandler("onClientGUIClick", landing_new.button[3], function ()
			landingGUI()
			if isElement(landing_new.window[1]) then destroyElement(landing_new.window[1]) end
			guiSetInputMode("allow_binds")
		end, false)

	-- submit button
	addEventHandler("onClientGUIClick", landing_new.button[2], function ()
			local uniquecode = guiGetText(landing_new.edit[1])
			local owner = guiGetText(landing_new.edit[2])
			local condition = guiGetText(landing_new.edit[3])
			local location = guiGetText(landing_new.edit[4])

			if not tonumber(uniquecode) then
				outputChatBox("The unique code may only contain numbers.")
				return false
			end

			if string.len(owner) > 2 and string.len(condition) > 2 and string.len(location) > 3 then
				local t = getElementData(resourceRoot, "faa:registrytable")

				uniquecode = tonumber(uniquecode)

				if t[uniquecode] then
					outputChatBox("This unique code already exists.")
					return false
				end

				t[uniquecode] = {}
				t[uniquecode]["owner"] = owner
				t[uniquecode]["condition"] = condition
				t[uniquecode]["notes"] = "Initial location: "..location

				setElementData(resourceRoot, "faa:registrytable", t)
				triggerServerEvent("faa:sqlQuery", resourceRoot, uniquecode, owner, condition, location)

				landingGUI()
				if isElement(landing_new.window[1]) then destroyElement(landing_new.window[1]) end
				guiSetInputMode("allow_binds")
			end
		end, false)
end

registryitem = {
    button = {},
    window = {},
    staticimage = {},
    label = {},
    gridlist = {},
    column = {},
    memo = {}
}
function registryitemGUI(code)
	-- needs a code to open
	if not tonumber(code) then return false end
	code = tonumber(code)

	-- to prevent double
	if isElement(registryitem.window[1]) then return false end

	-- to center the gui window
	local screenX, screenY = guiGetScreenSize()
	local width = 482
	local height = 329
	local x = ( screenX - width ) / 2
	local y = ( screenY - height ) / 2

	-- parameters
	local isFAA, rankFAA = exports.factions:isPlayerInFaction(getLocalPlayer(), 47)
	local isLeader = exports.factions:hasMemberPermissionTo(getLocalPlayer(), 47, "add_member")
	local fullname = string.gsub(getPlayerName(getLocalPlayer()), "_", " ")
	local clearance = "(guest)"
	if isFAA then clearance = "(staff)"	end
	if isLeader then clearance = "(admin)" end

	-- building the gui
	registryitem.window[1] = guiCreateWindow(x, y, width, height, "http://faa.gov - Landing Areas Registry - Check: "..code, false)
	guiWindowSetSizable(registryitem.window[1], false)

	registryitem.staticimage[1] = guiCreateStaticImage(0.02, 0.08, 0.17, 0.21, ":sfia/faadevice/faalogo.png", true, registryitem.window[1])
	registryitem.label[1] = guiCreateLabel(0.20, 0.11, 0.40, 0.12, "Federal Aviation Administration\nSan Andreas region", true, registryitem.window[1])
	guiSetFont(registryitem.label[1], "default-bold-small")
	registryitem.label[2] = guiCreateLabel(0.62, 0.11, 0.45, 0.19, "You have logged in as:\n"..fullname.." "..clearance, true, registryitem.window[1])
	guiLabelSetHorizontalAlign(registryitem.label[2], "left", true)
	registryitem.label[3] = guiCreateLabel(0.00, 0.30, 1.11, 0.11, "__________________________________________________________________________________________________", true, registryitem.window[1])
	registryitem.button[1] = guiCreateButton(0.87, 0.26, 0.11, 0.07, "Close", true, registryitem.window[1])
	guiSetProperty(registryitem.button[1], "NormalTextColour", "FFAAAAAA")
	registryitem.button[3] = guiCreateButton(0.76, 0.26, 0.11, 0.07, "Back", true, registryitem.window[1])
	guiSetProperty(registryitem.button[3], "NormalTextColour", "FFAAAAAA")
	registryitem.button[2] = guiCreateButton(0.54, 0.26, 0.22, 0.07, "Edit", true, registryitem.window[1])
	guiSetProperty(registryitem.button[2], "NormalTextColour", "FFAAAAAA")
	registryitem.button[4] = guiCreateButton(0.43, 0.26, 0.11, 0.07, "Delete", true, registryitem.window[1])
	guiSetProperty(registryitem.button[2], "NormalTextColour", "FFAAAAAA")

	local t = getElementData(resourceRoot, "faa:registrytable")
	if not t[code] then
		return false
	end

	if not isFAA then
		guiSetVisible(registryitem.button[2], false)
		guiSetVisible(registryitem.button[3], false)
	end

	if not isLeader then
		guiSetVisible(registryitem.button[4], false)
	end

	registryitem.memo[1] = guiCreateMemo(0.00, 0.45, 0.98, 1, t[code]["notes"] or "None.", true, registryitem.window[1])
	guiMemoSetReadOnly(registryitem.memo[1], true)
	registryitem.label[4] = guiCreateLabel(0.05, 0.38, 0.20, 0.07, "Code: "..code, true, registryitem.window[1])
	registryitem.label[5] = guiCreateLabel(0.20, 0.38, 0.45, 0.07, "Owner: "..t[code]["owner"], true, registryitem.window[1])
	registryitem.label[6] = guiCreateLabel(0.68, 0.38, 0.40, 0.07, "Condition: "..t[code]["condition"], true, registryitem.window[1])

	-- shut down button close
	addEventHandler("onClientGUIClick", registryitem.button[1], function ()
			if isElement(registryitem.window[1]) then destroyElement(registryitem.window[1]) end
		end, false)

	-- home button
	addEventHandler("onClientGUIClick", registryitem.button[3], function ()
			landingGUI()
			if isElement(registryitem.window[1]) then destroyElement(registryitem.window[1]) end
		end, false)

	-- edit button
	addEventHandler("onClientGUIClick", registryitem.button[2], function ()
			edit_registryitemGUI(code)
			if isElement(registryitem.window[1]) then destroyElement(registryitem.window[1]) end
		end, false)

	-- delete button
	addEventHandler("onClientGUIClick", registryitem.button[4], function ()
			-- cache / element data table part
			if t[code] then
				t[code] = nil
				setElementData(resourceRoot, "faa:registrytable", t)
				--sql part
				triggerServerEvent("faa:deleteregistry", resourceRoot, tonumber(code))
			end
			if isElement(registryitem.window[1]) then destroyElement(registryitem.window[1]) end
			landingGUI()
		end, false)
end

edit_registryitem = {
    button = {},
    window = {},
    staticimage = {},
    label = {},
    gridlist = {},
    column = {},
    memo = {},
    edit = {}
}
function edit_registryitemGUI(code)
	-- needs a code to open
	if not tonumber(code) then return false end
	code = tonumber(code)

	-- to prevent double
	if isElement(edit_registryitem.window[1]) then return false end

	-- to center the gui window
	local screenX, screenY = guiGetScreenSize()
	local width = 482
	local height = 329
	local x = ( screenX - width ) / 2
	local y = ( screenY - height ) / 2

	-- parameters
	local isFAA, rankFAA = exports.factions:isPlayerInFaction(getLocalPlayer(), 47)
	local isLeader = exports.factions:hasMemberPermissionTo(getLocalPlayer(), 47, "add_member")
	local fullname = string.gsub(getPlayerName(getLocalPlayer()), "_", " ")
	local clearance = "(guest)"
	if isFAA then clearance = "(staff)"	end
	if isLeader then clearance = "(admin)" end

	-- disable mta keys
	guiSetInputMode("no_binds_when_editing")

	-- building the gui
	edit_registryitem.window[1] = guiCreateWindow(x, y, width, height, "http://faa.gov - Landing Areas Registry - Edit: "..code, false)
	guiWindowSetSizable(edit_registryitem.window[1], false)

	edit_registryitem.staticimage[1] = guiCreateStaticImage(0.02, 0.08, 0.17, 0.21, ":sfia/faadevice/faalogo.png", true, edit_registryitem.window[1])
	edit_registryitem.label[1] = guiCreateLabel(0.20, 0.11, 0.40, 0.12, "Federal Aviation Administration\nSan Andreas region", true, edit_registryitem.window[1])
	guiSetFont(edit_registryitem.label[1], "default-bold-small")
	edit_registryitem.label[2] = guiCreateLabel(0.62, 0.11, 0.45, 0.19, "You have logged in as:\n"..fullname.." "..clearance, true, edit_registryitem.window[1])
	guiLabelSetHorizontalAlign(edit_registryitem.label[2], "left", true)
	edit_registryitem.label[3] = guiCreateLabel(0.00, 0.30, 1.11, 0.11, "__________________________________________________________________________________________________", true, edit_registryitem.window[1])
	edit_registryitem.button[1] = guiCreateButton(0.87, 0.26, 0.11, 0.07, "Close", true, edit_registryitem.window[1])
	guiSetProperty(edit_registryitem.button[1], "NormalTextColour", "FFAAAAAA")
	edit_registryitem.button[3] = guiCreateButton(0.76, 0.26, 0.11, 0.07, "Back", true, edit_registryitem.window[1])
	guiSetProperty(edit_registryitem.button[3], "NormalTextColour", "FFAAAAAA")
	edit_registryitem.button[2] = guiCreateButton(0.54, 0.26, 0.22, 0.07, "Save", true, edit_registryitem.window[1])
	guiSetProperty(edit_registryitem.button[2], "NormalTextColour", "FFAAAAAA")
	edit_registryitem.button[4] = guiCreateButton(0.32, 0.26, 0.22, 0.07, "Dump Location", true, edit_registryitem.window[1])
	guiSetProperty(edit_registryitem.button[2], "NormalTextColour", "FFAAAAAA")

	local t = getElementData(resourceRoot, "faa:registrytable")
	if not t[code] then
		return false
	end

	edit_registryitem.memo[1] = guiCreateMemo(0.00, 0.55, 0.98, 1, "", true, edit_registryitem.window[1])
	edit_registryitem.label[4] = guiCreateLabel(0.05, 0.38, 0.20, 0.07, "Code: "..code, true, edit_registryitem.window[1])
	edit_registryitem.label[5] = guiCreateLabel(0.20, 0.38, 0.45, 0.07, "Owner: "..t[code]["owner"], true, edit_registryitem.window[1])
	edit_registryitem.label[6] = guiCreateLabel(0.68, 0.38, 0.40, 0.07, "Condition: "..t[code]["condition"], true, edit_registryitem.window[1])
	edit_registryitem.label[7] = guiCreateLabel(0.02, 0.50, 0.20, 0.07, "Add note", true, edit_registryitem.window[1])

	edit_registryitem.edit[1] = guiCreateEdit(0.20, 0.45, 0.45, 0.07, "", true, edit_registryitem.window[1])
	edit_registryitem.edit[2] = guiCreateEdit(0.68, 0.45, 0.20, 0.07, "", true, edit_registryitem.window[1])

	-- shut down button close
	addEventHandler("onClientGUIClick", edit_registryitem.button[1], function ()
			if isElement(edit_registryitem.window[1]) then destroyElement(edit_registryitem.window[1]) end
			guiSetInputMode("allow_binds")
		end, false)

	-- home button
	addEventHandler("onClientGUIClick", edit_registryitem.button[3], function ()
			registryitemGUI(code)
			if isElement(edit_registryitem.window[1]) then destroyElement(edit_registryitem.window[1]) end
			guiSetInputMode("allow_binds")
		end, false)

	-- save button
	addEventHandler("onClientGUIClick", edit_registryitem.button[2], function ()
			local owner = false
			local condition = false
			local note = false

			if string.len(guiGetText(edit_registryitem.edit[1])) > 2 then
				owner = guiGetText(edit_registryitem.edit[1])
			end
			if string.len(guiGetText(edit_registryitem.edit[2])) > 2 then
				condition = guiGetText(edit_registryitem.edit[2])
			end
			if string.len(guiGetText(edit_registryitem.memo[1])) > 2 then
				note = guiGetText(edit_registryitem.memo[1])
			end

			local t = getElementData(resourceRoot, "faa:registrytable")
			t[code]["owner"] = owner or t[code]["owner"]
			t[code]["condition"] = condition or t[code]["condition"]
			setElementData(resourceRoot, "faa:registrytable", t)

			triggerServerEvent("faa:editregistry", resourceRoot, code, t[code]["owner"] , t[code]["condition"] , note, getLocalPlayer())

			if isElement(edit_registryitem.window[1]) then destroyElement(edit_registryitem.window[1]) end
			guiSetInputMode("allow_binds")
			setTimer( function ()
				registryitemGUI(code)
			end, 100, 1)
		end, false)

	-- dump location button
	addEventHandler("onClientGUIClick", edit_registryitem.button[4], function ()
			local x, y = getElementPosition( getLocalPlayer() )
			t[code]["x"] = x
			t[code]["y"] = y
			setElementData(resourceRoot, "faa:registrytable", t)

			-- sql
			triggerServerEvent("faa:addCoordinates", resourceRoot, code, x, y)

			registryitemGUI(code)
			if isElement(edit_registryitem.window[1]) then destroyElement(edit_registryitem.window[1]) end
			guiSetInputMode("allow_binds")
		end, false)
end

consult = {
    button = {},
    window = {},
    staticimage = {},
    label = {},
    gridlist = {},
    column = {},
    memo = {},
    edit = {}
}
function consultGUI()
	-- to prevent double
	if isElement(consult.window[1]) then return false end

	-- to center the gui window
	local screenX, screenY = guiGetScreenSize()
	local width = 482
	local height = 329
	local x = ( screenX - width ) / 2
	local y = ( screenY - height ) / 2

	-- parameters
	local isFAA, rankFAA = exports.factions:isPlayerInFaction(getLocalPlayer(), 47)
	local isLeader = exports.factions:hasMemberPermissionTo(getLocalPlayer(), 47, "add_member")
	local fullname = string.gsub(getPlayerName(getLocalPlayer()), "_", " ")
	local clearance = "(guest)"
	if isFAA then clearance = "(staff)"	end
	if isLeader then clearance = "(admin)" end

	-- disable mta keys
	guiSetInputMode("no_binds_when_editing")

	-- building the gui
	consult.window[1] = guiCreateWindow(x, y, width, height, "http://faa.gov - Landing Areas Registry - Consult", false)
	guiWindowSetSizable(consult.window[1], false)

	consult.staticimage[1] = guiCreateStaticImage(0.02, 0.08, 0.17, 0.21, ":sfia/faadevice/faalogo.png", true, consult.window[1])
	consult.label[1] = guiCreateLabel(0.20, 0.11, 0.40, 0.12, "Federal Aviation Administration\nSan Andreas region", true, consult.window[1])
	guiSetFont(consult.label[1], "default-bold-small")
	consult.label[2] = guiCreateLabel(0.62, 0.11, 0.45, 0.19, "You have logged in as:\n"..fullname.." "..clearance, true, consult.window[1])
	guiLabelSetHorizontalAlign(consult.label[2], "left", true)
	consult.label[3] = guiCreateLabel(0.00, 0.30, 1.11, 0.11, "__________________________________________________________________________________________________", true, consult.window[1])
	consult.button[1] = guiCreateButton(0.87, 0.26, 0.11, 0.07, "Close", true, consult.window[1])
	guiSetProperty(consult.button[1], "NormalTextColour", "FFAAAAAA")
	consult.button[3] = guiCreateButton(0.76, 0.26, 0.11, 0.07, "Back", true, consult.window[1])
	guiSetProperty(consult.button[3], "NormalTextColour", "FFAAAAAA")
	consult.button[2] = guiCreateButton(0.40, 0.55, 0.20, 0.1, "Submit", true, consult.window[1])
	guiSetProperty(consult.button[2], "NormalTextColour", "FFAAAAAA")

	local t = getElementData(resourceRoot, "faa:registrytable")

	consult.label[4] = guiCreateLabel(0.1, 0.38, 1, 0.07, "Please input the landing area unique code. It consists of numbers only.", true, consult.window[1])
	consult.label[5] = guiCreateLabel(0.75, 0.45, 0.45, 0.07, "Awaiting input", true, consult.window[1])
	--consult.label[6] = guiCreateLabel(0.68, 0.38, 0.40, 0.07, "Condition: "..t[code]["condition"], true, consult.window[1])
	--consult.label[7] = guiCreateLabel(0.02, 0.50, 0.20, 0.07, "Add note", true, consult.window[1])

	consult.edit[1] = guiCreateEdit(0.27, 0.45, 0.45, 0.07, "", true, consult.window[1])

	-- shut down button close
	addEventHandler("onClientGUIClick", consult.button[1], function ()
			if isElement(consult.window[1]) then destroyElement(consult.window[1]) end
			guiSetInputMode("allow_binds")
		end, false)

	-- back button
	addEventHandler("onClientGUIClick", consult.button[3], function ()
			mainGUI()
			if isElement(consult.window[1]) then destroyElement(consult.window[1]) end
			guiSetInputMode("allow_binds")
		end, false)

	-- submit button
	addEventHandler("onClientGUIClick", consult.button[2], function ()
			local input = guiGetText(consult.edit[1])
			input = tonumber(input) or false
			if input then
				if t[input] then
					registryitemGUI(input)
					if isElement(consult.window[1]) then destroyElement(consult.window[1]) end
					guiSetInputMode("allow_binds")
				else
					guiSetText(consult.label[5], "Doesn't exist")
				end
			else
				guiSetText(consult.label[5], "Numbers only")
			end
		end, false)
end

map = {
    button = {},
    window = {},
    staticimage = {},
    label = {},
    gridlist = {},
    column = {},
    memo = {},
    edit = {}
}
function mapGUI()
	-- to prevent double
	if isElement(map.window[1]) then return false end

	-- to center the gui window
	local screenX, screenY = guiGetScreenSize()
	local width = screenX
	local height = screenY
	local x = ( screenX - width ) / 2
	local y = ( screenY - height ) / 2

	-- parameters
	local isFAA, rankFAA = exports.factions:isPlayerInFaction(getLocalPlayer(), 47)
	local isLeader = exports.factions:hasMemberPermissionTo(getLocalPlayer(), 47, "add_member")
	local fullname = string.gsub(getPlayerName(getLocalPlayer()), "_", " ")
	local clearance = "(guest)"
	if isFAA then clearance = "(staff)"	end
	if isLeader then clearance = "(admin)" end

	local leftX, leftY = -762.6328125, 432.9130859375
	local rightX, rightY = 2990.1943359375, -2759.9619140625
	local vertical = rightY - leftY
	local horizontal = rightX - leftX

	-- disable mta keys
	guiSetInputMode("no_binds_when_editing")

	-- building the gui
	map.window[1] = guiCreateWindow(x, y, width, height, "http://faa.gov - Landing Areas Registry - Map", false)
	guiWindowSetSizable(map.window[1], false)

	map.staticimage[1] = guiCreateStaticImage(0.02, 0.02, 0.07, 0.11, ":sfia/faadevice/faalogo.png", true, map.window[1])
	map.staticimage[2] = guiCreateStaticImage(0.00, 0.17, 1, 1, ":sfia/faadevice/Sanandreas_map.jpg", true, map.window[1])

	map.label[1] = guiCreateLabel(0.10, 0.05, 0.40, 0.12, "Federal Aviation Administration\nSan Andreas region", true, map.window[1])
	guiSetFont(map.label[1], "default-bold-small")
	map.label[2] = guiCreateLabel(0.35, 0.05, 0.45, 0.19, "You have logged in as:\n"..fullname.." "..clearance, true, map.window[1])
	guiLabelSetHorizontalAlign(map.label[2], "left", true)
	map.label[3] = guiCreateLabel(0.00, 0.15, 1.11, 0.11, "__________________________________________________________________________________________________", true, map.window[1])
	map.button[1] = guiCreateButton(0.87, 0.05, 0.11, 0.07, "Close", true, map.window[1])
	guiSetProperty(map.button[1], "NormalTextColour", "FFAAAAAA")
	map.button[2] = guiCreateButton(0.76, 0.05, 0.11, 0.07, "Back", true, map.window[1])
	guiSetProperty(map.button[2], "NormalTextColour", "FFAAAAAA")

	local t = getElementData(resourceRoot, "faa:registrytable")

	-- making buttons
	for k, v in pairs(t) do
		local newcount = #map.button + 1
		local itemx = v["x"] or 0
		local itemy = v["y"] or 0

		local x = (itemx - leftX)/(rightX - leftX)
		local y = (itemy - leftY)/(rightY - leftY)
		map.button[newcount] = guiCreateButton(x - 0.005, y - 0.01, 0.01 * #tostring(k), 0.02, tostring(k), true, map.staticimage[2])

		addEventHandler("onClientGUIClick", map.button[newcount], function()
			registryitemGUI(k)
			if isElement(map.window[1]) then destroyElement(map.window[1]) end
			guiSetInputMode("allow_binds")
		end, false)
	end

	-- shut down button close
	addEventHandler("onClientGUIClick", map.button[1], function ()
			if isElement(map.window[1]) then destroyElement(map.window[1]) end
			guiSetInputMode("allow_binds")
		end, false)

	-- back button
	addEventHandler("onClientGUIClick", map.button[2], function ()
			mainGUI()
			if isElement(map.window[1]) then destroyElement(map.window[1]) end
			guiSetInputMode("allow_binds")
		end, false)

end

addEvent("faa:maingui")
addEventHandler("faa:maingui", getLocalPlayer(), mainGUI)
