--MAXIME
local version = "© OWL MTA Scripting Team [28.1.14]"
local myadminWindow = nil
local lists = {}

function adminhelp (commands, scriptUpdates)
	closeAhWindow()
	guiSetInputEnabled(true)
	myadminWindow = guiCreateWindow ( 0.15, 0.15, 0.7, 0.7,  "Index of admin commands | Dynamic Commands Library "..version, true)
	guiWindowSetSizable(myadminWindow, false)
	
	guiCreateLabel(0.02, 0.05, 0.6, 0.05,"Left click to copy command to clipboard, Right click to modify command", true, myadminWindow)
	
	local tabPanel = guiCreateTabPanel (0, 0.1, 1, 1, true, myadminWindow)
	local tab = {}
	for level = 1, 5 do 
		local tabName = "Trial+"
		if level == 2 then
			tabName = "Trial+"
		elseif level == 3 then
			tabName = "Trial+"
		elseif level == 4 then
			tabName = "Regular+"
		elseif level == 5 then
			tabName = "Lead+"
		end
		
		tab[level] = guiCreateTab(tabName, tabPanel)
		lists[level] = guiCreateGridList(0.02, 0.02, 0.96, 0.96, true, tab[level]) -- commands for level one admins 
		guiGridListAddColumn (lists[level], "Command", 0.2)
		guiGridListAddColumn (lists[level], "Explanation", 1.5)
		guiGridListAddColumn (lists[level], "Cmd ID", 0.2)
	end
	
	for level, levelcmds in pairs( commands ) do
		if #levelcmds == 0 then
			local row = guiGridListAddRow ( lists[level] )
			guiGridListSetItemText ( lists[level], row, 1, "-", false, false)
			guiGridListSetItemText ( lists[level], row, 2, "There are currently no commands specific to this level.", false, false)
			guiGridListSetItemText ( lists[level], row, 3, "-", false, false)
		else
			for _, command in pairs( levelcmds ) do
				local row = guiGridListAddRow ( lists[level] )
				guiGridListSetItemText ( lists[level], row, 1, command[1], false, false)
				guiGridListSetItemText ( lists[level], row, 2, command[2], false, false)
				guiGridListSetItemText ( lists[level], row, 3, command[3], false, false)
			end
		end
	end
	
	tab[6] = guiCreateTab( "Admin Rules & Recent Updates", tabPanel )
	local memoAdminRules = guiCreateMemo (  0.02, 0.02, 0.96, 0.96, getElementData(getResourceRootElement(getResourceFromName("account-system")), "adminrules:text") or "Error fetching...", true, tab[6] ) 
	guiMemoSetReadOnly(memoAdminRules, true)
	
	tab[7] = guiCreateTab( "Recent Script Changes", tabPanel )
	local memoScriptChanges = guiCreateMemo (  0.02, 0.02, 0.96, 0.90, scriptUpdates or "Coming soon ;)", true, tab[7] ) 
	local bUpdate = guiCreateButton(  0.02, 0.92, 0.96, 0.06, "Update", true, tab[7] ) 
	addEventHandler ("onClientGUIClick", bUpdate, function()
		triggerServerEvent ("admin-system:updateScript", getLocalPlayer(), getLocalPlayer(), guiGetText(memoScriptChanges) )
	end, false)
	if not exports.integration:isPlayerLeadAdmin(getLocalPlayer()) and not getElementData(getLocalPlayer(), "hasCmdLibraryAccess") then
		guiMemoSetReadOnly(memoScriptChanges, true)
		guiSetEnabled(bUpdate, false)
	end
	
	local tlBackButton = guiCreateButton(0.8, 0.04, 0.2, 0.06, "Close", true, myadminWindow) -- close button
	addEventHandler ("onClientGUIClick", tlBackButton, closeAhWindow , false)
	
	if exports.integration:isPlayerLeadAdmin(getLocalPlayer()) or getElementData(getLocalPlayer(), "hasCmdLibraryAccess") then
		local bAdd = guiCreateButton(0.6, 0.04, 0.2, 0.06, "Add New Command", true, myadminWindow) -- close button
		addEventHandler ("onClientGUIClick", bAdd, function(button, state)
			if (button == "left") then
				if (state == "up") then
					drawCmdModifyWindow(false, "", "", "Trial Admin")
				end
			end
		end, false)
	end
	
	addEventHandler("onClientGUIClick", lists[1] , copyToClipboard1 , false)
	addEventHandler("onClientGUIClick", lists[2] , copyToClipboard2 , false)
	addEventHandler("onClientGUIClick", lists[3] , copyToClipboard3 , false)
	addEventHandler("onClientGUIClick", lists[4] , copyToClipboard4 , false)
	addEventHandler("onClientGUIClick", lists[5] , copyToClipboard5 , false)
	
	local currentTabIndex = getElementData(getLocalPlayer(), "cmd:currentTabIndex") or 1
	guiSetSelectedTab ( tabPanel, tab[currentTabIndex] )
	
	addEventHandler("onClientGUITabSwitched", getRootElement( ), function(selectedTab)
		-- If there is a selected tab.
		if selectedTab ~= nil then 
			for i = 1, #tab do
				if isElement(tabPanel) and guiGetSelectedTab ( tabPanel ) == tab[i] then
					setElementData(getLocalPlayer(), "cmd:currentTabIndex", i, false)
					break
				end
			end
		end	
	end)
