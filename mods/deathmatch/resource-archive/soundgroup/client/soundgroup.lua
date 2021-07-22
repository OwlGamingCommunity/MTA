--[[local currentBPM = 128
local currentBPMS = 468.75
local rotationSpeed = 0.225
local rotationDistance = 30
local lightPhase, lightPhaseEndTick = 1, 0
local lightPhases = {
	{ 255, 255, 255, 255 },
	{ 255, 0, 0, 255 },
	{ 0, 255, 0, 255 },
	{ 0, 0, 255, 255 },
	{ 255, 255, 0, 255 },
	{ 0, 255, 255, 255 },
	{ 255, 0, 255, 255 }
}
local warningAlpha, warningAlphaStep = 255, true
local warningRotation, warningRotationStep = 0, true
local ledWalls, movingLights = { }, { }
local renderingLights, enableReverbEffect, forcedOff, renderingEpilepsyWarning
settings = { lights = true, led = true }
sound = nil
local mapObjects = { }
local uselessObjects = { [ 2991 ] = true, [ 930 ] = true, [ 964 ] = true, [ 8558 ] = true, [ 1722 ] = true, [ 1426 ] = true, [ 1428 ] = true, [ 1391 ] = true, [ 3504 ] = true, [ 2921 ] = true, [ 367 ] = true, [ 620 ] = true, [ 716 ] = true, [ 14391 ] = true, [ 1715 ] = true, [ 3069 ] = true, [ 14820 ] = true, [ 2232 ] = true, [ 2762 ] = true }
local lessObjects
]]

local screenWidth, screenHeight = guiGetScreenSize( )
areaData = nil

addEvent( "soundgroup:synchronize.map", true )
addEventHandler( "soundgroup:synchronize.map", root,
	function( serverAreaData )
		areaData = serverAreaData
	end
)

