wLicense, licenseList, bAcceptLicense, bCancel, bBuyLicense = nil
local Johnson = createPed(211,  1099, -767.7998046875, 976.52996826172)
setPedRotation(Johnson, 180)
setElementDimension(Johnson, 4)
setElementInterior(Johnson, 5)
setElementData( Johnson, "talk", 1, false )
setElementData( Johnson, "name", "Carla Cooper", false )
setPedAnimation ( Johnson, "FOOD", "FF_Sit_Look", -1, true, false, false )

local dominick = createPed(187,  1108.599609375, -767.2998046875, 976.59997558594)
setPedRotation(dominick, 180)
setElementDimension(dominick, 4)
setElementInterior(dominick, 5)
setElementData( dominick, "talk", 1, false )
setElementData( dominick, "name", "Dominick Hollingsworth", false )
setPedAnimation ( dominick, "FOOD", "FF_Sit_Look", -1, true, false, false )

local localPlayer = getLocalPlayer()
local cost = {
	["car"] =  550,
	["bike"] =  300,
	["boat"] =  950,
	["fishing"] =  250,
}
function showLicenseWindow()
	closewLicense()
	triggerServerEvent("onLicenseServer", getLocalPlayer())

	local vehiclelicense = getElementData(getLocalPlayer(), "license.car")
	local bikelicense = getElementData(getLocalPlayer(), "license.bike")
	local boatlicense = getElementData(getLocalPlayer(), "license.boat")
	local pilotlicense = getElementData(getLocalPlayer(), "license.pilot")
	local fishlicense = getElementData(getLocalPlayer(), "license.fish")

	local width, height = 300, 400
	local scrWidth, scrHeight = guiGetScreenSize()
	local x = scrWidth/2 - (width/2)
	local y = scrHeight/2 - (height/2)

	wLicense= guiCreateWindow(x, y, width, height, "DMV - Apply for a new license", false)

	licenseList = guiCreateGridList(0.05, 0.05, 0.9, 0.8, true, wLicense)
	local column = guiGridListAddColumn(licenseList, "License", 0.6)
	local column2 = guiGridListAddColumn(licenseList, "Cost", 0.3)

	if (vehiclelicense~=1) then
		local row = guiGridListAddRow(licenseList)
		guiGridListSetItemText(licenseList, row, column, "Car License", false, false)
		guiGridListSetItemText(licenseList, row, column2, "$"..cost["car"], true, false)
	end

	if (bikelicense~=1) then
		local row2 = guiGridListAddRow(licenseList)
		guiGridListSetItemText(licenseList, row2, column, "Bike License", false, false)
		guiGridListSetItemText(licenseList, row2, column2, "$"..cost["bike"], true, false)
	end

	if (boatlicense~=1) then
		local row3 = guiGridListAddRow(licenseList)
		guiGridListSetItemText(licenseList, row3, column, "Boat License", false, false)
		guiGridListSetItemText(licenseList, row3, column2, "$"..cost["boat"], true, false)
	end

	if (fishlicense~=1) then
		local row4 = guiGridListAddRow(licenseList)
		guiGridListSetItemText(licenseList, row4, column, "Fishing Permit", false, false)
		guiGridListSetItemText(licenseList, row4, column2, "$"..cost["fishing"], true, false)
	end

	bAcceptLicense = guiCreateButton(0.05, 0.85, 0.3, 0.1, "Take test", true, wLicense)
	bBuyLicense = guiCreateButton(0.05+0.3, 0.85, 0.3, 0.1, "Buy & Skip Test\n("..exports.donators:getPerks(22)[2].." GCs)", true, wLicense)
	bCancel = guiCreateButton(0.05+0.3+0.3, 0.85, 0.3, 0.1, "Cancel", true, wLicense)

	showCursor(true)

	addEventHandler("onClientGUIClick", bAcceptLicense, acceptLicense)
	addEventHandler("onClientGUIClick", bBuyLicense, acceptLicense)
	addEventHandler("onClientGUIClick", bCancel, cancelLicense)
end
addEvent("onLicense", true)
addEventHandler("onLicense", getRootElement(), showLicenseWindow)

