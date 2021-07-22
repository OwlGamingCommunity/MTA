
localPlayer = getLocalPlayer()
local currentObject
local currentUseData, currentMoveData, currentPickupData, currentUseDataType, currentMoveDataType, currentPickupDataType = {}, {}, {}, nil, nil, nil

function getPermissions(element)
	if getElementParent(getElementParent(element)) == getResourceRootElement(getThisResource()) then
		local perm = getElementData(element, "worlditem.permissions")
		if perm then
			return perm
		else
			return getPermissionsFromDB(element)
		end
	end
	return false
end

function itemPropertiesGUI(object)
	if not object then return end
	if canEditItemProperties(localPlayer, object) then
		currentObject = object
		currentUseData, currentMoveData, currentPickupData, currentUseDataType, currentMoveDataType, currentPickupDataType = {}, {}, {}, nil, nil, nil
		if propertiesWindow then
			destroyElement(propertiesWindow)
		end

		GUIEditor = {
		    tab = {},
		    tabpanel = {},
		    label = {},
		    button = {},
		    combobox = {},
		    checkbox = {}
		}
		
		local sx, sy = guiGetScreenSize()
		local w, h = 332, 391
		local x = (sx/2)-(w/2)
		local y = (sy/2)-(h/2)
		propertiesWindow = guiCreateWindow(x, y, w, h, "Item Properties", false)
		guiWindowSetSizable(propertiesWindow, false)

		--get data
		local id = tonumber(getElementData(object, "id")) or 0
		local itemID = tonumber(getElementData(object, "itemID")) or 0
		local itemValue = getElementData(object, "itemValue")
		local metadata = getElementData(object, "metadata") or {}
		local creator = tonumber(getElementData(object, "creator")) or 0
		local createdDate = getElementData(object, "createdDate")
		local protected = getElementData(object, "protected")
		local useExactValues = getElementData(object, "useExactValues")
		permissions = getPermissions(object) or {}
		--outputDebugString("#permissions = "..tostring(#permissions))
		local itemName = tostring(exports.global:getItemName(itemID, itemValue, metadata))

		if protected and protected ~= 0 then
			protected = true
		else
			protected = false
		end
		local protectedText = ""
		if protected then
			protectedText = "Yes"
		else
			protectedText = "No"
		end

		local creatorName = tostring(creator)

		if createdDate then
			createdDateText = tostring(createdDate)
		else	
			createdDateText = "Unknown"
		end

		local itemValueText
		if not itemValue then
			itemValueText = ""
		else
			if exports["item-system"]:getItemHideItemValue(itemID) then
				if exports.integration:isPlayerSupporter(localPlayer) and exports.global:isStaffOnDuty(localPlayer) or exports.integration:isPlayerTrialAdmin(localPlayer) and exports.global:isStaffOnDuty(localPlayer) or exports.integration:isPlayerScripter(localPlayer) and exports.global:isStaffOnDuty(localPlayer) then
					itemValueText = tostring(itemValue).." (hidden)"
				else
					itemValueText = "(hidden)"
				end
			else
				itemValueText = tostring(itemValue)
			end
		end

		GUIEditor.button[4] = guiCreateButton(158, 354, 164, 27, "Save", false, propertiesWindow)
		GUIEditor.button[5] = guiCreateButton(9, 354, 147, 27, "Cancel", false, propertiesWindow)
			addEventHandler("onClientGUIClick", GUIEditor.button[5], hideItemPropertiesGUI, false)
			addEventHandler("onClientGUIClick", GUIEditor.button[4], saveItemProperties, false)

		GUIEditor.tabpanel[1] = guiCreateTabPanel(9, 27, 314, 323, false, propertiesWindow)

		GUIEditor.tab[1] = guiCreateTab("Details", GUIEditor.tabpanel[1])

		GUIEditor.label[1] = guiCreateLabel(7, 8, 300, 19, itemName, false, GUIEditor.tab[1])
		guiSetFont(GUIEditor.label[1], "default-bold-small")
		
		local itemIDtext = "Item ID: "..tostring(itemID)
		local itemName2 = exports.global:getItemName(itemID)
		if(itemName ~= itemName2) then
			itemIDtext = "Item ID: "..tostring(itemID).." ("..tostring(exports.global:getItemName(itemID))..")"
		end
		GUIEditor.label[10] = guiCreateLabel(7, 32, 299, 21, tostring(itemIDtext), false, GUIEditor.tab[1])
		GUIEditor.label[11] = guiCreateLabel(7, 53, 299, 21, "Item value: "..itemValueText, false, GUIEditor.tab[1])

		GUIEditor.label[2] = guiCreateLabel(7, 74, 299, 21, "Placed by: "..creatorName, false, GUIEditor.tab[1])
		GUIEditor.label[3] = guiCreateLabel(7, 95, 299, 21, "Placed date: "..createdDateText, false, GUIEditor.tab[1])
		GUIEditor.label[4] = guiCreateLabel(7, 116, 299, 21, "Protected: "..protectedText, false, GUIEditor.tab[1])
		GUIEditor.checkbox[1] = guiCreateCheckBox(7, 137, 299, 21, "Use Exact Position", useExactValues, false, GUIEditor.tab[1])

		GUIEditor.tab[2] = guiCreateTab("Permissions", GUIEditor.tabpanel[1])

		GUIEditor.label[5] = guiCreateLabel(9, 11, 46, 18, "Use:", false, GUIEditor.tab[2])

		GUIEditor.button[1] = guiCreateButton(62, 35, 240, 25, "Define", false, GUIEditor.tab[2])
			addEventHandler("onClientGUIClick", GUIEditor.button[1], 
				function ()
					local num = 1
					local action = "use"
					local type
					local text = guiComboBoxGetItemText(GUIEditor.combobox[num], guiComboBoxGetSelected(GUIEditor.combobox[num]) or 1)
					for k,v in ipairs(permissionTypes) do
						if v[1] == text then
							type = v[2]
							break
						end
					end
					local oldData
					if permissions[action] == type then
						oldData = permissions[action.."Data"]
					end 	
					showDataSet(type, action, oldData)
				end
			, false)

		GUIEditor.button[2] = guiCreateButton(62, 99, 240, 25, "Define", false, GUIEditor.tab[2])
			addEventHandler("onClientGUIClick", GUIEditor.button[2], 
				function ()
					local num = 2
					local action = "move"
					local type
					local text = guiComboBoxGetItemText(GUIEditor.combobox[num], guiComboBoxGetSelected(GUIEditor.combobox[num]) or 1)
					for k,v in ipairs(permissionTypes) do
						if v[1] == text then
							type = v[2]
							break
						end
					end
					local oldData
					if permissions[action] == type then
						oldData = permissions[action.."Data"]
					end 	
					showDataSet(type, action, oldData)
				end
			, false)

		GUIEditor.button[3] = guiCreateButton(62, 166, 240, 25, "Define", false, GUIEditor.tab[2])
			addEventHandler("onClientGUIClick", GUIEditor.button[3], 
				function ()
					local num = 3
					local action = "pickup"
					local type
					local text = guiComboBoxGetItemText(GUIEditor.combobox[num], guiComboBoxGetSelected(GUIEditor.combobox[num]) or 1)
					for k,v in ipairs(permissionTypes) do
						if v[1] == text then
							type = v[2]
							break
						end
					end
					local oldData = nil
					if permissions[action] == type then
						oldData = permissions[action.."Data"]
					end 	
					showDataSet(type, action, oldData)
				end
			, false)

		GUIEditor.combobox[1] = guiCreateComboBox(60, 9, 244, 115, "", false, GUIEditor.tab[2])
			for k,v in ipairs(permissionTypes) do
				local row = guiComboBoxAddItem(GUIEditor.combobox[1], v[1])
				if v[2] == permissions.use then
					guiComboBoxSetSelected(GUIEditor.combobox[1], row)
					if v[3] then
						guiSetVisible(GUIEditor.button[1], true)
					else
						guiSetVisible(GUIEditor.button[1], false)
					end
				end
			end
			addEventHandler("onClientGUIComboBoxAccepted", GUIEditor.combobox[1], 
				function ()
					local num = 1
					local combo = GUIEditor.combobox[num]
					local btn = GUIEditor.button[num]
					local name = guiComboBoxGetItemText(combo, guiComboBoxGetSelected(combo))
					for k,v in ipairs(permissionTypes) do
						if name == v[1] then
							if v[3] then
								guiSetVisible(btn, true)
							else
								guiSetVisible(btn, false)
							end
							break
						end
					end
				end
			, false)
		GUIEditor.combobox[2] = guiCreateComboBox(60, 73, 244, 115, "", false, GUIEditor.tab[2])
			for k,v in ipairs(permissionTypes) do
				local row = guiComboBoxAddItem(GUIEditor.combobox[2], v[1])
				if v[2] == permissions.move then
					guiComboBoxSetSelected(GUIEditor.combobox[2], row)
					if v[3] then
						guiSetVisible(GUIEditor.button[2], true)
					else
						guiSetVisible(GUIEditor.button[2], false)
					end
				end
			end
			addEventHandler("onClientGUIComboBoxAccepted", GUIEditor.combobox[2], 
				function ()
					local num = 2
					local combo = GUIEditor.combobox[num]
					local btn = GUIEditor.button[num]
					local name = guiComboBoxGetItemText(combo, guiComboBoxGetSelected(combo))
					for k,v in ipairs(permissionTypes) do
						if name == v[1] then
							if v[3] then
								guiSetVisible(btn, true)
							else
								guiSetVisible(btn, false)
							end
							break
						end
					end
				end
			, false)
		GUIEditor.combobox[3] = guiCreateComboBox(60, 138, 244, 115, "", false, GUIEditor.tab[2])
			for k,v in ipairs(permissionTypes) do
				local row = guiComboBoxAddItem(GUIEditor.combobox[3], v[1])
				if v[2] == permissions.pickup then
					guiComboBoxSetSelected(GUIEditor.combobox[3], row)
					if v[3] then
						guiSetVisible(GUIEditor.button[3], true)
					else
						guiSetVisible(GUIEditor.button[3], false)
					end
				end
			end
			addEventHandler("onClientGUIComboBoxAccepted", GUIEditor.combobox[3], 
				function ()
					local num = 3
					local combo = GUIEditor.combobox[num]
					local btn = GUIEditor.button[num]
					local name = guiComboBoxGetItemText(combo, guiComboBoxGetSelected(combo))
					for k,v in ipairs(permissionTypes) do
						if name == v[1] then
							if v[3] then
								guiSetVisible(btn, true)
							else
								guiSetVisible(btn, false)
							end
							break
						end
					end
				end
			, false)

		GUIEditor.label[6] = guiCreateLabel(9, 75, 46, 18, "Move:", false, GUIEditor.tab[2])
		GUIEditor.label[7] = guiCreateLabel(9, 140, 46, 18, "Pick up:", false, GUIEditor.tab[2])
		GUIEditor.label[8] = guiCreateLabel(9, 239, 296, 56, "These settings define who can use, move and pick up this item. The character that dropped the item, admins and anyone with key to the interior can edit these settings. Items set as 'protected' by an admin cannot be moved or picked up before the item has been unprotected by an admin.", false, GUIEditor.tab[2])
		guiSetFont(GUIEditor.label[8], "default-small")
		guiLabelSetHorizontalAlign(GUIEditor.label[8], "left", true)
		GUIEditor.label[9] = guiCreateLabel(9, 204, 112, 18, "Protected: "..protectedText, false, GUIEditor.tab[2])
		
		local newCreatorName
		for k,v in ipairs(getElementsByType("player")) do
			local dbid = tonumber(getElementData(v, "dbid")) or 0
			if dbid == creator then
				newCreatorName = getPlayerName(v):gsub("_", " ")
				break
			end
		end
		if newCreatorName then
			guiSetText(GUIEditor.label[2], "Placed by: "..newCreatorName)
		end
		triggerServerEvent("item-world:getItemPropertiesData", getResourceRootElement(), object)
	end
end
addEvent("showItemProperties", true)
addEventHandler("showItemProperties", getRootElement(), itemPropertiesGUI)

function hideItemPropertiesGUI()
	if propertiesWindow then
		if isElement(propertiesWindow) then
			destroyElement(propertiesWindow)
		end
		propertiesWindow = nil
	end
	currentObject = nil
	currentUseData, currentMoveData, currentPickupData, currentUseDataType, currentMoveDataType, currentPickupDataType = {}, {}, {}, nil, nil, nil
end

function itemPropertiesGUIFillData(object, creatorName, createdDate, protected)
	if currentObject == object then
		if creatorName and isElement(GUIEditor.label[2]) then
			guiSetText(GUIEditor.label[2], "Placed by: "..creatorName:gsub("_", " "))
		end
		if isElement(GUIEditor.label[3]) then
			if createdDate then
				createdDate = tostring(createdDate)
			else	
				createdDate = "Unknown"
			end
			guiSetText(GUIEditor.label[3], "Placed date: "..createdDate)
		end
		if isElement(GUIEditor.label[4]) then
			if protected then
				protected = "Yes"
			else
				protected = "No"
			end
			guiSetText(GUIEditor.label[4], "Protected: "..protected)
			guiSetText(GUIEditor.label[9], "Protected: "..protected)
		end		
	end
end
addEvent("item-world:fillItemPropertiesGUI", true)
addEventHandler("item-world:fillItemPropertiesGUI", getResourceRootElement(), itemPropertiesGUIFillData)

function trim(s)
	s = s:gsub("^%s*(.-)%s*$", "%1")
	s = s:gsub("\n", "")
	return s
end

function saveItemProperties(button, state)	
	local object = currentObject
	if not object then return end
	
	local useText = guiComboBoxGetItemText(GUIEditor.combobox[1], guiComboBoxGetSelected(GUIEditor.combobox[1]) or 1)
	local moveText = guiComboBoxGetItemText(GUIEditor.combobox[2], guiComboBoxGetSelected(GUIEditor.combobox[2]) or 1)
	local pickupText = guiComboBoxGetItemText(GUIEditor.combobox[3], guiComboBoxGetSelected(GUIEditor.combobox[3]) or 1)
	local useExactValueChecked = guiCheckBoxGetSelected( GUIEditor.checkbox[1] )

	local use, move, pickup
	local useData, moveData, pickupData = {}, {}, {}
	for k,v in ipairs(permissionTypes) do
		if v[1] == useText then
			use = v[2]
			if v[3] then
				useData = currentUseData or {}
			end
		end
		if v[1] == moveText then
			move = v[2]
			if v[3] then
				moveData = currentMoveData or {}
			end
		end
		if v[1] == pickupText then
			pickup = v[2]
			if v[3] then
				pickupData = currentPickupData or {}
			end
		end	
	end

	triggerServerEvent("item-world:saveItemProperties", getResourceRootElement(), object, use, useData, move, moveData, pickup, pickupData, useExactValueChecked)
	
	hideItemPropertiesGUI()
end

function showDataSet(type, action, oldData)
	if dataWindow then
		if isElement(dataWindow) then
			destroyElement(dataWindow)
		end
		dataWindow = nil
	end

	dataAction = action

	local newData = {}

	local currentData
	if action == "use" then
		currentData = currentUseData
		currentDataType = currentUseDataType
	elseif action == "move" then
		currentData = currentMoveData
		currentDataType = currentMoveDataType
	elseif action == "pickup" then
		currentData = currentPickupData
		currentDataType = currentPickupDataType
	end

	if type == 4 then --factions
		local sx, sy = guiGetScreenSize()
		local w, h = 385, 445
		local x = (sx/2)-(w/2)
		local y = (sy/2)-(h/2)
		dataWindow = guiCreateWindow(x, y, w, h, "Select Factions", false)
		guiWindowSetSizable(dataWindow, false)

		inputCharName = guiCreateEdit(9, 50, 276, 27, "", false, dataWindow)
		local btnAdd = guiCreateButton(288, 52, 88, 25, "Add", false, dataWindow)
		feedbackLabel = guiCreateLabel(12, 26, 361, 22, "Enter name or ID of a faction to add.", false, dataWindow)
		inputGridlist = guiCreateGridList(9, 88, 367, 265, false, dataWindow)
			guiGridListAddColumn(inputGridlist, "ID", 0.1)
			guiGridListAddColumn(inputGridlist, "Faction", 0.8)
		
		local btnSave = guiCreateButton(10, 401, 366, 31, "Set data", false, dataWindow)
		local btnRemove = guiCreateButton(9, 357, 116, 30, "Remove selected", false, dataWindow)
		local btnRemoveAll = guiCreateButton(130, 357, 116, 30, "Remove all", false, dataWindow)

		addEventHandler("onClientGUIClick", btnAdd, 
			function ()
				local faction = guiGetText(inputCharName)
				if faction then
					local factionID, factionName
					if tonumber(faction) then --if number (faction ID)
						factionID = tonumber(faction)
						factionName = exports.factions:getFactionName(factionID)
					else --faction name
						factionID = exports.factions:getFactionIDFromName(faction)
						factionName = faction
					end

					if factionID and factionName then
						local alreadyAdded = false
						local rows = guiGridListGetRowCount(inputGridlist) - 1

						if rows > 50 then
							guiSetText(feedbackLabel, "Too many entries.")
							guiLabelSetColor(feedbackLabel, 255, 0, 0)							
						else
							local i = 0
							while i <= rows do
								if(tonumber(guiGridListGetItemText(inputGridlist, i, 1)) == factionID) then
									alreadyAdded = true
									break
								end
								i = i + 1
							end

							if alreadyAdded then
								guiSetText(inputCharName, "")
								guiSetText(feedbackLabel, "Enter name or ID of a faction to add.")
								guiLabelSetColor(feedbackLabel, 255, 255, 255)
							else
								local row = guiGridListAddRow(inputGridlist)
								guiGridListSetItemText(inputGridlist, row, 1, tostring(factionID), false, true)
								guiGridListSetItemText(inputGridlist, row, 2, tostring(factionName), false, true)
								guiSetText(inputCharName, "")
								guiSetText(feedbackLabel, "Enter name or ID of a faction to add.")
								guiLabelSetColor(feedbackLabel, 255, 255, 255)
							end
						end
					else
						guiSetText(feedbackLabel, "Not found.")
						guiLabelSetColor(feedbackLabel, 255, 0, 0)
					end
				else
					guiSetText(feedbackLabel, "Enter name or ID of a faction to add.")
					guiLabelSetColor(feedbackLabel, 255, 255, 255)					
				end
			end
		, false)	

		addEventHandler("onClientGUIClick", btnRemove, 
			function ()
				local row, column = guiGridListGetSelectedItem(inputGridlist)
				if(row >= 0) then
					guiGridListRemoveRow(inputGridlist, row)
				end
			end
		, false)		

		addEventHandler("onClientGUIClick", btnRemoveAll, 
			function ()
				guiGridListClear(inputGridlist)
			end
		, false)

		addEventHandler("onClientGUIClick", btnSave, 
			function ()
				local newData = {}
				local rows = guiGridListGetRowCount(inputGridlist) - 1
				local i = 0
				while i <= rows do
					local faction = tonumber(guiGridListGetItemText(inputGridlist, i, 1))
					table.insert(newData, faction)
					i = i + 1
				end

				outputConsole(tostring(toJSON(newData)))

				if dataAction == "use" then
					currentUseData = newData
					currentUseDataType = type
				elseif dataAction == "move" then
					currentMoveData = newData
					currentMoveDataType = type
				elseif dataAction == "pickup" then
					currentPickupData = newData
					currentPickupDataType = type
				end
				hideDataSet()
			end
		, false)

		guiSetInputMode("no_binds_when_editing")

		if currentData and currentDataType == type then
			for k, v in ipairs(currentData) do
				local factionID = tonumber(v)
				local factionName = exports.factions:getFactionName(factionID)
				local row = guiGridListAddRow(inputGridlist)
				guiGridListSetItemText(inputGridlist, row, 1, tostring(factionID), false, true)
				guiGridListSetItemText(inputGridlist, row, 2, tostring(factionName), false, false)
			end
		elseif oldData then
			for k, v in ipairs(oldData) do
				local factionID = tonumber(v)
				local factionName = exports.factions:getFactionName(factionID)
				local row = guiGridListAddRow(inputGridlist)
				guiGridListSetItemText(inputGridlist, row, 1, tostring(factionID), false, true)
				guiGridListSetItemText(inputGridlist, row, 2, tostring(factionName), false, false)
			end
		end

	elseif type == 5 then --characters
		local sx, sy = guiGetScreenSize()
		local w, h = 385, 445
		local x = (sx/2)-(w/2)
		local y = (sy/2)-(h/2)
		dataWindow = guiCreateWindow(x, y, w, h, "Select Characters", false)
		guiWindowSetSizable(dataWindow, false)

		inputCharName = guiCreateEdit(9, 50, 276, 27, "", false, dataWindow)
		local btnAdd = guiCreateButton(288, 52, 88, 25, "Add", false, dataWindow)
		feedbackLabel = guiCreateLabel(12, 26, 361, 22, "Enter name of a character to add.", false, dataWindow)
		inputGridlist = guiCreateGridList(9, 88, 367, 265, false, dataWindow)
			guiGridListAddColumn(inputGridlist, "Character Name", 0.9)
		
		local btnSave = guiCreateButton(10, 401, 366, 31, "Set data", false, dataWindow)
		local btnRemove = guiCreateButton(9, 357, 116, 30, "Remove selected", false, dataWindow)
		local btnRemoveAll = guiCreateButton(130, 357, 116, 30, "Remove all", false, dataWindow)

		addEventHandler("onClientGUIClick", btnAdd, 
			function ()
				local charname = guiGetText(inputCharName)
				if charname then
					local alreadyAdded = false
					local rows = guiGridListGetRowCount(inputGridlist) - 1

					if rows > 50 then
						guiSetText(feedbackLabel, "Too many entries.")
						guiLabelSetColor(feedbackLabel, 255, 0, 0)					
					else
						local i = 0
						while i <= rows do
							if(guiGridListGetItemText(inputGridlist, i, 1) == charname) then
								alreadyAdded = true
								break
							end
							i = i + 1
						end

						if alreadyAdded then
							guiSetText(inputCharName, "")
							guiSetText(feedbackLabel, "Enter name of a character to add.")
							guiLabelSetColor(feedbackLabel, 255, 255, 255)
						else
							local row = guiGridListAddRow(inputGridlist)
							guiGridListSetItemText(inputGridlist, row, 1, tostring(charname), false, false)
							guiSetText(inputCharName, "")
							guiSetText(feedbackLabel, "Enter name of a character to add.")
							guiLabelSetColor(feedbackLabel, 255, 255, 255)
						end
					end
				else
					guiSetText(feedbackLabel, "Enter name of a character to add.")
					guiLabelSetColor(feedbackLabel, 255, 255, 255)
				end
			end
		, false)	

		addEventHandler("onClientGUIClick", btnRemove, 
			function ()
				local row, column = guiGridListGetSelectedItem(inputGridlist)
				if(row >= 0) then
					guiGridListRemoveRow(inputGridlist, row)
				end
			end
		, false)		

		addEventHandler("onClientGUIClick", btnRemoveAll, 
			function ()
				guiGridListClear(inputGridlist)
			end
		, false)

		addEventHandler("onClientGUIClick", btnSave, 
			function ()
				local newData = {}
				local rows = guiGridListGetRowCount(inputGridlist) - 1
				local i = 0
				while i <= rows do
					local charname = guiGridListGetItemText(inputGridlist, i, 1)
					table.insert(newData, charname)
					i = i + 1
				end

				outputConsole(tostring(toJSON(newData)))

				if dataAction == "use" then
					currentUseData = newData
					currentUseDataType = type
				elseif dataAction == "move" then
					currentMoveData = newData
					currentMoveDataType = type
				elseif dataAction == "pickup" then
					currentPickupData = newData
					currentPickupDataType = type
				end
				hideDataSet()
			end
		, false)

		guiSetInputMode("no_binds_when_editing")

		if currentData and currentDataType == type then
			for k, v in ipairs(currentData) do
				local row = guiGridListAddRow(inputGridlist)
				guiGridListSetItemText(inputGridlist, row, 1, tostring(v), false, false)
			end
		elseif oldData then
			for k, v in ipairs(oldData) do
				local row = guiGridListAddRow(inputGridlist)
				guiGridListSetItemText(inputGridlist, row, 1, tostring(v), false, false)
			end
		end

	elseif type == 8 then --query string
		local sx, sy = guiGetScreenSize()
		local w, h = 429, 168
		local x = (sx/2)-(w/2)
		local y = (sy/2)-(h/2)
        dataWindow = guiCreateWindow(x, y, w, h, "Write Exciter Query String", false)
        guiWindowSetSizable(dataWindow, false)
        local oldText = ""
        if oldData then
        	if oldData[1] then
        		oldText = tostring(oldData[1])
        	end
        end
        inputDataMemo = guiCreateMemo(13, 32, 402, 91, oldText, false, dataWindow)
        local btn = guiCreateButton(16, 126, 392, 32, "Set data", false, dataWindow)
			addEventHandler("onClientGUIClick", btn, 
				function ()
					local querystring = trim(guiGetText(inputDataMemo))
					local newData = { querystring }

					outputConsole(toJSON(newData))

					if dataAction == "use" then
						currentUseData = newData
						currentUseDataType = type
					elseif dataAction == "move" then
						currentMoveData = newData
						currentMoveDataType = type
					elseif dataAction == "pickup" then
						currentPickupData = newData
						currentPickupDataType = type
					end
					hideDataSet()
				end
			, false)
		guiSetInputMode("no_binds_when_editing")

		if currentData and currentDataType == type then
			guiSetText(inputDataMemo, tostring(currentData[1]))
		elseif oldData then
			guiSetText(inputDataMemo, tostring(oldData[1]))
		end

	end
end

function hideDataSet()
	if dataWindow then
		if isElement(dataWindow) then
			destroyElement(dataWindow)
		end
		dataWindow = nil
	end
end