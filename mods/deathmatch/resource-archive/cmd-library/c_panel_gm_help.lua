--MAXIME
local myGMWindow = nil
local listsGM = {}

function GMHelp (commands, scriptUpdates)
	closeGhWindow()
	guiSetInputEnabled(true)
	myGMWindow = guiCreateWindow ( 0.15, 0.15, 0.7, 0.7,  "Index of GM commands | Dynamic Commands Library by Maxime - OG", true)
	guiWindowSetSizable(myGMWindow, false)
	
	guiCreateLabel(0.02, 0.05, 0.6, 0.05,"Left click to copy command to clipboard, Right click to modify command", true, myGMWindow)
	
	local tabPanel = guiCreateTabPanel (0, 0.1, 1, 1, true, myGMWindow)
	local tab = {}
	for level = 1, 5 do 
		local tabName = "Trial+"
		if level == 2 then
			tabName = "Regular+"
		elseif level == 3 then
			tabName = "Senior+"
		elseif level == 4 then
			tabName = "Lead+"
		elseif level == 5 then
			tabName = "Head+"
		end
		
		tab[level] = guiCreateTab(tabName, tabPanel)
		listsGM[level] = guiCreateGridList(0.02, 0.02, 0.96, 0.96, true, tab[level])  
		guiGridListAddColumn (listsGM[level], "Command", 0.2)
		guiGridListAddColumn (listsGM[level], "Explanation", 1.5)
		guiGridListAddColumn (listsGM[level], "Cmd ID", 0.2)
	end
	
	for level, levelcmds in pairs( commands ) do
		if #levelcmds == 0 then
			local row = guiGridListAddRow ( listsGM[level] )
			guiGridListSetItemText ( listsGM[level], row, 1, "-", false, false)
			guiGridListSetItemText ( listsGM[level], row, 2, "There are currently no commands specific to this level.", false, false)
			guiGridListSetItemText ( listsGM[level], row, 3, "-", false, false)
		else
			for _, command in pairs( levelcmds ) do
				local row = guiGridListAddRow ( listsGM[level] )
				guiGridListSetItemText ( listsGM[level], row, 1, command[1], false, false)
				guiGridListSetItemText ( listsGM[level], row, 2, command[2], false, false)
				guiGridListSetItemText ( listsGM[level], row, 3, command[3], false, false)
			end
		end
	end
	
	tab[6] = guiCreateTab( "Gamemaster Rules & Recent Updates", tabPanel )
	local memoGMRules = guiCreateMemo (  0.02, 0.02, 0.96, 0.96, getElementData(getResourceRootElement(getResourceFromName("account-system")), "gmrules:text") or "Error fetching...", true, tab[6] ) 
	guiMemoSetReadOnly(memoGMRules, true)
	
	tab[7] = guiCreateTab( "Recent Script Changes", tabPanel )
	local memoScriptChanges = guiCreateMemo (  0.02, 0.02, 0.96, 0.90, scriptUpdates or "Coming soon ;)", true, tab[7] ) 
	local bUpdate = guiCreateButton(  0.02, 0.92, 0.96, 0.06, "Update", true, tab[7] ) 
	addEventHandler ("onClientGUIClick", bUpdate, function()
		triggerServerEvent ("admin-system:updateScriptGM", getLocalPlayer(), getLocalPlayer(), guiGetText(memoScriptChanges) )
	end, false)
	if not exports.integration:isPlayerLeadAdmin(getLocalPlayer()) and not getElementData(getLocalPlayer(), "hasCmdLibraryAccess") then
		guiMemoSetReadOnly(memoScriptChanges, true)
		guiSetEnabled(bUpdate, false)
	end
	
	local tlBackButton = guiCreateButton(0.8, 0.04, 0.2, 0.06, "Close", true, myGMWindow) -- close button
	addEventHandler ("onClientGUIClick", tlBackButton, closeGhWindow , false)
	
	if exports.integration:isPlayerLeadAdmin(getLocalPlayer()) or getElementData(getLocalPlayer(), "hasCmdLibraryAccess") then
		local bAdd = guiCreateButton(0.6, 0.04, 0.2, 0.06, "Add New Command", true, myGMWindow) -- close button
		addEventHandler ("onClientGUIClick", bAdd, function(button, state)
			if (button == "left") then
				if (state == "up") then
					drawCmdModifyWindowGM(false, "", "", "Trial GM")
				end
			end
		end, false)
	end
	
	addEventHandler("onClientGUIClick", listsGM[1] , copyToClipboard1GM , false)
	addEventHandler("onClientGUIClick", listsGM[2] , copyToClipboard2GM , false)
	addEventHandler("onClientGUIClick", listsGM[3] , copyToClipboard3GM , false)
	addEventHandler("onClientGUIClick", listsGM[4] , copyToClipboard4GM , false)
	addEventHandler("onClientGUIClick", listsGM[5] , copyToClipboard5GM , false)
	
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
addEvent("admin-system:showGMcmds", true)
addEventHandler("admin-system:showGMcmds", getLocalPlayer(), GMHelp)

