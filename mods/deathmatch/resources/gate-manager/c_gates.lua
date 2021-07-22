local theVictim = nil
local movementGUI = nil
local sensivity = 2
local savedOpenedPos = { }
local savedClosedPos = { }
local savedOptions = { }
local editingPos = 1
function startEdit(theObject, parameters, dbid)
	theVictim = theObject

	movementGUI = build_movementScreen()
	addEventHandler("onClientGUIClick", movementGUI['btnCancel'], edit_cancel)
	addEventHandler("onClientGUIClick", movementGUI['btnSwitch'], edit_switch)
	addEventHandler("onClientGUIClick", movementGUI['btnSave'], edit_save)

	local tempTable = {"btnPlusRZ", "btnMinRZ", "btnMinZ", "btnPlusZ", "btnMinRY", "btnSwitch", "btnSave", "btnPlusY", "btnMinY", "btnMinX", "btnPlusX", "btnPlusRY", "btnMinRX", "btnPlusRX" }
	for _, value in ipairs(tempTable) do
		addEventHandler("onClientGUIClick", movementGUI[value], edit_clickButton)
	end
	savedOpenedPos = { }
	savedClosedPos = { }
	savedOptions = { }
	editingPos = 1
end
addEvent("gates:startedit", true)
addEventHandler("gates:startedit", getRootElement(), startEdit)

function edit_save()
	if not savedClosedPos["x"] then
		outputChatBox("You didn't make an ending position", 255, 0,0)
		return
	end

	if not savedOpenedPos["x"] then
		outputChatBox("You didn't make an starting position", 255, 0,0)
		return
	end

	destroyElement(movementGUI["_root"])
	movementGUI = build_optionScreen()
	addEventHandler("onClientGUIClick", movementGUI['btnCancel'], edit_cancel)
	addEventHandler("onClientGUIClick", movementGUI['btnSave'], edit_save2)

end

function edit_switch()
	if editingPos == 1 then -- old: start 		new: end
		local x, y, z = getElementPosition(theVictim)
		local rx, ry, rz = getElementRotation(theVictim)
		savedOpenedPos["x"] = x
		savedOpenedPos["y"] = y
		savedOpenedPos["z"] = z
		savedOpenedPos["rx"] = rx
		savedOpenedPos["ry"] = ry
		savedOpenedPos["rz"] = rz
		editingPos = 2
		guiSetText ( movementGUI["lblState"], "Editing the END position" )
		if (savedClosedPos["x"]) then
			setElementPosition(theVictim, savedClosedPos["x"], savedClosedPos["y"], savedClosedPos["z"])
			setElementRotation(theVictim, savedClosedPos["rx"], savedClosedPos["ry"], savedClosedPos["rz"])
		end
	else -- old: end 		new: start
		local x, y, z = getElementPosition(theVictim)
		local rx, ry, rz = getElementRotation(theVictim)
		savedClosedPos["x"] = x
		savedClosedPos["y"] = y
		savedClosedPos["z"] = z
		savedClosedPos["rx"] = rx
		savedClosedPos["ry"] = ry
		savedClosedPos["rz"] = rz
		editingPos = 1
		guiSetText ( movementGUI["lblState"], "Editing the START position" )
		if (savedOpenedPos["x"]) then
			setElementPosition(theVictim, savedOpenedPos["x"], savedOpenedPos["y"], savedOpenedPos["z"])
			setElementRotation(theVictim, savedOpenedPos["rx"], savedOpenedPos["ry"], savedOpenedPos["rz"])
		end
	end

end

function edit_cancel()
	triggerServerEvent("gates:canceledit", theVictim)
	if movementGUI then
		destroyElement(movementGUI["_root"])
		movementGUI = { }
	end
end

