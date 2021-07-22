function giveDuplicatedKey(thePlayer, itemID, value, cost)
	if thePlayer and itemID and value and cost then
		exports.global:giveItem(thePlayer, tonumber(itemID), tonumber(value))
		exports.global:takeMoney(thePlayer, cost)
	end
end
addEvent("locksmithNPC:givekey", true)
addEventHandler("locksmithNPC:givekey", resourceRoot, giveDuplicatedKey)

function getFactionInteriors()
	local factionInteriors = {}
	local possibleInteriors = exports.pool:getPoolElementsByType("interior")

	for key, interior in pairs(possibleInteriors) do
		for i, k in pairs(getElementData(client, "faction")) do
			if exports.factions:hasMemberPermissionTo(client, i, "manage_interiors") then
				if getElementData(interior, "status").faction == i then
					table.insert(factionInteriors, getElementData(interior, "dbid"))
				end
			end	
		end
	end
	triggerClientEvent("locksmithNPC:setFactionInteriors", client, factionInteriors)
end
addEvent("locksmithNPC:getFactionInts", true)
addEventHandler("locksmithNPC:getFactionInts", resourceRoot, getFactionInteriors)

