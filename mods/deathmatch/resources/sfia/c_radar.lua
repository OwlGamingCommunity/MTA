radarBlipsShowing = false
local radarBlips = {}
local vmatCallsigns = {}
local icons ={
	--1 helicoper
	--2 small plane (dodo)
	--3 small jet (shamal)
	--4 medium plane (beagle)
	--5 big jet (at-400)
	--6 ground vehicle
	--[vehModel] = iconID
	[592] = "05", --Andromada
	[577] = "05", --AT-400
	[511] = "04", --Beagle
	[512] = "02", --Cropduster
	[593] = "02", --Dodo
	[520] = "03", --Hydra
	[553] = "04", --Nevada
	[476] = "02", --Rustler
	[519] = "03", --Shamal
	[460] = "02", --Skimmer
	[513] = "02", --Stuntplane
}
function getIcon(element)
	local elementType = getElementType(element)
	if elementType == "vehicle" then
		local vehicleType = getVehicleType(element)
		if vehicleType == "Helicopter" then
			return "01"
		elseif vehicleType == "Plane" then
			local model = getElementModel(element)
			if icons[model] then
				return icons[model]
			else
				return "00"
			end
		else
			return "06"
		end
	end
	return "00"
end
local iconSize = {
	["00"] = { w=22, h=22 },
	["01"] = { w=14, h=19 },
	["02"] = { w=21, h=19 },
	["03"] = { w=20, h=24 },
	["04"] = { w=23, h=25 },
	["05"] = { w=32, h=36 },
	["06"] = { w=9, h=15 },
}
local iconRot = {
	[0] = "13",
	[15] = "14",
	[30] = "15",
	[45] = "16",
	[60] = "17",
	[75] = "18",
	[90] = "19",
	[105] = "20",
	[120] = "21",
	[135] = "22",
	[150] = "23",
	[165] = "24",
	[180] = "01",
	[195] = "02",
	[210] = "03",
	[225] = "04",
	[240] = "05",
	[255] = "06",
	[270] = "07",
	[285] = "08",
	[300] = "09",
	[315] = "10",
	[330] = "11",
	[345] = "12",
	[360] = "13",
}
function getIconRotation(hdg)
	for k, v in pairs(iconRot) do
		local min = k - 7
		local max = k + 7
		if hdg >= min and hdg <= max then
			return v
		end
	end
	return false
end

function getCallsign(element)
	local callsign
	if getElementType(element) == "vehicle" then
		local vehicleType = getVehicleType(element)
		if vehicleType == "Plane" or vehicleType == "Helicopter" then
			local aircallsign = getElementData(element, "aircallsign")
			if aircallsign then
				callsign = tostring(aircallsign)
			else
				callsign = tostring(getVehiclePlateText(element))
			end
		else
			if vmatCallsigns[element] then
				local test = tostring(vmatCallsigns[element])
				if test ~= "1" and test ~= "false" then
					callsign = test
				end
			end
		end
	end
	return callsign or false
end

function tablelength(T) -- No you can't use # for this.
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

function stopBlips()
	for element, theBlip in pairs( radarBlips ) do
		removeRadarBlip(element)
	end
	radarBlips = {}
end
addEventHandler("onClientResourceStop", resourceRoot, stopBlips)

function renderRadar()
	for element, theBlip in pairs( radarBlips ) do
		--while true do
			if ( isElement( element ) ) then 
				if ( theBlip ) then
					if getElementDimension(element) == getElementDimension(getLocalPlayer()) then
						local started = getVehicleEngineState(element)
						if started then
							local vehicleType = getVehicleType(element)
							if vehicleType ~= "Plane" and vehicleType ~= "Helicopter" then
								local inVmatRange = false
								for k,v in ipairs(airportAreas) do
									if isElementWithinColShape(element, v[1]) then
										if getElementDimension(element) == v[2] then
											inVmatRange = true
											break
										end
									end
								end
								if inVmatRange then
									if not exports.customblips:isCustomBlipVisible(theBlip) then
										exports.customblips:setCustomBlipVisible(theBlip, true)
									end
								else
									exports.customblips:setCustomBlipVisible(theBlip, false)
									break
								end
							else
								if not exports.customblips:isCustomBlipVisible(theBlip) then
									exports.customblips:setCustomBlipVisible(theBlip, true)
								end
							end
							local x,y,z = getElementPosition(element)
							exports.customblips:setCustomBlipPosition(theBlip, x, y)
							local icon = getIcon(element)
							local path = ":sfia/radaricons/"..icon..".png"
							exports.customblips:setBlipPath(theBlip, path)
							local heading
							if icon ~= "00" then
								local rz,ry,rx = getElementRotation(element, "ZYX")
								heading = 360-math.floor(rx)
								exports.customblips:setCustomBlipRotation(theBlip, heading)
							end
							local callsign = getCallsign(element)
							exports.customblips:setBlipText(theBlip, callsign)
							if vehicleType == "Plane" or vehicleType == "Helicopter" then
								if not isVehicleOnGround(element) then
									local altitude = math.floor(z)
									--local speed = math.floor(getElementVelocity(element))
									local headingString = ""
									if heading then
										if heading == 0 then
											heading = 360
										end
										headingString = tostring(heading)
										if string.len(headingString) == 1 then
											headingString = "00"..headingString
										elseif string.len(headingString) == 2 then
											headingString = "0"..headingString
										end
									end
									exports.customblips:setBlipText2(theBlip, "ALT: "..tostring(altitude).."\nHDG: "..headingString, 2) --.."\nSPD: "..tostring(speed)
								else
									exports.customblips:setBlipText2(theBlip, false)
								end
							end
						else
							exports.customblips:setCustomBlipVisible(theBlip, false)
						end
					else
						exports.customblips:setCustomBlipVisible(theBlip, false)
					end
				end
			end
		--end
	end
