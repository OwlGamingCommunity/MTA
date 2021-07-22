--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local sx,sy = guiGetScreenSize()
local loads = {}
local rendering = false
local rot = 0
local last_updated = getTickCount()
local time_out = 60000
local function render()
	rendering = true
	if getTickCount() - last_updated < time_out and exports.global:countTable( loads ) > 0 then
		if getElementData( localPlayer, 'loggedin' ) == 1 then
			local y = sy-51
			if isPedInVehicle(localPlayer) then
				y = sy - 325
			end
			rot = rot + 5
			if rot > 360 then rot = 0 end
			for index, load in pairs( loads ) do
				if load.cur < load.max then
					local text = index.."..."..""..load.cur.."/"..load.max.." ("..math.ceil( load.cur/load.max*100 ).."%)"
					local size = dxGetTextWidth( text ) + 45
					x = sx-size
					dxDrawRectangle( x,y,size,25,tocolor(0,0,0,100), true )
					dxDrawText( text, x+35,y+4,20,20,tocolor(255,255,255,255),1,"default","left","top",false,false,true )
					dxDrawImage( x+5,y+2,20,20,"images/loading.png", rot, 0, 0, nil, true )
					y = y - 26
				else
					loads[ index ] = nil
				end
			end    
	    end
	else
		removeEventHandler( 'onClientRender', root, render )
		rendering = false
	end
end

addEvent( 'hud:loading', true )
addEventHandler( 'hud:loading', root, function ( index, data ) 
	loads[ index ] = data
	last_updated = getTickCount()
	if not rendering then
		addEventHandler( 'onClientRender', root, render )
		rendering = true
	end
	
end )


