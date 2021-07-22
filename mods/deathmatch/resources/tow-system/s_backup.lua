backupBlip = false
backupPlayer = nil

function destroyBlip(thePlayer)
	for k,v in ipairs(exports.factions:getPlayersInFaction(4)) do
		triggerClientEvent(v, "destroyBackupBlip3", resourceRoot)
		outputChatBox("The unit no longer requires assistance. Resume normal patrol", v, 255, 194, 14)
	end
	if source and isElement(source) then
		removeEventHandler("onPlayerQuit", source, destroyBlip)
		removeEventHandler("savePlayer", source, destroyBlip)
	end
	backupPlayer = nil
	backupBlip = false
end

function removeBackup(thePlayer, commandName)
	local isIn, _ = exports.factions:isPlayerInFaction(thePlayer, 4)
	local leader = exports.factions:hasMemberPermissionTo(thePlayer, 4, "add_member")
	if exports.integration:isPlayerTrialAdmin(thePlayer) or (isIn and leader) then
		if (backupPlayer~=nil) then

			for k,v in ipairs(exports.factions:getPlayersInFaction(4)) do
				triggerClientEvent(v, "destroyBackupBlip3", backupBlip)
			end
			removeEventHandler("onPlayerQuit", backupPlayer, destroyBlip)
			removeEventHandler("savePlayer", backupPlayer, destroyBlip)
			backupPlayer = nil
			backupBlip = false
			outputChatBox("Backup system reset!", thePlayer, 255, 194, 14)
		else
			outputChatBox("Backup system did not need reset.", thePlayer, 255, 194, 14)
		end
	end
end
addCommandHandler("resettowbackup", removeBackup, false, false)

function backup(thePlayer, commandName)
		if (backupBlip == true) and (backupPlayer~=thePlayer) then -- in use
			outputChatBox("There is already a backup beacon in use.", thePlayer, 255, 194, 14)
		elseif (backupBlip == false) then -- make backup blip
			backupBlip = true
			backupPlayer = thePlayer
			for k,v in ipairs(exports.factions:getPlayersInFaction(4)) do
				triggerClientEvent(v, "createBackupBlip3", thePlayer)
				outputChatBox("A person requires a Tow Truck. Please respond ASAP!", v, 255, 194, 14)
			end

			addEventHandler("onPlayerQuit", thePlayer, destroyBlip)
			addEventHandler("savePlayer", thePlayer, destroyBlip)
			outputChatBox("You enabled your GPS Beacon for the towing company.", thePlayer, 0, 255, 0)
		elseif (backupBlip == true) and (backupPlayer==thePlayer) then -- in use by this player
			destroyBlip( thePlayer )
			outputChatBox("You disabled your GPS Beacon for the towing company.", thePlayer, 255, 0, 0)
		end
end
addCommandHandler("towtruck", backup, false, false)
