------------------------------
-----------(c)2014------------
-----------by r1k3------------
------------------------------
local width, height = guiGetScreenSize()
local rel = height/768 / 1.3
function loadAircraftFX()
attitudeIndicator = dxCreateTexture("grafik/attitude_indicator.png" , "argb", true,"clamp" )
altimeter1 = dxCreateTexture("grafik/altimeter_1.png" , "argb", true,"clamp" )
variometer = dxCreateTexture("grafik/variometer.png" , "argb", true,"clamp" )
altimeterPointer1 = dxCreateTexture("grafik/altimeter_pointer_1.png" , "argb", true,"clamp" )
altimeterPointer2 = dxCreateTexture("grafik/altimeter_pointer_2.png" , "argb", true,"clamp" )
airspeedIndicator = dxCreateTexture("grafik/airspeed_indicator.png" , "argb", true,"clamp" )
compass1 = dxCreateTexture("grafik/compass_1.png" , "argb", true,"clamp" )
compass2 = dxCreateTexture("grafik/compass_2.png" , "argb", true,"clamp" )
corner1 = dxCreateTexture("grafik/corner_1.png" , "argb", true,"clamp" )
corner2 = dxCreateTexture("grafik/corner_2.png" , "argb", true,"clamp" )
ledon = dxCreateTexture("grafik/led_on.png" , "argb", true,"clamp" )
ledoff = dxCreateTexture("grafik/led_off.png" , "argb", true,"clamp" )
end
addEventHandler("onClientResourceStart",getRootElement(),loadAircraftFX)
function renderAircraftFX()
 if isPedInVehicle(getLocalPlayer()) then
	--=============corner==========================--
	dxDrawImage( width/2 - 875 * rel/2, height - 125 * rel, 125 * rel, 125 * rel, corner1  )
	dxDrawImage( width/2 + 625 * rel/2, height - 125 * rel, 125 * rel, 125 * rel, corner2  )
	--=============control leds====================--
	local theVehicle = getPedOccupiedVehicle(getLocalPlayer())
	if isVehicleOnGround(theVehicle) then
		dxDrawImage( width/2 + 625 * rel/2, height - 50 * rel, 25 * rel, 25 * rel, ledon  )
	else
		dxDrawImage( width/2 + 625 * rel/2, height - 50 * rel, 25 * rel, 25 * rel, ledoff  )
	end
	dxDrawText ( " on Ground", width/2 + 675 * rel/2, height - 45 * rel, nil, nil, tocolor(150, 150, 150), 1 * rel, "default", "left", "top")

	if isVehicleLocked(theVehicle) then
		dxDrawImage( width/2 + 625 * rel/2, height - 75 * rel, 25 * rel, 25 * rel, ledon  )
	else
		dxDrawImage( width/2 + 625 * rel/2, height - 75 * rel, 25 * rel, 25 * rel, ledoff  )
	end
	dxDrawText ( " locked", width/2 + 675 * rel/2, height - 70 * rel, nil, nil, tocolor(150, 150, 150), 1 * rel, "default", "left", "top")

	if getVehicleLandingGearDown(theVehicle) then
		dxDrawImage( width/2 - 800 * rel/2, height - 50 * rel, 25 * rel, 25 * rel, ledon  )
	else
		dxDrawImage( width/2 - 800 * rel/2, height - 50 * rel, 25 * rel, 25 * rel, ledoff  )
	end
	dxDrawText ( " Gear", width/2 - 750 * rel/2, height - 45 * rel, nil, nil, tocolor(150, 150, 150), 1 * rel, "default", "left", "top")

	if getVehicleEngineState(theVehicle) then
	dxDrawImage( width/2 - 800 * rel/2, height - 75 * rel, 25 * rel, 25 * rel, ledon  )
	else
		dxDrawImage( width/2 - 800 * rel/2, height - 75 * rel, 25 * rel, 25 * rel, ledoff  )
	end
	dxDrawText ( " Engine", width/2 - 750 * rel/2, height - 70 * rel, nil, nil, tocolor(150, 150, 150), 1 * rel, "default", "left", "top")
	--=============attitude indicator==============--
	local rx, ry, rz = getElementRotation(theAircraft)
	if rx >= 180 and rx < 315  then
			rx = 313-360
	end
	if rx > 180 then
		rx = rx-360
		rx2 = rx-360
	end
	dxDrawRectangle( width/2 - (125 * rel/2), height - (125 * rel), 125 * rel, rx * rel + 63 * rel, tocolor ( 0, 209, 255, 255 ))--bluePart
	dxDrawRectangle( width/2 - (125  * rel/2), height - (62 * rel - rx * rel), 125 * rel, 125 * rel, tocolor ( 126, 67, 0, 255 ))--BrownPart
	dxDrawLine(width/2 - (125  * rel/2), height - (62 * rel - rx * rel), width/2 + (124  * rel/2), height - (62 * rel - rx * rel), tocolor ( 225, 228, 0, 255 ) )
	dxDrawLine(width/2, height - (62 * rel - rx * rel), width/2 - (124  * rel/2), height + rx * rel, tocolor ( 225, 255, 255, 255 ) )
	dxDrawLine(width/2, height - (62 * rel - rx * rel), width/2 + (124  * rel/2), height + rx * rel, tocolor ( 225, 255, 255, 255 ) )
	dxDrawImage( width/2 - 125 * rel/2, height - 125 * rel, 125 * rel, 125 * rel, attitudeIndicator  )
	--=============altimeter=======================--
	local x, y, z = getElementPosition(theAircraft)
	local zground = getGroundPosition(x, y, z)
	z = z * 3.2808
	zground = zground * 3.2808
	z1 =  z / 3.333333
	z2 =  z / 33.333333
	z3 = (z - zground)/ 3.333333
	z4 = (z - zground)/ 33.333333
	if z3 > z1 then
		z3 = z1
		z4 = z2
	end
	z5 = (z3 + (z5*30))/31
	z6 = (z4 + (z6*30))/31
	--toNN--
	dxDrawImage( width/2 + 125 * rel/2, height - 125 * rel, 125 * rel, 125 * rel, altimeter1  )
	dxDrawImage( width/2 + 125 * rel/2, height - 125 * rel, 125 * rel, 125 * rel, altimeterPointer1, z1  )
	dxDrawImage( width/2 + 125 * rel/2, height - 125 * rel, 125 * rel, 125 * rel, altimeterPointer2, z2  )
	--=============airspeed========================--
	local speedx, speedy, speedz = getElementVelocity ( theAircraft )
	local actualspeed = (speedx^2 + speedy^2 + speedz^2)^(0.5)
	local knots = actualspeed * 97.2
	knots = knots * 2
	dxDrawImage( width/2 - 375 * rel/2, height - 125 * rel, 125 * rel, 125 * rel, airspeedIndicator  )
	dxDrawImage( width/2 - 375 * rel/2, height - 125 * rel, 125 * rel, 125 * rel, altimeterPointer1, knots  )
	--=============compass=========================--
	dxDrawImage( width/2 - 625 * rel/2, height - 125 * rel, 125 * rel, 125 * rel, compass1  )
	dxDrawImage( width/2 - 625 * rel/2, height - 125 * rel, 125 * rel, 125 * rel, compass2, rz  )
	--=============variometer======================--
	dxDrawImage( width/2 + 375 * rel/2, height - 125 * rel, 125 * rel, 125 * rel, variometer  )
	local vario = (CurrentVarioDiff or 0) * 1.9438444924574 * 8
	if vario > 10 then
		vario = 10
	elseif vario < -10 then
		vario = -10
	end
	local vario = (oldvario * 10 + vario) /11
	oldvario = vario
	dxDrawImage( width/2 + 375 * rel/2, height - 125 * rel, 125 * rel, 125 * rel, altimeterPointer1, 270 + vario * 15  )
 else
  removeEventHandler("onClientRender", getRootElement(), renderAircraftFX)
 end
