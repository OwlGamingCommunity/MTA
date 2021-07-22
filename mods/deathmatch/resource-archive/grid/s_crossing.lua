--    ____        __     ____  __            ____               _           __ 
--   / __ \____  / /__  / __ \/ /___ ___  __/ __ \_________    (_)__  _____/ /_
--  / /_/ / __ \/ / _ \/ /_/ / / __ `/ / / / /_/ / ___/ __ \  / / _ \/ ___/ __/
-- / _, _/ /_/ / /  __/ ____/ / /_/ / /_/ / ____/ /  / /_/ / / /  __/ /__/ /_  
--/_/ |_|\____/_/\___/_/   /_/\__,_/\__, /_/   /_/   \____/_/ /\___/\___/\__/  
--                                 /____/                /___/                 
--Server-side script: The grid
--Last updated 26.03.2015 by Exciter
--Copyright 2008-2015, The Roleplay Project (www.roleplayproject.com)

local simMapFilesCache = {}

function serverSetToSim(vehicle, newSim, x, y, z, dir, oldSim)
	setElementFrozen(vehicle, true)
	--setElementFrozen(client, true)
	setElementVelocity(vehicle, 0, 0, 0)
	setVehicleTurnVelocity(vehicle, 0, 0, 0)
	exports.anticheat:changeProtectedElementDataEx(vehicle, "health", getElementHealth(vehicle), false)
	setElementPosition(vehicle, x, y, z)
	setElementDimension(vehicle, newSim)
	for i = 0, getVehicleMaxPassengers(vehicle) do
		local player = getVehicleOccupant(vehicle, i)
		if player then
			triggerClientEvent(player, "CantFallOffBike", player)
			--setElementPosition(player, x, y, z)
			setElementDimension(player, newSim)
		end
	end
	local attachments = getAttachedElements(vehicle)
	for k,v in ipairs(attachments) do
		setElementDimension(v, newSim)
	end
	--outputChatBox("-")
	outputChatBox(tostring(getPlayerName(client)).." traveled "..tostring(dir).." to sim "..tostring(newSim).." (from "..tostring(oldSim))
	--setElementFrozen(vehicle, false)
	--setElementFrozen(client, false)
	
	triggerClientEvent(client, "grid:clientMovedToSim", client, vehicle, newSim, x, y, z, dir, oldSim)
	
	setTimer(function ()
		setVehicleTurnVelocity(vehicle, 0, 0, 0)
		setElementHealth(vehicle, getElementData(vehicle, "health") or 1000)
		exports.anticheat:changeProtectedElementDataEx(vehicle, "health")
		setElementFrozen(vehicle, false)
	end, 1000, 1)
	
end
addEvent("grid:serverSetToSim", true)
addEventHandler("grid:serverSetToSim", root, serverSetToSim)

function getSimMaps(vehicle, newSim, x, y, z, dir, oldSim)
	local maps
	if not simMapFilesCache[newSim] then
		simMapFilesCache[newSim] = {}
		local simIDstring
		local regionstr = tostring(newSim)
		local strlenght = string.len(regionstr)
		if region == 0 then
			simIDstring = "5050"
		elseif strlenght == 4 then
			simIDstring = regionstr
		elseif strlenght == 3 then
			simIDstring = "0"..regionstr
		elseif strlenght == 2 then
			simIDstring = "00"..regionstr
		elseif strlength == 1 then
			simIDstring = "000"..regionstr
		else
			simIDstring = "0"
		end

		local extension = ".map"
		local xml = xmlLoadFile(":grid/meta.xml")
		if xml then
			local index = 0
			local node = xmlFindChild(xml, "file", index)
			local count = 1
			while node do
				local src = xmlNodeGetAttribute(node, "src")
				if src and src:sub(-#extension) == extension then
					local srcfolders = split(src, "/")
					local srcsim = srcfolders[2]
					if srcsim == simIDstring then
						table.insert(simMapFilesCache[newSim], src)
						count = count + 1
					end
				end
				index = index + 1
				node = xmlFindChild(xml, "file", index)
			end
			maps = simMapFilesCache[newSim]
		end
	else
		maps = simMapFilesCache[newSim]
	end
	triggerClientEvent(client, "grid:clientGetSimMaps", client, vehicle, newSim, x, y, z, dir, oldSim, maps)
end
addEvent("grid:getSimMaps", true)
addEventHandler("grid:getSimMaps", root, getSimMaps)