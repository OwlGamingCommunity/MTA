local objects = 
{
	-- Antman
	createObject(14876,-2027.7451171875,-113.7509765625,1043.2658691406,0,0,89.247436523438,21),
	createObject(1498,-2032.3000488281,-119.02488708496,1038.1955566406,0,0,90,21),
	createObject(10182,-2020.2902832031,-116.47886657715,1039.8902587891,0,0,359.25,21),
	createObject(1744,-2032.3382568359,-116.45636749268,1039.326171875,0,0,89.25,21),
	createObject(1744,-2032.3122558594,-114.46715545654,1039.3237304688,0,0,89.5,21),
	createObject(2184,-2029.6767578125,-114.62281036377,1038.1955566406,0,0,70,21),
	createObject(1337,-2032.0361328125,-116.5153427124,1038.5456542969,358.01947021484,8.0048217773438,196.27844238281,21),
	createObject(2969,-2031.9924316406,-116.01945495605,1039.79296875,0,0,89.75,21),
	createObject(2478,-2031.9548339844,-114.08589172363,1039.9439697266,0,0,90,21),
	createObject(1271,-2031.8657226563,-119.86763000488,1038.5379638672,0,0,0,21),
	createObject(2062,-2026.3493652344,-120.00075531006,1038.7377929688,0,0,278.75,21),
	createObject(2062,-2027.1085205078,-119.984375,1038.7641601563,0,0,306.25,21),
	createObject(1840,-2026.3699951172,-120.00203704834,1039.2814941406,0,0,253.5,21),
	createObject(1747,-2029.7448730469,-114.86269378662,1038.9713134766,0,0,230,21),
	createObject(1840,-2027.1564941406,-119.96365356445,1039.3109130859,0,0,290,21),
	createObject(1428,-2028.6091308594,-120.16281890869,1039.5632324219,9.9996032714844,0.50772094726563,179.91186523438,21),
	createObject(1421,-2025.9952392578,-112.81021118164,1038.9080810547,0,0,0,21),
	createObject(2255,-2024.2778320313,-112.88027954102,1040.6029052734,0,0,359.75,21),
	createObject(2114,-2032.05078125,-115.40947723389,1039.8129882813,0,291.99996948242,208,21),
	createObject(1598,-2027.9841308594,-119.97266387939,1038.4255371094,0,300,158,21),
	createObject(2482,-2024.4145507813,-120.27544403076,1038.1955566406,0,0,179.75,21),
	createObject(1764,-2028.8851318359,-115.04608917236,1038.1955566406,0,0,60,21)
}

local col = createColSphere(-2026.47265625, -116.447265625, 1039.1955566406,50)
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
