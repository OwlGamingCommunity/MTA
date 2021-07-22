 function replaceModel()
   local col = engineLoadCOL ( "colfixes/1.col" )
   engineReplaceCOL ( col, 11391 )
   
   local col = engineLoadCOL ( "colfixes/2.col")
   engineReplaceCOL ( col, 11393 )
 end
 addEventHandler ( "onClientResourceStart", getResourceRootElement(getThisResource()),
     function()
         replaceModel()
         setTimer (replaceModel, 1000, 1)
     end
)

local objects = 
{
	-- Forrest
createObject(11387,530.7675781,59.4912109,1046.8183594,0.0000000,0.0000000,0.0000000,24),
createObject(11389,521.4000244,75.5000000,1046.5999756,0.0000000,0.0000000,0.0000000,24),
createObject(11391,513.3593750,67.4000015,1044.7099609,0.0000000,0.0000000,0.0000000,24),
createObject(13027,538.0399780,87.5849991,1046.6550293,0.0000000,0.0000000,90.0000000,24),
createObject(8653,545.0000000,83.1591797,1043.8000488,0.0000000,0.0000000,90.0000000,24),
createObject(8653,545.0000000,83.1591797,1048.4000244,0.0000000,0.0000000,90.0000000,24),
createObject(8653,545.0000000,83.1591797,1046.0000000,0.0000000,0.0000000,90.0000000,24),
createObject(8653,545.6799927,92.1500015,1043.8000488,0.0000000,0.0000000,0.0000000,24),
createObject(8653,545.0000000,92.1494141,1043.8000488,0.0000000,0.0000000,90.0000000,24),
createObject(8653,545.0000000,92.1494141,1046.0000000,0.0000000,0.0000000,90.0000000,24),
createObject(8653,545.0000000,92.1494141,1048.4000244,0.0000000,0.0000000,90.0000000,24),
createObject(8653,545.6796875,92.1494141,1048.4000244,0.0000000,0.0000000,0.0000000,24),
createObject(8653,545.6796875,92.1494141,1046.0000000,0.0000000,0.0000000,0.0000000,24),
createObject(11416,530.3099976,79.1200027,1045.5600586,0.0000000,0.0000000,0.0000000,24),
createObject(11359,516.8917000,59.2000000,1045.5999756,0.0000000,0.0000000,0.0000000,24),
createObject(11359,516.8917000,59.2000000,1041.4500000,0.0000000,0.0000000,0.0000000,24),
createObject(8653,545.6796875,92.1494141,1048.4000244,0.0000000,0.0000000,0.0000000,24),
createObject(8653,531.0000000,68.0000000,1048.4000244,0.0000000,0.0000000,0.0000000,24),
createObject(8653,531.0000000,68.0000000,1048.4000244,0.0000000,0.0000000,0.0000000,24),
createObject(8653,531.0000000,76.0000000,1048.4000244,90.0000000,180.0000000,180.0000000,24),
createObject(8653,531.0000000,82.0000000,1048.4000244,90.0000000,179.9945068,179.9945068,24),
createObject(8653,520.0999756,58.9000015,1044.5000000,90.0000000,180.0054932,90.0000000,24),
createObject(8653,514.5999756,59.0000000,1044.5000000,90.0000000,180.0054932,90.0000000,24),
createObject(8653,512.0000000,59.0999985,1048.0000000,0.0000000,0.0000000,90.0000000,24),
createObject(11390,521.3300000,75.4500000,1047.9500000,0.0000000,0.0000000,0.0000000,24),
createObject(11388,521.3350000,75.5000000,1050.2500000,0.0000000,0.0000000,0.0000000,24),
createObject(2893,518.6290283,78.1549988,1044.7349854,7.9376221,0.0000000,89.4506836,24),
createObject(2893,518.6289062,79.9850006,1044.7349854,7.9321289,0.0000000,89.4506836,24),
createObject(11393,526.0000000,70.0999985,1045.0000000,0.0000000,0.0000000,0.0000000,24),
}

local col = createColSphere(526.0000000,70.0999985,1045.0000000, 120)
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
