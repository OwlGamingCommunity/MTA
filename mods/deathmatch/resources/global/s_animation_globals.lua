function applyAnimation(thePlayer, block, name, animtime, loop, updatePosition, forced, taser)
	if animtime==nil then animtime=-1 end
	if loop==nil then loop=true end
	if updatePosition==nil then updatePosition=true end
	if forced==nil then forced=true end
	
	if isElement(thePlayer) and (getElementType(thePlayer)=="player" or getElementType(thePlayer)=="ped") and not getPedOccupiedVehicle(thePlayer) and getElementData(thePlayer, "freeze") ~= 1 then
		if getElementData(thePlayer, "injuriedanimation") or ( not forced and not getElementData(thePlayer, "forcedanimation")==1 ) then
			return false
		end
		
		if not taser and getElementData(thePlayer, "tazed") then
			return false
		end
		
		if getElementType(thePlayer) == "player" then		
			triggerEvent("bindAnimationStopKey", thePlayer)
			toggleAllControls(thePlayer, false, true, false)
		end
		if (forced) then
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "forcedanimation", 1, false)
		else
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "forcedanimation", 0, false)
		end
		
		local setanim = setPedAnimation(thePlayer, block, name, animtime, loop, updatePosition, false)
		if animtime > 100 then
			setTimer(setPedAnimation, 50, 2, thePlayer, block, name, animtime, loop, updatePosition, false)
		end
		if animtime > 50 then
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "animationt", setTimer(removeAnimation, animtime, 1, thePlayer), false)
		end
		exports.anticheat:setEld(thePlayer, 'animation',{block, name, animtime, loop,updatePosition, false}, 'all')
		return setanim
	else
		return false
	end
end

function onSpawn()
	setPedAnimation(source)
	toggleAllControls(source, true, true, false)
	exports.anticheat:changeProtectedElementDataEx(source, "forcedanimation", 0, false)
end
addEventHandler("onPlayerSpawn", getRootElement(), onSpawn)

addEvent( "onPlayerStopAnimation", true )
function removeAnimation(thePlayer, tazer)
	if isElement(thePlayer) and getElementType(thePlayer)=="player" and getElementData(thePlayer, "freeze") ~= 1 and not getElementData(thePlayer, "injuriedanimation") and not getElementData(thePlayer, "superman:flying") then
		if isTimer( getElementData( thePlayer, "animationt" ) ) then
			killTimer( getElementData( thePlayer, "animationt" ) )
		end
		if not tazer and getElementData(thePlayer, "tazed") then
			return false
		end
		exports.anticheat:changeProtectedElementDataEx(thePlayer, "tazed", false, false)
		local setanim = setPedAnimation(thePlayer)
		exports.anticheat:changeProtectedElementDataEx(thePlayer, "forcedanimation", 0, false)
		exports.anticheat:changeProtectedElementDataEx(thePlayer, "animationt", 0, false)
		toggleAllControls(thePlayer, true, true, false)
		setPedAnimation(thePlayer)
		setTimer(setPedAnimation, 50, 2, thePlayer)
		setTimer(triggerEvent, 100, 1, "onPlayerStopAnimation", thePlayer)
		exports.anticheat:setEld(thePlayer, 'animation',nil, 'all')
		return setanim
	else
		return false
	end
end