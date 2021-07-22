-- waves
function setInitialWaves(res)
	local hour, mins = getTime()
	--createSewerFlood()
	fillPool()
	if (hour%2==0) then -- even hour
		
		setWaveHeight(0.5)
	else
		setWaveHeight(0)
	end
end
addEventHandler("onClientResourceStart", getResourceRootElement(), setInitialWaves)

function updateWaves()
	local hour, mins = getTime()

	if (hour%2==0) then -- even hour
		setWaveHeight(0.5)
	else
		setWaveHeight(0)
	end
end
addEvent("updateWaves", false)
addEventHandler("updateWaves", getRootElement(), updateWaves)

function fillPool()
	local water = createWater(-2699, 913, 66.4, -2690.6, 913.8, 66.4, -2700, 935, 66.4, -2691, 935, 66.4)
	local moreWater = createWater(2634, 954, 70, -2634, 958, 71, -2644, 958, 71, -2644, 954, 71)
	--local waterinDocks = createWater(-1709.3837890625, 64.994140625, 3.5494832992554, -1679.9404296875, 33.9873046875, 3.5546875, -1609.9833984375, 170.9228515625, 3.5546875, -1570.7001953125, 132.439453125, 3.5546875)
end

--[[
function createSewerFlood()
	 -- Dams
	createObject(16339, 1579.72265625, -1751.748046875, 1.3512325286865, 0, 0, 180)
	createObject(16339, 1411, -1714.7568359375, 1.3512325286865, 0, 0, 354)
	createObject(16339, 2582.4560546875, -2110.7, -0.28, 0, 0, 270)
	createObject(16339, 2581.673828125, -2120.3525390625, 0, 0, 0, 90)
	
	-- Water #1
	local xmin, xmax, ymin, ymax, z = 1330, 1420, -1733, -1298, 11.4
	local water = createWater(xmin, ymin, z, xmax, ymin, z, xmin, ymax, z, xmax, ymax, z)
	
	-- Water #2
	local xmin, xmax, ymin, ymax, z = 1574, 2534, -1917, -1729, 6
	local water = createWater(xmin, ymin, z, xmax, ymin, z, xmin, ymax, z, xmax, ymax, z)
	
	-- Water #3
	local xmin, xmax, ymin, ymax, z = 1613, 1629, -1729, -1680, 6
	local water = createWater(xmin, ymin, z, xmax, ymin, z, xmin, ymax, z, xmax, ymax, z)
	
	-- Water #4
	local xmin, xmax, ymin, ymax, z = 2534, 2628, -2115, -1452, 6
	local water = createWater(xmin, ymin, z, xmax, ymin, z, xmin, ymax, z, xmax, ymax, z)
end
]]