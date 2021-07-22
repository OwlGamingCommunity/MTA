intPostGUI = nil
function createWindow()
	player = source
	local width, height = 486, 314
	local sx, sy = guiGetScreenSize()
	local posX = (sx/2)-(width/2)
	local posY = (sy/2)-(height/2)
	intPostGUI = guiCreateWindow(posX,posY,width,height,"Interior Break-in // Forum Poster",false)
	fPost = guiCreateButton(102,274,97,30,"Post",false,intPostGUI)
	fCancel = guiCreateButton(231,273,97,30,"Cancel",false,intPostGUI)
	noteEdit = guiCreateMemo(44,106,365,160,"None.",false,intPostGUI)
	guiMemoSetReadOnly(noteEdit, false)
	pName = guiCreateLabel(43,37,383,21,"Player:",false,intPostGUI)
	intDim = guiCreateLabel(43,56,380,22,"Interior ID:",false,intPostGUI)
	iSFIaNLabel = guiCreateLabel(45,87,385,17,"Items stolen from interior + additional notes:",false,intPostGUI)
	addEventHandler("onClientRender", getRootElement(), renderIntData)
	removeEventHandler("onClientRender", getRootElement(), renderIntData)
	addEventHandler("onClientGUIClick", fPost, intPost)
	addEventHandler("onClientGUIClick", fCancel, intCancel)
end
addEvent("intpost:gui", true)
addEventHandler("intpost:gui", getRootElement(), createWindow)

local targetPlayer = nil
local interiorID = nil
local targetPlayerName = nil
function renderIntData(_targetPlayerName, _interiorID, _targetPlayer)
	if intPostGUI then
		destroyElement(intPostGUI)
		intPostGUI = nil
	end
	
	triggerEvent("intpost:gui", getLocalPlayer())
	guiSetInputEnabled(true)
	showCursor(true)
	
	interiorID = _interiorID
	targetPlayer = _targetPlayer
	targetPlayerName = _targetPlayerName
	
	guiSetText(pName, "Player: " ..targetPlayerName)
	guiSetText(intDim, "Interior ID: " ..interiorID)
end
addEvent("intpost:render", true)
addEventHandler("intpost:render", getRootElement(), renderIntData)

function intCancel(button, state)
	if source == fCancel and button == "left" and state == "up" then
		showCursor(false)
		destroyElement(intPostGUI)
		guiSetInputEnabled(false)
	end
end

function intPost(button, state)
	if source == fPost and button == "left" and state == "up" then
		triggerServerEvent("forum:intpost", getLocalPlayer(), guiGetText(noteEdit), targetPlayer, targetPlayerName, interiorID)
		showCursor(false)
		guiSetInputEnabled(false)
		destroyElement(intPostGUI)
	end
end
