vehTheftGUI = nil
function createWindow()
	player = source
	local width, height = 486, 314
	local sx, sy = guiGetScreenSize()
	local posX = (sx/2)-(width/2)
	local posY = (sy/2)-(height/2)
	vehTheftGUI = guiCreateWindow(posX,posY,width,height,"vehTheft - Forum Poster",false)
	EngineCheck = guiCreateCheckBox(41,115,16,20,"",false,false,vehTheftGUI)
	KeyCheck = guiCreateCheckBox(41,100,15,14,"",false,false,vehTheftGUI)
	KeyLabel = guiCreateLabel(64,99,67,18,"Spawn Key",false,vehTheftGUI)
	guiSetProperty(KeyLabel,"Text","Spawn Key")
	EngineLabel = guiCreateLabel(64,118,67,18,"Start Engine",false,vehTheftGUI)
	guiSetProperty(EngineLabel,"Text","Start Engine")
	vehTheftLabel = guiCreateLabel(32,40,68,20,"Vehicle ID:",false,vehTheftGUI)
	guiSetProperty(vehTheftLabel,"Text","Vehicle ID:")
	vehIDLabel = guiCreateLabel(96,40,64,19,"N/A",false,vehTheftGUI)
	pNameLabel = guiCreateLabel(32,62,73,17,"Player Name:",false,vehTheftGUI)
	guiSetProperty(pNameLabel,"Text","Player Name:")
	pName = guiCreateLabel(108,63,186,21,"N/A",false,vehTheftGUI)
	noteLabel = guiCreateLabel(28,155,81,21,"Notes:",false,vehTheftGUI)
	guiSetProperty(noteLabel,"Text","Notes:")
	noteEdit = guiCreateMemo(73,181,356,86,"None.",false,vehTheftGUI)
	guiMemoSetReadOnly(noteEdit, false)
	SellVehCheck = guiCreateCheckBox(156,101,15,14,"",false,false,vehTheftGUI)
	SellVehLabel = guiCreateLabel(178,100,74,17,"Sell Vehicle",false,vehTheftGUI)
	guiSetProperty(SellVehLabel,"Text","Sell Vehicle")
	ChangeLockCheck = guiCreateCheckBox(156,119,16,15,"",false,false,vehTheftGUI)
	ChangeLockLabel = guiCreateLabel(178,119,98,17,"Change Locks",false,vehTheftGUI)
	guiSetProperty(ChangeLockLabel,"Text","Change Locks")
	fPost = guiCreateButton(59,274,110,28,"Post",false,vehTheftGUI)
	guiSetProperty(fPost,"Text","Post")
	wCancel = guiCreateButton(320,274,107,29,"Cancel",false,vehTheftGUI)
	guiSetProperty(wCancel,"Text","Cancel")
	addEventHandler ( "onClientRender", getRootElement(), renderData )
	removeEventHandler ( "onClientRender", getRootElement(), renderData )
	addEventHandler( "onClientGUIClick", wCancel, CloseTheft )
	addEventHandler( "onClientGUIClick", fPost, postTheft )



end
addEvent("theft:gui", true)
addEventHandler("theft:gui", getRootElement(), createWindow)

local targetPlayer = nil
function renderData(targetPlayerName, targetVehicle, _targetPlayer)
	if vehTheftGUI then
		destroyElement(vehTheftGUI)
		vehTheftGUI = nil
	end
	triggerEvent("theft:gui", getLocalPlayer())
	guiSetInputEnabled(true)
	showCursor(true)
	
	targetPlayer = _targetPlayer
	
    guiSetText(pName, targetPlayerName)
	guiSetText(vehIDLabel, targetVehicle)
end
addEvent("theft:render", true)
addEventHandler("theft:render", getRootElement(), renderData)

function CloseTheft(button, state)
	if source == wCancel and button == "left" and state == "up" then
		showCursor(false)
		destroyElement(vehTheftGUI)
		guiSetInputEnabled(false)
	end
end

function postTheft(button, state)
	if source == fPost and button == "left" and state == "up" then
		triggerServerEvent("forum:theftpost", getLocalPlayer(), guiGetText(noteEdit), guiCheckBoxGetSelected(EngineCheck), guiCheckBoxGetSelected(KeyCheck), guiGetText(pName), guiGetText(vehIDLabel), targetPlayer, guiCheckBoxGetSelected(SellVehCheck), guiCheckBoxGetSelected(ChangeLockCheck))
		showCursor(false)
		destroyElement(vehTheftGUI)
		guiSetInputEnabled(false)
	end
end