--MAXIME
local gui, grid, col, col2 = {}, {}, {}, {}
local screenWidth, screenHeight = guiGetScreenSize()
local defaultStations, donorStations = {}, {}
local stationToRenew = nil

function openRadioManager(defaultStations1, donorStations1)
	if true then--canAccessManager() then
		local perk = exports.donators:getPerks(28)
		closeNewStation()
		showCursor(true)
		guiSetInputEnabled(true)
		if defaultStations1 and type(defaultStations1) == "table" then
			defaultStations, donorStations = defaultStations1, donorStations1
		end
		if gui.main and isElement(gui.main) then
			guiSetText(gui.main, "Radio Station Manager")
			guiSetEnabled(gui.main, true)
		else
			setElementData(localPlayer, "gui:ViewingRadioManager", true, true)
			local w, h = 800,474
			local x, y = (screenWidth-w)/2, (screenHeight-h)/2
			gui.main = guiCreateWindow(x,y,w,h,"Radio Station Manager | Loading..",false)
			guiWindowSetSizable(gui.main, false)

			gui.tabpanel = guiCreateTabPanel(0.0122,0.0401,0.9757,0.87,true,gui.main)
			gui.defaultStations = guiCreateTab("Server's default stations",gui.tabpanel)
			gui.donorStations = guiCreateTab("Donor's stations",gui.tabpanel)

			grid.defaultStations = guiCreateGridList(0,0,1,1,true,gui.defaultStations)
			col.id = guiGridListAddColumn(grid.defaultStations,"ID",0.05)
			col.name = guiGridListAddColumn(grid.defaultStations,"Station Name",0.18)
			col.ip = guiGridListAddColumn(grid.defaultStations,"Station IP",0.3)
			col.status = guiGridListAddColumn(grid.defaultStations,"Status",0.1)
			col.owner = guiGridListAddColumn(grid.defaultStations,"Station Owner",0.1)
			col.expireDate = guiGridListAddColumn(grid.defaultStations,"Expire Date",0.16)
			col.order = guiGridListAddColumn(grid.defaultStations,"Order",0.08)

			grid.donorStations = guiCreateGridList(0,0,1,1,true,gui.donorStations)
			col2.id = guiGridListAddColumn(grid.donorStations,"ID",0.05)
			col2.name = guiGridListAddColumn(grid.donorStations,"Station Name",0.18)
			col2.ip = guiGridListAddColumn(grid.donorStations,"Station IP",0.3)
			col2.status = guiGridListAddColumn(grid.donorStations,"Status",0.1)
			col2.owner = guiGridListAddColumn(grid.donorStations,"Station Owner",0.1)
			col2.expireDate = guiGridListAddColumn(grid.donorStations,"Expire Date",0.16)
			col2.order = guiGridListAddColumn(grid.donorStations,"Order",0.08)

			gui.addNew = guiCreateButton(0.0135,0.9135,0.32476,0.0675,"Create new station",true,gui.main)
			guiSetFont(gui.addNew, "default-bold-small")
			addEventHandler("onClientGUIClick", gui.addNew, function()
				if source == gui.addNew then
					openNewStation()
				end
			end)

			gui.buyNew = guiCreateButton(0.0135,0.9135,0.32476,0.0675,"Purchase a new station ("..perk[2].." GC)",true,gui.main)
			guiSetFont(gui.buyNew, "default-bold-small")
			addEventHandler("onClientGUIClick", gui.buyNew, function()
				if source == gui.buyNew then
					openNewStation(nil, nil, nil, nil, nil, true)
				end
			end)
			guiSetVisible(gui.buyNew, false)

			gui.renew = guiCreateButton(0.0135,0.9135,0.32476,0.0675,"Renew station",true,gui.main)
			guiSetFont(gui.renew, "default-bold-small")
			addEventHandler("onClientGUIClick", gui.renew, function()
				if source == gui.renew and stationToRenew and type(stationToRenew) == "table" then
					renewStation(stationToRenew)
				else
					exports.global:playSoundError()
				end
			end)
			guiSetVisible(gui.renew, false)

			gui.refresh = guiCreateButton(0.0135+0.32476,0.9135,0.32476,0.0675,"Sync stations to all clients",true,gui.main)
			guiSetFont(gui.refresh, "default-bold-small")

			local timer1 = nil
			addEventHandler("onClientGUIClick", gui.refresh, function()
				if source == gui.refresh then
					guiSetEnabled(gui.refresh, false)
					exports.global:playSoundCreate()
					if isTimer(timer1) then
						killTimer(timer1)
					end
					timer1 = setTimer(function()
						if gui.refresh and isElement(gui.refresh) then
							guiSetEnabled(gui.refresh, true)
						end
					end, 5000, 1)
					triggerServerEvent("forceSyncStationsToAllclients", localPlayer)
				end
			end)

			gui.bClose = guiCreateButton(0.0135+0.32476*2,0.9135,0.32476,0.0675,"Close",true,gui.main)
			guiSetFont(gui.bClose, "default-bold-small")
			addEventHandler("onClientGUIClick", gui.bClose, function()
				if source == gui.bClose then
					closeRadioManager()
				end
			end)

			addEventHandler("onClientGUITabSwitched", root, tabSwitch)

			triggerServerEvent("openRadioManager", localPlayer)
			guiSetEnabled(gui.main, false)
		end
		updateDefaultStations()
		updateDonorStations()
	end
