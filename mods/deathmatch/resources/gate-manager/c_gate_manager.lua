--Maxime
local localPlayer = getLocalPlayer()
local root = getRootElement()
local gatesList1 = {}
local gateID = nil
local version = "v2.1"
function createGateManagerWindow(gatesList)
	if gWin then
		closeGateManager()
	end
	
	showCursor(true)
	gatesList1 = gatesList
	local sx, sy = guiGetScreenSize()
	gWin = guiCreateWindow(sx/2-400,sy/2-300,800,600,"Gates Manager",false)
		guiWindowSetSizable(gWin,false)
		--guiSetProperty(gWin,"TitlebarEnabled","false")
	gatesGridList = guiCreateGridList(0.0113,0.1417,0.9775,0.8633,true,gWin)
		guiGridListSetSelectionMode(gatesGridList,2)
	--iUGLogo = guiCreateStaticImage(0.8,0.035,0.14,0.0883,":resources\OGLogo.png",true,gWin)
	bCreateNewGate = guiCreateButton(0.0113,0.035,0.0938,0.09,"Create\nNew Gate",true,gWin)
		guiSetFont(bCreateNewGate,"default-bold-small")
	bReload = guiCreateButton(0.1175,0.035,0.1,0.09,"Reload\nAll Gates",true,gWin)
		guiSetFont(bReload,"default-bold-small")
	bClose = guiCreateButton(0.23,0.035,0.1,0.09,"Close",true,gWin)
		guiSetFont(bClose,"default-bold-small")
	
	GUIEditor_Label =  guiCreateLabel(0.3425,0.0217,0.4913,0.09,"GATES MANAGER",true,gWin)
		guiLabelSetVerticalAlign(GUIEditor_Label,"center")
		guiLabelSetHorizontalAlign(GUIEditor_Label,"center",false)
		guiSetFont(GUIEditor_Label,"default-bold-small")

	
	
	if (gatesList) then
		local colID = guiGridListAddColumn(gatesGridList,"ID",0.07)
		local colObjectID = guiGridListAddColumn(gatesGridList,"Object ID",0.07)	
		local colType = guiGridListAddColumn(gatesGridList,"Type",0.04)
		local colCode = guiGridListAddColumn(gatesGridList,"Code",0.07)
		local colCreator = guiGridListAddColumn(gatesGridList,"Creator",0.07)
		local colAdminNote = guiGridListAddColumn(gatesGridList,"Description",0.15)
		local colautocloseTime = guiGridListAddColumn(gatesGridList,"Closing Time",0.08)
		local colmovementTime = guiGridListAddColumn(gatesGridList,"Speed",0.05)
		local objectInterior = guiGridListAddColumn(gatesGridList,"Int",0.04)
		local objectDimension = guiGridListAddColumn(gatesGridList,"Dim",0.04)
		local startX = guiGridListAddColumn(gatesGridList,"Closed X",0.08)
		local startY = guiGridListAddColumn(gatesGridList,"Closed Y",0.08)
		local startZ = guiGridListAddColumn(gatesGridList,"Closed Z",0.08)
		local startRX = guiGridListAddColumn(gatesGridList,"Closed RX",0.08)
		local startRY = guiGridListAddColumn(gatesGridList,"Closed RY",0.08)
		local startRZ = guiGridListAddColumn(gatesGridList,"Closed RZ",0.08)
		local endX = guiGridListAddColumn(gatesGridList,"Opened X",0.08)
		local endY = guiGridListAddColumn(gatesGridList,"Opened Y",0.08)
		local endZ = guiGridListAddColumn(gatesGridList,"Opened Z",0.08)
		local endRX = guiGridListAddColumn(gatesGridList,"Opened RX",0.08)
		local endRY = guiGridListAddColumn(gatesGridList,"Opened RY",0.08)
		local endRZ = guiGridListAddColumn(gatesGridList,"Opened RZ",0.08)
		local colCreatedDate = guiGridListAddColumn(gatesGridList,"Date",0.15)
		for _, record in ipairs(gatesList) do
			local row = guiGridListAddRow(gatesGridList)
			guiGridListSetItemText(gatesGridList, row, colID, tostring(record[1]), false, true)
			guiGridListSetItemText(gatesGridList, row, colObjectID, tostring(record[2]), false, true)
			guiGridListSetItemText(gatesGridList, row, colType, tostring(record[3]), false, true)
			guiGridListSetItemText(gatesGridList, row, colCode, tostring(record[4]), false, false)
			guiGridListSetItemText(gatesGridList, row, colCreator, tostring(record[5]), false, false)
			local date = tostring(record[6])
			if date == '0000-00-00 00:00:00' then date = "" end
			guiGridListSetItemText(gatesGridList, row, colCreatedDate, date, false, false)
			guiGridListSetItemText(gatesGridList, row, colAdminNote, tostring(record[7]), false, false)
			guiGridListSetItemText(gatesGridList, row, colautocloseTime, tostring(record[8]), false, true)
			guiGridListSetItemText(gatesGridList, row, colmovementTime, tostring(record[9]), false, true)
			guiGridListSetItemText(gatesGridList, row, objectInterior, tostring(record[10]), false, true)
			guiGridListSetItemText(gatesGridList, row, objectDimension, tostring(record[11]), false, true)
			guiGridListSetItemText(gatesGridList, row, startX, tostring(record[12]), false, true)
			guiGridListSetItemText(gatesGridList, row, startY, tostring(record[13]), false, true)
			guiGridListSetItemText(gatesGridList, row, startZ, tostring(record[14]), false, true)
			guiGridListSetItemText(gatesGridList, row, startRX, tostring(record[15]), false, true)
			guiGridListSetItemText(gatesGridList, row, startRY, tostring(record[16]), false, true)
			guiGridListSetItemText(gatesGridList, row, startRZ, tostring(record[17]), false, true)
			guiGridListSetItemText(gatesGridList, row, endX, tostring(record[18]), false, true)
			guiGridListSetItemText(gatesGridList, row, endY, tostring(record[19]), false, true)
			guiGridListSetItemText(gatesGridList, row, endZ, tostring(record[20]), false, true)
			guiGridListSetItemText(gatesGridList, row, endRX, tostring(record[21]), false, true)
			guiGridListSetItemText(gatesGridList, row, endRY, tostring(record[22]), false, true)
			guiGridListSetItemText(gatesGridList, row, endRZ, tostring(record[23]), false, true)
		end
		-- for i = 1 , guiGridListGetRowCount ( gatesGridList), 1 do 
			-- guiGridListAutoSizeColumn(gatesGridList, i)
		-- end
		guiGridListSetSelectionMode (  gatesGridList, 0 )
		addEventHandler( "onClientGUIDoubleClick", root, doubleClickedGate)
		addEventHandler("onClientGUIClick", root, singleClickedGate)
	end