local gui = {}
function showRecoverLicenseWindow()
	closeRecoverLicenseWindow()
	showCursor(true)
	local vehiclelicense = getElementData(getLocalPlayer(), "license.car")
	local bikelicense = getElementData(getLocalPlayer(), "license.bike")
	local boatlicense = getElementData(getLocalPlayer(), "license.boat")
	local pilotlicense = getElementData(getLocalPlayer(), "license.pilot")
	local fishlicense = getElementData(getLocalPlayer(), "license.fish")

	local width, height = 300, 400
	local scrWidth, scrHeight = guiGetScreenSize()
	local x = scrWidth/2 - (width/2)
	local y = scrHeight/2 - (height/2)

	gui.wLicense= guiCreateWindow(x, y, width, height, "DMV - Recover lost license", false)

	gui.licenseList = guiCreateGridList(0.05, 0.05, 0.9, 0.8, true, gui.wLicense)
	gui.column = guiGridListAddColumn(gui.licenseList, "License", 0.6)
	gui.column2 = guiGridListAddColumn(gui.licenseList, "Cost", 0.3)

	gui.row = guiGridListAddRow(gui.licenseList)
	guiGridListSetItemText(gui.licenseList, gui.row, gui.column, "Car License", false, false)
	guiGridListSetItemText(gui.licenseList, gui.row, gui.column2, "$"..cost["car"]/10, true, false)

	gui.row2 = guiGridListAddRow(gui.licenseList)
	guiGridListSetItemText(gui.licenseList, gui.row2, gui.column, "Bike License", false, false)
	guiGridListSetItemText(gui.licenseList, gui.row2, gui.column2, "$"..cost["bike"]/10, true, false)

	gui.row3 = guiGridListAddRow(gui.licenseList)
	guiGridListSetItemText(gui.licenseList, gui.row3, gui.column, "Boat License", false, false)
	guiGridListSetItemText(gui.licenseList, gui.row3, gui.column2, "$"..cost["boat"]/10, true, false)

	gui.row4 = guiGridListAddRow(gui.licenseList)
	guiGridListSetItemText(gui.licenseList, gui.row4, gui.column, "Fishing Permit", false, false)
	guiGridListSetItemText(gui.licenseList, gui.row4, gui.column2, "$"..cost["fishing"]/10, true, false)

	gui.bRecover = guiCreateButton(0.05, 0.85, 0.45, 0.1, "Recover", true, gui.wLicense)
	gui.bCancel = guiCreateButton(0.5, 0.85, 0.45, 0.1, "Cancel", true, gui.wLicense)

	addEventHandler("onClientGUIClick", gui.bRecover, function()
		local row, col = guiGridListGetSelectedItem(gui.licenseList)
		if (row==-1) or (col==-1) then
			exports.hud:sendBottomNotification(localPlayer, "Department of Motor Vehicles", "Please select a license first!" )
			return false
		end

		local licensetext = guiGridListGetItemText(gui.licenseList, guiGridListGetSelectedItem(gui.licenseList), 1)
		local licensecost = 0

		if (licensetext=="Car License") then
			if vehiclelicense~= 1 then
				exports.hud:sendBottomNotification(localPlayer, getElementData(dominick, "name"), "Sorry, we are unable to locate a license for you in our records. Please meet agent Carla Cooper in the other room." )
				return false
			end
			triggerServerEvent("license:recover", localPlayer, licensetext, cost["car"]/10, 133, getElementData(dominick, "name"))
		end
		if (licensetext=="Bike License") then
			if bikelicense~= 1 then
				exports.hud:sendBottomNotification(localPlayer, getElementData(dominick, "name"), "Sorry, we are unable to locate a license for you in our records. Please meet agent Carla Cooper in the other room." )
				return false
			end
			triggerServerEvent("license:recover", localPlayer, licensetext, cost["bike"]/10, 153, getElementData(dominick, "name"))
		end
		if (licensetext=="Boat License") then
			if boatlicense~= 1 then
				exports.hud:sendBottomNotification(localPlayer, getElementData(dominick, "name"), "Sorry, we are unable to locate a license for you in our records. Please meet agent Carla Cooper in the other room." )
				return false
			end
			triggerServerEvent("license:recover", localPlayer, licensetext, cost["boat"]/10, 155, getElementData(dominick, "name"))
		end
		if (licensetext=="Fishing Permit") then
			if fishlicense~= 1 then
				exports.hud:sendBottomNotification(localPlayer, getElementData(dominick, "name"), "Sorry, we are unable to locate a license for you in our records. Please meet agent Carla Cooper in the other room." )
				return false
			end
			triggerServerEvent("license:recover", localPlayer, licensetext, cost["fishing"]/10, 154, getElementData(dominick, "name"))
		end
	end, false)

	addEventHandler("onClientGUIClick", gui.bCancel, function()
		closeRecoverLicenseWindow()
	end, false)
end
addEvent("showRecoverLicenseWindow", true)
addEventHandler("showRecoverLicenseWindow", root, showRecoverLicenseWindow)

