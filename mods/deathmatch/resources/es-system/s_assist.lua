backupBlip = false
backupPlayer = nil

function removeBackup(thePlayer, commandName)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) or (exports.factions:isInFactionType(thePlayer, 4) and exports.factions:hasMemberPermissionTo(thePlayer, 2, "add_member")) then
		if (backupPlayer~=nil) then
			
			for k,v in ipairs(exports.factions:getPlayersInFaction(2)) do
				triggerClientEvent(v, "destroyBackupBlip2", getRootElement())
			end
			removeEventHandler("onPlayerQuit", backupPlayer, destroyBlip)
			removeEventHandler("savePlayer", backupPlayer, destroyBlip)
			backupPlayer = nil
			backupBlip = false
			outputChatBox("SFES-Assist system reset!", thePlayer, 255, 194, 14)
		else
			outputChatBox("SFES-Assist system did not need reset.", thePlayer, 255, 194, 14)
		end
	end
end
addCommandHandler("resetassist", removeBackup, false, false)

function backup(thePlayer, commandName)
	local duty = tonumber(getElementData(thePlayer, "duty"))
	
	if exports.factions:isInFactionType(thePlayer, 4) and (duty>0) then
		if (backupBlip == true) and (backupPlayer~=thePlayer) then -- in use
			outputChatBox("There is already a assist beacon in use.", thePlayer, 255, 194, 14)
		elseif (backupBlip == false) then -- make backup blip
			backupBlip = true
			backupPlayer = thePlayer
			for k,v in ipairs(exports.factions:getPlayersInFaction(2)) do
				local duty = tonumber(getElementData(v, "duty"))
				
				if (duty>0) then
					triggerClientEvent(v, "createBackupBlip2", thePlayer)
					outputChatBox("A unit needs urgent assistance! Please respond ASAP!", v, 255, 194, 14)
				end
			end

			addEventHandler("onPlayerQuit", thePlayer, destroyBlip)
			addEventHandler("savePlayer", thePlayer, destroyBlip)
			
		elseif (backupBlip == true) and (backupPlayer==thePlayer) then -- in use by this player
			for key, v in ipairs(exports.factions:getPlayersInFaction(2)) do
			
				local duty = tonumber(getElementData(v, "duty"))
				
				if (duty>0) then
					triggerClientEvent(v, "destroyBackupBlip2", getRootElement())
					outputChatBox("The unit no longer requires assistance.", v, 255, 194, 14)
				end
			end

			removeEventHandler("onPlayerQuit", thePlayer, destroyBlip)
			removeEventHandler("savePlayer", thePlayer, destroyBlip)
			backupPlayer = nil
			backupBlip = false
		end
	end
end
addCommandHandler("assist", backup, false, false)

function destroyBlip()
	for key, value in ipairs(exports.factions:getPlayersInFaction(2)) do
		outputChatBox("The unit no longer requires assistance.", value, 255, 194, 14)
		triggerClientEvent(value, "destroyBackupBlip2", getRootElement())
	end
	removeEventHandler("onPlayerQuit", source, destroyBlip)
	removeEventHandler("savePlayer", source, destroyBlip)
	backupPlayer = nil
	backupBlip = false
end