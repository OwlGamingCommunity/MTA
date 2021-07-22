--MAXIME
function playSoundHandbrake(state)
	if state == "off" then
		local sound = playSound(":resources/hb_off.mp3")
		if sound then
			setSoundVolume(sound , 1)
		end
	else
		local sound = playSound(":resources/hb_on.mp3")
		if sound then
			setSoundVolume(sound , 0.3)
		end
	end
end
addEvent( "playSoundHandbrake", true )
addEventHandler( "playSoundHandbrake", root,  playSoundHandbrake)

local function checkVelocity(veh)
	local x, y, z = getElementVelocity(veh)
	return math.abs(x) < 0.05 and math.abs(y) < 0.05 and math.abs(z) < 0.05
end

-- exported
-- commandName is optional
function doHandbrake(commandName)
	if isPedInVehicle ( localPlayer ) then
		local playerVehicle = getPedOccupiedVehicle ( localPlayer )
		if (getVehicleOccupant(playerVehicle, 0) == localPlayer) then
			-- vehicle doesn't move and its in a custom interior; custom (officially mapped) interiors would otherwise suffer from no-handbrake and vehicles falling through
			local override = getElementDimension(playerVehicle) > 0 and checkVelocity(playerVehicle)

			triggerServerEvent("vehicle:handbrake", playerVehicle, override, commandName)
		end
	end
end
addCommandHandler('kickstand', doHandbrake)
addCommandHandler('handbrake', doHandbrake)
addCommandHandler('anchor', doHandbrake)

--Cancel everything else but handbrake when player hit G. /maxime
function playerPressedKeyHandBrake(button, press)
	if button == "g" and (press) then -- Only output when they press it down
		doHandbrake()
		cancelEvent()
	end
end

function resourceStartBindG()
	bindKey("g", "down", playerPressedKeyHandBrake)
end
addEventHandler("onClientResourceStart", resourceRoot, resourceStartBindG)

addEventHandler('onClientVehicleStartExit', root,
	function(player)
		if player == localPlayer and not isVehicleLocked(source) and getPedControlState(localPlayer, 'handbrake') then
			setPedControlState(localPlayer, 'handbrake', false)
		end
	end)
