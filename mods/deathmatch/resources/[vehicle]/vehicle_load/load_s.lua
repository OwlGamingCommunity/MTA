--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local mysql = exports.mysql
local threads = {}
local threadTimer = nil
local load_speed = 50
local load_speed_multipler = 10
local load_timeout = 60000 -- 1 minutes.
local total

local query_load = "SELECT v.*, (CASE WHEN ((protected_until IS NULL) OR (protected_until > NOW() = 0)) THEN -1 ELSE TO_SECONDS(protected_until) END) AS protected_until, "
			.."TO_SECONDS(lastUsed) AS lastused_sec, (CASE WHEN lastlogin IS NOT NULL THEN TO_SECONDS(lastlogin) ELSE NULL END) AS owner_last_login, "
			.."l.faction AS impounder, "
			.."i.premium, i.insurancefaction "
			.."FROM vehicles v "
			.."LEFT JOIN characters c ON v.owner=c.id "
			.."LEFT JOIN leo_impound_lot l ON v.id=l.veh "
			.."LEFT JOIN insurance_data i ON v.id=i.vehicleid "

function load( res )
	-- Reset player in vehicle states
	for key, value in ipairs( getElementsByType('player') ) do
		exports.anticheat:setEld( value, "realinvehicle", 0 )
	end
	threads = { }
	-- ok
	local qh = dbQuery( exports.mysql:getConn('mta'), query_load.." WHERE v.deleted=0" )
	local result , num_affected_rows, last_insert_id = dbPoll ( qh, load_timeout )
	if result and num_affected_rows > 0 then
		total = num_affected_rows
		for _, row in ipairs( result ) do
			local co = coroutine.create( loadOneVehicle )
			table.insert( threads, { co, row } )
		end
		threadTimer = setTimer( resumeThreads, load_speed, 0 )
		outputDebugString( "[VEHICLE] Started loading "..num_affected_rows.." vehicles. Finish in "..exports.global:formatMoney( (load_speed*num_affected_rows)/1000/load_speed_multipler ).." second(s)" )
		triggerLatentClientEvent( 'hud:loading', resourceRoot, 'Loading vehicles', { max=total, cur=0 } )
	end
end
addEventHandler( 'onResourceStart', resourceRoot, load )

local percent = 0
function resumeThreads()
	for i, co in ipairs( threads ) do
		coroutine.resume( unpack(co) )
		table.remove( threads, i )

		-- loading
		local loaded = total-#threads
		local new_perc = math.ceil( loaded/total*100 )
		if percent ~= new_perc then
			percent = new_perc
			triggerLatentClientEvent( 'hud:loading', resourceRoot, 'Loading vehicles', { max=total, cur=loaded } )
		end

		if i == load_speed_multipler then
			break
		end
	end

	if #threads <= 0 then
		killTimer(threadTimer)
		triggerLatentClientEvent( 'hud:loading', resourceRoot, 'Loading vehicles', { max=total, cur=total } )
	end
end

