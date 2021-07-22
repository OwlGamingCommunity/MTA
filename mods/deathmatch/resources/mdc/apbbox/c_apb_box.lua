--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local screenW, screenH = guiGetScreenSize()
local RectSizeX, RectSizeY, RectXOrigin, textPos = 0, 0, 0, 0

local drawlist = true
local APBRendering = false
local apblist = {}

function drawAPBList()
	APBRendering = true
	if getPedOccupiedVehicle ( localPlayer ) then
		if drawlist and #apblist > 0 and getElementData(localPlayer, "hide_hud") ~= "0" then
			dxDrawRectangle(RectXOrigin, (screenH-RectSizeY)-30, RectSizeX, RectSizeY, tocolor(0, 0, 0, 100))
			for i, apb in ipairs(apblist) do
				dxDrawText(apb, RectXOrigin+5, (textPos+(16*i)), RectSizeX, screenH, tocolor(255, 255, 255, 255), 1, "default")
			end
		end
	else
		destroyAPBList()
	end
end 

local function setupAPBList(theTable)
	RectSizeX = 600
	RectSizeY = #theTable * 16 + 10
	textPos = (screenH-RectSizeY)-40

	apblist = {}
	for _, apb in ipairs(theTable) do
		text = "� "

		-- do we have a player name given?
		if #tostring(apb[1]) > 0 then
			text = text .. apb[ 1 ]:gsub( "_", " " ) .. ": "
		end

		text = text .. apb[2]

		table.insert(apblist, text)
		RectSizeX = math.max(RectSizeX, dxGetTextWidth(text) + 10)
	end
	RectXOrigin = (screenW/2)-(RectSizeX/2)
end

function drawAPB(theTable)
	setupAPBList(theTable)
	if apblist and #apblist > 0 and getPedOccupiedVehicle ( localPlayer ) then
		if not APBRendering then
			addEventHandler("onClientRender", root, drawAPBList)
		end
	else
		-- if apb list is emptied out of a sudden for any reason. Disable the dxbox.
		if APBRendering then
			destroyAPBList()
		end 
	end
end
addEvent("drawAPB", true)
addEventHandler("drawAPB", resourceRoot, drawAPB)

function destroyAPBList()
	if APBRendering then
		apblist = nil
		APBRendering = false
		removeEventHandler("onClientRender", root, drawAPBList)
		triggerServerEvent( "RemovePlayerFromTableEvent", resourceRoot )
	end
end

function toggleDrawAPB()
	if (drawlist) then
		drawlist = false
	else
		drawlist = true
	end
end
addCommandHandler("apblist", toggleDrawAPB)
