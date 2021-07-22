-- Wrappers
local addCommandHandler_ = addCommandHandler
	addCommandHandler  = function(commandName, fn, restricted, caseSensitive)
	if type(commandName) ~= "table" then
		commandName = {commandName}
	end
	for key, value in ipairs(commandName) do
		if key == 1 then
			addCommandHandler_(value, fn, restricted, caseSensitive)
		else
			addCommandHandler_(value,
				function(player, ...)
					if hasObjectPermissionTo(player, "command." .. commandName[1], not restricted) then
						fn(player, ...)
					end
				end
			)
		end
	end
end

function changeSpeedradar(player, commandName)
	if isCameraExisting(player) then
		if getElementData(player, "speedradar_chat") then
			setElementData(player, "speedradar_chat", false, true)
			outputChatBox("Speedcam changed to GUI", player, 255, 180, 20)
			triggerClientEvent(player, "speedcamON", player)
		else
			setElementData(player, "speedradar_chat", true, true)
			triggerClientEvent("destroyGUI", player)
			outputChatBox("Speedcam changed to chatbox", player, 255, 180, 20)
		end
	else
		outputChatBox("You need to have a speedcamera in order to use this command", player, 255, 0, 0)
	end	
end
addCommandHandler("speedmode", changeSpeedradar)

-- Exports
function isVerifiedElement(element, verified)
    if isElement(element) then
        if getElementType(element) == tostring(verified) then
            if verified == "vehicle" then
                if getVehicleType(element) ~= "BMX" then
                    return true
                else
                    return false
                end
            else
                return true
            end
        else
            return false
        end
    else
        return false
    end
end

function isCameraExisting(player)
	if not isVerifiedElement(player, "player") then return end
	local exists = false
	for _,v in ipairs(getElementsByType("colshape")) do
		if getElementData(v, "speedcamera:owner") == getPlayerName(player) then
			exists = true
			return true
		end
	end
	
	setTimer(function()
		if not exists then
			return false
		end
	end, 700, 1)
end

function getColorName(c1, c2)
	local color1 = COLORS[c1] or "Unknown"
	local color2 = COLORS[c2] or "Unknown"
	
	if color1 ~= color2 then
		return color1 .. " & " .. color2
	else
		return color1
	end
end

-- Interactive functions
addCommandHandler({"togspeedcamera", "togglespeedcamera", "togspeedcam", "togglespeedcam", "togspeed", "togglespeed"},
	function(player, cmd, speed)
		local vehicle = getPedOccupiedVehicle(player)
		if vehicle then
			if tonumber(getElementData(vehicle, "faction")) == 1 or tonumber(getElementData(vehicle, "faction")) == 50 or tonumber(getElementData(vehicle, "dbid") == 331) or tonumber(getElementData(vehicle, "faction")) == 45 or tonumber(getElementData(vehicle, "faction")) == 59 and (getVehicleController(vehicle) == player) then
				if getElementData(vehicle, "speedcamera:state") then
					local x, y, z = getElementPosition(vehicle)
					for _,v in ipairs(getAttachedElements(vehicle)) do
						if isVerifiedElement(v, "colshape") and getElementData(v, "speedcamera:state") then
							destroyElement(v)
							break
						end
					end
					outputChatBox("Dual Stalker SL speed camera has been deactivated on this cruiser.", player, 255, 180, 20, false)
					removeElementData(vehicle, "speedcamera:owner")
					removeElementData(vehicle, "speedcamera:state")
					if not getElementData(player, "speedradar_chat") then
						triggerClientEvent("destroyGUI", player)
					end
					playSoundFrontEnd(player, 101)
				else
					if not isCameraExisting(player) then
						local speed = tonumber(speed)
						if speed then
							if speed >= 30 and speed <= 500 then
								local x, y, z = getElementPosition(vehicle)
								local creator = getPlayerName(player)
								local radius = createColSphere(x, y, z, RANGES.speedcamera)
								attachElements(radius, vehicle)
								setElementData(player, "speedradar_chat", false, true)
								setElementData(vehicle, "speedcamera:owner", creator, false)
								setElementData(vehicle, "speedcamera:state", 1, false)
								setElementData(radius, "speedcamera:state", 1, false)
								setElementData(radius, "speedcamera:owner", creator, false)
								setElementData(radius, "speedcamera:speed", speed, false)
								setElementData(player, "speedcamera:setSpeed", speed, true)
								setElementData(player, "speedcamera:targetSpeed", "0", true)
								setElementData(player, "speedcamera:targetTopSpeed", "0", true)
								setElementData(player, "speedcamera:vehicleColor", "No info", true )
								setElementData(player, "speedcamera:vehicleName", "No info", true )
								setElementData(player, "speedcamera:vehicleDirection", "No info", true )
								outputChatBox("You have turned on Dual Stalker SL speed camera.", player, 255, 180, 20, false)
								
								triggerClientEvent(player, "speedcamON", player)
								
								playSoundFrontEnd(player, 101)
							end
						else
							outputChatBox("SYNTAX: /" .. cmd .. " [30 or more]", player, 255, 180, 20, false)
						end
					else
						outputChatBox("You need to deactivate the existing speed camera.", player, 255, 0, 0, false)
					end
				end
			else
				outputChatBox("You must be in a law enforcement vehicle in order to activate your speed camera.", player, 255, 0, 0, false)
			end
		end
	end, false, false
)

