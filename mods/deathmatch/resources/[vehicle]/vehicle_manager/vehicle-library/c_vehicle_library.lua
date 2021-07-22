--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]
local vehLib, VehLibGrid, addVehWindow, editFuelWindow = nil, nil, nil, nil
local buttons = {}
local labels = {}
local edits = {}
local memos = {}
local checkboxes = {}
local col = {}
local sx, sy = guiGetScreenSize()
local gui = {}
local page = 1
carshops = {}
--[[
{
	[1] = {"grotti", "Grotti's Cars"},
	[2] = {"JeffersonCarShop", "Jefferson Car Shop"},
	[3] = {"IdlewoodBikeShop", "Idlewood Bike Shop"},
	[4] = {"SandrosCars", "Sandro's Cars"},
	[5] = {"IndustrialVehicleShop", "Industrial Vehicle Shop"},
}
]]

function accountNameBuilder(id)
	accountName = false
	if id and tonumber(id)>0 then
		local name = exports.cache:getUsernameFromId(id)
		if name then
			accountName = name
		end
	end
	return accountName
end

local function updateLibraryGrid(vehs)
	guiGridListClear(VehLibGrid)
	for i = 1, #vehs do
		local row = guiGridListAddRow(VehLibGrid)
		guiGridListSetItemText(VehLibGrid, row, col.id, vehs[i].id or "", false, true)
		guiGridListSetItemText(VehLibGrid, row, col.enabled, ((vehs[i].enabled == "1") and "Yes" or "No"), false, true)
		guiGridListSetItemText(VehLibGrid, row, col.mtamodel, getVehicleNameFromModel(tonumber(vehs[i].vehmtamodel)).." ("..vehs[i].vehmtamodel..")", false, false)
		guiGridListSetItemText(VehLibGrid, row, col.brand, vehs[i].vehbrand, false, false)
		guiGridListSetItemText(VehLibGrid, row, col.model, vehs[i].vehmodel, false, false)
		guiGridListSetItemText(VehLibGrid, row, col.year, vehs[i].vehyear, false, false)
		guiGridListSetItemText(VehLibGrid, row, col.price, "$"..exports.global:formatMoney(vehs[i].vehprice), false, false)
		guiGridListSetItemText(VehLibGrid, row, col.tax, "$"..exports.global:formatMoney(vehs[i].vehtax), false, false)
		guiGridListSetItemText(VehLibGrid, row, col.notes, vehs[i].notes, false, false)
		guiGridListSetItemText(VehLibGrid, row, col.createdby, (accountNameBuilder(vehs[i].createdby) or "No-one") , false, false)
		guiGridListSetItemText(VehLibGrid, row, col.createdate, (vehs[i].createdate or "No-one"), false, true)
		guiGridListSetItemText(VehLibGrid, row, col.updatedby, (accountNameBuilder(vehs[i].updatedby) or "No-one"), false, false)
		guiGridListSetItemText(VehLibGrid, row, col.updatedate, vehs[i].updatedate, false, true)
		local spawntoText = ""
		if vehs[i].spawnto ~= "0" and carshops[tonumber(vehs[i].spawnto)] then
			spawntoText = carshops[tonumber(vehs[i].spawnto)].nicename
		end
		guiGridListSetItemText(VehLibGrid, row, col.spawnto, (spawntoText or vehs[i].spawnto), false, false)
	end
end

