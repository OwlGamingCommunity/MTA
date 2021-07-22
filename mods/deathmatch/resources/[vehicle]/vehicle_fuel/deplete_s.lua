--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

-- configurations
local depleting_rate = nil -- milliseconds, the higher this value is, the slower fuel is depleted.
local depleting_rate_empty = 15 -- multiplier, this effects how frequently emptied vehicles are being updated, doesn't effects depleting speed, 15 means update them 15 times slower than for vehs with driver inside.
local depleting_battery_unit = 0.1 -- the greater this value is, the faster battery will be depleted/recovered.
local deplete_concurrents = {  -- how many processes to run per thread.
	[1] = 1, -- vehicles with player inside.
	[2] = 10, -- empty vehicles.
} 

-- variable defintions.
fuellessVehicle = { [594]=true, [537]=true, [538]=true, [569]=true, [590]=true, [606]=true, [607]=true, [610]=true, [590]=true, [569]=true, [611]=true, [584]=true, [608]=true, [435]=true, [450]=true, [591]=true, [472]=true, [473]=true, [493]=true, [595]=true, [484]=true, [430]=true, [453]=true, [452]=true, [446]=true, [454]=true, [497]=true, [509]=true, [510]=true, [481]=true }
bikes = { [448]=true, [461]=true, [462]=true, [463]=true, [468]=true, [471]=true, [521]=true, [522]=true, [581]=true, [586]=true }
sportscar = { [402]=true, [411]=true, [415]=true, [429]=true, [451]=true, [477]=true, [494]=true, [502]=true, [503]=true, [506]=true, [541]=true, [559]=true, [560]=true, [587]=true, [603]=true, [602]=true }
lowclasscar = { [400]=true, [401]=true, [404]=true }
mediumclasscar = { }
highclasscar = { }
FUEL_PRICE = 2.2

local vehs = { }
local threads = { 
	[1] = { },
	[2] = { },
}
local threadTimer = { }
local resumeThreads = { }

