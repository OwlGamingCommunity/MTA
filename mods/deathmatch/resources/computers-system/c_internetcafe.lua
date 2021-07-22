wPedRightClick = nil
bTalkToPed, bClosePedMenu = nil
ax, ay = nil
closing = nil
sent=false
local models = {[2175]=true, [2190]=true,[2009]=true,[2008]=true,[11631]=true,[2198]=true,[2172]=true,[2193]=true,[2165]=true,[1998]=true,[1999]=true}

function isComputerModel(model)
	return models[model] or false
end

local function createComputerGUIEx()
	if getElementDimension(localPlayer) == 1 -- Los Santos Police Department, Pershing Square
	or getElementDimension(localPlayer) == 1483 -- State Police Department, Rodeo
	or getElementDimension(localPlayer) == 615 -- State Police Department, Rodeo, BCI Floor
	or getElementDimension(localPlayer) == 100 -- First Court of San Andreas, Pershing Square
	then
		createComputerGUI("Desktop Computer", "www.mdc.gov")
	else
		createComputerGUI("Desktop Computer")
	end
	triggerServerEvent("computers:on", localPlayer)
end

--
-- returns true if the computer isn't allowed to be used
--
local function same(a,b)
	return math.abs(a-b)<0.1
end
local function forbidden(element)
	local pos = {
		{ 125, 1463.0048828125, -1779.455078125, 1250.9819335938 }, -- Gabrielle McCoy's computer
		{ 125, 1467.5057373047, -1779.455688476, 1250.9819335938 }, -- Jessie Smith's computer
	}
	
	for k, v in ipairs( pos ) do
		if getElementDimension(element) == v[1] then
			local x, y, z = getElementPosition(element)
			if same(x, v[2]) and same(y, v[3]) and same(z, v[4]) then
				return true
			end
		end
	end
	return false
end

--
-- handle clicks
--
function clickComputer(button, state, absX, absY, wx, wy, wz, element)
	if wComputer or getElementData(getLocalPlayer(), "exclusiveGUI") or button ~= "right" or state ~= "down" or sent then
		return
	end
	
	if element and getElementType(element)=="object" then
		local isComputer = getElementData(element, "computer:clickable") or isComputerModel(getElementModel(element))
		if (isComputer) and not forbidden(element) then
			local x, y, z = getElementPosition(getLocalPlayer())
			if (getDistanceBetweenPoints3D(x, y, z, wx, wy, wz)<=3) then
				createComputerGUIEx()
			end
		end
	elseif not element then
		local camX, camY, camZ = getCameraMatrix()
		local cursorX, cursorY, endX, endY, endZ = getCursorPosition()
		
		local x = {processLineOfSight(camX, camY, camZ, endX, endY, endZ, true, true, true, true, true, true, false, true, localPlayer, true)}
		local hit, _, _, _, _, _, _, _, mat, _, _, buildingId, bx, by, bz = unpack(x)
		
		if hit and isComputerModel(buildingId) then
			local x, y, z = getElementPosition(getLocalPlayer())
			if (getDistanceBetweenPoints3D(x, y, z, wx, wy, wz)<=3) then
				createComputerGUIEx()
			end
		end
	end
end
addEventHandler("onClientClick", getRootElement(), clickComputer, true)
