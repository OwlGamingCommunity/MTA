local factor = 1.5

function relateVelocity(speed)
	return factor * speed
end

function getVehicleVelocity(vehicle, player)
	local speedx, speedy, speedz = getElementVelocity (vehicle)
	local actualspeed = (speedx^2 + speedy^2 + speedz^2)^(0.5) 
	if player and isElement(player) and getElementData(player, "speedo") == "2" then
		return actualspeed * 111.847
	else 
		return actualspeed * 180
	end
	--return relateVelocity((speedx^2 + speedy^2 + speedz^2)^(0.5)*100)
end