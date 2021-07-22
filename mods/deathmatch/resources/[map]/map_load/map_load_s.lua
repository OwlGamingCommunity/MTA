--[[
* ***********************************************************************************************************************
* Copyright (c) 2016 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local threads = { }
local threadTimer = nil
local percent = 0
local total

function getMapObjects( map_id )
	local qh = dbQuery( exports.mysql:getConn('mta'), "SELECT * FROM maps_objects WHERE map_id=?", map_id )
	local res, nums, id = dbPoll( qh, 100000 )
	if res then	
		return res
	else
		dbFree( qh )
		outputDebugString("[MAPS] getMapObjects / Failed on ID #"..tostring(map_id) )
	end
end

function loadMap( map_id, mass_load )
	-- if map is loaded, unload it first.
	if isMapLoaded( map_id ) then
		unloadMap( map_id, mass_load )
	end
	loaded_maps[ map_id ] = getMapObjects( map_id )
	if not mass_load then
		updateMapsLoadingQueue()
	end
	return loaded_maps[ map_id ]
end

function isMapLoaded( map_id ) 
	return loaded_maps[ map_id ]
end

function unloadMap( map_id, mass_load )
	loaded_maps[ map_id ] = nil
	if not mass_load then
		updateMapsLoadingQueue()
	end
	return true
end

function unloadAllMaps( )
	loaded_maps = { }
	updateMapsLoadingQueue()
	return true
end

function requestServerMaps( map_id )
	if map_id then
		if isMapLoaded( map_id ) then
			triggerLatentClientEvent( source, 'maps:loadMap', source, loaded_maps[ map_id ], map_id )
		end
	else
		for map_id, map in pairs( loaded_maps ) do
			triggerLatentClientEvent( source, 'maps:loadMap', source, map, map_id )
		end
	end
end
addEvent( 'maps:requestServerMaps', true )
addEventHandler( 'maps:requestServerMaps', root, requestServerMaps )

--[[ alternative approach.
function loadAllMaps()
	local online_players = #getElementsByType( 'player' )
	local qh = dbQuery( exports.mysql:getConn('mta'), "SELECT m.*, (SELECT COUNT(o.id) FROM maps_objects o WHERE o.map_id=m.id) AS object_count FROM maps m WHERE m.approved=1 AND m.enabled=1 ORDER BY object_count" )
	local res, nums, id = dbPoll( qh, 100000 )
	if res and nums > 0 then	
		total = nums
		for _, map in ipairs( res ) do
			local co = coroutine.create( loadMap )
			table.insert( threads, { co, map.id, true } )
		end
		threadTimer = setTimer( resumeThreads, settings.load_speed+(online_players*100), 0 )
		outputDebugString( "[MAPS] Started loading "..total.." mappings. Finish in "..exports.global:formatMoney( ((settings.load_speed+(online_players*100))*total)/1000/settings.load_speed_multipler ).." second(s)" )
		triggerLatentClientEvent( 'hud:loading', resourceRoot, 'Loading maps', { max=total, cur=0 } )
	else
		dbFree( qh )
	end
end
]]

function loadAllMaps()
	local online_players = #getElementsByType( 'player' )
	local qh = dbQuery( exports.mysql:getConn('mta'), "SELECT o.* FROM maps m LEFT JOIN maps_objects o ON m.id=o.map_id WHERE m.approved=1 AND m.enabled=1" )
	local res, nums, id = dbPoll( qh, 100000 )
	if res and nums > 0 then	
		total = nums
		loaded_maps = { }
		for _, obj in ipairs( res ) do
			loaded_maps[ obj.map_id ] = loaded_maps[ obj.map_id ] or { } 
			table.insert( loaded_maps[ obj.map_id ], obj )
		end
		outputDebugString( "[MAPS] Started loading "..total.." mapping objects. Finishing in "..exports.global:formatMoney( ((settings.load_speed+(online_players*100))*total)/1000/settings.load_speed_multipler ).." second(s)" )
		updateMapsLoadingQueue( true )
	else
		dbFree( qh )
	end
end

addEventHandler( 'onResourceStart', resourceRoot, function()
	if settings.startup_enabled then
		setTimer( loadAllMaps, settings.startup_delay, 1 )
	end
end)

function resumeThreads()
	for i, co in ipairs( threads ) do
		coroutine.resume( unpack(co) )
		table.remove( threads, i )

		-- loading 
		local loaded = total-#threads
		local new_perc = math.ceil( loaded/total*100 )
		if percent ~= new_perc then
			percent = new_perc
			triggerLatentClientEvent( 'hud:loading', resourceRoot, 'Loading maps', { max=total, cur=loaded } )
		end

		if i == settings.load_speed_multipler then
			break
		end
	end
	
	if #threads <= 0 then
		killTimer(threadTimer)
		threadTimer = nil
		triggerLatentClientEvent( 'hud:loading', resourceRoot, 'Loading maps', { max=total, cur=total } )
		outputDebugString( "[MAPS] Finished loading "..total.." mappings." )
		updateMapsLoadingQueue()
	end
end

function updateMapsLoadingQueue( forced )
	local q = { }
	for map_id, map_data in pairs( loaded_maps ) do
		if map_data then
			q[ map_id ] = true
		end
	end
	if forced or getElementData( resourceRoot, settings.element_data_name ) ~= q then
		return setElementData( resourceRoot, settings.element_data_name, q, true )
	end
end

