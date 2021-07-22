-- calling indicatorStateTransitions[current_state][mode] returns the new state for the indicators.
local indicatorStateTransitions = {
	none = { left = "left", right = "right", both = "both" },
	left = { left = "none", right = "both", both = "both" },
	right = { left = "both", right = "none", both = "both" },
	both = { left = "right", right = "left", both = "none" }
}

-- saved vehicle light state
local indicatingVehicles = {}

function turnIndicatorsOff(vehicle)
	if indicatingVehicles[vehicle] then
		killTimer(indicatingVehicles[vehicle].timer)

		-- restore the previous light states
		local lightState = getElementData(vehicle, 'lights') or 0
		if lightState == 0 then
			-- toggle lights off
			setVehicleOverrideLights(vehicle, 1)
		else
			-- toggle lights on
			setVehicleOverrideLights(vehicle, 2)
		end

		for i = 0, 3 do
			setVehicleLightState(vehicle, i, 0)
		end

		removeEventHandler("onElementDataChange", vehicle, lightsDataChange)

		indicatingVehicles[vehicle] = nil
		return true
	end
	return false
end

local function turnIndicatorsOn(vehicle)
	indicatingVehicles[vehicle] = {
		state = "none",
		timer = setTimer(doIndicatorsForVehicle, 400, 0, vehicle),
		on = false
	}

	-- force lights on
	setVehicleOverrideLights(vehicle, 2)

	addEventHandler("onElementDataChange", vehicle, lightsDataChange)
end

local function toggleIndicators(mode)
	if mode ~= "left" and mode ~= "right" and mode ~= "both" then return end

	local vehicle = getPedOccupiedVehicle(client)
	if vehicle and getVehicleOccupant(vehicle, 0) == client then
		-- just turning them on
		local currentState = indicatingVehicles[vehicle] and indicatingVehicles[vehicle].state or "none"
		local nextState = indicatorStateTransitions[currentState][mode]
		if nextState == nil then return end -- we expect a string for the new mode

		if nextState == "none" then
			turnIndicatorsOff(vehicle)
		else
			if not indicatingVehicles[vehicle] then
				turnIndicatorsOn(vehicle)
			end
			indicatingVehicles[vehicle].state = nextState
		end
	end
end
addEvent("indicator:toggle", true)
addEventHandler("indicator:toggle", resourceRoot, toggleIndicators)

function lightsDataChange(name)
	if name == "lights" and indicatingVehicles[source] then
		turnIndicatorsOff(source)
	end
end

local function setVehicleLightStateEx(vehicle, light, state)
	setVehicleLightState(vehicle, light, state)
	setVehicleLightState(vehicle, 3 - light, state)
end

function doIndicatorsForVehicle(vehicle)
	local data = indicatingVehicles[vehicle]
	if not data then
		-- should never get to this
		--outputDebugString("doing indicator without valid indicating vehicle", 2)
		return
	end

	if not isElement(vehicle) then
		--outputDebugString("killing indicator timer for non-element")
		killTimer(data.timer)
		indicatingVehicles[vehicle] = nil
		return
	end

	if data.state == "none" then
		--outputDebugString("killing indicator timer for state none")
		turnIndicatorsOff(vehicle)
		return
	end

	-- if the vehicle's lights are turned on, we kind of expect the not-indicating side to be on as well.
	local defaultLights = (getElementData(vehicle, 'lights') or 0) > 0 and 0 or 1
	local lights = data.on and 0 or 1
	data.on = not data.on

	if data.state == "left" then
		setVehicleLightStateEx(vehicle, 0, lights)
		setVehicleLightStateEx(vehicle, 1, defaultLights)
	elseif data.state == "right" then
		setVehicleLightStateEx(vehicle, 0, defaultLights)
		setVehicleLightStateEx(vehicle, 1, lights)
	elseif data.state == "both" then
		setVehicleLightStateEx(vehicle, 0, lights)
		setVehicleLightStateEx(vehicle, 1, lights)
	else
		--outputDebugString("Invalid State: " .. tostring(data.state))
	end
end

addEventHandler("onVehicleRespawn", root, function() turnIndicatorsOff(source) end)
