-- @author: Terra
-- @info: open-able doors & world model removals
-- @type: server side


-- CHANGE THE DOORS' DIMENSION AND INTERIOR BEFORE UPLOADING!!

local roomDoors = 
{ 
	-- ID, x, y, z, rx, ry, rz, offsetx, offsety, rotation 
	
	-- Chief's Office
	{ 3089, 229.6510, 119.5000, 1010.3500, 0, 0, 0, 0.48, 0, 90 },
	{ 3089, 232.6370, 119.5000, 1010.3500, 0, 0, 180, -0.5, 0, -90 },
	
	-- Commander's Office
	{ 3089, 232.8999, 110.5700, 1010.3500, 0, 0, 270, 0, -0.48, 90 },
	{ 3089, 232.8999, 107.5840, 1010.3500, 0, 0, 90, 0, 0.49, -90 },
	
	-- Interrogation Room
	{ 3089, 229.5000, 110.5700, 1010.3500, 0, 0, 270, 0, -0.48, -90 },
	{ 3089, 229.5000, 107.5840, 1010.3500, 0, 0, 90, 0, 0.49, 90 },
	
	-- Situation Room
	{ 3089, 222.1899, 119.5000, 1010.3500, 0, 0, 0, 0, 0, 90 },
	
	-- Second Floor ( East )
	{ 3089, 260.0700, 117.6999, 1008.9500, 0, 0, 180, 0, 0, 90 }, 
	{ 3089, 260.7599, 117.6999, 1008.9500, 0, 0, 0, 0, 0, -90 },
	
	{ 3089, 268.3800, 115.8800, 1008.9500, 0, 0, 270, 0, -0.48, 90 },
	{ 3089, 268.3800, 112.9000, 1008.9500, 0, 0, 90, 0, 0.49, -90 },
	
	{ 3089, 268.3800, 110.5800, 1008.9500, 0, 0, 270, 0, -0.48, 90 },
	{ 3089, 268.3800, 107.6000, 1008.9500, 0, 0, 90, 0, 0.49, -90 },
	
	{ 3089, 265.2000, 112.6600, 1008.9500, 0, 0, 270, 0, 0, -90 },
	
	-- Ground Floor ( East )
	{ 3089, 268.9870, 112.5999, 1004.7500, 0, 0, 0, 0.49, 0, -90 },
	{ 3089, 271.9730, 112.5999, 1004.7500, 0, 0, 180, -0.49, 0, 90 },
	
	{ 3089, 264.3450, 112.5999, 1004.7500, 0, 0, 0, 0.49, 0, -90 },
	{ 3089, 267.3310, 112.5999, 1004.7500, 0, 0, 180, -0.49, 0, 90 },
	
	{ 3089, 264.4800, 115.8000, 1004.7500, 0, 0, 0, 0.49, 0, 90 },
	{ 3089, 267.4577, 115.8000, 1004.7500, 0, 0, 180, -0.5, 0, -90 },
	
	{ 3089, 275.7799, 118.8800, 1004.7500, 0, 0, 270, 0, -0.49, -90 },
	{ 3089, 275.7799, 115.9000, 1004.7500, 0, 0, 90, 0, 0.48, 90 },
	
	{ 3089, 275.7801, 122.8500, 1004.7500, 0, 0, 270, 0, 0, -90 },
	
	{ 3089, 253.1000, 107.5899, 1003.3500, 0, 0, 90, 0, 0.49, -90 },
	{ 3089, 253.1000, 110.5699, 1003.3500, 0, 0, 270, 0, -0.49, 90 },
	
	{ 3089, 253.1000, 123.7800, 1003.3500, 0, 0, 90, 0, 0.49, -90 },
	{ 3089, 253.1000, 126.7600, 1003.3500, 0, 0, 270, 0, -0.49, 90 },
	
	-- Ground Floor ( West )
	{ 3089, 239.6999, 119.0700, 1003.3500, 0, 0, 270, 0, -0.49, -90 },
	{ 3089, 239.6999, 116.0900, 1003.3500, 0, 0, 90, 0, 0.49, 90 },
	
	{ 3089, 239.6999, 123.5920, 1003.3500, 0, 0, 90, 0, 0.49, 90 },
	{ 3089, 239.6999, 126.5759, 1003.3500, 0, 0, 270, 0, -0.49, -90 },
	
	--{ 3089, 238.9100, 116.0000, 1003.3500, 0, 0, 180, -0.49, 0, 90 },
	--{ 3089, 235.9290, 116.0000, 1003.3500, 0, 0, 0, 0.5, 0, -90 },
	
	{ 3089, 233.1200, 119.1999, 1003.3500, 0, 0, 0, 0, 0, 90 },
	--{ 3089, 236.8292, 119.1999, 1003.3500, 0, 0, 0, 0, 0, 90 },
	
	{ 3089, 225.0900, 116.0000, 1003.3500, 0, 0, 0, 0, 0, -90 },
	
	{ 3089, 220.3380, 116.0000, 1003.3500, 0, 0, 0, 0.49, 0, -90 },
	{ 3089, 223.3240, 116.0000, 1003.3500, 0, 0, 180, -0.49, 0, 90 },
	
	-- Cells
	{ 14843, 212.9799, 116.5000, 999.2699, 0, 0, 0, 0, 0, 0 },
	{ 01495, 213.6000, 124.8899, 998.0000, 0, 0, 0, 0.1, 0, -86 },
	{ 01495, 220.1000, 118.5000, 998.0000, 0, 0, 0, 0.1, 0, 86 },
}	

