local objects = 
{
	-- Maxime
	createObject(15031,2532.99,-1335.19,1029.93,0,0,0,20),
	createObject(1649,2537.35,-1332.69,1031.60,0,0,0,20),
	createObject(1649,2530.95,-1332.69,1031.60,0,0,0,20),
	createObject(1498,2535.25,-1340.07,1029.93,0,0,0,20),
	createObject(2074,2536.60,-1336.47,1032.71,0,0,0,20),
	createObject(2074,2531.79,-1334.20,1032.71,0,0,0,20),
	createObject(14720,2538.21,-1339.43,1029.93,0,0,90,20),
	createObject(2074,2530.55,-1338.18,1032.71,0,0,0,20),
	createObject(2116,2536.80,-1335.80,1029.93,0,0,0,20),
	createObject(2310,2536.76,-1337.78,1030.43,0,0,269.98,20),
	createObject(2310,2536.79,-1334.87,1030.43,0,0,89.97,20),
	createObject(1502,2531.89,-1338.27,1029.93,0,0,270,20),
	createObject(1330,2539.25,-1333.40,1030.41,0,0,0,20),
	createObject(1793,2528.69,-1334.5,1029.93,0,0,270,20),
	createObject(2520,2529.87,-1337.80,1029.93,0,0,0,20),
	createObject(2525,2531.08,-1336.73,1029.93,0,0,0,20),
	createObject(2524,2529.88,-1339.56,1029.93,0,0,88,20),
	createObject(1744,2532.60,-1336.09,1031.67,0,0,0,20),
	createObject(2088,2533.28,-1337.88,1029.93,0,0,90,20),
	createObject(2102,2532.99,-1336.50,1032.01,0,0,0,20),
	createObject(1738,2537.07,-1333.00,1030.44,0,0,0,20),
	createObject(1416,2533.63,-1335.06,1030.50,0,0,270,20),
	createObject(1748,2533.85,-1335.25,1031.08,0,0,270,20),
	createObject(2987,2539.69,-1337.09,1031.19,0,0,270,20),
}

local col = createColSphere(2532.99,-1335.19,1029.93,100)
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
	
	-- can step into the shower
	if getElementModel( value ) == 2520 then
		setElementCollisionsEnabled( value, false )
	end
end