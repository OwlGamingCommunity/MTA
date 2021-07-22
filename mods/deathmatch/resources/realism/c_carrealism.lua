local sx, sy = guiGetScreenSize()
local localPlayer = getLocalPlayer()
distanceTraveled = 0
local syncTraveled = 0
local oX, oY, oZ
local carSync = false
local lastVehicle = nil

function setUp(startedResource)
	if(startedResource == getThisResource()) then
		oX,oY,oZ = getElementPosition(localPlayer)
	end
end
addEventHandler("onClientResourceStart",getRootElement(),setUp)

function monitoring()
	local x,y,z = getElementPosition(localPlayer)
	if(isPedInVehicle(localPlayer)) then
		local x,y,z = getElementPosition(localPlayer)
		local thisTime  = getDistanceBetweenPoints3D(x,y,z,oX,oY,oZ) -- / 2.1
		if thisTime < 5 then
			distanceTraveled = distanceTraveled + thisTime
			syncTraveled = syncTraveled + thisTime
		end
	end
	oX = x
	oY = y
	oZ = z
end
addEventHandler("onClientRender",getRootElement(),monitoring)

function getDistanceTraveled()
	return distanceTraveled
end

function receiveDistanceSync( amount )
	if (isPedInVehicle(localPlayer)) then
		if (source == getPedOccupiedVehicle(localPlayer)) then
			distanceTraveled = amount or 0
			carSync = true
		end
	end
end
addEvent("realism:distance", true)
addEventHandler("realism:distance", getRootElement(), receiveDistanceSync)

function onResourceStart()
	if (isPedInVehicle(localPlayer)) then
		local theVehicle = getPedOccupiedVehicle(localPlayer)
		if (theVehicle) then
			carSync = false
			triggerServerEvent("realism:distance", theVehicle)
		end
	end
	setTimer(stopCarSync, 1000, 0)
	setTimer(syncBack, 60000, 0)
end
addEventHandler("onClientResourceStart", getResourceRootElement(), onResourceStart)

function syncBack(force)
	if (isPedInVehicle(localPlayer) or force) then
		local theVehicle = getPedOccupiedVehicle(localPlayer)
		if (theVehicle or force) then
			if carSync then
				local shit = force and lastVehicle or theVehicle
				if isElement(shit) then
					triggerServerEvent("realism:distance", shit, distanceTraveled, syncTraveled)
					syncTraveled = 0
				end
			end
		end
	end
end

function stopCarSync()
	if not (isPedInVehicle(localPlayer)) then
		if carSync then
			syncBack(true)
		end
		carSync = false
		distanceTraveled = 0
		syncTraveled = 0
	else
		lastVehicle = getPedOccupiedVehicle(localPlayer)
	end
end

function bikeSpeed(theVehicle)
    if getPedOccupiedVehicle(getLocalPlayer()) then
        if getVehicleType(theVehicle) == "Bike" then
            if getPedControlState(localPlayer, "accelerate") then
				toggleControl("steer_forward", false)
			else
                toggleControl("steer_forward", true)
			end
			setTimer(bikeSpeed, 50, 1, theVehicle)
		else
			toggleControl("steer_forward", true)
		end
	else
		toggleControl("steer_forward", true)
    end
end
addEventHandler("onClientPlayerVehicleEnter", getLocalPlayer(), bikeSpeed)