end
addEvent("openRadioManager", true)
addEventHandler("openRadioManager", root, openRadioManager)
addCommandHandler("radios", openRadioManager)

function closeRadioManager()
	if gui.main and isElement(gui.main) then
		setElementData(localPlayer, "gui:ViewingRadioManager", false, true)
		removeEventHandler("onClientGUITabSwitched", root, tabSwitch)
		closeNewStation()
		destroyElement(gui.main)
		guiSetInputEnabled(false)
		showCursor(false)
		gui.main = nil
	end
end

function tabSwitch(theTab)
	if theTab == gui.defaultStations then
		outputDebugString("defaultStations")
		guiSetVisible(gui.addNew, true)
		guiSetVisible(gui.buyNew, false)
		updateBottomBtns()
		guiSetVisible(gui.renew, false)
	elseif theTab == gui.donorStations then
		outputDebugString("donorStations")
		guiSetVisible(gui.addNew, false)
		guiSetVisible(gui.buyNew, true)
		if ownedAnyStation() then
			guiSetEnabled(gui.refresh, true)
		else
			guiSetEnabled(gui.refresh, false)
		end
	end
end

function ownedAnyStation()
	local username = getElementData(localPlayer, "account:username")
	for i, k in pairs(donorStations) do
		--outputChatBox(tostring(k["owner"]))
		--outputChatBox(tostring(username))
		if k["owner"] == username then
			return true
		end
	end
	return false
end

function togRadioManager(state)
	if gui.main and isElement(gui.main) then
		guiSetEnabled(gui.main, state)
	end
end

function accountNameBuilder(id)
	accountName = false
	if id then
		local name = exports.cache:getUsernameFromId(id)
		if name then
			accountName = name
		end
	end
	return accountName
end

