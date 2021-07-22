--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

--[[
Interior types:
TYPE 0: House
TYPE 1: Business
TYPE 2: Government (Unbuyable)
TYPE 3: Rentable
--]]

local threads = { }
local threadTimer = nil
local load_speed = 50
local load_speed_multipler = 100
local load_timeout = 60000 -- 1 minutes.
local percent = 0
local total

local query_load = "SELECT interiors.interior_id, (CASE WHEN lastlogin IS NOT NULL THEN TO_SECONDS(lastlogin) ELSE NULL END) AS owner_last_login, interiors.id AS id, interiors.x AS x, interiors.y AS y, "
					.." interiors.z AS z, interiorwithin, dimensionwithin, angle, interiorx, interiory, interiorz, interior, angleexit, type, disabled, locked, owner, cost, supplies, address, faction, name, "
					.." keypad_lock, keypad_lock_pw, keypad_lock_auto,safepositionX, safepositionY, safepositionZ, safepositionRZ, businessNote, furniture, tokenUsed, TO_SECONDS(lastused) AS lastused_sec, "
					.." (CASE WHEN ((protected_until IS NULL) OR (protected_until > NOW() = 0)) THEN -1 ELSE TO_SECONDS(protected_until) END) AS protected_until FROM `interiors` "
					.." LEFT JOIN `interior_business` ON `interiors`.`id` = `interior_business`.`intID` "
					.." LEFT JOIN characters ON interiors.owner=characters.id "

local function load( res )
	-- prepair
	for _, thePlayer in ipairs( exports.pool:getPoolElementsByType("player") ) do
		exports.anticheat:setEld( thePlayer, "interiormarker", false )
	end
	setInteriorSoundsEnabled ( false )
	threads = { }
	-- ok
	local qh = dbQuery( exports.mysql:getConn('mta'), query_load.." WHERE deleted='0' " )
	local result , num_affected_rows, last_insert_id = dbPoll ( qh, load_timeout )
	if result and num_affected_rows > 0 then
		total = num_affected_rows
		for _, row in ipairs( result ) do
			local co = coroutine.create( loadOne )
			table.insert( threads, { co, row, nil, true } )
		end
		threadTimer = setTimer( resumeThreads, load_speed, 0 )
		outputDebugString( "[INTERIOR] Started loading "..num_affected_rows.." interiors. Finish in "..exports.global:formatMoney( (load_speed*num_affected_rows)/1000/load_speed_multipler ).." second(s)" )
		triggerLatentClientEvent( 'hud:loading', resourceRoot, 'Loading interiors', { max=total, cur=0 } )
	end
end
addEventHandler( 'onResourceStart', resourceRoot, load )

function resumeThreads()
	for i, co in ipairs( threads ) do
		coroutine.resume( unpack(co) )
		table.remove( threads, i )

		-- loading
		local loaded = total-#threads
		local new_perc = math.ceil( loaded/total*100 )
		if percent ~= new_perc then
			percent = new_perc
			triggerLatentClientEvent( 'hud:loading', resourceRoot, 'Loading interiors', { max=total, cur=loaded } )
		end

		if i == load_speed_multipler then
			break
		end
	end

	if #threads <= 0 then
		killTimer(threadTimer)
		triggerLatentClientEvent( 'hud:loading', resourceRoot, 'Loading interiors', { max=total, cur=total } )
		setTimer( triggerLatentClientEvent, 50000, 1, 'interior:initializeSoFar', resourceRoot, true )
	end
end

