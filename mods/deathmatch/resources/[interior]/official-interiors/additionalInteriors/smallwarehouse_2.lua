local objects = 
{
	-- Fox
	createObject(5184,2453.296875,-2545.8308105469,1113.3159179688,0,0,0,6),
	createObject(3623,2451.9477539063,-2550.2216796875,1098.2241210938,0,0,270.26989746094,6),
	createObject(3623,2479.7087402344,-2536.4406738281,1098.2241210938,0,0,270.26989746094,6),
	createObject(3623,2451.9477539063,-2522.8044433594,1098.2241210938,0,0,89.999969482422,6),
	createObject(3623,2424.0131835938,-2536.6667480469,1098.2241210938,0,0,89.999969482422,6),
	createObject(3623,2451.9477539063,-2528.5205078125,1100.9233398438,0,180,270,6),
	createObject(3623,2451.9477539063,-2544.5087890625,1100.9233398438,0,180,89.999938964844,6),
	createObject(11389,2453.7927246094,-2538.1896972656,1097.5415039063,0,0,270,6),
	createObject(11390,2453.8889160156,-2538.1394042969,1098.798828125,0,0,270,6),
	createObject(11387,2437.8090820313,-2547.5520019531,1097.7739257813,0,0,270,6),
	createObject(3109,2437.9208984375,-2536.6435546875,1095.6245117188,0,0,179.45971679688,6),
	createObject(3109,2438.4660644531,-2540.2941894531,1095.6245117188,0,0,179.45971679688,6),
	createObject(2000,2442.3059082031,-2542.2521972656,1094.4331054688,0,0,180.53955078125,6),
	createObject(1421,2441.0539550781,-2542.3459472656,1095.1958007813,0,0,0,6),
	createObject(2605,2446.3029785156,-2542.3266601563,1094.8315429688,0,0,179.45977783203,6),
	createObject(1722,2446.7287597656,-2541.2612304688,1094.4331054688,0,0,139.57995605469,6)
}

local col = createColSphere(2453.296875,-2545.8308105469,1113.3159179688,100)
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