--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

local localPlayer = getLocalPlayer()
local iMap = nil
local helpLabel = nil
local vehicle = nil
local seat = nil

function displayGPS()
	vehicle = source
	if (iMap) then
		hideGUI()
	else
		showGUI()
	end
end
addEvent("displayGPS", true)
addEventHandler("displayGPS", getRootElement(), displayGPS)

function hideGUI()
	showCursor(false)
	
	if (isElement(iMap)) then
		destroyElement(iMap)
	end
	iMap = nil
	
	if (isElement(helpLabel)) then
		destroyElement(helpLabel)
	end
	helpLabel = nil
	
	vehicle = nil
	
	call(getResourceFromName("realism"), "showSpeedo")
end

function onVehicleEnter(player, nseat)
	if (player==localPlayer) then
		vehicle = source
		seat = nseat
	end
end
addEventHandler("onClientVehicleEnter", getRootElement(), onVehicleEnter)

function showGUI()
	resetRoute()
	
	local width, height = 700, 700
	local scrWidth, scrHeight = guiGetScreenSize()
	local x = scrWidth/2 - (width/2)
	local y = scrHeight/2 - (height/2)

	iMap = guiCreateStaticImage(x, y, width, height, "map.jpg", false) -- Map
	
	local height = 50
	local y = scrHeight - (height/1.5)
	helpLabel = guiCreateLabel(x, y, width, height, "Left click to set GPS Target - Right click to disable GPS", false)
	guiLabelSetHorizontalAlign(helpLabel, "center")
	guiSetFont(helpLabel, "default-bold-small")
	
	call(getResourceFromName("realism"), "hideSpeedo")
	
	addEventHandler("onClientGUIClick", iMap, calculateRouteOnClick, false)
	showCursor(true)
end

function resetRoute()
	triggerEvent("drawGPS", localPlayer, nil, nil, nil, nil, nil)
end


function resetRouteOnExit(player)
	if (player==localPlayer) then
		resetRoute()
		hideGUI()
	end
end
addEventHandler("onClientVehicleExit", getRootElement(), resetRouteOnExit)

function calculateRouteOnClick(button, state, absx, absy)
	if (button=="left")  then
		tx, ty, tz = convert2DMapCoordToWorld(absx, absy)
		
		local x, y, z = getElementPosition(localPlayer)
		local route = calculatePathByCoords(tx, ty, tz, x, y, z)
		if route then
			triggerEvent("drawGPS", localPlayer, route, tx, ty, tz, vehicle)
		end
		
		hideGUI()
	else
		resetRoute()
		hideGUI()
	end
end

function convert2DMapCoordToWorld(relX, relY)
	local scrWidth, scrHeight = guiGetScreenSize()
	local relX, relY, wx, wy, wz = getCursorPosition()

	local ax, ay = guiGetPosition( iMap, true )
	local bx, by = guiGetSize( iMap, true )
	local cx, cy = getCursorPosition()
	cxr = ( cx - ax ) / bx
	cyr = ( cy - ay ) / by
	
	local x = cxr*6000 - 3000
	local y = 3000 - cyr*6000
	
	local z = getGroundPosition(x, y, 1500)
	return x, y, z
end