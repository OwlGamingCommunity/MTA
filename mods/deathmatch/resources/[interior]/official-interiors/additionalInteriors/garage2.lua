local objects = 
{
	-- 360
	createObject(16010,1433.29980469,1364.19921875,1.39999998,0.00000000,0.00000000,90.00000000,22), --object(des_reslab_) (1)
	createObject(4103,1418.39941406,1494.39941406,-51.00000000,270.00000000,0.00000000,0.00000000,22), --object(staples_lan) (1)
	createObject(5835,1459.00000000,1360.00000000,16.60000038,0.00000000,0.00000000,0.00000000,22), --object(ci_astage) (1)
	createObject(5835,1427.90002441,1397.09997559,16.60000038,0.00000000,0.00000000,90.0000000,22), --object(ci_astage) (2)
	createObject(5835,1427.90002441,1317.90002441,16.60000038,0.00000000,0.00000000,270.0000000,22), --object(ci_astage) (3)
	createObject(3055,1434.09997559,1347.69995117,12.00000000,0.00000000,0.00000000,270.0000000,22), --object(kmb_shutter) (1)
	createObject(3055,1434.09997559,1357.09997559,12.00000000,0.00000000,0.00000000,270.0000000,22), --object(kmb_shutter) (2)
	createObject(3029,1434.06005859,1362.40002441,9.82999992,0.00000000,0.00000000,0.0000000,22), --object(cr1_door) (1)
	createObject(5835,1393.59997559,1360.09997559,16.60000038,0.00000000,0.00000000,180.0000000,22), --object(ci_astage) (4)
	createObject(1450,1419.19995117,1368.30004883,10.39999962,0.00000000,0.00000000,90.0000000,22), --object(dyn_crate_3) (2)
	createObject(1344,1419.19995117,1370.19995117,10.60000038,0.00000000,0.00000000,90.0000000,22), --object(cj_dumpster2) (1)
	createObject(16010,1419.09997559,1355.80004883,24.00000000,0.00000000,180.00000000,90.0000000,22) --object(des_reslab_) (2)
}

local col = createColSphere(1433.6201171875, 1363.212890625, 10.830528259277,50)
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
	setElementDimension( value, 93 )
end