function updateDefaultStations()
	guiGridListClear(grid.defaultStations)
	local maxRow = #defaultStations
	for i = 1, maxRow do
		local row = guiGridListAddRow(grid.defaultStations)
		guiGridListSetItemText(grid.defaultStations, row, col.id, defaultStations[i]["id"] , false, true)
		guiGridListSetItemText(grid.defaultStations, row, col.name, defaultStations[i]["station_name"] , false, false)
		guiGridListSetItemText(grid.defaultStations, row, col.ip, defaultStations[i]["source"] , false, false)
		guiGridListSetItemText(grid.defaultStations, row, col.status, (defaultStations[i]["enabled"] == "1" and "Activated" or "Deactivated"), false, false)
		guiGridListSetItemText(grid.defaultStations, row, col.owner, accountNameBuilder(defaultStations[i]["owner"]) or "No-one" , false, false)
		guiGridListSetItemText(grid.defaultStations, row, col.expireDate, defaultStations[i]["expire_date"] or "Never" , false, false)
		guiGridListSetItemText(grid.defaultStations, row, col.order, defaultStations[i]["order"] or "--" , false, true)
	end

	addEventHandler( "onClientGUIDoubleClick", grid.defaultStations,
		function( button )
			if button == "left" then
				local row, col = -1, -1
				local row, col = guiGridListGetSelectedItem(grid.defaultStations)
				if row ~= -1 and col ~= -1 then
					if exports.integration:isPlayerLeadAdmin(localPlayer) then
						local id = guiGridListGetItemText( grid.defaultStations , row, 1 )
						local name = guiGridListGetItemText( grid.defaultStations , row, 2 )
						local ip = guiGridListGetItemText( grid.defaultStations , row, 3 )
						local state = guiGridListGetItemText( grid.defaultStations , row, 4 )
						local order = guiGridListGetItemText( grid.defaultStations , row, 7 )
						openNewStation(id, name, ip, state, order)
					else
						exports.global:playSoundError()
					end
				end
			end
		end,
	false)
	updateBottomBtns()
end

function updateDonorStations()
	guiGridListClear(grid.donorStations)
	local maxRow = #donorStations
	for i = 1, maxRow do
		local row = guiGridListAddRow(grid.donorStations)
		guiGridListSetItemText(grid.donorStations, row, col2.id, donorStations[i]["id"] , false, true)
		guiGridListSetItemText(grid.donorStations, row, col2.name, donorStations[i]["station_name"] , false, false)
		guiGridListSetItemText(grid.donorStations, row, col2.ip, donorStations[i]["source"] , false, false)
		guiGridListSetItemText(grid.donorStations, row, col2.status, (donorStations[i]["enabled"] == "1" and "Activated" or "Deactivated"), false, false)
		guiGridListSetItemText(grid.donorStations, row, col2.owner, accountNameBuilder(donorStations[i]["owner"]) or "No-one" , false, false)
		guiGridListSetItemText(grid.donorStations, row, col2.expireDate, donorStations[i]["expire_date"] or "Never" , false, false)
		guiGridListSetItemText(grid.donorStations, row, col2.order, donorStations[i]["order"] or "--" , false, true)
	end

	addEventHandler( "onClientGUIDoubleClick", grid.donorStations,
		function( button )
			if button == "left" then
				local row, col = -1, -1
				local row, col = guiGridListGetSelectedItem(grid.donorStations)
				if row ~= -1 and col ~= -1 then
					local username = getElementData(localPlayer, "account:username")
					local owner = guiGridListGetItemText( grid.donorStations , row, 5 )
					if owner == username or exports.integration:isPlayerLeadAdmin(localPlayer) then
						local id = guiGridListGetItemText( grid.donorStations , row, 1 )
						local name = guiGridListGetItemText( grid.donorStations , row, 2 )
						local ip = guiGridListGetItemText( grid.donorStations , row, 3 )
						local state = guiGridListGetItemText( grid.donorStations , row, 4 )
						local order = guiGridListGetItemText( grid.donorStations , row, 7 )
						openNewStation(id, name, ip, state, order, true)
					else
						exports.global:playSoundError()
					end
				end
			end
		end,
	false)

	addEventHandler( "onClientGUIClick", grid.donorStations,
		function( button )
			if button == "left" then
				local row, col = -1, -1
				local row, col = guiGridListGetSelectedItem(grid.donorStations)
				if row ~= -1 and col ~= -1 then
					local username = getElementData(localPlayer, "account:username")
					local owner = guiGridListGetItemText( grid.donorStations , row, 5 )
					if owner == username then --or exports.integration:isPlayerLeadAdmin(localPlayer) then
						local id = guiGridListGetItemText( grid.donorStations , row, 1 )
						local name = guiGridListGetItemText( grid.donorStations , row, 2 )
						local ip = guiGridListGetItemText( grid.donorStations , row, 3 )
						local owner = guiGridListGetItemText( grid.donorStations , row, 5 )
						local ex = guiGridListGetItemText( grid.donorStations , row, 6 )
						guiSetVisible(gui.renew, true)
						guiSetVisible(gui.buyNew, false)
						stationToRenew = {id, name, ip, owner, ex}
					else
						guiSetVisible(gui.renew, false)
						guiSetVisible(gui.buyNew, true)
						stationToRenew = nil
					end
				end
			end
		end,
	false)
