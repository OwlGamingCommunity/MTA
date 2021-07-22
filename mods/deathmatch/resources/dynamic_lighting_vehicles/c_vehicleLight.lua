--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* Original author: Ren712
* ***********************************************************************************************************************
]]

local vehLiTable = { left={},right={}, color ={}, vehType={} }

local gWorldSelfShadow = false -- enables object self shadowing ( may be bugged for rotated objects on a custom map)
local flTimerUpdate = 50 -- default 200, the effect update time interval
local light_states = {
	[1] = {
		gLightTheta = math.rad(8), -- Theta is the inner cone angle (6)
		gLightPhi = math.rad(30), -- Phi is the outer cone angle (18)
		gLightFalloff = 1,-- default 1.5 , light intensity attenuation between the phi and theta areas
		gLightAttenuation = 30, -- default 18. The light strength
		gDarkness = 350, -- default 255, must be at least 255, the higher, the darker it will be, 255 = brightest.
		lightMaxDistance = 500, -- default 40
	},
	[2] = {
		gLightTheta = math.rad(8), -- Theta is the inner cone angle (6)
		gLightPhi = math.rad(60), -- Phi is the outer cone angle (18)
		gLightFalloff = 1.5,-- default 1.5 , light intensity attenuation between the phi and theta areas
		gLightAttenuation = 80, -- default 18. The light strength
		gDarkness = 500, -- default 255, must be at least 255, the higher, the darker it will be, 255 = brightest.
		lightMaxDistance = 500, -- default 40
	}
}

local excludeVehicleId = {441,464,501,465,564,571,594,606,607,610,611,584,608,450,591}

local shTeNul = nil
local rendering = false

function getPositionFromElementOffset(element,offX,offY,offZ)
	local m = getElementMatrix ( element )  -- Get the matrix
	local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1]  -- Apply transform
	local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
	local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
	return x, y, z                               -- Return the transformed point
end

