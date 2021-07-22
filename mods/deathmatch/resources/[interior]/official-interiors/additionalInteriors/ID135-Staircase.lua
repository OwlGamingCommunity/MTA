local objects = 
{
	--Maxime
	createObject ( 14590, 2296.8999, 1706.69995, 1106.19995, 0, 0, 0 ,1 ),
	createObject ( 1569, 2299.93311, 1686.09998, 1100.90002 , 0, 0, 0 ,1 ),
	createObject ( 1569, 2299.93262, 1686.09961, 1103.40002 , 0, 0, 0 ,1 ),
	createObject ( 1569, 2299.80005, 1685.64001, 1105.09998 , 0, 0, 0 ,1 ),
	createObject ( 1569, 2295, 1677.77832, 1107.09998, 0, 0, 90 ,1),
	createObject ( 1569, 2301.30005, 1676.83997, 1102.90002, 0, 0, 180 ,1),
}

local col = createColSphere(2300.720703125, 1685.6923828125, 1101.9095458984 ,20)

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
