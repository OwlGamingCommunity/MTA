--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* Original author: Ren712
* ***********************************************************************************************************************
]]

flashLiTable = {flModel={}, shLight={}, shLiBul={}, shLiRay={}, isFlon={} ,isFLen={}, fLInID={} }
isLightOn = false
item_dbid = nil
---------------------------------------------------------------------------------------------------
-- editable variables
---------------------------------------------------------------------------------------------------

disableFLTex = false -- true=makes the flashlight body not visible (useful for alter attach)
autoEnableFL = false -- true=the player gets the flashlight without writing commands
gLightTheta = math.rad(10) -- (6)Theta is the inner cone angle
gLightPhi = math.rad(40) -- (18) Phi is the outer cone angle
gLightFalloff = 0.5 -- light intensity attenuation between the phi and theta areas
gAttenuation = 25 -- (25)light attenuation (max radius)
gWorldSelfShadow = false -- enables object self shadowing ( may be bugged for rotated objects on a custom map)
gLightColor = {0.9,0.9,0.7,1.5} -- rgba color of the projected light, light rays and the lightbulb
switch_key = 'l' -- define the key that switches the light effect
objID = 15060  -- the object we are going to replace (interior building shadow in this case)

theTikGap = 1 -- here you set how many seconds to wait after switching the flashlight on/off
flTimerUpdate = 500 -- the effect update time interval 

getLastTack = getTickCount ( )-(theTikGap*1000)
shTeNul = dxCreateShader ( "shaders/shader_null.fx",0,0,false )
scrWidth, scrHeight = guiGetScreenSize()
sx = scrWidth/2
sy = scrHeight/2
rendering = false


function renderLighting()
	rendering = true
	for index,this in pairs( exports.pool:getPoolElementsByType("player") ) do
		if this and isElement(this) and isHolding(this) and flashLiTable.shLight[this] then
			local x1, y1, z1 = getPedBonePosition ( this, 24 )
			local lx1, ly1, lz1 = getPedBonePosition ( this, 25 )
			--local lx1, ly1, lz1 = getWorldFromScreenPosition(sx, sy, 10)
			exports.dynamic_lighting:setLightDirection(flashLiTable.shLight[this],lx1-x1,ly1-y1,lz1-z1,false)
			exports.dynamic_lighting:setLightPosition(flashLiTable.shLight[this],x1,y1,z1)	
		end
	end
end


function createFlashlightModel(thisPed)
	if not flashLiTable.flModel[thisPed] then	
		flashLiTable.flModel[thisPed] = createObject(objID,0,0,0,0,0,0,true)
		if disableFLTex and shTeNul then
			engineApplyShaderToWorldTexture ( shTeNul, "flashlight_COLOR", flashLiTable.flModel[thisPed] )	
			engineApplyShaderToWorldTexture ( shTeNul, "flashlight_L", flashLiTable.flModel[thisPed] )	
		end
		setElementAlpha(flashLiTable.flModel[thisPed],254)
		exports.bone_attach:attachElementToBone(flashLiTable.flModel[thisPed],thisPed,12,0,0.015,0.1,0,0,0)
	end
end

function destroyFlashlightModel(thisPed)
	if flashLiTable.flModel[thisPed] then			
		exports.bone_attach:detachElementFromBone(flashLiTable.flModel[thisPed])
		if disableFLTex and shTeNul then
			engineRemoveShaderFromWorldTexture ( shTeNul, "*", flashLiTable.flModel[thisPed] )
		end
		destroyElement(flashLiTable.flModel[thisPed])
		flashLiTable.flModel[thisPed]=nil
	end
end

function flashLightSwitch(isON,thisPed)
	if isElementStreamedIn(thisPed) and flashLiTable.isFLen[thisPed] then 
		playSwitchSound(thisPed) 
	end

	if isON then
		flashLiTable.isFlon[thisPed]=true
	else
		flashLiTable.isFlon[thisPed]=false
	end
