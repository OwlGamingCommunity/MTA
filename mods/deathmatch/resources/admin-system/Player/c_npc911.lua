local gui = {}

function build_Dialog()

	if gui["_root"] and isElement(gui["_root"]) then destroyElement(gui["_root"]) end
	
	gui._placeHolders = {}

	showCursor(true)
	guiSetInputMode("no_binds_when_editing")
	
	local screenWidth, screenHeight = guiGetScreenSize()
	local windowWidth, windowHeight = 383, 217
	local left = screenWidth/2 - windowWidth/2
	local top = screenHeight/2 - windowHeight/2
	gui["_root"] = guiCreateWindow(left, top, windowWidth, windowHeight, "Staff NPC 911 call", false)
	guiWindowSetSizable(gui["_root"], false)
	
	gui["lineEdit"] = guiCreateEdit(20, 165, 171, 31, "", false, gui["_root"])
	guiEditSetMaxLength(gui["lineEdit"], 32767)
	
	gui["pushButton"] = guiCreateButton(250, 145, 75, 23, "Send", false, gui["_root"])
	addEventHandler("onClientGUIClick", gui["pushButton"], function()
			triggerServerEvent("npc911", getResourceRootElement(), localPlayer, guiGetText(gui["lineEdit"]), guiGetText(gui["lineEdit_2"]))
			destroyElement(gui["_root"])
			showCursor(false)
			guiSetInputMode("allow_binds")
			outputChatBox("A NPC 911 call has been made.")
		end, false)
	
	gui["pushButton_2"] = guiCreateButton(250, 185, 75, 23, "Close", false, gui["_root"])
	addEventHandler("onClientGUIClick", gui["pushButton_2"], function ()
			destroyElement(gui["_root"])
			showCursor(false)
			guiSetInputMode("allow_binds")
		end, false)
	
	gui["label"] = guiCreateLabel(20, 145, 111, 16, "Location", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["label"], "left", false)
	guiLabelSetVerticalAlign(gui["label"], "center")
	
	gui["label_2"] = guiCreateLabel(20, 25, 121, 16, "Situation", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["label_2"], "left", false)
	guiLabelSetVerticalAlign(gui["label_2"], "center")
	
	gui["lineEdit_2"] = guiCreateEdit(20, 45, 321, 71, "", false, gui["_root"])
	guiEditSetMaxLength(gui["lineEdit_2"], 32767)
	
	return gui, windowWidth, windowHeight
end

addEvent("buildGUI_npc911", true)
addEventHandler("buildGUI_npc911", getResourceRootElement(), build_Dialog)