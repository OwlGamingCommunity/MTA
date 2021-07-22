--[[
* ***********************************************************************************************************************
* Copyright (c) 2016 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local loaded = { removals = { }, objects = { }, blips = { } }

function loadOneObject( obj, loaded, is_test )
	if obj.radius then -- world object removal
		if removeWorldModel ( obj.model, obj.radius, obj.posX, obj.posY, obj.posZ , obj.interior ) then
			if obj.lodModel and tonumber( obj.lodModel ) and obj.lodModel ~= obj.model then
				if removeWorldModel ( obj.lodModel, obj.radius, obj.posX, obj.posY, obj.posZ , obj.interior ) then
					table.insert( loaded.removals, { obj.lodModel, obj.radius, obj.posX, obj.posY, obj.posZ , obj.interior } )
				end
			end
			table.insert( loaded.removals, { obj.model, obj.radius, obj.posX, obj.posY, obj.posZ , obj.interior } )
			if is_test then
				local blip = createBlip ( obj.posX, obj.posY, obj.posZ, 0, 1 )
				if blip then
					table.insert( loaded.blips, blip )
				end
			end
		end
	else
		local created_object = createObject ( obj.model, obj.posX, obj.posY, obj.posZ , obj.rotX, obj.rotY, obj.rotZ )
		if created_object then
			setElementInterior( created_object, obj.interior )
			setElementDimension( created_object, obj.dimension )
			setObjectBreakable( created_object, obj.breakable == 1 )
			setElementCollisionsEnabled ( created_object, obj.collisions ~= 0 )
			if obj.scale and tonumber( obj.scale ) then
				setObjectScale( created_object, obj.scale )
			end
			setElementDoubleSided ( created_object, obj.doublesided == 1 )
			if obj.alpha and tonumber( obj.alpha ) then
				setElementAlpha ( created_object, obj.alpha )
			end
			table.insert( loaded.objects, created_object )
			if is_test then
				local blip = createBlip ( obj.posX, obj.posY, obj.posZ, 0, 1 )
				if blip then
					if obj.interior and obj.interior ~= 0 then
						setElementInterior( blip )
					end
					if obj.dimension and obj.dimension ~= 0 then
						setElementDimension( blip )
					end
					table.insert( loaded.blips, blip )
				end
			end
		end
	end
end

function loadMap( contents, map_id, is_test )
	loaded = { removals = { }, objects = { }, blips = { } }
	
	-- if map is loaded, unload it first.
	if isMapLoaded( map_id ) then
		unloadMap( map_id )
	end
	-- then load it again.
	if contents then
		for _, obj in pairs( contents ) do
			loadOneObject( obj, loaded, is_test )
		end
	end
	loaded_maps[ map_id ] = loaded
	return loaded
end
addEvent( 'maps:loadMap', true )
addEventHandler( 'maps:loadMap', root, loadMap )

function unloadMap( map_id )
	local result = { objects = 0, removals = 0, blips = 0 }
	local loaded_map = isMapLoaded( map_id )
	if loaded_map then
		-- destroy all loaded map objects.
		for index, obj in pairs( loaded_map.objects ) do
			if destroyElement( obj ) then
				result.objects = result.objects + 1
			end
		end
		-- restore all removed world models.
		for index, obj in pairs( loaded_map.removals ) do
			if restoreWorldModel( unpack( obj ) ) then
				result.removals = result.removals + 1
			end
		end
		-- destroy all blips if any.
		for index, blip in pairs( loaded_map.blips ) do
			if destroyElement( blip ) then
				result.blips = result.blips + 1
			end
		end
		loaded_maps[ map_id ] = nil
	end
	return result
end
addEvent( 'maps:unloadMap', true )
addEventHandler( 'maps:unloadMap', root, unloadMap )
	
function isMapLoaded( map_id, is_temp ) 
	if loaded_maps[ map_id ] then
		if is_temp then
			return #loaded_maps[ map_id ].blips > 0 and loaded_maps[ map_id ] or false
		else
			return loaded_maps[ map_id ]
		end
	else
		return false
	end
end

function unloadAllMaps( is_test )
	local result = { }
	for map_id, map in pairs( loaded_maps ) do
		local res = { objects = 0, removals = 0, blips = 0 }
		if is_test then -- only unload testing maps.
			if #map.blips > 0 then -- is a testing map.
				res = unloadMap( map_id )
			end
		else
			res = unloadMap( map_id )
		end
		if res.objects > 0 or res.removals > 0 or res.blips > 0 then
			table.insert( result, res )
		end
	end
	return result
end

function requestServerMaps()
	triggerServerEvent( 'maps:requestServerMaps', localPlayer )
end
addEvent( 'maps:requestServerMaps', true )
addEventHandler( 'maps:requestServerMaps', root, requestServerMaps)

addCommandHandler('loadmaps', function()
	requestServerMaps()
end)

addEventHandler ( "onClientElementDataChange", resourceRoot,
function ( dataName, oldValue )
	if dataName == settings.element_data_name then
		local queue = getElementData( resourceRoot, settings.element_data_name )
		if queue and queue ~= oldValue then
			syncMaps()
		end
	end
end)

function syncMaps()
	local synced_maps = getElementData( resourceRoot, settings.element_data_name )
	if synced_maps then
		-- unload maps first.
		for map_id, _ in pairs( loaded_maps ) do
			if not synced_maps[ map_id ] and isMapLoaded( map_id ) then
				unloadMap( map_id )
			end
		end
		-- load map.
		for map_id, _ in pairs( synced_maps ) do
			if not isMapLoaded( map_id ) then
				triggerLatentServerEvent( 'maps:requestServerMaps', localPlayer, map_id )
			end
		end
	end
end
addEventHandler( 'onClientResourceStart', resourceRoot, syncMaps )
addEventHandler( 'onClientResourceStop', resourceRoot, function() unloadAllMaps(false) end )
