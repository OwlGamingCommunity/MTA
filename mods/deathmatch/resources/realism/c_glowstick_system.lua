cooldown = 0

function dropGlowStick()
	if (cooldown==0) then
		local x, y, z = getElementPosition(getLocalPlayer())
		local rot = getPedRotation(getLocalPlayer())
		local x = x + math.sin(math.rad(rot)) * 1
		local y = y + math.cos(math.rad(rot)) * 1
		local ground = getGroundPosition(x, y, z)
				
		cooldown = 1
		setTimer(resetCooldown, 5000, 1)
		triggerServerEvent("createGlowStick", getLocalPlayer(), x, y, ground) 
	else
		outputChatBox("Please wait before dropping another glowstick.", 255, 194, 14)
	end
end

function resetCooldown()
	cooldown = 0
end