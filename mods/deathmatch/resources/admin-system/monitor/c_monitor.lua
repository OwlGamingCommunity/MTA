wMonitor, monitorList, bRemove, bCancel = nil

function showMonitorWindow(content, ableToRemove)
	if wMonitor then
		destroyElement(wMonitor)
		wMonitor = nil
	end
	
	local width, height = 635, 436
	local scrWidth, scrHeight = guiGetScreenSize()
	local x = scrWidth/2 - (width/2)
	local y = scrHeight/2 - (height/2)
	
	wMonitor = guiCreateWindow(x, y, width, height,"Admin Monitor v1.0",false)
		guiWindowSetSizable(wMonitor,false)
	monitorList = guiCreateGridList(9,26,617,375,false,wMonitor)
	local column = guiGridListAddColumn(monitorList, "Username", 0.2)
	local column2 = guiGridListAddColumn(monitorList, "Playername", 0.25)
	local column3 = guiGridListAddColumn(monitorList, "Reason", 1)
	
	for row, value in ipairs( content ) do
		local row = guiGridListAddRow(monitorList)
		guiGridListSetItemText(monitorList, row, column, value[1], false, false)
		guiGridListSetItemText(monitorList, row, column2, value[2], false, false)
		guiGridListSetItemText(monitorList, row, column3, value[3], false, false)
	end
	
	bRemove = guiCreateButton(10,405,201,22,"REMOVE",false, wMonitor)
	bEdit = guiCreateButton(211,405,214,22,"EDIT",false,wMonitor)
	bCancel = guiCreateButton(425,405,201,22,"CANCEL",false,wMonitor)
	
	if (ableToRemove) then
		addEventHandler("onClientGUIClick", bRemove, removePlayerFromList, false)
		addEventHandler("onClientGUIClick", bEdit, editPlayerFromList, false)
	else
		guiSetEnabled(bRemove,false)
		guiSetEnabled(bEdit,false)
	end
	
	addEventHandler("onClientGUIClick", bCancel, closeMonitor, false)
	addEventHandler("onClientGUIDoubleClick", monitorList, copyMonitorToClipboard, false)
	showCursor(true)

end
addEvent("onMonitorPopup", true)
addEventHandler("onMonitorPopup", getRootElement(), showMonitorWindow)

function removePlayerFromList(button, state)
	if button == "left" and state == "up" then
		local row, col = guiGridListGetSelectedItem(monitorList)
		
		if (row==-1) or (col==-1) then
			outputChatBox("Please select a player first!", 255, 0, 0)
		else
			local name = tostring(guiGridListGetItemText(monitorList, guiGridListGetSelectedItem(monitorList), 2))
			local player = getPlayerFromName(name:gsub(" ", "_"))
			if player then
				triggerServerEvent("monitor:remove", player)
			else
				outputChatBox("No such player (anymore)...", 255, 0, 0)
			end
		end
	end
end

function editPlayerFromList(button, state)
	if button == "left" and state == "up" then
		local row, col = guiGridListGetSelectedItem(monitorList)
		if (row==-1) or (col==-1) then
			outputChatBox("Please select a player first!", 255, 0, 0)
		else
			local name = tostring(guiGridListGetItemText(monitorList, guiGridListGetSelectedItem(monitorList), 2))
			local player = getPlayerFromName(name:gsub(" ", "_"))
			if player then
				showMonitorEdit(tostring(guiGridListGetItemText(monitorList, guiGridListGetSelectedItem(monitorList), 1)), tostring(guiGridListGetItemText(monitorList, guiGridListGetSelectedItem(monitorList), 2)), tostring(guiGridListGetItemText(monitorList, guiGridListGetSelectedItem(monitorList), 3)))
			else
				outputChatBox("No such player (anymore)...", 255, 0, 0)
			end
		end
	end
end

function copyMonitorToClipboard(button, state)
	if button == "left" and state == "up" then
		local row, col = guiGridListGetSelectedItem(monitorList)
		if (row==-1) or (col==-1) then
			outputChatBox("Please select a player first!", 255, 0, 0)
		else
			local name = tostring(guiGridListGetItemText(monitorList, guiGridListGetSelectedItem(monitorList), 2))
			local player = getPlayerFromName(name:gsub(" ", "_"))
			if player then
				if setClipboard ( tostring(guiGridListGetItemText(monitorList, guiGridListGetSelectedItem(monitorList), 3)) ) then
					outputChatBox("Copied monitor content to clipboard.")
				end
			else
				outputChatBox("No such player (anymore)...", 255, 0, 0)
			end
		end
	end
end

function closeMonitor(button, state)
	if button == "left" and state == "up" then
		destroyElement(wMonitor)
		wMonitor = nil
		showCursor(false)
	end
end


local guiLogIn = nil
 -- log in window
 