function showLibrary(vehs, thePed)
	if isElement(vehLib) then
		closeLibrary()
	end

	if not vehs then
		--return false
	end

	showCursor(true)

	local w, h = 784, 562
	page = 1

	-- Below resizes the grid depending if they're on the vehlib or are on the vehicle stores.
	local gridW, gridH = 0.9758,0.8541
	if not thePed then 
		gridW, gridH = 0.9758,0.8000
	end

	vehLib = guiCreateWindow((sx-w)/2,(sy-h)/2,w,h,"Custom Vehicles System - Vehicle Library",false)
	guiWindowSetSizable(vehLib,false)
	VehLibGrid = guiCreateGridList(0.0115,0.0463,gridW,gridH,true,vehLib)

	col.id = guiGridListAddColumn(VehLibGrid,"ID",0.06)
	col.enabled = guiGridListAddColumn(VehLibGrid,"Enabled",0.06)
	col.mtamodel = guiGridListAddColumn(VehLibGrid,"MTA Model",0.15)
	col.brand = guiGridListAddColumn(VehLibGrid,"Brand",0.15)
	col.model = guiGridListAddColumn(VehLibGrid,"Model",0.15)
	col.year = guiGridListAddColumn(VehLibGrid,"Year",0.1)
	col.price = guiGridListAddColumn(VehLibGrid,"Price",0.1)
	col.tax = guiGridListAddColumn(VehLibGrid,"Tax",0.1)
	col.updatedby = guiGridListAddColumn(VehLibGrid,"Updated By",0.15)
	col.updatedate = guiGridListAddColumn(VehLibGrid,"Update Date",0.2)
	col.createdby = guiGridListAddColumn(VehLibGrid,"Created By",0.15)
	col.createdate = guiGridListAddColumn(VehLibGrid,"Create Date",0.2)
	col.notes = guiGridListAddColumn(VehLibGrid,"Notes",0.5)
	col.spawnto = guiGridListAddColumn(VehLibGrid,"Spawn to",0.2)

	carshops = exports["carshop-system"]:getCarShops()

	updateLibraryGrid(vehs)

	if thePed and isElement(thePed) and getElementData(thePed, "carshop") then
		local drivetestPrice = 25
		local orderPrice = 0
		buttons["testdrive"] = guiCreateButton(0.0115,0.9181,0.1237,0.0587,"Test Drive ($"..drivetestPrice..")",true,vehLib)
		guiSetFont(buttons["testdrive"],"default-bold-small")
		--guiSetEnabled(buttons["testdrive"], false)
		addEventHandler( "onClientGUIClick", buttons["testdrive"],
			function( button )
				if button == "left" then
					local row, col = -1, -1
					local row, col = guiGridListGetSelectedItem(VehLibGrid)
					if row ~= -1 and col ~= -1 then
						local vehShopID = guiGridListGetItemText( VehLibGrid , row, 1 )
						--outputChatBox(vehShopID)
						triggerServerEvent("vehicle-manager:handling:createTestVehicle", localPlayer, tonumber(vehShopID), thePed, false)
						closeLibrary()
						playSuccess()
					else
						guiSetText(vehLib, "You need to select a vehicle from the list above first.")
						playError()
						triggerServerEvent("shop:storeKeeperSay", localPlayer, localPlayer, "Which one do you want to test?" , getElementData(thePed, "name"))
					end
				end
			end,
		false)

		buttons["ordervehicle"] = guiCreateButton(0.148,0.9181,0.1237,0.0587,"Order Vehicle",true,vehLib)
		guiSetFont(buttons["ordervehicle"],"default-bold-small")

		addEventHandler( "onClientGUIClick", buttons["ordervehicle"],
			function( button )
				if button == "left" then
					local row, col = -1, -1
					local row, col = guiGridListGetSelectedItem(VehLibGrid)
					if row ~= -1 and col ~= -1 then
						-- check if player has a cellphone.
						local vehShopID = guiGridListGetItemText( VehLibGrid , row, 1 )
						triggerServerEvent("vehicle-manager:handling:orderVehicle", localPlayer, tonumber(vehShopID), thePed)
						closeLibrary()
						playSuccess()
					else
						guiSetText(vehLib, "You need to select a vehicle from the list above first.")
						playError()
						triggerServerEvent("shop:storeKeeperSay", localPlayer, localPlayer, "Which one do you want to order?" , getElementData(thePed, "name"))
					end
				end
			end,
		false)


		local playerOrderedFromShop = getElementData(localPlayer, "carshop:grotti:orderedvehicle:"..getElementData(thePed, "carshop"))
		if playerOrderedFromShop then
			guiSetEnabled(buttons["ordervehicle"], false)
			buttons["cancelorder"] = guiCreateButton(0.148,0.9181,0.1237,0.0587,"Cancel Order",true,vehLib)
			guiSetFont(buttons["cancelorder"],"default-bold-small")
			addEventHandler( "onClientGUIClick", buttons["cancelorder"],
				function( button )
					if button == "left" then
						triggerServerEvent("vehicle-manager:handling:orderVehicle:cancel", localPlayer, getElementData(thePed, "carshop"))
						triggerServerEvent("shop:storeKeeperSay", localPlayer, localPlayer, "Sure!" , getElementData(thePed, "name"))
						closeLibrary()
						playSuccess()
					end
				end,
			false)
		end

	else
		buttons[1] = guiCreateButton(0.0115,0.9181,0.1237,0.0587,"Create",true,vehLib)
		guiSetFont(buttons[1],"default-bold-small")
		addEventHandler( "onClientGUIClick", buttons[1], function()
			if source == buttons[1] then
				local veh = {}
				addNewVehicle(veh)
			end
		end)
		guiSetEnabled(buttons[1], false)

		buttons[2] = guiCreateButton(0.148,0.9181,0.1237,0.0587,"View/Modify",true,vehLib)
		guiSetFont(buttons[2],"default-bold-small")
		addEventHandler( "onClientGUIClick", buttons[2],
			function( button )
				if button == "left" then
					local row, col = -1, -1
					local row, col = guiGridListGetSelectedItem(VehLibGrid)
					if row ~= -1 and col ~= -1 then
						triggerServerEvent("vehlib:getCurrentVehicleRecord", localPlayer, tonumber(guiGridListGetItemText( VehLibGrid , row, 1 )))
					else
						guiSetText(vehLib, "You need to select a record from the list above first.")
						playError()
					end
				end
			end,
		false)
		guiSetEnabled(buttons[2], false)

		buttons[3] = guiCreateButton(0.2844,0.9181,0.1237,0.0587,"Handling",true,vehLib)
		guiSetFont(buttons[3],"default-bold-small")
		guiSetEnabled(buttons[3], false)
		addEventHandler( "onClientGUIClick", buttons[3],
			function( button )
				if button == "left" then
					local row, col = -1, -1
					local row, col = guiGridListGetSelectedItem(VehLibGrid)
					if row ~= -1 and col ~= -1 then
						local vehShopID = guiGridListGetItemText( VehLibGrid , row, 1 )
						exports.global:fadeToBlack()
						setTimer(function ()
							triggerServerEvent("vehicle-manager:handling:createTestVehicle", getLocalPlayer(), tonumber(vehShopID), thePed, true)
						end, 1000, 1)
						closeLibrary()
					else
						guiSetText(vehLib, "You need to select a record from the list above first.")
						playError()
					end
				end
			end,
		false)

		buttons[4] = guiCreateButton(0.4209,0.9181,0.1237,0.0587,"Delete",true,vehLib)
		guiSetFont(buttons[4],"default-bold-small")
		addEventHandler( "onClientGUIClick", buttons[4],
			function( button )
				if button == "left" then
					local row, col = -1, -1
					local row, col = guiGridListGetSelectedItem(VehLibGrid)
					if row ~= -1 and col ~= -1 then
						local createdby = guiGridListGetItemText( VehLibGrid , row, 11 )
						if createdby ~= getElementData(localPlayer, "account:username") and not exports.integration:isPlayerVehicleConsultant(localPlayer)  then
							guiSetText(vehLib, "You can only delete vehicles you added. Notify "..createdby.." if this vehicle isn't appropriate.")
							playError()
						else
							local id = guiGridListGetItemText( VehLibGrid , row, 1 )
							local brand = guiGridListGetItemText( VehLibGrid , row, 4 )
							local model = guiGridListGetItemText( VehLibGrid , row, 5 )
							showConfirmDelete(id, brand, model, createdby)
						end
					else
						guiSetText(vehLib, "You need to select a record from the list above first.")
						playError()
					end
				end
			end,
		false)
		guiSetEnabled(buttons[4], false)

		buttons[5] = guiCreateButton(0.5574,0.9181,0.1237,0.0587,"Refresh",true,vehLib)
		guiSetFont(buttons[5],"default-bold-small")
		addEventHandler( "onClientGUIClick", buttons[5], function(button)
			if button == "left" then
				refreshLibrary()
			end
		end, false)
		--guiSetEnabled(buttons[5], false)

		buttons[7] = guiCreateButton(0.6939,0.9181,0.1237,0.0587,"Restart Shops",true,vehLib)
		guiSetFont(buttons[7],"default-bold-small")
		addEventHandler( "onClientGUIClick", buttons[7], function(button)
			if button == "left" then
				triggerServerEvent("vehlib:refreshcarshops", localPlayer)
			end
		end, false)
		guiSetEnabled(buttons[7], false)


		if exports.integration:isPlayerVehicleConsultant(localPlayer) or exports.integration:isPlayerLeadAdmin(localPlayer) then
			guiSetEnabled(buttons[1], true) -- CREATE
			guiSetEnabled(buttons[2], true) -- EDIT
			guiSetEnabled(buttons[3], true) -- HANDLING
			guiSetEnabled(buttons[4], true) -- DELETE
			guiSetEnabled(buttons[7], true) -- RESTART CARSHOP
		elseif exports.integration:isPlayerTrialAdmin(localPlayer) or exports.integration:isPlayerVCTMember(localPlayer) then
			guiSetEnabled(buttons[7], true) -- RESTART CARSHOP
			guiSetEnabled(buttons[3], true) -- HANDLING
		end

		-- NEXT, PREVIOUS AND SEARCH FEATURE.
		buttons[13] = guiCreateButton(0.8304,0.8500,0.1569,0.0587, "Next Page",true,vehLib)
		guiSetFont(buttons[13],"default-bold-small")
		addEventHandler( "onClientGUIClick", buttons[13], function(button)
			if button == "left" then
				page = page + 1
				triggerServerEvent("vehlib:fetchMoreLibraryData", localPlayer, page)
			end
		end, false)

		buttons[14] = guiCreateButton(0.6654,0.8500,0.1569,0.0587, "Previous Page",true,vehLib)
		guiSetFont(buttons[14],"default-bold-small")
		addEventHandler( "onClientGUIClick", buttons[14], function(button)
			if button == "left" then
				if page == 1 then return end
				page = page - 1
				triggerServerEvent("vehlib:fetchMoreLibraryData", localPlayer, page)
			end
		end, false)

		buttons[15] = guiCreateButton(0.5000,0.8500,0.1569,0.0587, "Search",true,vehLib)
		guiSetFont(buttons[15],"default-bold-small")
		addEventHandler("onClientKey", root, keyHandler)
		addEventHandler( "onClientGUIClick", buttons[15], function(button)
			if button == "left" then
				searchLibrary(guiGetText(edits[10]))
			end
		end, false)

		edits[10] = guiCreateEdit(0.0135,0.8500,0.4750,0.0580,"Make, Model, Year, MTA Model",true,vehLib)
		addEventHandler("onClientGUIClick", edits[10], function(button)
			if button == "left" then 
				guiSetText(edits[10], "")
			end
		end, false)
		guiSetInputEnabled(true)
	end
			
	buttons[6] = guiCreateButton(0.8304,0.9181,0.1569,0.0587,"Close",true,vehLib)
	guiSetFont(buttons[6],"default-bold-small")
	addEventHandler( "onClientGUIClick", buttons[6], function()
		if source == buttons[6] then
			closeLibrary()
		end
	end)
	triggerEvent("hud:convertUI", localPlayer, vehLib)
