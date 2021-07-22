--This script estimates the size of the radar, based upon some simple calculations
local MIN_VELOCITY = 0.3
local MIN_DISTANCE = 180

local MAX_VELOCITY = 1
local MAX_DISTANCE = 350
--
local localPlayer = getLocalPlayer()
local ratio
do
	local velocityDiff = MAX_VELOCITY - MIN_VELOCITY
	local distanceDiff = MAX_DISTANCE - MIN_DISTANCE
	ratio = distanceDiff/velocityDiff
end


function getRadarRadius ()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if not vehicle then --The radar does not resize when on foot
		return MIN_DISTANCE
	else
		if getVehicleType(vehicle) == "Plane" then
			return MAX_DISTANCE
		end
		local speed = ( getDistanceBetweenPoints3D(0,0,0,getElementVelocity(vehicle)) )
		if speed <= MIN_VELOCITY then
			return MIN_DISTANCE
		elseif speed >= MAX_VELOCITY then
			return MAX_DISTANCE
		end
		--Otherwise we're somewhere in between
		local streamDistance = speed - MIN_VELOCITY --Since MIN_DISTANCE is the lower bound, remove it
		streamDistance = streamDistance * ratio
		streamDistance = streamDistance + MIN_DISTANCE
		return math.ceil(streamDistance)
	end
end


--Simple RotZ calc (Only need RotZ since we're in 2D)
function getVectorRotation (px, py, lx, ly )
	local rotz = 6.2831853071796 - math.atan2 ( ( lx - px ), ( ly - py ) ) % 6.2831853071796
 	return -rotz
end


--GUI/DX merging funcs

function destroyWidget ( widget )
	if isElement(widget) then
		return destroyElement ( widget )
	elseif type(widget) == "table" and widget.destroy then
		return widget:destroy()
	end
end

function isWidget ( widget )
	if isElement(widget) and string.find(getElementType(widget),"gui-") == 1 then
		return true
	elseif type(widget) == "table" and widget.fX then
		return true
	end
	return false
end

function convertToWidget ( widget ) --Converts metatableless images to classes (lost in transition between resources)
	if isElement(widget) and string.find(getElementType(widget),"gui-") == 1 then
		return widget
	elseif type(widget) == "number" then
		return dxImage:getByID ( widget )
	end
	return false	
end

function getWidgetPosition ( widget )
	if isElement(widget) then
		return guiGetPosition ( widget, false )
	elseif type(widget) == "table" and widget.position then
		return widget:position()
	end
end

function setWidgetPosition ( widget, x, y )
	if isElement(widget) then
		return guiSetPosition ( widget, x, y, false )
	elseif type(widget) == "table" and widget.position then
		return widget:position(x,y,false)
	end
end

function getWidgetSize ( widget )
	if isElement(widget) then
		return guiGetSize ( widget, false )
	elseif type(widget) == "table" and widget.size then
		return widget:size()
	end
end

function setWidgetSize ( widget, w, h )
	if isElement(widget) then
		return guiSetSize ( widget, w, h, false )
	elseif type(widget) == "table" and widget.size then
		return widget:size(w,h,false)
	end
end

function setWidgetVisible ( widget, bVisible )
	if isElement(widget) then
		return guiSetVisible ( widget, bVisible )
	elseif type(widget) == "table" and widget.visible then
		return widget:visible(bVisible)
	end
end

function setWidgetAlpha ( widget, alpha )
	if isElement(widget) then
		return guiSetAlpha ( widget, alpha )
	elseif type(widget) == "table" and widget.color then
		local r,g,b = widget:color()
		return widget:color(r,g,b,alpha*255)
	end
end

function getWidgetAlpha ( widget )
	if isElement(widget) then
		return guiGetAlpha ( widget )
	elseif type(widget) == "table" and widget.tColor then
		return widget.tColor[4]/255
	end
end

function setWidgetColor ( widget, r, g, b ) -- Image ONLY
	if type(widget) == "table" and widget.color then
		return widget:color(r,g,b,255)
	end
end

function getWidgetColor ( widget ) -- Image ONLY
	if type(widget) == "table" and widget.tColor then
		return widget.tColor[1], widget.tColor[2], widget.tColor[3]
	end
end

function setWidgetRotation ( widget, rot, offX, offY ) -- Image ONLY
	if type(widget) == "table" and widget.fRot then
		return widget:rotation(rot,offX,offY)
	end
end

function getWidgetRotation ( widget ) -- Image ONLY
	if type(widget) == "table" and widget.fRot then
		return widget.fRot, widget.fRotXOff, widget.fRotYOff
	end
end