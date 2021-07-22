

local staticMarkers1 = {}
local staticBlips1 = {}
local bufferRoutes = {}

function displayAllMarkers(tempRoutes)
	if tempRoutes then
		clearAllMarkers()
		bufferRoutes = tempRoutes
		local timerDelay =0
		for i = 1, #tempRoutes do 
			timerDelay = timerDelay + 1000
			setTimer(function ()
				displayRoute(tempRoutes[i], i)
			end, timerDelay, 1)
		end
	end
end
addEvent( "job-system-trucker:displayAllMarkers", true)
addEventHandler("job-system-trucker:displayAllMarkers", root , displayAllMarkers)

function displayRoute(route, id)
	local x, y, z = route[1], route[2], route[3]
	local radius, r, g, b, trans = 4, 255, 200, 0, 100
	
	if tonumber(route[8]) and (tonumber(route[8]) > 0) then
		radius, r, g, b, trans = 20, 219, 48, 0, 200
	end
	
	staticBlips1[id] = createBlip(x, y, z, 0, 2, r, g, b)
	staticMarkers1[id] = createMarker(x, y, z, "checkpoint", radius, r, g, b, trans)
	addEventHandler("onClientMarkerHit", staticMarkers1[id], showRouteInfo)
	addEventHandler("onClientMarkerLeave", staticMarkers1[id], cleanID)
end

function clearAllMarkers()
	if exports.integration:isPlayerTrialAdmin(getLocalPlayer()) then
		local count = 0
		for i = 1, #staticMarkers1 do
			if staticMarkers1[i] then 
				destroyElement(staticMarkers1[i])
				staticMarkers1[i] = nil
				count = count + 1
			end
			if staticBlips1[i] then
				destroyElement(staticBlips1[i])
				staticBlips1[i] = nil
			end
		end
		bufferRoutes = nil
		outputChatBox("Cleared "..count.." truck markers.")
	end
end
addCommandHandler("clearallmarkers", clearAllMarkers)

function showRouteInfo(player, dim)
	for i = 1, #staticMarkers1 do 
		if staticMarkers1[i] and (player == getLocalPlayer() and isElementWithinMarker ( player, staticMarkers1[i] ) )then
			outputChatBox("     Order ID #"..bufferRoutes[i][7].." - "..(bufferRoutes[i][6] or "Unknown").." (Int ID#"..bufferRoutes[i][8]..", "..(bufferRoutes[i][4] or "0").." kg)")
			setElementData(player, "truckerjob:markerID", bufferRoutes[i][7])
			setElementData(player, "truckerjob:markerIndex", i)
			break
		end
	end
end

function cleanID(player)
	if player == getLocalPlayer() then
		setElementData(player, "truckerjob:markerID", false)
		setElementData(player, "truckerjob:markerIndex", false)
	end
end

function delTruckerMarker( cm, id) 
	local sourcePlayer = getLocalPlayer()
	
	if not exports.integration:isPlayerScripter(sourcePlayer) then
		outputChatBox("Only Full Admins and above can access /"..cm..".", 255,0 ,0 )
		return false  
	end     
	
	local markerIndex = getElementData(sourcePlayer, "truckerjob:markerIndex")
	local markerID = getElementData(sourcePlayer, "truckerjob:markerID")
	if not markerIndex or not markerID then
		outputChatBox("You're not at the marker. Please use /showAllTruckMarkers first.", 255, 0 ,0)
		return false
	end
	
	if destroyElement(staticMarkers1[markerIndex]) then
		triggerServerEvent("truckerjob:delMarker", sourcePlayer, markerID)	
		cleanID(sourcePlayer)
	end 
end
addCommandHandler("deltruckmarker", delTruckerMarker)

function getMarkerIndexFromID(id)
	for i = 1, #bufferRoutes do 
		if bufferRoutes[i] and bufferRoutes[i][id]  == id then
			return i
		end
	end
	return false
end