function edit_clickButton()
	sensivity = guiScrollBarGetScrollPosition ( movementGUI["scrollSensivity"] ) / 25
	if source == movementGUI["btnMinZ"] then
		local x, y, z = getElementPosition(theVictim)
		z = z - sensivity
		setElementPosition(theVictim, x, y, z)
	elseif source == movementGUI["btnPlusZ"] then
		local x, y, z = getElementPosition(theVictim)
		z = z + sensivity
		setElementPosition(theVictim, x, y, z)
	elseif source == movementGUI["btnPlusX"] then
		local x, y, z = getElementPosition(theVictim)
		x = x + sensivity
		setElementPosition(theVictim, x, y, z)
	elseif source == movementGUI["btnMinX"] then
		local x, y, z = getElementPosition(theVictim)
		x = x - sensivity
		setElementPosition(theVictim, x, y, z)
	elseif source == movementGUI["btnPlusY"] then
		local x, y, z = getElementPosition(theVictim)
		y = y + sensivity
		setElementPosition(theVictim, x, y, z)
	elseif source == movementGUI["btnMinY"] then
		local x, y, z = getElementPosition(theVictim)
		y = y - sensivity
		setElementPosition(theVictim, x, y, z)
	elseif source == movementGUI["btnPlusRX"] then
		local rx, ry, rz = getElementRotation(theVictim)
		rx = rx + sensivity
		setElementRotation(theVictim, rx, ry, rz)
	elseif source == movementGUI["btnMinRX"] then
		local rx, ry, rz = getElementRotation(theVictim)
		rx = rx - sensivity
		setElementRotation(theVictim, rx, ry, rz)
	elseif source == movementGUI["btnPlusRY"] then
		local rx, ry, rz = getElementRotation(theVictim)
		ry = ry + sensivity
		setElementRotation(theVictim, rx, ry, rz)
	elseif source == movementGUI["btnMinRY"] then
		local rx, ry, rz = getElementRotation(theVictim)
		ry = ry - sensivity
		setElementRotation(theVictim, rx, ry, rz)
	elseif source == movementGUI["btnPlusRZ"] then
		local rx, ry, rz = getElementRotation(theVictim)
		rz = rz + sensivity
		setElementRotation(theVictim, rx, ry, rz)
	elseif source == movementGUI["btnMinRZ"] then
		local rx, ry, rz = getElementRotation(theVictim)
		rz = rz - sensivity
		setElementRotation(theVictim, rx, ry, rz)
	end
end

function build_movementScreen()
	local gui = {}
	gui._placeHolders = {}

	local screenWidth, screenHeight = guiGetScreenSize()
	local windowWidth, windowHeight = 206, 236
	local left = screenWidth/2 - windowWidth/2
	local top = screenHeight/2 - windowHeight/2
	gui["_root"] = guiCreateWindow(left, top, windowWidth, windowHeight, "MainWindow", false)
	guiWindowSetSizable(gui["_root"], false)

	gui["lblState"] = guiCreateLabel(10, 25, 141, 16, "Editing the START location", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["lblState"], "left", false)
	guiLabelSetVerticalAlign(gui["lblState"], "center")

	gui["btnSwitch"] = guiCreateButton(10, 205, 61, 23, "Switch", false, gui["_root"])
	gui["btnCancel"] = guiCreateButton(70, 205, 61, 23, "Cancel", false, gui["_root"])
	gui["btnSave"] = guiCreateButton(130, 205, 61, 23, "Save", false, gui["_root"])
	gui["btnPlusY"] = guiCreateButton(110, 55, 31, 21, "^", false, gui["_root"])
	gui["btnMinY"] = guiCreateButton(110, 95, 31, 21, "V", false, gui["_root"])
	gui["btnMinX"] = guiCreateButton(80, 75, 31, 21, "<", false, gui["_root"])
	gui["btnPlusX"] = guiCreateButton(140, 75, 31, 21, ">", false, gui["_root"])
	gui["btnPlusRY"] = guiCreateButton(110, 125, 31, 21, "^", false, gui["_root"])
	gui["btnMinRX"] = guiCreateButton(80, 145, 31, 21, "<", false, gui["_root"])
	gui["btnPlusRX"] = guiCreateButton(140, 145, 31, 21, ">", false, gui["_root"])
	gui["btnMinRY"] = guiCreateButton(110, 165, 31, 21, "V", false, gui["_root"])
	gui["btnPlusZ"] = guiCreateButton(20, 75, 21, 21, "^", false, gui["_root"])
	gui["btnMinZ"] = guiCreateButton(20, 95, 21, 21, "V", false, gui["_root"])
	gui["btnMinRZ"] = guiCreateButton(20, 155, 21, 21, "<", false, gui["_root"])
	gui["btnPlusRZ"] = guiCreateButton(40, 155, 21, 21, ">", false, gui["_root"])

	gui["scrollSensivity"] = guiCreateScrollBar ( 180, 50, 20, 150, false, false, gui["_root"])
	guiScrollBarSetScrollPosition ( gui["scrollSensivity"], 40 )

	gui["label"] = guiCreateLabel(20, 55, 46, 13, "Position", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["label"], "left", false)
	guiLabelSetVerticalAlign(gui["label"], "center")

	gui["label_2"] = guiCreateLabel(20, 125, 46, 13, "Rotation", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["label_2"], "left", false)
	guiLabelSetVerticalAlign(gui["label_2"], "center")
	return gui
