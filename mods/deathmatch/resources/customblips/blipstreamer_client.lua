streamedBlips = {}
VISIBLE_BLIP_COUNT = 0
local DEFAULT_STREAM_DISTANCE = 500
local g_root = getRootElement()

function guiConvertToCustomBlip ( guiElem, x, y, fRadius )
	if streamedBlips[guiElem] then
		outputDebugString("guiConvertToCustomBlip - Already a custom blip",0)
		return
	end
	--Check for valid arguments first
	if ( not isElement(guiElem) ) or 
		string.find(getElementType(guiElem),"gui-") ~= 1 or 
		not tonumber(x) or
		not tonumber(y) then
			outputDebugString("guiConvertToCustomBlip - Bad argument",0)
			return false	
	end
	fRadius = tonumber(fRadius) or DEFAULT_STREAM_DISTANCE

	--If the stream status has been turned off and was previously turned on
	streamedBlips[guiElem] = streamedBlips[guiElem] or {}
	streamedBlips[guiElem].radius = fRadius
	streamedBlips[guiElem].x = x
	streamedBlips[guiElem].y = y
	streamedBlips[guiElem].visible = true
	
	local width,height = guiGetSize(guiElem,false)
	streamedBlips[guiElem].width = width
	streamedBlips[guiElem].height = height
	
	VISIBLE_BLIP_COUNT = VISIBLE_BLIP_COUNT + 1
	
	addEventHandler ( "onClientElementDestroy", guiElem,
		function()
			streamedBlips[source] = nil
			VISIBLE_BLIP_COUNT = VISIBLE_BLIP_COUNT - 1
			destroyWidget ( source )
		end,
	false )
	
	return guiElem
end

function createCustomBlip ( x, y, width, height, path, fRadius, pd, element, text )
	if 	not tonumber(x) or
		not tonumber(y) or
		not type(path) == "string" then
			outputDebugString("createCustomBlip - Bad argument",0)
			return false	
	end
	sourceResource = sourceResource or getThisResource()
	local resourceName = getResourceName(sourceResource)
	
	fRadius = fRadius or DEFAULT_STREAM_DISTANCE
	if not tonumber(fRadius) then
		outputDebugString("createCustomBlip - Bad argument",0)
		return false
	end
	local image = dxImage:create( ":"..resourceName.."/"..path, 0, 0, width, height, false, pd, element, text )

	streamedBlips[image] = streamedBlips[image] or {}
	streamedBlips[image].radius = fRadius
	streamedBlips[image].x = x
	streamedBlips[image].y = y
	streamedBlips[image].width = width
	streamedBlips[image].height = height
	streamedBlips[image].visible = true
	streamedBlips[image].pd = pd
	
	VISIBLE_BLIP_COUNT = VISIBLE_BLIP_COUNT + 1
	
	addEventHandler ( "onClientResourceStop", getResourceRootElement(sourceResource),
		function()
			streamedBlips[image] = nil
			VISIBLE_BLIP_COUNT = VISIBLE_BLIP_COUNT - 1
			destroyWidget ( image )
		end
	)
	
	return image.id
end

function getCustomBlipStreamRadius(blip)
	blip = convertToWidget ( blip )
	--Check for valid arguments first
	if not isWidget(blip) or not streamedBlips[blip] then
		outputDebugString("getCustomBlipStreamRadius - Bad 'custom blip' argument",0)
		return false	
	end
	return streamedBlips[blip].radius or false
end

function setCustomBlipStreamRadius(blip, fRadius)
	blip = convertToWidget ( blip )
	fRadius = tonumber(fRadius)
	--Check for valid arguments first
	if not isWidget(blip) or not streamedBlips[blip] or not fRadius then
		outputDebugString("setCustomBlipStreamRadius - Bad 'custom blip' argument",0)
		return false	
	end
	streamedBlips[blip].radius = fRadius
	return true
end

function getCustomBlipPosition(blip)
	blip = convertToWidget ( blip )
	--Check for valid arguments first
	if not isWidget(blip) or not streamedBlips[blip] then
		outputDebugString("getCustomBlipPosition - Bad 'custom blip' argument",0)
		return false	
	end
	return streamedBlips[blip].x,streamedBlips[blip].y