addCommandHandler({"resetspeed", "resetspeedcam", "resetspeedcamera"},
	function(player, cmd)
		if isCameraExisting(player) then
			local playerVehicle = getPedOccupiedVehicle(player)
			if getElementData(playerVehicle, "speedcamera:owner") == getPlayerName(player) then
				removeElementData(playerVehicle, "speedcamera:owner")
				removeElementData(playerVehicle, "speedcamera:state")
			end

			for _,v in ipairs(getElementsByType("colshape")) do
				if getElementData(v, "speedcamera:owner") == getPlayerName(player) then
					destroyElement(v)
					break
				end
			end

			if not getElementData(player, "speedradar_chat") then
				triggerClientEvent("destroyGUI", player)
			end

			setElementData(player, "speedcamera:targetSpeed", "0", true)
			setElementData(player, "speedcamera:targetTopSpeed", "0", true)
			setElementData(player, "speedcamera:vehicleColor", "No info", true )
			setElementData(player, "speedcamera:vehicleName", "No info", true )
			setElementData(player, "speedcamera:vehicleDirection", "No info", true )
			outputChatBox("All of your speed cameras are now deactivated.", player, 255, 180, 20, false)
		else
			outputChatBox("You do not have any existing speed cameras.", player, 255, 0, 0, false)
		end
	end, false, false
)

-- Events
addEventHandler("onColShapeHit", root,
	function(hitElement, matchingDimension)
		if matchingDimension then
			if not isVerifiedElement(hitElement, "vehicle") then return end
			if getElementData(source, "speedcamera:state") then
				if (not POLICE_VEHICLES[getElementModel(hitElement)]) and (not GOV_VEHICLES[getElementModel(hitElement)]) then
					local speedx, speedy, speedz = getElementVelocity(hitElement)
					local actualspeed = (speedx ^ 2 + speedy ^ 2 + speedz ^ 2) ^ (0.5)
					local kmh = math.ceil(actualspeed * 180)
					if tonumber(kmh) >= tonumber(getElementData(source, "speedcamera:speed")) then
						local radar = getElementAttachedTo(source)
						if radar then
							local x, y, z = getElementPosition(getVehicleController(hitElement) or hitElement)
							setTimer(function(hitElement, x, y, z, kmh)
								local nx, ny, nz = getElementPosition(hitElement)
								local dx = nx - x
								local dy = ny - y
								
								if dy > math.abs(dx) then
									direction = "northbound"
								elseif dy < -math.abs(dx) then
									direction = "southbound"
								elseif dx > math.abs(dy) then
									direction = "eastbound"
								elseif dx < -math.abs(dy) then
									direction = "westbound"
								end
								
								if isVerifiedElement(radar, "vehicle") and getElementData(radar, "speedcamera:state") then
									local c1, c2, c3, c4 = getVehicleColor(hitElement)
									for seat,player in pairs(getVehicleOccupants(radar)) do
										
										if tonumber(getElementData(player, "speedcamera:targetTopSpeed")) <= math.floor(tonumber(kmh)) then
											setElementData(player, "speedcamera:targetTopSpeed", math.floor(tonumber(kmh)), true)
											playSoundFrontEnd( player, 43 )
											setTimer( playSoundFrontEnd, 1000, 2, player, 43 )
										end

										setElementData(player, "speedcamera:targetSpeed", math.floor(tonumber(kmh)), true)
										setElementData(player, "speedcamera:vehicleColor", getColorName(c1, c2), true )
										setElementData(player, "speedcamera:vehicleName", exports.global:getVehicleName(hitElement), true )
										setElementData(player, "speedcamera:vehicleDirection", direction, true )
										 
										-- If we are using the chat, normal chatbox. Otherwise go in console
										if getElementData(player, "speedradar_chat") then
											outputChatBox("[RADAR] A " .. getColorName(c1, c2) .. " " .. exports.global:getVehicleName(hitElement) .. " was clocked travelling at " .. math.floor(tonumber(kmh) * 0.621371) .. " mph (" .. tonumber(kmh) .. " km/h) and is heading " .. direction .. ".", player, 255, 180, 20, false)										
										else
											outputConsole( "[RADAR] A " .. getColorName(c1, c2) .. " " .. exports.global:getVehicleName(hitElement) .. " was clocked travelling at " .. math.floor(tonumber(kmh) * 0.621371) .. " mph (" .. tonumber(kmh) .. " km/h) and is heading " .. direction .. ".", player )
										end
									end
								end
							end, 500, 1, hitElement, x, y, z, kmh)
						end
					end
				end
			end
		end
	end
)