end
function checkVariometer()
setTimer ( function()
		local theVehicle = getPedOccupiedVehicle(getLocalPlayer())
		if theVehicle then
			local posx, posy, posz = getElementPosition(theVehicle)
			CurrentVarioDiff = posz - PlaneCurrentPosz
			PlaneCurrentPosz = posz
			checkVariometer()
		end
	end, 125, 1 )
end
function CheckForAircraftEnter(thePlayer, seat)
	local theVehicle = getPedOccupiedVehicle(getLocalPlayer())
	local vehType = nil
	if isElement(theVehicle) then
		vehType = getVehicleType(theVehicle)
	end
	if (vehType == "Plane" or vehType == "Helicopter") and thePlayer == getLocalPlayer() and (seat == 0 or seat == 1) and getElementModel(theVehicle) ~= 539 then
		lastVehicle = "Plane"
		theAircraft = theVehicle
		local driver = getVehicleOccupant ( theVehicle, 0 )
		if (driver == getLocalPlayer()) then
			addEventHandler("onClientRender",getRootElement(),renderAircraftFX)
			local posx, posy, posz = getElementPosition(theVehicle)
			PlaneCurrentPosz = posz
			z5 = 0
			z6 = 0
			oldvario = 0
			checkVariometer()
		end
	end
end
addEventHandler("onClientVehicleEnter",getRootElement(),CheckForAircraftEnter)
function CheckForAircraftExit(thePlayer, seat)
	if lastVehicle == "Plane" and thePlayer == getLocalPlayer() and (seat == 0 or seat == 1) then
		removeEventHandler("onClientRender", getRootElement(), renderAircraftFX)
	end
end
addEventHandler("onClientVehicleExit",getRootElement(),CheckForAircraftExit)