function showoMonitorAdd()
	if guiLogIn then
		return
	end
	local screenwidth, screenheight = guiGetScreenSize ()
	
	local Width = 250
	local Height = 150
	local X = (screenwidth - Width)/2
	local Y = (screenheight - Height)/2
	
	guiLogIn = guiCreateWindow ( X , Y , Width , Height , "Add someone to the monitor system" , false )
	
	guiUserLabel  = guiCreateLabel(0.05, 0.15, 0.9, 0.2, "Exact Username:", true, guiLogIn)
	guiUserNameEdit = guiCreateEdit(0.05, 0.25, 0.9, 0.2, "", true, guiLogIn)
	guiPasswordLabel  = guiCreateLabel(0.05, 0.45, 0.9, 0.2, "Reason:", true, guiLogIn)
	guiPasswordEdit = guiCreateEdit(0.05, 0.55, 0.9, 0.2, "", true, guiLogIn)

	guiLogInBackButton = guiCreateButton(0.15, 0.8, 0.3, 0.2, "Cancel", true, guiLogIn)
	guiLogInSubmitButton = guiCreateButton(0.55, 0.8, 0.3, 0.2, "Next", true, guiLogIn)
 	
	guiSetInputEnabled ( true)
	-- if the player has clicked back, just close the windows
	addEventHandler ( "onClientGUIClick", guiLogInBackButton,  function(button, state)
		if(button == "left") then
			destroyElement(guiLogIn)
			guiSetInputEnabled ( false)
			guiLogIn = nil
		end
	end, false)
	
	-- if the player has clicked log in, get the name and password details, and send it to the server
	addEventHandler ( "onClientGUIClick", guiLogInSubmitButton,  function(button, state)
		if(button == "left") then
			triggerServerEvent("monitor:add", getLocalPlayer(), guiGetText(guiUserNameEdit),  guiGetText(guiPasswordEdit))
			destroyElement(guiLogIn)
			guiSetInputEnabled ( false)
			 guiLogIn = nil
		end
	end, false)
	
	-- GUIEditor_Window = {}
	-- GUIEditor_Button = {}
	-- GUIEditor_Label = {}
	-- GUIEditor_Edit = {}

	-- GUIEditor_Window[1] = guiCreateWindow(377,351,240,79,"",false)
	-- guiWindowSetSizable(GUIEditor_Window[1],false)
	-- GUIEditor_Label[1] = guiCreateLabel(11,22,64,22,"Username:",false,GUIEditor_Window[1])
	-- guiLabelSetVerticalAlign(GUIEditor_Label[1],"center")
	-- guiLabelSetHorizontalAlign(GUIEditor_Label[1],"center",false)
	-- guiSetFont(GUIEditor_Label[1],"default-bold-small")
	-- GUIEditor_Edit[1] = guiCreateEdit(81,22,150,22,"",false,GUIEditor_Window[1])
	-- GUIEditor_Button[1] = guiCreateButton(11,50,109,20,"Cancel",false,GUIEditor_Window[1])
	-- GUIEditor_Button[2] = guiCreateButton(120,50,111,20,"Next",false,GUIEditor_Window[1])
	
	
end
addEvent("monitor:oadd", true)
addEventHandler("monitor:oadd", getRootElement(), showoMonitorAdd)

function showoMonitorAdd2()
	if guiLogIn then
		return
	end
	local screenwidth, screenheight = guiGetScreenSize ()
	
	local Width = 240
	local Height = 79
	local X = (screenwidth - Width)/2
	local Y = (screenheight - Height)/2
	
	guiSetInputEnabled (true)
	guiLogIn = guiCreateWindow(X,Y,Width,Height,"Admin Monitor",false)
		guiWindowSetSizable(guiLogIn,false)
	guiUserLabel = guiCreateLabel(11,22,64,22,"Username:",false,guiLogIn)
		guiLabelSetVerticalAlign(guiUserLabel,"center")
		guiLabelSetHorizontalAlign(guiUserLabel,"center",false)
		guiSetFont(guiUserLabel,"default-bold-small")
	guiUserNameEdit = guiCreateEdit(81,22,150,22,"",false,guiLogIn)
	guiLogInBackButton = guiCreateButton(11,50,109,20,"Cancel",false,guiLogIn)
	guiLogInSubmitButton = guiCreateButton(120,50,111,20,"Next",false,guiLogIn)
	
	addEventHandler ( "onClientGUIClick", guiLogInBackButton,  function(button, state)
		if(button == "left") then
			destroyElement(guiLogIn)
			guiSetInputEnabled ( false)
			guiLogIn = nil
		end
	end, false)
	
	addEventHandler ( "onClientGUIClick", guiLogInSubmitButton,  function(button, state)
		if(button == "left") then
			triggerServerEvent("monitor:checkUsername", getLocalPlayer(), guiGetText(guiUserNameEdit))
			destroyElement(guiLogIn)
			guiSetInputEnabled ( false)
			guiLogIn = nil
		end
	end, false)
end
addEvent("monitor:oadd2", true)
addEventHandler("monitor:oadd2", getRootElement(), showoMonitorAdd2)


function showMonitorEdit(username, charname, monitorContent)
	guiSetInputEnabled ( true)
	
	local screenwidth, screenheight = guiGetScreenSize ()
	local Width = 420
	local Height = 165
	local X = (screenwidth - Width)/2
	local Y = (screenheight - Height)/2
	
	wMonitorEdit = guiCreateWindow(X, Y, Width,Height,"Admin Monitor on "..charname.."("..username..")",false)
		guiWindowSetSizable(wMonitorEdit,false)
	mMonitorContent = guiCreateMemo(9,25,402,113,monitorContent,false,wMonitorEdit)
	bSave1 = guiCreateButton(9,138,201,21,"SAVE",false,wMonitorEdit)
	bCancel1 = guiCreateButton(210,138,201,21,"CANCEL",false,wMonitorEdit)
	addEventHandler ( "onClientGUIClick", bCancel1,  function(button, state)
		if(button == "left") then
			destroyElement(wMonitorEdit)
			guiSetInputEnabled ( false)
			wMonitorEdit = nil
		end
	end, false)
	
	addEventHandler ( "onClientGUIClick", bSave1,  function(button, state)
		if(button == "left") then
			triggerServerEvent("monitor:onSaveEdittedMonitor",getLocalPlayer(),getLocalPlayer(), username, guiGetText(mMonitorContent), tostring(charname):gsub(" ", "_"))
			destroyElement(wMonitorEdit)
			guiSetInputEnabled ( false)
			wMonitorEdit = nil
		end
	end, false)
end
