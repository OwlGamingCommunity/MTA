mods = {}

function showSpeedToAdmins(velocity)
	kph = math.ceil(velocity * 1.609344)
	exports.global:sendMessageToAdmins("[Possible Speedhack/HandlingHack] " .. getPlayerName(client) .. ": " .. velocity .. "Mph/".. kph .." Kph")
end
addEvent("alertAdminsOfSpeedHacks", true)
addEventHandler("alertAdminsOfSpeedHacks", getRootElement(), showSpeedToAdmins)

function showDMToAdmins(kills)
	exports.global:sendMessageToAdmins("[Possible DeathMatching] " .. getPlayerName(client) .. ": " .. kills .. " kills in <=2 Minutes.")
end
addEvent("alertAdminsOfDM", true)
addEventHandler("alertAdminsOfDM", getRootElement(), showDMToAdmins)

-- [MONEY HACKS]
function scanMoneyHacks()
	local tick = getTickCount()
	local hackers = { }
	local hackersMoney = { }
	local counter = 0

	local players = exports.pool:getPoolElementsByType("player")
	for key, value in ipairs(players) do
		local logged = getElementData(value, "loggedin")
		if (logged==1) then
			if not (exports.integration:isPlayerTrialAdmin(value)) then -- Only check if its not an admin...

				local money = getPlayerMoney(value)
				local truemoney = exports.global:getMoney(value)
				if (money) then
					if (money > truemoney) then
						counter = counter + 1
						hackers[counter] = value
						hackersMoney[counter] = (money-truemoney)
					end
				end
			end
		end
	end
	local tickend = getTickCount()

	local theConsole = getRootElement()
	for key, value in ipairs(hackers) do
		local money = hackersMoney[key]
		local accountID = getElementData(value, "account:id")
		local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
		outputChatBox("AntiCheat: " .. targetPlayerName .. " was auto-banned for Money Hacks. (" .. tostring(money) .. "$)", getRootElement(), 255, 0, 51)
	end
end
setTimer(scanMoneyHacks, 3600000, 0) -- Every 60 minutes

function outputModInfo(thePlayer, command, targetPlayer)
	if not exports.integration:isPlayerTrialAdmin(thePlayer) then return end
	if not targetPlayer then
		outputChatBox("SYNTAX: /" .. command .. " [Player Partial Name/ID]", thePlayer, 255, 194, 14)
		return
	else
		local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
		if targetPlayer then
			if mods[targetPlayer] then
				for filename, modList in pairs(mods[targetPlayer]) do
					outputChatBox("===== "..filename.." =====", thePlayer, 255, 194, 14)
					-- Print details on each modification
					for idx,item in ipairs(modList) do
						outputChatBox( idx .. ") id: " .. item.id .. " name: " .. item.name, thePlayer, 255, 194, 14)
						if item.sizeX then
							outputChatBox( "size: " .. item.sizeX .. "," .. item.sizeY .. "," .. item.sizeZ, thePlayer, 255, 194, 14)
							outputChatBox( "originalSize: " .. item.originalSizeX .. "," .. item.originalSizeY .. "," .. item.originalSizeZ, thePlayer, 255, 194, 14)
						end
						if item.length then
							outputChatBox( "length: " .. item.length .. " md5: " .. item.md5, thePlayer, 255, 194, 14)
						end
					end
				end
			else
				outputChatBox("No modifications found.", thePlayer, 255, 194, 14)
			end
		else
			outputChatBox("Player not found.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("mods", outputModInfo)

function handleOnPlayerModInfo ( filename, modList )
	if not mods[source] then
		mods[source] = {}
	end
	mods[source][filename] = modList
end
addEventHandler ( "onPlayerModInfo", getRootElement(), handleOnPlayerModInfo )

-- Ensure no one gets missed when the resource is (re)started
addEventHandler( "onResourceStart", resourceRoot,
    function()
        for _,plr in ipairs( exports.pool:getPoolElementsByType("player") ) do
            resendPlayerModInfo( plr )
        end
    end
)
