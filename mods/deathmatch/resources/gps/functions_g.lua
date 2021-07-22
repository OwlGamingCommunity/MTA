--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

local last_street = {}
local last_check = nil
local cache = 5000 -- miliseconds
local islandx, islandy =  4440.701171875, 1716.4150390625
local floor = math.floor

function getPlayerStreetLocation(player)
	local pid = getElementData(player, 'dbid') or 0
	if not last_check or getTickCount() - last_check > cache then
		last_check = getTickCount()
		local x, y = getElementPosition(player)
		
		if getDistanceBetweenPoints2D( islandx, islandy, x, y ) < 500 then
			last_street[pid] = "San Tortuguilla Island"
		else
			local node = findNodeClosestToPoint(vehicleNodes, x, y, z)
			if node and node.streetname then
				last_street[pid] = node.streetname
			end
		end 
	end
	return last_street[pid] or "Unknown"
end

function findNodeClosestToPoint(db, x, y, z)
	local areaID = getAreaID(x, y)
	local minDist, minNode
	local nodeX, nodeY, dist
	if db[areaID] and type(db[areaID]) == 'table' then
		for id,node in pairs(db[areaID]) do
			nodeX, nodeY = node.x, node.y
			dist = (x - nodeX)*(x - nodeX) + (y - nodeY)*(y - nodeY)
			if not minDist or dist < minDist then
				minDist = dist
				minNode = node
			end
		end
		return minNode
	end
end

function getAreaID(x, y)
	return floor((math.max(-3000,math.min(y,3000)) + 3000)/750)*8 + floor((math.max(-3000,math.min(x,3000)) + 3000)/750)
end

function getNodeByID(db, nodeID)
	local areaID = floor(nodeID / 65536)
	return (db and db[areaID]) and db[areaID][nodeID]
end
