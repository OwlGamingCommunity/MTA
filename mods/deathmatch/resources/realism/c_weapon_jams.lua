--[[local jamcount = 0
local pJam = nil
local state = 0
local jammed = false

function playerFired(weapon, ammo, ammoInClip, x, y, z, element)
	if (weapon==30 or weapon==31) then
		local chance = math.random(1,300)
		if (chance==1) then
			jamcount = 0
			state = 0
			jammed = true
			
			if (isElement(pJam)) then
				destroyElement(pJam)
				pJam = nil
			end
			
			pJam = guiCreateProgressBar(0.425, 0.75, 0.2, 0.035, true)
			outputChatBox("Your weapon has jammed, Tap - and = in order to unjam your weapons.", 255, 0, 0)
			local slot = getPedWeaponSlot(getLocalPlayer())
			triggerServerEvent("togglefiring", getLocalPlayer(), false, true)
			bindKey("num_sub", "down", unjamWeapon)
			triggerServerEvent("jammed", getLocalPlayer())
		end
	end
end
addEventHandler("onClientPlayerWeaponFire", getLocalPlayer(), playerFired)

function unjamWeapon()
	if (state==0) then
		bindKey("num_add", "down", unjamWeapon)
		unbindKey("num_sub", "down", unjamWeapon)
		state = 1
	elseif (state==1) then
		bindKey("num_sub", "down", unjamWeapon)
		unbindKey("num_add", "down", unjamWeapon)
		state = 0
	end
	
	jamcount = jamcount + 5
	guiProgressBarSetProgress(pJam, jamcount)
	
	if (jamcount>=100) then
		jammed = false
		triggerServerEvent("notjammed", getLocalPlayer())
		destroyElement(pJam)
		pJam = nil
		triggerServerEvent("togglefiring", getLocalPlayer(), true)
		outputChatBox("Your weapon is now unjammed.", 0, 255, 0)
		unbindKey("num_sub", "down", unjamWeapon)
		unbindKey("num_add", "down", unjamWeapon)
	end
end

function weaponChangedJammed(prev, curr)
	if (curr==5) then
		if (jammed) then
			triggerServerEvent("jammed", getLocalPlayer())
			pJam = guiCreateProgressBar(0.425, 0.75, 0.2, 0.035, true)
			outputChatBox("Your weapon has jammed, Tap - and = in order to unjam your weapons.", 255, 0, 0)
			local slot = getPedWeaponSlot(getLocalPlayer())
			triggerServerEvent("togglefiring", getLocalPlayer(), false)
			bindKey("num_sub", "down", unjamWeapon)
		end
	elseif	(prev==5) then
		jamcount = 0
		state = 0
		
		if (pJam) then
			destroyElement(pJam)
		end
		
		triggerServerEvent("togglefiring", getLocalPlayer(), true)
		triggerServerEvent("notjammed", getLocalPlayer())
		unbindKey("num_sub", "down", unjamWeapon)
		unbindKey("num_add", "down", unjamWeapon)
	end
end
addEventHandler("onClientPlayerWeaponSwitch", getLocalPlayer(), weaponChangedJammed)]]