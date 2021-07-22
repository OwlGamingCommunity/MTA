--[[ SAPT Leader commands.
Add, edit or remove routes, lines or destinations ]]--

currentRoutes = { }
currentLines = { }
currentDestinations = { }

function showIBISAdmin(thePlayer, commandName)
	local isIn, _, lead = exports.factions:isPlayerInFaction(thePlayer, 64)
	if isIn then
		if lead then
			triggerClientEvent(thePlayer, "sapt:client_showIBISAdmin", thePlayer, currentRoutes, currentLines, currentDestinations)
		end
	end
end
addCommandHandler("ibisadmin", showIBISAdmin, false, false)
