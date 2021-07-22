local localPlayer = getLocalPlayer()
local sounds = { }

function createSiren(thePlayer, seat)
	if (getVehicleSirensOn(source) and (seat==0)) then
		local x, y, z = getElementPosition(source)
		local px, py, pz = getElementPosition(localPlayer)
		
		if (getDistanceBetweenPoints3D(x, y, z, px, py, pz)<25) then
			local sound = playSound3D("siren.wav", x, y, z, true)
			setSoundVolume(sound, 0.6)
			
			for i = 1, 20 do
				if (sounds[i]==nil) then
					sounds[i] = { }
					sounds[i][1] = source
					sounds[i][2] = sound
					break
				end
			end
		end
	end
end
--addEventHandler("onClientVehicleExit", getRootElement(), createSiren)

function destroySiren(thePlayer, seat)
	if (seat==0) then
		local key = 0
		for i = 1, 20 do
			if (sounds[i]~=nil) then
				if (sounds[i][1]==source) then
					key = i
					break
				end
			else
				break
			end
		end
		
		if (key>0) then
			local sound = sounds[key][2]
			stopSound(sound)
			table.remove(sounds, key)
		end
	end
end
--addEventHandler("onClientVehicleEnter", getRootElement(), destroySiren)