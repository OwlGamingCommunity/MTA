
local c_lastspeed = 0
local c_speed = 0
local isplayernotjumpaway = true

-----------------------------
function getActualVelocity( element, x, y, z )
	return (x^2 + y^2 + z^2) ^ 0.5
end

-----------------------------
function updateDamage(c_veh)
	c_speed = getActualVelocity( c_veh, getElementVelocity( c_veh ) )
	if c_lastspeed - c_speed >= 0.25 and not isElementFrozen( c_veh ) then
		if (c_lastspeed - c_speed >= 0.45) then -- trigger throwing out of the vehicle
			local vehicle = getPedOccupiedVehicle(localPlayer)
			local x, y, z = getElementPosition(localPlayer)
			local nx, ny, nz
			local rz = getPedRotation(localPlayer)

			nx = x + math.sin( math.rad( rz )) * 2
			ny = y + math.cos( math.rad( rz )) * 2
			nz = getGroundPosition(nx, ny, z)
			
			local bcollision, ex, ey, ez, element = processLineOfSight(x, y, z+1, nx, ny, nz+1, true, true, true, true, true, false, false, false, vehicle)
			if (bcollision) then
				ez = getGroundPosition(ex, ey, ez)
				if not getElementData(localPlayer, "seatbelt") and getVehicleType(vehicle) ~= "Train" then
					triggerServerEvent("crashThrowPlayerFromVehicle", vehicle, {ex, ey, ez+2}, vehicle)
				end
			else
				if not getElementData(localPlayer, "seatbelt") and getVehicleType(vehicle) ~= "Train" then
					triggerServerEvent("crashThrowPlayerFromVehicle", vehicle, {nx, ny, nz+2}, vehicle)
				end
			end
		end
		c_lasthealth = getElementHealth(localPlayer) - 20*(c_lastspeed)
		if c_lasthealth <= 0 then
			c_lasthealth = 0
		end
		setElementHealth(localPlayer , c_lasthealth)
	end
	c_lastspeed = c_speed
end

function onJumpOut()
	isplayernotjumpaway = false
end

function onJumpFinished()

	isplayernotjumpaway = true
end

-----------------------------
addEventHandler( "onClientVehicleStartExit", root,onJumpOut)
addEventHandler( "onClientVehicleExit", root,onJumpFinished)
addEventHandler( "onClientRender", root,function  ( )
	if isPedInVehicle(localPlayer) then
		c_veh = getPedOccupiedVehicle(localPlayer)
		if c_veh then
			--local c_veh_driver = getVehicleOccupant ( c_veh, 0 )
			--if c_veh_driver == localPlayer then
				updateDamage(c_veh)
			--end
		end
	else
		c_speed = 0
		c_lastspeed = 0
	end
end
)