--
-- c_snow_ground.lua
--

--[[
local helpMessage = "F7 to turn off ground snow"
local helpMessageTime = 4000
local helpMessageY = 0.2]]

local bEffectEnabled
local noiseTexture
local snowShader
local treeShader
local naughtyTreeShader

----------------------------------------------------------------
----------------------------------------------------------------
-- Effect switching on and off
----------------------------------------------------------------
----------------------------------------------------------------

--------------------------------
-- onClientResourceStart
--		Auto switch on at start
--------------------------------
addEventHandler( "onClientResourceStart", resourceRoot,
	function()
		triggerEvent( "switchGoundSnow", resourceRoot, true )
	end
)

--------------------------------
-- Command handler
--		Toggle via command
--------------------------------
function toggleGoundSnow()
	triggerEvent( "switchGoundSnow", resourceRoot, not bEffectEnabled )
end
addCommandHandler('groundsnow',toggleGoundSnow)
--addCommandHandler('Toggle ground snow',toggleGoundSnow)
--bindKey("F7","down","Toggle ground snow")


--------------------------------
-- Switch effect on or off
--------------------------------
local checkInteriorAgainTimer
function switchGoundSnow( bOn )
	--outputDebugString("switchGoundSnow("..tostring(bOn)..")")
	if checkInteriorAgainTimer then
		if isTimer(checkInteriorAgainTimer) then
			killTimer(checkInteriorAgainTimer)
		end
		checkInteriorAgainTimer = nil
	end
	if bOn then
		local userSetting = getElementData(localPlayer, "groundsnow")
		if not userSetting or userSetting ~= "0" then
			local interior = getElementInterior(localPlayer)
			if interior == 0 then
				enableGoundSnow()
			else
				--outputDebugString("bypass: interior")
				checkInteriorAgainTimer = setTimer(checkInteriorAgain, 5000, 1)
			end
		else
			--outputDebugString("bypass: setting")
		end
	else
		disableGoundSnow()
	end
end
addEvent( "switchGoundSnow", true )
addEventHandler( "switchGoundSnow", getRootElement(), switchGoundSnow )

function checkInteriorAgain()
	local interior = getElementInterior(localPlayer)
	if interior == 0 then
		local userSetting = getElementData(localPlayer, "groundsnow")
		if not userSetting or userSetting ~= "0" then
			enableGoundSnow()
		else
			--outputDebugString("bypass: setting")
		end
	else
		--outputDebugString("bypass: interior")
	end
	if isTimer(checkInteriorAgainTimer) then
		killTimer(checkInteriorAgainTimer)
	end
	checkInteriorAgainTimer = nil
end

----------------------------------------------------------------
----------------------------------------------------------------
-- Effect clever stuff
----------------------------------------------------------------
----------------------------------------------------------------
local maxEffectDistance = 250		-- To speed up the shader, don't use it for objects further away than this

-- List of world texture name matches
-- (The ones later in the list will take priority) 
local snowApplyList = {
						"*",				-- Everything!
				}

-- List of world textures to exclude from this effect
local snowRemoveList = {
						"",	"unnamed",									-- unnamed

						"vehicle*", "?emap*", "?hite*",					-- vehicles
						"*92*", "*wheel*", "*interior*",				-- vehicles
						"*handle*", "*body*", "*decal*",				-- vehicles
						"*8bit*", "*logos*", "*badge*",					-- vehicles
						"*plate*", "*sign*",							-- vehicles
						"headlight", "headlight1",						-- vehicles

						"shad*",										-- shadows
						"coronastar",									-- coronas
						"tx*",											-- grass effect
						"lod*",											-- lod models
						"cj_w_grad",									-- checkpoint texture
						"*cloud*",										-- clouds
						"*smoke*",										-- smoke
						"sphere_cj",									-- nitro heat haze mask
						"particle*",									-- particle skid and maybe others
						"*water*", "sw_sand", "coral",					-- sea
						"radardisc", "radar*",
						"blugrad32", "greengrad32", "lyellow32", "redgrad32", "skull", --pickups
					}

local treeApplyList = {
						"sm_des_bush*", "*tree*", "*ivy*", "*pine*",	-- trees and shrubs
						"veg_*", "*largefur*", "hazelbr*", "weeelm",
						"*branch*", "cypress*",
						"*bark*", "gen_log", "trunk5",
						"bchamae", "vegaspalm01_128",

	}

