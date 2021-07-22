function tazerFired(x, y, z, target)
	local px, py, pz = getElementPosition(source)
	local distance = getDistanceBetweenPoints3D(x, y, z, px, py, pz)

	if (distance<20) then
		if (isElement(target) and getElementType(target)=="player") then
			for key, value in ipairs(exports.global:getNearbyElements(target, "player", 20)) do
				if (value~=source) then
					triggerClientEvent(value, "showTazerEffect", value, x, y, z) -- show the sparks
				end
			end
			
			exports.anticheat:changeProtectedElementDataEx(target, "tazed", true, false)
			toggleAllControls(target, false, true, false)
			exports.global:applyAnimation(target, "ped", "FLOOR_hit_f", -1, false, false, true, true, true)
			--setElementData(target, "tazed", true)
			setTimer(removeAnimation, 10005, 1, target)
		end
	end
end
addEvent("tazerFired", true )
addEventHandler("tazerFired", getRootElement(), tazerFired)

function removeAnimation(thePlayer)
	if (isElement(thePlayer) and getElementType(thePlayer)=="player") then
		exports.global:removeAnimation(thePlayer, true)
		--toggleAllControls(thePlayer, true, true, true)
		
	end
end

function updateDeagleMode(mode)
	if ( tonumber(mode) and (tonumber(mode) >= 0 and tonumber(mode) <= 2) ) then
		exports.anticheat:changeProtectedElementDataEx(client, "deaglemode", mode, true)
	end
end
addEvent("deaglemode", true)
addEventHandler("deaglemode", getRootElement(), updateDeagleMode)