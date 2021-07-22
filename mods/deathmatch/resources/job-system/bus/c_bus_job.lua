local line, route, m_number, curCpType = nil

local busMarker, busNextMarker = nil
local busBlip, busNextBlip = nil
local busStopColShape = nil

local bus = { [431]=true, [437]=true }

local blip

function resetBusJob()
	if (isElement(blip)) then
		destroyElement(blip)
		removeEventHandler("onClientVehicleEnter", getRootElement(), startBusJob)
		blip = nil
	end
	
	if isElement(busMarker) then
		destroyElement(busMarker)
		busMarker = nil
	end
	
	if isElement(busBlip) then
		destroyElement(busBlip)
		busBlip = nil
	end
	
	if isElement(busNextMarker) then
		destroyElement(busNextMarker)
		busNextMarker = nil
	end
	
	if isElement(busNextBlip) then
		destroyElement(busNextBlip)
		busNextBlip = nil
	end
	
	m_number = 0
	triggerServerEvent("payBusDriver", getLocalPlayer(), line, -1)
end

function displayBusJob()
	blip = createBlip(1787.1259765625, -1903.591796875, 13.394536972046, 0, 4, 255, 255, 0)  --0 0 1787.1259765625 -1903.591796875 13.394536972046
	exports.hud:sendBottomNotification(localPlayer, "Bus Driver", "Approach the yellow blip on your radar and enter a Bus to start working.")
end

