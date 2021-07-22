governmentVehicle = { [407]=true, [416]=true, [427]=true, [490]=true, [528]=true, [407]=true, [544]=true, [523]=true, [596]=true, [597]=true, [598]=true, [599]=true, [601]=true, [428]=true }
orangeVehicle = { [525]=true, [524]=true, [486]=true, [552]=true, [578]=true }

local factions = 
{
	-- faction types
	[-2] = {1, 61, governmentVehicle}, -- Law
	[-3] = {1, 61, governmentVehicle}, -- Government
	[-4] = {3, 61, governmentVehicle}, -- Medical
	
	-- 0 = civilian vehicles OR no other strobes
	[19555] = {2, 140, orangeVehicle},
	[0] = {3, 61, orangeVehicle},
	
	-- factions
	[64] = {2, false, governmentVehicle}, -- Los Santos International Airport
	
	--Vehicles
	[525] = {2, 61, orangeVehicle},
	[524] = {2, 61, orangeVehicle},
	[486] = {2, 61, orangeVehicle},
	[552] = {2, 61, orangeVehicle},
	[578] = {2, 61, orangeVehicle},
}

function vehicleBlown()
	exports.anticheat:changeProtectedElementDataEx(source, "lspd:flashers", nil, true)
end
addEventHandler("onVehicleRespawn", getRootElement(), vehicleBlown)

local function getFactionType(vehicle)
	local vehicleFactionID = getElementData(vehicle, "faction")
	local vehicleFactionElement = exports.pool:getElement("team", vehicleFactionID)
	if vehicleFactionElement then
		local type = getElementData(vehicleFactionElement, "type")
		if tonumber(type) then
			return getElementData(vehicleFactionElement, "type"), vehicleFactionID
		end
	end
	return 100, 100
end

local function canUseStrobes(vehicle, data)
	if data then
		if data[2] then
			if exports.global:hasItem(vehicle, data[2], "Law") then
				return 1 --Returns strobe type 1, for Law vehicles.
			elseif exports.global:hasItem(vehicle, data[2]) then
				return data[1]
			end
		else
			for i = 3, #data do
				if data[i][getElementModel(vehicle)] then
					return data[1]
				end
			end
		end
	end
	return false
end

function toggleFlasherState()
	if not (client) then
		return false
	end
	local theVehicle = getPedOccupiedVehicle(client)
	if not theVehicle then
		return false
	end
	
	if (theVehicle) then
		local currentFlasherState = getElementData(theVehicle, "lspd:flashers") or 0
		if currentFlasherState ~= 0 then
			exports.anticheat:changeProtectedElementDataEx(theVehicle, "lspd:flashers", nil, true)
			local oldState = getElementData(theVehicle, "lights:old") or 1
			exports.anticheat:setEld(theVehicle, "lights", oldState, 'all')
			if oldState == 1 or oldState == 2 then
				setVehicleOverrideLights(theVehicle, 2)
				local trailer = getVehicleTowedByVehicle(theVehicle)
				if trailer then
					setVehicleOverrideLights(trailer, 2)
				end
			else
				setVehicleOverrideLights(theVehicle, 1)
				local trailer = getVehicleTowedByVehicle(theVehicle)
				if trailer then
					setVehicleOverrideLights(trailer, 1)
				end
			end
		else
			local type, id = getFactionType(theVehicle)
			local color = canUseStrobes(theVehicle, factions[-type]) or canUseStrobes(theVehicle, factions[id]) or canUseStrobes(theVehicle, factions[getElementModel(theVehicle)]) or canUseStrobes(theVehicle, factions[0])
			or canUseStrobes(theVehicle, factions[19555])
			if color then
				local oldState = getElementData(theVehicle, "lights")
				exports.anticheat:setEld(theVehicle, "lights", 1, 'all')
				exports.anticheat:setEld(theVehicle, "lights:old", oldState, 'all')
				setVehicleOverrideLights(theVehicle, 2)
				local trailer = getVehicleTowedByVehicle(theVehicle)
				if trailer then
					setVehicleOverrideLights(trailer, 2)
				end
				exports.anticheat:changeProtectedElementDataEx(theVehicle, "lspd:flashers", color, true)
			else
				outputChatBox("There are no strobes installed in this vehicle.", client, 255, 0, 0)
			end
		end
	end
end
addEvent( "lspd:toggleFlashers", true )
addEventHandler( "lspd:toggleFlashers", getRootElement(), toggleFlasherState )