local naughtyTreeApplyList = {
						"planta256", "sm_josh_leaf", "kbtree4_test", "trunk3",					-- naughty trees and shrubs
						"newtreeleaves128", "ashbrnch", "pinelo128", "tree19mi",
						"lod_largefurs07", "veg_largefurs05","veg_largefurs06",
						"fuzzyplant256", "foliage256", "cypress1", "cypress2",
	}

--------------------------------
-- Switch effect on
--------------------------------
function enableGoundSnow()
	if bEffectEnabled then return end
	-- Version check
	if getVersion ().sortable < "1.1.1-9.03285" then
		outputChatBox( "Resource is not compatible with this client." )
		return
	end

	snowShader = dxCreateShader ( "snow_ground.fx", 0, maxEffectDistance )
	treeShader = dxCreateShader( "snow_trees.fx" )
	naughtyTreeShader = dxCreateShader( "snow_naughty_trees.fx" )
	sNoiseTexture = dxCreateTexture( "smallnoise3d.dds" )

	if not snowShader or not treeShader or not naughtyTreeShader or not sNoiseTexture then
		--outputChatBox( "Could not create shader. Please use debugscript 3" )
		return nil
	end

	-- Setup shaders
	dxSetShaderValue( treeShader, "sNoiseTexture", sNoiseTexture )
	dxSetShaderValue( naughtyTreeShader, "sNoiseTexture", sNoiseTexture )
	dxSetShaderValue( snowShader, "sNoiseTexture", sNoiseTexture )
	dxSetShaderValue( snowShader, "sFadeEnd", maxEffectDistance )
	dxSetShaderValue( snowShader, "sFadeStart", maxEffectDistance/2 )

	-- Process snow apply list
	for _,applyMatch in ipairs(snowApplyList) do
		engineApplyShaderToWorldTexture ( snowShader, applyMatch )
	end

	-- Process snow remove list
	for _,removeMatch in ipairs(snowRemoveList) do
		engineRemoveShaderFromWorldTexture ( snowShader, removeMatch )
	end

	-- Process tree apply list
	for _,applyMatch in ipairs(treeApplyList) do
		engineApplyShaderToWorldTexture ( treeShader, applyMatch )
	end

	-- Process naughty tree apply list
	for _,applyMatch in ipairs(naughtyTreeApplyList) do
		engineApplyShaderToWorldTexture ( naughtyTreeShader, applyMatch )
	end

	-- Init vehicle checker
	doneVehTexRemove = {}
	vehTimer = setTimer( checkCurrentVehicle, 100, 0 )
	removeVehTextures()

	-- Flag effect as running
	bEffectEnabled = true

	--showHelp()
end

--------------------------------
-- Switch effect off
--------------------------------
function disableGoundSnow()
	if not bEffectEnabled then return end

	-- Destroy all elements
	destroyElement( sNoiseTexture  )
	destroyElement( treeShader )
	destroyElement( naughtyTreeShader )
	destroyElement( snowShader )

	killTimer( vehTimer )

	-- Flag effect as stopped
	bEffectEnabled = false
end


----------------------------------------------------------------
-- removeVehTextures
--		Keep effect off vehicles
----------------------------------------------------------------
local nextCheckTime = 0
local bHasFastRemove = getVersion().sortable > "1.1.1-9.03285"

addEventHandler( "onClientPlayerVehicleEnter", root,
	function()
		removeVehTexturesSoon ()
	end
)

-- Called every 100ms
function checkCurrentVehicle ()
	local veh = getPedOccupiedVehicle(localPlayer)
	local id = veh and getElementModel(veh)
	if lastveh ~= veh or lastid ~= id then
		lastveh = veh
		lastid = id
		removeVehTexturesSoon()
	end
	if nextCheckTime < getTickCount() then
		nextCheckTime = getTickCount() + 5000
		removeVehTextures()
	end
end

-- Called the players current vehicle need processing
function removeVehTexturesSoon ()
	nextCheckTime = getTickCount() + 200
end

-- Remove textures from players vehicle from effect
function removeVehTextures ()
	if not bHasFastRemove then return end

	local veh = getPedOccupiedVehicle(localPlayer)
	if veh then
		local id = getElementModel(veh)
		local vis = engineGetVisibleTextureNames("*",id)
		-- For each texture
		if vis then	
			for _,removeMatch in pairs(vis) do
				-- Remove for each shader
				if not doneVehTexRemove[removeMatch] then
					doneVehTexRemove[removeMatch] = true
					engineRemoveShaderFromWorldTexture ( snowShader, removeMatch )
				end
			end
		end
	end