end
addEvent("vehlib:showLibrary", true)
addEventHandler("vehlib:showLibrary",getLocalPlayer(), showLibrary)

addEvent("vehlib:loadPage", true)
addEventHandler("vehlib:loadPage", root, function(vehs, search)
	if vehs then
		updateLibraryGrid(vehs)

		if not guiGetEnabled(buttons[13]) then
			guiSetEnabled(buttons[13], true)
		end

		if search then 
			guiSetEnabled(buttons[13], false)
			guiSetEnabled(buttons[14], false)
		end
	end
end)

addEvent("vehlib:hitFinalPage", true)
addEventHandler("vehlib:hitFinalPage", root, function()
	guiSetEnabled(buttons[13], false)
end)

function searchLibrary(text)
	if string.len(text) < 1 then 
		return false
	end

	if text == "Make, Model, Year, MTA Model" then 
		return false
	end
	
	triggerServerEvent("vehlib:searchLibrary", localPlayer, text)
end

function keyHandler(button, press)
	if button == "enter" and press then 
		searchLibrary(guiGetText(edits[10]))
	end
end

function closeLibrary()
	if isElement(vehLib) then
		destroyElement(vehLib)
		vehLib = nil
	end
	removeEventHandler("onClientKey", root, keyHandler)
	showCursor(false)
	guiSetInputEnabled(false)
