--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local myInteriorsToDraw = {}
local myDrawnInteriorBlips = {}
local refreshRate = 5 -- minutes
function getAllMyInteriors()
	clearMyDrawnInteriorBlips()
	myInteriorsToDraw = {}
	for key, interior in ipairs(getElementsByType("interior")) do
		if isElement(interior) then
			local status = getElementData(interior, "status")
			if status and status.owner == getElementData(localPlayer, "dbid") then
				local entrance = getElementData(interior, "entrance")
				if entrance.int == 0 and entrance.dim == 0 then
					table.insert( myInteriorsToDraw, { entrance.x, entrance.y, entrance.z, status.type } )
				else
					locateMyParentInteriorInWorldMap( interior, status.type )
				end
			end
		end
	end
end

function locateMyParentInteriorInWorldMap(theInterior, myInteriorType)
	if not isElement(theInterior) then
		return false
	end

	local entrance = getElementData(theInterior, "entrance")
	if entrance.int ~= 0 and entrance.dim ~= 0 then
		local nextInterior = getInteriorFromID( entrance.dim )
		if nextInterior and isElement(nextInterior) then
			locateMyParentInteriorInWorldMap(nextInterior, myInteriorType)
		else
			return false
		end
	else
		local status = getElementData(theInterior, "status")
		if status.owner == getElementData(localPlayer, "dbid") then
			table.insert( myInteriorsToDraw, { entrance.x, entrance.y, entrance.z, myInteriorType } )
		end
	end
end

function getInteriorFromID(intID)
	for key, interior in ipairs(getElementsByType("interior")) do
		if interior and isElement(interior) and getElementData(interior, "dbid") == tonumber(intID) then
			return interior
		end
	end
	return false
end

local timerDraw = nil
function drawAllMyInteriorBlips()
	local logged = getElementData(localPlayer, "loggedin")
	if not logged or logged == 0 then return false end
	if timerDraw and isElement(timerDraw) and isTimer(timerDraw) then
		killTimer(timerDraw)
		timerDraw = nil
	end
	timerDraw = setTimer(function ()
		getAllMyInteriors()
		for i, interior in pairs(myInteriorsToDraw) do
			local icon = nil

			if interior[4] == 1 then
				icon = 32
			else
				icon = 31
			end
			
			local blip = createBlip(interior[1], interior[2], interior[3], icon )
			if blip then
				table.insert(myDrawnInteriorBlips, blip)
				--outputDebugString("Interior blip drew.")
			end
		end
	end, 5000, 1)
end
addEvent("drawAllMyInteriorBlips", true)
addEventHandler("drawAllMyInteriorBlips", localPlayer, drawAllMyInteriorBlips)

function clearMyDrawnInteriorBlips()
	if #myDrawnInteriorBlips > 0 then
		for i, blip in pairs(myDrawnInteriorBlips) do
			if isElement(blip) then
				destroyElement(blip)
			end
		end
	end
end


function blipRefresher()
	drawAllMyInteriorBlips()
	setTimer(function()
		drawAllMyInteriorBlips()
	end, refreshRate*1000*60, 0)
end
addEventHandler("onClientResourceStart", resourceRoot, blipRefresher)