end

function updateBottomBtns()
	if exports.integration:isPlayerLeadAdmin(localPlayer) then
		guiSetEnabled(gui.addNew, true)
		guiSetEnabled(gui.refresh, true)
	else
		guiSetEnabled(gui.addNew, false)
		guiSetEnabled(gui.refresh, false)
	end
end

function openNewStation(id, name, ip, state, order, buyNew)

	closeNewStation()
	togRadioManager(false)
	exports.global:playSoundSuccess()
	local perk = exports.donators:getPerks(28)
	local w, h = 400, 135
	gui.wNewStation = guiCreateStaticImage(0, 0, w, h, ":resources/window_body.png", false)
	exports.global:centerWindow(gui.wNewStation)
	local margin = 10
	local lineH = 25
	local col1 = 85
	gui.l1 = guiCreateLabel(margin, margin, w-margin*2, lineH, "NEW STATION", false, gui.wNewStation)
	guiSetFont(gui.l1, "default-bold-small")
	guiLabelSetHorizontalAlign(gui.l1, "center", true)
	guiLabelSetVerticalAlign(gui.l1, "center", true)

	gui.l2 = guiCreateLabel(margin, margin+lineH, col1, lineH, "Station Name:", false, gui.wNewStation)
	guiSetFont(gui.l2, "default-bold-small")
	guiLabelSetVerticalAlign(gui.l2, "center", true)
	gui.eName = guiCreateEdit(margin+col1, margin+lineH, w-margin*2-col1, lineH, name and name or "", false, gui.wNewStation)

	gui.l3 = guiCreateLabel(margin, margin+lineH*2, col1, lineH, "Station IP:", false, gui.wNewStation)
	guiSetFont(gui.l3, "default-bold-small")
	guiLabelSetVerticalAlign(gui.l3, "center", true)
	gui.eIP = guiCreateEdit(margin+col1, margin+lineH*2, w-margin*2-col1, lineH, ip and ip or "", false, gui.wNewStation)

	local buttons = 5
	local buttonW = (w-margin*2)/buttons

	local moveCost = math.ceil(perk[2]/10)

	gui.bMoveUp = guiCreateButton(margin, margin+lineH/2+lineH*3, buttonW , lineH, buyNew and "Move up\n("..moveCost.." GCs)" or "Move up",false,gui.wNewStation)
	guiSetFont(gui.bMoveUp, buyNew and "default-small" or "default-bold-small")
	addEventHandler("onClientGUIClick", gui.bMoveUp, function()
		if source == gui.bMoveUp then
			triggerServerEvent("moveStationPosition", localPlayer, id, name, order, true, buyNew)
			exports.global:playSoundCreate()
			closeNewStation()
		end
	end)

	gui.bMoveDown = guiCreateButton(margin+buttonW, margin+lineH/2+lineH*3, buttonW , lineH, buyNew and "Move down\n("..moveCost.." GCs)" or "Move down",false,gui.wNewStation)
	guiSetFont(gui.bMoveDown, buyNew and "default-small" or "default-bold-small")
	addEventHandler("onClientGUIClick", gui.bMoveDown, function()
		if source == gui.bMoveDown then
			triggerServerEvent("moveStationPosition", localPlayer, id, name, order, false, buyNew)
			exports.global:playSoundCreate()
			closeNewStation()
		end
	end)

	gui.bSubmit = guiCreateButton(margin+buttonW*2, margin+lineH/2+lineH*3, buttonW , lineH, "Create",false,gui.wNewStation)
	guiSetFont(gui.bSubmit, "default-bold-small")
	addEventHandler("onClientGUIClick", gui.bSubmit, function()
		if source == gui.bSubmit then
			local sName = guiGetText(gui.eName)
			local sIP = guiGetText(gui.eIP)
			if string.len(sName) < 1 or string.len(sIP) < 1 then
				exports.global:playSoundError()
			else
				if guiGetText(gui.bSubmit) == "Save" then
					triggerServerEvent("editStation", localPlayer, id, sName, sIP)
					exports.global:playSoundCreate()
				elseif guiGetText(gui.bSubmit) == "Create" then
					triggerServerEvent("createNewStation", localPlayer, sName, sIP)
					exports.global:playSoundCreate()
				elseif guiGetText(gui.bSubmit) == "Purchase" then
					triggerServerEvent("createNewStation", localPlayer, sName, sIP, true)
					exports.global:playSoundCreate()
				else
					triggerServerEvent("togStation", localPlayer, id, guiGetText(gui.bSubmit))
					exports.global:playSoundCreate()
				end
				closeNewStation()
			end
		end
	end)

	gui.bDelete = guiCreateButton(margin+buttonW*3, margin+lineH/2+lineH*3, buttonW , lineH, "Delete",false,gui.wNewStation)
	guiSetFont(gui.bDelete, "default-bold-small")
	addEventHandler("onClientGUIClick", gui.bDelete, function()
		if source == gui.bDelete then
			if id then
				triggerServerEvent("deleteStation", localPlayer, id)
				exports.global:playSoundCreate()
				closeNewStation()
			else
				exports.global:playSoundError()
			end
		end
	end)

	gui.bClose1 = guiCreateButton(margin+buttonW*4, margin+lineH/2+lineH*3, buttonW , lineH, "Close",false,gui.wNewStation)
	guiSetFont(gui.bClose1, "default-bold-small")
	addEventHandler("onClientGUIClick", gui.bClose1, function()
		if source == gui.bClose1 then
			closeNewStation()
		end
	end)

	if id then
		guiSetEnabled(gui.bMoveDown, true)
		guiSetEnabled(gui.bMoveUp, true)
		guiSetText(gui.l1, "EDIT STATION #"..id)
	else
		guiSetEnabled(gui.bMoveDown, false)
		guiSetEnabled(gui.bMoveUp, false)
		guiSetEnabled(gui.bDelete, false)
		if buyNew then
			guiSetText(gui.l1, "PURCHASE NEW STATION")
		else
			guiSetText(gui.l1, "NEW STATION")
		end
	end

	if state == "Activated" then
		guiSetText(gui.bSubmit, "Deactivated")
	elseif state == "Deactivated" then
		guiSetText(gui.bSubmit, "Activated")
	else
		if buyNew then
			guiSetText(gui.bSubmit, "Purchase")
		else
			guiSetText(gui.bSubmit, "Create")
		end
	end

	local changeSubmitBtn = function ()
		if id and (source == gui.eName or source == gui.eIP) then
			guiSetText(gui.bSubmit, "Save")
		end
	end

	addEventHandler("onClientGUIChanged", gui.eName, changeSubmitBtn)
	addEventHandler("onClientGUIChanged", gui.eIP, changeSubmitBtn)
