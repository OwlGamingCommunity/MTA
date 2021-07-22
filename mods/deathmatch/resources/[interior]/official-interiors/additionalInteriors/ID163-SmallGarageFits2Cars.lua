local objects = 
{
	--Maxime
	createObject(12943,321.2999900,-109.5000000,1010.0000000,0.0000000,0.0000000,0.0000000,40), --object(sw_shed07,40), (1,40),
	createObject(12942,321.2999900,-109.5040000,1010.0000000,0.0000000,0.0000000,0.0000000,40), --object(sw_shedinterior01,40), (2,40),
	createObject(5856,329.2999900,-109.5000000,1012.0000000,0.0000000,0.0000000,0.0000000,40), --object(lawnspraydoor1,40), (2,40),
	createObject(5856,315.8994100,-105.5996100,1012.0000000,0.0000000,0.0000000,90.0000000,40), --object(lawnspraydoor1,40), (3,40),
	createObject(2001,328.7000100,-106.2000000,1010.0000000,0.0000000,0.0000000,0.0000000,40), --object(nu_plant_ofc,40), (1,40),
	createObject(2001,329.0000000,-112.9000000,1010.0000000,0.0000000,0.0000000,0.0000000,40), --object(nu_plant_ofc,40), (2,40),
	createObject(2001,313.8999900,-113.0000000,1010.0000000,0.0000000,0.0000000,0.0000000,40), --object(nu_plant_ofc,40), (3,40),
	createObject(640,314.2999900,-109.5000000,1010.7000100,0.0000000,0.0000000,0.0000000,40), --object(kb_planter_bush2,40), (1,40),
	createObject(18608,313.2000100,-109.3000000,1016.2000100,0.0000000,0.0000000,90.0000000,40), --object(counts_lights01,40), (1,40),
	createObject(921,328.9910000,-111.8000000,1011.9000200,0.0000000,0.0000000,275.0000000,40), --object(cj_ind_light,40), (1,40),
	createObject(921,328.9910000,-107.0996100,1011.9000200,0.0000000,0.0000000,274.9990000,40), --object(cj_ind_light,40), (2,40),
	createObject(1430,326.0000000,-106.0000000,1010.2999900,0.0000000,0.0000000,0.0000000,40), --object(cj_dump1_low01,40), (1,40),
	createObject(1339,324.5000000,-106.2000000,1010.7000100,0.0000000,0.0000000,0.0000000,40), --object(binnt09_la,40), (1,40),
	createObject(1428,323.2000100,-106.3000000,1011.5999800,0.0000000,0.0000000,0.0000000,40), --object(dyn_ladder,40), (1,40),
	createObject(2114,323.0000000,-106.3000000,1010.2000100,0.0000000,0.0000000,0.0000000,40), --object(basketball,40), (1,40),
	createObject(1255,320.2000100,-106.4000000,1010.5999800,0.0000000,0.0000000,0.0000000,40), --object(lounger,40), (1,40),
	createObject(1255,320.7999900,-106.2000000,1010.6099900,0.0000000,200.0000000,0.0000000,40), --object(lounger,40), (2,40),

}

local col = createColCuboid(311.978515625, -114.9384765625, 1009.0441894531, 20, 10, 10)

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
	-- if getElementModel(object) == 10281 then
		-- setObjectScale ( object, 0.60000002384186  )
	-- end
	--setElementCollisionsEnabled ( object, true )
end