end
addEvent("admin-system:showadmincmds", true)
addEventHandler("admin-system:showadmincmds", getLocalPlayer(), adminhelp)

function closeAhWindow()
	if myadminWindow then 
		destroyElement(myadminWindow)
		showCursor (false)
		guiSetInputEnabled(false)
		myadminWindow = nil
		closeCmdModifyWindow()
	end
end

function copyToClipboard1(button,state)
	local row, col = guiGridListGetSelectedItem(lists[1])
	if (row==-1) or (col==-1) then
		outputChatBox("Please select a command first!", 255, 0, 0)
	else
		local CmdName = tostring(guiGridListGetItemText(lists[1], guiGridListGetSelectedItem(lists[1]), 1))
		if (button == "left") and (state == "up") then
			if setClipboard (CmdName) then
				outputChatBox("Copied monitor content to clipboard.")
			end
		elseif (exports.integration:isPlayerLeadAdmin(getLocalPlayer()) or getElementData(getLocalPlayer(), "hasCmdLibraryAccess")) and (button == "right") and (state == "up") then
			local cmdEx = tostring(guiGridListGetItemText(lists[1], guiGridListGetSelectedItem(lists[1]), 2))
			local cmdID = tonumber(guiGridListGetItemText(lists[1], guiGridListGetSelectedItem(lists[1]), 3))
			drawCmdModifyWindow(cmdID, CmdName, cmdEx,"Trial Admin")
		end
	end
end

function copyToClipboard2(button,state)
	local row, col = guiGridListGetSelectedItem(lists[2])
	if (row==-1) or (col==-1) then
		outputChatBox("Please select a command first!", 255, 0, 0)
	else
		local CmdName = tostring(guiGridListGetItemText(lists[2], guiGridListGetSelectedItem(lists[2]), 1))
		if (button == "left") and (state == "up") then
			if setClipboard (CmdName) then
				outputChatBox("Copied monitor content to clipboard.")
			end
		elseif (exports.integration:isPlayerLeadAdmin(getLocalPlayer()) or getElementData(getLocalPlayer(), "hasCmdLibraryAccess")) and (button == "right") and (state == "up") then
			local cmdEx = tostring(guiGridListGetItemText(lists[2], guiGridListGetSelectedItem(lists[2]), 2))
			local cmdID = tonumber(guiGridListGetItemText(lists[2], guiGridListGetSelectedItem(lists[2]), 3))
			drawCmdModifyWindow(cmdID, CmdName, cmdEx, "Regular Admin")
		end
	end
end