end

function build_optionScreen()
	local gui = {}

	local screenWidth, screenHeight = guiGetScreenSize()
	local windowWidth, windowHeight = 222, 358
	local left = screenWidth/2 - windowWidth/2
	local top = screenHeight/2 - windowHeight/2
	gui["_root"] = guiCreateWindow(left, top, windowWidth, windowHeight, "MainWindow", false)
	guiWindowSetSizable(gui["_root"], false)

	gui["chkbyGate"] = guiCreateRadioButton(10, 35, 131, 17, "Opening by command", false, gui["_root"])
	gui["chkbyGatePassword"] = guiCreateRadioButton(10, 55, 201, 17, "Opening by command with password", false, gui["_root"])
	gui["txtGateByPassword"] = guiCreateEdit(70, 75, 131, 20, "", false, gui["_root"])
	guiEditSetMaxLength(gui["txtGateByPassword"], 32767)
	gui["chkbyItem"] = guiCreateRadioButton(10, 105, 201, 17, "Opening by command with item", false, gui["_root"])
	gui["txtItemID"] = guiCreateEdit(70, 125, 131, 20, "", false, gui["_root"])
	guiEditSetMaxLength(gui["txtItemID"], 32767)
	gui["txtItemValue"] = guiCreateEdit(70, 145, 131, 20, "", false, gui["_root"])
	guiEditSetMaxLength(gui["txtItemValue"], 32767)
	gui["label"] = guiCreateLabel(11, 128, 46, 13, "ItemID", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["label"], "left", false)
	guiLabelSetVerticalAlign(gui["label"], "center")
	gui["label_2"] = guiCreateLabel(10, 148, 46, 13, "ItemValue", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["label_2"], "left", false)
	guiLabelSetVerticalAlign(gui["label_2"], "center")
	gui["chkbyKeypad"] = guiCreateRadioButton(10, 175, 201, 17, "Opening by keypad", false, gui["_root"])
	gui["txtPIN"] = guiCreateEdit(70, 195, 131, 20, "", false, gui["_root"])
	guiEditSetMaxLength(gui["txtPIN"], 32767)
	gui["label_3"] = guiCreateLabel(10, 195, 31, 16, "PIN", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["label_3"], "left", false)
	guiLabelSetVerticalAlign(gui["label_3"], "center")
	gui["chkbyKeypad_2"] = guiCreateRadioButton(10, 215, 201, 17, "Open by colsphere trigger", false, gui["_root"])
	gui["btnSave"] = guiCreateButton(110, 325, 101, 23, "Save", false, gui["_root"])
	gui["btnCancel"] = guiCreateButton(10, 325, 101, 23, "Cancel", false, gui["_root"])
	gui["label_4"] = guiCreateLabel(10, 25, 81, 16, "Access settings", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["label_4"], "left", false)
	guiLabelSetVerticalAlign(gui["label_4"], "center")
	gui["label_5"] = guiCreateLabel(10, 235, 81, 16, "Other settings", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["label_5"], "left", false)
	guiLabelSetVerticalAlign(gui["label_5"], "center")
	gui["chkAutoClose"] = guiCreateCheckBox(10, 255, 111, 17, "Closes automaticly", false, false, gui["_root"])
	gui["label_6"] = guiCreateLabel(10, 275, 81, 16, "Auto close after:", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["label_6"], "left", false)
	guiLabelSetVerticalAlign(gui["label_6"], "center")

	return gui, windowWidth, windowHeight
end

function setupGates()
	for _, element in ipairs(exports.pool:getPoolElementsByType("object")) do
		if getElementData(element, "gate") then
			setObjectBreakable(element, false)
		end
	end
end
addEventHandler("onClientResourceStart", resourceRoot, setupGates)