end


----------------------------------------------------------------
-- Help message
----------------------------------------------------------------
--[[
function showHelp()
	if bShowHelp ~= nil then return end
	bShowHelp = true
	helpStartTime = getTickCount()
	setTimer( function() bShowHelp=false end, helpMessageTime, 1 )
end

addEventHandler( "onClientRender", root,
	function ()
		if bShowHelp then
			local age = getTickCount() - helpStartTime
			if ( age > helpMessageTime - 256 ) then
				age = helpMessageTime - age
			end
			age = math.min(math.max(0,age),255)
			local sx, sy = guiGetScreenSize()
			dxDrawText(helpMessage, sx/2-3, sy*helpMessageY, sx/2+2, 0, tocolor(0, 0, 0, age), 3, 'default', 'center' )
			dxDrawText(helpMessage, sx/2+3, sy*helpMessageY, sx/2+2, 0, tocolor(0, 0, 0, age), 3, 'default', 'center' )
			dxDrawText(helpMessage, sx/2, sy*helpMessageY, sx/2, 0, tocolor(255, 255, 0, age), 3, 'default', 'center' )
		end
	end
)
]]

----------------------------------------------------------------
-- Unhealthy hacks
----------------------------------------------------------------
_dxCreateShader = dxCreateShader
function dxCreateShader( filepath, priority, maxDistance, bDebug )
	priority = priority or 0
	maxDistance = maxDistance or 0
	bDebug = bDebug or false

	-- Slight hack - maxEffectDistance doesn't work properly before build 3236 if fullscreen
	local build = getVersion ().sortable:sub(9)
	local fullscreen = not dxGetStatus ().SettingWindowed
	if build < "03236" and fullscreen then
		maxDistance = 0
	end

	return _dxCreateShader ( filepath, priority, maxDistance, bDebug )
end

----------------------------------------------------------------
-- SLIPPERY ROADS / SNOW TIRES
----------------------------------------------------------------
local snowTireID = 212

function applySlippery(vehicle, hasSnowTire)
	local thisVehicle = getPedOccupiedVehicle(localPlayer)
	if(vehicle ~= thisVehicle) then return end
	if not hasSnowTire then
		local model = getElementModel(vehicle)
		if model == 598 or model == 596 or model == 597 or model == 599 or model == 490 then -- Police cars
			setGravity ( 0.0070 )
		elseif model == 554 or model == 572 or model == 579 or model == 400 or model == 404 or model == 489 or model == 505 or model == 470 then
			setGravity ( 0.0050 )
		elseif model == 429 or model == 541 or model == 415 or model == 480 or model == 562 or model == 565 or model == 434 or model == 494 or model == 502 or model == 503 or model == 401 or model == 559 or model == 561 or model == 560 or model == 506 or model == 451 or model == 558 or model == 555 or model == 477 then
			setGravity ( 0.004 )
		else
			setGravity ( 0.0045 )
		end
	end
	
	local vType = getVehicleType(vehicle) 
	local editingMode = getElementData(vehicle, "isTestDriveCar")
	local jobVeh = getElementData(vehicle, "job") or 0 
	
	if hasSnowTire or vType == "Plane" or vType == "Helicopter" or vType == "Boat" or vType == "Train" or editingMode or jobVeh > 0 then
		setGravity( 0.008 )
	end
end
addEvent("shader_snow_ground:applySlippery", true)
addEventHandler("shader_snow_ground:applySlippery", root, applySlippery)

addEventHandler("OnClientVehicleExit", getRootElement(),
	function(thePlayer, seat)
		if thePlayer == getLocalPlayer() then
			setGravity ( 0.008 )
		end
	end
)
function resetGravity()
	if not getPedOccupiedVehicle(getLocalPlayer()) then --or exports.global:hasItem(getPedOccupiedVehicle(localPlayer), snowTireID) then
		setGravity( 0.008 )
	end
end
setTimer(resetGravity, 4000, 0)

function resetGravityOnResourceStop(res)
	setGravity( 0.008 )
end
addEventHandler("onClientResourceStop", resourceRoot, resetGravityOnResourceStop)