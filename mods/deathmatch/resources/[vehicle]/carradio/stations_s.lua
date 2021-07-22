--MAXIME
mysql = exports.mysql
local streams = {}
function fetchStation()
	local preparedQ = "SELECT * FROM `radio_stations` WHERE `enabled`='1' AND (`expire_date` IS NULL) OR (`expire_date` > NOW()) ORDER BY `id` ASC"
	local mQuery = mysql:query(preparedQ)
	streams = {
		[0] = { "Radio Off", "" },
	}
	local count = 0
	while true do
		local row = mysql:fetch_assoc(mQuery)
		if not row then break end
		table.insert(streams, {row["station_name"], row["source"] } )
		count = count + 1
	end
	outputDebugString("Server: Fetched "..(count).." stations from db.")
	mysql:free_result(mQuery)
	return count
end

function resourceStart()
	fetchStation()
	setTimer(fetchStation, RADIO_SERVER_REFRESHRATE, 0)
end
addEventHandler("onResourceStart", resourceRoot, resourceStart)

function getStreams()
	return streams
end

function sendStationsToClient()
	if streams and #streams > 0 then
		outputDebugString("Server: sending "..(#streams).." stations to client.")
		triggerClientEvent(source, "getStationsFromServer", source, streams)
	end
end
addEvent("sendStationsToClient", true)
addEventHandler("sendStationsToClient", root, sendStationsToClient)

function forceSyncStationsToAllclients()
	local stations = fetchStation()
	local syncedClients, failedClients = 0, 0
	if stations and tonumber(stations) and tonumber(stations) > 0 then
		for i, player in pairs(getElementsByType("player")) do
			if triggerClientEvent(player, "getStationsFromServer", player, streams) then
				syncedClients = syncedClients + 1
			else
				failedClients = failedClients + 1
			end
		end
		exports.hud:sendBottomNotification(client, "Radio Station Manager", stations.." radio station(s) have been successfully synced to "..syncedClients.." online clients ("..failedClients.." failed).")
	else
		exports.hud:sendBottomNotification(client, "Radio Station Manager", "Could not synced any radio stations.")
	end
end
addEvent("forceSyncStationsToAllclients", true)
addEventHandler("forceSyncStationsToAllclients", root, forceSyncStationsToAllclients)