end
addEvent("createGateManagerWindow", true)
addEventHandler("createGateManagerWindow", localPlayer, createGateManagerWindow)

function closeGateManager()
	if gWin then
		removeEventHandler("onClientGUIClick", root, singleClickedGate)
		removeEventHandler( "onClientGUIDoubleClick", root, doubleClickedGate)
		destroyElement(gWin)
		gWin = nil
		showCursor(false)
	end
	closeEntryGateView() 
	closeCreateGate()
end

function createNewGate()
	if wCreateNewGate then
		closeCreateGate()
		guiSetInputEnabled(false)
	else
		GUIEditor_Window = {}
		GUIEditor_Button = {}
		GUIEditor_Label = {}
		GUIEditor_Edit = {}
		guiSetInputEnabled(true)
		local wx,wy = guiGetPosition(gWin, false)
		wCreateNewGate = guiCreateWindow(wx+71,wy+198,658,291,"Gate Manager "..version.." - Create new gate",false) --wx+71,wy+198,658,205,
			--guiSetProperty(wCreateNewGate,"TitlebarEnabled","false")
			guiWindowSetSizable(wCreateNewGate,false)
			guiSetProperty(wCreateNewGate, "AlwaysOnTop" , "true")
		GUIEditor_Label[4] = guiCreateLabel(19,23,124,22,"Gate Type: ",false,wCreateNewGate)
			guiSetFont(GUIEditor_Label[4],"default-bold-small")
		boxGateType = guiCreateComboBox(143,23,246,22,"(1) For everyone",false,wCreateNewGate)
				guiComboBoxAdjustHeight (  boxGateType, 5 )
				guiComboBoxAddItem(boxGateType, "(1) For everyone")
				guiComboBoxAddItem(boxGateType, "(2) For everyone with password")
				guiComboBoxAddItem(boxGateType, "(3) Work with item")
				guiComboBoxAddItem(boxGateType, "(4) Work with item and itemvalue")
				guiComboBoxAddItem(boxGateType, "(5) Open with /gate and keypad")
				guiComboBoxAddItem(boxGateType, "(6) Colsphere trigger")
				guiComboBoxAddItem(boxGateType, "(7) For faction ID")		
				guiComboBoxAddItem(boxGateType, "(8) Exciter Query String")
				guiComboBoxAddItem(boxGateType, "(9) Work with key to vehicle ID")
				guiComboBoxAddItem(boxGateType, "(10) Keycard")
		GUIEditor_Label[5] = guiCreateLabel(393,24,82,21,"Password:",false,wCreateNewGate)
			guiSetFont(GUIEditor_Label[5],"default-bold-small")
		ePassword = guiCreateEdit(475,23,164,22,"",false,wCreateNewGate)
		GUIEditor_Label[3] = guiCreateLabel(27,55,613,21,"Copy & paste whole line from .map file in 2 text boxes below. Example: <object id=\"\"> ... </object>",false,wCreateNewGate)
			guiLabelSetHorizontalAlign(GUIEditor_Label[3],"center",false)
			guiSetFont(GUIEditor_Label[3],"default-small")
		
		GUIEditor_Label[1] = guiCreateLabel(19,73,124,22,"Gate Closed State :",false,wCreateNewGate)
			guiSetFont(GUIEditor_Label[1],"default-bold-small")
		eClosedState = guiCreateEdit(143,73,497,22,"",false,wCreateNewGate)
		
		GUIEditor_Label[2] = guiCreateLabel(19,105,124,22,"Gate Opened State:",false,wCreateNewGate)
			guiSetFont(GUIEditor_Label[2],"default-bold-small")
		eOpenedState = guiCreateEdit(143,105,497,22,"",false,wCreateNewGate)
		
		GUIEditor_Label[7] = guiCreateLabel(19,137,154,22,"Timeout, Speed:",false,wCreateNewGate)
			guiSetFont(GUIEditor_Label[7],"default-bold-small")
		eTimeOut = guiCreateEdit(143,137,122,22,"",false,wCreateNewGate)
		eSpeed = guiCreateEdit(265,137,126,22,"",false,wCreateNewGate)
		
		GUIEditor_Label[6] = guiCreateLabel(19,169,124,22,"Description:",false,wCreateNewGate)
			guiSetFont(GUIEditor_Label[6],"default-bold-small")
		eAdminNote = guiCreateEdit(143,169,247,22,"",false,wCreateNewGate)

		GUIEditor_Label[8] = guiCreateLabel(19, 201, 124, 22, "Sound:", false, wCreateNewGate)
			guiSetFont(GUIEditor_Label[8], "default-bold-small")
		boxGateSound = guiCreateComboBox(143, 201, 246, 81, "metalgate", false, wCreateNewGate)
			guiComboBoxAddItem(boxGateSound, "metalgate")
			guiComboBoxAddItem(boxGateSound, "none")
			guiComboBoxAddItem(boxGateSound, "alarmbell")
		GUIEditor_Label[9] = guiCreateLabel(19, 244, 124, 22, "Trigger Distance:", false, wCreateNewGate)
			guiSetFont(GUIEditor_Label[9], "default-bold-small")
		eTriggerDistFoot = guiCreateEdit(143, 243, 122, 22, "", false, wCreateNewGate)
		GUIEditor_Label[10] = guiCreateLabel(155, 228, 100, 15, "On Foot:", false, wCreateNewGate)
			guiSetFont(GUIEditor_Label[10], "default-small")
			guiLabelSetHorizontalAlign(GUIEditor_Label[10], "center", false)
		eTriggerDistVeh = guiCreateEdit(265, 243, 126, 22, "", false, wCreateNewGate)
		GUIEditor_Label[11] = guiCreateLabel(277, 228, 100, 15, "In Vehicle:", false, wCreateNewGate)
			guiSetFont(GUIEditor_Label[11], "default-small")
			guiLabelSetHorizontalAlign(GUIEditor_Label[11], "center", false)
		
		bCreateGate = guiCreateButton(401,228,118,53,"CREATE",false,wCreateNewGate)
			guiSetFont(bCreateGate,"default-bold-small")
			guiSetEnabled(bCreateGate,false)
		bCancelCreateGate = guiCreateButton(529,228,111,53,"CANCEL",false,wCreateNewGate)
			guiSetFont(bCancelCreateGate,"default-bold-small")
		addEventHandler("onClientGUIChanged", root, validation2)
	end
