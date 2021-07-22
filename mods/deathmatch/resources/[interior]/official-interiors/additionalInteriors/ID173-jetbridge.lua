local objects = 
{
	--Exciter
	createObject(7996,1596.7,1618,7.9,0,0,0,4), --object (vgsSairportland03) (2)
	createObject(4990,1637.3,1565.2,10.5,0,0,0,4), --object (airprtwlkto1_LAS) (1)
	createObject(8615,1593.5,1615.9,12.5,0,0,270,4), --object (vgsSstairs04_lvs) (1)
	createObject(4990,1632.2,1565.3,14,0,0,0,4), --object (airprtwlkto1_LAS) (2)
	createObject(4990,1642.4,1565.2,14,0,0,0,4), --object (airprtwlkto1_LAS) (3)
	createObject(4990,1637.3,1565.3,17.6,0,0,0,4), --object (airprtwlkto1_LAS) (4),
	createObject(3489,1632.5,1615.9,16.4,0,0,320,4), --object (HANGAR1_08_LVS) (1)
	createObject(3489,1626.5,1622.4,16.4,0,0,347.999,4), --object (HANGAR1_08_LVS) (2)
	createObject(3489,1624.8,1614.2,16.4,0,0,359.997,4), --object (HANGAR1_08_LVS) (3)
	createObject(3489,1621.3,1631.4,16.4,0,0,39.995,4), --object (HANGAR1_08_LVS) (4),
	createObject(3489,1613.4,1644.9,16.4,0,0,89.988,4), --object (HANGAR1_08_LVS) (6)
	createObject(3489,1561.4,1610.3,16.4,0,0,229.984,4), --object (HANGAR1_08_LVS) (7)
	createObject(3489,1569.5,1612.2,16.4,0,0,179.979,4), --object (HANGAR1_08_LVS) (8)
	createObject(3489,1562,1621.9,16.4,0,0,209.978,4), --object (HANGAR1_08_LVS) (9)
	createObject(3489,1563.5,1620.2,16.4,0,0,139.727,4), --object (HANGAR1_08_LVS) (11)
	createObject(3489,1594.2,1589.2,-11,90,0,269.999,4), --object (HANGAR1_08_LVS) (12)
	createObject(4990,1636.8,1640.2,15.3,0,0,0,4), --object (airprtwlkto1_LAS) (5)
	createObject(4990,1697.4,1524.7,16.6,0,0,310,4), --object (airprtwlkto1_LAS) (6)
	createObject(7191,1616.5,1612.8,14.2,0,270,90,4), --object (vegasNnewfence2b) (29)
	createObject(7191,1616.5,1616.7,14.2,0,270,90,4), --object (vegasNnewfence2b) (37)
	createObject(7191,1616.5,1620.6,14.2,0,270,90,4), --object (vegasNnewfence2b) (42)
	createObject(7191,1616.5,1624.5,14.2,0,270,90,4), --object (vegasNnewfence2b) (44),
	createObject(1649,1594.4,1616,15.9,0,0,90,4), --object (wglasssmash) (38)
	createObject(1649,1594.4,1620.4,15.9,0,0,90,4), --object (wglasssmash) (39)
	createObject(1649,1594.4,1610.1,15.9,0,0,90,4), --object (wglasssmash) (40)
	createObject(1649,1594.4,1611.6,18.6,0,0,90,4), --object (wglasssmash) (41)
	createObject(1649,1594.4,1616,19.2,0,0,90,4), --object (wglasssmash) (42)
	createObject(1649,1594.4,1620.4,19.2,0,0,90,4), --object (wglasssmash) (43)
	createObject(8069,1599.1,1604.8,22.2,0,180,0,4), --object (hseing05_lvs) (1)
	createObject(1569,1596.4,1583.1,14.2,0,0,0,4), --object (ADAM_V_DOOR) (9)
}

local col = createColSphere(1597, 1622, 10.8, 150)

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
