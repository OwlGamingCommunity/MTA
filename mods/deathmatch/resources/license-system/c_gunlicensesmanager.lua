-- written (very poorly) by anumaz, on 2014-11-12
-- configs

-- end of configs

-- cache

local licenses_table = { }

--[[function fetchTable(table)
	licenses_table = table
end
addEvent("fetchTable", true)
addEventHandler("fetchTable", resourceRoot, fetchTable)]]

-- end of cache

function refreshGridlist()
	licenses_table = getElementData(resourceRoot, "gunlicense:table")
	refreshMainGUI()
end
addEvent("gunlicense:refreshclient", true)
addEventHandler("gunlicense:refreshclient", resourceRoot, refreshGridlist)

-- main gui
GUIEditor = {
    gridlist = {},
    window = {},
    button = {},
    column = {}
}
function mainGUI()
	if isElement(GUIEditor.window[1]) then destroyElement(GUIEditor.window[1]) end

	setElementData(getLocalPlayer(), "gunlicense:activewindow", true)

	licenses_table = getElementData(resourceRoot, "gunlicense:table")

	GUIEditor.window[1] = guiCreateWindow(532, 299, 542, 266, "Firearms Licensing Unit", false)
	guiWindowSetSizable(GUIEditor.window[1], false)

	GUIEditor.gridlist[1] = guiCreateGridList(0.02, 0.11, 0.96, 0.67, true, GUIEditor.window[1])
	guiGridListSetSortingEnabled(GUIEditor.gridlist[1], false)
	GUIEditor.column[1] = guiGridListAddColumn(GUIEditor.gridlist[1], "Full name", 0.3)
	GUIEditor.column[2] = guiGridListAddColumn(GUIEditor.gridlist[1], "Tier 1", 0.3)
	GUIEditor.column[3] = guiGridListAddColumn(GUIEditor.gridlist[1], "Tier 2", 0.3)
	fillTheGridlist()

	GUIEditor.button[1] = guiCreateButton(0.02, 0.81, 0.19, 0.14, "Search", true, GUIEditor.window[1])
	addEventHandler("onClientGUIClick", GUIEditor.button[1], function ()
			if not isElement(search.window[1]) then
				searchGUI()
			end
		end, false)

	GUIEditor.button[2] = guiCreateButton(0.24, 0.81, 0.19, 0.14, "Issue", true, GUIEditor.window[1])
	addEventHandler("onClientGUIClick", GUIEditor.button[2], function ()
			if not isElement(issue.window[1]) then
				issuelicenseGUI()
			end
		end, false)

	GUIEditor.button[3] = guiCreateButton(0.46, 0.81, 0.19, 0.14, "Revoke", true, GUIEditor.window[1])
	addEventHandler("onClientGUIClick", GUIEditor.button[3], function ()
			local rindex, cindex = guiGridListGetSelectedItem(GUIEditor.gridlist[1])
			local name = guiGridListGetItemText(GUIEditor.gridlist[1], rindex, 1)

			if rindex ~= -1 then
				revokeGUI(rindex + 1)
			else
				outputChatBox("You must select a character from the list.")
			end
		end, false)

	GUIEditor.button[4] = guiCreateButton(0.79, 0.81, 0.19, 0.14, "Close", true, GUIEditor.window[1])
	addEventHandler("onClientGUIClick", GUIEditor.button[4], function ()
			if isElement(GUIEditor.window[1]) then destroyElement(GUIEditor.window[1]) end
			setElementData(getLocalPlayer(), "gunlicense:activewindow", false)
		end, false)
end
addEvent("weaponlicensesGUI", true)
addEventHandler("weaponlicensesGUI", localPlayer, mainGUI)

function fillTheGridlist()
	for k,v in ipairs(licenses_table) do
		local row = guiGridListAddRow(GUIEditor.gridlist[1])
		guiGridListSetItemText( GUIEditor.gridlist[1], row, GUIEditor.column[1], v["charactername"], false, false)
		guiGridListSetItemText( GUIEditor.gridlist[1], row, GUIEditor.column[2], v["gun_license"] == "1" and "Yes" or "No", false, false)
		guiGridListSetItemText( GUIEditor.gridlist[1], row, GUIEditor.column[3], v["gun2_license"] == "1" and "Yes" or "No", false, false)
	end