function closeRecoverLicenseWindow()
	if gui.wLicense and isElement(gui.wLicense) then
		destroyElement(gui.wLicense)
		gui.wLicense = nil
		showCursor(false)
	end
end

function acceptLicense(button, state)
	if (button=="left") then
		if (source==bAcceptLicense) or (source==bBuyLicense)then
			local row, col = guiGridListGetSelectedItem(licenseList)
			if (row==-1) or (col==-1) then
				exports.hud:sendBottomNotification(localPlayer, "Department of Motor Vehicles", "Please select a license first!" )
				return false
			end

			local license = 0
			local licensetext = guiGridListGetItemText(licenseList, guiGridListGetSelectedItem(licenseList), 1)
			local licensecost = 0

			if (licensetext=="Car License") then
				license = 1
				licensecost = cost["car"]
				minimumAge = 16
			end
			if (licensetext=="Bike License") then
				license = 2
				licensecost = cost["bike"]
				minimumAge = 16
			end
			if (licensetext=="Boat License") then
				license = 3
				licensecost = cost["boat"]
			end
			if (licensetext=="Fishing Permit") then
				license = 5
				licensecost = cost["fishing"]
			end

			if license <= 0 then
				return false
			end

			if minimumAge then
				local characterAge = tonumber(getElementData(getLocalPlayer(), "age")) or 0
				if characterAge < minimumAge then
					exports.hud:sendBottomNotification(localPlayer, "Department of Motor Vehicles", "You must be at least "..tostring(minimumAge).." years to get a "..tostring(licensetext).."." )
					return false
				end
			end

			if (source==bAcceptLicense) then
				if not exports.global:hasMoney( getLocalPlayer(), licensecost ) then
					exports.hud:sendBottomNotification(localPlayer, "Department of Motor Vehicles", "You do not have the $"..licensecost.." required for this license." )
					return false
				end
			end

			if source==bAcceptLicense then
				if (license == 1) then
					if  getElementData(getLocalPlayer(), "license.car") < 0 then
						exports.hud:sendBottomNotification(localPlayer, "Department of Motor Vehicles", "You need to wait another " .. -getElementData(getLocalPlayer(), "license.car") .. " hours before being able to obtain a " .. licensetext .. "." )
					elseif (getElementData(getLocalPlayer(),"license.car")==0) then
						triggerServerEvent("payFee", getLocalPlayer(), licensecost, "an automotive driver's license")
						createlicenseTestIntroWindow() -- take the drivers theory test.
						destroyElement(licenseList)
						destroyElement(bAcceptLicense)
						destroyElement(bCancel)
						destroyElement(wLicense)
						wLicense, licenseList, bAcceptLicense, bCancel = nil, nil, nil, nil
						showCursor(false)
					elseif(getElementData(getLocalPlayer(),"license.car")==3) then
						initiateDrivingTest()
					end
				elseif (license == 2) then
					if getElementData(getLocalPlayer(), "license.bike") < 0 then
						exports.hud:sendBottomNotification(localPlayer, "Department of Motor Vehicles", "You need to wait another " .. -getElementData(getLocalPlayer(), "license.bike") .. " hours before being able to obtain a " .. licensetext .. "." )
					elseif (getElementData(getLocalPlayer(),"license.bike")==0) then
						triggerServerEvent("payFee", getLocalPlayer(), licensecost, "a motorbike driver's license")
						createlicenseBikeTestIntroWindow() -- take the drivers theory test.
						destroyElement(licenseList)
						destroyElement(bAcceptLicense)
						destroyElement(bCancel)
						destroyElement(wLicense)
						wLicense, licenseList, bAcceptLicense, bCancel = nil, nil, nil, nil
						showCursor(false)
					elseif(getElementData(getLocalPlayer(),"license.bike")==3) then
						initiateBikeTest()
					end
				elseif (license == 3) then
					if getElementData(getLocalPlayer(), "license.boat") < 0 then
						exports.hud:sendBottomNotification(localPlayer, "Department of Motor Vehicles", "You need to wait another " .. -getElementData(getLocalPlayer(), "license.boat") .. " hours before being able to obtain a " .. licensetext .. "." )
					elseif (getElementData(getLocalPlayer(),"license.boat")==0) then
						triggerServerEvent("payFee", getLocalPlayer(), licensecost, "an boat driver's license")
						createlicenseBoatTestIntroWindow() -- boat theory test
						destroyElement(licenseList)
						destroyElement(bAcceptLicense)
						destroyElement(bCancel)
						destroyElement(wLicense)
						wLicense, licenseList, bAcceptLicense, bCancel = nil, nil, nil, nil
						showCursor(false)
					end
				elseif (license == 5) then
					if getElementData(getLocalPlayer(), "license.fish") < 0 then
						exports.hud:sendBottomNotification(localPlayer, "Department of Motor Vehicles", "You need to wait another " .. -getElementData(getLocalPlayer(), "license.fish") .. " hours before being able to obtain a " .. licensetext .. "." )
					elseif (getElementData(getLocalPlayer(),"license.fish")==0) then
						triggerServerEvent("payFee", getLocalPlayer(), licensecost, "a fishing permit")
						triggerServerEvent("acceptFishLicense", getLocalPlayer())
						destroyElement(licenseList)
						destroyElement(bAcceptLicense)
						destroyElement(bCancel)
						destroyElement(wLicense)
						wLicense, licenseList, bAcceptLicense, bCancel = nil, nil, nil, nil
						showCursor(false)
					end
				end
			elseif source==bBuyLicense then
				if license == 1 then
					if  getElementData(getLocalPlayer(), "license.car") < 0 then
						exports.hud:sendBottomNotification(localPlayer, "Department of Motor Vehicles", "You need to wait another " .. -getElementData(getLocalPlayer(), "license.car") .. " hours before being able to obtain a " .. licensetext .. "." )
						return
					end
					triggerServerEvent("acceptCarLicense", localPlayer, true)
					closewLicense()
				elseif license == 2 then
					if  getElementData(getLocalPlayer(), "license.bike") < 0 then
						exports.hud:sendBottomNotification(localPlayer, "Department of Motor Vehicles", "You need to wait another " .. -getElementData(getLocalPlayer(), "license.bike") .. " hours before being able to obtain a " .. licensetext .. "." )
						return
					end
					triggerServerEvent("acceptBikeLicense", localPlayer, true)
					closewLicense()
				elseif license == 3 then
					if  getElementData(getLocalPlayer(), "license.boat") < 0 then
						exports.hud:sendBottomNotification(localPlayer, "Department of Motor Vehicles", "You need to wait another " .. -getElementData(getLocalPlayer(), "license.boat") .. " hours before being able to obtain a " .. licensetext .. "." )
						return
					end
					triggerServerEvent("acceptBoatLicense", localPlayer, true)
					closewLicense()
				elseif license == 5 then
					if  getElementData(getLocalPlayer(), "license.fish") < 0 then
						exports.hud:sendBottomNotification(localPlayer, "Department of Motor Vehicles", "You need to wait another " .. -getElementData(getLocalPlayer(), "license.fish") .. " hours before being able to obtain a " .. licensetext .. "." )
						return
					end
					triggerServerEvent("acceptFishLicense", localPlayer, true)
					closewLicense()
				end
			end
		end
	end
