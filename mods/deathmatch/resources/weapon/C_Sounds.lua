setWorldSoundEnabled( 42, false )
setWorldSoundEnabled( 5, false )
setWorldSoundEnabled( 5, 87, true ) -- Fix punching sound
setWorldSoundEnabled( 5, 58, true ) -- Fix punching sound
setWorldSoundEnabled( 5, 37, true ) -- Fix punching sound

local function playGunfireSound(weaponID)
    local muzzleX, muzzleY, muzzleZ = getPedWeaponMuzzlePosition(source)
    local px, py, pz = getElementPosition ( source )
	local dim = getElementDimension(source)
	local int = getElementDimension(source)
	
	--[[ PAINTBALL
	if getElementData(localPlayer, "paintball") == 2 then
		local sound = playSound3D(":event-system/paintball/paintball.mp3", muzzleX, muzzleY, muzzleZ, false)
		if weaponID == 31 then
			setSoundMaxDistance(sound, 170)
		elseif weaponID == 25 or weaponID == 24 or weaponID == 29 then
			setSoundMaxDistance(sound, 120)
		elseif weaponID == 34 then
			setSoundMaxDistance(sound, 325)
		end
		setElementDimension(sound, dim)
		setSoundVolume(sound, 1)
		
		return
	end
	--]]

	if weaponID == 22 then --colt45
		local sound = playSound3D("sounds/weap/Colt45.wav", muzzleX, muzzleY, muzzleZ, false)
		setSoundMaxDistance(sound, 95)
		setElementDimension(sound, dim)
		setSoundVolume(sound, 0.3)
	elseif weaponID == 23 then
		local sound = playSound3D("sounds/weap/Silenced.wav", muzzleX, muzzleY, muzzleZ, false)
		setSoundMaxDistance(sound, 15)
		setElementDimension(sound, dim)
		setSoundVolume(sound, 0.3)
	elseif weaponID == 24 then--deagle
		local sound = nil 
		local mode = getElementData(source, "deaglemode")
		if mode == 0 then
			sound = playSound3D("sounds/weap/Tazer.wav", muzzleX, muzzleY, muzzleZ, false)
		else
			sound = playSound3D("sounds/weap/Deagle.wav", muzzleX, muzzleY, muzzleZ, false)
			setSoundVolume(sound, 0.3)
		end
		setSoundMaxDistance(sound, 120)
		setElementDimension(sound, dim)
		setSoundVolume(sound, 0.3)
	elseif weaponID == 25 then--shotgun
		local sound = nil
		local mode = getElementData(source, "shotgunmode")
		if mode == 0 then
			sound = playSound3D("sounds/weap/beanbag.wav", muzzleX, muzzleY, muzzleZ, false)
		else
			sound = playSound3D("sounds/weap/Shotgun.wav", muzzleX, muzzleY, muzzleZ, false)
			setSoundVolume(sound, 0.3)
		end
		setSoundMaxDistance(sound, 120)
		setElementDimension(sound, dim)
	elseif weaponID == 26 then--sawn-off
		local sound = playSound3D("sounds/weap/Sawed-Off.wav", muzzleX, muzzleY, muzzleZ, false)
		setSoundMaxDistance(sound, 95)
		setElementDimension(sound, dim)
		setSoundVolume(sound, 0.3)
	elseif weaponID == 27 then--combat shotgun
		local sound = playSound3D("sounds/weap/Combat Shotgun.wav", muzzleX, muzzleY, muzzleZ, false)
		setSoundMaxDistance(sound, 100)
		setElementDimension(sound, dim)
		setSoundVolume(sound, 0.3)
	elseif weaponID == 28 then--uzi
		local sound = playSound3D("sounds/weap/UZI.wav", muzzleX, muzzleY, muzzleZ, false)
		setSoundMaxDistance(sound, 105)
		setElementDimension(sound, dim)
		setSoundVolume(sound, 0.3)
	elseif weaponID == 32 then--tec-9
		local sound = playSound3D("sounds/weap/tec9.wav", muzzleX, muzzleY, muzzleZ, false)
		setSoundMaxDistance(sound, 105)
		setElementDimension(sound, dim)
		setSoundVolume(sound, 0.3)
	elseif weaponID == 29 then--mp5
		local sound = playSound3D("sounds/weap/MP5.wav", muzzleX, muzzleY, muzzleZ, false)
		setSoundMaxDistance(sound, 120)
		setElementDimension(sound, dim)
		setSoundVolume(sound, 0.3)
	elseif weaponID == 30 then--ak47
		local sound = playSound3D("sounds/weap/AK-47.wav", muzzleX, muzzleY, muzzleZ, false)
		setSoundMaxDistance(sound, 180)
		setElementDimension(sound, dim)
		setSoundVolume(sound, 0.3)
	elseif weaponID == 31 then--m4
		local sound = playSound3D("sounds/weap/M4.wav", muzzleX, muzzleY, muzzleZ, false)
		setSoundMaxDistance(sound, 170)
		setElementDimension(sound, dim)
		setSoundVolume(sound, 0.3)
	elseif weaponID == 33 then--rifle
		local sound = playSound3D("sounds/weap/Rifle.wav", muzzleX, muzzleY, muzzleZ, false)
		setSoundMaxDistance(sound, 175)
		setElementDimension(sound, dim)
		setSoundVolume(sound, 0.3)
	elseif weaponID == 34 then--sniper
		local sound = playSound3D("sounds/weap/Sniper.wav", muzzleX, muzzleY, muzzleZ, false)
		setSoundMaxDistance(sound, 325)
		setElementDimension(sound, dim)
		setSoundVolume(sound, 0.3)
    end
end
addEventHandler("onClientPlayerWeaponFire", root, playGunfireSound)


--[[function shakeCamera(weapon)
	x,y,z = getPedBonePosition ( getLocalPlayer(), 26 )
	if weapon == 22  then 
		createExplosion ( x,y,z + 10,12,false,0.1,false)
	elseif weapon == 24  then 
		createExplosion ( x,y,z + 10,12,false,0.2,false)
	elseif weapon == 25  then 
		createExplosion ( x,y,z + 10,12,false,0.4,false)
	elseif weapon == 26  then
		createExplosion ( x,y,z + 10,12,false,0.5,false)
	elseif weapon == 27  then 
		createExplosion ( x,y,z + 10,12,false,0.3,false)
	elseif weapon == 28  then 
		createExplosion ( x,y,z + 10,12,false,0.1,false)
	elseif weapon == 29  then 
		createExplosion ( x,y,z + 10,12,false,0.1,false)
	elseif weapon == 30  then 
		createExplosion ( x,y,z+10,12,false,0.1,false)
        elseif weapon == 31  then 
		createExplosion ( x,y,z + 10,12,false,0.1,false)
	elseif weapon == 33  then 
		createExplosion ( x,y,z + 10,12,false,0.1,false)
	elseif weapon == 22  then
		createExplosion ( x,y,z + 10,12,false,0.1,false)
	elseif weapon == 28  then 
		createExplosion ( x,y,z + 10,12,false,0.1,false)
	elseif weapon == 32  then 
		createExplosion ( x,y,z + 10,12,false,0.1,false)
	elseif weapon == 38  then 
		createExplosion ( x,y,z + 10,12,false,0.4,false)
	end
end
addEventHandler ( "onClientPlayerWeaponFire", getLocalPlayer(), shakeCamera )
]]