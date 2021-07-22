local spam = {}
local uTimers = {}
local antispamCooldown = 5000
local LOG_COMMANDS = false
local resourceCache = false

function onCmd( commandName )
	if LOG_COMMANDS and not resourceCache then
		resourceCache = {}
		--store/sort commands in the table where key is resource and value is table with commands
		for _, subtable in pairs( getCommandHandlers() ) do
			local commandName = subtable[1]
			local theResource = subtable[2]
					
			resourceCache[commandName] = getResourceName(theResource)
		end
	end

	if not getElementData(source, "cmdDisabled") and commandName ~= 'Next' and commandName ~= 'Previous' then
		spam[source] = tonumber(spam[source] or 0) + 1
		local playerName = getPlayerName( source ):gsub('_', ' ')
		if spam[source] == 25 then
			outputChatBox('   Please try not to spam too much or you will have your commands disabled.', source, 255,0,0)
			exports.global:sendMessageToAdmins("[ANTI-CMDSPAM] Detected Player '" .. playerName .. "' for possibly spamming "..tonumber(spam[source]).." commands / "..(antispamCooldown/1000).." seconds. ('/"..commandName.."').")
		elseif spam[source] > 50 then
			exports.global:sendMessageToAdmins("[ANTI-CMDSPAM] Player '" .. playerName .. "' has had his commands disabled spamming "..tonumber(spam[source]).." commands / "..(antispamCooldown/1000).." seconds. ('/"..commandName.."').")
			outputChatBox('   Your command usage has been disabled.', source, 255,0,0)
			exports.anticheat:changeProtectedElementDataEx(source, "cmdDisabled", true)
			spam[source] = 0
		end
	
		if isTimer(uTimers[source]) then
			killTimer(uTimers[source])
		end
	
		uTimers[source] = setTimer(	function (source)
			spam[source] = 0
			
			if isElement(source) and getElementData(source, "cmdDisabled") then
				exports.anticheat:changeProtectedElementDataEx(source, "cmdDisabled", false)
			end
		end, antispamCooldown, 1, source)
		if LOG_COMMANDS then
			theResource = "Unknown"
			if resourceCache[commandName] ~= nil then
				theResource = resourceCache[commandName]
			end
			outputServerLog('[CMD] '.. playerName ..' executed command /'.. commandName ..' from ' .. theResource)
			outputDebugString('[CMD] '.. playerName ..' executed command /'.. commandName ..' from ' .. theResource)
		end
	else
		cancelEvent()
	end
end
addEventHandler('onPlayerCommand', root, onCmd)

function quitPlayer()
	spam[source] = nil
end
addEventHandler("onPlayerQuit", root, quitPlayer)