--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]
 
-- settings.
local strength = 0
local maxStrength = 6
local fadeSpeed = 0.1
local forced = false
local last = getTickCount()
local duration = 10000

-- variables.
local sw, sh = guiGetScreenSize()
local ss = dxCreateScreenSource( sw, sh )
local blurShader, blurTec, rendering
local state = 'on'

addEventHandler( 'onClientResourceStart', resourceRoot,
function()
	blurShader, blurTec = dxCreateShader('blur/blurshader.fx')
    if not blurShader then
        outputDebugString('[HUD] Could not create blur shader. Please use debugscript 3.')
    end
end )

addEventHandler( 'onClientResourceStop', resourceRoot,
function()
    if (blurShader) then
        destroyElement( blurShader )
        blurShader = nil
    end
end )

local function render()
    rendering = true
    if blurShader then
        if duration and getTickCount() - last >= duration then
            state = 'off'
            force = false
        end
        dxUpdateScreenSource( ss )
        dxSetShaderValue( blurShader, 'ScreenSource', ss )
        dxSetShaderValue( blurShader, 'BlurStrength', strength )
		dxSetShaderValue( blurShader, 'UVSize', sw, sh )
        dxDrawImage( 0, 0, sw, sh, blurShader )
        if state == 'on' then
            if strength >= 0 and strength < maxStrength-fadeSpeed then
                strength = strength + fadeSpeed
            end
        else
            if strength >= fadeSpeed then
                strength = strength - fadeSpeed
                if strength <= 0 then
                    rendering = false
                    removeEventHandler( 'onClientPreRender', root, render )
                end
            end
        end
    else
        rendering = false
        removeEventHandler( 'onClientPreRender', root, render )
    end
end

addEvent( 'hud:blur', true )
addEventHandler( 'hud:blur', root, function( maxStrength_, forced_, fadeSpeed_, duration_ )
    if tonumber( maxStrength_ ) then
        if ( forced_ or not force ) then
            maxStrength = maxStrength_
            fadeSpeed = fadeSpeed_ or 0.1
            forced = forced_
            duration = duration_
            last = getTickCount()
            state = 'on'
            strength = 0
            if not rendering then
                addEventHandler( 'onClientPreRender', root, render )
            end
        end
    elseif maxStrength_ == 'off' then
        if ( forced_ or not force ) and rendering then
            state = 'off'
            forced = false
        end
    end
end )

