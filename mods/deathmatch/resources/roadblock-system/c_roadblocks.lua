local rbWindow, rbList, bUse, bClose, tempObject, tempObjectID, tempObjectRot = nil
local tempObjectPosX, tempObjectPosY, tempObjectPosZ, tempObjectPosRot, tempObjectZfix = nil
local tempObjectRotX = 0.0
local tempObjectRotY = 0.0
local roadblockID = 	{	"978",				"981", 				"3578", 	"1228", 		"1282", 				"1422", 		"1424", 		"1425",		"1459", 		"3091", 	"1593", 		"1238",		"1237"	} -- objectid
local roadblockTypes = 	{ 	"Small roadblock", 		"Large roadblock", 		"Yellow fence", "Small warning fence", 	"Small warning fence with light", 	"Ugly small fence", 	"Sidewalk block", 	"Detour ->", 	"Warning fence", 	"Vehicles ->",	"Small spikestrip",	"Traffic Cone",	"Pole"} -- name
local roadblockRot = 	{	"180",				"0", 				"0",		"90",			"90",					"0",			"0",			"0",		"0",			"0",		"90", 			"0",		"0" } -- rotation needed to face to player
local roadblockZ = 		{"0",				"0",				"0",		"0",			"0",					"0",			"0",			"0",		"0",			"0",		"-0.4",			"-0.18",	"-0.45" } -- Height fix				
local thePlayer = getLocalPlayer()
local new = true
local eventon = false