function copyToClipboard3(button,state)
	local row, col = guiGridListGetSelectedItem(lists[3])
	if (row==-1) or (col==-1) then
		outputChatBox("Please select a command first!", 255, 0, 0)
	else
		local CmdName = tostring(guiGridListGetItemText(lists[3], guiGridListGetSelectedItem(lists[3]), 1))
		if (button == "left") and (state == "up") then
			if setClipboard (CmdName) then
				outputChatBox("Copied monitor content to clipboard.")
			end
		elseif (exports.integration:isPlayerLeadAdmin(getLocalPlayer()) or getElementData(getLocalPlayer(), "hasCmdLibraryAccess")) and (button == "right") and (state == "up") then
			local cmdEx = tostring(guiGridListGetItemText(lists[3], guiGridListGetSelectedItem(lists[3]), 2))
			local cmdID = tonumber(guiGridListGetItemText(lists[3], guiGridListGetSelectedItem(lists[3]), 3))
			drawCmdModifyWindow(cmdID, CmdName, cmdEx, "Super Admin")
		end
	end
end

function copyToClipboard4(button,state)
	local row, col = guiGridListGetSelectedItem(lists[4])
	if (row==-1) or (col==-1) then
		outputChatBox("Please select a command first!", 255, 0, 0)
	else
		local CmdName = tostring(guiGridListGetItemText(lists[4], guiGridListGetSelectedItem(lists[4]), 1))
		if (button == "left") and (state == "up") then
			if setClipboard (CmdName) then
				outputChatBox("Copied monitor content to clipboard.")
			end
		elseif (exports.integration:isPlayerLeadAdmin(getLocalPlayer()) or getElementData(getLocalPlayer(), "hasCmdLibraryAccess")) and (button == "right") and (state == "up") then
			local cmdEx = tostring(guiGridListGetItemText(lists[4], guiGridListGetSelectedItem(lists[4]), 2))
			local cmdID = tonumber(guiGridListGetItemText(lists[4], guiGridListGetSelectedItem(lists[4]), 3))
			drawCmdModifyWindow(cmdID, CmdName, cmdEx, "Lead Admin" )
		end
	end
end

function copyToClipboard5(button,state)
	local row, col = guiGridListGetSelectedItem(lists[5])
	if (row==-1) or (col==-1) then
		outputChatBox("Please select a command first!", 255, 0, 0)
	else
		local CmdName = tostring(guiGridListGetItemText(lists[5], guiGridListGetSelectedItem(lists[5]), 1))
		if (button == "left") and (state == "up") then
			if setClipboard (CmdName) then
				outputChatBox("Copied monitor content to clipboard.")
			end
		elseif (exports.integration:isPlayerLeadAdmin(getLocalPlayer()) or getElementData(getLocalPlayer(), "hasCmdLibraryAccess")) and (button == "right") and (state == "up") then
			local cmdEx = tostring(guiGridListGetItemText(lists[5], guiGridListGetSelectedItem(lists[5]), 2))
			local cmdID = tonumber(guiGridListGetItemText(lists[5], guiGridListGetSelectedItem(lists[5]), 3))
			drawCmdModifyWindow(cmdID, CmdName, cmdEx, "Head Admin")
		end
	end
end


local function getAdminLevelFromTitle(text)
	if not text then
		return "1"
	elseif text == "Trial Admin" then
		return "3"
	elseif text == "Admin Admin" then
		return "4"
	elseif text == "Lead Admin" then
		return "5"
	elseif text == "Head Admin" then
		return "6"
	else
		return "1"
	end
end

local function getTypeFromTitle(text)
	if not text then
		return "1"
	elseif text == "(1) Admin Command" then
		return "1"
	elseif text == "(2) GameMaster Command" then
		return "2"
	elseif text == "(3) Player Command" then
		return "3"
	else
		return "1"
	end
end

local function guiComboBoxAdjustHeight ( combobox, itemcount )
    if getElementType ( combobox ) ~= "gui-combobox" or type ( itemcount ) ~= "number" then error ( "Invalid arguments @ 'guiComboBoxAdjustHeight'", 2 ) end
    local width = guiGetSize ( combobox, false )
    return guiSetSize ( combobox, width, ( itemcount * 20 ) + 20, false )