end

function addRadarBlip(element)
	if not radarBlips[element] then
		local icon = getIcon(element)
		local rz,ry,rx = getElementRotation(element, "ZYX")
		local heading = 360-math.floor(rx)
		local iconRot = getIconRotation(heading)
		local path
		if not iconRot or icon == "00" then
			path = "radaricons/00.png"
		else
			path = "radaricons/"..icon.."-"..iconRot..".png"
		end
		callsign = getCallsign(element)
		radarBlips[element] = exports.customblips:createCustomBlip( 0, 0, iconSize[icon].w, iconSize[icon].h, path, 999999, false, element, callsign)
		exports.customblips:setBlipHideFromRadar(radarBlips[element], true)
	end
end
function removeRadarBlip(element)
	if radarBlips[element] then
		exports.customblips:destroyCustomBlip(radarBlips[element])
		radarBlips[element] = nil
	end
end

function showRadarBlips()
	radarBlipsShowing = true
	for k, v in ipairs(getElementsByType("vehicle")) do
		local vehicleType = getVehicleType(v)
		if vehicleType == "Plane" or vehicleType == "Helicopter" then --or exports.global:hasItem(v, 264)
			local started = getVehicleEngineState(v)
			if started then
				addRadarBlip(v)
			end
		end
	end
	triggerServerEvent("atcradar:serverVmatGet", getResourceRootElement(getThisResource()))
	addEventHandler("onClientRender", getRootElement(), renderRadar)
end
function hideRadarBlips()
	removeEventHandler("onClientRender", getRootElement(), renderRadar)
	for k, v in pairs(radarBlips) do
		removeRadarBlip(k)
	end
	radarBlips = {}
	radarBlipsShowing = false
end

addEventHandler("onClientVehicleEnter", getRootElement(),
	function(thePlayer, seat)
		local vehicleType = getVehicleType(source)
		if vehicleType == "Plane" or vehicleType == "Helicopter" then
			if thePlayer == getLocalPlayer() then
				if not radarBlipsShowing then
					showRadarBlips()
				end
			end
			if radarBlipsShowing then
				addRadarBlip(source)
			end
		end
	end
)
addEventHandler("onClientVehicleExit", getRootElement(),
	function(thePlayer, seat)
		if radarBlipsShowing then
			if thePlayer == getLocalPlayer() then
				hideRadarBlips()
			end
			local started = getVehicleEngineState(source)
			if not started then
				removeRadarBlip(source)
			end
		end
	end
)

function enterVmatVehicle(vehicle, thePlayer, callsign, seat)
	vmatCallsigns[vehicle] = callsign
	if thePlayer == getLocalPlayer() then
		if not radarBlipsShowing then
			showRadarBlips()
		end
	end
	if radarBlipsShowing then
		addRadarBlip(vehicle)
	end
end
addEvent("atcradar:vmatEnter", true)
addEventHandler("atcradar:vmatEnter", getResourceRootElement(getThisResource()), enterVmatVehicle)
function exitVmatVehicle(vehicle, thePlayer)
	if radarBlipsShowing then
		removeRadarBlip(vehicle)
	end
	if thePlayer == getLocalPlayer() then
		if radarBlipsShowing then
			hideRadarBlips()
		end
	end
end
addEvent("atcradar:vmatExit", true)
addEventHandler("atcradar:vmatExit", getResourceRootElement(getThisResource()), exitVmatVehicle)

function getVmatVehicles(vehicles)
	if radarBlipsShowing then
		for k,v in ipairs(vehicles) do
			vmatCallsigns[v[1]] = v[2]
			addRadarBlip(v[1])			
		end
	end
end
addEvent("atcradar:vmatGet", true)
addEventHandler("atcradar:vmatGet", getResourceRootElement(getThisResource()), getVmatVehicles)

function startBlips()
	local vehicle = getPedOccupiedVehicle(getLocalPlayer())
	if vehicle then
		local vehicleType = getVehicleType(vehicle)
		if vehicleType == "Plane" or vehicleType == "Helicopter" then
			if not radarBlipsShowing then
				showRadarBlips()
			end
		end
	end
end
addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), startBlips)