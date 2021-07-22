local tick = getTickCount()

-- /astats
function getAdminStats(thePlayer, commandName)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		outputChatBox("-=-=-=-=-=-=-=-=-= STATISTICS =-=-=-=-=-=-=-=-=-", thePlayer, 255, 194, 14)
		
		-- CURRENT PLAYERS
		local playerCount = getPlayerCount()
		local maxCount = getMaxPlayers()
		outputChatBox("     Current Players: " .. playerCount .. "/" .. maxCount , thePlayer, 255, 194, 14)
		
		-- UPTIME
		local currTick = getTickCount()
		local uptimeMilliseconds = currTick - tick
		
		local minutes = math.floor((uptimeMilliseconds/1000)/60)
		
		outputChatBox("     Uptime: " .. minutes .. " Minutes", thePlayer, 255, 194, 14)
		
		-- Queries:
		local queries = exports.mysql:returnQueryStats()
		outputChatBox("     SQL Queries: " .. queries ,  thePlayer, 255, 194, 14)  

		-- Cache hits
		local cacheUsed = exports.cache:stats()
		outputChatBox("     Player Cache hits: " .. cacheUsed ,  thePlayer, 255, 194, 14)  
		
		-- VEHICLES
		outputChatBox("     Vehicles: " .. #exports.pool:getPoolElementsByType("vehicle") , thePlayer, 255, 194, 14)
	end
end
addCommandHandler("astats", getAdminStats)