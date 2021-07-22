local anim = false
local localPlayer = getLocalPlayer()
local walkanims = { WALK_armed = true, WALK_civi = true, WALK_csaw = true, Walk_DoorPartial = true, WALK_drunk = true, WALK_fat = true, WALK_fatold = true, WALK_gang1 = true, WALK_gang2 = true, WALK_old = true, WALK_player = true, WALK_rocket = true, WALK_shuffle = true, Walk_Wuzi = true, woman_run = true, WOMAN_runbusy = true, WOMAN_runfatold = true, woman_runpanic = true, WOMAN_runsexy = true, WOMAN_walkbusy = true, WOMAN_walkfatold = true, WOMAN_walknorm = true, WOMAN_walkold = true, WOMAN_walkpro = true, WOMAN_walksexy = true, WOMAN_walkshop = true, run_1armed = true, run_armed = true, run_civi = true, run_csaw = true, run_fat = true, run_fatold = true, run_gang1 = true, run_old = true, run_player = true, run_rocket = true, Run_Wuzi = true }
local attachedRotation = false

function onRender()
	local forcedanimation = getElementData(localPlayer, "forcedanimation")

	if (getPedAnimation(localPlayer)) and not (forcedanimation==1) then
		local screenWidth, screenHeight = guiGetScreenSize()
		anim = true
		--[[local text = "Press Spacebar to Cancel " .. ( getElementData(localPlayer, "parachuting") and "Parachuting" or "Animation" )
		local width = getElementData(localPlayer, "parachuting") and 435 or 420
		dxDrawText(text, screenWidth-width, screenHeight-91, screenWidth, screenHeight, tocolor ( 0, 0, 0, 255 ), 1, "pricedown")
		dxDrawText(text, screenWidth-width-2, screenHeight-93, screenWidth-30, screenHeight, tocolor ( 255, 255, 255, 255 ), 1, "pricedown")]]

		-- turning while walking
		local block, style = getPedAnimation(localPlayer)
		if block == "ped" and walkanims[ style ] and not getKeyState("lalt") and not getKeyState("ralt") then
			local px, py, pz, lx, ly, lz = getCameraMatrix()
			setPedRotation( localPlayer, math.deg( math.atan2( ly - py, lx - px ) ) - 90 )
		end
	elseif not (getPedAnimation(localPlayer)) and (anim) then
		anim = false
		toggleAllControls(true, true, false)
	end

	local element = getElementAttachedTo(localPlayer)
	if element and getElementType( element ) == "vehicle" then
		if attachedRotation then
			local rx, ry, rz = getElementRotation( element )
			setPedRotation( localPlayer, rz + attachedRotation )
		else
			local rx, ry, rz = getElementRotation( element )
			attachedRotation = getPedRotation( localPlayer ) - rz
		end
	elseif attachedRotation then
		attachedRotation = false
	end
end
addEventHandler("onClientRender", root, onRender)

function stopAnimationFix()
	if not getPedAnimation( localPlayer ) then
		setPedAnimation (localPlayer)
		triggerServerEvent("stopAnimationFix2", getRootElement(), localPlayer)
		local forcedanimation = getElementData(localPlayer, "forcedanimation")
		if not (forcedanimation==1) then
			triggerServerEvent("unbindAnimationStopKey", localPlayer)
		end
	end
end
addEvent("stopAnimationFix", true)
addEventHandler( "stopAnimationFix", getRootElement(), stopAnimationFix )