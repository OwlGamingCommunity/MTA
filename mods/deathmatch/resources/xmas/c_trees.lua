--SETTINGS:
local trees = {
	--{x, y, z}
	{1479.0634765625, -1682.8359375, 11}, -- Pershing Square
	{1128.7459716797, -1454.0148925781, 13.798126220703}, -- Verona Mall
	{1775.2470703125, -1352.0703125, 13.754605293274}, -- Downtown Mall
}
local fxEnabled = true --whether to enable tree render effects (blinking balls, sparkling stars)


--globals
local spawnedBalls = {}
local spawnedStars = {}
local isTreeFxRunning = false

function spawnAllTrees()
	for k, v in ipairs(trees) do
		spawnTree(v[1], v[2], v[3])
	end
	if fxEnabled then
		setTimer(updateTreeFX, 5000, 1)
	end
end
addEventHandler('onClientResourceStart', resourceRoot, spawnAllTrees)

function updateTreeFX(isUpdating, newState)
	if isUpdating then
		fxEnabled = newState
	else
		local userSetting = getElementData(localPlayer, "xmastreefx")
		if not userSetting or userSetting ~= "0" then
			fxEnabled = true
		else
			fxEnabled = false
		end
	end
	if fxEnabled then
		if not isTreeFxRunning then
			enableTreeFX()
		end
	else
		if isTreeFxRunning then
			disableTreeFX()
		end
	end
end
addEvent("xmas:updateTreeFX", true)
addEventHandler("xmas:updateTreeFX", root, updateTreeFX)

function enableTreeFX()
	isTreeFxRunning = true
	addEventHandler("onClientRender", root, renderTrees)
end
function disableTreeFX()
	isTreeFxRunning = false
	removeEventHandler("onClientRender", root, renderTrees)
end

function spawnTree(basex, basey, basez)
	basez = basez - 3

	createObject(654, basex, basey, basez)
	createObject(3038, basex-2, basey-2, basez+8, 0, 0, 45)
	createObject(3038, basex-2, basey-2, basez+12, 0, 0, 45)
	createObject(3038, basex-2, basey-2, basez+16, 0, 0, 45)

	createObject(3038, basex, basey+3, basez+8, 0, 0, 270)
	createObject(3038, basex, basey+3, basez+12, 0, 0, 270)
	createObject(3038, basex, basey+3, basez+16, 0, 0, 270)

	createObject(3038, basex+3, basey, basez+8, 0, 0, 180)
	createObject(3038, basex+3, basey, basez+12, 0, 0, 180)
	createObject(3038, basex+3, basey, basez+16, 0, 0, 180)

	local treeBall = {
		{ basex-3, basey-3, basez+8, 'corona', 3.0, 255, 0, 255, 255 },
		{ basex+3, basey+3, basez+8, 'corona', 3.0, 255, 0, 0, 255 },
		{ basex+3, basey-3, basez+8, 'corona', 3.0, 255, 255, 0, 255 },
		{ basex-3, basey+3, basez+8, 'corona', 4.0, 255, 150, 255, 255 },
		
		{ basex-1, basey-3, basez+10, 'corona', 4.0, 0, 150, 255, 255 },
		{ basex+1, basey+3, basez+9, 'corona', 3.0, 0, 255, 255, 255 },
		{ basex+1, basey-3, basez+10, 'corona', 3.0, 0, 65, 255, 255 },
		{ basez-1, basey+3, basez+11, 'corona', 3.0, 255, 0, 255, 255 },
		
		{ basex-4, basey+3, basez+13, 'corona', 3.0, 255, 0, 255, 255 },
		{ basex+3, basey-3, basez+13, 'corona', 4.0, 255, 150, 10, 255 },
		{ basex+1, basey+3, basez+13, 'corona', 3.0, 255, 65, 65, 255 },
		{ basex-3, basey-3, basez+13, 'corona', 3.0, 255, 255, 65, 255 },
		
		{ basex-2, basey+3, basez+16, 'corona', 3.0, 255, 0, 18, 255 },
		{ basex+3, basey-3, basez+17, 'corona', 4.0, 255, 65, 10, 255 },
		{ basex+2, basey+3, basez+17.5, 'corona', 4.0, 255, 180, 65, 255 },
		{ basex-3, basey-3, basez+16, 'corona', 3.0, 255, 0, 65, 255 },
	}
	local ball = {};
	
	for i, tball in ipairs(treeBall) do
		ball[i] = createMarker(tball[1], tball[2], tball[3], tball[4], tball[5], tball[6], tball[7], tball[8], tball[9])
		setElementData(ball[i], 'period', math.random(250, 750))
		table.insert(spawnedBalls, ball[i])
	end

	local star = createObject(1247, basex, basey, basez+23)
	setObjectScale(star, 10.0)
	starCorona = createMarker(basex, basey, basez+23, 'corona', 8.0, 255, 0, 0, 255)
	table.insert(spawnedStars, starCorona)
end

function renderTrees()
	if fxEnabled then
		if(getElementDimension(localPlayer) == 0) then
			for k, v in ipairs(trees) do
				local basex, basey, basez = v[1], v[2], v[3]
				fxAddSparks( basex, basey, basez+23, 0, 0, 2, 1.5, 2, 0, 0, 0, false, 2, 1 );
				fxAddSparks( basex, basey, basez+23, 0, 0, 2, 1.5, 2, 0, 0, 0, false, 2, 1 );
				fxAddSparks( basex, basey, basez+23, 0, 0, -2, 2.5, 15, 0, 0, 0, false, 1, 2 );
				fxAddSparks( basex, basey, basez+23, 0, 0, 2, 2.5, 15, 0, 0, 0, false, 5, 2 );
			end
			
			local ap = math.abs( math.cos( getTickCount()/250 )*255 );
			local r = math.abs( math.cos( getTickCount()/250)*255 );
			for k, v in ipairs(spawnedStars) do
				setMarkerColor(v, r, 0, 0, ap);
			end
			
			for k, treeBalls in ipairs(spawnedBalls) do
				local ap = math.abs(math.cos(getTickCount()/getElementData(treeBalls, 'period'))*255);
				local r, g, b = getMarkerColor(treeBalls);
				setMarkerColor(treeBalls, r, g, b, ap);
			end
		end
	end
end