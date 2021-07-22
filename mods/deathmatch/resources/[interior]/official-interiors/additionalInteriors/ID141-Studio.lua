local objects = 
{
	--Maxime
	createObject ( 14393, 1154.90002, -801.40002, 2100.2981, 0, 0, 270 , 77),
	createObject ( 1569, 1150.59998, -807.32001, 2098.09009, 0, 0, 270 , 77),
	createObject ( 14391, 1142.59998, -808.60699, 2099 , 0, 0, 0, 77),
	createObject ( 14392, 1141.80005, -807.70001, 2099.3999 , 0, 0, 0, 77),
	createObject ( 14393, 1141.89941, -807.69922, 2100.30005 , 0, 0, 0, 77),
	createObject ( 1714, 1145.09998, -809.59998, 2098.1001, 0, 0, 270 , 77),
	createObject ( 1714, 1145.09998, -808.5, 2098.1001, 0, 0, 270 , 77),
	createObject ( 1714, 1145.09998, -807.40002, 2098.1001, 0, 0, 270 , 77),
	createObject ( 1215, 1150.90002, -808.09998, 2100.8999, 0, 90, 180 , 77),
}

local col = createColSphere(1150.19140625, -808.0947265625, 2099.0656738281 ,20)

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
