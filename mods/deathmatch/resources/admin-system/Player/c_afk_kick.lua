local pending = getRealTime().timestamp
local localPlayer = getLocalPlayer()
local armed = false

function checkForAFK()
	if (pending + 600) < getRealTime().timestamp and not armed then
		triggerServerEvent("admin:armAFK", resourceRoot)
		armed = true
	end
end
setTimer(checkForAFK, 60000, 0) -- Every minute check pls

function playerIsNotAway()
	pending = getRealTime().timestamp
	if armed then
		armed = false
		triggerServerEvent("admin:disarmAFK", resourceRoot)
	end
end

for _, v in pairs({"onClientCursorMove", "onClientConsole", "onClientClick", "onClientKey"}) do
	addEventHandler(v, root, playerIsNotAway)
end