function startBusJob()
	local job = getElementData(getLocalPlayer(), "job")
	if (job == 3) then
		if blip then
			destroyElement(blip)
			blip = nil
		end
		if busMarker then
			exports.hud:sendBottomNotification(localPlayer, "Bus Driver", "You have already started a bus route.")
		else
			local vehicle = getPedOccupiedVehicle(getLocalPlayer())
			if vehicle and getVehicleController(vehicle) == getLocalPlayer() and bus[getElementModel(vehicle)] then
				line = math.random( 1, #g_bus_routes )
				route = g_bus_routes[line]
				curCpType = 0
				
				local x, y, z = 1811, -1890, 13 -- Depot start point
				busBlip = createBlip(x, y, z, 0, 3, 255, 200, 0, 255)
				busMarker = createMarker(x, y, z, "checkpoint", 4, 255, 200, 0, 150) -- start marker.
				busStopColShape = createColSphere(0, 0, 0, 5)
				
				addEventHandler("onClientMarkerHit", busMarker, updateBusCheckpointCheck)
				addEventHandler("onClientMarkerLeave", busMarker, checkWaitAtStop)
				addEventHandler("onClientColShapeHit", busStopColShape,
					function(element)
						if getElementType(element) == "vehicle" and bus[getElementModel(element)] then
							setVehicleLocked(vehicle, false)
						end
					end
				)
				addEventHandler("onClientColShapeLeave", busStopColShape,
					function(element)
						if getElementType(element) == "vehicle" and bus[getElementModel(element)] then
							setVehicleLocked(vehicle, true)
						end
					end
				)
				
				local nx, ny, nz = route.points[1][1], route.points[1][2], route.points[1][3]
				if (route.points[1][4]==true) then
					busNextMarker = createMarker( nx, ny, nz, "checkpoint", 2.5, 255, 0, 0, 150) -- small red marker
					busNextBlip = createBlip( nx, ny, nz, 0, 2, 255, 0, 0, 255) -- small red blip
				else
					busNextMarker = createMarker( nx, ny, nz, "checkpoint", 2.5, 255, 200, 0, 150) -- small yellow marker
					busNextBlip = createBlip( nx, ny, nz, 0, 2, 255, 200, 0, 255) --small  yellow blip
				end
				
				m_number = 0
				triggerServerEvent("payBusDriver", getLocalPlayer(), line, 0)
				
				setVehicleLocked(vehicle, true)
				
				exports.hud:sendBottomNotification(localPlayer, "Bus Driver", "Follow the bus route, stopping at the bus stops (red marker).")
			else
				exports.hud:sendBottomNotification(localPlayer, "Bus Driver", "You must be in a Bus or Coach to begin a bus route.")
			end
		end
	else
		exports.hud:sendBottomNotification(localPlayer, "Notification", "You are not a Bus Driver. Go to City Hall to obtain this job.")
	end
end
addCommandHandler("startbus", startBusJob, false, false)

function updateBusCheckpointCheck(thePlayer)
	if thePlayer == getLocalPlayer() then
		local vehicle = getPedOccupiedVehicle(thePlayer)
		if vehicle and bus[getElementModel(vehicle)] then
			if curCpType == 3 then
				busStopTimer = setTimer(updateBusCheckpointAfterStop, 5000, 1, true)
				triggerEvent("hudOverlay:drawOverlayTopRight", thePlayer, { {"Bus Driver"}, {""}, {"Wait at the bus stop for a moment until the marker disappears."}, }, false, false, false, 5)
				triggerServerEvent("busAdNextStop", getLocalPlayer(), line, route.points[m_number][5])
			elseif curCpType == 2 then
				endOfTheLine()
			elseif curCpType == 1 then
				busStopTimer = setTimer(updateBusCheckpointAfterStop, 5000, 1, false)
				triggerEvent("hudOverlay:drawOverlayTopRight", thePlayer, { {"Bus Driver"}, {""}, {"Wait at the bus stop for a moment until the marker disappears."}, }, false, false, false, 5)
				triggerServerEvent("busAdNextStop", getLocalPlayer(), line, route.points[m_number][5])
			else
				updateBusCheckpoint()
			end
		else
			exports.hud:sendBottomNotification(localPlayer, "Bus Driver", "You must be in a bus or coach to drive the bus route.") -- Wrong car type.
		end
	end
end

function updateBusCheckpoint()
	-- Find out which marker is next.
	local max_number = #route.points
	local newnumber = m_number+1
	local nextnumber = m_number+2
	local x, y, z = nil
	local nx, ny, nz = nil
	
	x = route.points[newnumber][1]
	y = route.points[newnumber][2]
	z = route.points[newnumber][3]
	
	if (tonumber(max_number-1) == tonumber(m_number)) then -- if the next checkpoint is the final checkpoint.
		setElementPosition(busMarker, x, y, z)
		setElementPosition(busBlip, x, y, z)
		
		if (route.points[newnumber][4]==true) then -- If it is a stop.
			curCpType = 3
			setMarkerColor(busMarker, 255, 0, 0, 150)
			setBlipColor(busBlip, 255, 0, 0, 255)
			setElementPosition(busStopColShape, x, y, z)
		else -- it is just a route.
			curCpType = 2
			setMarkerColor(busMarker, 255, 200, 0, 150)
			setBlipColor(busBlip, 255, 200, 0, 255)
		end
		
		nx, ny, nz = 1811, -1890, 13 -- Depot start point
		setElementPosition(busNextMarker, nx, ny, nz)
		setElementPosition(busNextBlip, nx, ny, nz)
		setMarkerColor(busNextMarker, 255, 0, 0, 150)
		setBlipColor(busNextBlip, 255, 0, 0, 255)
		setMarkerIcon(busNextMarker, "finish")
	else
		nx = route.points[nextnumber][1]
		ny = route.points[nextnumber][2]
		nz = route.points[nextnumber][3]
		
		setElementPosition(busMarker, x, y, z)
		setElementPosition(busBlip, x, y, z)
		
		setElementPosition(busNextMarker, nx, ny, nz)
		setElementPosition(busNextBlip, nx, ny, nz)
		
		if (route.points[newnumber][4]==true) then -- If it is a stop.
			curCpType = 1
			setMarkerColor(busMarker, 255, 0, 0, 150)
			setBlipColor(busBlip, 255, 0, 0, 255)
			setElementPosition(busStopColShape, x, y, z)
		else -- it is just a route.
			curCpType = 0
			setMarkerColor(busMarker, 255, 200, 0, 150)
			setBlipColor(busBlip, 255, 200, 0, 255)
		end
		
		if (route.points[nextnumber][4] == true) then
			setMarkerColor(busNextMarker, 255, 0, 0, 150)
			setBlipColor(busNextBlip, 255, 0, 0, 255)
		else
			setMarkerColor(busNextMarker, 255, 200, 0, 150)
			setBlipColor(busNextBlip, 255, 200, 0, 255)
		end
	end
	m_number = m_number + 1
end

function checkWaitAtStop(thePlayer)
	if thePlayer == getLocalPlayer() then
		if busStopTimer then
			exports.hud:sendBottomNotification(localPlayer, "Bus Driver", "You didn't wait at the bus stop.")
			if isTimer(busStopTimer) then
				killTimer(busStopTimer)
				busStopTimer = nil
			end
		end
	end
end

function updateBusCheckpointAfterStop(endOfLine)
	if isTimer(busStopTimer) then
		killTimer(busStopTimer)
		busStopTimer = nil
	end
	local stopNumber = route.points[m_number][5]
	triggerServerEvent("payBusDriver", getLocalPlayer(), line, stopNumber)
	if endOfLine then
		endOfTheLine(getLocalPlayer())
	else
		updateBusCheckpoint(getLocalPlayer())
	end
end

function endOfTheLine()
	if busNextBlip then
		destroyElement(busNextBlip)
		destroyElement(busNextMarker)
		busNextBlip = nil
		busNextMarker = nil
		
		if busStopColShape then
			destroyElement(busStopColShape)
			busStopColShape = nil
		end
		
		local x, y, z = 1811, -1890, 13 -- Depot start point
		setElementPosition(busMarker, x, y, z)
		setElementPosition(busBlip, x, y, z)
		setMarkerColor(busMarker, 255, 0, 0, 150)
		setBlipColor(busBlip, 255, 0, 0, 255)
		setMarkerIcon(busMarker, "finish")
		curCpType = 2
	else
		if busBlip then
			-- Remove the old marker.
			destroyElement(busBlip)
			destroyElement(busMarker)
			busBlip = nil
			busMarker = nil
		end
		triggerServerEvent("payBusDriver", getLocalPlayer(), line, -2)
		setVehicleLocked(vehicle, false)
		exports.hud:sendBottomNotification(localPlayer, "Bus Driver", "End of the Line. Use /startbus to begin the route again.") --if line is finished
	end
end

function enterBus ( thePlayer, seat, jacked )
	if(thePlayer == getLocalPlayer())then
		local vehID = getElementModel (source)
		if(bus[vehID])then
			if(seat~=0)then
				local driver = getVehicleOccupant(source)
				if driver then -- you can only pay the driver if the bus has a driver
					if not exports.global:hasMoney(getLocalPlayer(), 5)then
						triggerServerEvent("removePlayerFromBus", getLocalPlayer())
						outputChatBox("You can't afford the $5 bus fare.", 255, 0, 0)
					else
						triggerServerEvent("payBusFare", getLocalPlayer(), driver)
						outputChatBox("You have paid $5 to ride the bus", 0, 255, 0)
					end
				end
			elseif not busMarker and getElementData(getLocalPlayer(), "job") == 3 then
				exports.hud:sendBottomNotification(localPlayer, "Bus Driver", "Use /startbus to begin the bus route.")
			end
		end
	end
end
addEventHandler("onClientVehicleEnter", getRootElement(), enterBus)

function startEnterBus(thePlayer, seat)
	if seat == 0 and bus[getElementModel(source)] then
		if getVehicleController(source) then -- if someone try to jack the driver stop him
			cancelEvent()
			if thePlayer == getLocalPlayer() then
				exports.hud:sendBottomNotification(localPlayer, "Notification", "The drivers door is locked.")
			end
		else
			setVehicleLocked(source, false)
		end
	end
end
addEventHandler("onClientVehicleStartEnter", getRootElement(), startEnterBus)

function onPlayerQuit()
	if getElementData(source, "job") == 3 then
		vehicle = getPedOccupiedVehicle(source)
		if vehicle and bus[getElementModel(vehicle)] and getVehicleOccupant(vehicle) == source then
			setVehicleLocked(vehicle, false)
		end
	end
end
addEventHandler("onClientPlayerQuit", getRootElement(), onPlayerQuit)