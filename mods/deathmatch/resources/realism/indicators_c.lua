local leftkey = "["
local rightkey = "]"
local bothkey = "="

function indicateLeft() triggerServerEvent("indicator:toggle", resourceRoot, "left") end
function indicateRight() triggerServerEvent("indicator:toggle", resourceRoot, "right") end
function indicateBoth() triggerServerEvent("indicator:toggle", resourceRoot, "both") end

local function addBinds()
	if getElementData(localPlayer, "bind_indicators") ~= "1" then
		bindKey ( leftkey, "down", indicateLeft )
		bindKey ( rightkey, "down", indicateRight )
		bindKey ( bothkey, "down", indicateBoth )
	else
		addCommandHandler("indicator_left", indicateLeft)
		addCommandHandler("indicator_right", indicateRight)
		addCommandHandler("indicator_both", indicateBoth)
	end
end

addEventHandler ( "onClientPlayerVehicleEnter", localPlayer, function(vehicle, seat)
	if seat == 0 then
		addBinds()
	end
end)

addEventHandler( "onClientResourceStart", resourceRoot, function()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if vehicle and getVehicleOccupant(vehicle, 0) == localPlayer then
		addBinds()
	end
end)

addEventHandler ( "onClientPlayerVehicleExit", localPlayer, function(vehicle, seat)
	unbindKey(leftkey, "down", indicateLeft )
	unbindKey(rightkey, "down", indicateRight)
	unbindKey(bothkey, "down", indicateBoth)

	removeCommandHandler("indicator_left")
	removeCommandHandler("indicator_right")
	removeCommandHandler("indicator_both")
end)
