-- ID174-Tent
local objects =
{
	--Chaos
    createObject ( 11505, 1348.536, 1486.236, 16.468, 0, 0, 0, 4 ), --Ground Floor
	createObject ( 3498, 1351.6591, 1487.694, 20.574, 20, 0, 315, 4 ), --Support Pillar
	createObject ( 3498, 1345.1591, 1487.694, 20.574, 20, 0, 45, 4 ), --Support Pillar
	createObject ( 3498, 1351.662, 1483.194, 20.574, 20, 0, 225, 4 ), --Support Pillar
	createObject ( 3498, 1345.153, 1483.161, 20.574, 20, 0, 135, 4 ), --Support Pillar
	createObject ( 3498, 1348.297, 1488.141, 20.574, 20, 0, 0, 4 ),  --Support Pillar
	createObject ( 3498, 1348.297, 1482.718, 20.574, 19.995, 0, 180, 4 ),  --Support Pillar
	createObject ( 2561, 1345.442, 1487.4821, 19.346, 20, 0, 6, 4, 0, 255, 1.5, 1.5, 1.5 ), --Curtain
	createObject ( 2561, 1348.8887, 1487.7109, 19.346, 19.99, 0, 353.996, 4, 0, 255, 1.5, 1.5, 1.5 ), --Curtain
	createObject ( 2561, 1351.255, 1492.146, 19.346, 15, 0, 270, 4, 0, 255, 1.5, 1.5, 1.5 ), --Curtain
	createObject ( 2561, 1351.255, 1484.947, 19.346, 14.996, 0, 270, 4, 0, 255, 1.5, 1.5, 1.5 ), --Curtain
	createObject ( 2561, 1345.569, 1482.447, 19.346, 14.996, 0, 90, 4, 0, 255, 1.5, 1.5, 1.5 ), --Curtain
	createObject ( 2561, 1345.53, 1484.6639, 19.346, 14.996, 0, 90, 4, 0, 255, 1.5, 1.5, 1.5 ), --Curtain
	createObject ( 2561, 1347.882, 1483.1219, 19.346, 20, 0, 174, 4, 0, 255, 1.5, 1.5, 1.5 ), --Curtain
	createObject ( 2561, 1351.184, 1483.377, 19.346, 19.995, 0, 186, 4, 0, 255, 1.5, 1.5, 1.5 ), --Curtain
	createObject ( 2561, 1351.252, 1478.947, 19.362, 15, 180, 270, 4, 0, 255, 1.5, 1.5, 1.5 ), --Curtain
	createObject ( 2561, 1351.252, 1486.147, 19.362, 14.996, 179.995, 270, 4, 0, 255, 1.5, 1.5, 1.5 ), --Curtain
	createObject ( 2561, 1354.8621, 1487.079, 19.366, 19.99, 180, 353.996, 4, 0, 255, 1.5, 1.5, 1.5 ), --Curtain
	createObject ( 2561, 1351.416, 1488.103, 19.368, 19.995, 180, 5.999, 4, 0, 255, 1.5, 1.5, 1.5 ), --Curtain
	createObject ( 2561, 1345.207, 1482.756, 19.366, 19.99, 180, 185.999, 4, 0, 255, 1.5, 1.5, 1.5 ), --Curtain
	createObject ( 2561, 1341.917, 1483.762, 19.375, 19.995, 180, 173.996, 4, 0, 255, 1.5, 1.5, 1.5 ), --Curtain
	createObject ( 2561, 1345.54, 1490.6639, 19.366, 14.991, 180, 90, 4, 0, 255, 1.5, 1.5, 1.5 ), --Curtain
	createObject ( 2561, 1345.574, 1488.4561, 19.366, 14.991, 180, 90, 4, 0, 255, 1.5, 1.5, 1.5 ), --Curtain
	createObject ( 2561, 1344.2889, 1486.954, 22.363, 270, 0, 270, 4, 0, 255, 3, 3, 3 ), --Curtain
	createObject ( 2561, 1352.309, 1483.704, 22.365, 270, 180, 270, 4, 0, 255, 3, 3, 3 ), --Curtain
	createObject ( 2561, 1349.3311, 1483.704, 21.268, 0, 0, 90, 4, 0, 255, 3, 3, 3 ), --Curtain
	createObject ( 2885, 1350.066, 1483.769, 24.638, 340, 0, 6, 4 ), --Collision Fix
	createObject ( 2885, 1346.564, 1483.7629, 24.638, 340, 0, 354, 4 ), --Collision Fix
	createObject ( 2885, 1346.564, 1487.092, 24.638, 339.999, 0, 186, 4 ), --Collision Fix
	createObject ( 2885, 1350.066, 1487.1121, 24.638, 340, 0, 174, 4 ), --Collision Fix
	createObject ( 2885, 1351.038, 1487.1121, 24.638, 345, 0, 90, 4 ), --Collision Fix
	createObject ( 2885, 1345.76, 1487.1121, 24.638, 344.998, 0, 270, 4 ), --Collision Fix
	createObject ( 2885, 1348.0699, 1488.77, 22.388, 270, 0, 0, 4 ), --Collision Fix
}

local col = createColSphere(1345.7598, 1485.4551, 19.312 ,20)

local function watchChanges( )
	if getElementDimension( getLocalPlayer( ) ) > 0 and getElementDimension( getLocalPlayer( ) ) ~= getElementDimension( objects[1] ) and getElementInterior( getLocalPlayer( ) ) == getElementInterior( objects[1] ) then
		for key, value in pairs( objects ) do
			setElementDimension( value, getElementDimension( getLocalPlayer( ) ) )
		end
	elseif getElementDimension( getLocalPlayer( ) ) == 0 and getElementDimension( objects[1] ) ~= 65535 then
		for key, value in pairs( objects ) do
			setElementDimension( value, 65535 )
		end
	end
end
addEventHandler( "onClientColShapeHit", col,
	function( element )
		if element == getLocalPlayer( ) then
			addEventHandler( "onClientRender", root, watchChanges )
		end
	end
)
addEventHandler( "onClientColShapeLeave", col,
	function( element )
		if element == getLocalPlayer( ) then
			removeEventHandler( "onClientRender", root, watchChanges )
		end
	end
)

-- Put them standby for now.
for key, value in pairs( objects ) do
	setElementDimension( value, 65535 )
end

for index, object in ipairs ( objects ) do
    setElementDoubleSided ( object, true )
	--setElementCollisionsEnabled ( object, true )
end
