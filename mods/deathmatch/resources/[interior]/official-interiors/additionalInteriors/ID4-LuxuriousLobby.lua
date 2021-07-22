local objects = 
{
	--Maxime
	createObject ( 14415, 2546.19995, -1304.5, 1082.09998 , 0, 0, 0, 2),
	createObject ( 1569, 2533.40991, -1308.90002, 1075.93005, 0, 0, 180 , 2),
	createObject ( 1569, 2516.80005, -1295.27002, 1075.92798, 0, 0, 270 , 2),
	createObject ( 1569, 2516.7998, -1298.27148, 1075.92798, 0, 0, 90 , 2),
	createObject ( 1569, 2530.40503, -1308.90002, 1075.93005, 0, 0, 359.995 , 2),
	createObject ( 2290, 2536.30005, -1307.69995, 1075.90002, 0, 0, 180 , 2),
	createObject ( 2290, 2529.56006, -1307.69995, 1075.90002, 0, 0, 179.995 , 2),
	createObject ( 948, 2537.19995, -1307.59998, 1075.90002 , 0, 0, 0, 2),
	createObject ( 948, 2526.62988, -1307.59998, 1075.90002 , 0, 0, 0, 2),
	createObject ( 14455, 2537.80005, -1296.40002, 1077.59998, 0, 0, 90 , 2),
	createObject ( 14455, 2537.80005, -1302.15002, 1077.59998, 0, 0, 90 , 2),
	createObject ( 948, 2537.3999, -1291.09998, 1075.90002 , 0, 0, 0, 2),
	createObject ( 948, 2517.30005, -1298.48206, 1075.90002 , 0, 0, 0, 2),
	createObject ( 948, 2526.2998, -1298.5, 1075.90002 , 0, 0, 0, 2),
	createObject ( 948, 2526.2998, -1295.06995, 1075.90002 , 0, 0, 0, 2),
	createObject ( 948, 2517.2998, -1295.09961, 1075.90002 , 0, 0, 0, 2),
	createObject ( 2290, 2524.43994, -1299.5, 1075.90002, 0, 0, 179.995 , 2),
	createObject ( 2290, 2522.43994, -1294, 1075.90002, 0, 0, 359.995 , 2),
	createObject ( 2637, 2527.80005, -1292.69995, 1076.30005, 0, 0, 50 , 2),
	createObject ( 2637, 2528, -1292.90002, 1076.30005, 90, 180, 229.999 , 2),
	createObject ( 2637, 2528.26489, -1292.26001, 1075.90002, 0, 90, 49.999 , 2),
	createObject ( 2637, 2527.3999, -1293.19995, 1075.90002, 0, 90, 229.999 , 2),
	createObject ( 2637, 2527.69995, -1292.59998, 1076.09998, 270, 0, 49.999 , 2),
	createObject ( 14820, 2527.69995, -1292.59998, 1076.80005, 0, 0, 230 , 2),
	createObject ( 14807, 2525.30005, -1289.09998, 1077.19995, 0, 0, 10 , 2),
	createObject ( 14807, 2525.8999, -1289.30005, 1077.19995, 0, 0, 339.998 , 2),
	createObject ( 2231, 2526, -1290.5, 1081, 0, 0, 39.25 , 2),
	createObject ( 2231, 2528.62988, -1292.33997, 1075.90002, 0, 0, 49.246 , 2),
	createObject ( 2231, 2527.89941, -1293.19922, 1075.90002, 0, 0, 49.246 , 2),
	createObject ( 2231, 2538.19995, -1290.80005, 1081, 0, 0, 315.249 , 2),
	createObject ( 2231, 2537.80005, -1309.09998, 1081, 0, 0, 215.247 , 2),
	createObject ( 2231, 2525.6001, -1308.69995, 1081, 0, 0, 135.244 , 2),
	createObject ( 2225, 2526, -1290.69995, 1075.90002, 0, 0, 50 , 2),
	createObject ( 2086, 2532.80005, -1300.30005, 1076.30005 , 0, 0, 0, 2),
	createObject ( 1704, 2531, -1301.59998, 1075.90002, 0, 0, 120 , 2),
	createObject ( 1703, 2532.30005, -1298.19995, 1075.90002, 0, 0, 10 , 2),
	createObject ( 948, 2531.19995, -1302.09998, 1075.90002, 0, 0, 29.998 , 2),
	createObject ( 948, 2534.8999, -1297.80005, 1075.90002, 0, 0, 9.993 , 2),
	createObject ( 2290, 2533.1001, -1291.90002, 1075.90002, 0, 0, 359.995 , 2),

}

local col = createColSphere(2546.19995, -1304.5, 1082.09998 ,2000)

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