end

function checkNearByPlayers()
	for index,thisPed in ipairs ( exports.pool:getPoolElementsByType("player") ) do
		if thisPed and isElement(thisPed) and isElementStreamedIn(thisPed) then
			if isElementOnScreen(thisPed) then
				-- holding flashlight, create bone attach object.
				if flashLiTable.isFLen[thisPed] then
					createFlashlightModel(thisPed)
					-- turned on
					if flashLiTable.isFlon[thisPed] then
						createFlashLightShader(thisPed)
						if isDynamicLightingEnabled() then
							createWorldLight(thisPed)
						else
							destroyWorldLight(thisPed)
						end
					-- holding fl, but turned off, we remove everything except the attached object.
					else
						destroyWorldLight(thisPed)
						destroyFlashLightShader(thisPed) 
					end
				-- isn't holding flashlight, remove everything.
				else
					removeFlFromPlayer(thisPed)
				end
			end
		-- if streamed out, we remove everything.
		else
			removeFlFromPlayer(thisPed)
		end
	end
end

function getPlayerInteriorFromServer(thisPed,interiorID)
	if flashLiTable.flModel[thisPed] then
		flashLiTable.fLInID[thisPed]=interiorID
		if flashLiTable.flModel[thisPed] then setElementInterior ( flashLiTable.flModel[thisPed], flashLiTable.fLInID[thisPed]) end
	end
end

function flashLightEnable(isEN,thisPed)
	flashLiTable.isFLen[thisPed]=isEN
end
addEvent( "flashlight:enable", true )
addEventHandler( "flashlight:enable", resourceRoot, flashLightEnable)

function toggleLight( state )
	if state == switch_key then
		if (getTickCount ( ) - getLastTack < theTikGap*1000) then 
			return 
		end
		toggleLight( not isLightOn )
	else
		local batt = getBattery()
		if not state or batt > 0 then
			isLightOn = state
			triggerServerEvent("onSwitchLight",localPlayer ,isLightOn)
			triggerEvent( "switchFlashLight",resourceRoot,isLightOn)
			getLastTack = getTickCount ( )
			toggleBatteryDrainer( isLightOn )
		end
		exports.hud:sendBottomNotification(localPlayer, "Flashlight", ( isLightOn and "ON" or "OFF" )..". Battery: "..batt.."%", 255, 194, 14)
	end
end

function toggleFlashLight(state, dbid)
	if state == nil then
		if (getTickCount ( ) - getLastTack < theTikGap*1000) then 
			return 
		end
		toggleFlashLight( not isHolding(localPlayer), dbid )
	else
		if state then
			if not isHolding(localPlayer) then
				if getPedOccupiedVehicle ( localPlayer ) then
					playSoundFrontEnd(4)
					exports.hud:sendBottomNotification(localPlayer, "Flashlight", "You can not use flashlight inside vehicles.", 255, 194, 14)
				elseif getPedWeaponSlot ( localPlayer ) ~= 0 then
					playSoundFrontEnd(4)
					exports.hud:sendBottomNotification(localPlayer, "Flashlight", "Your hands are all busy and can't hold the flashlight at the moment.", 255, 194, 14)
				else
					triggerServerEvent("flashlight:enable",localPlayer ,true, exports.pool:getPoolElementsByType('player') )
					triggerServerEvent("onSwitchLight",localPlayer ,false)
					bindKey(switch_key,"down",toggleLight)
					exports.hud:sendBottomNotification(localPlayer, "Flashlight", "Press L to turn on.", 255, 194, 14)
				end
			end
		else
			if isHolding(localPlayer) then
				triggerServerEvent("onSwitchLight",localPlayer ,false)
				triggerServerEvent("flashlight:enable",localPlayer ,false, exports.pool:getPoolElementsByType('player') )
				unbindKey(switch_key,"down",toggleLight)
				--exports.hud:sendBottomNotification(localPlayer, "Flashlight", "OFF", 255, 194, 14)
			end
			toggleBatteryDrainer( state )
		end
	end
	isLightOn = false
	item_dbid = dbid