end

function setBlipImageColor(blip, r, g, b)
	blip = convertToWidget ( blip )
	r = tonumber(r)
	g = tonumber(g)
	b = tonumber(b)

	if not isWidget(blip) or not streamedBlips[blip] then
		outputDebugString("getCustomBlipStreamRadius - Bad 'custom blip' argument",0)
		return false	
	end

	setWidgetColor(blip, r, g, b)
	return true
end

function setCustomBlipPosition(blip, x,y)
	blip = convertToWidget ( blip )
	x = tonumber(x)
	y = tonumber(y)
	--Check for valid arguments first
	if not isWidget(blip) or not streamedBlips[blip] or not x or not y then
		outputDebugString("setCustomBlipPosition - Bad argument",0)
		return false	
	end
	streamedBlips[blip].x,streamedBlips[blip].y = x,y 
	return true
end

function setBlipText(blip, text)
	blip = convertToWidget ( blip )

	if not isWidget(blip) or not streamedBlips[blip] then
		outputDebugString("setBlipText - Bad 'custom blip' argument",0)
		return false	
	end

	setWidgetText(blip, text)
	return true
end

function setBlipText2(blip, text, lines)
	blip = convertToWidget ( blip )

	if not isWidget(blip) or not streamedBlips[blip] then
		outputDebugString("setBlipText - Bad 'custom blip' argument",0)
		return false	
	end

	setWidgetText2(blip, text, lines)
	return true
end

function setBlipPath(blip, path)
	blip = convertToWidget ( blip )

	if not isWidget(blip) or not streamedBlips[blip] then
		outputDebugString("setBlipPath - Bad 'custom blip' argument",0)
		return false	
	end

	setWidgetPath(blip, path)
	return true
end

function setBlipHideFromRadar(blip, state)
	blip = convertToWidget ( blip )

	if not isWidget(blip) or not streamedBlips[blip] then
		outputDebugString("setBlipPath - Bad 'custom blip' argument",0)
		return false	
	end

	setWidgetHideFromRadar(blip, state)
	return true
end

function setCustomBlipRadarScale(blip, scale)
	blip = convertToWidget ( blip )
	scale = tonumber(scale)
	--Check for valid arguments first
	if not isWidget(blip) or not streamedBlips[blip] then
		outputDebugString("setCustomBlipRadarScale - Bad argument",0)
		return false	
	end
	streamedBlips[blip].radarScale = scale or nil
	return true
end

function setCustomBlipAlpha(blip, alpha)
	blip = convertToWidget ( blip )
	alpha = tonumber(alpha)
	--Check for valid arguments first
	if not isWidget(blip) or not streamedBlips[blip] or not alpha then
		outputDebugString("setCustomBlipAlpha - Bad argument",0)
		return false	
	end
	setWidgetAlpha(blip,alpha)
	return true
end

function setCustomBlipRotation(blip, rot, offX, offY)
	blip = convertToWidget ( blip )
	rot = tonumber(rot) or 0
	offX = tonumber(offX) or 0
	offY = tonumber(offY) or 0

	if not isWidget(blip) or not streamedBlips[blip] then
		outputDebugString("setCustomBlipRotation - Bad 'custom blip' argument",0)
		return false	
	end

	setWidgetRotation(blip, rot, offX, offY)
	return true
end

function setCustomBlipVisible(blip,visible)
	blip = convertToWidget ( blip )
	visible = not not visible
	
	if not isWidget(blip) or not streamedBlips[blip] then
		outputDebugString("setCustomBlipVisible - Bad argument",0)
		return false
	end
	
	if visible == streamedBlips[blip].visible then return false end
	
	streamedBlips[blip].visible = visible
	
	if setWidgetVisible ( blip, visible ) then
		VISIBLE_BLIP_COUNT = visible and (VISIBLE_BLIP_COUNT + 1) or (VISIBLE_BLIP_COUNT - 1)
		return true
	end
	return false
end

