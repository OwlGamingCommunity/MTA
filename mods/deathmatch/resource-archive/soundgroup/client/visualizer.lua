local screenWidth, screenHeight = guiGetScreenSize( )
local specWidth = screenWidth
local screenWidth = screenWidth * 0
local specHeight = ( specWidth / 16 ) * 7
local screenStartY = specHeight / 2
local bands, peakData, ticks, maxbpm, startTime, release, peak, peaks = 40

specWidth = specWidth / 2

function reset( )
	peaks = { }
	
	for k = 0, bands - 1 do
		peaks[ k ] = { }
	end
	
	peakData = { }
	ticks = getTickCount( )
	maxbpm = 1
	bpmcount = 1
	startTime = 0
	release = { }
	peak = 0
end

local gRotAngle = 0
local gBluColor = 0
local gRedColor = 0
local gHScale = 0
local gVScale = 0

rendering = false
renderingOptions = {
	psychedelicAnimation = true
}

function startVisualizer( )
	startTicks = getTickCount( )
	ticks = getTickCount( )
	reset( )
	
	if ( not cinemaShader ) then
		cinemaShader = dxCreateShader( "shaders/visualizer.fx" )
		
		if ( not cinemaShader ) then
			return
		end
	end
	
	dxSetShaderValue( cinemaShader, "gBrighten", -0.3 )
	dxSetShaderValue( cinemaShader, "gRotAngle", math.rad( gRotAngle ) )
	dxSetShaderValue( cinemaShader, "gGrayScale", 0 )
	dxSetShaderValue( cinemaShader, "gRedColor", gRedColor )
	dxSetShaderValue( cinemaShader, "gGrnColor", 0 )
	dxSetShaderValue( cinemaShader, "gBluColor", 0 )
	dxSetShaderValue( cinemaShader, "gAlpha", 1 )
	dxSetShaderValue( cinemaShader, "gScrRig", 0)
	dxSetShaderValue( cinemaShader, "gScrDow", 0)
	dxSetShaderValue( cinemaShader, "gHScale", gHScale )
	dxSetShaderValue( cinemaShader, "gVScale", gVScale )
	dxSetShaderValue( cinemaShader, "gHOffset", 0 )
	dxSetShaderValue( cinemaShader, "gVOffset", 0 )
	
	if ( not cinemaShader ) then
		return
	else
		renderTarget = dxCreateRenderTarget( specWidth, specHeight )
		
		specWidth = specWidth - 6
		
		engineApplyShaderToWorldTexture( cinemaShader, "drvin_screen" )
	end
	
	if ( not rendering ) then
		rendering = true
		
		addEventHandler( "onClientRender", root, render )
	end
end

function render( )
	if ( sound.source ) and ( rendering ) then --and ( settings.led )
		local fftData = getSoundFFTData( sound.source, 2048, bands )
		
		if ( not fftData ) then
			return
		end
		
		calc( fftData, sound.source )
		
		if ( renderingOptions.psychedelicAnimation ) and ( settings.led ) then
			gRotAngle = gRotAngle + 1
			gBluColor = gBluColor + 0.03
			gRedColor = gRedColor + 0.06
			gHScale = gHScale + 0.25
			gVScale = gVScale + 0.0825
			
			if ( gRotAngle >= 360 ) then
				gRotAngle = gRotAngle < 0 and math.abs( gRotAngle - 360 ) or -gRotAngle - 360
			end
			
			if ( gBluColor >= 0.565 ) then
				gBluColor = 0
			end
			
			if ( gRedColor >= 0.425 ) then
				gRedColor = 0
			end
			
			if ( gHScale >= 15 ) then
				gHScale = 5 / math.random( 10, 1000 )
			end
			
			if ( gVScale >= 10 ) then
				gVScale = 2 / math.random( 10, 1000 )
			end
			
			dxSetShaderValue( cinemaShader, "gRotAngle", math.rad( gRotAngle ) )
			dxSetShaderValue( cinemaShader, "gBluColor", gBluColor )
			dxSetShaderValue( cinemaShader, "gRedColor", gRedColor )
			dxSetShaderValue( cinemaShader, "gHScale", gHScale )
			dxSetShaderValue( cinemaShader, "gVScale", gVScale )
		end
	end
end

function resetLed( )
	gRotAngle = 0
	gBluColor = 0
	gRedColor = 0
	gHScale = 1
	gVScale = 1

	if ( cinemaShader ) then
		dxSetShaderValue( cinemaShader, "gRotAngle", math.rad( gRotAngle ) )
		dxSetShaderValue( cinemaShader, "gBluColor", gBluColor )
		dxSetShaderValue( cinemaShader, "gRedColor", gRedColor )
		dxSetShaderValue( cinemaShader, "gHScale", gHScale )
		dxSetShaderValue( cinemaShader, "gVScale", gVScale )
	end
end