function loadOne( data, updatePlayers, massLoad )
	-- mass load
	if type(data) == 'table' then
		-- making sure interior won't be spawned twice.
		local element = exports.pool:getElement( 'interior', data.id )
		if element then
			if isElement( element ) then
				destroyElement( element )
			end
			element = nil
		end

		-- create interior element and allocate in pool.
		element = createElement( 'interior', 'int'..data.id )
		exports.anticheat:setEld(element, "dbid", data.id, 'all' )
		exports.pool:allocateElement( element, data.id, true )

		-- for preview and other purposes.
		if data.interior_id then
			exports.anticheat:setEld( element, 'interior_id', data.interior_id, 'all' )
		end

		-- set entrance.
		exports.anticheat:setEld( element, "entrance", { x=data.x, y=data.y, z=data.z, int=data.interiorwithin, dim=data.dimensionwithin, rot=data.angle, fee=0 }, 'all' )
		setElementPosition( element , data.x, data.y, data.z )
		setElementInterior( element, data.interiorwithin )
		setElementDimension( element, data.dimensionwithin )

		-- set exit
		exports.anticheat:setEld( element, "exit", { x=data.interiorx, y=data.interiory, z=data.interiorz, int=data.interior, dim=data.id, rot=data.angleexit, fee=0 }, 'all' )
		exports.anticheat:setEld( element, "status", { type=data.type, disabled=data.disabled == 1, locked=data.locked==1, owner=data.owner, cost=data.cost, supplies=data.supplies, faction=data.faction, furniture=data.furniture == 1, tokenUsed=data.tokenUsed == 1 }, 'all' )
		exports.anticheat:setEld( element, "name", data.name, 'all' )
		exports.anticheat:setEld( element, "address", data.address, 'all' ) --MS: Create and set elementData for Address from DB value

		--inactivity
		if data.owner > 0 and data.protected_until ~= -1 then
			exports.anticheat:setEld( element, "protected_until", tonumber(data.protected_until), 'all' )
		end
		if data.lastused_sec then
			exports.anticheat:setEld( element, "lastused", tonumber(data.lastused_sec), 'all' )
		end
		if data.owner_last_login then
			exports.anticheat:setEld( element, "owner_last_login", tonumber(data.owner_last_login), 'all' )
		end

		--keyless door lock
		if data.keypad_lock and data.type ~= 2 and data.owner and data.owner > 0 then
			setElementData( element, "keypad_lock", data.keypad_lock, true )
			if data.keypad_lock_pw then
				setElementData( element, "keypad_lock_pw", data.keypad_lock_pw, true )
			end
			if data.keypad_lock_auto then
				setElementData( element, "keypad_lock_auto", data.keypad_lock_auto == 1, true )
			end
		end

		-- safe
		if data.safepositionX then
			exports.interior_system:addSafe( data.id, nil, { data.safepositionX, data.safepositionY, data.safepositionZ }, data.interior, data.safepositionRZ, false, true )
		end

		-- business notes.
		if data.businessNote then
			exports.anticheat:setEld( element, "business:note", data.businessNote , 'all' )
		end

		-- draw owner's blips.
		if updatePlayers then
			if isElement(updatePlayers[2]) then
				if isElement(updatePlayers[1]) then
					triggerLatentClientEvent( updatePlayers[1], 'drawAllMyInteriorBlips', updatePlayers[2] )
				end
				triggerLatentClientEvent( updatePlayers[2], 'drawAllMyInteriorBlips', updatePlayers[2] )
			end
		end

		-- loading and streaming interior markers.
		if not massLoad then
			triggerLatentClientEvent( 'interior:schedulePickupLoading', resourceRoot, element )
		end

		--settings
		local settings
		if data.settings then
			settings = fromJSON(data.settings)
		else
			settings = {}
		end
		exports.anticheat:setEld(veh, "settings", settings or {}, false)

		return true
	-- load one.
	elseif tonumber(data) then
		dbQuery( function( qh, updatePlayers )
			local result , num_affected_rows, last_insert_id = dbPoll ( qh, 0 )
			if result then
				loadOne( result[1], updatePlayers )
			end
		end, { updatePlayers }, exports.mysql:getConn('mta'), query_load.." WHERE interiors.id=? "..( loadDeletedOne and "" or " AND deleted=0 " ), data )
	end
end

function unload( int )
	int = isElement(int) and int or exports.pool:getElement( 'interior', int )
	if int then
		exports.interior_system:clearSafe( getElementData( int, 'dbid' ) or 0 )
		destroyElement( int )
	end
end

addEventHandler( 'onResourceStop', resourceRoot, function ()
	triggerEvent( 'interior:clearAllSafes', resourceRoot )
end )