function enableRoadblockGUI(parameter)
	local faction = exports.factions:getCurrentFactionDuty(thePlayer)
	if not (rbWindow) and faction then
		local width, height = 300, 400
		local scrWidth, scrHeight = guiGetScreenSize()
		
		local x = scrWidth*0.8 - (width/2)
		local y = scrHeight*0.75 - (height/2)
	
		rbWindow = guiCreateWindow ( x, y, width, height, "Create Roadblocks", false)
		rbList = guiCreateGridList(0.05, 0.05, 0.9, 0.8, true, rbWindow)
		addEventHandler("onClientGUIDoubleClick", rbList, selectRoadblockGUI, false)
		local column = guiGridListAddColumn(rbList, "ID", 0.2)
		local column2 = guiGridListAddColumn(rbList, "Type", 0.5)
		local column3 = guiGridListAddColumn(rbList, "Rot", 0.1)
		local column4 = guiGridListAddColumn(rbList, "Z", 0.1)
		
		--[[
		for key, value in ipairs(roadblockID) do
			local newRow = guiGridListAddRow(rbList)
			guiGridListSetItemText(rbList, newRow, column, roadblockID[key], true, false)
			guiGridListSetItemText(rbList, newRow, column2, roadblockTypes[key], false, false)
			guiGridListSetItemText(rbList, newRow, column3, roadblockRot[key], false, false)
			guiGridListSetItemText(rbList, newRow, column4, roadblockZ[key], false, false)
		end
		--]]
		local faction = exports.factions:getCurrentFactionDuty(thePlayer)
		local theTeam = exports.factions:getFactionFromID(faction)
		local factionType = tonumber(getElementData(theTeam, "type"))
		local allowedObjects = {}
		local alreadyAdded = {}

		if(roadblocks[-factionType] and #roadblocks[-factionType] > 0) then
			for key,value in ipairs(roadblocks[-factionType]) do
				if not alreadyAdded[value[2]] then
					table.insert(allowedObjects, value)
					alreadyAdded[value[2]] = true
				end
			end
		end
		if(roadblocks[faction] and #roadblocks[faction] > 0) then
			for key,value in ipairs(roadblocks[faction]) do
				if not alreadyAdded[value[2]] then
					table.insert(allowedObjects, value)
					alreadyAdded[value[2]] = true
				end
			end
		end
		
		for key, value in ipairs(allowedObjects) do
			local newRow = guiGridListAddRow(rbList)
			guiGridListSetItemText(rbList, newRow, column, value[2], true, false)
			guiGridListSetItemText(rbList, newRow, column2, value[1], false, false)
			guiGridListSetItemText(rbList, newRow, column3, value[3], false, false)
			guiGridListSetItemText(rbList, newRow, column4, value[4], false, false)
		end


		bUse = guiCreateButton(0.05, 0.85, 0.45, 0.1, "Use", true, rbWindow)
		addEventHandler("onClientGUIClick", bUse, selectRoadblockGUI, false)
		
		bClose = guiCreateButton(0.5, 0.85, 0.45, 0.1, "Close", true, rbWindow)
		addEventHandler("onClientGUIClick", bClose, cancelRoadblockGUI, false)
	
		outputChatBox("Select a roadblock in the GUI, place it on the spot you want.", 0, 255, 0)
		outputChatBox("Press use -, =, [, ], pgup and pgdn to rotate your object", 0, 255, 0)
		outputChatBox("Press [SPACE] to save a object.", 0, 255, 0)
	
		if not isCursorShowing() then showCursor(true) end
	else
		cleanupRoadblockGUI()
	end
end

function cleanupRoadblockGUI()
	cleanupRoadblock()
	if rbWindow then
		destroyElement(rbWindow)
		rbWindow = nil
	end
	if isCursorShowing() then showCursor(false) end
end

function cleanupRoadblock()
	if (isElement(tempObject)) then
		destroyElement(tempObject)
		tempObjectPosX, tempObjectPosY, tempObjectPosZ, tempObjectPosRot = nil
		tempObjectID, tempObjectRot = nil
		tempObjectRotX = 0.0
		tempObjectRotY = 0.0
		new = true
		unbindKey ( "space", "down", convertTempToRealObject)
	unbindKey ( "pgup", "down", zUp)
	unbindKey ( "pgdn", "down", zDown)
	unbindKey ( "=", "down", xUp)
	unbindKey ( "-", "down", xDown)
	unbindKey ( "]", "down", yUp)
	unbindKey ( "[", "down", yDown)
	end
	if eventon then
		removeEventHandler("onClientPreRender",getRootElement(),updateRoadblockObject)
		eventon = false
	end
end

function selectRoadblockGUI(button, state)
	if (source==bUse) and (button=="left") or (source==rbList) and (button=="left") then
		local row, col = guiGridListGetSelectedItem(rbList)
		
		if (row==-1) or (col==-1) then
			outputChatBox("Please select a type first!", 255, 0, 0)
		else
			cleanupRoadblock()
			
			local objectid = tonumber(guiGridListGetItemText(rbList, guiGridListGetSelectedItem(rbList), 1))
			local objectrot = tonumber(guiGridListGetItemText(rbList, guiGridListGetSelectedItem(rbList), 3))
			local objectz = tonumber(guiGridListGetItemText(rbList, guiGridListGetSelectedItem(rbList), 4))
			spawnTempObject(objectid, objectrot, objectz)
			if isCursorShowing() then showCursor(false) end
		end
	end
end

function spawnTempObject(objectid, objectrot, objectz)
	-- create temporary object
	tempObjectID = objectid
	tempObjectRot = objectrot
	tempObjectZfix = objectz
	tempObject = createObject( objectid, 0, 0, 0, 0, 0, 0)
	setElementAlpha(tempObject, 200)
	setElementInterior ( tempObject, getElementInterior ( thePlayer ) )
	setElementDimension ( tempObject, getElementDimension ( thePlayer ) )

	bindKey ( "space", "down", convertTempToRealObject)
	bindKey ( "pgup", "down", zUp)
	bindKey ( "pgdn", "down", zDown)
	bindKey ( "=", "down", xUp)
	bindKey ( "-", "down", xDown)
	bindKey ( "]", "down", yUp)
	bindKey ( "[", "down", yDown)
	updateRoadblockObject()
	new = false
	if not eventon then
		addEventHandler("onClientPreRender",getRootElement(),updateRoadblockObject)
		eventon = true
	end
end

function convertTempToRealObject(key, keyState)
	if (isElement(tempObject)) then
		triggerServerEvent("roadblockCreateWorldObject", thePlayer, tempObjectID, tempObjectPosX, tempObjectPosY, tempObjectPosZ, tempObjectPosRot, tempObjectRotX, tempObjectRotY)
		cleanupRoadblock()
		if not isCursorShowing() then showCursor(true) end
	end
end

function updateRoadblockObject(key, keyState)
	if (isElement(tempObject)) then
		local distance = 6
		local px, py, pz = getElementPosition ( thePlayer )
		local rz = getPedRotation ( thePlayer )    

		local x = distance*math.cos((rz+90)*math.pi/180)
		local y = distance*math.sin((rz+90)*math.pi/180)
		local b2 = 15 / math.cos(math.pi/180)
		local nx = px + x
		local ny = py + y
		local nz = tempObjectPosZ
		if (new) then
			nz = pz - 0.5
		end
		  
		local objrot =  rz + tempObjectRot
		if (objrot > 360) then
			objrot = objrot-360
		end
		 
		if tempObjectZfix ~= 0 then
			nz = nz + tempObjectZfix
			tempObjectZfix = 0
		end
		  
		setElementRotation ( tempObject, tempObjectRotX, tempObjectRotY, objrot )
		moveObject ( tempObject, 10, nx, ny, nz)
		
		tempObjectPosX = nx
		tempObjectPosY = ny
		tempObjectPosZ = nz
		tempObjectPosRot = objrot
	end
end
function xDown()
	tempObjectRotX = tempObjectRotX - 1
end
function xUp()
	tempObjectRotX = tempObjectRotX + 1
end
function yDown()
	tempObjectRotY = tempObjectRotY - 1
end
function yUp()
	tempObjectRotY = tempObjectRotY + 1
end
function zDown()
	tempObjectPosZ  = tempObjectPosZ - 0.1
end
function zUp()
	tempObjectPosZ  = tempObjectPosZ + 0.1
end
function cancelRoadblockGUI(button, state)
	if (source==bClose) and (button=="left") then
		cleanupRoadblockGUI()
	end
end

addEvent( "enableRoadblockGUI", true )
addEventHandler( "enableRoadblockGUI", getRootElement(), enableRoadblockGUI )