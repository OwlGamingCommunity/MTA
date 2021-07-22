local objects = 
{
	-- Underground Parking Garage
	createObject(10010,1106.0000000,-1312.8000488,78.5000000,0.0000000,0.0000000,0.0000000, 1), --object(ugcarpark_sfe) (1)
	createObject(7997,1118.5999756,-1279.1999512,74.3000031,0.0000000,0.0000000,90.0000000, 1), --object(vgssairportland02) (1)
	createObject(3055,1071.0000000,-1279.6999512,81.0999985,0.0000000,0.0000000,0.0000000, 1), --object(kmb_shutter) (1)
	createObject(3055,1071.0000000,-1279.6999512,86.0999985,0.0000000,0.0000000,0.0000000, 1), --object(kmb_shutter) (2)
	createObject(3055,1078.8000488,-1279.6999512,86.0999985,0.0000000,0.0000000,0.0000000, 1), --object(kmb_shutter) (3)
	createObject(3055,1078.8000488,-1279.6999512,81.0999985,0.0000000,0.0000000,0.0000000, 1) --object(kmb_shutter) (4)
}

local col = createColSphere(1105.9000244141,-1312.8000488281,79.0625,100)
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