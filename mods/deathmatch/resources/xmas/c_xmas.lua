--    ____        __     ____  __            ____               _           __ 
--   / __ \____  / /__  / __ \/ /___ ___  __/ __ \_________    (_)__  _____/ /_
--  / /_/ / __ \/ / _ \/ /_/ / / __ `/ / / / /_/ / ___/ __ \  / / _ \/ ___/ __/
-- / _, _/ /_/ / /  __/ ____/ / /_/ / /_/ / ____/ /  / /_/ / / /  __/ /__/ /_  
--/_/ |_|\____/_/\___/_/   /_/\__,_/\__, /_/   /_/   \____/_/ /\___/\___/\__/  
--                                 /____/                /___/                 
--Client side script: Special christmas season features
--Last updated 04.12.2014 by Exciter
--Copyright 2008, The Roleplay Project (www.roleplayproject.com)

local santaSound

function santaDoesStuff(what, santa)
	if santaSound and isElement(santaSound) then
		destroyElement(santaSound)
		santaSound = nil
	end
	if(what == "arrive") then
		local x,y,z = getElementPosition(santa)
		santaSound = playSound3D("sound/holidays.mp3", x, y, z, false)
		setSoundMinDistance(santaSound, 0)
		setSoundMaxDistance(santaSound, 319)
		setPedControlState(santa, "enter_exit", true)
		--setTimer(setPedControlState, 1000, 1, santa, "enter_exit", false)
	elseif(what == "depart") then
		local x,y,z = getElementPosition(santa)
		santaSound = playSound3D("sound/santa.mp3", x, y, z, false) 
		setSoundMinDistance(santaSound, 0)
		setSoundMaxDistance(santaSound, 20)
		setTimer(function()
			setPedControlState(santa, "enter_exit", true)
			--setTimer(setPedControlState, 1000, 1, santa, "enter_exit", false)
		end, 30000, 1)
	elseif(what == "hoho") then
		local x,y,z = getElementPosition(santa)
		santaSound = playSound3D("sound/santa.mp3", x, y, z, false) 
		setElementInterior(santaSound, getElementInterior(santa))
		setElementDimension(santaSound, getElementDimension(santa))
		setSoundMinDistance(santaSound, 0)
		setSoundMaxDistance(santaSound, 20)
		attachElements(santaSound, santa)
		--[[
		setTimer(function()
			detachElements(santaSound, santa)
			destroyElement(santaSound)
		end, 29000, 1)
		--]]
	end
end
addEvent("xmas:santaSound", true)
addEventHandler("xmas:santaSound", getRootElement(), santaDoesStuff)