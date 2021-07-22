local shipMoveProgress = {}
local shipMoveTimer = {}
local isShipSailing = {}
local shipDestination = {}

--colshape = createColCuboid(-2532, 1515, -7, 247, 53, 65)

--[[
local excludeModels = {
	[0] = true,	
}
local elements = getElementsWithinColShape(colshape)
outputChatBox(tostring(#elements).." elements.")

moveX, moveY, moveZ = 0, 50, 0

count = 0
for k,v in ipairs(elements) do
	local model = getElementModel(v)
	if not excludeModels[model] then
		outputChatBox(tostring(model))
		local x, y, z = getElementPosition(v)
		local rx, ry, rz = getElementRotation(v)
		local x = x + moveX
		local y = y + moveY
		local z = z + moveZ
		local object = createObject(model, x, y, z, rx, ry, rz, false)
		setElementInterior(object, 0)
		setElementDimension(object, 200)
		count = count + 1
	end
end

outputChatBox(tostring(count).." objects.")
--]]


--local ship = createObject(9585, -2426, 1679, 7, 0, 0, 0, false)
local ship = createObject(9585, 2684.5, -2269.1000976563, 7, 0, 0, 180, false)
--setElementDimension(ship, 200)
shipDestination[ship] = 1

--[[
local objects = {
	--model, x, y, z, rx, ry, rz
	{9586, -2.3, 0, 10.1, 0, 0, 0},
	{9590, 0, 0, 1.6, 0, 0, 0},
}
--]]
local objects = {
	--model, x, y, z, rx, ry, rz, lod
	{9619, 0, 0, 0, 0, 0, 0, 0}, --hull lod
	{9586, -2.28, 0, 10.1, 0, 0, 0}, --deck1
	--{9587, 8, 0, 16.6, 0, 0, 0}, --container1
	--{9588, 5.7, 0, 0.6, 0, 0, 0}, --container2
	{9590, 6.35, 0, 1.8, 0, 0, 0}, --deck2
	{9761, -1.4, 0, 20, 0, 0, 0}, --siderails
	{9584, -75.2, 0.01, 19.2, 0, 0, 0, 9620}, --bridge
	--{9620, -75.2, 0.01, 19.2, 0, 0, 0, true}, --bridge lod
	{9698, -63.7, -1.15, 22.1, 0, 0, 0}, --bridge2
	{9819, -60.5, 6.2, 26, 0, 0, 0}, --electronics1
	{9818, -60.3, 0, 26.7, 0, 0, 0}, --electronics2
}

for k,v in ipairs(objects) do
	local lod = false
	local lodModel
	if tonumber(v[8]) then
		if v[8] == 0 then
			lod = true
		end
		lodModel = v[8]
	end
	local object = createObject(v[1], 0, 0, 0, 0, 0, 0, lod)
	--setElementDimension(object, 200)
	attachElements(object, ship, v[2], v[3], v[4], v[5], v[6], v[7])
	if not lod and lodModel then
		local lodObject = createObject(lodModel, 0, 0, 0, 0, 0, 0, true)
		attachElements(lodObject, ship, v[2], v[3], v[4], v[5], v[6], v[7])
		setLowLODElement(object, lodObject)
	elseif lod then
		setLowLODElement(object, ship)
	end
end


local shipRoutes = {
	--FROM NOWHERE TO LS
	[1] = {
		--x, y, rz, speed
		{3066, 5000, 270, 1000}, --nowhere
		{3066, -1986, 270, 900000},
		{3002, -2228, 230, 30000},
		{2887, -2273, 199, 30000},
		{2685, -2284, 180, 30000},
		{2684.5, -2269.1000976563, 180, 60000}, --LS ISPS terminal
	},
	--FROM LS TO NOWHERE
	[2] = {
		--x, y, rz, speed
		{2684.5, -2269.1000976563, 180, 1000}, --LS ISPS terminal
		{2685, -2284, 180, 60000},
		{2947, -2284, 180, 60000},
		{3030, -2336, 130, 60000},

		{3066, -2465, 90, 60000},
		{3066, 5000, 90, 900000}, --nowhere
	},
}

function sailShip(ship, route)
	if shipRoutes[route] and not isShipSailing[ship] then
		isShipSailing[ship] = true
		shipDestination[ship] = route
		local theRoute = shipRoutes[route]
		local oldX, oldY, oldZ = getElementPosition(ship)
		local newX = theRoute[1][1]
		local newY = theRoute[1][2]
		local newZ = oldZ
		local newRot = theRoute[1][3]
		setElementPosition(ship, newX, newY, newZ)
		setElementRotation(ship, 0, 0, newRot)
		shipMoveProgress[ship] = 1
		moveShip(ship, route)
	end
end


function moveShip(ship, route)
	if tonumber(shipMoveProgress[ship]) then
		local progress = shipMoveProgress[ship] + 1
		--outputDebugString("checkpoint "..tostring(progress))
		local theRoute = shipRoutes[route]
		local checkpoint = theRoute[progress]
		if checkpoint then
			local oldX, oldY, oldZ = getElementPosition(ship)
			local rx, ry, rz = getElementRotation(ship)
			local newX = checkpoint[1]
			local newY = checkpoint[2]
			local newZ = oldZ
			local newRot = -(rz - checkpoint[3])
			local newSpeed = checkpoint[4]
			moveObject(ship, newSpeed, newX, newY, newZ, 0, 0, newRot)
			shipMoveTimer[ship] = setTimer(moveShip, newSpeed, 1, ship, route)
			shipMoveProgress[ship] = shipMoveProgress[ship] + 1
		else
			shipReachedDestination(ship, route)
		end
	end
end

function shipReachedDestination(ship, route)
	--outputChatBox("Destination reached.")
	isShipSailing[ship] = false
end

function startShip(thePlayer, commandName, route)
	if tonumber(route) then
		if exports.integration:isPlayerScripter(thePlayer) then
			route = tonumber(route)
			if shipDestination[ship] then
				if shipDestination[ship] ~= route then
					sailShip(ship, route)
				end
			end
		end
	end
end
addCommandHandler("sailship", startShip)

--sailShip(ship, 2)