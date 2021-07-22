local drivers = {}
local blips = {}
local acCheck = { }

function updateBusBlips(line)
	local driversonline = 0
	for k, v in ipairs(drivers[line]) do
		driversonline = driversonline + #v
	end

	if driversonline > 0 then
		for k, v in ipairs(drivers[line]) do
			if #(drivers[line][k-1] or {}) + #v > 0 then
				setBlipColor( blips[line][k], 127, 255, 63, 127 )
			else
				setBlipColor( blips[line][k], 255, 255, 63, 127 )
			end
		end
	else
		for k, v in ipairs(blips[line]) do
			setBlipColor( v, 255, 63, 63, 127 )
		end
	end
end

function removeDriver()
	for k, v in ipairs(drivers) do
		for key, value in ipairs(v) do
			for i, player in pairs(value) do
				if player == source then
					table.remove(value, i)
				end
			end
		end
	end
end

function removeDriverOnAllLines()
	removeDriver()
	for line, v in pairs(drivers) do
		updateBusBlips(line)
	end
end
addEventHandler( "onPlayerQuit", getRootElement(), removeDriverOnAllLines )
addEventHandler("onCharacterLogin", getRootElement(), removeDriverOnAllLines )

function doPay(client)
	local hours = tonumber(getElementData(client, "hoursplayed"))
	local rate = 50
	local hoursrate = math.floor(hours*(rate*0.03))

	if hours>=10 then
		rate = rate-hoursrate
		if rate < 10 then
			rate = 10
		end
	end

	exports.global:giveMoney(client, rate)
end

function payBusDriver(line, stop)
	local seat = getPedOccupiedVehicleSeat(client)
	if not seat or seat ~= 0 then
		return
	end

	if (acCheck[client] == stop) and (stop ~= -1) then
		triggerBusCheatDetection(client,stop)
	end

	acCheck[client] = stop
	if stop == -2 then
		removeDriver()
		doPay(client)
	elseif stop == -1 then
		removeDriverOnAllLines()
		return
	elseif stop == 0 then
		table.insert( drivers[line][1], client )
	else
		doPay(client)

		if drivers[line][stop+1] then
			removeDriver()
			table.insert( drivers[line][stop+1], client )
		end
	end
	updateBusBlips(line)
end
addEvent("payBusDriver",true)
addEventHandler("payBusDriver", getRootElement(), payBusDriver)

function triggerBusCheatDetection(thePlayer,stop)
	outputDebugString("[payBusDriver]".. getPlayerName(thePlayer) .. " " .. getPlayerIP(thePlayer) .. " used the same stop twice ("..stop..")")
end

function busAdNextStop(line, stop)
	local seat = getPedOccupiedVehicleSeat(source)
	if not seat or seat ~= 0 then
		return
	end

	if(stop<#g_bus_routes[line].stops)then
		exports.hud:sendBottomNotification(source, "Bus Operator", "Current Stop: [".. g_bus_routes[line].stops[stop] .. "]     Next Stop: [".. g_bus_routes[line].stops[stop+1] .. "] ")
	end
end
addEvent("busAdNextStop",true)
addEventHandler("busAdNextStop", getRootElement(), busAdNextStop)

function takeBusFare(thePlayer)
	exports.global:takeMoney(source, 5)
	exports.global:giveMoney(thePlayer, 5)
end
addEvent("payBusFare", true)
addEventHandler("payBusFare", getRootElement(), takeBusFare)

function ejectPlayerFromBus()
	exports.anticheat:changeProtectedElementDataEx(source, "realinvehicle", 0, false)
	removePedFromVehicle(source)
end
addEvent("removePlayerFromBus", true)
addEventHandler("removePlayerFromBus", getRootElement(), ejectPlayerFromBus)

-- BUS ROUTES BLIPS
function createBusBlips( )
	for routeID, route in ipairs( g_bus_routes ) do
		blips[routeID] = {}
		drivers[routeID] = {}
		for pointID, point in ipairs( route.points ) do
			if point[4] and #route.points ~= pointID then
				local stop = #blips[routeID]+1
				blips[routeID][stop] = createBlip( point[1], point[2], point[3], 0, 1, 255, 63, 63, 127, -5, 65 )
				drivers[routeID][stop] = {}
			end
		end
	end
end
addEventHandler( "onResourceStart", getResourceRootElement(), createBusBlips )
