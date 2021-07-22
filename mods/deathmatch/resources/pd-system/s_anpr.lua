-- Variables
RANGES = {anpr = 8, speedcamera = 30}
POLICE_VEHICLES = {[523] = true, [598] = true, [596] = true, [597] = true, [599] = true}
GOV_VEHICLES = {[523] = true, [598] = true, [596] = true, [597] = true, [599] = true, [416] = true, [427] = true, [407] = true, [544] = true}
COLORS = {
	"white", "blue", "red", "dark green", "purple",
	"yellow", "blue", "gray", "blue", "silver",
	"gray", "blue", "dark gray", "silver", "gray",
	"green", "red", "red", "gray", "blue",
	"red", "red", "gray", "dark gray", "dark gray",
	"silver", "brown", "blue", "silver", "brown",
	"red", "blue", "gray", "gray", "dark gray",
	"black", "green", "light green", "blue", "black",
	"brown", "red", "red", "green", "red",
	"pale", "brown", "gray", "silver", "gray",
	"green", "blue", "dark blue", "dark blue", "brown",
	"silver", "pale", "red", "blue", "gray",
	"brown", "red", "silver", "silver", "green",
	"dark red", "blue", "pale", "light pink", "red",
	"blue", "brown", "light green", "red", "black",
	"silver", "pale", "red", "blue", "dark red",
	"purple", "dark red", "dark green", "dark brown", "purple",
	"green", "blue", "red", "pale", "silver",
	"dark blue", "gray", "blue", "blue", "blue",
	"silver", "light blue", "gray", "pale", "blue",
	"black", "pale", "blue", "pale", "gray",
	"blue", "pale", "blue", "dark gray", "brown",
	"silver", "blue", "dark brown", "dark green", "red",
	"dark blue", "red", "silver", "dark brown", "brown",
	"red", "gray", "brown", "red", "blue",
	"pink", [0] = "black"
}

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

function isANPRExisting(player)
	if not isVerifiedElement(player, "player") then return end
	local exists = false
	for _,v in ipairs(getElementsByType("colshape")) do
		if getElementData(v, "anpr:owner") == getPlayerName(player) then
			exists = true
			return true
		end
	end
	
	setTimer(function()
		if exists == false then
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
addCommandHandler({"toganpr", "toggleanpr", "toganprcamera", "toganprcam"},
function(player, cmd, speed)
	local vehicle = getPedOccupiedVehicle(player)
	local fID = getElementData(vehicle, "faction")
    if vehicle then
        if (fID == 1) or (fID == 50) then
            if exports.global:hasItem(vehicle, 284) then
                if getElementData(vehicle, "anpr:state") then
                    local x, y, z = getElementPosition(vehicle)
                    for _,v in ipairs(getAttachedElements(vehicle)) do
                        if isVerifiedElement(v, "colshape") and getElementData(v, "anpr:state") then
                            destroyElement(v)
                            break
                        end
                    end
                    outputChatBox("The ANPR System has been deactivated on this cruiser.", player, 255, 180, 20, false)
                    removeElementData(vehicle, "anpr:owner")
                    removeElementData(vehicle, "anpr:state") 
                    playSoundFrontEnd(player, 101)
                else
                    if not isANPRExisting(player) then
                        local x, y, z = getElementPosition(vehicle)
                        local creator = getPlayerName(player)
                        local radius = createColSphere(x, y, z, RANGES.anpr)
                        attachElements(radius, vehicle)
                        setElementData(vehicle, "anpr:owner", creator, false)
                        setElementData(vehicle, "anpr:state", 1, false)
                        setElementData(radius, "anpr:state", 1, false)
                        setElementData(radius, "anpr:owner", creator, false)
                        setElementData(player, "anpr:vehicleColor", "No info", true )
                        setElementData(player, "anpr:vehicleName", "No info", true )
                        outputChatBox("You have turned on the ANPR System.", player, 255, 180, 20, false)
                        --triggerClientEvent(player, "anprON", player)
                        playSoundFrontEnd(player, 45)
                    else
                        outputChatBox("SYNTAX: /" .. cmd, player, 255, 180, 20, false)
                    end    
                end 
            else
                outputChatBox("You must be in a law enforcement vehicle with a ANPR system.", player, 255, 0, 0, false)    
            end    
        else
            outputChatBox("You must be in a law enforcement vehicle in order to activate your speed camera.", player, 255, 0, 0, false)
        end
    end
end, false, false )

addCommandHandler({"resetanpr", "resetanprcam", "resetanprcamera"},
	function(player, cmd)
		if isANPRExisting(player) then
			for _,v in ipairs(getElementsByType("vehicle")) do
				if getElementData(v, "anpr:owner") == getPlayerName(player) then
					removeElementData(v, "anpr:owner")
					removeElementData(v, "anpr:state")
				end
			end
			
			for _,v in ipairs(getElementsByType("colshape")) do
				if getElementData(v, "anpr:owner") == getPlayerName(player) then
					destroyElement(v)
					break
				end
			end
			setElementData(player, "anpr:vehicleColor", "No info", true )
			setElementData(player, "anpr:vehicleName", "No info", true )
			outputChatBox("All of your speed cameras are now deactivated.", player, 255, 180, 20, false)
		else
			outputChatBox("There's no ANPR system active.", player, 255, 0, 0, false)
		end
	end, false, false
)

-- Events
addEventHandler("onColShapeHit", root,
    function(hitElement, matchingDimension)
        if matchingDimension then
            if not isVerifiedElement(hitElement, "vehicle") then return end
            if getElementData(source, "anpr:state") then
                local radar = getElementAttachedTo(source)
                if radar and (not triggered[hitElement]) then
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
                       
                        if isVerifiedElement(radar, "vehicle") and getElementData(radar, "anpr:state") then
                            local c1, c2, c3, c4 = getVehicleColor(hitElement)
                            if hasVehicleANPR(hitElement) then
                                for seat,player in pairs(getVehicleOccupants(radar)) do
                                    playSoundFrontEnd( player, 45 )
                                    setTimer( playSoundFrontEnd, 500, 5, player, 45 )
                                    setElementData(player, "anpr:vehicleColor", getColorName(c1, c2), true )
                                    setElementData(player, "anpr:vehicleName", exports.global:getVehicleName(hitElement), true )
                                    setElementData(player, "anpr:vehicleName", exports.global:getVehicleName(hitElement), true )
                                    setElementData(player, "anpr:vehicleDirection", direction, true )
                                    outputChatBox("[RADAR] A ANPR hit was recorded on a " .. getColorName(c1, c2) .. " " .. exports.global:getVehicleName(hitElement).." with plates "..getElementData(hitElement, "plate")..".", player, 255, 0, 0, false)
                                    triggered[hitElement] = true
                                    setTimer(function(hitElement) triggered[hitElement] = nil end, 5000, 1, hitElement)                                
                                end
                            end    
                        end
                    end, 500, 1, hitElement, x, y, z, kmh)
                end
            end
        end
    end
)

