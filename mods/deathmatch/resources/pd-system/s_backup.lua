local backupColours = {
	{ 255, 0, 0, "Red", false },
	{ 0, 255, 0, "Green", false },
	{ 0, 0, 255, "Blue", false },
	{ 255, 255, 0, "Yellow", false },
	{ 255, 0, 255, "Pink", false },
	{ 0, 255, 255, "Light-Blue", false },
	{ 255, 255, 255, "White", false }
}

local allowedFactionTypes = {
	[2] = true,
	[3] = true,	
	[4] = true
}

local vehiclesDashboardRadio = { [596] = true,[597] = true, [598] = true, [599] = true, [601] = true, [427] = true, [407] = true, [416] = true, [528] = true, [523] = true }

function startBackup(thePlayer) 
	local faction = exports.factions:getCurrentFactionDuty(thePlayer) or -1
	local theTeam = exports.factions:getFactionFromID(faction)
	local factionType = getElementData(theTeam, "type")
	local factionShortName = ""
	if (allowedFactionTypes[factionType]) and (faction > 0) then
	--if getPedOccupiedVehicle(thePlayer) then
		local veh = getPedOccupiedVehicle(thePlayer)
		if veh then
			local model = getElementModel(veh)
			if veh and vehiclesDashboardRadio[model] then
				triggerEvent('sendAme', thePlayer, "flicks a switch on their dashboard radio.")
			else
				triggerEvent('sendAme', thePlayer, "flicks a switch on their radio.")
			end
		else
			triggerEvent('sendAme', thePlayer, "flicks a switch on their radio.")
		end
		
		for a, b in ipairs(split(getTeamName(theTeam), ' ')) do 
			factionShortName = factionShortName .. b:sub( 1, 1) 
		end
	
		local availableColourIndex = false
		local alreadyUsingOne = false
		for index, colorarray in ipairs(backupColours) do
			-- See if there is one available, and if the player is already using one.
			if (backupColours[index][5] == false) and (availableColourIndex == false) then
				availableColourIndex = index
			elseif (backupColours[index][5] == thePlayer) then
				alreadyUsingOne = true
				availableColourIndex = index
			end			
		end
		
		if alreadyUsingOne then
			backupColours[availableColourIndex][5] = false
			for keyValue, theArrayPlayer in ipairs( getElementsByType("player") ) do
				local faction = exports.factions:getCurrentFactionDuty(theArrayPlayer) or -1
				local pTheTeam = exports.factions:getFactionFromID(faction)
				if pTheTeam then
					local pFactionType = getElementData(pTheTeam, "type")
					if allowedFactionTypes[pFactionType]  then
						if (faction > 0) then
							triggerClientEvent(theArrayPlayer, "destroyBackupBlip", thePlayer, availableColourIndex)
							outputChatBox("The '".. backupColours[availableColourIndex][4]  .."' unit (" .. factionShortName ..") no longer requires assistance. Resume normal patrol.", theArrayPlayer, 255, 194, 14)
						end
					end	
				end
			end	
		elseif availableColourIndex then
			backupColours[availableColourIndex][5] = thePlayer
			for keyValue, theArrayPlayer in ipairs( getElementsByType("player") ) do
				local faction = exports.factions:getCurrentFactionDuty(theArrayPlayer) or -1
				local pTheTeam = exports.factions:getFactionFromID(faction)
				if pTheTeam then
					local pFactionType = getElementData(pTheTeam, "type")
					if allowedFactionTypes[pFactionType]  then
						if (faction > 0) then
							triggerClientEvent(theArrayPlayer, "createBackupBlip", thePlayer, availableColourIndex, backupColours[availableColourIndex])
							outputChatBox("The '".. backupColours[availableColourIndex][4]  .."' unit (" .. factionShortName ..") has enabled their radio backup beacon!", theArrayPlayer, 255, 194, 14)
						end
					end	
				end
			end		
		else
			outputChatBox("All the backup beacons are already in use.", thePlayer, 255, 194, 14)
		end
	--end
	end
end
addCommandHandler("backup", startBackup)

function destroyBlips(thePlayer)
	local availableColourIndex = false
	local factionShortName = ""
	for index, colorarray in ipairs(backupColours) do
		if (backupColours[index][5] == thePlayer) then
			availableColourIndex = index
		end		
	end
	
	if availableColourIndex then
		local thePlayerFactionID = exports.factions:getCurrentFactionDuty(thePlayer) or -1
		local factionName = exports.factions:getFactionName(thePlayerFactionID)
		for a, b in ipairs(split(factionName, ' ')) do 
			factionShortName = factionShortName .. b:sub( 1, 1) 
		end
		backupColours[availableColourIndex][5] = false
		for keyValue, theArrayPlayer in ipairs( getElementsByType("player") ) do
			local faction = exports.factions:getCurrentFactionDuty(theArrayPlayer) or -1
			local pTheTeam = exports.factions:getFactionFromID(faction)
			if pTheTeam then
				local pFactionType = getElementData(pTheTeam, "type")
				if allowedFactionTypes[pFactionType]  then
					triggerClientEvent(theArrayPlayer, "destroyBackupBlip", theArrayPlayer, availableColourIndex)
					if (faction > 0) then
						outputChatBox("The '".. backupColours[availableColourIndex][4]  .."' unit (" .. factionShortName ..")  no longer requires assistance. Resume normal patrol.", theArrayPlayer, 255, 194, 14)
					end
				end	
			end
		end	
	end
end
addEventHandler("onPlayerQuit", getRootElement(), function() destroyBlips(source) end)
addEventHandler("savePlayer", getRootElement(), function() destroyBlips(source) end)

function syncBlips(thePlayer)
	destroyBlips(thePlayer)

	local ftypes = exports.factions:getPlayerFactionTypes(thePlayer)
	local allowedType = false
	for k,v in pairs(allowedFactionTypes) do
		if ftypes[k] then
			allowedType = true
			break
		end
	end

	local duty = tonumber(getElementData(thePlayer, "duty"))
	if allowedType and (duty > 0) then
		for index, colorarray in ipairs(backupColours) do
			if (backupColours[index][5] ~= false) and (isElement(backupColours[index][5])) then
				triggerClientEvent(thePlayer, "createBackupBlip", backupColours[index][5], index, backupColours[index])
			end			
		end
	end
end
addEventHandler("onCharacterLogin", getRootElement(), function() setTimer(syncBlips, 2500, 1, source) end)
addEventHandler("onPlayerDuty", getRootElement(),  function() setTimer(syncBlips, 500, 1, source) end)
