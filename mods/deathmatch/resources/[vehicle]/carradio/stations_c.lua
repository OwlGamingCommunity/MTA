streams = {
	[0] = { "Radio Off", "" },
}

function getStreams()
	return streams
end

function getStationsFromServer(streamsFromServer)
	if streamsFromServer and #streamsFromServer > 0 then
		streams = streamsFromServer
		outputDebugString("Client: recieved "..(#streamsFromServer).." stations from server.")
	end
end
addEvent("getStationsFromServer", true)
addEventHandler("getStationsFromServer", root, getStationsFromServer)

function sendStationsRequestToServer()
	triggerServerEvent("sendStationsToClient", localPlayer)
end
addCommandHandler("getstations", sendStationsRequestToServer)

function resourceStart()
	setTimer(sendStationsRequestToServer, 5000, 1)
	setTimer(sendStationsRequestToServer, RADIO_CLIENT_REFRESHRATE, 0)
end
addEventHandler("onClientResourceStart", resourceRoot, resourceStart)