function hasVehicleANPR(theVehicle)
	if getElementType(theVehicle) == "vehicle" then
		local anpr = exports.mdc:getANPRTable()
        local plate = getElementData(theVehicle, "plate")
		local disabledPlate = getElementData(theVehicle, "show_plate")
		if ( #anpr > 0 and disabledPlate == 1) then
			for i = 1, #anpr, 1 do
				if (anpr[i][1] == plate or getElementData(theVehicle, "stolen") == 1) then
					return true 
				end
			end
		end
        return false 
	end
end					


addEventHandler("onPlayerQuit", root,
	function()
		if isANPRExisting(source) then
			for _,v in ipairs(getElementsByType("vehicle")) do
				if getElementData(v, "anpr:owner") == getPlayerName(source) then
					removeElementData(v, "anpr:owner")
					removeElementData(v, "anpr:state")
					setElementData(source, "anpr:vehicleColor", "No info", true )
					setElementData(source, "anpr:vehicleName", "No info", true )
				end
			end
			
			for _,v in ipairs(getElementsByType("colshape")) do
				if getElementData(v, "anpr:owner") == getPlayerName(source) then
					destroyElement(v)
					break
				end
			end
		end
	end
)

addEventHandler("onPlayerVehicleExit", root,
	function(vehicle, seat, jacked)
		if getElementData(vehicle, "anpr:state") and (seat == 0) then
			removeElementData(vehicle, "anpr:owner")
			removeElementData(vehicle, "anpr:state")
			setElementData(source, "anpr:vehicleColor", "No info", true )
			setElementData(source, "anpr:vehicleName", "No info", true )
			for _,v in ipairs(getElementsByType("colshape")) do
				if getElementData(v, "anpr:owner") == getPlayerName(source) then
					destroyElement(v)
					break
				end
			end
			outputChatBox("ANPR System has been deactivated.", source, 255, 180, 20, false)
		end
	end
)

addEventHandler("onResourceStop", resourceRoot,
	function()
		for _,v in ipairs(getElementsByType("vehicle")) do
			if getElementData(v, "anpr:state") then
				removeElementData(v, "anpr:owner")
				removeElementData(v, "anpr:state")
				setElementData(source, "anpr:vehicleColor", "No info", true )
				setElementData(source, "anpr:vehicleName", "No info", true )
				outputChatBox("ANPR System has been deactivated.", getVehicleController(v), 255, 180, 20, false)
			end
		end
		
		for _,v in ipairs(getElementsByType("colshape")) do
			if getElementData(v, "anpr:state") then
				destroyElement(v)
			end
		end
	end
)

addEventHandler("onPlayerWasted", root,
	function(ammo, killer, weapon, bodypart, stealth)
		if isANPRExisting(source) then
			for _,v in ipairs(getElementsByType("vehicle")) do
				if getElementData(v, "anpr:owner") == getPlayerName(source) then
					removeElementData(v, "anpr:owner")
					removeElementData(v, "anpr:state")
					setElementData(source, "anpr:vehicleColor", "No info", true )
					setElementData(source, "anpr:vehicleName", "No info", true )
				end
			end
			
			for _,v in ipairs(getElementsByType("colshape")) do
				if getElementData(v, "anpr:owner") == getPlayerName(source) then
					destroyElement(v)
					break
				end
			end
			outputChatBox("ANPR System has been deactivated.", source, 255, 180, 20, false)
		end
	end
)