end

function closeNewStation()
	if gui.wNewStation and isElement(gui.wNewStation) then
		destroyElement(gui.wNewStation)
		gui.wNewStation = nil
		togRadioManager(true)
	end
end

function renewStation(station)
	closeRenewStation()
	togRadioManager(false)
	exports.global:playSoundSuccess()
	local w, h = 400, 170
	gui.wRenewStation = guiCreateStaticImage(0, 0, w, h, ":resources/window_body.png", false)
	exports.global:centerWindow(gui.wRenewStation)
	local margin = 20
	local lineH = 16
	local col1 = w - margin*2
	gui.l1 = guiCreateLabel(margin, margin, w-margin*2, lineH, "RENEW STATION", false, gui.wRenewStation)
	guiSetFont(gui.l1, "default-bold-small")
	guiLabelSetHorizontalAlign(gui.l1, "center", true)
	guiLabelSetVerticalAlign(gui.l1, "center", true)

	gui.l2 = guiCreateLabel(margin, margin+lineH, col1, lineH, "You're about to renew radio station ID#"..station[1]..":", false, gui.wRenewStation)
	--guiSetFont(gui.l2, "default-bold-small")
	guiLabelSetVerticalAlign(gui.l2, "center", true)

	gui.l3 = guiCreateLabel(margin, margin+lineH*2, col1, lineH, "Station Name: "..station[2], false, gui.wRenewStation)
	guiSetFont(gui.l3, "default-bold-small")
	guiLabelSetVerticalAlign(gui.l3, "center", true)

	gui.l4 = guiCreateLabel(margin, margin+lineH*3, col1, lineH, "Streaming URL: "..station[3], false, gui.wRenewStation)
	guiSetFont(gui.l4, "default-bold-small")
	guiLabelSetVerticalAlign(gui.l3, "center", true)

	gui.l5 = guiCreateLabel(margin, margin+lineH*4, col1, lineH, "Owner: "..station[4], false, gui.wRenewStation)
	guiSetFont(gui.l5, "default-bold-small")
	guiLabelSetVerticalAlign(gui.l3, "center", true)

	gui.l6 = guiCreateLabel(margin, margin+lineH*5, col1, lineH, "Expiration Date: "..station[5], false, gui.wRenewStation)
	guiSetFont(gui.l6, "default-bold-small")
	guiLabelSetVerticalAlign(gui.l3, "center", true)


	local buttons = 4
	local bH = 30
	local buttonW = (w-margin*2)/buttons

	local perk = exports.donators:getPerks(28)
	local cost7 = math.ceil(perk[2]/4)
	local cost30 = cost7*3
	local cost90 = cost7*3*2

	gui.b7days = guiCreateButton(margin, margin+lineH/2+lineH*6, buttonW , bH, "7 days\n("..cost7.." GCs)",false,gui.wRenewStation)
	--guiSetFont(gui.b7days, "default-bold-small")
	addEventHandler("onClientGUIClick", gui.b7days, function()
		if source == gui.b7days then
			triggerServerEvent("renewStation", localPlayer, station, 7)
			exports.global:playSoundCreate()
			closeRenewStation()
		end
	end)

	gui.b30days = guiCreateButton(margin+buttonW, margin+lineH/2+lineH*6, buttonW , bH, "30 days\n("..cost30.." GCs)",false,gui.wRenewStation)
	--guiSetFont(gui.b30days, "default-bold-small")
	addEventHandler("onClientGUIClick", gui.b30days, function()
		if source == gui.b30days then
			triggerServerEvent("renewStation", localPlayer, station, 30)
			exports.global:playSoundCreate()
			closeRenewStation()
		end
	end)

	gui.b90days = guiCreateButton(margin+buttonW*2, margin+lineH/2+lineH*6, buttonW , bH, "90 days\n("..cost90.." GCs)",false,gui.wRenewStation)
	--guiSetFont(gui.b90days, "default-bold-small")
	addEventHandler("onClientGUIClick", gui.b90days, function()
		if source == gui.b90days then
			triggerServerEvent("renewStation", localPlayer, station, 90)
			exports.global:playSoundCreate()
			closeRenewStation()
		end
	end)

	gui.bClose1 = guiCreateButton(margin+buttonW*3, margin+lineH/2+lineH*6, buttonW , bH, "Close",false,gui.wRenewStation)
	--guiSetFont(gui.bClose1, "default-bold-small")
	addEventHandler("onClientGUIClick", gui.bClose1, function()
		if source == gui.bClose1 then
			closeRenewStation()
		end
	end)

end

function closeRenewStation()
	if gui.wRenewStation and isElement(gui.wRenewStation) then
		destroyElement(gui.wRenewStation)
		gui.wRenewStation = nil
		togRadioManager(true)
	end
end
