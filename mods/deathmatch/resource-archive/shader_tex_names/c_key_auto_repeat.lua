--
-- c_key_auto_repeat.lua
--

-------------------------------------------------------------
-- Keyboard auto-repeat
-------------------------------------------------------------
KeyAutoRepeat = {}
KeyAutoRepeat.repeatDelay = 500					-- Wait before 1st repeat
KeyAutoRepeat.repeatRateInitial = 100			-- Delay between repeats (initial)
KeyAutoRepeat.repeatRateMax = 10				-- Delay between repeats (after key held for repeatRateChangeTime)
KeyAutoRepeat.repeatRateChangeTime = 2700		-- Amount of time to move between repeatRateInitial and repeatRateMax
KeyAutoRepeat.keydownInfo = {}

-- Result event - Same parameters as onClientKey
addEvent( "onClientKeyClick" )

-- Update repeats
function KeyAutoRepeat.pulse()
	for key,info in pairs(KeyAutoRepeat.keydownInfo) do
		local age = getTickCount () - info.downStartTime
		age = age - KeyAutoRepeat.repeatDelay	-- Initial delay
		if age > 0 then
			-- Make rate speed up as the key is held
			local ageAlpha = math.unlerpclamped( 0, age, KeyAutoRepeat.repeatRateChangeTime )
			local dynamicRate = math.lerp( KeyAutoRepeat.repeatRateInitial, ageAlpha, KeyAutoRepeat.repeatRateMax )		

			local count = math.floor(age/dynamicRate)	-- Repeat rate
			if count > info.count then
				info.count = count
				triggerEvent("onClientKeyClick", resourceRoot, key )
			end
		end
	end
end
addEventHandler("onClientRender", root, KeyAutoRepeat.pulse )

-- When a key is pressed/release
function KeyAutoRepeat.keyChanged(key,down)
	KeyAutoRepeat.keydownInfo[key] = nil
	if down then
		KeyAutoRepeat.keydownInfo[key] = { downStartTime=getTickCount (), count=0 }
		triggerEvent("onClientKeyClick", resourceRoot, key )
	end
end
addEventHandler("onClientKey", root, KeyAutoRepeat.keyChanged)


-------------------------------------------------------------
-- Math extentions
-------------------------------------------------------------
function math.lerp(from,alpha,to)
    return from + (to-from) * alpha
end

function math.unlerp(from,pos,to)
	if ( to == from ) then
		return 1
	end
	return ( pos - from ) / ( to - from )
end

function math.clamp(low,value,high)
    return math.max(low,math.min(value,high))
end

function math.unlerpclamped(from,pos,to)
	return math.clamp(0,math.unlerp(from,pos,to),1)
end
