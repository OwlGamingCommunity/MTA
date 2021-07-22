local function canSaveDescription(client, theVehicle)
	local playerId = getElementData(client, "dbid")
	local theVehicle = getPedOccupiedVehicle(client)
	local dbid = getElementData(theVehicle, "dbid")
	local factionId = getElementData(theVehicle, "faction")
	local owner = getElementData(theVehicle, "owner")

	return exports.global:hasItem(client, 3, dbid) 
		or owner == playerId
		or exports.global:hasItem(theVehicle, 3, dbid)
		or exports.factions:isPlayerInFaction(client, factionId)
		or exports.integration:isPlayerTrialAdmin(client)
end

function saveToDescription(descriptions, theVehicle)
	if not canSaveDescription(client, theVehicle) then return end

	local dbid = getElementData(theVehicle, "dbid")
	local acceptedQuerys = { }
	connection = exports.mysql:getConn("mta")
	for i = 1, 5 do
		dbExec(connection, "UPDATE `vehicles` SET `??` = ? WHERE id = ?", "description"..i, tostring(descriptions[i]), tostring(dbid))
	
		exports.anticheat:changeProtectedElementDataEx(theVehicle, "description:"..i, descriptions[i], true)
		acceptedQuerys[i] = true

	end
	if descriptions[6] then
		dbExec(connection, "UPDATE `vehicles` SET `descriptionadmin` = ? WHERE id = ?", tostring(descriptions[6]), dbid )
		exports.anticheat:changeProtectedElementDataEx(theVehicle, "description:admin", descriptions[6], true)
	end

	outputChatBox("Description saved succesfully.", source, 0, 255, 0)
	
	
end
addEvent("saveDescriptions", true)
addEventHandler("saveDescriptions", getRootElement(), saveToDescription)
