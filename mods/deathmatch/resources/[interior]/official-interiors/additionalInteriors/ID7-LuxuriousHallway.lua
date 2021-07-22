local objects = 
{
	--Maxime
	createObject ( 14388, 1254.90002, -919, 1098.90002 , 0, 0, 0, 5),
	createObject ( 14395, 1269.66394, -933.96997, 1099.41199 , 0, 0, 0, 5),
	createObject ( 14394, 1265.55005, -941.71997, 1096.44995 , 0, 0, 0, 5),
	createObject ( 14388, 1214, -931.29999, 1098.90002, 0, 0, 90 , 5),
	createObject ( 1569, 1280.66504, -930.69501, 1101.573 , 0, 0, 0, 5),
	createObject ( 1569, 1283.66809, -930.677, 1097.27197, 0, 0, 180 , 5),
	createObject ( 1569, 1279.66797, -930.67676, 1097.27197, 0, 0, 179.995 , 5),
	createObject ( 1569, 1276.66504, -930.67969, 1097.27197 , 0, 0, 0, 5),
	createObject ( 1569, 1287.69995, -938.21997, 1097.28003, 0, 0, 270 , 5),
	createObject ( 1569, 1287.69995, -941.21997, 1097.28003, 0, 0, 90 , 5),
	createObject ( 1569, 1287.69922, -942.21002, 1097.28003, 0, 0, 270 , 5),
	createObject ( 1569, 1287.69922, -945.21002, 1097.28003, 0, 0, 90 , 5),
	createObject ( 1569, 1252.93396, -937.59998, 1095.65002 , 0, 0, 0, 5),
	createObject ( 1569, 1255.93506, -937.59998, 1095.65002, 0, 0, 180 , 5),
	createObject ( 1569, 1280.66504, -930.67969, 1097.27197 , 0, 0, 0, 5),
	createObject ( 1569, 1283.66699, -930.69434, 1101.573, 0, 0, 180 , 5),
}

local col = createColSphere(1254.48046875, -938.01171875, 1096.6500244141 ,20)

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
