copCars = {
[427] = true,
[490] = true,
[528] = true,
[523] = true,
[596] = true,
[597] = true,
[598] = true,
[599] = true,
[601] = true }

function onCopCarEnter(thePlayer, seat)
	if (seat < 2) and (thePlayer==getLocalPlayer()) then
		local model = getElementModel(source)
		if (copCars[model]) then
			setRadioChannel(0)
		end
	end
end
addEventHandler("onClientVehicleEnter", getRootElement(), onCopCarEnter)

function realisticWeaponSounds(weapon)
	local x, y, z = getElementPosition(getLocalPlayer())
	local tX, tY, tZ = getElementPosition(source)
	local distance = getDistanceBetweenPoints3D(x, y, z, tX, tY, tZ)
	
	if (distance<25) and (weapon>=22 and weapon<=34) then
		local randSound = math.random(27, 30)
		playSoundFrontEnd(randSound)
	end
end
addEventHandler("onClientPlayerWeaponFire", getRootElement(), realisticWeaponSounds)

function getElementSpeed(element,unit)
	if (unit == nil) then unit = 0 end
	if (isElement(element)) then
		local x,y,z = getElementVelocity(element)
		if (unit=="mph" or unit==1 or unit =='1') then
			return (x^2 + y^2 + z^2) ^ 0.5 * 100
		else
			return (x^2 + y^2 + z^2) ^ 0.5 * 1.61 * 100
		end
	else
		return false
	end
end

function setElementSpeed(element, unit, speed)
	if (unit == nil) then unit = 0 end
	if (speed == nil) then speed = 0 end
	speed = tonumber(speed)
	local acSpeed = getElementSpeed(element, unit)
	if (acSpeed~=false) then
		local diff = speed/acSpeed
		local x,y,z = getElementVelocity(element)
		setElementVelocity(element,x*diff,y*diff,z*diff)
		return true
	else
		return false
	end
end


function angle(vehicle)
	local vx,vy,vz = getElementVelocity(vehicle)
	local modV = math.sqrt(vx*vx + vy*vy)
	
	if not isVehicleOnGround(vehicle) then return 0,modV end
	
	local rx,ry,rz = getElementRotation(vehicle)
	local sn,cs = -math.sin(math.rad(rz)), math.cos(math.rad(rz))
	
	local cosX = (sn*vx + cs*vy)/modV

	return math.deg(math.acos(cosX))*0.5, modV
end