local function updateDepletingRate()
	depleting_rate = math.max( #getElementsByType('player')*50, 10000 )
end
updateDepletingRate()

function syncFuelOnEnter(thePlayer)
	triggerClientEvent( thePlayer, "syncFuel", source, getElementData(source, "fuel") or 0, getElementData(source, "battery") or 100 )
end
addEventHandler("onVehicleEnter", getRootElement(), syncFuelOnEnter)
addEvent( 'fuel:sync', false )
addEventHandler( 'fuel:sync', root, syncFuelOnEnter )

function getFuelLoss( veh )
	if getVehicleEngineState( veh ) and ( getElementData( veh, "fuel" ) or 0 ) > 0 and not fuellessVehicle[ getElementModel( veh ) ] then
		local int = getElementInterior( veh )
		local dim = getElementDimension( veh )
		local x, y, z = getElementPosition( veh )

		-- initiate some data.
		vehs[ veh ] = vehs[ veh ] or { } 
		vehs[ veh ].old_int = vehs[ veh ].old_int or int
		vehs[ veh ].old_dim = vehs[ veh ].old_dim or dim
		vehs[ veh ].old_post = vehs[ veh ].old_post or { x, y, z }

		-- if vehicle has not been going in/out any interiors; or if we haven't moved too far up and down
		if vehs[ veh ].old_int == int and vehs[ veh ].old_dim == dim and math.abs( z - vehs[ veh ].old_post[3] ) < 30 then
			local distance = getDistanceBetweenPoints3D( x, y, z, unpack( vehs[ veh ].old_post ) ) 
			vehs[ veh ].old_post = { x, y, z }
			local mass = getVehicleHandling( veh )["mass"]
			local percentage = math.min( 100, ( distance/400 ) + ( mass/20000 ) )/100 -- maxium is 100/100
			local fuelLoss = percentage * getMaxFuel( veh )

			-- if vehicle lose too much fuel while moving in the same int/dim in a short period of time, it must have been teleported or respawned.
			-- the percentage is ~0.018 for going 240km/h, which is a distance of 800 units.
			return percentage < 0.025 and fuelLoss or 0
		else
			vehs[ veh ].old_int = int
			vehs[ veh ].old_dim = dim
			vehs[ veh ].old_post = { x, y, z }
			return 0
		end
	else
		return 0
	end
end

local function countLightsOn( veh )
	local total = 0
	if ( getElementData( veh, 'lights' ) or 0 ) > 0 or getVehicleOverrideLights( veh ) == 2 then
		for i = 0, 3 do
			if getVehicleLightState ( veh, i ) == 0 then
				total = total + depleting_battery_unit
			end
		end
	end
	return total
end

local function isRadioOn( veh )
	return ( getElementData( veh, "vehicle:radio" ) or 0 ) ~= 0-- and ( getElementData( veh, "vehicle:radio:volume" ) or 100 ) ~= 0
end

function getBatteryGainLoss( veh )
	if fuellessVehicle[ getElementModel( veh ) ] then
		return 0
	else
		local engergyLoss = ( isRadioOn( veh ) and depleting_battery_unit or 0 ) + countLightsOn( veh )
		if engergyLoss > 0 then
			return getVehicleEngineState( veh ) and engergyLoss or -engergyLoss
		else
			return getVehicleEngineState( veh ) and depleting_battery_unit or 0
		end
	end
end

local function deplete( element )
	if element and isElement( element ) then
		if getElementType( element ) == 'player' then
			if isPedInVehicle( element ) then
				local veh = getPedOccupiedVehicle( element )
				if veh and getVehicleController( veh ) == element then
					local changed = false
					-- calculate battery
					local batt = ( getElementData( veh, 'battery' ) or 100 ) + getBatteryGainLoss( veh )
					batt = math.max( 0, batt )
					batt = math.min( 100, batt )
					if getElementData( veh, 'battery' ) ~= batt then
						exports.anticheat:setEld( veh, 'battery', batt )
						-- if battery runs out and player having lights/radio on, force them all to turn off.
						if batt == 0 then
							if countLightsOn( veh ) > 0 then
								exports.anticheat:setEld( veh, 'lights', 0, 'all' )
								setVehicleOverrideLights( veh, 1 )
							end
							if isRadioOn( veh ) then
								exports.anticheat:setEld( veh, 'vehicle:radio', 0, 'all' )
							end
						end 
						changed = true
					end
					
					-- calculate fuel
					local fuel = math.max( 0, ( getElementData( veh, 'fuel' ) or 0 ) - getFuelLoss(veh) )
					if fuel ~= getElementData( veh, 'fuel' ) then
						exports.anticheat:setEld( veh, "fuel", fuel )
						-- if the tank is emptied, shutdown the engine.
						if getElementData( veh, 'fuel' ) == 0 and getVehicleEngineState( veh )  then
							setVehicleEngineState( veh, false )
							exports.anticheat:setEld( veh, "engine", 0 )
							toggleControl( element, 'brake_reverse', false )
						end
						changed = true
					end
					if changed then
						triggerLatentClientEvent( element, "syncFuel", veh, fuel, batt ) -- latent cuz it's obviously not urgent.
					end
				end
			end
		elseif getElementType( element ) == 'vehicle' then
			if not getVehicleOccupant( element ) then
				-- calculate battery
				local batt = ( getElementData( element, 'battery' ) or 100 ) + ( getBatteryGainLoss( element ) * depleting_rate_empty )
				batt = math.max( 0, batt )
				batt = math.min( 100, batt )
				if getElementData( element, 'battery' ) ~= batt then
					exports.anticheat:setEld( element, 'battery', batt )
					-- if battery runs out and player having lights/radio on, force them all to turn off.
					if batt == 0 then
						if countLightsOn( element ) > 0 then
							exports.anticheat:setEld( element, 'lights', 0, 'all' )
							setVehicleOverrideLights( element, 1 )
						end
						if isRadioOn( element ) then
							exports.anticheat:setEld( element, 'vehicle:radio', 0, 'all' )
						end
					end 
				end

				-- calculate fuel
				local fuel = math.max( 0, ( getElementData( element, 'fuel' ) or 0 ) - ( getFuelLoss(element) * depleting_rate_empty ) )
				if fuel ~= getElementData( element, 'fuel' ) then
					exports.anticheat:setEld( element, "fuel", fuel )
					-- if the tank is emptied, shutdown the engine.
					if getElementData( element, 'fuel' ) == 0 and getVehicleEngineState( element )  then
						setVehicleEngineState( element, false )
						exports.anticheat:setEld( element, "engine", 0 )
					end
				end
			end
		end
	end
end

local function killThreadTimer( id )
	if threadTimer[id] and isTimer( threadTimer[id] ) then
		killTimer( threadTimer[id] )
		threadTimer[id] = nil
	end
end

function fuelDepleting( id )
	threads[ id ] = {}

	if id == 1 then
		updateDepletingRate()
	end

	local elements = getElementsByType( id == 1 and 'player' or 'vehicle' )
	for k, element in ipairs( elements ) do
		local co = coroutine.create( deplete )
		table.insert( threads[ id ], { func = co, element = element } )
	end
	killThreadTimer( id )
	-- spread the timer to process all elements during the depleting_rate wait time instead of doing them all instantly and at once.
	local thread_delay = math.max( 50, math.ceil( depleting_rate*(id == 2 and depleting_rate_empty or 1)/(#elements/deplete_concurrents[ id ]) ) )
	local thread_count = math.ceil( #elements/deplete_concurrents[ id ] )
	
	if id == 2 then
		outputDebugString( '[FUEL] fuelDepleting / id: '..id..' / thread_delay: '..thread_delay )
		outputDebugString( '[FUEL] fuelDepleting / id: '..id..' / threads_count:  '..thread_count )
	end
	
	threadTimer[ id ] = setTimer( resumeThreads, thread_delay, 0 , id )
	setTimer( fuelDepleting, math.ceil( math.max( #elements*50/deplete_concurrents[ id ], id == 1 and depleting_rate+1000 or depleting_rate*(depleting_rate_empty+1) ) ), 1, id )
end

function resumeThreads( id )
	if id == 2 then
		outputDebugString( '[FUEL] resumeThreads / id '..id..' / remaining processes: '..#threads[ id ] )
	end
	for i, co in ipairs( threads[ id ] ) do
		coroutine.resume( co.func, co.element )
		table.remove( threads[ id ], i )
		if i >= deplete_concurrents[ id ] then
			break
		end
	end

	if #threads[ id ] <= 0 then
		killThreadTimer( id )
	end
end

function randomizeFuelPrice()
	FUEL_PRICE = math.random(30, 50) / 30
end

addEventHandler( 'onResourceStart', resourceRoot, function()
	fuelDepleting( 1 ) -- vehicles with driver.
	-- fuelDepleting( 2 ) -- vehicles without driver.
	setTimer( randomizeFuelPrice, 3600000, 0 )
end)
