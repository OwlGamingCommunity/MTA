-- @author: Terra
-- @info: re-textures for L.S.P.D head-quarters
-- @type: client side

local texture = { }
local shader = { }
local property = 
{ 
	{ 'wall.png', 'mp_cop_wall' }, { 'wall.png', 'mp_cop_wallpink' }, 
	{ 'beam.png', 'mp_cop_skirting' }, { 'beam.png', 'mp_cop_skirt' },
	{ 'floor.png', 'mp_cop_floor1' }, { 'wall.png', 'mp_cop_ceiling' },
	{ 'floor.png', 'mp_cop_floor' }, { 'floor.png', 'mp_cop_floor2' },
	{ 'floor.png', 'mp_cop_tile' }, { 'floor.png', 'mp_cop_carpet' },
	{ 'floor.png', 'mp_cop_ceilingtile' }, { 'floor.png', 'mp_cop_vinyl' },
	{ 'cellwall.png', 'mp_tank_roomplain' }, { 'cellwall.png', 'mp_tank_room' }, 
	{ 'cellwall.png', 'mp_cop_cell' }, { 'floor.png', 'mp_gun_dirt' },
	{ 'floor.png', 'pol_stairs2' }, { 'beam.png', 'mp_cop_frame' }, 
	{ 'beam.png', 'mp_cop_marble' }, { 'beam.png', 'mp_cop_sep' },
	{ 'chief.png', 'mp_cop_chief' }, { 'beam.png', 'garage_docks' },
	{ 'logo.png', 'cj_bs_menu4' }, { 'plates.png', 'cj_cert_2' },
	{ 'plates2.png', 'cj_cert_1' }
}

addEventHandler ( 'onClientResourceStart', resourceRoot,
	function ( )
		for i = 1, #property do
			texture[ i ] = dxCreateTexture ('Int-LSPD/textures/'.. property[ i ][ 1 ], 'argb', true, 'wrap', '2d' )
			if ( texture[ i ] ) then	
				if ( i <= 21 ) then
					shader[ i ], _ =  dxCreateShader ( 'Int-LSPD/shader.fx', 0, 0, false, 'world' )
				else
					shader[ i ], _ =  dxCreateShader ( 'Int-LSPD/shader.fx', 0, 0, false, 'object' )
				end
				
				if ( shader[ i ] ) then
					dxSetShaderValue ( shader[ i ], 'Tex0', texture[ i ] )
					engineApplyShaderToWorldTexture ( shader[ i ], tostring( property[ i ][ 2 ] ) )
				end	
			end	
		end
	end
)		

local removalTable = 
{ 
	-- Dispatch Room
	{ 2198, 5.00, 233.609375, 124.015625, 1003.21875, 10 }, 
	{ 2197, 5.00, 233.609375, 124.015625, 1003.21875, 10 },
	
	-- Interrogation Room
	{ 2185, 10.00, 223.4052734375, 109.984375, 1010.21875, 10 },
	{ 2162, 10.00, 223.4052734375, 109.984375, 1010.21875, 10 },
	{ 1806, 10.00, 223.4052734375, 109.984375, 1010.21875, 10 },
	
	-- Situation Room
	{ 2029, 5.00, 222.8701171875, 124.716796875, 1010.21875, 10 },
	{ 1715, 5.00, 222.8701171875, 124.716796875, 1010.21875, 10 },
	
	-- Cells
	--{ 2165, 2.00, 226.7802734375, 119.462890625, 999.03985595703, 10 },
	{ 1806, 2.00, 226.7802734375, 119.462890625, 999.03985595703, 10 },
	--{ 2165, 2.00, 222.984375, 119.2421875, 999.13073730469, 10 },
	{ 1806, 2.00, 222.984375, 119.2421875, 999.13073730469, 10 },
	{ 2356, 5.00, 222.984375, 119.2421875, 999.13073730469, 10 },
	
	-- Training Room
	{ 2165, 10.00, 274.53125, 109.798828125, 1008.8203125, 10 },
	{ 1806, 10.00, 274.53125, 109.798828125, 1008.8203125, 10 },
	{ 2356, 10.00, 274.53125, 109.798828125, 1008.8203125, 10 },
	
	-- Briefing Room
	{ 1722, 5.00, 260.970703125, 109.255859375, 1008.8203125, 10 },
	
	-- Downstairs ( west )
	{ 1998, 10.00, 228.171875, 111.2373046875, 1003.21875, 10 },
	{ 2008, 10.00, 228.171875, 111.2373046875, 1003.21875, 10 },
	{ 2356, 10.00, 228.171875, 111.2373046875, 1003.21875, 10 },
	{ 1806, 10.00, 228.171875, 111.2373046875, 1003.21875, 10 },
	{ 2174, 10.00, 228.171875, 111.2373046875, 1003.21875, 10 },
	
	{ 1722, 2.00, 225.376953125, 120.708984375, 1003.21875, 10 }
}

addEventHandler ( 'onClientElementStreamIn', root,
	function ( )
		for key, value in ipairs ( removalTable ) do
			
			local objectID, radius, x, y, z, interior = value[ 1 ], value[ 2 ], value[ 3 ], value[ 4 ], value[ 5 ], value[ 6 ]
			if ( objectID ~= nil ) and ( radius ~= nil ) and ( x ~= nil ) and ( y ~= nil ) and ( z ~= nil ) and ( interior ~= nil ) then
				
				removeWorldModel ( objectID, radius, x, y, z, interior )
			end	
		end	
	end
)	