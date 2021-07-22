local gui = {}
local basic_title = "San Andreas Airports - Federal Aviation Administration"

function build_Dialog(data)	
	
	if gui["_root"] and isElement(gui["_root"]) then destroyElement(gui["_root"]) end -- We shall not make two copies!

	gui._placeHolders = {}
	
	guiSetInputMode("no_binds_when_editing")

	local screenWidth, screenHeight = guiGetScreenSize()
	local windowWidth, windowHeight = 851, 689
	local left = screenWidth/2 - windowWidth/2
	local top = screenHeight/2 - windowHeight/2
	gui["_root"] = guiCreateWindow(left, top, windowWidth, windowHeight, "San Andreas Airports - Federal Aviation Administration", false)
	guiWindowSetSizable(gui["_root"], false)

	local processedText = tostring(data)
	
	--gui["label"] = guiCreateLabel(10, 25, 521, 641, "LSA map", false, gui["_root"])
	--guiLabelSetHorizontalAlign(gui["label"], "left", false)
	--guiLabelSetVerticalAlign(gui["label"], "center")

	--gui["map"] = guiCreateStaticImage(10, 25, 521, 641, "/images/map_"..map..".png", false, gui["_root"])
	
	gui["label_2"] = guiCreateLabel(560, 35, 211, 21, "Awaiting", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["label_2"], "left", false)
	guiLabelSetVerticalAlign(gui["label_2"], "center")
	
	gui["label_3"] = guiCreateLabel(560, 65, 131, 16, "Ground: ", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["label_3"], "left", false)
	guiLabelSetVerticalAlign(gui["label_3"], "center")
	
	gui["label_4"] = guiCreateLabel(560, 85, 121, 41, "Runways: ", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["label_4"], "left", false)
	guiLabelSetVerticalAlign(gui["label_4"], "center")
	
	gui["label_5"] = guiCreateLabel(560, 135, 211, 21, "Please choose a map.", false, gui["_root"])
	guiLabelSetHorizontalAlign(gui["label_5"], "left", false)
	guiLabelSetVerticalAlign(gui["label_5"], "center")
	
	gui["pushButton"] = guiCreateButton(570, 235, 101, 31, "LSA", false, gui["_root"])
		addEventHandler("onClientGUIClick", gui["pushButton"], function ()
				destroySomeElements()				
				gui["map"] = guiCreateStaticImage(10, 25, 521, 641, "/images/map_LSA.jpg", false, gui["_root"])
				guiSetText(gui["label_2"], "Controlled")
				guiSetText(gui["label_3"], "Ground: 122.800")
				guiSetText(gui["label_4"], "Runways: 09, 27")
				guiSetText(gui["label_5"], "CHECK IF TOWER IS ACTIVE")
				guiSetText(gui["_root"], "LSA - "..basic_title)
			end, false)
	
	gui["pushButton_2"] = guiCreateButton(570, 275, 101, 31, "SFA", false, gui["_root"])
		addEventHandler("onClientGUIClick", gui["pushButton_2"], function ()
				destroySomeElements()				
				gui["map"] = guiCreateStaticImage(10, 25, 521, 641, "/images/map_SFA.png", false, gui["_root"])
				guiSetText(gui["label_2"], "Uncontrolled")
				guiSetText(gui["label_3"], "Ground: 118.500")
				guiSetText(gui["label_4"], "Runways: 22, 04")
				guiSetText(gui["label_5"], "ASSUME TOWER IS NOT ACTIVE")
				guiSetText(gui["_root"], "SFA - "..basic_title)
			end, false)
	
	gui["pushButton_3"] = guiCreateButton(570, 315, 101, 31, "LVA", false, gui["_root"])
		addEventHandler("onClientGUIClick", gui["pushButton_3"], function ()
				destroySomeElements()				
				gui["map"] = guiCreateStaticImage(10, 25, 521, 641, "/images/map_LVA.png", false, gui["_root"])
				guiSetText(gui["label_2"], "Controlled")
				guiSetText(gui["label_3"], "Ground: 119.900")
				guiSetText(gui["label_4"], "Runways: 18, 36")
				guiSetText(gui["label_5"], "CHECK IF TOWER IS ACTIVE")
				guiSetText(gui["_root"], "LVA - "..basic_title)
			end, false)

	
	gui["pushButton_4"] = guiCreateButton(570, 355, 101, 31, "BCA", false, gui["_root"])
		addEventHandler("onClientGUIClick", gui["pushButton_4"], function ()
				destroySomeElements()				
				gui["map"] = guiCreateStaticImage(10, 25, 521, 641, "/images/map_BCA.jpg", false, gui["_root"])
				guiSetText(gui["label_2"], "Military")
				guiSetText(gui["label_3"], "Ground: N/A")
				guiSetText(gui["label_4"], "Runways: 22, 04")
				guiSetText(gui["label_5"], "PRIOR PERMISSION REQUIRED")
				guiSetText(gui["_root"], "BCA - "..basic_title)
			end, false)

	
	gui["pushButton_5"] = guiCreateButton(570, 395, 101, 31, "STA", false, gui["_root"])
		addEventHandler("onClientGUIClick", gui["pushButton_5"], function ()
				destroySomeElements()				
				gui["map"] = guiCreateStaticImage(10, 25, 521, 641, "/images/map_OCA.png", false, gui["_root"])
				guiSetText(gui["label_2"], "Controlled")
				guiSetText(gui["label_3"], "Ground: 117.00")
				guiSetText(gui["label_4"], "Runways: 36, 18")
				guiSetText(gui["label_5"], "CHECK IF TOWER IS ACTIVE")
				guiSetText(gui["_root"], "STA - "..basic_title)
			end, false)

	
	gui["pushButton_6"] = guiCreateButton(600, 515, 191, 91, "Close", false, gui["_root"])
		addEventHandler("onClientGUIClick", gui["pushButton_6"], function ()
				destroyElement(gui["_root"])
				guiSetInputMode("allow_binds")
				showCursor(false)
			end, false)

	gui["pushButton_7"] = guiCreateButton(700, 315, 101, 31, "NOTAMs", false, gui["_root"])
		addEventHandler("onClientGUIClick", gui["pushButton_7"], function ()
				destroySomeElements()
				--triggerServerEvent("fetchNotamData", resourceRoot)
				guiSetText(gui["_root"], "NOTAMs - "..basic_title)					
				gui["memo"] = guiCreateMemo(10, 25, 521, 641, processedText, false, gui["_root"])
				guiMemoSetReadOnly(gui["memo"], true)
				if exports.factions:isPlayerInFaction(localPlayer, 47) then
					guiMemoSetReadOnly(gui["memo"], false)
					gui["pushButton_8"] = guiCreateButton(700, 345, 101, 31, "SAVE", false, gui["_root"])
						addEventHandler("onClientGUIClick", gui["pushButton_8"], function ()
							outputDebugString("Clicked!")
							triggerServerEvent("updateNotamData", localPlayer, guiGetText(gui["memo"]))
						end, false)
				end
			end, false)
	
	return gui, windowWidth, windowHeight
end
addEvent("build_Dialog", true)
addEventHandler("build_Dialog", localPlayer, build_Dialog)


function destroySomeElements()
	if gui["memo"] and isElement(gui["memo"]) then destroyElement(gui["memo"]) end	
	if gui["map"] and isElement(gui["map"]) then destroyElement(gui["map"]) end
	if gui["pushButton_8"] and isElement(gui["pushButton_8"]) then destroyElement(gui["pushButton_8"]) end
end

function listenToServerCall(data)
	guiSetText(gui["memo"], data)
end
addEvent("listenToServerCall", true)
addEventHandler("listenToServerCall", resourceRoot, listenToServerCall)