--[[
local function calculateQuarterNote( bpm )
	if ( tonumber( bpm ) ) then
		return math.floor( ( ( 60 / bpm ) * 1000 ) * 100000 ) / 100000
	end
	
	return 0
end

local function getStageLights( )
	local result = { }
	
	for _, element in ipairs( getElementsByType( "marker" ) ) do
		if ( getElementData( element, "soundgroup:light" ) ) then
			table.insert( result, element )
		end
	end
	
	return result
end

local function destroyStageLights( )
	for _, element in ipairs( getStageLights( ) ) do
		destroyElement( element )
	end
end

local function flushStageMap( )
	destroyStageLights( )
	
	lightPhaseEndTick = getTickCount( ) + currentBPMS
	
	for index, element in ipairs( mapObjects ) do
		if ( getElementModel( element ) == 2763 ) then
			setElementData( element, "soundgroup:led_wall", true )
			
			table.insert( ledWalls, element )
		elseif ( getElementModel( element ) == 2888 ) then
			local x, y, z = getElementPosition( element )
			local _, _, rotZ = getElementRotation( element )
			
			setElementData( element, "soundgroup:light", true )
			setElementData( element, "soundgroup:light.index", index )
			
			local corona = createMarker( x, y, z + 0.2, "corona", 0.725 )
			
			setElementInterior( corona, getElementInterior( element ) )
			setElementDimension( corona, getElementDimension( element ) )
			setElementData( corona, "soundgroup:light", true )
			setElementParent( corona, element )
			
			table.insert( movingLights, { originalRotationZ = rotZ, object = element, corona = corona } )
		end
	end
	
	return true
end

local function playStageSound( )
	if ( sound ) then
		if ( isElement( sound.source ) ) then
			destroyElement( sound.source )
		end
		
		if ( sound.filePath ) and ( sound.filePath:find( "http" ) ) then
			sound.source = playSound3D( sound.filePath, sound.x, sound.y, sound.z, false )
			
			if ( sound.source ) then
				setElementInterior( sound.source, sound.interior )
				setElementDimension( sound.source, sound.dimension )
				
				setSoundMinDistance( sound.source, sound.minDistance )
				setSoundMaxDistance( sound.source, sound.maxDistance )
				setSoundVolume( sound.source, sound.volume )
				
				setTimer( function( sound )
					if ( isElement( sound ) ) then
						setSoundPanningEnabled( sound, false )
						
						startVisualizer( )
						
						if ( not forcedOff ) and ( not renderingLights ) then
							for _, element in ipairs( getStageLights( ) ) do
								setMarkerColor( element, 0, 0, 255, 255 )
								
								local object = getElementParent( element )
								
								if ( object ) then
									local rotX, rotY, rotZ = getElementRotation( object )
									local data = movingLights[ tonumber( getElementData( object, "soundgroup:light.index" ) ) ]
									
									if ( data ) then
										setElementRotation( object, rotX, rotY, data.originalRotationZ )
									end
								end
							end
							
							renderingLights = true
							
							addEventHandler( "onClientRender", root, renderLights )
						end
					end
				end, 1000, 1, sound.source )
				
				return true
			end
		else
			sound.source = nil
			
			if ( cinemaShader ) then
				dxSetShaderValue( cinemaShader, "gBrighten", -2.25 )
			end
			
			for _, element in ipairs( getStageLights( ) ) do
				setMarkerColor( element, 0, 0, 255, 255 )
				
				local object = getElementParent( element )
				
				if ( object ) then
					local rotX, rotY, rotZ = getElementRotation( object )
					local data = movingLights[ tonumber( getElementData( object, "soundgroup:light.index" ) ) ]
					
					if ( data ) then
						setElementRotation( object, rotX, rotY, data.originalRotationZ )
					end
				end
			end
		end
	end
	
	return false
end

local function synchronizeMap( )
	triggerServerEvent( "soundgroup:synchronize.map", localPlayer )
end

local function synchronizeSound( )
	triggerServerEvent( "soundgroup:synchronize.sound", localPlayer )
end
addEvent( "soundgroup:stop", true )
addEventHandler( "soundgroup:stop", root,
	function( )
		destroyStageLights( )
		
		if ( sound ) then
			sound.filePath = nil
			
			playStageSound( )
		end
		
		if ( renderingLights ) then
			renderingLights = false
			
			removeEventHandler( "onClientRender", root, renderLights )
		end
	end
)

addEvent( "soundgroup:synchronize.settings", true )
addEventHandler( "soundgroup:synchronize.settings", root,
	function( serverSettings )
		settings = serverSettings
		
		resetLed( )
	end
)

addEvent( "soundgroup:synchronize.sound", true )
addEventHandler( "soundgroup:synchronize.sound", root,
	function( serverSound )
		local soundSource = sound and sound.source or nil
		
		sound = serverSound
		sound.source = soundSource
		
		enableReverbEffect = false
		
		playStageSound( )
		
		renderingLightsEndTick = getTickCount( ) + 1000
	end
)

addEvent( "soundgroup:epilepsy_warning", true )
addEventHandler( "soundgroup:epilepsy_warning", root,
	function( state )
		renderingEpilepsyWarning = state
		
		local fn = renderingEpilepsyWarning and addEventHandler or removeEventHandler
		fn( "onClientHUDRender", root, epilepsyWarningRender )
	end
)

function renderLights( )
	if ( renderingLights ) and ( settings.lights ) then
		if ( areaData ) then
			local x, y, z = getElementPosition( localPlayer )
			local interior, dimension = getElementInterior( localPlayer ), getElementDimension( localPlayer )
			
			if ( getDistanceBetweenPoints3D( x, y, z, areaData.x, areaData.y, areaData.z ) < areaData.radius ) and ( interior == areaData.interior ) and ( dimension == areaData.dimension ) and ( sound.source ) then
				if ( getSoundBPM( sound.source ) ) and ( math.ceil( getSoundBPM( sound.source ) ) ~= currentBPM ) then
					currentBPM = math.ceil( getSoundBPM( sound.source ) )
					currentBPMS = calculateQuarterNote( currentBPM )
				end
				
				if ( getTickCount( ) >= lightPhaseEndTick ) then
					lightPhase = lightPhases[ lightPhase + 1 ] and lightPhase + 1 or 1
					lightPhaseEndTick = getTickCount( ) + currentBPMS
				end
				
				for index, data in ipairs( movingLights ) do
					if ( isElement( data.object ) ) then
						local rotX, rotY, rotZ = getElementRotation( data.object )
						
						if ( data.rotationPhase ) then
							if ( rotZ < data.originalRotationZ + ( rotationDistance / 2 ) ) then
								rotZ = rotZ + ( rotationSpeed + math.random( 0, 10 ) / 100 )
							else
								movingLights[ index ].rotationPhase = false
							end
						else
							if ( rotZ > data.originalRotationZ - ( rotationDistance / 2 ) ) then
								rotZ = rotZ - ( rotationSpeed + math.random( 0, 20 ) / 100 )
							else
								movingLights[ index ].rotationPhase = true
							end
						end
						
						rotZ = rotZ > 360 and rotZ - 360 or ( rotZ < 0 and rotZ + 360 or rotZ )
						
						setElementRotation( data.object, rotX, rotY, rotZ )
					end
					
					if ( isElement( data.corona ) ) then
						local lightPhase = lightPhases[ lightPhase ]
						
						setMarkerColor( movingLights[ index ].corona, lightPhase[ 1 ], lightPhase[ 2 ], lightPhase[ 3 ], lightPhase[ 4 ] )
					end
				end
			end
			
			if ( getTickCount( ) >= renderingLightsEndTick ) and ( sound.source ) and ( ( not isLineOfSightClear( x, y, z, sound.x, sound.y, sound.z, true, false, false, false, false, true, true, localPlayer ) ) or ( getDistanceBetweenPoints3D( x, y, z, sound.x, sound.y, sound.z ) > 65 ) ) and ( interior == sound.interior ) and ( dimension == sound.dimension ) then
				if ( not enableReverbEffect ) then
					setSoundEffectEnabled( sound.source, "reverb", true )
					setSoundVolume( sound.source, 0.2 )
					enableReverbEffect = true
				end
			else
				if ( enableReverbEffect ) then
					setSoundEffectEnabled( sound.source, "reverb", false )
					setSoundVolume( sound.source, 0.35 )
					enableReverbEffect = false
				end
			end
		end
	end
end

function epilepsyWarningRender( )
	if ( not renderingEpilepsyWarning ) then
		return
	end
	
	if ( areaData ) and ( sound.source ) then
		if ( getDistanceBetweenPoints3D( areaData.x, areaData.y, areaData.z, getElementPosition( localPlayer ) ) < areaData.radius ) and ( getElementInterior( localPlayer ) == areaData.interior ) and ( getElementDimension( localPlayer ) == areaData.dimension ) then
			if ( not warningAlphaStep ) then
				if ( warningAlpha >= 255 ) then
					warningAlphaStep = true
				else
					warningAlpha = warningAlpha + 5
				end
			else
				if ( warningAlpha <= 100 ) then
					warningAlphaStep = false
				else
					warningAlpha = warningAlpha - 5
				end
			end
			
			if ( not warningRotationStep ) then
				if ( warningRotation >= 5 ) then
					warningRotationStep = true
				else
					warningRotation = warningRotation + 0.16
				end
			else
				if ( warningRotation <= -5 ) then
					warningRotationStep = false
				else
					warningRotation = warningRotation - 0.16
				end
			end
			
			dxDrawImage( 0, screenHeight - 165, 200, 200, "assets/warning_white.png", warningRotation, 0, 0, tocolor( 255, 255, 255, warningAlpha ), true )
		end
	end
end
]]

