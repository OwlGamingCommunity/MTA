local flashingVehicles = { }

function bindKeys(res)
	bindKey("p", "down", toggleFlashers)
	
	for key, value in ipairs(getElementsByType("vehicle")) do
		if isElementStreamedIn(value) then
			local flasherState = getElementData(value, "lspd:flashers")
			if flasherState and flasherState > 0 then
				flashingVehicles[value] = true
			end
		end
	end
end
addEventHandler("onClientResourceStart", getResourceRootElement(), bindKeys)

function toggleFlashers()
	local theVehicle = getPedOccupiedVehicle(getLocalPlayer())
	if (theVehicle) then
		triggerServerEvent("lspd:toggleFlashers", theVehicle)
	end
end
addCommandHandler("togglecarflashers", toggleFlashers, false)

function streamIn()
	if getElementType( source ) == "vehicle" and getElementData( source, "lspd:flashers" ) then
		local flasherState = getElementData(source, "lspd:flashers")
		if flasherState and flasherState > 0 then
			flashingVehicles[source] = true
		else
			local headlightColors = getElementData(source, "headlightcolors") or {255,255,255} 
			setVehicleHeadLightColor(source, headlightColors[1], headlightColors[2], headlightColors[3])
		end
	end
end
addEventHandler("onClientElementStreamIn", getRootElement(), streamIn)

function streamOut()
	if getElementType( source ) == "vehicle" then
		flashingVehicles[source] = nil
	end
end
addEventHandler("onClientElementStreamOut", getRootElement(), streamOut)

function updateSirens( name )
	if name == "lspd:flashers" and isElementStreamedIn( source ) and getElementType( source ) == "vehicle" then
		local flasherState = getElementData(source, "lspd:flashers")
		if flasherState then
			flashingVehicles[source] = true
		--else
		--	flashingVehicles[source] = nil
		end
	end
end
addEventHandler("onClientElementDataChange", getRootElement(), updateSirens)

local quickFlashState = 0
function doFlashes()
	quickFlashState = ( quickFlashState + 1 ) % 12
	for veh in pairs(flashingVehicles) do
		if not (isElement(veh)) then
			flashingVehicles[veh] = nil
		else
			local flasherState = getElementData(veh, "lspd:flashers") or 0
			_G['doFlashersFor' .. flasherState]( veh )
		end		
	end
end
setTimer(doFlashes, 50, 0)

function doFlashersFor0( veh )
	flashingVehicles[veh] = nil
	local headlightColors = getElementData(veh, "headlightcolors") or {255,255,255} 
	setVehicleHeadLightColor(veh, headlightColors[1], headlightColors[2], headlightColors[3])
	setVehicleLightState(veh, 0, 0)
	setVehicleLightState(veh, 1, 0)
	setVehicleLightState(veh, 2, 0)
	setVehicleLightState(veh, 3, 0)
end

function doFlashersFor2( veh, backOnly, thePlayer  )
	-- old flashers for tow trucks
	local state = quickFlashState < 6 and 1 or 0
	if not backOnly then
		setVehicleHeadLightColor(veh, 128, 64, 0)
		setVehicleLightState(veh, 0, 1-state)
		setVehicleLightState(veh, 1, state)
	end
	setVehicleLightState(veh, 2, 1-state)
	setVehicleLightState(veh, 3, state)
end

function doFlashersFor1( veh ) -- regular PD flashers
	doQuickFlashers( veh, 255, 0, 0, 0, 0, 255 )
	doFlashersFor2( veh, true )
end

function doFlashersFor3( veh ) -- regular ES flashers
	doQuickFlashers( veh, 255, 0, 0, 255, 0, 0 )
	doFlashersFor2( veh, true )
end

function doQuickFlashers( veh, r1, g1, b1, r2, g2, b2 )
	-- Red, White, Red, White, Red, White, -Alternate-, Blue, White, Blue, White, Blue, White, -repeat-.
	if quickFlashState < 6 then
		setVehicleLightState(veh, 0, 1)
		setVehicleLightState(veh, 1, 0)
	else
		setVehicleLightState(veh, 0, 0)
		setVehicleLightState(veh, 1, 1)
	end
	
	if quickFlashState == 0 or quickFlashState == 2 or quickFlashState == 4 then
		setVehicleHeadLightColor(veh, r1, g1, b1)
	elseif quickFlashState == 6 or quickFlashState == 8 or quickFlashState == 10 then
		setVehicleHeadLightColor(veh, r2, g2, b2)
	else
		setVehicleHeadLightColor(veh, 255, 255, 255)
	end
end