addCommandHandler( "noanimations",
	function( cmd )
		renderingOptions.psychedelicAnimation = not renderingOptions.psychedelicAnimation
		outputChatBox( "Psychedelic rendering " .. ( renderingOptions.psychedelicAnimation and "on" or "off" ) .. ".", 0, 255, 0, false )
		
		if ( not renderingOptions.psychedelicAnimation ) then
			resetLed( )
		end
	end
)

addCommandHandler( "noled",
	function( cmd )
		rendering = not rendering
		
		dxSetShaderValue( cinemaShader, "gAlpha", not rendering and 0 or 1 )
		
		local fn = not rendering and removeEventHandler or addEventHandler
		
		fn( "onClientRender", root, render )
		
		outputChatBox( "Rendering " .. ( rendering and "on" or "off" ) .. ".", 0, 255, 0, false )
	end
)

function min( num1, num2 ) 
	return num1 <= num2 and num1 or num2
end

function max( num1, num2 ) 
	return num1 >= num2 and num1 or num2
end

function calc( fft )
	dxSetRenderTarget( renderTarget, true )
	
	math.randomseed ( getTickCount ( ) )
	
	local bpm = getSoundBPM( sound.source )
	
	if ( not bpm ) or ( bpm == 0 ) then
		bpm = 1
	end
	
	local calced = { }
	local y = 0

	local r, g, b = 0, 0, 0
	local var = bpm + 37
	
	if ( var <= 56 ) then
		r, g, b = 99, 184, 255
	elseif ( var >= 57 and var < 83 ) then
		r, g, b = 238, 174, 238
	elseif ( var >= 83 and var < 146 ) then
		r, g, b = 238, 174, 238
	elseif ( var >= 146 and var < 166 ) then
		r, g, b = 99, 184, 255
	elseif ( var > 166 and var <= 200 ) then
		r, g, b = 238, 201, 0
	elseif ( var >= 200 ) then
		r, g, b = var, 0, 0
	end
	
	local bSpawnParticles = true
	
	if ( bpm <= 1 ) and ( not getSoundBPM( sound.source ) ) and ( getSoundPosition( sound.source ) <= 20 ) then
		r, g, b = 255, 255, 255
		bSpawnParticles = false
	end
	
	local movespeed = ( 1 * ( bpm / 180 ) ) + 1
	local dir = bpm <= 100 and "down" or "up"
	local prevcalced = calced
	
	for x, peak in ipairs( fft ) do
		local posx = x - 1
		
		peak = fft[ x ]
		y = math.sqrt( peak ) * 3 * ( specHeight - 4 )
		
		if ( y > 200 + specHeight ) then
			y = specHeight + 200
		end
		
		calced[ x ] = y
		
		y = y - 1
		
		if ( y >= -1 ) then
			dxDrawRectangle( ( posx * ( specWidth / bands ) ) + 10 + screenWidth, screenStartY, 10, max( ( y + 1 ) / 4, 1 ), tocolor( r, g, b, 255 ) )
		end
		
		if ( bSpawnParticles ) then
			for key = 0, 40 do
				if ( not peaks[ x ][ key ] ) then
					if ( #peaks[ x ] <= 20 ) and ( prevcalced[ x ] <= calced[ x ] ) and ( ( release[ x ] ) or ( release[ x ] == nil ) ) and ( y > 1 ) then
						peaks[ x ][ key ] = { }
						
						if ( dir == "up" ) then
							peaks[ x ][ key ].pos = screenStartY
						else
							peaks[ x ][ key ].pos = screenStartY + ( ( y + 1 ) / 4 )
						end
						
						peaks[ x ][ key ].posx = ( posx * ( specWidth / bands ) ) + 12 + screenWidth + ( 2 - key )
						peaks[ x ][ key ].alpha = 128
						peaks[ x ][ key ].dirx = 0
						
						release[ x ] = false
						
						setTimer( function( )
							release[ x ] = true
						end, 100, 1 )
					end
				else
					if ( bpm > 0 ) then
						local maxScreenPos = 290
						local AlphaMulti = 255 / maxScreenPos
						
						value = peaks[ x ][ key ]
						
						if ( value ~= nil ) then
							local sX = value.posx
							
							dxDrawRectangle( value.posx, value.pos, 7, 7, tocolor( r, g, b, value.alpha ) )
							
							value.pos = dir == "down" and value.pos + movespeed or value.pos - movespeed
							value.posx = value.posx + ( movespeed <= 2 and math.random( -movespeed, movespeed ) or math.random( -1, 1 ) )
							value.alpha = value.alpha - ( AlphaMulti ) - math.random( 1, 4 )
							
							if ( value.alpha <= 0 ) then
								peaks[ x ][ key ] = nil
							end
						end
					end
				end
			end
		end
	end
	
	dxSetRenderTarget( )
	dxSetShaderValue( cinemaShader, "gTexture", renderTarget )
end