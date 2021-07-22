local blipHolder = { }
local arr = { }
addEvent("createBackupBlip", true)
addEvent("destroyBackupBlip", true)

function createBackupBlip( availableColourIndex, colourArray )
	triggerEvent("destroyBackupBlip", source, availableColourIndex)
	
	local x, y, z = getElementPosition(source)
	local tempBackupBlip = createBlip(x, y, z, 0, 3, colourArray[1], colourArray[2], colourArray[3], 255, 255, 32767)
	attachElements(tempBackupBlip, source)	
	blipHolder[availableColourIndex] = tempBackupBlip
	table.insert(arr, tempBackupBlip)
end
addEventHandler("createBackupBlip", getRootElement(), createBackupBlip)

function destroyBackupBlip( availableColourIndex )
	if blipHolder[availableColourIndex] and isElement(blipHolder[availableColourIndex] ) then
		for a, b in ipairs(arr) do
			if b == blipHolder[availableColourIndex] then
				table.remove(arr,a)
				break
			end
		end
		
		destroyElement( blipHolder[availableColourIndex] )
		blipHolder[availableColourIndex] = false
	end
end
addEventHandler("destroyBackupBlip", getRootElement(), destroyBackupBlip)

function dutyToggle( goingOnDuty )
	if not goingOnDuty then
		refreshBlips ( )
	end
end
addEventHandler("onPlayerDuty", getRootElement(), dutyToggle)

function refreshBlips ( )
	for a,b in ipairs(arr) do
		destroyElement(b)
	end
	arr = { }
	blipHolder = { }
	--outputChatBox("[Debug] Destroying all the blips")
end
addEventHandler("accounts:characters:spawn", getRootElement(), refreshBlips)