end

function closeCreateGate()
	if wCreateNewGate then
		removeEventHandler("onClientGUIChanged", root, validation2)
		destroyElement(wCreateNewGate)
		guiSetInputEnabled(false)
		wCreateNewGate = nil
	end
end

function validation2 ()
	if guiGetText(eClosedState) ~= "" and  guiGetText(eOpenedState) ~= "" and guiGetText(eTimeOut) ~= "" and guiGetText(eSpeed) ~= "" then
		guiSetEnabled(bCreateGate, true)
	else
		guiSetEnabled(bCreateGate, false)	
	end
end


function singleClickedGate(button, state)
	if button == "left" then
		if source == bClose then
			showCursor(false)
			closeGateManager()
		elseif source == bCancel then
			closeEntryGateView() 
		elseif source == bCreateNewGate then
			createNewGate()
		elseif source == bCancelCreateGate then
			closeCreateGate()
		elseif source == bCreateGate then
			local tableClosed = processInput(guiGetText(eClosedState))
			local tableOpened = processInput(guiGetText(eOpenedState), 1)
			triggerServerEvent("addGate", localPlayer,localPlayer, tableClosed[1], tableClosed[4], tableClosed[5],tableClosed[6],tableClosed[7],tableClosed[8],tableClosed[9],tableOpened[4],tableOpened[5],tableOpened[6],tableOpened[7],tableOpened[8],tableOpened[9],(guiComboBoxGetSelected(boxGateType)+1),guiGetText(ePassword), guiGetText(eTimeOut),guiGetText(eSpeed), tableClosed[2],tableClosed[3],getElementData(getLocalPlayer(), "account:username") ,guiGetText(eAdminNote),(guiComboBoxGetItemText(boxGateSound,guiComboBoxGetSelected(boxGateSound))),guiGetText(eTriggerDistFoot),guiGetText(eTriggerDistVeh))
		elseif source == bSave then
			triggerServerEvent("saveGate", localPlayer,localPlayer, guiGetText(eObjectModel), guiGetText(eStartX), guiGetText(eStartY),guiGetText(eStartZ),guiGetText(eStartRX),guiGetText(eStartRY),guiGetText(eStartRZ),guiGetText(eEndX),guiGetText(eEndY),guiGetText(eEndZ),guiGetText(eEndRX),guiGetText(eEndRY),guiGetText(eEndRZ),(guiComboBoxGetSelected(boxGateType)+1),guiGetText(ePassword), guiGetText(eInterval),guiGetText(eSpeed), guiGetText(eInt),guiGetText(eDim),getElementData(getLocalPlayer(), "account:username") ,guiGetText(eAdminNote), gateID,(guiComboBoxGetItemText(boxGateSound,guiComboBoxGetSelected(boxGateSound))),guiGetText(eTriggerDistFoot),guiGetText(eTriggerDistVeh))
		elseif source == bDelete then 
			guiSetVisible(lMsg, true)
			guiSetVisible(bDelete, false)
			guiSetVisible(bGoToGate, false)
			bYes = guiCreateButton(143,201,118,31,"YES",false,wGateEntryView)
				guiSetFont(bYes,"default-bold-small")
			bNo = guiCreateButton(273,201,118,31,"NO",false,wGateEntryView)
				guiSetFont(bYes,"default-bold-small")
			guiSetEnabled(bSave,false)
			guiSetEnabled(bCancel,false)
		elseif source == bNo then
			guiSetVisible(lMsg, false)
			guiSetVisible(bDelete, true)
			guiSetVisible(bGoToGate, true)
			destroyElement(bYes)
			destroyElement(bNo)
			guiSetEnabled(bSave,true)
			guiSetEnabled(bCancel,true)
		elseif source == bYes then
			triggerServerEvent("delGate", localPlayer,localPlayer, "maxime", gateID)
		elseif source == bReload then
			triggerServerEvent("reloadGates", localPlayer,localPlayer)
		elseif source == bGoToGate then
			triggerServerEvent("gotoGate", localPlayer,localPlayer, "gotogate", gateID)
			closeGateManager()
		else
		end
	end
