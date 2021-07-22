

function showImpoundUI(vehElementsret)
	if not wImpound then
		local width, height = 400, 200
		local scrWidth, scrHeight = guiGetScreenSize()
		local x = scrWidth - width
		local y = scrHeight/10
		
		wImpound = guiCreateWindow(x, y, width, height, "Impound: Release a vehicle", false)
		guiWindowSetSizable(wImpound, false)
		
		bClose = guiCreateButton(0.6, 0.85, 0.2, 0.1, "Close", true, wImpound)
		bRelease = guiCreateButton(0.825, 0.85, 0.2, 0.1, "Release", true, wImpound)
		addEventHandler("onClientGUIClick", bClose, hideImpoundUI, false)
		addEventHandler("onClientGUIClick", bRelease, releaseCar, false)
		

		gCars = guiCreateGridList(0.05, 0.1, 0.9, 0.65, true, wImpound)
		addEventHandler("onClientGUIClick", gCars, updateCar, false)
		local col = guiGridListAddColumn(gCars, "Impounded Vehicles", 0.7)
		IDcolumn = guiGridListAddColumn(gCars, "ID", 0.2)
		
		for key, value in ipairs(vehElementsret) do
			local dbid = getElementData(value, "dbid")
			local row = guiGridListAddRow(gCars)
			guiGridListSetItemText(gCars, row, col, exports.global:getVehicleName(value), false, false)
			guiGridListSetItemText(gCars, row, IDcolumn, tostring(dbid), false, false)
		end
		guiGridListSetSelectedItem(gCars, 0, 1)
		
		lCost = guiCreateLabel(0.3, 0.85, 0.2, 0.1, "Cost: $1000.00", true, wImpound)
		guiSetFont(lCost, "default-bold-small")
		
		updateCar()
			

		guiSetInputEnabled(true)
		
		outputChatBox("Welcome to the TTR Impound Lot.")
	end
end

function updateCar()
	local row, col = guiGridListGetSelectedItem(gCars)
	
	if (row~=-1) and (col~=-1) then
		guiSetText(lCost, "Cost: $1000.00")
		
		if not exports.global:hasMoney(getLocalPlayer(), 250) and exports.global:hasItem(getLocalPlayer(), 3, guiGridListGetItemText(gCars, row, IDcolumn)) then
			guiLabelSetColor(lCost, 255, 0, 0)
			guiSetEnabled(bRelease, false)
		else
			guiLabelSetColor(lCost, 0, 255, 0)
			guiSetEnabled(bRelease, true)
		end
	else
		guiSetEnabled(bRelease, false)
	end
end


function hideImpoundUI()
	destroyElement(bClose)
	bClose = nil
	
	destroyElement(bRelease)
	bRelease = nil

	
	destroyElement(wImpound)
	wImpound = nil
	
	setCameraTarget(getLocalPlayer())
	guiSetInputEnabled(false)
end

function releaseCar(button)
	if (button=="left") then
		local row, col = guiGridListGetSelectedItem(gCars)
		if row ~= -1 and col ~= -1 then
			triggerServerEvent("releaseCar", getLocalPlayer(), tonumber(guiGridListGetItemText (gCars, row, 2 )))
			hideImpoundUI()
		end
	end
end
addEvent("ShowImpound", true)
addEventHandler("ShowImpound", getRootElement(), showImpoundUI)
