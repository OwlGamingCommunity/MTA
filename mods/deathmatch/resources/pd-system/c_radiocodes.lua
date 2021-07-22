local myWindow = nil
local memoCodes = nil
local memoProcedure = nil
local content = {}
local clientFirstTime = true
function displayPdCodes(contentFromServer)
    closePdCodes() --This make sure the GUI doesn't get doubled when you type the cmd twice.
	if clientFirstTime then
		triggerServerEvent("refreshPdCodes", localPlayer)
		clientFirstTime = false
		return false
	end
	if not exports.factions:isPlayerInFaction(localPlayer, 1) then --if player isn't in PD then stop script here, do nothing.
		return false
	end
	
    if contentFromServer and type(contentFromServer) == "table" then --get an updated version of data from server if any.
	outputDebugString("Updated content from server.")
		content = contentFromServer
	end
	
	myWindow = guiCreateWindow( 0.25, 0.25, 0.5, 0.5, "Los Santos Government - Radio Codes & Procedures - V2.0",true)
	local tabPanel = guiCreateTabPanel ( 0, 0.12, 1, 1, true, myWindow ) 
	
	--Response & Ten Codes
	local tabCodes = guiCreateTab( "Response & Ten Codes", tabPanel )
	
	memoCodes = guiCreateMemo ( 0.02, 0.02, 0.96, 0.96, content.codes or "It's lonely here or content is out of date. \n\nPlease refresh..", true, tabCodes )
	guiMemoSetReadOnly(memoCodes, true)
	
	--Radio Procedures
	local tabProcedure = guiCreateTab( "Radio procedures", tabPanel )
	memoProcedure = guiCreateMemo ( 0.02, 0.02, 0.96, 0.96, content.procedures or "It's lonely here or content is out of date. \n\nPlease refresh..", true, tabProcedure )
	guiMemoSetReadOnly(memoProcedure, true)
	
	local tlBackButton = guiCreateButton(0.89, 0.05, 0.1, 0.07, "Close", true, myWindow) -- close button      
	addEventHandler("onClientGUIClick", tlBackButton, closePdCodes, false)
	
	--Update the window(s)
	local tlSaveButton = guiCreateButton(0.77, 0.05, 0.1, 0.07, "Save", true, myWindow) -- save button, hidden from players
	addEventHandler("onClientGUIClick", tlSaveButton, function()
		local contentToBeUpdated = {}
		contentToBeUpdated.codes = guiGetText(memoCodes)
		contentToBeUpdated.procedures = guiGetText(memoProcedure)
		triggerServerEvent("updatePdCodes", localPlayer, contentToBeUpdated)
	end)

	--Refresh the content / You will need to edit the positon for this button, as I just copied and pasted.
	local tlRefreshButton = guiCreateButton(0.65, 0.05, 0.1, 0.07, "Refresh", true, myWindow) 

	
	guiSetVisible(tlSaveButton, false)
	local isInPD, _ = exports.factions:isPlayerInFaction(getLocalPlayer(), 1)
	local pdLeader = exports.factions:hasMemberPermissionTo(getLocalPlayer(), 1, "edit_motd")
	local isInHP, _  = exports.factions:isPlayerInFaction(getLocalPlayer(), 59)
	local hpLeader = exports.factions:hasMemberPermissionTo(getLocalPlayer(), 59, "edit_motd")
	if (isInPD and pdLeader) or (isInHP and hpLeader) then 
		guiSetVisible(tlSaveButton, true)
		guiMemoSetReadOnly(memoProcedure, false)
		guiMemoSetReadOnly(memoCodes, false)
	end -- save button is visible and memo is writeable if leader
	
	addEventHandler("onClientGUIClick", tlRefreshButton, refreshPdCodes)
	showCursor( true ) 
	guiSetInputEnabled(true)
end
addEvent("displayPdCodes", true)
addEventHandler("displayPdCodes", root, displayPdCodes)
addCommandHandler("pdcodes", displayPdCodes)

function refreshPdCodes()
	triggerServerEvent("refreshPdCodes", localPlayer)
end

function closePdCodes()
	if myWindow and isElement(myWindow) then --If 
		showCursor(false)
		destroyElement(myWindow)
		tlBackButton = nil
		myWindow = nil
	end
	guiSetInputEnabled(false)
end