local objects = 
{
	--Maxime
	createObject(8231,554.7999900,2645.1001000,10.0000000,0.0000000,0.0000000,0.0000000,10), --object(vgsbikeschl05,10), (1,10),
	createObject(8231,559.2999900,2653.3999000,10.0000000,0.0000000,0.0000000,270.0000000,10), --object(vgsbikeschl05,10), (2,10),
	createObject(6037,532.5996100,2635.5000000,-1.4000000,90.0000000,0.0000000,179.9950000,10), --object(filler02_law,10), (1,10),
	createObject(1745,553.4000200,2640.1001000,8.3000000,0.0000000,0.0000000,270.0000000,10), --object(med_bed_3,10), (1,10),
	createObject(1726,557.7000100,2637.6999500,8.3000000,0.0000000,0.0000000,90.0000000,10), --object(mrk_seating2,10), (1,10),
	createObject(8231,548.4600200,2628.5000000,10.0000000,0.0000000,0.0000000,90.0000000,10), --object(vgsbikeschl05,10), (3,10),
	createObject(2297,563.5000000,2639.3994100,8.3000000,0.0000000,0.0000000,225.0000000,10), --object(tv_unit_2,10), (1,10),
	createObject(2229,563.4000200,2636.6999500,8.3000000,0.0000000,0.0000000,255.0000000,10), --object(swank_speaker,10), (1,10),
	createObject(1742,560.5999800,2636.5300300,8.3000000,0.0000000,0.0000000,180.0000000,10), --object(med_bookshelf,10), (1,10),
	createObject(2141,560.2000100,2644.0000000,8.3000000,0.0000000,0.0000000,0.0000000,10), --object(cj_kitch2_l,10), (1,10),
	createObject(2341,563.1992200,2644.0000000,8.3000000,0.0000000,0.0000000,0.0000000,10), --object(cj_kitch2_corner,10), (1,10),
	createObject(2133,563.2001300,2643.0400400,8.3000000,0.0000000,0.0000000,270.0000000,10), --object(cj_kitch2_r,10), (2,10),
	createObject(15038,553.0000000,2643.8999000,8.9000000,0.0000000,0.0000000,0.0000000,10), --object(plant_pot_3_sv,10), (1,10),
	createObject(14762,552.5999800,2638.8999000,10.2000000,0.0000000,0.0000000,0.0000000,10), --object(arsewinows,10), (1,10),
	createObject(2596,552.7998000,2637.5000000,10.5000000,10.9970000,358.9950000,129.9960000,10), --object(cj_sex_tv,10), (1,10),
	createObject(2132,561.2000100,2644.0000000,8.3000000,0.0000000,0.0000000,0.0000000,10), --object(cj_kitch2_sink,10), (1,10),
	createObject(1536,563.7000100,2640.6001000,8.3000000,0.0000000,0.0000000,90.0000000,10), --object(gen_doorext15,10), (1,10),
	createObject(3440,553.0000000,2643.9394500,6.2200000,0.0000000,0.0000000,0.0000000,10), --object(arptpillar01_lvs,10), (1,10),
	createObject(6037,550.7000100,2646.5000000,-1.4000000,90.0000000,0.0000000,90.0000000,10), --object(filler02_law,10), (2,10),
	createObject(6037,550.7000100,2646.3999000,-1.4000000,90.0000000,0.0000000,0.0000000,10), --object(filler02_law,10), (3,10),
	createObject(3942,553.0000000,2636.6999500,16.4440000,0.0000000,0.0000000,0.0000000,10), --object(bistrobar,10), (2,10),
	createObject(2262,557.5999800,2638.0000000,10.1000000,0.0000000,0.0000000,90.0000000,10), --object(frame_slim_3,10), (1,10),
	createObject(948,557.5999800,2640.5000000,8.3000000,0.0000000,0.0000000,0.0000000,10), --object(plant_pot_10,10), (1,10),
	createObject(2261,557.6008900,2639.5000000,10.0000000,0.0000000,0.0000000,90.0000000,10), --object(frame_slim_2,10), (1,10),
	createObject(2239,554.7999900,2644.1999500,8.3000000,0.0000000,0.0000000,0.0000000,10), --object(cj_mlight16,10), (1,10),
	createObject(6037,538.0000000,2646.8999000,-1.4000000,90.0000000,0.0000000,90.0000000,10), --object(filler02_law,10), (4,10),

}

local col = createColSphere(563.11963, 2641.35791, 9.29688 , 20)

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