end

function refreshLibrary()
	triggerServerEvent("vehlib:sendLibraryToClient", localPlayer, localPlayer)
end


function addNewVehicle(veh)
	if vehLib then
		guiSetEnabled(vehLib, false)
	end

	if addVehWindow then
		closeAddNewVehicle()
		return false
	end
	guiSetInputEnabled(true)

	this = {}
	local fuel = veh.fuel or {}

	local w, h = 438,392+30+40
	addVehWindow = guiCreateWindow((sx-w)/2,(sy-h)/2,w,h,(veh.update and "Edit Vehicle" or "Add new vehicle"),false)
	guiSetProperty(addVehWindow,"AlwaysOnTop","true")
	guiSetProperty(addVehWindow,"SizingEnabled","false")

	labels[1] = guiCreateLabel(0.0251,0.06,0.4292,0.0459,"MTA Vehicle Model (Name or ID):",true,addVehWindow)
	guiSetFont(labels[1],"default-bold-small")
	edits[1] = guiCreateEdit(0.0388,0.11,0.4155,0.06,(veh.mtaModel or ""),true,addVehWindow)
	if veh.update then
		guiSetEnabled(edits[1], false)
	end
	labels[2] = guiCreateLabel(0.0251,0.185,0.4292,0.0459,"Brand:",true,addVehWindow)
	guiSetFont(labels[2],"default-bold-small")
	edits[2] = guiCreateEdit(0.0388,0.235,0.4155,0.06,(veh.brand or ""),true,addVehWindow)
	labels[3] = guiCreateLabel(0.0251,0.31,0.4292,0.0459,"Model:",true,addVehWindow)
	guiSetFont(labels[3],"default-bold-small")
	edits[3] = guiCreateEdit(0.0388,0.36,0.4155,0.06,(veh.model or ""),true,addVehWindow)
	labels[4] = guiCreateLabel(0.516,0.06,0.4292,0.0459,"Year:",true,addVehWindow)
	guiSetFont(labels[4],"default-bold-small")
	edits[4] = guiCreateEdit(0.5411,0.11,0.4155,0.06,(veh.year or ""),true,addVehWindow)
	labels[5] = guiCreateLabel(0.516,0.185,0.4292,0.0459,"Price:",true,addVehWindow)
	guiSetFont(labels[5],"default-bold-small")
	edits[5] = guiCreateEdit(0.5388,0.235,0.4178,0.06,(veh.price or ""),true,addVehWindow)
	labels[6] = guiCreateLabel(0.516,0.31,0.4292,0.0459,"Tax:",true,addVehWindow)
	guiSetFont(labels[6],"default-bold-small")
	edits[6] = guiCreateEdit(0.5434,0.36,0.4132,0.06,(veh.tax or ""),true,addVehWindow)

	labels["spawnto"] = guiCreateLabel(0.0251,0.435,0.4292,0.0459,"Spawn to carshop:",true,addVehWindow)
	guiSetFont(labels["spawnto"],"default-bold-small")

	carshops = exports["carshop-system"]:getCarShops()

	gui["spawnto"] =  guiCreateComboBox ( 0.0388,0.485,0.4155,0.06, "None", true, addVehWindow)
	guiComboBoxAdjustHeight(gui["spawnto"], #carshops+1)
	guiComboBoxAddItem(gui["spawnto"], "None")
	for i = 1,  #carshops do
		guiComboBoxAddItem(gui["spawnto"], carshops[i].nicename)
	end
	addEventHandler("onClientGUIComboBoxAccepted", gui["spawnto"], function()
		if guiComboBoxGetSelected(gui["spawnto"]) <= 0 then
			if isElement(edits[7]) then
				destroyElement(labels["stock"])
				destroyElement(labels["spawnrate"])
				destroyElement(edits[7])
				destroyElement(edits[8])
			end
		else
			if not isElement(edits[7]) then
				labels["stock"] = guiCreateLabel(0.0251,0.54,0.4292,0.0459,"Total Stock:",true,addVehWindow)
				guiSetFont(labels["stock"],"default-bold-small")
				labels["spawnrate"] = guiCreateLabel(0.516,0.54,0.4292,0.0459,"Spawn Rate:",true,addVehWindow)
				guiSetFont(labels["spawnrate"],"default-bold-small")

				edits[7] = guiCreateEdit(0.0388,0.58,0.4132,0.06,(veh.stock or "0"),true,addVehWindow)
				edits[8] = guiCreateEdit(0.5388,0.58,0.4132,0.06,(veh.spawn_rate or "0"),true,addVehWindow)
			end
		end
	end, false)
	guiComboBoxSetSelected(gui["spawnto"],tonumber(veh.spawnto) or -1 )
	triggerEvent("onClientGUIComboBoxAccepted", gui["spawnto"])

	labels["doortype"] = guiCreateLabel(0.516,0.435,0.4292,0.0459,"Doors:",true,addVehWindow)
	guiSetFont(labels["doortype"],"default-bold-small")

	gui["doortype"] = guiCreateComboBox( 0.5388,0.485,0.2,0.06, "Default", true, addVehWindow)
	guiComboBoxAdjustHeight(gui["doortype"], 3)
	outputDebugString(tostring(veh.doortype))
	guiComboBoxAddItem(gui["doortype"], "Default")
	guiComboBoxAddItem(gui["doortype"], "Scissor")
	guiComboBoxAddItem(gui["doortype"], "Butterfly")
	guiComboBoxSetSelected(gui["doortype"], veh.doortype or 0 )

	local fuelType, fuelConsumption, fuelCapacity
	if not fuel.type then
		fuelType = "Petrol"
		fuel.type = "petrol"
	else
		if fuel.type == "petrol" then
			fuelType = "Petrol"
		elseif fuel.type == "diesel" then
			fuelType = "Diesel"
		elseif fuel.type == "electric" then
			fuelType = "Electricity"
		elseif fuel.type == "jet" then
			fuelType = "JET A-1"
		elseif fuel.type == "avgas" then
			fuelType = "100LL AVGAS"
		else
			fuelType = "Petrol"
			fuel.type = "petrol"
		end
	end
	if not fuel.con then
		fuelConsumption = "0"
		fuel.con = 0
	else
		fuelConsumption = tostring(fuel.con)
	end
	if not fuel.cap then
		fuelCapacity = 50
		fuel.cap = 50
	else
		fuelCapacity = tostring(fuel.cap)
	end
	this.fuel = fuel

	--[[
	buttons[10] = guiCreateButton(0.0251,0.56,0.9178,0.08,"FUEL: "..fuelType.." | "..fuelConsumption.." ltr/km | "..fuelCapacity.." ltr",true,addVehWindow)
	guiSetFont(buttons[10],"default-small")
	addEventHandler( "onClientGUIClick", buttons[10], function()
		if source == buttons[10] then
			editFuel(fuel)
		end
	end)
	]]

	--outputChatBox(veh.spawnto)
	labels[7] = guiCreateLabel(0.0251,0.5383+0.1046+0.015,0.4292,0.0459,"Note(s):",true,addVehWindow)
	guiSetFont(labels[7],"default-bold-small")

	memos[1] = guiCreateMemo(0.0388,0.6224+0.07,0.9178,0.15,(veh.note or ""),true,addVehWindow)


	checkboxes[1] = guiCreateCheckBox(0.8,0.435,0.15,0.0459,"Enabled",false,true,addVehWindow) --0.5383
	if veh.enabled and tonumber(veh.enabled) == 1 then
		guiCheckBoxSetSelected(checkboxes[1], true)
	end

	if veh.update then
		checkboxes[2] = guiCreateCheckBox(0.8,0.495,0.151,0.0459,"Copy",false,true,addVehWindow)
	end


	buttons[8] = guiCreateButton(0.0388,0.8622,0.4475,0.0944,"Cancel",true,addVehWindow)
	guiSetFont(buttons[8],"default-bold-small")
	addEventHandler( "onClientGUIClick", buttons[8], function()
		if source == buttons[8] then
			closeAddNewVehicle()
		end
	end)

	buttons[9] = guiCreateButton(0.516,0.8622,0.4406,0.0944,"Validate",true,addVehWindow)
	guiSetFont(buttons[9],"default-bold-small")
	addEventHandler( "onClientGUIClick", buttons[9], function()
		if source == buttons[9] then
			validateCreateVehicle(veh)
		end
	end)

	triggerEvent("hud:convertUI", localPlayer, addVehWindow)
end
addEvent("vehlib:showEditVehicleRecord", true)
addEventHandler("vehlib:showEditVehicleRecord",getLocalPlayer(), addNewVehicle)

function editFuel(fuel)
	if editFuelWindow then
		closeEditFuel()
		return false
	end

	--local fuel = this.fuel

	local w, h = 438,392+30
	editFuelWindow = guiCreateWindow((sx-w)/2,(sy-h)/2,w,h,"Fuel settings",false)
	guiSetProperty(editFuelWindow,"AlwaysOnTop","true")
	guiSetProperty(editFuelWindow,"SizingEnabled","false")

	labels["engine"] = guiCreateLabel(0.0251,0.0867,0.4292,0.0459,"Engine Type:",true,editFuelWindow)
	guiSetFont(labels["doortype"],"default-bold-small")

	gui["engine"] = guiCreateComboBox( 0.0388,0.1327,0.2,0.0791, "Petrol", true, editFuelWindow)
	guiComboBoxAdjustHeight(gui["engine"], 5)
	outputDebugString(tostring(fuel.engine))
	guiComboBoxAddItem(gui["engine"], "Petrol")
	guiComboBoxAddItem(gui["engine"], "Diesel")
	guiComboBoxAddItem(gui["engine"], "Electric")
	guiComboBoxAddItem(gui["engine"], "Turbine (jet a-1)")
	guiComboBoxAddItem(gui["engine"], "Piston (avgas)")
	guiComboBoxSetSelected(gui["engine"], fuel.engine or 0 )

	labels[8] = guiCreateLabel(0.0251,0.185,0.4292,0.0459,"Consumption (litres/kilometer):",true,editFuelWindow)
	guiSetFont(labels[8],"default-bold-small")

	edits[8] = guiCreateEdit(0.0388,0.235,0.4155,0.06,(fuel.con or ""),true,editFuelWindow)

	labels[9] = guiCreateLabel(0.516,0.185,0.4292,0.0459,"Capacity (litres):",true,editFuelWindow)
	guiSetFont(labels[9],"default-bold-small")

	edits[9] = guiCreateEdit(0.5388,0.235,0.4178,0.06,(fuel.cap or ""),true,editFuelWindow)

	--shit
	buttons[11] = guiCreateButton(0.0388,0.8622,0.4475,0.0944,"Cancel",true,editFuelWindow)
	guiSetFont(buttons[11],"default-bold-small")
	addEventHandler( "onClientGUIClick", buttons[11], function()
		if source == buttons[11] then
			closeEditFuel()
		end
	end)

	buttons[12] = guiCreateButton(0.516,0.8622,0.4406,0.0944,"Update",true,editFuelWindow)
	guiSetFont(buttons[12],"default-bold-small")
	addEventHandler( "onClientGUIClick", buttons[12], function()
		if source == buttons[12] then
			--validateCreateVehicle(veh)
		end
	end)
	triggerEvent("hud:convertUI", localPlayer, editFuelWindow)
end

function closeEditFuel()
	if editFuelWindow then
		destroyElement(editFuelWindow)
		editFuelWindow = nil
	end
end

function closeAddNewVehicle()
	if editFuelWindow then
		destroyElement(editFuelWindow)
		editFuelWindow = nil
	end
	if addVehWindow then
		destroyElement(addVehWindow)
		addVehWindow = nil
	end

	if vehLib then
		guiSetEnabled(vehLib, true)
	end

	guiSetInputEnabled(false)
end

function validateCreateVehicle(data)
	if guiGetText(buttons[9]) == "Create" or guiGetText(buttons[9]) == "Update" then
		playSoundCreate()
		local veh = {}
		veh.mtaModel = guiGetText(edits[1])
		if not tonumber(veh.mtaModel) then
			veh.mtaModel = getVehicleModelFromName(veh.mtaModel)
		end
		veh.brand = guiGetText(edits[2])
		veh.model = guiGetText(edits[3])
		veh.year = guiGetText(edits[4])
		veh.price = guiGetText(edits[5])
		veh.tax = guiGetText(edits[6])
		veh.note = guiGetText(memos[1])
		if isElement(edits[7]) then
			veh.stock = math.floor(tonumber(guiGetText(edits[7])))
			veh.rate = math.floor(tonumber(guiGetText(edits[8])))
		end

		if data and data.update then
			veh.update = true
			veh.id = data.id
		else
			veh.update = false
		end


		if checkboxes[1] and isElement(checkboxes[1]) and guiCheckBoxGetSelected(checkboxes[1]) then
			veh.enabled = true
		else
			veh.enabled = false
		end

		if checkboxes[2] and isElement(checkboxes[2]) and guiCheckBoxGetSelected(checkboxes[2]) then
			veh.copy = true
		else
			veh.copy = false
		end


		local item = guiComboBoxGetSelected ( gui["spawnto"] )
		veh.spawnto = (item == -1) and 0 or item

		local item = guiComboBoxGetSelected ( gui["doortype"] )
		veh.doortype = (item == -1) and 0 or item

		triggerServerEvent("vehlib:createVehicle", localPlayer, veh)
		closeAddNewVehicle()
	else

		local allGood = true
		--VALIDATE MTA MODEL
		local input = guiGetText(edits[1])
		local vehName = getVehicleNameFromModel(input)
		local vehModel = getVehicleModelFromName(input)
		if input == "584" or input == "611" or input == "606" or input == "607" or input == "608" or input == "450" then
			guiSetText(labels[1], "MTA Vehicle Model (OK!):")
			guiLabelSetColor(labels[1], 0, 255,0)
		elseif vehName and vehName ~= "" then
			guiSetText(labels[1], "MTA Vehicle Model (OK!):")
			guiLabelSetColor(labels[1], 0, 255,0)
		elseif vehModel and tonumber(vehModel) then
			guiSetText(labels[1], "MTA Vehicle Model (OK!):")
			guiLabelSetColor(labels[1], 0, 255,0)
		elseif exports.integration:isPlayerScripter(getLocalPlayer()) then
			guiSetText(labels[1], "MTA Vehicle Model (OK!):")
			guiLabelSetColor(labels[1], 0, 255,0)
		else
			guiSetText(labels[1], "MTA Vehicle Model (Invalid!):")
			guiLabelSetColor(labels[1], 255, 0,0)
			allGood = false
		end

		--VALIDATE BRAND
		if string.len(guiGetText(edits[2])) > 0 then
			guiSetText(labels[2], "Brand (OK!):")
			guiLabelSetColor(labels[2], 0, 255,0)
		else
			guiSetText(labels[2], "Brand (Invalid!):")
			guiLabelSetColor(labels[2], 255, 0,0)
			allGood = false
		end

		--VALIDATE MODEL
		if string.len(guiGetText(edits[3])) > 0 then
			guiSetText(labels[3], "Model (OK!):")
			guiLabelSetColor(labels[3], 0, 255,0)
		else
			guiSetText(labels[3], "Model (Invalid!):")
			guiLabelSetColor(labels[3], 255, 0,0)
			allGood = false
		end

		--VALIDATE YEAR
		input = guiGetText(edits[4])
		if string.len(input) > 0 and tonumber(input) and tonumber(input) > 1000 and tonumber(input) < 3000 then
			guiSetText(labels[4], "Year (OK!):")
			guiLabelSetColor(labels[4], 0, 255,0)
		else
			guiSetText(labels[4], "Year (Invalid!):")
			guiLabelSetColor(labels[4], 255, 0,0)
			allGood = false
		end

		--VALIDATE PRICE
		input = guiGetText(edits[5])
		if string.len(input) > 0 and tonumber(input) and tonumber(input) > 0 then
			guiSetText(labels[5], "Price (OK!):")
			guiLabelSetColor(labels[5], 0, 255,0)
		else
			guiSetText(labels[5], "Price (Invalid!):")
			guiLabelSetColor(labels[5], 255, 0,0)
			allGood = false
		end

		--VALIDATE TAX
		input = guiGetText(edits[6])
		if string.len(input) > 0 and tonumber(input) and tonumber(input) >= 0 then
			guiSetText(labels[6], "Tax (OK!):")
			guiLabelSetColor(labels[6], 0, 255,0)
		else
			guiSetText(labels[6], "Tax (Invalid!):")
			guiLabelSetColor(labels[6], 255, 0,0)
			allGood = false
		end

		if isElement(edits[7]) then
			-- STOCK
			input = guiGetText(edits[7])
			if string.len(input) > 0 and tonumber(input) and math.floor(tonumber(input)) >= 1 then
				guiSetText(labels[7], "Total Stock (OK!):")
				guiLabelSetColor(labels[7], 0, 255,0)
			else
				guiSetText(labels[7], "Total Stock (Invalid!):")
				guiLabelSetColor(labels[7], 255, 0,0)
				allGood = false
			end
			-- SPAWN RATE
			input = guiGetText(edits[8])
			if string.len(input) > 0 and tonumber(input) and math.floor(tonumber(input)) >= 1 and math.floor(tonumber(input)) <= 100 then
				guiSetText(labels[8], "Spawn Rate (OK!):")
				guiLabelSetColor(labels[8], 0, 255,0)
			else
				guiSetText(labels[8], "Spawn Rate (Invalid!):")
				guiLabelSetColor(labels[8], 255, 0,0)
				allGood = false
			end
		end

		--CONCLUSION
		if allGood then
			if data and data.update then
				guiSetText(buttons[9], "Update")
			else
				guiSetText(buttons[9], "Create")
			end
			playSuccess()
		else
			guiSetText(buttons[9], "Validate")
			playError()
		end
	end
end

function showConfirmDelete(id, brand, model, createdby)
	local w, h = 394,111
	editFuelWindow = guiCreateWindow((sx-w)/2,(sy-h)/2,w,h,"",false)
	guiWindowSetSizable(editFuelWindow,false)
	guiSetProperty(editFuelWindow,"AlwaysOnTop","true")
	guiSetProperty(editFuelWindow,"TitlebarEnabled","false")
	labels[8] = guiCreateLabel(0.0254,0.2072,0.9645,0.1982,"Are you sure you want to delete veh #"..id.."("..brand.." "..model..")?",true,editFuelWindow)
	guiLabelSetHorizontalAlign(labels[8],"center",false)
	labels[9] = guiCreateLabel(0.0254,0.4054,0.9492,0.2162,"This action can't be undone!",true,editFuelWindow)
	guiLabelSetHorizontalAlign(labels[9],"center",false)
	buttons[10] = guiCreateButton(0.0254,0.6577,0.4695,0.2613,"Cancel",true,editFuelWindow)
	addEventHandler( "onClientGUIClick", buttons[10], function()
		if source == buttons[10] then
			closeConfirmDelete()
		end
	end)
	buttons[11] = guiCreateButton(0.5051,0.6577,0.4695,0.2613,"Confirm",true,editFuelWindow)
	addEventHandler( "onClientGUIClick", buttons[11], function()
		if source == buttons[11] then
			triggerServerEvent("vehlib:deleteVehicle", localPlayer, id)
			closeConfirmDelete()
			playSuccess()
		end
	end)
	triggerEvent("hud:convertUI", localPlayer, editFuelWindow)
end

function closeConfirmDelete()
	if editFuelWindow then
		destroyElement(editFuelWindow)
		editFuelWindow = nil
	end
end

function playError()
	playSoundFrontEnd(4)
end

function playSuccess()
	playSoundFrontEnd(13)
end

function playSoundCreate()
	playSoundFrontEnd(6)
end

function guiComboBoxAdjustHeight ( combobox, itemcount )
	if getElementType ( combobox ) ~= "gui-combobox" or type ( itemcount ) ~= "number" then error ( "Invalid arguments @ 'guiComboBoxAdjustHeight'", 2 ) end
	local width = guiGetSize ( combobox, false )
	return guiSetSize ( combobox, width, ( itemcount * 20 ) + 20, false )
end
