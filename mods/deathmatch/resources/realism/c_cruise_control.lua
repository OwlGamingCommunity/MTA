local limitSpeed = { }
--[[
table.insert(limitSpeed, 510, 60) -- Mountain bike
table.insert(limitSpeed, 509, 55) -- Bike
table.insert(limitSpeed, 481, 55) -- BMX
table.insert(limitSpeed, 522, 160) -- NRG-500
table.insert(limitSpeed, 468, 125) -- Sanchez
table.insert(limitSpeed, 581, 140) -- BF-400
table.insert(limitSpeed, 521, 150) -- FCR-900
table.insert(limitSpeed, 461, 145) -- PCJ-600
table.insert(limitSpeed, 463, 140) -- Freeway
table.insert(limitSpeed, 586, 130) -- Wayfarer
table.insert(limitSpeed, 448, 80) -- Pizzaboy
table.insert(limitSpeed, 462, 90) -- Faggio
table.insert(limitSpeed, 471, 120) -- Quadbike
table.insert(limitSpeed, 523, 160) -- HPV1000
table.insert(limitSpeed, 449, 45) -- HPV1000

table.insert(limitSpeed, 414, 160) -- Mule
table.insert(limitSpeed, 431, 160) -- Bus
]]

local ccEnabled = false
local theVehicle = nil
local targetSpeed = 0
specialVehicles = {
    [573] = true,
}

function doCruiseControl()
    if not isElement(theVehicle) or not getVehicleEngineState(theVehicle) then
        deactivateCruiseControl()
        return false
    end
    local x,y = angle(theVehicle)
    if (x < 5) then
        local targetSpeedTmp = getElementSpeed(theVehicle)
        if (targetSpeedTmp > targetSpeed) then
            setPedControlState(localPlayer, "accelerate",false)
        elseif (targetSpeedTmp < targetSpeed) then
            setPedControlState(localPlayer, "accelerate",true)
        end
    end
end

function activateCruiseControl()
    addEventHandler("onClientRender", getRootElement(), doCruiseControl)
    ccEnabled = true
    bindMe()
end

function deactivateCruiseControl()
    removeEventHandler("onClientRender", getRootElement(), doCruiseControl)
    setPedControlState(localPlayer, "accelerate",false)
    ccEnabled = false
    exports.hud:sendBottomNotification(localPlayer, "Cruise Control", "Cruise Control disabled.")
end

function applyCruiseControl()
	theVehicle = getPedOccupiedVehicle( getLocalPlayer() )
	if (theVehicle) then
		if (getVehicleOccupant(theVehicle) == getLocalPlayer()) then
			if (getVehicleEngineState ( theVehicle ) == true) then
				if (ccEnabled) then
					deactivateCruiseControl()
				else
					targetSpeed = getElementSpeed(theVehicle)
					if targetSpeed > 10 then
						if (getVehicleType(theVehicle) == "Automobile" or getVehicleType(theVehicle) == "Bike" or getVehicleType(theVehicle) =="Boat" or getVehicleType(theVehicle) == "Train" or getVehicleType(theVehicle) == "Plane" or getVehicleType(theVehicle) == "Helicopter") or specialVehicles[getElementModel(theVehicle)] then
							exports.hud:sendBottomNotification(localPlayer, "Cruise Control Enabled", "Use - and + to adjust the speed.")
							activateCruiseControl()
						end
					else
                        exports.hud:sendBottomNotification(localPlayer, "Cruise Control", "Cruise Control can be used for maintaining speed, not pulling up.")
					end
				end
            else
                exports.hud:sendBottomNotification(localPlayer, "Cruise Control", "The engine is not turned on!")
			end
		end
	end
end
addEvent("realism:togCc", true)
addEventHandler("realism:togCc", root, applyCruiseControl)

addEventHandler("onClientPlayerVehicleExit", getLocalPlayer(), function(veh, seat)
    if (seat==0) then
        if (ccEnabled) then
            deactivateCruiseControl()
        end
    end
end)

function increaseCruiseControl()
    if (ccEnabled) then
        targetSpeed = targetSpeed + 5
        
        local tV = getPedOccupiedVehicle(getLocalPlayer()) 
        if (tV) then
            local maxSpeed = limitSpeed[getElementModel(tV)]
            if maxSpeed then 
                if targetSpeed > maxSpeed then
                    targetSpeed = maxSpeed
                end
            end
        end 
    end
end


function decreaseCruiseControl()
    if (ccEnabled) then
        targetSpeed = targetSpeed - 5
    end
end


function startAccel()
    if (ccEnabled) then
        deactivateCruiseControl()
    end
end


function stopAccel()
    if (ccEnabled) then
        deactivateCruiseControl()
    end
end


function restrictBikes(manual) 
    local tV = getPedOccupiedVehicle(getLocalPlayer()) 
    if (tV) then
        local maxSpeed = limitSpeed[getElementModel(tV)]
        if maxSpeed then 
            tS = exports.global:getVehicleVelocity(tV) 
            if tS > maxSpeed then 
                toggleControl("accelerate",false) 
            else 
                toggleControl("accelerate", true) 
            end 
        end
    end 
end


function bindMe()
    bindKey("brake_reverse", "down", stopAccel)
    bindKey("accelerate", "down", startAccel)
end

    function loadMe( startedRes )
        outputDebugString("cc loaded")
        bindKey("-", "down", decreaseCruiseControl)
        bindKey("num_sub", "down", decreaseCruiseControl)
        
        bindKey("=", "down", increaseCruiseControl)
        bindKey("num_add", "down", increaseCruiseControl)
        
        addCommandHandler("cc", applyCruiseControl)
        addCommandHandler("cruisecontrol", applyCruiseControl)

        addEventHandler("onClientRender", getRootElement(), restrictBikes)
        bindMe()
    end
addEventHandler( "onClientResourceStart", getResourceRootElement(getThisResource()) , loadMe)

function isCcEnabled()
    return ccEnabled
end

function resourceStart()
	bindKey("c", "down", function()
		if getElementData(localPlayer, "vehicle_hotkey") == "0" then 
			return false
		end
		applyCruiseControl()
	end) 
end
addEventHandler("onClientResourceStart", resourceRoot, resourceStart)