local backupBlip = nil
addEvent("createBackupBlip2", true)
addEvent("destroyBackupBlip2", true)
addEventHandler("createBackupBlip2", getRootElement(), function ()
	if (backupBlip) then
		destroyElement(backupBlip)
		backupBlip = nil
	end
	local x, y, z = getElementPosition(source)
	backupBlip = createBlip(x, y, z, 0, 3, 0, 0, 255, 255, 255, 32767)
	attachElements(backupBlip, source)
end)
addEventHandler("destroyBackupBlip2", getRootElement(), function ()
	if (backupBlip) then
		destroyElement(backupBlip)
		backupBlip = nil
	end
end)