end

function validation ()
	if tonumber(guiGetText(eObjectModel)) and tonumber(guiGetText(eStartX)) and tonumber(guiGetText(eStartY)) and tonumber(guiGetText(eStartZ)) and tonumber(guiGetText(eStartRX)) and tonumber(guiGetText(eStartRY)) and tonumber(guiGetText(eStartRZ)) and tonumber(guiGetText(eEndX)) and tonumber(guiGetText(eEndY)) and tonumber(guiGetText(eEndZ)) and tonumber(guiGetText(eEndRX)) and tonumber(guiGetText(eEndRY)) and tonumber(guiGetText(eEndRZ)) and tonumber(guiGetText(eInterval)) and tonumber(guiGetText(eSpeed)) and tonumber(guiGetText(eInt)) and tonumber(guiGetText(eDim)) and tonumber(guiGetText(eInt)) then
		guiSetEnabled(bSave, true)
	else
		guiSetEnabled(bSave, false)	
	end
end

function getRowFromGateID(gateID)
	for key, row in pairs(gatesList1) do
		if tonumber(row[1]) == tonumber(gateID) then
			return row
		end
	end
end

function doubleClickedGate(button, state )
    if button == "left" then
		if source == gatesGridList then
			if wGateEntryView then
				closeEntryGateView()
				guiSetInputEnabled(false)
			end
			guiSetInputEnabled(true)
			local row, col = guiGridListGetSelectedItem( source )
			gateID = tonumber(guiGridListGetItemText ( source, row, 1 ))
			local editGateElement = getGateElementFromID(gateID)
			local targetRow = getRowFromGateID(gateID)
			GUIEditor_Label = {}
			GUIEditor_Edit = {}
			local wx,wy = guiGetPosition(gWin, false)
			wGateEntryView = guiCreateWindow(wx+70,wy+190,659,316,"Gate Manager "..version.." - Edit existing gate",false) 
				--guiSetProperty(wGateEntryView,"TitlebarEnabled","false")
				guiWindowSetSizable(wGateEntryView,false)
				guiSetProperty(wGateEntryView, "AlwaysOnTop" , "true")
			GUIEditor_Label[1] = guiCreateLabel(19,73,124,22,"Gate Closed State :",false,wGateEntryView)
			guiSetFont(GUIEditor_Label[1],"default-bold-small")
			GUIEditor_Label[2] = guiCreateLabel(19,105,124,22,"Gate Opened State:",false,wGateEntryView)
			guiSetFont(GUIEditor_Label[2],"default-bold-small")
			eStartX = guiCreateEdit(143,73,82,22,targetRow[12],false,wGateEntryView)
			eStartY = guiCreateEdit(225,73,82,22,targetRow[13],false,wGateEntryView)
			eStartZ = guiCreateEdit(307,73,82,22,targetRow[14],false,wGateEntryView)
			eStartRX = guiCreateEdit(393,73,82,22,targetRow[15],false,wGateEntryView)
			eStartRY = guiCreateEdit(475,73,82,22,targetRow[16],false,wGateEntryView)
			eStartRZ = guiCreateEdit(558,73,82,22,targetRow[17],false,wGateEntryView)
			eEndX = guiCreateEdit(143,105,82,22,targetRow[18],false,wGateEntryView)
			eEndY = guiCreateEdit(225,105,82,22,targetRow[19],false,wGateEntryView)
			eEndZ = guiCreateEdit(307,105,82,22,targetRow[20],false,wGateEntryView)
			eEndRX = guiCreateEdit(393,105,82,22,targetRow[21],false,wGateEntryView)
			eEndRY = guiCreateEdit(475,105,82,22,targetRow[22],false,wGateEntryView)
			eEndRZ = guiCreateEdit(557,105,82,22,targetRow[23],false,wGateEntryView)
			GUIEditor_Label[3] = guiCreateLabel(162,50,204,17,"Position ( X, Y, Z )",false,wGateEntryView)
			guiLabelSetHorizontalAlign(GUIEditor_Label[3],"center",false)
			GUIEditor_Label[4] = guiCreateLabel(414,50,202,21,"Rotation ( X, Y, Z )",false,wGateEntryView)
			guiLabelSetHorizontalAlign(GUIEditor_Label[4],"center",false)
			GUIEditor_Label[5] = guiCreateLabel(19,23,124,22,"Gate Type: ",false,wGateEntryView)
			guiSetFont(GUIEditor_Label[5],"default-bold-small")
			boxGateType = guiCreateComboBox(143,23,246,22,"(1) For everyone",false,wGateEntryView)
				guiComboBoxAdjustHeight (  boxGateType, 5 )
				guiComboBoxAddItem(boxGateType, "(1) For everyone")
				guiComboBoxAddItem(boxGateType, "(2) For everyone with password")
				guiComboBoxAddItem(boxGateType, "(3) Work with item")
				guiComboBoxAddItem(boxGateType, "(4) Work with item and itemvalue")
				guiComboBoxAddItem(boxGateType, "(5) Open with /gate and keypad")
				guiComboBoxAddItem(boxGateType, "(6) Colsphere trigger")
				guiComboBoxAddItem(boxGateType, "(7) For faction ID")
				guiComboBoxAddItem(boxGateType, "(8) Exciter Query String")
				guiComboBoxAddItem(boxGateType, "(9) Work with key to vehicle ID")
				guiComboBoxAddItem(boxGateType, "(10) Keycard")
			ePassword = guiCreateEdit(475,23,164,22,targetRow[4],false,wGateEntryView)
			lPassword = guiCreateLabel(393,24,82,21,"Password:",false,wGateEntryView)
			guiSetFont(lPassword,"default-bold-small")
			GUIEditor_Label[6] = guiCreateLabel(19,169,124,22,"Description:",false,wGateEntryView)
			guiSetFont(GUIEditor_Label[6],"default-bold-small")
			lMsg = guiCreateLabel(19,200,120,35,"Are you sure?\n This action can't be undone!",false,wGateEntryView)
				guiSetFont(lMsg,"default-small")
				guiLabelSetColor(lMsg,255,255,0)
				guiSetVisible(lMsg, false)
			eAdminNote = guiCreateEdit(143,169,247,22,targetRow[7],false,wGateEntryView)
			GUIEditor_Label[7] = guiCreateLabel(391,169,84,22,"Object model",false, wGateEntryView)
			guiSetFont(GUIEditor_Label[7],"default-bold-small")
			eObjectModel = guiCreateEdit(475,169,165,22,targetRow[2],false,wGateEntryView)
			GUIEditor_Label[8] = guiCreateLabel(321,137,154,22,"Closing interval, Speed:",false,wGateEntryView)
				guiSetFont(GUIEditor_Label[8],"default-bold-small")
			eInterval = guiCreateEdit(475,137,82,22,targetRow[8],false,wGateEntryView)
			eSpeed = guiCreateEdit(558,137,82,22,targetRow[9],false,wGateEntryView)
			GUIEditor_Label[9] = guiCreateLabel(19,137,124,22,"Int, Dim:",false,wGateEntryView)
				guiSetFont(GUIEditor_Label[9],"default-bold-small")
			eInt = guiCreateEdit(144,137,81,22,targetRow[10],false,wGateEntryView)
			eDim = guiCreateEdit(226,137,81,22,targetRow[11],false,wGateEntryView)
			guiComboBoxSetSelected(boxGateType, tonumber(targetRow[3]) -1 )

			--outputDebugString("editGateElement="..tostring(editGateElement))
			local dataTriggerDistance, dataTriggerDistanceVehicle, dataSound
			if editGateElement then
				dataTriggerDistance = tonumber(getElementData(editGateElement, "gate:triggerDistance"))
				dataTriggerDistanceVehicle = tonumber(getElementData(editGateElement, "gate:triggerDistanceVehicle"))
				dataSound = getElementData(editGateElement, "gate:sound")
			end
			--outputDebugString("dataTriggerDistance="..tostring(dataTriggerDistance))
			if dataTriggerDistance then
				dataTriggerDistance = tostring(dataTriggerDistance) or ""
			else
				dataTriggerDistance = ""
			end
			--outputDebugString("dataTriggerDistanceVehicle="..tostring(dataTriggerDistanceVehicle))
			if dataTriggerDistanceVehicle then
				dataTriggerDistanceVehicle = tostring(dataTriggerDistanceVehicle) or ""
			else
				dataTriggerDistanceVehicle = ""
			end
			--outputDebugString("dataSound="..tostring(dataSound))
			if dataSound then
				dataSound = tostring(dataSound)
			else
				dataSound = "none"
			end
			--base 169
			GUIEditor_Label[12] = guiCreateLabel(19, 201, 124, 22, "Sound:", false, wGateEntryView) --201+32
				guiSetFont(GUIEditor_Label[12], "default-bold-small")
			boxGateSound = guiCreateComboBox(143, 201, 246, 81, "", false, wGateEntryView)
				local soundOptions = {"metalgate", "none", "alarmbell"}
				local soundOptionItems = {}
				for k,v in ipairs(soundOptions) do
					local item = guiComboBoxAddItem(boxGateSound, v)
					soundOptionItems[v] = item
				end
				guiComboBoxSetSelected(boxGateSound, soundOptionItems[dataSound])
			GUIEditor_Label[13] = guiCreateLabel(19, 244, 124, 22, "Trigger Distance:", false, wGateEntryView) --244+43
				guiSetFont(GUIEditor_Label[13], "default-bold-small")
			eTriggerDistFoot = guiCreateEdit(143, 243, 122, 22, dataTriggerDistance, false, wGateEntryView)
			GUIEditor_Label[14] = guiCreateLabel(155, 228, 100, 15, "On Foot:", false, wGateEntryView) --228-16
				guiSetFont(GUIEditor_Label[14], "default-small")
				guiLabelSetHorizontalAlign(GUIEditor_Label[14], "center", false)
			eTriggerDistVeh = guiCreateEdit(265, 243, 126, 22, dataTriggerDistanceVehicle, false, wGateEntryView)
			GUIEditor_Label[15] = guiCreateLabel(277, 228, 100, 15, "In Vehicle:", false, wGateEntryView)
				guiSetFont(GUIEditor_Label[15], "default-small")
				guiLabelSetHorizontalAlign(GUIEditor_Label[15], "center", false)

			bDelete = guiCreateButton(143,275,118,31,"DELETE",false,wGateEntryView) --201+32
				guiSetFont(bDelete,"default-bold-small")
			bGoToGate = guiCreateButton(273,275,118,31,"GO TO GATE",false,wGateEntryView)
				guiSetFont(bGoToGate,"default-bold-small")
			bSave = guiCreateButton(401,275,118,31,"SAVE",false, wGateEntryView)
				guiSetFont(bSave,"default-bold-small")
			bCancel = guiCreateButton(529,275,111,31,"CANCEL",false,wGateEntryView)
				guiSetFont(bCancel,"default-bold-small")
			
			addEventHandler("onClientGUIChanged", root, validation)
			--guiSetEnabled(bOk, false)	
		end
	end