--[[local chairs = { left = { }, right = { }, front = { } }
local maxRows = 100

local soundGroupTexture = dxCreateTexture( "assets/soundgroup-logo@1920x1920.png" )

addEventHandler( "onClientPreRender", root,
	function( )
		--if ( areaData ) and ( getDistanceBetweenPoints3D( areaData.x, areaData.y, areaData.z, getElementPosition( localPlayer ) ) <= 100 ) and ( getElementInterior( localPlayer ) == areaData.interior ) and ( getElementDimension( localPlayer ) == areaData.dimension ) then
			local x, y, z = 598.70001220703, -1255.4, 70.400001525879
			
			dxSetBlendMode( "add" )
			dxDrawMaterialSectionLine3D( x, y, z - 3, x, y, z + 2, 0, 0, 1920, 1920, soundGroupTexture, 5, tocolor( 255, 255, 255, 255 ), x - 5, y, z )
			dxSetBlendMode( "blend" )
		--end
	end
)]]

addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		triggerServerEvent( "soundgroup:ready", localPlayer )
	end
)

--[[
addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		--currentBPMS = calculateQuarterNote( currentBPM )
		
		triggerServerEvent( "soundgroup:ready", localPlayer )
		
		--renderingLightsEndTick = getTickCount( ) + 1000
		
		local rows = 5
		local columns = 27
		
		-- left seatings
		for i = 0, rows - 1 do
			chairs.left[ i ] = { }
			for j = 0, columns - 1 do
				local obj = createObject( 1721, 600.90002441406 + ( i * 1.3 ), -1246 - ( j * 0.7 ), 70.300003051758 + ( i * 0.3 ), 0, 0, 90 )
				table.insert( chairs.left[ i ], obj )
				setElementDimension( obj, 491 )
				setElementInterior( obj, 3 )
			end
		end
		
		-- right seatings
		for i = 0, rows - 1 do
			chairs.right[ i ] = { }
			for j = 0, columns - 1 do
				local obj = createObject( 1721, 592.40002441406 - ( i * 1.3 ), -1246 - ( j * 0.7 ), 70.300003051758 + ( i * 0.3 ), 0, 0, 270 )
				table.insert( chairs.right[ i ], obj )
				setElementDimension( obj, 491 )
				setElementInterior( obj, 3 )
			end
		end
		
		local total = rows * columns * 2
		local rows = 5
		local columns = 7
		
		-- front seatings
		for i = 0, rows - 1 do
			chairs.front[ i ] = { }
			for j = 0, columns - 1 do
				local obj = createObject( 1721, 598.75 - ( j * 0.7 ), -1243.8000488281 + ( i * 1.3 ), 70.300003051758, 0, 0, 180 )
				table.insert( chairs.front[ i ], obj )
				setElementDimension( obj, 491 )
				setElementInterior( obj, 3 )
			end
		end
		
		total = total + ( rows * columns )
		
		--outputChatBox( total )
		
		maxRows = rows
		
		local dupontTexture = dxCreateTexture( "assets/dupont-fashion-logo@397x174.png" )
		local soundGroupTexture = dxCreateTexture( "assets/soundgroup-logo@1920x1920.png" )
		
		multiplier = 0.8
		multiplierState = false
		maxi = 25
		maxiState = false

		addEventHandler( "onClientPreRender", root,
			function( )
				if ( areaData ) and ( getDistanceBetweenPoints3D( areaData.x, areaData.y, areaData.z, getElementPosition( localPlayer ) ) <= 100 ) and ( getElementInterior( localPlayer ) == areaData.interior ) and ( getElementDimension( localPlayer ) == areaData.dimension ) then
					-- dupont logo 1
					if ( dupontTexture ) then
						local x, y, z = 604, -1265.9, 72.3
						
						dxSetBlendMode( "add" )
						dxDrawMaterialSectionLine3D( x, y, z + 3, x, y, z, 0, 0, 397, 174, dupontTexture, 5, tocolor( 0, 0, 0, 75 ), x, y + 5, z )
						dxSetBlendMode( "blend" )
					end
					
					-- dupont logo 2
					if ( dupontTexture ) then
						local x, y, z = 589.5, -1265.9, 72.3
						
						dxSetBlendMode( "add" )
						dxDrawMaterialSectionLine3D( x, y, z + 3, x, y, z, 0, 0, 397, 174, dupontTexture, 5, tocolor( 0, 0, 0, 75 ), x, y + 5, z )
						dxSetBlendMode( "blend" )
					end
					
					-- soundgroup logo 1
					if ( soundGroupTexture ) then
						local x, y, z = 608.6, -1255, 75.5
						
						dxSetBlendMode( "add" )
						dxDrawMaterialSectionLine3D( x, y, z - 3, x, y, z + 3, 0, 0, 1920, 1920, soundGroupTexture, 5, tocolor( 255, 255, 255, 225 ), x - 5, y, z )
						dxSetBlendMode( "blend" )
					end
					
					-- soundgroup logo 2
					if ( soundGroupTexture ) then
						local x, y, z = 584.825, -1254.375, 75.5
						
						dxSetBlendMode( "add" )
						dxDrawMaterialSectionLine3D( x, y, z - 3, x, y, z + 3, 0, 0, 1920, 1920, soundGroupTexture, 5, tocolor( 255, 255, 255, 225 ), x + 5, y, z )
						dxSetBlendMode( "blend" )
					end
					
					-- laser
					if ( multiplierState ) then
						if ( multiplier >= 1.7 ) then
							multiplierState = false
						else
							multiplier = multiplier + 0.003
						end
					else
						if ( multiplier <= 0.3 ) then
							multiplierState = true
						else
							multiplier = multiplier - 0.003
						end
					end
					
					if ( maxiState ) then
						if ( maxi >= 50 ) then
							maxiState = false
						else
							maxi = maxi + 1
						end
					else
						if ( maxi <= 1 ) then
							maxiState = true
						else
							maxi = maxi - 1
						end
					end
					
					local x, y, z = 596.6, -1269.1999511719, 77.3
					
					for i = 0, maxi do
						dxDrawLine3D( x, y, z, x + ( i * multiplier ), y + 40, z, tocolor( 195, 225, 255, math.random( 40, 80 ) ), 0.1925 )
						dxDrawLine3D( x, y, z, x - ( i * multiplier ), y + 40, z, tocolor( 195, 225, 255, math.random( 40, 80 ) ), 0.1925 )
					end
				end
			end
		)
	end
)
]]

