--MAXIME
local businessNameCache = {}
local searched = {}
local refreshCacheRate = 10 --Minutes
function getBusinessNameFromID( id )
	if not id or not tonumber(id) then
		--outputDebugString("Client cache: id is empty.")
		return false
	else
		id = tonumber(id)
	end
	
	if businessNameCache[id] then
		return businessNameCache[id]
	end
	
	for i, player in pairs(getElementsByType("player")) do
		if id == getElementData(player, "dbid") then
			businessNameCache[id] = exports.global:getPlayerName(player)
			return businessNameCache[id]
		end
	end
	
	if not searched[id] or getTickCount() - searched[id] > refreshCacheRate*1000*60 then
		searched[id] = getTickCount()
		triggerServerEvent("requestBusinessNameCacheFromServer", localPlayer, id)
	else 
		--outputDebugString("Client cache: Previously requested for server's cache but not found. Searching cancelled.")
		return false
	end

	return "Loading.."
end

function retrieveBusinessNameCacheFromServer(businessName, id)
	--outputDebugString("Client cache: Retrieving data from server and adding to client's cache.")
	if businessName and id then
		businessNameCache[id] = businessName
	end
end
addEvent("retrieveBusinessNameCacheFromServer", true)
addEventHandler("retrieveBusinessNameCacheFromServer", root, retrieveBusinessNameCacheFromServer)