local theDoors = { }
addEventHandler ( 'onResourceStart', resourceRoot,
	function ( )
		for key, value in ipairs ( roomDoors ) do
			
			local objectID, x, y, z, rotX, rotY, rotZ, offX, offY, targetZ = value[ 1 ], value[ 2 ], value[ 3 ], value[ 4 ], value[ 5 ], value[ 6 ], value[ 7 ], value[ 8 ], value[ 9 ], value[ 10 ]
			if ( objectID ~= nil ) and ( x ~= nil ) and ( y ~= nil ) and ( z ~= nil ) and ( rotX ~= nil ) and ( rotY ~= nil ) and ( rotZ ~= nil ) then
				
				local theDoor = createObject ( objectID, x, y, z, rotX, rotY, rotZ, false )
				if ( theDoor ) then
					
					table.insert ( theDoors, { theDoor, offX, offY, targetZ, false } )
					
					if ( objectID ~= 0968 ) then
						setElementInterior ( theDoor , 10 )
						setElementDimension ( theDoor, 18 )
					else
						setElementInterior ( theDoor , 0 )
						setElementDimension ( theDoor, 0 )
					end
				end	
			end
		end	
	end
)

addCommandHandler ( 'gate', 
	function ( thePlayer, commandName )
		
		if ( exports.global:hasItem( thePlayer, 131 ) ) then
		
			for key, value in ipairs ( theDoors ) do
				
				local isOpen = value[ 5 ]
				if ( not isOpen ) then
					
					local x, y, z = getElementPosition ( thePlayer )
					local doorX, doorY, doorZ = getElementPosition ( value[ 1 ] )
					
					if ( getElementModel ( value[ 1 ] ) == 14843 ) then
						x = x - 4 -- The centre of the cell gate is out of bounds for the player, hence the offset.
					end
					
					local distance = 3
					if ( getElementModel( value[ 1 ] ) == 0968 ) then
						distance = 10 
					end
					
					if ( getDistanceBetweenPoints3D ( x, y, z, doorX, doorY, doorZ ) <= distance ) then
						
						value[ 5 ] = true
						
						if ( getElementModel ( value[ 1 ] ) ~= 14843 and getElementModel ( value[ 1 ] ) ~= 0968 ) then -- Room doors
							moveObject ( value[ 1 ], 1500, doorX + value[ 2 ], doorY + value[ 3 ], doorZ, 0, 0, value[ 4 ] )
							setTimer( 
								function( )
									
									moveObject( value[ 1 ], 1500, doorX, doorY, doorZ, 0, 0, -value[ 4 ] )
									setTimer( function( ) value[ 5 ] = false end, 1500, 1 )
									
								end, 5000, 1
							)
						elseif ( getElementModel( value[ 1 ] ) == 14843 ) then -- Cell door
							moveObject ( value[ 1 ], 2000, doorX - 1.8, doorY, doorZ, 0, 0, 0 )
							
							setTimer( moveObject, 6000, 1, value[ 1 ], 2000, doorX, doorY, doorZ, 0, 0, 0 )
							setTimer( function( ) value[ 5 ] = false end, 8000, 1 )
							
						elseif ( getElementModel ( value[ 1 ] ) == 0968 ) then -- Barrier ( outside )
							moveObject ( value[ 1 ], 1500, doorX, doorY, doorZ, 0, value[ 4 ], 0 )
							setTimer( 
								function( )
									
									moveObject( value[ 1 ], 1500, doorX, doorY, doorZ, 0, -value[ 4 ], 0 )
									setTimer( function( ) value[ 5 ] = false end, 1500, 1 )
									
								end, 5000, 1
							)
						end	
					end
				end
			end
		end	
	end
)	