addCommandHandler( "lessobjects",
	function( cmd, minRows )
		lessObjects = not lessObjects
		
		local minRows = tonumber( minRows ) and tonumber( minRows ) or 0
			  minRows = math.max( 0, math.min( maxRows, minRows ) )
		
		if ( lessObjects ) then
			for type, rows in pairs( chairs ) do
				for row, elements in pairs( rows ) do
					if ( tonumber( row ) >= minRows ) then
						for column, element in ipairs( elements ) do
							setElementData( element, "temp:old_dimension", getElementDimension( element ) )
							setElementDimension( element, 1337 )
						end
					end
				end
			end
		else
			for type, rows in pairs( chairs ) do
				for row, elements in pairs( rows ) do
					for column, element in ipairs( elements ) do
						local oldDimension = tonumber( getElementData( element, "temp:old_dimension" ) )
						
						if ( oldDimension ) then
							setElementDimension( element, oldDimension )
						end
					end
				end
			end
		end
		
		outputChatBox( "Believe it or not, there are now " .. ( lessObjects and "less" or "more" ) .. " objects.", 0, 255, 0, false )
	end
)

--[[
addCommandHandler( "nomusic",
	function( cmd )
		--
		if ( sound.source ) then
			sound.filePath = nil
			
			playStageSound( )
			
			outputChatBox( "Music is now off.", 0, 255, 0, false )
		else
			synchronizeSound( )
			
			outputChatBox( "Music is now on.", 0, 255, 0, false )
		end
		--
		
		local isSoundOff = getSoundVolume( sound.source ) == 0
		
		setSoundVolume( sound.source, isSoundOff and 0.35 or 0 )
		
		outputChatBox( "Music is now " .. ( isSoundOff and "on" or "off" ) .. ".", 0, 255, 0, false )
	end
)

addCommandHandler( "musicvolume",
	function( cmd, volume )
		local volume = tonumber( volume )
		
		if ( volume ) then
			volume = math.min( 100, math.max( 0, volume ) )
			
			setSoundVolume( sound.source, volume / 100 )
			
			outputChatBox( "Volume set to " .. volume .. "%.", 0, 255, 0, false )
		else
			outputChatBox( "SYNTAX: /" .. cmd .. " [volume: 0-100]", 220, 180, 20, false )
		end
	end
)

addCommandHandler( "noeffects",
	function( cmd )
		renderingLights = true
		executeCommandHandler( "nolights" )
		
		rendering = true
		executeCommandHandler( "noled" )
		
		renderingOptions.psychedelicAnimation = true
		executeCommandHandler( "noanimations" )
	end
)

addCommandHandler( "nolights",
	function( cmd )
		renderingLights = not renderingLights
		forcedOff = not renderingLights
		
		local fn = not renderingLights and removeEventHandler or addEventHandler
		
		fn( "onClientRender", root, renderLights )
		
		if ( not renderingLights ) then
			destroyStageLights( )
		else
			flushStageMap( )
		end
		
		outputChatBox( "Rendering lights " .. ( renderingLights and "on" or "off" ) .. ".", 0, 255, 0, false )
	end
)]]