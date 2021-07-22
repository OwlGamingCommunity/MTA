function formatTimeString( time, unit )
	if time == 0 then
		return ""
	end
	return time .. " " .. unit .. ( time ~= 1 and "s" or "" )
end
function formatTimeInterval( seconds )
	if type( seconds ) ~= "number" then
		return seconds
	end
	
	seconds = now( ) - seconds
	if seconds < 0 then
		return seconds
	end
	
	if seconds < 60 then
		return formatTimeString( seconds, "second" )
	end
	
	local minutes = math.floor( seconds / 60 )
	if minutes < 60 then
		return formatTimeString( minutes, "minute" ) .. " " .. formatTimeString( seconds - minutes * 60, "second" )
	end
	
	local hours = math.floor( minutes / 60 )
	if hours < 48 then
		return formatTimeString( hours, "hour" ) .. " " .. formatTimeString( minutes - hours * 60, "minute" )
	end
	
	local days = math.floor( hours / 24 )
	return formatTimeString( days, "day" )
end

--[[ Debug Overkill
function toJSONx( t )
	for k, v in ipairs( t ) do
		if isElement( v ) then
			t[k] = tostring(v)
		end
	end
	return toJSON(t)
end

local aeh = addEventHandler
function addEventHandler( a, b, c, ... )
	return aeh( a, b, function( ... ) if a ~= "onClientRender" then outputChatBox( a .. ":" .. toJSONx( {... } ), localPlayer and 255, localPlayer and 0, localPlayer and 0 ) end c( ... ) end, ...)
end
]]
-- whatsoever man. strings aint cool. even less to say, empty strings?!
local ged = getElementData
function getElementData( a, b, ... )
	if isElement(a) then
		local v = ged( a, b, ... )
		if b == "account:id" then
			if v == "" then
				return false
			else
				return tonumber(v)
			end
		end
		return v
	end
end