end

function closeEntryGateView() 
	if wGateEntryView then
		removeEventHandler("onClientGUIChanged", root, validation)
		destroyElement(wGateEntryView) 
		wGateEntryView = nil 
		--gateEntryData = nil 
		guiSetInputEnabled(false)
	end
end

function guiComboBoxAdjustHeight ( combobox, itemcount )
    if getElementType ( combobox ) ~= "gui-combobox" or type ( itemcount ) ~= "number" then error ( "Invalid arguments @ 'guiComboBoxAdjustHeight'", 2 ) end
    local width = guiGetSize ( combobox, false )
    return guiSetSize ( combobox, width, ( itemcount * 20 ) + 20, false )
end

function processInput(raw, state)
	local t = {}
	local count = 0
	local z, x, y , cell = nil
	local count = 1
	if state then 
		count = 10
	end
	z, x = string.find(raw, 'model="')
	y = string.find(raw, '"', x + 1)	
	cell = string.sub( raw, x+1, y-1)
	if cell ~= "" then 
		outputChatBox("Processing ["..count.."/18] [Object Model] ... '"..cell.."'...Done!")
		table.insert(t,cell)
		count = count + 1
	else
		outputChatBox("Processing [1/18] [Object Model] ... Failed! Operation canceled.")
		return
	end
	
	z, x = string.find(raw, 'interior="')
	y = string.find(raw, '"', x + 1)
	cell = string.sub( raw, x+1, y-1)
	if cell ~= "" then 
		outputChatBox("Processing ["..count.."/18] [Interior] ... '"..cell.."'...Done!")
		table.insert(t,cell)
		count = count + 1
	else
		outputChatBox("Processing ["..count.."/18] [Interior] ... Failed! Operation canceled.")
		return
	end
	
	z, x = string.find(raw, 'dimension="')
	y = string.find(raw, '"', x + 1)
	cell = string.sub( raw, x+1, y-1)
	if cell ~= "" then 
		outputChatBox("Processing ["..count.."/18] [dimension] ... '"..cell.."'...Done!")
		table.insert(t,cell)
		count = count + 1
	else
		outputChatBox("Processing ["..count.."/18] [dimension] ... Failed! Operation canceled.")
		return
	end

	z, x = string.find(raw, 'posX="')
	y = string.find(raw, '"', x + 1)
	cell = string.sub( raw, x+1, y-1)
	if cell ~= "" then 
		outputChatBox("Processing ["..count.."/18] [posX] ... '"..cell.."'...Done!")
		table.insert(t,cell)
		count = count + 1
	else
		outputChatBox("Processing ["..count.."/18] [posX] ... Failed! Operation canceled.")
		return
	end
	--
	
	z, x = string.find(raw, 'posY="')
	y = string.find(raw, '"', x + 1)
	cell = string.sub( raw, x+1, y-1)
	if cell ~= "" then 
		outputChatBox("Processing ["..count.."/18] [posY] ... '"..cell.."'...Done!")
		table.insert(t,cell)
		count = count + 1
	else
		outputChatBox("Processing ["..count.."/18] [posY] ... Failed! Operation canceled.")
		return
	end
	
	z, x = string.find(raw, 'posZ="')
	y = string.find(raw, '"', x + 1)
	cell = string.sub( raw, x+1, y-1)
	if cell ~= "" then 
		outputChatBox("Processing ["..count.."/18] [posZ] ... '"..cell.."'...Done!")
		table.insert(t,cell)
		count = count + 1
	else
		outputChatBox("Processing ["..count.."/18] [posZ] ... Failed! Operation canceled.")
		return
	end
	
	z, x = string.find(raw, 'rotX="')
	y = string.find(raw, '"', x + 1)
	cell = string.sub( raw, x+1, y-1)
	if cell ~= "" then 
		outputChatBox("Processing ["..count.."/18] [rotX] ... '"..cell.."'...Done!")
		table.insert(t,cell)
		count = count + 1
	else
		outputChatBox("Processing ["..count.."/18] [rotX] ... Failed! Operation canceled.")
		return
	end
	
	z, x = string.find(raw, 'rotY="')
	y = string.find(raw, '"', x + 1)
	cell = string.sub( raw, x+1, y-1)
	if cell ~= "" then 
		outputChatBox("Processing ["..count.."/18] [rotY] ... '"..cell.."'...Done!")
		table.insert(t,cell)
		count = count + 1
	else
		outputChatBox("Processing ["..count.."/18] [rotY] ... Failed! Operation canceled.")
		return
	end
	
	z, x = string.find(raw, 'rotZ="')
	y = string.find(raw, '"', x + 1)
	cell = string.sub( raw, x+1, y-1)
	if cell ~= "" then 
		outputChatBox("Processing ["..count.."/18] [rotZ] ... '"..cell.."'...Done!")
		table.insert(t,cell)
	else
		outputChatBox("Processing ["..count.."/18] [rotZ] ... Failed! Operation canceled.")
		return
	end
	
	return t
end

function getGateElementFromID(id)
	id = tonumber(id)
	if not id then return false end
	for k, theGate in ipairs(getElementsByType("object", getResourceRootElement(getThisResource()))) do
		local dbid = tonumber(getElementData(theGate, "gate:id"))
		if(dbid == id) then
			return theGate
		end
	end
	return false
end


addEventHandler("onClientResourceStop", root, function () guiSetInputEnabled(false) showCursor(false) end)
