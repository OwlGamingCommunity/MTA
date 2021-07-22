--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

function showsize(thePlayer, cmd, type)
	if not exports.integration:isPlayerScripter(thePlayer) then
		return false
	end
	if type then
		if not isValidType(type) then
			return outputChatBox("Invalid element type.", thePlayer)
		end
	end
	local players = #poolTable["player"]
	local playersByDbid = #poolTable["playerByDbid"]
	local interiors = #poolTable["interior"]
	local elevators = #poolTable["elevator"]
	local vehicles = #poolTable["vehicle"]
	local colshapes = #poolTable["colshape"]
	local peds = #poolTable["ped"]
	local markers = #poolTable["marker"]
	local objects = #poolTable["object"]
	local pickups = #poolTable["pickup"]
	local teams = #poolTable["team"]
	local blips = #poolTable["blip"]
	
	local tplayers = #getElementsByType("player")
	local tinteriors = #getElementsByType("interior")
	local televators = #getElementsByType("elevator")
	local tvehicles = #getElementsByType("vehicle")
	local tcolshapes = #getElementsByType("colshape")
	local tpeds = #getElementsByType("ped")
	local tmarkers = #getElementsByType("marker")
	local tobjects = #getElementsByType("object")
	local tpickups = #getElementsByType("pickup")
	local tteams = #getElementsByType("team")
	local tblips = #getElementsByType("blip")
	
	outputChatBox("------POOLED ELEMENTS------", thePlayer)
	outputChatBox("PLAYERS: " .. tostring(players) .. " ("..tostring(playersByDbid)..") /" .. tostring(tplayers), thePlayer)
	outputChatBox("INTERIORS: " .. tostring(interiors) .. "/" .. tostring(tinteriors), thePlayer)
	outputChatBox("ELEVATORS: " .. tostring(elevators) .. "/" .. tostring(televators), thePlayer)
	outputChatBox("VEHICLES: " .. tostring(vehicles) .. "/" .. tostring(tvehicles), thePlayer)
	outputChatBox("COLSHAPES: " .. tostring(colshapes) .. "/" .. tostring(tcolshapes), thePlayer)
	outputChatBox("PEDS: " .. tostring(peds) .. "/" .. tostring(tpeds), thePlayer)
	outputChatBox("MARKERS: " .. tostring(markers) .. "/" .. tostring(tmarkers), thePlayer)
	outputChatBox("OBJECTS: " .. tostring(objects) .. "/" .. tostring(tobjects), thePlayer)
	outputChatBox("PICKUPS: " .. tostring(pickups) .. "/" .. tostring(tpickups), thePlayer)
	outputChatBox("TEAMS: " .. tostring(teams) .. "/" .. tostring(tteams), thePlayer)
	outputChatBox("BLIPS: " .. tostring(blips) .. "/" .. tostring(tblips), thePlayer)

	if type == "player" then
		local count = 0
		for id, player in pairs(indexedPools["player"]) do
			local playerName = "<Not an element>"
			if player and isElement(player) then
				playerName = getPlayerName(player)
			end
			outputChatBox(id.." - "..playerName, thePlayer)
			count = count + 1
		end
		outputChatBox("indexedPools: "..count.. " / poolTable: "..(players).." / Actual: "..tplayers, thePlayer)
	elseif type == "playerByDbid" then
		local count = 0
		for id, player in pairs(indexedPools["playerByDbid"]) do
			local playerName = "<Not an element>"
			if player and isElement(player) then
				playerName = getPlayerName(player)
			end
			outputChatBox(id.." - "..playerName, thePlayer)
			count = count + 1
		end
		outputChatBox("indexedPools: "..count.. " / poolTable: "..(playersByDbid).." / Actual: "..tplayers, thePlayer)
	end
end
addCommandHandler("poolsize", showsize)

addEventHandler("onResourceStop", resourceRoot, function ()
	exports.data:save(poolTable, "poolTable")
	exports.data:save(indexedPools, "indexedPools")
end)

addEventHandler("onResourceStart", resourceRoot, function() 
	local loaded = exports.data:load("poolTable")
	if loaded then
		poolTable = loaded
	end
	loaded = exports.data:load("indexedPools")
	if loaded then
		indexedPools = loaded
	end

	if not indexedPools['playerByDbid'] then
		indexedPools['playerByDbid'] = {}
	end

	if not poolTable['playerByDbid'] then
		poolTable['playerByDbid'] = {}
	end

	if not indexedPools["ped"] then
		indexedPools["ped"] = {}
	end
	--setTimer(restartResource, 3000, 1, getResourceFromName("id-system")) --Restart id-system 3 seconds after pool starts because it looks like id-system get fucked everytime pool restarts (not 100% sure) / maxime / 2015.4.13
end)

addEventHandler("onPlayerJoin", getRootElement(),
	function ()
		allocateElement(source)
	end
)

addEventHandler("onPlayerQuit", getRootElement(),
	function ()
		deallocateElement(source)
		deallocatePlayerElementByDbid(source)
	end
)

addEventHandler("onElementDestroy", getRootElement(),
	function ()
		deallocateElement(source)
	end
)

function deallocatePlayerElementByDbid(element)
	local elementType = "playerByDbid"
	local i = 0
	for k = #poolTable[elementType], 1, -1 do
		if not poolTable[elementType][k] or not isElement(poolTable[elementType][k]) or poolTable[elementType][k] == element then
			table.remove(poolTable[elementType], k)
		end
	end
	
	if indexedPools[elementType] then
		local id = nil
		if element and isElement(element) then
			id = tonumber(getElementData(element, idelementdata[elementType]))
		end
		if id and id > 0 and indexedPools[elementType][id] then
			indexedPools[elementType][id] = nil
		else
			for k, v in pairs(indexedPools[elementType]) do
				if v == element or not v or not isElement(v) then
					indexedPools[elementType][k] = nil
				end
			end
		end
	end
end

function scanPlayerElementByDbid(dataName,oldValue) --Maxime / 2015.4.12
	if dataName == "dbid" and getElementType(source) == "player" then -- check if the element is a player and element data is dbid/charid
		local newValue = getElementData(source,dataName) -- find the new value
		deallocatePlayerElementByDbid(source)
		if newValue and tonumber(newValue) and newValue > 0 then
			table.insert (poolTable["playerByDbid"], source)
			if indexedPools["playerByDbid"] then
				indexedPools["playerByDbid"][tonumber(newValue)] = source
			end
		end
	end
end
addEventHandler("onElementDataChange",getRootElement(),scanPlayerElementByDbid)

function reallocatePlayerElementPools(player, c)
	if not exports.integration:isPlayerScripter(player) then
		return
	end
 
	local a = 0
	local b = 0
	poolTable["player"] = {}
	indexedPools["player"] = {}
	poolTable["playerByDbid"] = {}
	indexedPools["playerByDbid"] = {}
	for i, p in pairs(getElementsByType("player")) do
		allocateElement(p)
		a = a + 1
		local newValue = getElementData(p,"dbid")
		if newValue and tonumber(newValue) and newValue > 0 then
			table.insert (poolTable["playerByDbid"], p)
			if indexedPools["playerByDbid"] then
				indexedPools["playerByDbid"][tonumber(newValue)] = p
			end
			b = b + 1
		end
	end
	outputChatBox("Reallocated "..a.." playerid elements and "..b.." playerByDbid elements.", player)
end
addCommandHandler("reallocatePlayerElementPools", reallocatePlayerElementPools, false)
