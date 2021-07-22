--    ____        __     ____  __            ____               _           __ 
--   / __ \____  / /__  / __ \/ /___ ___  __/ __ \_________    (_)__  _____/ /_
--  / /_/ / __ \/ / _ \/ /_/ / / __ `/ / / / /_/ / ___/ __ \  / / _ \/ ___/ __/
-- / _, _/ /_/ / /  __/ ____/ / /_/ / /_/ / ____/ /  / /_/ / / /  __/ /__/ /_  
--/_/ |_|\____/_/\___/_/   /_/\__,_/\__, /_/   /_/   \____/_/ /\___/\___/\__/  
--                                 /____/                /___/                 
--Client-side script: The grid
--Last updated 12.03.2015 by Exciter
--Copyright 2008-2015, The Roleplay Project (www.roleplayproject.com)

local colNorth, colWest, colSouth, colEast, water

local borderCoord, borderZone, crossingMarginFoot, crossingMarginVehicle = 5800, 100, 1, 10
--local borderCoord, borderZone, crossingMarginFoot, crossingMarginVehicle = 1000, 100, 1, 10

local simMapFilesCache = {}
local simMapLoaded = {}
local allSimMapsLoaded = {}

function createBorders()
	colNorth = createColRectangle(-borderCoord, borderCoord, borderCoord*2, borderZone)
	colWest = createColRectangle(-borderCoord-borderZone, -borderCoord-borderZone, borderZone, (borderCoord*2)+(borderZone*2))
	colSouth = createColRectangle(-borderCoord, -borderCoord-borderZone, borderCoord*2, borderZone)
	colEast = createColRectangle(borderCoord, -borderCoord-borderZone, borderZone, (borderCoord*2)+(borderZone*2))
	--colLoad = createColRectangle(-6000, -6000, 12000, 12000)
	activateColshapes()
end

function activateColshapes()
	addEventHandler("onClientColShapeHit", colNorth, hitNorth)
	addEventHandler("onClientColShapeHit", colWest, hitWest)
	addEventHandler("onClientColShapeHit", colSouth, hitSouth)
	addEventHandler("onClientColShapeHit", colEast, hitEast)
	--addEventHandler("onClientColShapeHit", colLoad, hitLoad)
end
function deactivateColshapes()
	removeEventHandler("onClientColShapeHit", colNorth, hitNorth)
	removeEventHandler("onClientColShapeHit", colWest, hitWest)
	removeEventHandler("onClientColShapeHit", colSouth, hitSouth)
	removeEventHandler("onClientColShapeHit", colEast, hitEast)
	--removeEventHandler("onClientColShapeHit", colLoad, hitLoad)
end

function hitNorth(theElement, matchingDimension)
	if(getElementInterior(theElement) == 0) then
		if(theElement == getLocalPlayer()) then
			--deactivateColshapes()
			outputChatBox("NORTH")
			setToSim(theElement, "north")
		end
	end
end
function hitWest(theElement, matchingDimension)
	if(getElementInterior(theElement) == 0) then
		if(theElement == getLocalPlayer()) then
			--deactivateColshapes()
			outputChatBox("WEST")
			setToSim(theElement, "west")
		end
	end
end
function hitSouth(theElement, matchingDimension)
	if(getElementInterior(theElement) == 0) then
		if(theElement == getLocalPlayer()) then
			--deactivateColshapes()
			outputChatBox("SOUTH")
			setToSim(theElement, "south")
		end
	end
end
function hitEast(theElement, matchingDimension)
	if(getElementInterior(theElement) == 0) then
		if(theElement == getLocalPlayer()) then
			--deactivateColshapes()
			outputChatBox("EAST")
			setToSim(theElement, "east")
		end
	end
end
function hitLoad(theElement, matchingDimension)
	if(getElementInterior(theElement) == 0) then
		if(theElement == getLocalPlayer()) then
			--do something
		end
	end
end

function setToSim(element, direction)
	local vehicle = getPedOccupiedVehicle(element)
	if vehicle then
		if getVehicleController(vehicle) ~= element then
			--if the player is in a vehicle, but is not the driver, then do nothing, as the driver will trigger the sim crossing for the vehicle and everyone in it.
			return false
		end
	end
	if vehicle then
		element = vehicle
	end

	--Sim dimension format: XXYY
	local dimension = getElementDimension(element)
	if dimension == 0 then
		dimension = 5050
	end
	local newSim, x, y, z
	local oldX, oldY, oldZ = getElementPosition(element)

	local crossingMargin = 1
	if vehicle then
		local x0, y0, z0, x1, y1, z1 = getElementBoundingBox(vehicle)
		local boundingBox = {x0, y0, z0, x1, y1, z1}
		for k,v in ipairs(boundingBox) do
			if v > crossingMargin then
				crossingMargin = v
			end
		end
		crossingMargin = crossingMargin + 2
	else
		crossingMargin = crossingMarginFoot
	end

	if direction == "north" then
		newSim = dimension + 1
		x, y, z = oldX, -borderCoord+crossingMargin, oldZ
	elseif direction == "west" then
		newSim = dimension - 100
		x, y, z = borderCoord-crossingMargin, oldY, oldZ
	elseif direction == "south" then
		newSim = dimension - 1
		x, y, z = oldX, borderCoord-crossingMargin, oldZ
	elseif direction == "east" then
		newSim = dimension + 100
		x, y, z = -borderCoord+crossingMargin, oldY, oldZ
	end

	--world-wrap (simulated earth sphere)
	local s = tostring(newSim)
	local sl = s:len()
	if(sl == 1) then
		s = "000"..s
	elseif(sl == 2) then
		s = "00"..s
	elseif(sl == 3) then
		s = "0"..s
	end
	--local a,b,c,d = s:match("%d%d%d%d")
	--local a,b,c,d
	local splitchars = {}
	for i = 1, #s do
	    local res = s:sub(i,i)
	    table.insert(splitchars, res)
	end
	local a,b,c,d = splitchars[1],splitchars[2],splitchars[3],splitchars[4]

	local xx = a..b
	local yy = c..d
	local xxn = tonumber(xx)
	local yyn = tonumber(yy)
	if(xx == "99") then
		xx = "01"
	elseif(xx == "00") then
		xx = "98"
	end
	if(yy == "99") then
		yy = "01"
	elseif(yy == "00") then
		yy = "98"
	end
	--outputChatBox(tostring(xx).." and "..tostring(yy))
	newSim = tonumber(xx..yy)
	--outputChatBox(tostring(newSim))

	if newSim == 5050 then
		newSim = 0
	end

	local textres = "New sim: "..tostring(newSim)
	outputDebugString(textres)
	--outputChatBox(textres)
	local textres = "Coords: "..tostring(x)..","..tostring(y)..","..tostring(z).."."
	--outputDebugString(textres)
	--outputChatBox(textres)	

	if vehicle then
		triggerServerEvent("grid:serverSetToSim", getLocalPlayer(), vehicle, newSim, x, y, z, direction, dimension)
	else
		setElementPosition(element, x, y, z)
		setElementDimension(element, newSim)
		outputChatBox(tostring(getPlayerName(getLocalPlayer())).." traveled "..tostring(direction).." to sim "..tostring(newSim).." on foot (from "..tostring(dimension)..").")
		clientMovedToSim(false, newSim, x, y, z, direction, dimension)
	end
	if newSim == 0 then
		--restoreSA()
	else
		--cleanSim()
	end
	--activateColshapes()
end

function cleanSim(vehicle, newSim, x, y, z, dir, oldSim)
	updateLoadingStatus("Making space")
	for i = 550, 20000 do
	    removeWorldModel(i, 10000, 0, 0, 0, 0)
	end
	setOcclusionsEnabled(false)
	setWaterLevel(0)
	water = createWater(-2999, -2999, 0, 2999, -2999, 0, -2999, 2999, 0, 2999, 2999, 0)
	getMaps(vehicle, newSim, x, y, z, dir, oldSim)
end

function restoreSA()
	updateLoadingStatus("Restoring San Andreas")
	restoreAllWorldModels()
	exports.maps:restoreSA()
	--outputDebugString("SA restored")
	clientSimCrossingComplete(vehicle, newSim, x, y, z, dir, oldSim)
end

function getMaps(vehicle, newSim, x, y, z, dir, oldSim)
	updateLoadingStatus("Searching for maps")
	if allSimMapsLoaded[newSim] then
		mapsComplete(vehicle, newSim, x, y, z, dir, oldSim)
	else
		if simMapFilesCache[newSim] then
			mapsToDownload = #simMapFilesCache[newSim]
			mapsDownloaded = 0
			crossingValues = {
				["vehicle"] = vehicle,
				["newSim"] = newSim,
				["x"] = x,
				["y"] = y,
				["z"] = z,
				["dir"] = dir,
				["oldSim"] = oldSim,
			}
			updateLoadingStatus("Downloading "..tostring(mapsToDownload).." maps")
			for k,v in ipairs(simMapFilesCache[newSim]) do
				downloadFile(v)
			end
		else
			triggerServerEvent("grid:getSimMaps", root, vehicle, newSim, x, y, z, dir, oldSim)
		end
	end
end

function downloadMaps(vehicle, newSim, x, y, z, dir, oldSim, maps)
	updateLoadingStatus("Initializing maps download")
	simMapFilesCache[newSim] = {}
	if maps then
		mapsToDownload = #maps
		mapsDownloaded = 0
		crossingValues = {
			["vehicle"] = vehicle,
			["newSim"] = newSim,
			["x"] = x,
			["y"] = y,
			["z"] = z,
			["dir"] = dir,
			["oldSim"] = oldSim,
		}
		for k,v in ipairs(maps) do
			table.insert(simMapFilesCache[newSim], v)
		end
		updateLoadingStatus("Downloading "..tostring(mapsToDownload).." maps")
		for k,v in ipairs(simMapFilesCache[newSim]) do
			downloadFile(v)
		end
	else
		mapsComplete(vehicle, newSim, x, y, z, dir, oldSim)
	end
end
addEvent("grid:clientGetSimMaps", true)
addEventHandler("grid:clientGetSimMaps", root, downloadMaps)

function onMapDownloadFinish(file, success)
	if(source == resourceRoot) then
		local match = false
		newSim = crossingValues.newSim
		for k,v in ipairs(simMapFilesCache[newSim]) do
			if v == file then
				match = true
				break
			end
		end
		if match then
			spawnMap(file, newSim)
			mapsDownloaded = mapsDownloaded + 1
			if mapsDownloaded == mapsToDownload then
				mapsComplete(crossingValues.vehicle, crossingValues.newSim, crossingValues.x, crossingValues.y, crossingValues.z, crossingValues.dir, crossingValues.oldSim)
			else
				updateLoadingStatus("Downloading "..tostring(mapsToDownload - mapsDownloaded).." maps")
			end
			if not success then
				outputDebugString("grid: Failed to download map '"..tostring(file).."'.", 2)
			end
		end
	end
end
addEventHandler("onClientFileDownloadComplete", root, onMapDownloadFinish)

function mapsComplete(vehicle, newSim, x, y, z, dir, oldSim)
	clientSimCrossingComplete(vehicle, newSim, x, y, z, dir, oldSim)
end

function clientMovedToSim(vehicle, newSim, x, y, z, dir, oldSim)
	if vehicle then
		setElementFrozen(vehicle, true)
	else
		setElementFrozen(getLocalPlayer(), true)
	end
	showLoading(newSim)
	if newSim == 0 then
		restoreSA(vehicle, newSim, x, y, z, dir, oldSim)
	else
		cleanSim(vehicle, newSim, x, y, z, dir, oldSim)
	end
end
addEvent("grid:clientMovedToSim", true)
addEventHandler("grid:clientMovedToSim", root, clientMovedToSim)

function clientSimCrossingComplete(vehicle, newSim, x, y, z, dir, oldSim)
	hideLoading()
	if vehicle then
		setElementFrozen(vehicle, false)
	else
		setElementFrozen(getLocalPlayer(), false)
	end
end
addEvent("grid:clientSimCrossingComplete", true)
addEventHandler("grid:clientSimCrossingComplete", root, clientMovedToSim)

createBorders()

addEventHandler("onClientResourceStop", getResourceRootElement(getThisResource()),
	function(stoppedRes)
		restoreAllWorldModels()
	end
)