end

function refreshMainGUI()
	if isElement(GUIEditor.window[1]) then destroyElement(GUIEditor.window[1]) end
	if isElement(search.window[1]) then destroyElement(search.window[1]) end
	if isElement(issue.window[1]) then destroyElement(issue.window[1]) end
	mainGUI()
end

-- search gui
search = {
    button = {},
    window = {},
    edit = {},
    label = {}
}
function searchGUI()
	if isElement(search.window[1]) then destroyElement(search.window[1]) end
	search.window[1] = guiCreateWindow(596, 346, 376, 78, "Firearms Licensing Unit - Search", false)
	guiWindowSetSizable(search.window[1], false)
	guiSetInputMode("no_binds_when_editing")

	search.label[1] = guiCreateLabel(0.04, 0.51, 0.23, 0.22, "Enter full name", true, search.window[1])
	search.edit[1] = guiCreateEdit(0.29, 0.41, 0.37, 0.41, "", true, search.window[1])
	search.button[1] = guiCreateButton(0.68, 0.41, 0.13, 0.42, "Search", true, search.window[1])
	addEventHandler("onClientGUIClick", search.button[1], function ()
			for k,v in ipairs(licenses_table) do
				if v["charactername"] == string.gsub(guiGetText(search.edit[1]), " ", "_") then
					guiGridListSetVerticalScrollPosition(GUIEditor.gridlist[1], k / #licenses_table * 100)
					guiGridListSetSelectedItem(GUIEditor.gridlist[1], k - 1, 1)
					guiSetInputMode("allow_binds")
					if isElement(search.window[1]) then destroyElement(search.window[1]) end
					break
				end
			end
		end, false)

	search.button[2] = guiCreateButton(0.82, 0.41, 0.13, 0.42, "Close", true, search.window[1])
	addEventHandler("onClientGUIClick",search.button[2], function ()
			if isElement(search.window[1]) then destroyElement(search.window[1]) end
			guiSetInputMode("allow_binds")
		end, false)
end

-- issue license
issue = {
    progressbar = {},
    edit = {},
    button = {},
    window = {},
    label = {},
    combobox = {}
}
function issuelicenseGUI()
	if isElement(issue.window[1]) then destroyElement(issue.window[1]) end
	issue.window[1] = guiCreateWindow(628, 297, 322, 291, "Firearms Licensing Unit - Issue", false)
	guiWindowSetSizable(issue.window[1], false)
	guiSetInputMode("no_binds_when_editing")

	issue.edit[1] = guiCreateEdit(0.50, 0.14, 0.44, 0.13, "", true, issue.window[1])
	issue.combobox[1] = guiCreateComboBox(0.50, 0.35, 0.44, 0.30, "", true, issue.window[1])
	guiComboBoxAddItem(issue.combobox[1], "Tier 1")
	guiComboBoxAddItem(issue.combobox[1], "Tier 2")
	issue.label[1] = guiCreateLabel(0.04, 0.16, 0.40, 0.08, "Full name", true, issue.window[1])
	issue.label[2] = guiCreateLabel(0.04, 0.34, 0.40, 0.08, "License tier", true, issue.window[1])
	issue.progressbar[1] = guiCreateProgressBar(0.20, 0.57, 0.60, 0.11, true, issue.window[1])
	issue.button[1] = guiCreateButton(0.05, 0.76, 0.44, 0.18, "Issue", true, issue.window[1])
	addEventHandler("onClientGUIClick", issue.button[1], function ()
		if guiGetText(issue.edit[1]) == "" then
			outputChatBox("You have failed to enter a name.")
			return
		end
		if tonumber(guiGetText(issue.edit[1])) then
			outputChatBox("You have entered number(s) in the name.")
			return
		end
		local targetname = guiGetText(issue.edit[1])
		targetname = string.gsub(targetname, " ", "_")

		local licensetype = guiGetText(issue.combobox[1])

		if licensetype == "Tier 2" then
			if exports.factions:hasMemberPermissionTo(getLocalPlayer(), 1, "add_member") or exports.factions:hasMemberPermissionTo(getLocalPlayer(), 50, "add_member") or exports.integration:isPlayerLeadAdmin(getLocalPlayer()) then
			else
				outputChatBox("You lack the access to issue a Tier 2 license.")
				return false
			end
		end

		local timer1, timer2, timer3, timer4 = nil

		--[[if isElement(getPlayerFromName(targetname)) then
			outputDebugString("is element")
			outputDebugString(targetname)
			outputDebugString(getElementData(getPlayerFromName(targetname), "logged"))
			if getElementData(getPlayerFromName(targetname), "logged") == 1 then
				outputDebugString("is logged!") --]]
				timer1 = setTimer( function ()
					if licensetype == "Tier 1" then
						triggerServerEvent("gunlicense:changeelement", resourceRoot, targetname, "gun")
					elseif licensetype == "Tier 2" then
						triggerServerEvent("gunlicense:changeelement", resourceRoot, targetname, "gun2")
					end
				end, 3000, 1)
			--end
		--end

		timer2 = setTimer( function()
				if licensetype == "Tier 1" then
					triggerServerEvent("gunlicense:issuemysql", resourceRoot, targetname, "gun")
					triggerServerEvent("gunlicense:synctable", resourceRoot, licenses_table)
				elseif licensetype == "Tier 2" then
					triggerServerEvent("gunlicense:issuemysql", resourceRoot, targetname, "gun2")
					triggerServerEvent("gunlicense:synctable", resourceRoot, licenses_table)
				end
			end, 3000, 1)


		local itemnumber = nil
		if licensetype == "Tier 1" then
			for k,v in ipairs(licenses_table) do
				if v["charactername"] == tostring(targetname) then
					itemnumber = k
					break
				end
			end

			if itemnumber ~= nil then
				licenses_table[itemnumber]["charactername"] = tostring(targetname)
				licenses_table[itemnumber]["gun_license"] = "1"
			else
				local newitem = #licenses_table + 1
				licenses_table[newitem] = { }
				licenses_table[newitem]["charactername"] = tostring(targetname)
				licenses_table[newitem]["gun_license"] = "1"
			end
		end
		if licensetype == "Tier 2" then
			for k,v in ipairs(licenses_table) do
				if v["charactername"] == tostring(targetname) then
					itemnumber = k
					break
				end
			end

			if itemnumber ~= nil then
				licenses_table[itemnumber]["charactername"] = tostring(targetname)
				licenses_table[itemnumber]["gun2_license"] = "1"
			else
				local newitem = #licenses_table + 1
				licenses_table[newitem] = { }
				licenses_table[newitem]["charactername"] = tostring(targetname)
				licenses_table[newitem]["gun2_license"] = "1"
			end
		end

		timer3 = setTimer( function ()
				outputChatBox("You have given "..targetname.." a "..licensetype.." license.")
				local search = string.gsub(targetname, " ", "_")
				refreshMainGUI()
				for k,v in ipairs(licenses_table) do
					if v["charactername"] == search then
						guiGridListSetVerticalScrollPosition(GUIEditor.gridlist[1], k / #licenses_table * 100)
						guiGridListSetSelectedItem(GUIEditor.gridlist[1], k - 1, 1)
						guiSetInputMode("allow_binds")
						if isElement(issue.window[1]) then destroyElement(issue.window[1]) end
						break
					end
				end
			end, 4000, 1)

		local progress = 0
		timer4 = setTimer( function ()
				if isElement(issue.progressbar[1]) then
					guiProgressBarSetProgress(issue.progressbar[1], progress + 2)
					progress = progress + 2
				end
			end, 60, 50)

	end, false)


	issue.button[2] = guiCreateButton(0.50, 0.76, 0.44, 0.18, "Close", true, issue.window[1])
	addEventHandler("onClientGUIClick", issue.button[2], function ()
			if isElement(issue.window[1]) then destroyElement(issue.window[1]) end
			if isTimer(timer1) then killTimer(timer1) end
			if isTimer(timer2) then killTimer(timer2) end
			if isTimer(timer3) then killTimer(timer3) end
			if isTimer(timer4) then killTimer(timer4) end
			if isTimer(timer5) then killTimer(timer5) end
			guiSetInputMode("allow_binds")
		end, false)
end

-- revoke license
revoke = {
    button = {},
    window = {},
    label = {},
    combobox = {}
}
function revokeGUI(tableid)
	if isElement(revoke.window[1]) then destroyElement(revoke.window[1]) end
	revoke.window[1] = guiCreateWindow(0.42, 0.33, 0.15, 0.14, "Firearms Licensing Unit - Revoke license", true)
	guiWindowSetSizable(revoke.window[1], false)
	local name = licenses_table[tableid]["charactername"]
	local tier1 = false
	local tier2 = false

	revoke.label[1] = guiCreateLabel(12, 25, 210, 20, name, false, revoke.window[1])
	revoke.combobox[1] = guiCreateComboBox(11, 52, 110, 61, "", false, revoke.window[1])
	if licenses_table[tableid]["gun_license"] == "1" then
		guiComboBoxAddItem(revoke.combobox[1], "Tier 1")
		tier1 = true
	end
	if licenses_table[tableid]["gun2_license"] == "1" then
		guiComboBoxAddItem(revoke.combobox[1], "Tier 2")
		tier2 = true
	end
	revoke.button[1] = guiCreateButton(144, 51, 78, 28, "Revoke", false, revoke.window[1])
	addEventHandler("onClientGUIClick", revoke.button[1], function ()
			if isElement(getPlayerFromName(name)) and getElementData(getPlayerFromName(name), "loggedin") == 1 then
				triggerServerEvent("gunlicense:revokeElement", resourceRoot, name)
			end
			if tier1 and not tier2 then
				table.remove(licenses_table, tableid)
				triggerServerEvent("gunlicense:revokemysql", resourceRoot, name)
				outputChatBox(name.."'s Tier 1 weapon license have been revoked.")
				triggerServerEvent("gunlicense:synctable", resourceRoot, licenses_table)
			elseif tier2 and not tier1 then
				table.remove(licenses_table, tableid)
				triggerServerEvent("gunlicense:revokemysql", resourceRoot, name)
				outputChatBox(name.."'s Tier 2 weapon license have been revoked.")
				triggerServerEvent("gunlicense:synctable", resourceRoot, licenses_table)
			elseif tier1 and tier2 then
				if guiGetText(revoke.combobox[1]) == "Tier 1" then
					table.remove(licenses_table, tableid)
					triggerServerEvent("gunlicense:revokemysql", resourceRoot, name)
					outputChatBox(name.."'s Tier 1 weapon license have been revoked.")
					triggerServerEvent("gunlicense:issuemysql", resourceRoot, name, "gun2")
					triggerServerEvent("gunlicense:changeelement", resourceRoot, name, "gun2")
					local newitem = #licenses_table + 1
					licenses_table[newitem] = { }
					licenses_table[newitem]["charactername"] = tostring(name)
					licenses_table[newitem]["gun2_license"] = "1"
					triggerServerEvent("gunlicense:synctable", resourceRoot, licenses_table)
				elseif guiGetText(revoke.combobox[1]) == "Tier 2" then
					table.remove(licenses_table, tableid)
					triggerServerEvent("gunlicense:revokemysql", resourceRoot, name)
					outputChatBox(name.."'s Tier 2 weapon license have been revoked.")
					triggerServerEvent("gunlicense:issuemysql", resourceRoot, name, "gun")
					triggerServerEvent("gunlicense:changeelement", resourceRoot, name, "gun")
					local newitem = #licenses_table + 1
					licenses_table[newitem] = { }
					licenses_table[newitem]["charactername"] = tostring(name)
					licenses_table[newitem]["gun_license"] = "1"
					triggerServerEvent("gunlicense:synctable", resourceRoot, licenses_table)
				else
					outputChatBox("You must select the type of license you want to revoke.")
				end
			end


			if isElement(revoke.window[1]) then destroyElement(revoke.window[1]) end
		end, false)

	revoke.button[2] = guiCreateButton(144, 84, 78, 28, "Close", false, revoke.window[1])
	addEventHandler("onClientGUIClick", revoke.button[2], function ()
			if isElement(revoke.window[1]) then destroyElement(revoke.window[1]) end
		end, false)
end
