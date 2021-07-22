local objects = 
{
	createObject(18020,2489.1943359375,-1690.2387695313,2032.4692382813,0,0,0,8),
	createObject(2515,2485.0329589844,-1686.2604980469,2031.47265625,0,0,180.54052734375,8),
	createObject(2515,2483.3227539063,-1686.259765625,2031.47265625,0,0,180.53833007813,8),
	createObject(2515,2486.6765136719,-1686.259765625,2031.47265625,0,0,180.53833007813,8),
	createObject(2515,2488.3532714844,-1686.259765625,2031.47265625,0,0,180.53833007813,8),
	createObject(2738,2484.275390625,-1680.228515625,2031.0825195313,0,0,0,8),
	createObject(2738,2486.275390625,-1680.228515625,2031.0825195313,0,0,0,8),
	createObject(2738,2488.3156738281,-1680.228515625,2031.0825195313,0,0,0,8),
	createObject(2741,2487.5024414063,-1686.7309570313,2032.0561523438,0,0,180.54052734375,8),
	createObject(2741,2484.2280273438,-1686.73046875,2032.0561523438,0,0,180.53833007813,8),
	createObject(2742,2489.1374511719,-1684.8503417969,2032.0458984375,0,0,270.27026367188,8),
	createObject(1533,2481.3510742188,-1687.6369628906,2030.4926757813,0,0,180,8),
	createObject(1533,2482.8510742188,-1687.6369628906,2030.4926757813,0,0,180,8),
	createObject(8555,2469.2863769531,-1662.1713867188,1990.4926757813,0,270,270,8),
	createObject(8555,2469.2524414063,-1708.8408203125,1990.4926757813,0,270,90,8)
}

local col = createColSphere(2480.6015625, -1687.2392578125, 2031.4916992188,100)
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