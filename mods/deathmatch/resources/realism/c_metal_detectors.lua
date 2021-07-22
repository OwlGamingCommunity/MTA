local metalDetectors = { 
	{ 1492.3427734375, -1782.794921875, 1250.9418945313, 3, 125 }, -- City hall 1
	{ 1437.6494140625, -1782.6025390625, 1250.9476318359, 3, 125 }, -- City hall 2
	
	{ 284.4296875, 126.9765625, 757.83776855469, 14, 888 }, -- Club BB #1
	{ 286.2783203125, 127.1025390625, 757.84588623047, 14, 888 }, -- Club BB #2
	{ 287.9130859375, 127.001953125, 757.85308837891, 14, 888 }, -- Club BB #3
	{ 289.8359375, 127.03125, 757.86151123047, 14, 888 }, -- Club BB #4
	
	{  387.2724609375, 170.51953125, 1008.3828125, 3, 100 }, -- Court #1
	{  387.3564453125, 172.103515625, 1008.3828125, 3, 100 }, -- Court #2
	{  387.3173828125, 173.7783203125, 1008.3828125, 3, 100 }, -- Court #3
	{  387.48046875, 175.4140625, 1008.3828125, 3, 100 }, -- Court #4
	{  387.22265625, 177.1357421875, 1008.3828125, 3, 100 } -- Court #5
}

function metalDetectorHit(element, dimension)
	local x, y, z = getElementPosition(getLocalPlayer())
	local mx, my, mz = getElementPosition(source)
	if (getDistanceBetweenPoints3D(mx, my, mz, x, y, z) < 25) then
		if ( dimension )  then
			if ( getElementType(element) == "player") then
				local meleeammo = getPedTotalAmmo(element, 1)
				local handgunammo = getPedTotalAmmo(element, 2)
				local shotgunammo = getPedTotalAmmo(element, 3)
				local smgammo = getPedTotalAmmo(element, 4)
				local rifleammo = getPedTotalAmmo(element, 5)
				local sniperammo = getPedTotalAmmo(element, 6)
				local heavyammo = getPedTotalAmmo(element, 7)
				local thrownammo = getPedTotalAmmo(element, 8)
				local detonatorammo = getPedTotalAmmo(element, 9)
				
				if (meleeammo>0 or handgunammo>0 or shotgunammo>0 or smgammo>0 or rifleammo>0 or sniperammo>0 or heavyammo>0 or thrownammo>0 or detonatorammo>0) then
					setTimer(playSoundFrontEnd, 70, 12, 5)
				end
			end
		end
	end
end

function initalizeMetalDetectors()
	for i=1, #metalDetectors do
		local metalDetector = metalDetectors[i]
		if (metalDetector) then
			local metalSphere = createColTube(metalDetector[1], metalDetector[2], metalDetector[3], 0.5, 1)
			setElementInterior(metalSphere, metalDetector[4])
			setElementDimension(metalSphere, metalDetector[5])
			addEventHandler("onClientColShapeHit", metalSphere, metalDetectorHit)
		end
	end
end
addEventHandler("onClientResourceStart", getResourceRootElement(), initalizeMetalDetectors)