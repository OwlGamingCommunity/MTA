function getVehicleName(veh)
	return exports.global:getVehicleName(veh)
end

function monitorSpeed(theVehicle, matchingDimension)
	if (matchingDimension) and (getElementType(theVehicle)=="vehicle") then
		local enabled = getElementData(source, "speedcam:enabled")
		if (enabled) then
			local thePlayer = getVehicleOccupant(theVehicle)
			if thePlayer then
				local maxSpeed = getElementData(source, "speedcam:maxspeed")
				local timer = setTimer(checkSpeed, 100, 30, theVehicle, thePlayer, source, maxSpeed)
				exports.anticheat:changeProtectedElementDataEx(thePlayer, "speedcam:timer", timer, false)
			end
		end
	end
end

function stopMonitorSpeed(theVehicle, matchingDimension)
	if (matchingDimension) and (getElementType(theVehicle)=="vehicle") then
		local thePlayer = getVehicleOccupant(theVehicle)
		if thePlayer then
			local timer = getElementData(thePlayer, "speedcam:timer")
			if isTimer( timer ) then
				killTimer( timer )
			end
			exports.anticheat:changeProtectedElementDataEx( thePlayer, "speedcam:timer",false, false)
		end
	end
end

function checkSpeed(theVehicle, thePlayer, colshape, maxSpeed)
	local currentSpeed = math.floor(exports.global:getVehicleVelocity(theVehicle))

	if (currentSpeed > maxSpeed) then
		local timer = getElementData(thePlayer, "speedcam:timer")
		if timer then
			killTimer(timer)
		end
		exports.anticheat:changeProtectedElementDataEx(thePlayer, "speedcam:timer",false, false)

		--[[ Flash! DISABLED by Anthony
		for i = 0, getVehicleMaxPassengers(theVehicle) do
			local p = getVehicleOccupant(theVehicle, i)
			if p then
				triggerClientEvent(p, "speedcam:cameraEffect", p)
			end
		end]]
		local x, y, z = getElementPosition(thePlayer)
		setTimer(sendWarningToCops, 500, 1, theVehicle, thePlayer, currentSpeed, x, y, z)
	end
end


--Color Names
local colors = {
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
	"pink", [0] = "black" }

local function vehicleColor( c1, c2 )
	local color1 = colors[ c1 ] or "Unknown"
	local color2 = colors[ c2 ] or "Unknown"

	if color1 ~= color2 then
		return color1 .. " & " .. color2
	else
		return color1
	end
end

local function canCameraSee(theVehicle, thePlayer)
	if getElementData(thePlayer, "fullfacehelmet") then 
		return false
	elseif getElementData(theVehicle, "tinted") and getElementData(theVehicle, "vehicle:windowstat") ~= 1 then
		return false
	end

	return true
end

function sendWarningToCops(theVehicle, thePlayer, speed, x, y, z)
	local direction = "in an unknown direction"
	local areaName = getZoneName(x, y, z)
	local nx, ny, nz = getElementPosition(thePlayer)
	local vehicleName = getVehicleName(theVehicle)
	local vehicleID = getElementData(theVehicle, "dbid")
	local color1, color2 = getVehicleColor(theVehicle)

	local dx = nx - x
	local dy = ny - y

	if dy > math.abs(dx) then
		direction = "Northbound"
	elseif dy < -math.abs(dx) then
		direction = "Southbound"
	elseif dx > math.abs(dy) then
		direction = "Eastbound"
	elseif dx < -math.abs(dy) then
		direction = "Westbound"
	end

	--if not (vehicleName == "Police LS") and not (vehicleName == "Police LV") and not (vehicleName == "Police SF") and not (vehicleName == "Police Ranger")  then
	if tonumber(getElementData(theVehicle, "faction")) == 1 or tonumber(getElementData(theVehicle, "faction") == 45) or tonumber(getElementData(theVehicle, "dbid") == 331) or tonumber(getElementData(theVehicle, "faction")) == 2 or getElementModel(theVehicle) == 481 or getElementModel(theVehicle) == 509 or getElementModel(theVehicle) == 510 then
		return
	else
		local teamPlayers = { }
		for a, b in ipairs(exports.factions:getPlayersInFaction(1)) do
			for _, itemRow in ipairs(exports['item-system']:getItems(b)) do
				local setIn = false
				if (not setIn) and (itemRow[1] == 6 and itemRow[2] > 0) then
					table.insert(teamPlayers, b)
					setIn = true
					break
				end
			end
		end
		for a, b in ipairs(exports.factions:getPlayersInFaction(59)) do
			for _, itemRow in ipairs(exports['item-system']:getItems(b)) do
				local setIn = false
				if (not setIn) and (itemRow[1] == 6 and itemRow[2] > 0) then
					table.insert(teamPlayers, b)
					setIn = true
					break
				end
			end
		end

		for key, value in ipairs(teamPlayers) do
			local duty = tonumber(getElementData(value, "duty"))
			if (duty == 1) then
			local vehicleOfficerIsIn = getPedOccupiedVehicle(value)
			if vehicleOfficerIsIn then
					--local vehicleFaction = tonumber(getElementData(vehicleOfficerIsIn, "faction"))
					--if vehicleFaction and vehicleFaction == 1 or vehicleFaction == 2 then
							triggerClientEvent(value, "beep", value)
							outputChatBox("[RADIO] All units, we've got a traffic violation at the " .. areaName .. " speedcam.", value, 0, 210, 255)
							outputChatBox("[RADIO] The vehicle was a " .. vehicleColor(color1, color2) .. " " .. vehicleName .. " travelling at " .. tostring(math.ceil(speed)) .. " KM/H.", value, 0, 210, 255)
						if getElementData(theVehicle, "registered") == 1 and getElementData(theVehicle, "show_plate") == 1 and exports.vehicle:hasVehiclePlates( theVehicle ) then
							outputChatBox("[RADIO] The plates are '"..  getVehiclePlateText ( theVehicle ) .."' and the vehicle was heading " .. direction .. ".", value, 0, 210, 255)
						elseif getElementData(theVehicle, "registered") == 0 and getElementData(theVehicle, "show_plate") == 1 and exports.vehicle:hasVehiclePlates( theVehicle ) then
							outputChatBox("[RADIO] The vehicle is not registered and was heading " .. direction .. ".", value, 0, 210, 255)
						else
							outputChatBox("[RADIO] The vehicle has no plates and was heading " .. direction .. ".", value, 0, 210, 255)
						end
					--end
				end
			end
		end

		if vehicleID > 0 then
			local playerseen = -1
			if canCameraSee(theVehicle, thePlayer) then
				playerseen = getElementData(thePlayer, "dbid") or -1
			end
			
			dbExec(exports.mysql:getConn("mta"), "INSERT INTO `speedingviolations` (`carID`, `time`, `speed`, `area`, `personVisible`) VALUES (?, NOW(), ?, ?, ?)", vehicleID, tostring(math.ceil(speed)), areaName .. " " ..direction, playerseen)
		end
	end
end