function renderVehicleLighting()
	--outputDebugString(#exports.pool:getPoolElementsByType('vehicle'))
	for dbid, this in pairs( exports.pool:getPoolElementsByType('vehicle') ) do
		if this and isElement(this) and isElementOnScreen(this) and ( vehLiTable.left[this] or vehLiTable.right[this] ) then
			local col = vehLiTable.color[this]
			local vehType = vehLiTable.vehType[this]
			local x1, y1, z1, x2, y2, z2, rx, ry, rz = nil
			rx, ry, rz = getElementRotation(this, "ZXY")
			rx = rx - 4
	
			if vehType == "Bike" then
				x1,y1,z1 = getPositionFromElementOffset(this,0,0.8,0.1) -- (left,front,above)			
			elseif vehType == "Train" then
				x1,y1,z1 = getPositionFromElementOffset(this,-0.7,5.0,-0.9) -- (left,front,above)
				x2,y2,z2 = getPositionFromElementOffset(this,0.7,5.0,-0.9) -- (left,front,above)
			else
				x1,y1,z1 = getPositionFromElementOffset(this,-0.7,0.8,-0.1) -- (left,front,above)
				x2,y2,z2 = getPositionFromElementOffset(this,0.7,0.8,-0.1) -- (left,front,above)
			end
		
			if vehLiTable.left[this] then
				exports.dynamic_lighting:setLightDirection(vehLiTable.left[this],rx,ry,rz,true)
				exports.dynamic_lighting:setLightPosition(vehLiTable.left[this],x1,y1,z1)
				if col and type(col) == 'table' then
					exports.dynamic_lighting:setLightColor(vehLiTable.left[this],col[1],col[2],col[3],1) 
				end
			end
			if vehLiTable.right[this] and vehType~="Bike" then
				exports.dynamic_lighting:setLightDirection(vehLiTable.right[this],rx,ry,rz,true)
				exports.dynamic_lighting:setLightPosition(vehLiTable.right[this],x2,y2,z2)
				if col and type(col) == 'table' then
					exports.dynamic_lighting:setLightColor(vehLiTable.right[this],col[1],col[2],col[3],1)  
				end
			end
		end
	end
end

function createWorldLight(veh)
	local state = getElementData(veh, 'lights') or 0
	if state > 0 then
		return exports.dynamic_lighting:createSpotLight(0,0,3,0,0,0,0,0,0,0,true,
		light_states[state].gLightFalloff,
		light_states[state].gLightTheta,
		light_states[state].gLightPhi,
		light_states[state].gLightAttenuation,
		gWorldSelfShadow)
	end
end

function destroyWorldLight(this)
	return exports.dynamic_lighting:destroyLight(this)
end

function lightEffectStop(thisVeh, side)
	if (not side or side == 'left') and vehLiTable.left[thisVeh] then
		destroyWorldLight(vehLiTable.left[thisVeh])
		vehLiTable.left[thisVeh] = nil
	end
	if (not side or side == 'right') and vehLiTable.right[thisVeh] then
		destroyWorldLight(vehLiTable.right[thisVeh])
		vehLiTable.right[thisVeh] = nil
	end
end

function lightEffectManage(thisVeh,vehType)
	local state = getElementData(thisVeh, 'lights') or 0
	if state == 0 then 
		lightEffectStop(thisVeh)
		return 
	end

	local posX,posY,posZ = getElementPosition(thisVeh)
	local camX,camY,camZ = getCameraMatrix()
	local camDist = getDistanceBetweenPoints3D ( posX,posY,posZ,camX,camY,camZ )
	local ispastDist = light_states[state~=0 and state or 1].lightMaxDistance < camDist
	
	if ispastDist then
		lightEffectStop(thisVeh)
		return
	else
		-- left 
		if getVehicleLightState ( thisVeh, 0 ) == 1 or getVehicleOverrideLights ( thisVeh ) ~= 2 then 
			lightEffectStop(thisVeh, 'left')
		elseif getVehicleOverrideLights ( thisVeh ) == 2 and not vehLiTable.left[thisVeh] then
			vehLiTable.left[thisVeh] = createWorldLight(thisVeh)
		end
		-- right , bikes only need one left light.
		if vehType ~= 'bike' then
			if getVehicleLightState ( thisVeh, 1 ) == 1 or getVehicleOverrideLights ( thisVeh ) ~= 2 then 
				lightEffectStop(thisVeh, 'right')
			elseif getVehicleOverrideLights ( thisVeh ) == 2 and not vehLiTable.right[thisVeh] then
				vehLiTable.right[thisVeh] = createWorldLight(thisVeh)
			end
		end
	end
	
	if vehLiTable.left[thisVeh] or vehLiTable.right[thisVeh] then
		local r,g,b = getVehicleHeadLightColor(thisVeh)
		local tone = light_states[state~=0 and new_state or 1].gDarkness
		vehLiTable.color[thisVeh] = {r/tone,g/tone,b/tone}
	end
end

function startVehicleLighting()
	-- create then apply shader.
	if not shTeNul or not isElement(shTeNul) then
		shTeNul = dxCreateShader ( "shaders/shader_null.fx",0,0,false )
		engineApplyShaderToWorldTexture(shTeNul, "headlight*" )
	end
	
	if FLenTimer and isTimer(FLenTimer) then
		killTimer(FLenTimer)
	end
	FLenTimer = setTimer( function()
		for dbid, thisVeh in pairs( exports.pool:getPoolElementsByType('vehicle') ) do
			if thisVeh and isElement(thisVeh) then
				if exports.dynamic_lighting:isInNightTime() and not isVehicleBlown(thisVeh) then
					local vehType = getVehicleType(thisVeh)
					local vehID = getElementModel(thisVeh)
					local isMatch = true
					for index,name in ipairs(excludeVehicleId) do
						if vehID==name then isMatch = false end
					end
					vehLiTable.vehType[thisVeh] = vehType
					if isMatch and ( vehType == "Automobile" or vehType == "Monster Truck" or vehType == "Bike" or vehType == "Train" ) then
						if isElementStreamedIn(thisVeh) then
							if isElementOnScreen(thisVeh) then
								lightEffectManage(thisVeh,vehType)
							end
						else
							lightEffectStop(thisVeh)
						end
					end
				else
					lightEffectStop(thisVeh)
				end
			end
		end
	end
	,flTimerUpdate,0 )
end

function stopVehicleLighting()
	-- remove applied shader
	if shTeNul and isElement(shTeNul) then
		engineRemoveShaderFromWorldTexture ( shTeNul, "headlight*" )
		destroyElement(shTeNul)
		shTeNul = nil
	end

	if FLenTimer and isTimer(FLenTimer) then
		killTimer(FLenTimer)
		FLenTimer = nil
	end

	for index,thisVeh in ipairs(getElementsByType("vehicle")) do
		lightEffectStop(thisVeh)
	end	
end
addEventHandler("onClientResourceStop", resourceRoot, stopVehicleLighting)

function clientElementDestroy()
	if getElementType(source) == "vehicle"  then
		lightEffectStop(source)
	end
end


function toggleThisSystem( dataName )
	if dataName == getThisResource() or dataName == "dynamic_lighting" then
		if getElementData(localPlayer, 'dynamic_lighting') == '0' then
			if rendering then
				removeEventHandler("onClientPreRender", root, renderVehicleLighting)
				stopVehicleLighting()
				removeEventHandler("onClientElementDestroy", root, clientElementDestroy)
				removeEventHandler("onClientElementStreamOut", root, clientElementDestroy)
				rendering = false
			end
		else
			if getElementData(localPlayer, 'dynamic_lighting_vehicles') == '0' then
				if rendering then
					removeEventHandler("onClientPreRender", root, renderVehicleLighting)
					stopVehicleLighting()
					removeEventHandler("onClientElementDestroy", root, clientElementDestroy)
					removeEventHandler("onClientElementStreamOut", root, clientElementDestroy)
					rendering = false
				end
			else
				if not rendering then
					addEventHandler("onClientPreRender", root, renderVehicleLighting)
					startVehicleLighting()
					addEventHandler("onClientElementDestroy", root, clientElementDestroy)
					addEventHandler("onClientElementStreamOut", root, clientElementDestroy)
					rendering = true
				end

				for _, veh in pairs( getElementsByType('vehicle') ) do
					lightEffectStop(veh)
					if isElementStreamedIn(veh) then
						exports.pool:allocateElement( veh , getElementData(veh, 'dbid'), true )
					end
				end
			end
		end
	end
end
addEventHandler ( "onClientElementDataChange", localPlayer, toggleThisSystem)
addEventHandler("onClientResourceStart", resourceRoot, toggleThisSystem)

-- headlight modes & sound effects
addEventHandler ( "onClientElementDataChange", root, function(dataName)
	if dataName == 'lights' and source and isElement(source) and getElementType(source) == 'vehicle' then
		local new_state = getElementData(source, 'lights') or 0
		-- play sound to driver and passengers
		if getPedOccupiedVehicle(localPlayer) == source then
			local sound = playSound(':resources/headlight_'..(new_state == 0 and 'up' or 'down')..'.mp3')
			setElementInterior( sound, getElementInterior(source) )
			setElementDimension( sound, getElementDimension(source) )
		end
		
		if new_state > 0 and vehLiTable then
			-- update left light
			if vehLiTable.left then
				for veh, light in pairs(vehLiTable.left) do
					if veh == source then
						destroyWorldLight( vehLiTable.left[source] )
						vehLiTable.left[source] = createWorldLight( source )
					end
				end
			end
			-- update right light
			if vehLiTable.right then
				for veh, light in pairs(vehLiTable.right) do
					if veh == source then
						destroyWorldLight( vehLiTable.right[source] )
						vehLiTable.right[source] = createWorldLight( source )
					end
				end
			end
			-- update darkness
			if vehLiTable.color then
				for veh, tone in pairs(vehLiTable.color) do
					if veh == source then
						local tone = light_states[new_state].gDarkness
						local r,g,b = getVehicleHeadLightColor(source)
						vehLiTable.color[source] = {r/tone,g/tone,b/tone}
					end
				end
			end
		end
	end
end)