function closeGhWindow()
	if myGMWindow then 
		destroyElement(myGMWindow)
		showCursor (false)
		guiSetInputEnabled(false)
		myGMWindow = nil
		closeCmdModifyWindowGM()
	end
end

function copyToClipboard1GM(button,state)
	local row, col = guiGridListGetSelectedItem(listsGM[1])
	if (row==-1) or (col==-1) then
		outputChatBox("Please select a command first!", 255, 0, 0)
	else
		local CmdName = tostring(guiGridListGetItemText(listsGM[1], guiGridListGetSelectedItem(listsGM[1]), 1))
		if (button == "left") and (state == "up") then
			if setClipboard (CmdName) then
				outputChatBox("Copied monitor content to clipboard.")
			end
		elseif (exports.integration:isPlayerLeadAdmin(getLocalPlayer()) or getElementData(getLocalPlayer(), "hasCmdLibraryAccess")) and (button == "right") and (state == "up") then
			local cmdEx = tostring(guiGridListGetItemText(listsGM[1], guiGridListGetSelectedItem(listsGM[1]), 2))
			local cmdID = tonumber(guiGridListGetItemText(listsGM[1], guiGridListGetSelectedItem(listsGM[1]), 3))
			drawCmdModifyWindowGM(cmdID, CmdName, cmdEx,"Trial GM")
		end
	end
end

function copyToClipboard2GM(button,state)
	local row, col = guiGridListGetSelectedItem(listsGM[2])
	if (row==-1) or (col==-1) then
		outputChatBox("Please select a command first!", 255, 0, 0)
	else
		local CmdName = tostring(guiGridListGetItemText(listsGM[2], guiGridListGetSelectedItem(listsGM[2]), 1))
		if (button == "left") and (state == "up") then
			if setClipboard (CmdName) then
				outputChatBox("Copied monitor content to clipboard.")
			end
		elseif (exports.integration:isPlayerLeadAdmin(getLocalPlayer()) or getElementData(getLocalPlayer(), "hasCmdLibraryAccess")) and (button == "right") and (state == "up") then
			local cmdEx = tostring(guiGridListGetItemText(listsGM[2], guiGridListGetSelectedItem(listsGM[2]), 2))
			local cmdID = tonumber(guiGridListGetItemText(listsGM[2], guiGridListGetSelectedItem(listsGM[2]), 3))
			drawCmdModifyWindowGM(cmdID, CmdName, cmdEx, "Regular GM")
		end
	end
end

function copyToClipboard3GM(button,state)
	local row, col = guiGridListGetSelectedItem(listsGM[3])
	if (row==-1) or (col==-1) then
		outputChatBox("Please select a command first!", 255, 0, 0)
	else
		local CmdName = tostring(guiGridListGetItemText(listsGM[3], guiGridListGetSelectedItem(listsGM[3]), 1))
		if (button == "left") and (state == "up") then
			if setClipboard (CmdName) then
				outputChatBox("Copied monitor content to clipboard.")
			end
		elseif (exports.integration:isPlayerLeadAdmin(getLocalPlayer()) or getElementData(getLocalPlayer(), "hasCmdLibraryAccess")) and (button == "right") and (state == "up") then
			local cmdEx = tostring(guiGridListGetItemText(listsGM[3], guiGridListGetSelectedItem(listsGM[3]), 2))
			local cmdID = tonumber(guiGridListGetItemText(listsGM[3], guiGridListGetSelectedItem(listsGM[3]), 3))
			drawCmdModifyWindowGM(cmdID, CmdName, cmdEx, "Senior GM")
		end
	end
end

function copyToClipboard4GM(button,state)
	local row, col = guiGridListGetSelectedItem(listsGM[4])
	if (row==-1) or (col==-1) then
		outputChatBox("Please select a command first!", 255, 0, 0)
	else
		local CmdName = tostring(guiGridListGetItemText(listsGM[4], guiGridListGetSelectedItem(listsGM[4]), 1))
		if (button == "left") and (state == "up") then
			if setClipboard (CmdName) then
				outputChatBox("Copied monitor content to clipboard.")
			end
		elseif (exports.integration:isPlayerLeadAdmin(getLocalPlayer()) or getElementData(getLocalPlayer(), "hasCmdLibraryAccess")) and (button == "right") and (state == "up") then
			local cmdEx = tostring(guiGridListGetItemText(listsGM[4], guiGridListGetSelectedItem(listsGM[4]), 2))
			local cmdID = tonumber(guiGridListGetItemText(listsGM[4], guiGridListGetSelectedItem(listsGM[4]), 3))
			drawCmdModifyWindowGM(cmdID, CmdName, cmdEx, "Lead GM" )
		end
	end
end