function loadOneVehicle(data, loadDeletedOne)
	-- mass load
	if type(data) == 'table' then
		-- making sure vehicle won't be spawned twice.
		local veh = exports.pool:getElement( 'vehicle', data.id )
		if veh then
			if isElement( veh ) then
				destroyElement( veh )
			end
			veh = nil
		end

		-- Valid vehicle variant?
		local var1, var2 = data.variant1, data.variant2
		if not exports.vehicle:isValidVariant( data.model, var1, var2 ) then
			var1, var2 = exports.vehicle:getRandomVariant( data.model )
			dbExec( exports.mysql:getConn('mta'), "UPDATE vehicles SET variant1 = " .. var1 .. ", variant2 = " .. var2 .. " WHERE id='" .. mysql:escape_string(data.id) .. "'")
		end

		-- Spawn the vehicle
		veh = createVehicle(data.model, data.currx, data.curry, data.currz, data.currrx, data.currry, data.currrz, data.plate, false, var1, var2)
		if veh then
			-- pool allocation.
			exports.anticheat:setEld( veh, "dbid", data.id, 'all' )
			exports.pool:allocateElement( veh, data.id )

			-- disable tank explodable
			setVehicleFuelTankExplodable( veh, false )

			-- color and paintjob.
			if data.paintjob ~= 0 then
				setVehiclePaintjob( veh, data.paintjob )
			end

			-- texture.
			if data.paintjob_url then
				exports.anticheat:setEld(veh, "paintjob:url", data.paintjob_url, 'all' )
			end

			-- color
			local color1 = fromJSON(data.color1)
			local color2 = fromJSON(data.color2)
			local color3 = fromJSON(data.color3)
			local color4 = fromJSON(data.color4)
			setVehicleColor( veh, color1[1], color1[2], color1[3], color2[1], color2[2], color2[3], color3[1], color3[2], color3[3], color4[1], color4[2], color4[3] )

			-- set the vehicle armored if it is armored
			if exports.vehicle:getArmoredCars()[ data.model ] then
				setVehicleDamageProof( veh, true )
			end

			-- upgrades.
			for slot, upgrade in ipairs( fromJSON( data.upgrades ) ) do
				if upgrade and tonumber(upgrade) > 0 then
					addVehicleUpgrade( veh, upgrade )
				end
			end

			-- panels
			for panel, state in ipairs( fromJSON( data.panelStates ) ) do
				setVehiclePanelState( veh, panel-1 , tonumber(state) or 0 )
			end

			-- doors
			for door, state in ipairs( fromJSON( data.doorStates ) ) do
				setVehicleDoorState( veh, door-1, tonumber(state) or 0 )
			end

			-- lights
			local lights = fromJSON( data.headlights )
			if lights then
				setVehicleHeadLightColor ( veh, lights[1], lights[2], lights[3] )
			end
			exports.anticheat:setEld( veh, "headlightcolors", lights, 'all' )

			-- wheels
			local wheels = fromJSON( data.wheelStates )
			if wheels then
				setVehicleWheelStates( veh, tonumber(wheels[1]) , tonumber(wheels[2]) , tonumber( wheels[3]) , tonumber(wheels[4]) )
			end

			-- lock the vehicle if it's locked
			setVehicleLocked( veh, data.owner ~= -1 and data.locked == 1 )

			-- set the sirens on if it has some
			setVehicleSirensOn( veh, data.sirens == 1 )

			-- now element data and whatnot.
			-- job
			if data.job > 0 then
				toggleVehicleRespawn(veh, true)
				setVehicleRespawnDelay(veh, 60000)
				setVehicleIdleRespawnDelay(veh, 15 * 60000)
				exports.anticheat:setEld(veh, "job", data.job, 'all' )
			else
				exports.anticheat:setEld(veh, "job", 0, 'all' )
			end

			setVehicleRespawnPosition(veh, data.x, data.y, data.z, data.rotx, data.roty, data.rotz)
			exports.anticheat:setEld(veh, "respawnposition", {data.x, data.y, data.z, data.rotx, data.roty, data.rotz} )

			-- element data
			exports.anticheat:setEld( veh, "vehicle_shop_id", data.vehicle_shop_id, 'all' )
			exports.anticheat:setEld( veh, "fuel", data.fuel )
			exports.anticheat:setEld( veh, "faction", data.faction, 'all' )
			exports.anticheat:setEld( veh, "owner", data.owner, 'all' )
			exports.anticheat:setEld( veh, "vehicle:windowstat", 0, 'all' )
			exports.anticheat:setEld( veh, "plate", data.plate, 'all' )
			exports.anticheat:setEld( veh, "registered", data.registered, 'all' )
			exports.anticheat:setEld( veh, "show_plate", data.show_plate, 'all' )
			exports.anticheat:setEld( veh, "show_vin", data.show_vin, 'all' )
			exports.anticheat:setEld( veh, "description:1", data.description1, 'all' )
			exports.anticheat:setEld( veh, "description:2", data.description2, 'all' )
			exports.anticheat:setEld( veh, "description:3", data.description3, 'all' )
			exports.anticheat:setEld( veh, "description:4", data.description4, 'all' )
			exports.anticheat:setEld( veh, "description:5", data.description5, 'all' )
			exports.anticheat:setEld( veh, "description:admin", data.descriptionadmin, 'all' )
			exports.anticheat:setEld( veh, "token", data.tokenUsed == 1, 'all' )
			exports.anticheat:setEld( veh, "hotwired", (data.hotwired == 1 and true or false), 'all')

			if data.lastused_sec ~= mysql_null() then
				exports.anticheat:setEld( veh, "lastused", data.lastused_sec, 'all' )
			end

			--outputDebugString(tostring(data.owner_last_login))
			if data.owner_last_login ~= mysql_null() then
				exports.anticheat:setEld( veh, "owner_last_login", data.owner_last_login, 'all' )
			end

			if data.owner > 0 and data.protected_until ~= -1 then
				exports.anticheat:setEld( veh, "protected_until", data.protected_until, 'all' )
			end

			local customTextures = fromJSON(data.textures) or {}
			exports.anticheat:setEld( veh, "textures", customTextures, 'all' )

			exports.anticheat:setEld( veh, "deleted", data.deleted, 'all' )
			exports.anticheat:setEld( veh, "chopped", data.chopped, 'all' )
			--exports.anticheat:setEld(veh, "note", data.note, true)

			-- impound shizzle
			exports.anticheat:setEld( veh, "Impounded", tonumber(data.Impounded), 'all' )
			if tonumber(data.Impounded) > 0 then
				setVehicleDamageProof(veh, true)
				if data.impounder then
					--outputDebugString("set")
					exports.anticheat:setEld( veh, "impounder", data.impounder )
				else
					exports.anticheat:setEld( veh, "impounder", 4 ) --RT
				end
			end

			-- insurance stuff
			if exports.global:isResourceRunning("insurance") then
        		exports.anticheat:setEld( veh, "insurance:fee", data.premium or 0 )
        		exports.anticheat:setEld( veh, "insurance:faction", data.insurancefaction or 0 )
            end

			setElementDimension(veh, data.currdimension)
			setElementInterior(veh, data.currinterior)

			exports.anticheat:setEld( veh, "dimension", data.dimension )
			exports.anticheat:setEld( veh, "interior", data.interior )

			-- lights
			setVehicleOverrideLights(veh, data.lights == 0 and 1 or data.lights )

			-- engine
			if data.hp <= 350 then
				setElementHealth( veh, 300 )
				setVehicleDamageProof( veh, true )
				setVehicleEngineState( veh, false )
				exports.anticheat:setEld( veh, "engine", 0 )
				exports.anticheat:setEld( veh, "enginebroke", 1 )
			else
				setElementHealth( veh, data.hp )
				setVehicleEngineState( veh, data.engine == 1)
				exports.anticheat:setEld( veh, "engine", data.engine )
				exports.anticheat:setEld( veh, "enginebroke", 0 )
			end


			-- handbrake
			setElementFrozen( veh, false )
			exports.anticheat:setEld( veh, "handbrake", data.handbrake )
			if data.handbrake > 0 then
				setElementFrozen( veh, true )
			end

			local hasInterior, interior = exports['vehicle-interiors']:add( veh )
			if hasInterior and data.safepositionX and data.safepositionY and data.safepositionZ and data.safepositionRZ then
				exports.vehicle:addSafe( data.id, data.safepositionX, data.safepositionY, data.safepositionZ, data.safepositionRZ, interior )
			end

			if data.bulletproof == 1 then
				exports.anticheat:setEld( veh, "bulletproof", data.bulletproof )
				setVehicleDamageProof(veh, true)
			end

			if data.tintedwindows == 1 then
				exports.anticheat:setEld(veh, "tinted", true, 'all' )
			end
			exports.anticheat:setEld(veh, "odometer", tonumber(data.odometer) )

			-- texture.
			if #customTextures > 0 and exports.global:isResourceRunning( 'item-texture' ) then
				for somenumber, texture in ipairs( customTextures ) do
					exports['item-texture']:addTexture(veh, texture[1], texture[2] )
				end
			end

			-- custom handlings
			if getResourceFromName ( "vehicle_manager" ) then
				exports.vehicle_manager:loadCustomVehProperties( veh )
			end

			--settings
			local settings
			if data.settings then
				settings = fromJSON(data.settings)
			else
				settings = {}
			end
			exports.anticheat:setEld(veh, "settings", settings or {}, false)
		end
	-- load one.
	elseif tonumber(data) then
		dbQuery( function( qh )
			local result , num_affected_rows, last_insert_id = dbPoll ( qh, 0 )
			if result then
				loadOneVehicle( result[1] )
			end
		end, { }, exports.mysql:getConn('mta'), query_load.." WHERE v.id=? "..( loadDeletedOne and "" or " AND deleted=0 " ), data )
	end
end
