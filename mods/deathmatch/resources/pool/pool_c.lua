--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

addEventHandler('onClientElementStreamIn', root, function ()
	local type = getElementType(source)
	local id = idelementdata[ type ]
	allocateElement( source , id and getElementData(source, id), true )
end)

addEventHandler('onClientElementDestroy', root, function ()
	deallocateElement(source)
end)

addEventHandler('onClientElementStreamOut', root, function ()
	deallocateElement(source)
end)

function showsize( cmd, type)
	if not exports.integration:isPlayerScripter(localPlayer) then
		return false
	end
	if type then
		if not isValidType(type) then
			return outputChatBox("Invalid element type.", localPlayer)
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
	
	outputChatBox("------CLIENT POOLED ELEMENTS------")
	outputChatBox("PLAYERS: " .. tostring(players) .. " ("..tostring(playersByDbid)..") /" .. tostring(tplayers))
	outputChatBox("INTERIORS: " .. tostring(interiors) .. "/" .. tostring(tinteriors))
	outputChatBox("ELEVATORS: " .. tostring(elevators) .. "/" .. tostring(televators))
	outputChatBox("VEHICLES: " .. tostring(vehicles) .. "/" .. tostring(tvehicles))
	outputChatBox("COLSHAPES: " .. tostring(colshapes) .. "/" .. tostring(tcolshapes))
	outputChatBox("PEDS: " .. tostring(peds) .. "/" .. tostring(tpeds))
	outputChatBox("MARKERS: " .. tostring(markers) .. "/" .. tostring(tmarkers))
	outputChatBox("OBJECTS: " .. tostring(objects) .. "/" .. tostring(tobjects))
	outputChatBox("PICKUPS: " .. tostring(pickups) .. "/" .. tostring(tpickups))
	outputChatBox("TEAMS: " .. tostring(teams) .. "/" .. tostring(tteams))
	outputChatBox("BLIPS: " .. tostring(blips) .. "/" .. tostring(tblips))

end
addCommandHandler("poolsize", showsize)