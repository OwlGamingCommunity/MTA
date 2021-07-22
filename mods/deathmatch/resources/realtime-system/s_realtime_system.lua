local firstStart = true

function updateTime(specifiedPlayer)
	local offset = tonumber(get("offset")) or 0
	local realtime = getRealTime()
	hour = realtime.hour + offset
	if hour >= 24 then
		hour = hour - 24
	elseif hour < 0 then
		hour = hour + 24
	end

	minute = realtime.minute
	setTime(hour, minute)

	nextupdate = (60-realtime.second) * 1000
	setMinuteDuration( nextupdate )
	setTimer( setMinuteDuration, nextupdate + 5, 1, 60000 )

	if not firstStart then
		for k, v in ipairs(getElementsByType("player")) do
			local int = getElementInterior(v)
			local dim = getElementDimension(v)
			if int > 0 and dim > 0 then
				refreshClientTime(int, dim, v)
			end
		end
	end

	firstStart = false
end
addEventHandler("onResourceStart", resourceRoot, updateTime )

-- update the time every 30 minutes (correction)
setTimer( updateTime, 1800000, 0 )

function setGameTime(thePlayer, commandName, hour, minute)
	if exports.integration:isPlayerAdmin(thePlayer) then
		if not tonumber(hour) or not tonumber(minute) or (tonumber(hour) % 1 ~= 0) or (tonumber(minute) % 1 ~= 0) or tonumber(hour) < 0 or tonumber(hour) > 23 or tonumber(minute) > 60 or tonumber(hour) < 0 then
			outputChatBox( "SYNTAX: /" .. commandName .. " [hour] [minute]", thePlayer, 255, 194, 14 )
		else
			if setTime(hour, minute) then
				local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
				local adminName = getElementData(thePlayer, "account:username")
				exports.global:sendMessageToAdmins("[REALTIME]: "..adminTitle.." "..adminName.." has temporarily changed game time to "..hour..":"..minute)
			end
		end
	end
end
addCommandHandler("setgametime", setGameTime, false, false)

function refreshClientTime(interior, dimension, player)
	local offset = tonumber(get("offset")) or 0
	local realtime = getRealTime()
	hour = realtime.hour + offset
	if hour >= 24 then
		hour = hour - 24
	elseif hour < 0 then
		hour = hour + 24
	end
	if player then
		client = player
	end
	if not interior then
		interior = getElementInterior(client)
	end
	if not dimension then
		dimension = getElementDimension(client)
	end
	minute = realtime.minute
	if(interior > 0 and dimension > 0) then
		local overridetime = tonumber(exports.interior_system:getInteriorSetting(dimension, "time")) --0=auto,1=day,2=night
		if overridetime then
			if overridetime == 1 then --day
				hour, minute = 12, 0
			elseif overridetime == 2 then --night
				hour, minute = 0, 0
			end
		end
	end
	triggerClientEvent(client, "updateClientTime", resourceRoot, hour, minute)
end
addEvent("realtime:refreshClientTime", true)
addEventHandler("realtime:refreshClientTime", resourceRoot, refreshClientTime)
addEventHandler("onPlayerInteriorChange", getRootElement(), refreshClientTime)
