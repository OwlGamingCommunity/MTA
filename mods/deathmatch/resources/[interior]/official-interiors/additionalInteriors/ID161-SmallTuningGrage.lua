local objects = 
{
	--Maxime
	createObject(11312,798.2998047,62.2998047,966.5000000,0.0000000,0.0000000,0.0000000,3), --object(modshop2_sfse,3), (1,3),
	createObject(11312,793.7999878,73.0000000,966.5000000,0.0000000,0.0000000,0.0000000,3), --object(modshop2_sfse,3), (2,3),
	createObject(11312,813.2998047,55.8994141,966.5000000,0.0000000,0.0000000,180.0000000,3), --object(modshop2_sfse,3), (1,3),
	createObject(1497,794.2000122,64.5999985,964.2999878,0.0000000,0.0000000,0.0000000,3), --object(gen_doorext02,3), (1,3),
	createObject(11312,821.0996094,55.8994141,966.5000000,0.0000000,0.0000000,90.0000000,3), --object(modshop2_sfse,3), (1,3),
	createObject(14878,815.7000122,58.0999985,964.7999878,0.0000000,0.0000000,88.0000000,3), --object(michelle-barrels,3), (1,3),
	createObject(935,804.5000000,63.5000000,964.9000244,0.0000000,0.0000000,0.0000000,3), --object(cj_drum,3), (1,3),
	createObject(1271,799.9000244,63.9000015,964.5999756,0.0000000,0.0000000,0.0000000,3), --object(gunbox,3), (1,3),
	createObject(1271,799.3994141,63.6992188,965.2999878,0.0000000,0.0000000,19.9951172,3), --object(gunbox,3), (2,3),
	createObject(1271,799.0999756,63.7999992,964.5999756,0.0000000,0.0000000,355.0000000,3), --object(gunbox,3), (3,3),
	createObject(2180,802.0999756,63.7999992,964.2999878,0.0000000,0.0000000,180.0000000,3), --object(med_office5_desk_3,3), (1,3),
	createObject(2190,801.2000122,64.1999969,965.0999756,0.0000000,0.0000000,0.0000000,3), --object(pc_1,3), (1,3),
	createObject(2317,802.2000122,64.0000000,965.3499756,0.0000000,0.0000000,340.0000000,3), --object(cj_tele_3,3), (1,3),
	createObject(1715,801.9000244,62.9000015,964.2999878,0.0000000,0.0000000,190.0000000,3), --object(kb_swivelchair2,3), (1,3),
	createObject(5140,825.5999756,57.0000000,966.5000000,0.0000000,0.0000000,180.0000000,3), --object(snpedtatshp,3), (1,3),
	createObject(3077,808.0999756,54.5000000,964.2999878,0.0000000,0.0000000,0.0000000,3), --object(nf_blackboard,3), (1,3),
	createObject(1428,803.4000244,63.7000008,965.9000244,0.0000000,0.0000000,344.0000000,3), --object(dyn_ladder,3), (1,3),
	createObject(1238,806.9000244,63.5000000,964.5999756,0.0000000,0.0000000,0.0000000,3), --object(trafficcone,3), (1,3),
	createObject(2063,893.0999756,46.0999985,964.2000122,0.0000000,0.0000000,0.0000000,3), --object(cj_greenshelves,3), (2,3),
	createObject(2502,814.0000000,64.0999985,964.2999878,0.0000000,0.0000000,0.0000000,3), --object(cj_hobby_shelf_5,3), (1,3),
	createObject(2502,815.3636475,64.0996094,964.2999878,0.0000000,0.0000000,0.0000000,3), --object(cj_hobby_shelf_5,3), (2,3),
	createObject(14860,814.5000000,50.7000008,966.7999878,0.0000000,0.0000000,0.0000000,3), --object(coochie-posters,3), (1,3),

}

local col = createColCuboid(790.1064453125, 52.890625, 963.10473632813, 30, 15, 8)

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


