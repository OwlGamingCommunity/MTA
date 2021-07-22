local backupBlip = nil
addEvent("createBackupBlip3", true)
addEvent("destroyBackupBlip3", true)
addEventHandler("createBackupBlip3", getRootElement(), function ()
	if (backupBlip) then
		destroyElement(backupBlip)
		backupBlip = nil
	end
	local x, y, z = getElementPosition(source)
	backupBlip = createBlip(x, y, z, 0, 3, 0, 0, 255, 99, 0, 32767)
	attachElements(backupBlip, source)
end)
addEventHandler("destroyBackupBlip3", getRootElement(), function ()
	if (backupBlip) then
		destroyElement(backupBlip)
		backupBlip = nil
	end
end)