addEventHandler("onPlayerQuit", root,
	function()
		if isCameraExisting(source) then
			local playerVehicle = getPedOccupiedVehicle(source)
			if getElementData(playerVehicle, "speedcamera:owner") == getPlayerName(source) then
				removeElementData(playerVehicle, "speedcamera:owner")
				removeElementData(playerVehicle, "speedcamera:state")
			end

			for _,v in ipairs(getElementsByType("colshape")) do
				if getElementData(v, "speedcamera:owner") == getPlayerName(source) then
					destroyElement(v)
					break
				end
			end
		end
	end
)

addEventHandler("onPlayerVehicleExit", root,
	function(vehicle, seat, jacked)
		if getElementData(vehicle, "speedcamera:state") and (seat == 0) then
			removeElementData(vehicle, "speedcamera:owner")
			removeElementData(vehicle, "speedcamera:state")
			setElementData(source, "speedcamera:targetSpeed", "0", true)
			setElementData(source, "speedcamera:targetTopSpeed", "0", true)
			setElementData(source, "speedcamera:vehicleColor", "No info", true )
			setElementData(source, "speedcamera:vehicleName", "No info", true )
			setElementData(source, "speedcamera:vehicleDirection", "No info", true )
			for _,v in ipairs(getElementsByType("colshape")) do
				if getElementData(v, "speedcamera:owner") == getPlayerName(source) then
					destroyElement(v)
					break
				end
			end
			outputChatBox("Speed camera has been deactivated.", source, 255, 180, 20, false)
			if not getElementData(source, "speedradar_chat") then
				triggerClientEvent("destroyGUI", source)
			end
		end
	end
)

addEventHandler("onResourceStop", resourceRoot,
	function()
		for _,v in ipairs(getElementsByType("vehicle")) do
			if getElementData(v, "speedcamera:state") then
				removeElementData(v, "speedcamera:owner")
				removeElementData(v, "speedcamera:state")
				setElementData(source, "speedcamera:targetSpeed", "0", true)
				setElementData(source, "speedcamera:targetTopSpeed", "0", true)
				setElementData(source, "speedcamera:vehicleColor", "No info", true )
				setElementData(source, "speedcamera:vehicleName", "No info", true )
				setElementData(source, "speedcamera:vehicleDirection", "No info", true )
				outputChatBox("Speed camera has been deactivated.", getVehicleController(v), 255, 180, 20, false)
			end
		end
		
		for _,v in ipairs(getElementsByType("colshape")) do
			if getElementData(v, "speedcamera:state") then
				destroyElement(v)
			end
		end
	end
)

addEventHandler("onPlayerWasted", root,
	function(ammo, killer, weapon, bodypart, stealth)
		if isCameraExisting(source) then
			for _,v in ipairs(getElementsByType("vehicle")) do
				if getElementData(v, "speedcamera:owner") == getPlayerName(source) then
					removeElementData(v, "speedcamera:owner")
					removeElementData(v, "speedcamera:state")
					setElementData(source, "speedcamera:targetSpeed", "0", true)
					setElementData(source, "speedcamera:targetTopSpeed", "0", true)
					setElementData(source, "speedcamera:vehicleColor", "No info", true )
					setElementData(source, "speedcamera:vehicleName", "No info", true )
					setElementData(source, "speedcamera:vehicleDirection", "No info", true )
				end
			end
			
			for _,v in ipairs(getElementsByType("colshape")) do
				if getElementData(v, "speedcamera:owner") == getPlayerName(source) then
					destroyElement(v)
					break
				end
			end
			if not getElementData(source, "speedradar_chat") then
				triggerClientEvent("destroyGUI", source)
			end
			outputChatBox("Speed camera has been deactivated.", source, 255, 180, 20, false)
		end
	end
)