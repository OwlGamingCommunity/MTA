local objects = 
{
	-- Marser
	createObject(7627,969.59191894531,2082.12890625,14.168575286865,0,0,0,28),
	createObject(5313,975.62835693359,2071.0595703125,0.8954519033432,0,0,0,28),
	createObject(5313,941.84875488281,2072.91796875,0.8954519033432,0,0,0.14544677734375,28),
	createObject(5313,986.98419189453,2060.5310058594,8.8454513549805,90,0,269.94067382813,28),
	createObject(11102,977.44049072266,2073.2199707031,12.021842002869,0,0,0,28),
	createObject(11292,928.65185546875,2084.4909667969,14.220579147339,0,0,182.58605957031,28),
	createObject(1721,925.17529296875,2082.6662597656,10.114563941956,0,0,312.3603515625,28),
	createObject(1721,925.1748046875,2082.666015625,10.114563941956,0,0,312.35778808594,28),
	createObject(1721,925.04595947266,2085.17578125,10.114563941956,0,0,252.80834960938,28),
	createObject(2912,932.31713867188,2085.4711914063,10.114563941956,0,0,332.21020507813,28),
	createObject(2912,932.31640625,2085.470703125,10.789553642273,0,0,352.05993652344,28),
	createObject(2062,931.23681640625,2085.6103515625,10.683197021484,0,0,0,28),
	createObject(3626,928.62377929688,2083.8872070313,11.225852966309,0,0,2.4520263671875,28)
}

local col = createColSphere(947.330078125, 2070.7724609375, 10.856549263, 100)
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
