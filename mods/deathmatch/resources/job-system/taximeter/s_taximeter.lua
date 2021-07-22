--Server-side script: Taximeter
--Created by Exciter, anumaz, 04.05.2014
--Last updated 05.05.2014 by Exciter
--Released as open source. This header should remain intact. Otherwise no use restrictions.

local root = getRootElement()

addEventHandler("onVehicleEnter", root,
		function (player, seat)
				if taxiModels[getElementModel(source)] then
						local theVehicle = source
					
						local fare = getElementData(theVehicle, "taximeter.fare")
						local distance = getElementData(theVehicle, "taximeter.distance")
						local running = getElementData(theVehicle, "taximeter.running") or false
						
						if not fare then
							setElementData(theVehicle, "taximeter.fare", defaultfare)
							fare = defaultfare
						end
						if not distance then
							setElementData(theVehicle, "taximeter.distance", 0)
							distance = 0
						end
						
						local x,y,z = getElementPosition(theVehicle)
						local pos = {x,y,z}
						local light = isVehicleTaxiLightOn(theVehicle)
						
						triggerClientEvent(player, "taximeter:initialize", theVehicle, seat, distance, running, pos, fare, light)
				end
		end
)
--[[
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()),
		function (startedRes)
				local players = getElementsByType("player")
				for k,player in ipairs(players) do
					if isPedInVehicle(player) then
						local theVehicle = getPedOccupiedVehicle(player)
						if taxiModels[getElementModel(theVehicle)] then
								local fare = getElementData(theVehicle, "taximeter.fare")
								local distance = getElementData(theVehicle, "taximeter.distance")
								local running = getElementData(theVehicle, "taximeter.running") or false
								
								if not fare then
									setElementData(theVehicle, "taximeter.fare", defaultfare)
									fare = defaultfare
								end
								if not distance then
									setElementData(theVehicle, "taximeter.distance", 0)
									distance = 0
								end
								
								local x,y,z = getElementPosition(theVehicle)
								local pos = {x,y,z}
								local light = isVehicleTaxiLightOn(theVehicle)
								
								triggerClientEvent(player, "taximeter:initialize", theVehicle, seat, distance, running, pos, fare, light)
						end
					end
				end
		end
)
--]]

addEvent("taximeter:clientStarted", true)
addEventHandler("taximeter:clientStarted", root,
		function ()
			local player = client
			if isPedInVehicle(player) then
				local theVehicle = getPedOccupiedVehicle(player)
				if taxiModels[getElementModel(theVehicle)] then
						local fare = getElementData(theVehicle, "taximeter.fare")
						local distance = getElementData(theVehicle, "taximeter.distance")
						local running = getElementData(theVehicle, "taximeter.running") or false
						
						if not fare then
							setElementData(theVehicle, "taximeter.fare", defaultfare)
							fare = defaultfare
						end
						if not distance then
							setElementData(theVehicle, "taximeter.distance", 0)
							distance = 0
						end
						
						local x,y,z = getElementPosition(theVehicle)
						local pos = {x,y,z}
						local seat = getPedOccupiedVehicleSeat(player)
						local light = isVehicleTaxiLightOn(theVehicle)
						triggerClientEvent(player, "taximeter:initialize", theVehicle, seat, distance, running, pos, fare, light)
				end
			end
		end
)

function sendTaximeterSync(distance, running, pos, ignoreCheck)
	--outputDebugString("sendTaximeterSync("..tostring(distance)..", "..tostring(running)..", "..tostring(pos)..")")
	local theVehicle = source
	local driver = client
	--outputDebugString("theVehicle="..tostring(theVehicle).." driver="..tostring(driver))
	--outputDebugString(tostring(getPlayerName(getVehicleController(theVehicle))).."=="..tostring(getPlayerName(driver)))
	if(ignoreCheck or getVehicleController(theVehicle) == driver) then
		setElementData(theVehicle, "taximeter.distance", tonumber(distance) or 0)
		setElementData(theVehicle, "taximeter.running", running)
		--outputDebugString("running:"..tostring(running))
		local passengers = getVehicleOccupants(theVehicle)
		for seat, player in pairs(passengers) do
			if player ~= driver then
				triggerClientEvent(player, "taximeter:sync", theVehicle, distance, running, pos)
			end
		end
	end
end
addEvent("taximeter:sendSync", true)
addEventHandler("taximeter:sendSync", root, sendTaximeterSync)

function updateFare(newFare)
	local theVehicle = source
	local driver = client
	if(getVehicleController(theVehicle) == driver) then
		setElementData(theVehicle, "taximeter.fare", tonumber(newFare))
		local passengers = getVehicleOccupants(theVehicle)
		for seat, player in pairs(passengers) do
			if player ~= driver then
				triggerClientEvent(player, "taximeter:sendFare", theVehicle, newFare)
			end
		end		
	end
end
addEvent("taximeter:setFare", true)
addEventHandler("taximeter:setFare", root, updateFare)

function resetMeter()
	local driver = client
	local theVehicle = getPedOccupiedVehicle(driver)
	if(getVehicleController(theVehicle) == driver) then
		setElementData(theVehicle, "taximeter.distance", 0)
		local passengers = getVehicleOccupants(theVehicle)
		for seat, player in pairs(passengers) do
			if player ~= driver then
				triggerClientEvent(player, "taximeter:resetMeter", theVehicle)
			end
		end		
	end
end
addEvent("taximeter:resetMeter", true)
addEventHandler("taximeter:resetMeter", root, resetMeter)

function toggleTaxiLight(state)
	local driver = client
	local theVehicle = getPedOccupiedVehicle(driver)
	if(getVehicleController(theVehicle) == driver) then
		setVehicleTaxiLightOn(theVehicle, state)
	end
end
addEvent("taximeter:setLight", true)
addEventHandler("taximeter:setLight", root, toggleTaxiLight)
