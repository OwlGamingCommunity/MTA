--This script estimates the size of the radar, based upon some simple calculations
local MIN_VELOCITY = 0.3
local MIN_DISTANCE = 180

local MAX_VELOCITY = 1
local MAX_DISTANCE = 350
--
--Planes always use the MAX_DISTANCE since the radar is always zoomed out
local planes = {
[592]=true,[553]=true,[577]=true,[511]=true,[512]=true,
[476]=true,[593]=true,[519]=true,[520]=true,[460]=true,[513]=true,
}
--
local localPlayer = getLocalPlayer()
local ratio
do
	local velocityDiff = MAX_VELOCITY - MIN_VELOCITY
	local distanceDiff = MAX_DISTANCE - MIN_DISTANCE
	ratio = distanceDiff/velocityDiff
end


function getRadarRadius ()
	if not isPedInVehicle(localPlayer) then --The radar does not resize when on foot
		return MIN_DISTANCE
	else
		local vehicle = getPedOccupiedVehicle(localPlayer)
		if planes[getElementModel(vehicle)] then
			return MAX_DISTANCE
		end
		local speed = ( getDistanceBetweenPoints3D(0,0,0,getElementVelocity(vehicle)) )
		if speed <= MIN_VELOCITY then
			return MIN_DISTANCE
		elseif speed >= MAX_VELOCITY then
			return MAX_DISTANCE
		end
		--Otherwise we're somewhere in between
		local streamDistance = speed - MIN_VELOCITY --Since MIN_DISTANCE is the lower bound, remove it
		streamDistance = streamDistance * ratio
		streamDistance = streamDistance + MIN_DISTANCE
		return math.ceil(streamDistance)
	end
end