end

function cancelLicense(button, state)
	if (source==bCancel) and (button=="left") then
		destroyElement(licenseList)
		destroyElement(bAcceptLicense)
		destroyElement(bCancel)
		destroyElement(wLicense)
		wLicense, licenseList, bAcceptLicense, bCancel = nil, nil, nil, nil
		showCursor(false)
	end
end

function closewLicense()
	if wLicense and isElement(wLicense) then
		destroyElement(wLicense)
		wLicense = nil
		showCursor(false)
	end
end

bindKey( "accelerate", "down",
	function( )
		local veh = getPedOccupiedVehicle( getLocalPlayer( ) )
		if veh and getVehicleOccupant( veh ) == getLocalPlayer( ) then
			if isElementFrozen( veh ) and getVehicleEngineState( veh ) then
				if getVehicleType(veh) == 'veh' or getVehicleType(veh) == 'Bike' then
					exports.hud:sendBottomNotification(localPlayer, "Department of Motor Vehicles", "Kickstand is applied. Use /kickstand to release it." )
				elseif getVehicleType(veh) == 'Boat' then
					exports.hud:sendBottomNotification(localPlayer, "Department of Motor Vehicles", "Your anchor is applied. Use /anchor to raise it." )
				else
					exports.hud:sendBottomNotification(localPlayer, "Department of Motor Vehicles", "Your handbrake is applied. Use /handbrake to release it." )
				end
			elseif not getVehicleEngineState( veh ) and getVehicleType(veh) ~= 'Bike' and getVehicleType(veh) ~= 'BMX' then
				exports.hud:sendBottomNotification(localPlayer, "Department of Motor Vehicles", "Your engine is off. Press 'J' to turn it on." )
			end
		end
	end
)
