local debugResoruce = nil
local spamTimer
_G["postEvent"] = function( sourceResource, eventName, eventSource, eventClient, luaFilename, luaLineNumber, ... )
	if not sourceResource or sourceResource ~= debugResoruce then return end
	if isTimer(spamTimer) then return end
	spamTimer = setTimer(function() end, 250, 1)
    local args = { ... }
    local srctype = eventSource and getElementType(eventSource)
    local resname = sourceResource and getResourceName(sourceResource)
    local plrname = eventClient and getPlayerName(eventClient)
    outputDebugString( "postEvent"
        .. " " .. tostring(resname)
        .. " " .. tostring(eventName)
        .. " source:" .. tostring(srctype)
        .. " player:" .. tostring(plrname)
        .. " file:" .. tostring(luaFilename)
        .. "(" .. tostring(luaLineNumber) .. ")"
        .. " numArgs:" .. tostring(#args)
        .. " arg1:" .. tostring(args[1])
        )
end

_G["preEvent"] = function( sourceResource, eventName, eventSource, eventClient, luaFilename, luaLineNumber, ... )
	if not sourceResource or sourceResource ~= debugResoruce then return end
	if isTimer(spamTimer) then return end
	spamTimer = setTimer(function() end, 250, 1)
    local args = { ... }
    local srctype = eventSource and getElementType(eventSource)
    local resname = sourceResource and getResourceName(sourceResource)
    local plrname = eventClient and getPlayerName(eventClient)
    outputDebugString( "preEvent"
        .. " " .. tostring(resname)
        .. " " .. tostring(eventName)
        .. " source:" .. tostring(srctype)
        .. " player:" .. tostring(plrname)
        .. " file:" .. tostring(luaFilename)
        .. "(" .. tostring(luaLineNumber) .. ")"
        .. " numArgs:" .. tostring(#args)
        .. " arg1:" .. tostring(args[1])
        )
end

_G["preFunction"] = function( sourceResource, functionName, isAllowedByACL, luaFilename, luaLineNumber, ... )
	if not sourceResource or sourceResource ~= debugResoruce then return end
	if isTimer(spamTimer) then return end
	spamTimer = setTimer(function() end, 250, 1)
    local args = { ... }
    local resname = sourceResource and getResourceName(sourceResource)
    outputDebugString( "preFunction"
        .. " " .. tostring(resname)
        .. " " .. tostring(functionName)
        .. " allowed:" .. tostring(isAllowedByACL)
        .. " file:" .. tostring(luaFilename)
        .. "(" .. tostring(luaLineNumber) .. ")"
        .. " numArgs:" .. tostring(#args)
        .. " arg1:" .. tostring(args[1])
        )
end

_G["postFunction"] = function( sourceResource, functionName, isAllowedByACL, luaFilename, luaLineNumber, ... )
	if not sourceResource or sourceResource ~= debugResoruce then return end
	if isTimer(spamTimer) then return end
	spamTimer = setTimer(function() end, 250, 1)
    local args = { ... }
    local resname = sourceResource and getResourceName(sourceResource)
    outputDebugString( "postFunction"
        .. " " .. tostring(resname)
        .. " " .. tostring(functionName)
        .. " allowed:" .. tostring(isAllowedByACL)
        .. " file:" .. tostring(luaFilename)
        .. "(" .. tostring(luaLineNumber) .. ")"
        .. " numArgs:" .. tostring(#args)
        .. " arg1:" .. tostring(args[1])
        )
end

local types = {}
types[1] = "preFunction"
types[2] = "preEvent"
types[3] = "postEvent"
types[4] = "postFunction"

local debugEnabled = false
local actualDebug = 0

function disableDebug()
	if debugEnabled then
		debugEnabled = false
		local str = types[actualDebug]
		removeDebugHook(str, _G[str])
		outputChatBox(str.." debughook removed! ("..getResourceName(debugResoruce)..")")
		debugResoruce = nil
	end
end

addCommandHandler("cdebughook", function(cmd,debug_type,res)
	disableDebug()
	if not exports.integration:isPlayerScripter(localPlayer) then return end
	debug_type = tonumber(debug_type)
	if not debug_type or not types[debug_type] or not res then
		outputChatBox("/"..cmd.." [1:preFunction | 2:preEvent | 3:postEvent | 4:postFunction] [Resource-Name]")
	else
		local resourceName = res
		local res = getResourceFromName(resourceName)
		if not res then
			outputChatBox("Invalid resource: "..resourceName)
			return
		end
		debugResoruce = res
		debugEnabled = true
		actualDebug = debug_type
		local str = types[actualDebug]
		outputChatBox(str.." debughook added! ("..resourceName.." | CLIENT)")
		addDebugHook(str, _G[str])
	end
end)