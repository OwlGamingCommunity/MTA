-- configs
local scriptversion = "0.1"
local author = "anumaz"
-- vars

-- start of script

-- If the frequency is within that newly created table (from sql), then return true
function getChannelRestrictions(freq)
	local qh = dbQuery(mysql:getConn('mta'), "SELECT `limitedto` FROM `restricted_freqs` WHERE `frequency`= ?", freq)
	local results = dbPoll(qh, 10000)

	return results
end

function hasChannelAccess(player, channel)
	local restrictions = getChannelRestrictions(channel)

	if not restrictions or #restrictions == 0 then
		return true
	end

	for _, restriction in pairs(restrictions) do
		if exports.factions:isPlayerInFaction(player, tonumber(restriction['limitedto'])) then
			return true
		end
	end

	return false
end

function openRestrictedFreqs(thePlayer)
	-- Is he an admin?
	if not exports.integration:isPlayerTrialAdmin(thePlayer) then
		return nil
	end

	local frequencies = exports.mysql:query("SELECT `id`, `frequency`, (SELECT `name` FROM `factions` WHERE `factions`.`id`=`restricted_freqs`.`limitedto`) AS `faction`, `addedby` FROM `restricted_freqs`")
	local freqs = {}
	while true do 
		local row = exports.mysql:fetch_assoc(frequencies)
		if not row then
			break
		end
		row.addedby = exports.cache:getUsernameFromId(row.addedby) or "Unknown"
		--outputChatBox("#"..row["id"]..". Freq: '"..row["frequency"].."' Limited to: '"..row["faction"].."' Added by: '"..row["addedby"].."' .", thePlayer)
		table.insert(freqs, row)
	end

	triggerClientEvent(thePlayer, "openRestrictedFreqs", thePlayer, freqs)
	--[[ if #freqs > 0 then
		triggerClientEvent(thePlayer, "openRestrictedFreqs", thePlayer, freqs)
	else
		outputChatBox("Nothing to display .", thePlayer)
	end ]]--
end
addCommandHandler("restrictfreqs", openRestrictedFreqs)
addCommandHandler("rf", openRestrictedFreqs)

function addNewFrequency(thePlayer, commandName, freq, factionID)
	-- Is he an admin?
	if not exports.integration:isPlayerTrialAdmin(thePlayer) then
		return nil
	end

	-- Anything provided? Is it a number?
	if not freq or not factionID or not tonumber(factionID) then
		outputChatBox("SYNTAX: /" .. commandName .." [frequency] [factionID]", thePlayer)
		return nil
	end

	-- Does that faction exist?
	local theTeam = exports.pool:getElement("team", factionID)	
	if not theTeam then
		outputChatBox("That faction ID does not exist. Please check /showfactions", thePlayer)
		return nil
	end

	local accountID = getElementData(thePlayer, "account:id")
	if exports.mysql:query_free("INSERT INTO `restricted_freqs` SET `frequency`='"..exports.global:toSQL(freq).."', `limitedto`='"..exports.global:toSQL(factionID).."', `addedby`='"..accountID.."'") then
		outputChatBox("A new frequency has been added to the restricted list:", thePlayer)
		outputChatBox("Frequency: " ..freq.." Restricted to faction: " ..getTeamName(theTeam), thePlayer)
	else
		outputChatBox("ERROR: An error occured when trying to update database. Contact a scripter.", thePlayer, 255, 0, 0)
	end
end
addCommandHandler("addfreq", addNewFrequency)
addEvent("addNewFrequency", true)
addEventHandler("addNewFrequency", root, addNewFrequency)

function displayFrequencies(thePlayer)
	-- Is he an admin?
	if not exports.integration:isPlayerTrialAdmin(thePlayer) then
		return nil
	end

	local frequencies = exports.mysql:query("SELECT `id`, `frequency`, (SELECT `name` FROM `factions` WHERE `factions`.`id`=`restricted_freqs`.`limitedto`) AS `faction`, `addedby` FROM `restricted_freqs`")
	local count = 0
	while true do 
		local row = exports.mysql:fetch_assoc(frequencies)
		if not row then
			break
		end
		count = count + 1
		outputChatBox("#"..row["id"]..". Freq: '"..row["frequency"].."' Limited to: '"..row["faction"].."' Added by: '"..exports.cache:getUsernameFromId(row["addedby"]).."' .", thePlayer)
	end
	if count <=0 then
		outputChatBox("None", thePlayer)
	end
end
addCommandHandler("freqs", displayFrequencies)

function deleteFrequency(thePlayer, commandName, id)
	-- Is he an admin?
	if not exports.integration:isPlayerTrialAdmin(thePlayer) then
		return nil
	end

	-- Is there any id providen, is it a number?
	if not id and not tonumber(id) then
		outputChatBox("SYNTAX: /" .. commandName .. " [id] -- Use /freqs to display frequency IDs.", thePlayer)
		return nil
	end

	local freq = exports.mysql:query_fetch_assoc("SELECT `frequency` FROM `restricted_freqs` WHERE `id`='"..id.."'")
	-- Is the frequency even restricted?
	if not freq or not freq["frequency"] then
		outputChatBox("That frequency ID is not restricted. Use /freqs.", thePlayer)
		return nil
	end

	if exports.mysql:query_free("DELETE FROM `restricted_freqs` WHERE `id`='"..id.."'") then
		outputChatBox("Frequency with id #" ..id .. " was succesfully deleted.", thePlayer)
	else
		outputChatBox("ERROR: A mysql error happened. Contact a scripter with error code: #RF101", thePlayer, 255, 0, 0)
	end
end
addCommandHandler("delfreq", deleteFrequency)
addEvent("deleteFrequency", true)
addEventHandler("deleteFrequency", root, deleteFrequency)