-- Updated by Adams 27/01/14
local timer = {}
local tuned = {}
local function updateWorldItemValue(item, station, volume)
    if station < 0 or station > #exports.carradio:getStreams() then return end

    local newvalue = tostring(station)
    if volume and volume ~= 100 then
        newvalue = newvalue .. ':' .. volume
    end

    exports.anticheat:changeProtectedElementDataEx(item, "itemValue", newvalue)
    mysql:query_free( "UPDATE worlditems SET itemvalue='" .. newvalue .. "' WHERE id=" .. getElementData(item, "id"))
    triggerClientEvent("toggleSound", item)
end

function changeTrack(item, step)
    local streams = exports.carradio:getStreams()
    local splitValue = split(tostring(getElementData(item, "itemValue")), ':')
    local current = tonumber(splitValue[1]) or 1
    current = current + step
    if current > #streams then
        current = 0
    elseif current < 0 then
        current = #streams
    end
    updateWorldItemValue(item, current, tonumber(splitValue[2]))
	
	if not tuned[item] then
		exports.global:sendLocalMeAction(source, "retunes the Ghettoblaster.")
		tuned[item] = true
	else
		if timer[item] and isTimer(timer[item]) then
			killTimer(timer[item])
		end
		timer[item] = setTimer(function()
			tuned[item] = false
		end, 10*1000, 1)
	end
end
addEvent("changeGhettoblasterTrack", true)
addEventHandler("changeGhettoblasterTrack", getRootElement(), changeTrack)

addEvent('changeGhettoblasterVolume', true)
addEventHandler('changeGhettoblasterVolume', root,
    function(newvalue)
        newvalue = math.floor(newvalue)
        if newvalue < 0 or newvalue > 100 then return end

        local splitValue = split(tostring(getElementData(source, "itemValue")), ':')

        updateWorldItemValue(source, tonumber(splitValue[1]) or 1, newvalue)
    end)