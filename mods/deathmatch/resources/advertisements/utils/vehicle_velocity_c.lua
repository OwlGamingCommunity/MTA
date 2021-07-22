local SPEED_REDUCTION_TIME_SLEEP = 100
local MINIMUM_STOPPING_SPEED = 0.1

addEvent("onClientVehicleStopped", false)

local function isVehicleStopped(vehicle)
    local x, y, z = vehicle.velocity:getX(), vehicle.velocity:getY(), vehicle.velocity:getZ()

    return math.abs(x) < MINIMUM_STOPPING_SPEED and math.abs(y) < MINIMUM_STOPPING_SPEED and math.abs(z) < MINIMUM_STOPPING_SPEED
end

function bringVehicleToStop(vehicle)
    if not isVehicleStopped(vehicle) then
        setAnalogControlState('handbrake', 1)
        setAnalogControlState('brake_reverse', 1)
        setTimer(bringVehicleToStop, SPEED_REDUCTION_TIME_SLEEP, 1, vehicle)
    else
        setAnalogControlState('handbrake', 0)
        setAnalogControlState('brake_reverse', 0)
        triggerEvent("onClientVehicleStopped", vehicle)
    end
end
