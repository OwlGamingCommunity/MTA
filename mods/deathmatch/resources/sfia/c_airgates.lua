function showGateControlGUI(element)
	hideGateControlGUI()
	local gateID = getElementData(element, "airport.gate.id")
	if gateID then
		if canPlayerControlGates() then
			gateID = tonumber(gateID)

			local px,py,pz = getElementPosition(getLocalPlayer())
			local x,y,z = getElementPosition(element)
			if(getDistanceBetweenPoints3D(px,py,pz,x,y,z) > 2) then
				outputDebugString("Too far away.")
				return
			end
			triggerServerEvent("airport-gates:getGUIdata", getLocalPlayer(), element, gateID)
		end
	end
end
addEvent("airport-gates:controlGUI", true)
addEventHandler("airport-gates:controlGUI", getRootElement(), showGateControlGUI)

function fillGateControlGUI(element, gateID, open, plane, connected)
	if element then
		local width, height = 300, 390
		local scrWidth, scrHeight = guiGetScreenSize()
		local x = scrWidth/2 - (width/2)
		local y = scrHeight/2 - (height/2)

		window = guiCreateWindow(x, y, width, height, tostring(gates[gateID][2]), false)
		guiWindowSetSizable(window, false)

		local openText
		if open then
			openText = "Open"
		else
			openText = "Closed"
		end
		lblStatus = guiCreateLabel(0.05, 0.05, 0.9, 0.05, "Status: "..tostring(openText), true, window)

		local planeText
		if plane then
			planeText = tostring(getVehicleName(plane)).." ("..tostring(getVehiclePlateText(plane))..")"
		else
			planeText = ""
		end
		lblPlane = guiCreateLabel(0.05, 0.1, 0.9, 0.05, "Plane: "..tostring(planeText), true, window)

		if connected then
			local bridgeText = "Bridge connected to "..tostring(getVehiclePlateText(connected))
			lblBridge = guiCreateLabel(0.05, 0.15, 0.9, 0.05, tostring(bridgeText), true, window)
		end

		if open then
			bOpen = guiCreateButton(0.05, 0.2, 0.9, 0.1, "Close Gate", true, window)
			addEventHandler("onClientGUIClick", bOpen, function(button, state)
				if source ~= bOpen then return end
				triggerServerEvent("airport-gates:setGateOpen", getLocalPlayer(), gateID, false)
				--setGateOpen(gateID, false)
				showGateControlGUI(element)
			end)
		else
			bOpen = guiCreateButton(0.05, 0.2, 0.9, 0.1, "Open Gate", true, window)
			addEventHandler("onClientGUIClick", bOpen, function(button, state)
				if source ~= bOpen then return end
				triggerServerEvent("airport-gates:setGateOpen", getLocalPlayer(), gateID, true)
				--setGateOpen(gateID, true)
				showGateControlGUI(element)
			end)
		end

		if connected then
			bBridge = guiCreateButton(0.05, 0.35, 0.9, 0.1, "Disconnect bridge", true, window)
			addEventHandler("onClientGUIClick", bBridge, function(button, state)
				if source ~= bBridge then return end
				triggerServerEvent("airport-gates:disconnectBridge", getLocalPlayer(), gateID)
				--disconnectBridge(gateID)
				showGateControlGUI(element)
			end)
		else
			bBridge = guiCreateButton(0.05, 0.35, 0.9, 0.1, "Connect bridge", true, window)
			if not plane then
				guiSetEnabled(bBridge, false)
			else
				local model = getElementModel(plane)
				if(model == 519 or model == 577) then
					addEventHandler("onClientGUIClick", bBridge, function(button, state)
						if source ~= bBridge then return end
						triggerServerEvent("airport-gates:connectBridge", getLocalPlayer(), gateID)
						--connectBridge(gateID)
						showGateControlGUI(element)
					end)
				else
					guiSetEnabled(bBridge, false)
				end
			end
		end
		bCancel = guiCreateButton(0.05, 0.5, 0.9, 0.1, "Cancel", true, window)
		addEventHandler("onClientGUIClick", bCancel, function(button, state)
			if source ~= bCancel then return end
			hideGateControlGUI()
		end)
	end
end
addEvent("airport-gates:fillControlGUI", true)
addEventHandler("airport-gates:fillControlGUI", getRootElement(), fillGateControlGUI)

function hideGateControlGUI()
	if lblStatus then destroyElement(lblStatus) end
	if lblPlane then destroyElement(lblPlane) end
	if lblBridge then destroyElement(lblBridge) end
	if bOpen then destroyElement(bOpen) end
	if bBridge then destroyElement(bBridge) end
	if bCancel then destroyElement(bCancel) end
	if window then destroyElement(window) end
	window, lblStatus, lblPlane, lblBridge, bOpen, bBridge, bCancel = nil, nil, nil, nil, nil, nil, nil
	if isCursorShowing() then showCursor(false) end
end

function canPlayerControlGates()
	--[[
	if(exports.factions:isPlayerInFaction(getLocalPlayer(), 47) or exports.integration:isPlayerTrialAdmin(thePlayer) and getElementData(thePlayer, "duty_admin") == 1) then
		return true
	end
	--]]
	--local factionTable = getElementData(getLocalPlayer(), "factiontable")
	--for k,v in ipairs(factionTable) do
	--	local faction = v[1]
	--	if(allowedFactions[faction]) then
	--		return true
	--	end
	--end
	--return false
	return true
end

function playCabinSound(sound)
	--outputDebugString("playCustomChatSound("..tostring(sound)..")")
	playSound("sound/"..tostring(sound)..".wav", false)
end
addEvent( "airport-gates:playCabinSound", true )
addEventHandler( "airport-gates:playCabinSound", getRootElement(), playCabinSound )