function copyToClipboard5GM(button,state)
	local row, col = guiGridListGetSelectedItem(listsGM[5])
	if (row==-1) or (col==-1) then
		outputChatBox("Please select a command first!", 255, 0, 0)
	else
		local CmdName = tostring(guiGridListGetItemText(listsGM[5], guiGridListGetSelectedItem(listsGM[5]), 1))
		if (button == "left") and (state == "up") then
			if setClipboard (CmdName) then
				outputChatBox("Copied monitor content to clipboard.")
			end
		elseif (exports.integration:isPlayerLeadAdmin(getLocalPlayer()) or getElementData(getLocalPlayer(), "hasCmdLibraryAccess")) and (button == "right") and (state == "up") then
			local cmdEx = tostring(guiGridListGetItemText(listsGM[5], guiGridListGetSelectedItem(listsGM[5]), 2))
			local cmdID = tonumber(guiGridListGetItemText(listsGM[5], guiGridListGetSelectedItem(listsGM[5]), 3))
			drawCmdModifyWindowGM(cmdID, CmdName, cmdEx, "Head GM")
		end
	end
end

local function getAdminLevelFromTitle(text)
	if not text then
		return "1"
	elseif text == "Trial GM" then
		return "1"
	elseif text == "Regular GM" then
		return "2"
	elseif text == "Senior GM" then
		return "3"
	elseif text == "Lead GM" then
		return "4"
	elseif text == "Head GM" then
		return "5"
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

local wCmdModifyGM = nil
function drawCmdModifyWindowGM(cmdID, CmdName, cmdEx, AccessLevel)
	closeCmdModifyWindowGM()
	local width, height = 343, 189
	local sx, sy = guiGetScreenSize()
	local posX = (sx/2)-(width/2)
	local posY = (sy/2)-(height/2)
	wCmdModifyGM = guiCreateWindow(posX,posY,width,height,"Command Modifying",false)
		guiWindowSetSizable(wCmdModifyGM,false)
	local l1 = guiCreateLabel(14,26,99,24,"Command Name:",false,wCmdModifyGM)
		guiLabelSetVerticalAlign(l1,"center")
		guiSetFont(l1,"default-bold-small")
	local l2 = guiCreateLabel(14,56,99,24,"Explanation:",false,wCmdModifyGM)
		guiLabelSetVerticalAlign(l2,"center")
		guiSetFont(l2,"default-bold-small")
	local eName = guiCreateEdit(113,26,216,24,CmdName,false,wCmdModifyGM)
	local eEx = guiCreateEdit(113,56,216,24,cmdEx,false,wCmdModifyGM)
	local l3 = guiCreateLabel(14,116,99,24,"Type: ",false,wCmdModifyGM)
		guiLabelSetVerticalAlign(l3,"center")
		guiSetFont(l3,"default-bold-small")
		
	local eType = guiCreateComboBox(113,116,216,24,"(2) GameMaster Command",false,wCmdModifyGM)
		guiComboBoxAddItem(eType, "(1) Admin Command")
		guiComboBoxAddItem(eType, "(2) GameMaster Command")
		guiComboBoxAddItem(eType, "(3) Player Command")
		guiComboBoxAdjustHeight (  eType, 3 )
		
	local l4 = guiCreateLabel(14,86,99,24,"Access Level:",false,wCmdModifyGM)
		guiLabelSetVerticalAlign(l4,"center")
		guiSetFont(l4,"default-bold-small")
		
	local eAccess = guiCreateComboBox(113,86,216,24,AccessLevel,false,wCmdModifyGM)
		guiComboBoxAddItem(eAccess, "Trial GM")
		guiComboBoxAddItem(eAccess, "Regular GM")
		guiComboBoxAddItem(eAccess, "Senior GM")
		guiComboBoxAddItem(eAccess, "Lead GM")
		guiComboBoxAddItem(eAccess, "Head GM")
		guiComboBoxAdjustHeight (  eAccess, 5 )

	local bDel = guiCreateButton(14,150,104,27,"DELETE",false,wCmdModifyGM)
	addEventHandler("onClientGUIClick", bDel , function()
		triggerServerEvent ("admin-system:delCmdGM", getLocalPlayer(), getLocalPlayer(), cmdID, CmdName )
	end, false)
	
	local bSave = guiCreateButton(118,150,104,27,"SAVE",false,wCmdModifyGM)
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
		
		triggerServerEvent ("admin-system:saveCmdGM", getLocalPlayer(), getLocalPlayer(), cmdID, guiGetText(eName), guiGetText(eEx), cmdAccess1, cmdType1 )
	end, false)
	
	local bCancel = guiCreateButton(222,150,107,27,"CANCEL",false,wCmdModifyGM)
	addEventHandler("onClientGUIClick", bCancel , closeCmdModifyWindowGM , false)
end

function closeCmdModifyWindowGM()
	if wCmdModifyGM then
		destroyElement(wCmdModifyGM)
		wCmdModifyGM = nil
	end
end


