--[[local MarijuanaPlantGUIState = nil
ax, ay = nil

function clickMarijuanaPlant(button, state, absX, absY, wx, wy, wz, element)
	if (button=="right") and (state=="down") then
		for k, v in pairs(getElementsByType("object", getResourceRootElement())) do
			if isElementStreamedIn(v) then
				local dbid = getElementData(v, "marijuanaplant:id")
				local x, y, z = getElementPosition(v)
				local distance = getDistanceBetweenPoints3D(wx, wy, wz, x, y, z)
				if (distance<=1.4) then
					if (MarijuanaPlantGUIState == 1) then
						hideMarijuanaPlantGUI()
						showCursor(false)
					else
						id = getElementData(v, "marijuanaplant:id")
						grams = getElementData(v, "marijuanaplant:grams")
						day = getElementData(v, "marijuanaplant:day")
						timer = getElementData(v, "marijuanaplant:timer")
						showMarijuanaPlantGUI(dbid, grams, day, timer)
						showCursor(true)
					end
				end
			end
		end
	end
end
addEventHandler("onClientClick", getRootElement(), clickMarijuanaPlant)


function showMarijuanaPlantGUI(dbid, grams, day, timer)
	MarijuanaPlantGUIState = 1
	MarijuanaPlantGUI = guiCreateWindow(708,329,228,203,"Marijuana Plant: #"..dbid,false)
	guiWindowSetSizable(MarijuanaPlantGUI, false)
	
	MarijuanaPlantINFO = guiCreateMemo(9,21,210,152,"ID: "..dbid.."\nGrams: "..grams.."\nDay: "..day.."\nTimer: "..timer.." milliseconds",false,MarijuanaPlantGUI)
	guiMemoSetReadOnly (MarijuanaPlantINFO, true)
	
	if grams == 84 then
		GrabDrugButton = guiCreateButton(9,175,102,19,"Grab Marijuana",false,MarijuanaPlantGUI)
		addEventHandler("onClientGUIClick", GrabDrugButton, giveMarijuana, false)
	else
		GrabDrugButton = guiCreateButton(9,175,102,19,"Grab Marijuana",false,MarijuanaPlantGUI)
		guiSetEnabled(GrabDrugButton, false)
	end
	
	CloseButton = guiCreateButton(114,175,105,19,"Close",false,MarijuanaPlantGUI)
	addEventHandler("onClientGUIClick", CloseButton, hideMarijuanaPlantGUI, false)
end

function hideMarijuanaPlantGUI()
	MarijuanaPlantGUIState = 0
	destroyElement(MarijuanaPlantGUI)
	showCursor(false)
end
addEvent( "hideMarijuanaPlantGUI", true )
addEventHandler( "hideMarijuanaPlantGUI", getRootElement(), hideMarijuanaPlantGUI)

function giveMarijuana()
	thePlayer = getLocalPlayer()
	triggerServerEvent("giveMarijuanaToPlayer", getLocalPlayer(), thePlayer, grams, id)
end]]