gmGUI = nil
function createWindow()
	player = source
	local width, height = 508, 272
	local sx, sy = guiGetScreenSize()
	local posX = (sx/2)-(width/2)
	local posY = (sy/2)-(height/2)
	gmGUI = guiCreateWindow(posX, posY, width, height,"GameMaster School Report",false)
	gmLabel1 = guiCreateLabel(20,27,495,17,"Player(s) taught: (Seperate names using ;. Example: Raz Washer;Woody Dingle)",false,gmGUI)
	gmPlayers = guiCreateEdit(19,47,471,24,"None.",false,gmGUI)
	gmLabel2 = guiCreateLabel(20,78,485,22,"Notes: (Please state how the schooling went & how the player reacted to the school)",false,gmGUI)
	gmNotes = guiCreateMemo(19,102,472,130,"None.",false,gmGUI)
	wSubmit = guiCreateButton(43,235,113,28,"Submit",false,gmGUI)
	wCancel = guiCreateButton(344,235,113,28,"Cancel",false,gmGUI)
	addEventHandler("onClientGUIClick", wSubmit, GMPost)
	addEventHandler("onClientGUIClick", wCancel, GMCancel)
end
addEvent("gmpost:gui", true)
addEventHandler("gmpost:gui", getRootElement(), createWindow)

function openGUI()
	if gmGUI then
		destroyElement(gmGUI)
		gmGUI = nil
	end
	
	triggerEvent("gmpost:gui", getLocalPlayer())
	guiSetInputEnabled(true)
	showCursor(true)
end
addEvent("gmpost:opengui", true)
addEventHandler("gmpost:opengui", getRootElement(), openGUI)

function GMPost(button, state)
	if source == wSubmit and button == "left" and state == "up" then
		triggerServerEvent("gmpost:submit", getLocalPlayer(), guiGetText(gmPlayers), guiGetText(gmNotes))
		showCursor(false)
		guiSetInputEnabled(false)
		destroyElement(gmGUI)
	end
end

function GMCancel(button, state)
	if source == wCancel and button == "left" and state == "up" then
		showCursor(false)
		guiSetInputEnabled(false)
		destroyElement(gmGUI)
	end
end