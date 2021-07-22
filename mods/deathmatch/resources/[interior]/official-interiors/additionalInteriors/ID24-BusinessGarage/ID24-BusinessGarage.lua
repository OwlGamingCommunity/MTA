local texture = { }
local shader = { }
local property = 
{ 
	{ "transparentTex.png", "smoketest1a_sfw" } -- Remove the ugly shadow
	
}

local objects = 
{
	--Maxime
	createObject ( 10184, 603.54309, -6.72429, 1002.38983, 0, 0, 180 ,1)
}

local col = createColSphere(613.52,     3.31, 1000.92 ,20)

local function watchChanges( )
	if getElementDimension( getLocalPlayer( ) ) > 0 and getElementDimension( getLocalPlayer( ) ) ~= getElementDimension( objects[1] ) and getElementInterior( getLocalPlayer( ) ) == getElementInterior( objects[1] ) then
		for key, value in pairs( objects ) do
			setElementDimension( value, getElementDimension( getLocalPlayer( ) ) )
		end
		for i = 1, #property do -- Remove the ugly Shadow 
			texture[ i ] = dxCreateTexture ( tostring( 'additionalInteriors/ID24-BusinessGarage/'.. property[ i ][ 1 ] ), 'argb', true, 'wrap', '2d' )
			if ( texture[ i ] ) then	
				if ( i <= 21 ) then
					shader[ i ], _ =  dxCreateShader ( 'additionalInteriors/ID24-BusinessGarage/shader.fx', 0, 0, false, 'world' )
				else
					shader[ i ], _ =  dxCreateShader ( 'additionalInteriors/ID24-BusinessGarage/shader.fx', 0, 0, false, 'object' )
				end
				if ( shader[ i ] ) then
					dxSetShaderValue ( shader[ i ], 'Tex0', texture[ i ] )
					engineApplyShaderToWorldTexture ( shader[ i ], tostring( property[ i ][ 2 ] ) )
				end	
			end	
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


