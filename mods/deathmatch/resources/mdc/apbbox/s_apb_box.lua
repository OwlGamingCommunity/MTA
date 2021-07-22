--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local apbDrawn = {}

local function getFactionType( vehicle )
	local vehicleFactionID = getElementData(vehicle, "faction")
	local faction = exports.pool:getElement("team", vehicleFactionID)
	if faction then
		return getElementData( faction, "type" ), vehicleFactionID
	end
end

local function getLatestApb( )
	-- prepare 'max' latest APB to send to client.
	local max = 5
	local latests = {}
	local count = 0
	for i = #apb, 1, -1 do -- Loop the apb table backward.
		count = count + 1
		if count <= max then
			table.insert( latests, apb[ i ] )
		else
			break
		end
	end
	return latests
end

function sendApbToClient( player, data )
	triggerLatentClientEvent( player, "drawAPB", resourceRoot, data )
end

function updateClientAPB()
	local data = getLatestApb( )
	for index, player in pairs( apbDrawn ) do
		if player and isElement( player ) and getElementType( player ) == 'player' then
			sendApbToClient( player, data )
		else
			RemovePlayerFromTable( player )
		end
	end
end

function RemovePlayerFromTable( player )
	apbDrawn[ client or player ] = nil
	--outputDebugString( "[MDC] RemovePlayerFromTable / "..getPlayerName(client or player) )
end
addEvent("RemovePlayerFromTableEvent", true)
addEventHandler("RemovePlayerFromTableEvent", resourceRoot, RemovePlayerFromTable)

function ShowListCheck(thePlayer, seat)
	if (seat == 0) or (seat == 1) then
		local ftype, fid = getFactionType( source )
		if ftype == 2 or exports.global:hasItem( source, 143 ) then
			--outputDebugString( "[MDC] ShowListCheck / "..getPlayerName(thePlayer) )
			apbDrawn[ thePlayer ] = thePlayer
			sendApbToClient( thePlayer, getLatestApb( ) )
		end
	end
end
addEventHandler("onVehicleEnter", root, ShowListCheck)

-- save the player list before resource stops.
addEventHandler( 'onResourceStop', resourceRoot, function()
	exports.data:save( apbDrawn, 'apbDrawn' )
end)

-- load the player list (if any) after resource start.
addEventHandler( 'onResourceStart', resourceRoot, function()
	local data = exports.data:load( 'apbDrawn' )
	if data then 
		apbDrawn = data
	end
	-- you may also want to do that again so they don't have to re-enter their car everytime you restart the resource.
	updateClientAPB()
end)