--MAXIME
function now()
	local timePassed = math.floor((getRealTime().timestamp - lastTime))
	--outputChatBox(timePassed)
	return serverCurrentTimeSec + timePassed
end

function formatTimeInterval( timeInseconds )
	if type( timeInseconds ) ~= "number" then
		return timeInseconds, 0
	end
	
	local seconds = now()-timeInseconds
	if seconds < 1 then
		return "Just now", 0
	end
	
	if seconds < 60 then
		return formatTimeString( seconds, "second" ).." ago", seconds
	end
	
	local minutes = math.floor( seconds / 60 )
	if minutes < 60 then
		return formatTimeString( minutes, "m" ) .. " " .. formatTimeString( seconds - minutes * 60, "s" ).." ago" , seconds
	end
	
	local hours = math.floor( minutes / 60 )
	if hours < 48 then
		return formatTimeString( hours, "h" ) .. " " .. formatTimeString( minutes - hours * 60, "m" ).." ago", seconds
	end
	
	local days = math.floor( hours / 24 )
	return formatTimeString( days, "day" ).." ago", seconds
end

function formatFutureTimeInterval( timeInseconds )
	if type( timeInseconds ) ~= "number" then
		return timeInseconds, 0
	end
	
	local seconds = timeInseconds-now()
	if seconds < 0 then
		return "0s", 0
	end
	
	if seconds < 60 then
		return formatTimeString( seconds, "second" ), seconds
	end
	
	local minutes = math.floor( seconds / 60 )
	if minutes < 60 then
		return formatTimeString( minutes, "m" ) .. " " .. formatTimeString( seconds - minutes * 60, "s" ), seconds
	end
	
	local hours = math.floor( minutes / 60 )
	if hours < 48 then
		return formatTimeString( hours, "h" ) .. " " .. formatTimeString( minutes - hours * 60, "m" ), seconds
	end
	
	local days = math.floor( hours / 24 )
	return formatTimeString( days, "day" ), seconds
end

function formatTimeString( time, unit )
	if time == 0 then
		return ""
	end
	if unit == "day" or unit == "hour" or unit == "minute" or unit == "second" then
		return time .. " " .. unit .. ( time ~= 1 and "s" or "" )
	else
		return time .. "" .. unit-- .. ( time ~= 1 and "s" or "" )
	end
end

function minutesToDays(minutes) 
	local oneDay = minutes*60*24
	return math.floor(minutes/oneDay)
end	

function formatSeconds(seconds)
	if type( seconds ) ~= "number" then
		return seconds
	end
	
	if seconds <= 0 then
		return "Now"
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

function isLeapYear(year)
	return year%4==0 and (year%100~=0 or year%400==0)
end

function getTimestamp(year, month, day, hour, minute, second)
	-- initiate variables
	local monthseconds = { 2678400, 2419200, 2678400, 2592000, 2678400, 2592000, 2678400, 2678400, 2592000, 2678400, 2592000, 2678400 }
	local timestamp = 0
	local datetime = getRealTime()
	year, month, day = year or datetime.year + 1900, month or datetime.month + 1, day or datetime.monthday
	hour, minute, second = hour or datetime.hour, minute or datetime.minute, second or datetime.second

	-- calculate timestamp
	for i=1970, year-1 do timestamp = timestamp + (isLeapYear(i) and 31622400 or 31536000) end
	for i=1, month-1 do timestamp = timestamp + ((isLeapYear(year) and i == 2) and 2505600 or monthseconds[i]) end
	timestamp = timestamp + 86400 * (day - 1) + 3600 * hour + 60 * minute + second

	timestamp = timestamp - 3600 --GMT+1 compensation
	if datetime.isdst then timestamp = timestamp - 3600 end

	return timestamp
end

function datetimeToTimestamp(datetime)
	--Converts a datetime string (YYYY-MM-DD HH:MM:SS) to UNIX timestamp
	local pattern = "(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)"
	local year, month, day, hour, minute, seconds = datetime:match(pattern)
	return getTimestamp(year, month, day, hour, minute, seconds)
end