function isCustomBlipVisible(blip)
	blip = convertToWidget ( blip )
	if not isWidget(blip) then
		outputDebugString("isCustomBlipVisible - Bad argument",0)
		return nil
	end
	return streamedBlips[blip].visible
end

function destroyCustomBlip(blip)
	blip = convertToWidget ( blip )
	if not isWidget(blip) or not streamedBlips[blip] then
		outputDebugString("destroyCustomBlip - Bad 'custom blip' argument",0)
		return false	
	end	
	streamedBlips[blip] = nil
	VISIBLE_BLIP_COUNT = VISIBLE_BLIP_COUNT - 1
	return destroyWidget ( blip )
end

addEventHandler("onClientRender",g_root,
	function()
		if VISIBLE_BLIP_COUNT == 0 then
			return
		end
		
		local cameraTarget = getCameraTarget()
		local radarRadius = getRadarRadius()
		local toF11Map = isPlayerMapVisible()
		local radarOpen = isPlayerHudComponentVisible("radar")
		local camX,camY,_,camTargetX,camTargetY = getCameraMatrix()
		local x,y,camRot,F11minX,F11minY,F11maxX,F11maxY,F11sizeX,F11sizeY
		
		--Are we in fixed camera mode?
		if not cameraTarget then
			x,y = camX,camY
		else
			x,y = getElementPosition(cameraTarget)
		end
	
		if not toF11Map then --Render to the radar
			--Are we in fixed camera mode?
			if not cameraTarget then
				camRot = getVectorRotation(camX,camY,camTargetX,camTargetY)
			else
				local vehicle = getPedOccupiedVehicle(localPlayer)
				if ( vehicle ) then
					--Look back works on all vehicles
					if getPedControlState(localPlayer, "vehicle_look_behind") or
					( getPedControlState(localPlayer, "vehicle_look_left") and getPedControlState(localPlayer, "vehicle_look_right") ) or
					--Look left/right on any vehicle except planes and helis (these rotate them)
					( getVehicleType(vehicle)~="Plane" and getVehicleType(vehicle)~="Helicopter" and 
					( getPedControlState(localPlayer, "vehicle_look_left") or getPedControlState(localPlayer, "vehicle_look_right") ) ) then
						camRot = -math.rad(getPedRotation(localPlayer))
					else
						camRot = getVectorRotation(camX,camY,camTargetX,camTargetY)
					end
				elseif getPedControlState(localPlayer, "look_behind") then
					camRot = -math.rad(getPedRotation(localPlayer))
				else
					camRot = getVectorRotation(camX,camY,camTargetX,camTargetY)
				end
			end
		else
			F11minX,F11minY,F11maxX,F11maxY = getPlayerMapBoundingBox()
			F11sizeX = F11maxX - F11minX
			F11sizeY = F11maxY - F11minY
			--
			F11sizeX = F11sizeX/6000
			F11sizeY = F11sizeY/6000
		end
		for blip,infoTable in pairs(streamedBlips) do
			if isWidget(blip) then
				if streamedBlips[blip].visible  then
					local bx,by = infoTable.x,infoTable.y
					--outputChatBox ( tostring(getDistanceBetweenPoints2D ( x,y,bx,by )-getRadarRadius()).." "..tostring(infoTable.radius))
					if 	( toF11Map ) then
						if not isMTAWindowActive() then
							setWidgetVisible(blip,true)
							renderBlip(blip,toF11Map,x,y,camRot,radarRadius,F11minX,F11minY,F11maxX,F11maxY,F11sizeX,F11sizeY)
						else
							setWidgetVisible(blip,false)
						end
					elseif	(	not infoTable.radius	) or
							(( 	getDistanceBetweenPoints2D ( x,y,bx,by )-radarRadius ) < infoTable.radius ) and radarOpen then
						setWidgetVisible(blip,true)
						renderBlip(blip,toF11Map,x,y,camRot,radarRadius,F11minX,F11minY,F11maxX,F11maxY,F11sizeX,F11sizeY)
					else
						setWidgetVisible(blip,false)
					end
				end
			else
				streamedBlips[blip] = nil
				VISIBLE_BLIP_COUNT = VISIBLE_BLIP_COUNT - 1
			end
		end
	end
)