end

local wCmdModify = nil
function drawCmdModifyWindow(cmdID, CmdName, cmdEx, AccessLevel)
	closeCmdModifyWindow()
	local width, height = 343, 189
	local sx, sy = guiGetScreenSize()
	local posX = (sx/2)-(width/2)
	local posY = (sy/2)-(height/2)
	wCmdModify = guiCreateWindow(posX,posY,width,height,"Command Modifying",false)
		guiWindowSetSizable(wCmdModify,false)
	local l1 = guiCreateLabel(14,26,99,24,"Command Name:",false,wCmdModify)
		guiLabelSetVerticalAlign(l1,"center")
		guiSetFont(l1,"default-bold-small")
	local l2 = guiCreateLabel(14,56,99,24,"Explanation:",false,wCmdModify)
		guiLabelSetVerticalAlign(l2,"center")
		guiSetFont(l2,"default-bold-small")
	local eName = guiCreateEdit(113,26,216,24,CmdName,false,wCmdModify)
	local eEx = guiCreateEdit(113,56,216,24,cmdEx,false,wCmdModify)
	local l3 = guiCreateLabel(14,116,99,24,"Type: ",false,wCmdModify)
		guiLabelSetVerticalAlign(l3,"center")
		guiSetFont(l3,"default-bold-small")
		
	local eType = guiCreateComboBox(113,116,216,24,"(1) Admin Command",false,wCmdModify)
		guiComboBoxAddItem(eType, "(1) Admin Command")
		guiComboBoxAddItem(eType, "(2) GameMaster Command")
		guiComboBoxAddItem(eType, "(3) Player Command")
		guiComboBoxAdjustHeight (  eType, 3 )
		
	local l4 = guiCreateLabel(14,86,99,24,"Access Level:",false,wCmdModify)
		guiLabelSetVerticalAlign(l4,"center")
		guiSetFont(l4,"default-bold-small")
		
	local eAccess = guiCreateComboBox(113,86,216,24,AccessLevel,false,wCmdModify)
		guiComboBoxAddItem(eAccess, "Trial Admin")
		guiComboBoxAddItem(eAccess, "Regular Admin")
		guiComboBoxAddItem(eAccess, "Lead Admin")
		guiComboBoxAdjustHeight (  eAccess, 3 )

	local bDel = guiCreateButton(14,150,104,27,"DELETE",false,wCmdModify)
	addEventHandler("onClientGUIClick", bDel , function()
		triggerServerEvent ("admin-system:delCmd", getLocalPlayer(), getLocalPlayer(), cmdID, CmdName )
	end, false)
	
	local bSave = guiCreateButton(118,150,104,27,"SAVE",false,wCmdModify)
	if not cmdID then
		guiSetText(bSave, "Add")
		guiSetEnabled(bDel, false)
	end
	addEventHandler("onClientGUIClick", bSave , function()
		local item = guiComboBoxGetSelected(eAccess)
		local text = guiComboBoxGetItemText(eAccess, item)
		local cmdAccess1 = getAdminLevelFromTitle(text)
		
		item = guiComboBoxGetSelected(eType)
		text = guiComboBoxGetItemText(eType, item)
		local cmdType1 = getTypeFromTitle(text)
		
		--outputDebugString(cmdID.. guiGetText(eName).. guiGetText(eEx)..cmdAccess1..cmdType1)
		triggerServerEvent ("admin-system:saveCmd", getLocalPlayer(), getLocalPlayer(), cmdID, guiGetText(eName), guiGetText(eEx), cmdAccess1, cmdType1 )
	end, false)
	
	local bCancel = guiCreateButton(222,150,107,27,"CANCEL",false,wCmdModify)
	addEventHandler("onClientGUIClick", bCancel , closeCmdModifyWindow , false)
end

function closeCmdModifyWindow()
	if wCmdModify then
		destroyElement(wCmdModify)
		wCmdModify = nil
	end
end