end

--setTimer(toggleFlashLight, 50, 1)

---------------------------------------------------------------------------------------------------
-- events
---------------------------------------------------------------------------------------------------
		
addEventHandler("onClientResourceStart", resourceRoot, function()
	engineImportTXD( engineLoadTXD( "objects/flashlight.txd" ), objID ) 
	engineReplaceModel ( engineLoadDFF( "objects/flashlight.dff", 0 ), objID,true)
	triggerServerEvent("onPlayerStartRes",localPlayer )
	exports.dynamic_lighting:setWorldNormalShading(false)
	if FLenTimer and isTimer(FLenTimer) then
		killTimer(FLenTimer)
	end
	FLenTimer = setTimer( checkNearByPlayers, flTimerUpdate, 0 )
end
)

addEventHandler("onClientResourceStop", resourceRoot, function()
	for index,this in ipairs( getElementsByType("player") ) do
		if flashLiTable.shLight[this] then
			destroyWorldLight(this)
		end
	end
	-- turn off local light and all its effects.
	toggleFlashLight(false)
end
)



addEvent( "flashOnPlayerSwitch", true )
addEvent( "flashOnPlayerInter", true)
addEventHandler( "flashOnPlayerSwitch", resourceRoot, flashLightSwitch)

addEventHandler( "flashOnPlayerInter", resourceRoot, getPlayerInteriorFromServer)

-- no guns while holding the flashlight.
function weaponSwitch ( prevSlot, newSlot )
	if isHolding(localPlayer) and newSlot ~= 0 then
		playSoundFrontEnd(4)
		exports.hud:sendBottomNotification(localPlayer, "Weapon", "You can not use weapons while holding a flashlight.", 255, 194, 14)
		cancelEvent()
	end
end
addEventHandler ( "onClientPlayerWeaponSwitch", localPlayer, weaponSwitch )

addEvent( 'flashlight:toggleFlashLight', true )
addEventHandler( 'flashlight:toggleFlashLight' , root, toggleFlashLight )

-- no flashlight in car.
addEventHandler("onClientVehicleEnter", root,
    function(thePlayer, seat)
    	if thePlayer == localPlayer then
    		toggleFlashLight(false)
    	end
    end
)

function toggleThisSystem( dataName )
	if dataName == getThisResource() or dataName == "dynamic_lighting" or dataName == "dynamic_lighting_nighttime_only" then
		local enabled_dynLight = false
		if getElementData(localPlayer, 'dynamic_lighting') == '0' or not exports.dynamic_lighting:isInNightTime() then
			if rendering then
				removeEventHandler("onClientPreRender", root, renderLighting )
				rendering = false
			end
			enabled_dynLight = false
		else
			if not rendering then
				addEventHandler( "onClientPreRender", root, renderLighting )
				rendering = true
			end
			enabled_dynLight = false
		end

		checkNearByPlayers()
	end
end
addEventHandler ( "onClientElementDataChange", localPlayer, toggleThisSystem )
addEventHandler( "onClientResourceStart", resourceRoot, toggleThisSystem )

function whenPlayerQuits(thisPed)
	removeFlFromPlayer(thisPed)  
end
addEvent( "flashOnPlayerQuit", true )
addEventHandler( "flashOnPlayerQuit", resourceRoot, whenPlayerQuits)

function clientElementDestroy()
	if getElementType(source) == 'player' then
		removeFlFromPlayer(source)
	end
end
addEventHandler("onClientElementStreamOut", root, clientElementDestroy)
addEventHandler( 'onClientElementDestroy', root, clientElementDestroy)

addEventHandler( 'account:character:select', root, function ()
	toggleFlashLight(false)
end)
