-- Default position on start of the resource
local x = 1662.669921875
local y = -1646.29296875
local z = 87.375
local int = 0
local dim = 0

--
local LSN_MONEY = 20

-- Some variables needed
local marker = nil
local cameraRadius = 15

function setPlayerFreecamEnabled(player)
	if not isPlayerFreecamEnabled(player) then
		removePedFromVehicle(player)
		setElementData(player, "realinvehicle", 0, false)

		setElementAlpha(player, 0)
		setElementData(player, "reconx", true)

		local startX, startY, startZ = getElementPosition(player)
		setElementData(player, "tv:dim", getElementDimension(player), false)
		setElementData(player, "tv:int", getElementInterior(player), false)
		setElementData(player, "tv:x", startX, false)
		setElementData(player, "tv:y", startY, false)
		setElementData(player, "tv:z", startZ, false)
		setElementDimension(player, dim)
		setElementInterior(player, int)

		return triggerClientEvent(player,"doSetFreecamEnabledTV", getRootElement(), x,y,z, false)
	else
		return false
	end
end

function moveCamera(newx, newy, newz, newint, newdim)
	if (marker) then
		destroyElement(marker)
	end
	marker = createMarker( newx, newy, newz, 'corona', 4, 255, 127, 0, 127)
	setElementInterior(marker, newint)
	setElementDimension(marker, 65535)
	
	x = newx
	y = newy
	z = newz
	int = newint
	dim = newdim
	return true
end

-- Move to the default position
moveCamera(x, y, z, int, dim)

function setPlayerFreecamDisabled(player)
	if isPlayerFreecamEnabled(player) then
		setElementDimension(player, getElementData(player, "tv:dim"))
		setElementInterior(player, getElementData(player, "tv:int"))
		setElementAlpha(player, 255)
		removeElementData(player, "reconx", true)
		
		return triggerClientEvent(player,"doSetFreecamDisabledTV", getRootElement(), false)
	else
		return false
	end
end

function setPlayerFreecamOption(player, theOption, value)
	return triggerClientEvent(player,"doSetFreecamOptionTV", getRootElement(), theOption, value)
end

function isPlayerFreecamEnabled(player)
	return getElementData(player,"freecamTV:state")
end



-- 

local earnings = 0
local watching = 0

--

function tv(player)
	local hasTV = exports.global:hasItem(player, 104, 1)
	local getDim = getElementDimension(player)
	if hasTV or (getDim > 0) or isPlayerFreecamEnabled(player) then
		if isPlayerFreecamEnabled(player) then
			setPlayerFreecamDisabled(player)
		elseif getCameraTarget(player) ~= player then
			outputChatBox("Can't put you into TV mode at the moment.", player, 255, 0, 0)
		elseif isTVRunning() then
			setPlayerFreecamEnabled(player)
		else
			outputChatBox("There's no TV Show running.", player, 255, 194, 14)
		end
	else
		outputChatBox("There's no TV near you.", player, 255, 194, 14)
	end
end
addCommandHandler("tv", tv)
addEvent("useTV", true)
addEventHandler("useTV", getRootElement(), tv)

addCommandHandler("movetv",
	function(player)
		if exports.factions:isPlayerInFaction(player, 20) then
			if isTVRunning() then
				outputChatBox("There is already a TV show running.", player, 255, 0, 0)
			else
				-- I like to ... move it!
				local posX, posY, posZ = getElementPosition(player)
				local posDim = getElementDimension(player)
				local posInt = getElementInterior(player)
				if moveCamera(posX, posY, posZ + 1, posInt, posDim) then
					for k, v in ipairs( getElementsByType( "player" ) ) do
						if getElementData(v, "faction") == 20 then
							outputChatBox("[TV] ".. getPlayerName(player):gsub("_", " ") .. " moved the camera position.", v, 200, 100, 200)
						end
					end
				else
					outputChatBox("Error!", player, 255, 0,0)
				end
			end
		end
	end
)

addCommandHandler("starttv",
	function(player)
		if exports.factions:isPlayerInFaction(player, 20) then
			if not isTVRunning() then
				outputChatBox("[TV] " .. getPlayerName(player):gsub("_", " ") .. " started a TV Show. (( /tv to watch ))", getRootElement( ), 200, 100, 200)
				exports.logs:dbLog(player, 23, player, "TV START")
				watching = 0
				earnings = 0
				setElementDimension(marker, dim)
			else
				outputChatBox("There is a TV Show already running.", player, 255, 0, 0)
			end
		end
	end
)

addCommandHandler("endtv",
	function(player)
		if exports.factions:isPlayerInFaction(player, 20) then
			if isTVRunning() then
				setElementDimension(marker, 65535)
				outputChatBox("[TV] " .. getPlayerName(player):gsub("_", " ") .. " ended the TV Show.", getRootElement( ), 200, 100, 200)
				
				for k, v in ipairs( getElementsByType( "player" ) ) do
					if isPlayerFreecamEnabled(v) then
						setPlayerFreecamDisabled(v)
					end
					
					if getElementData(v, "faction") == 20 then
						outputChatBox("[TV] Max. Viewers: " .. watching .. ", Earnings: $" .. exports.global:formatMoney(earnings), v, 200, 100, 200)
					end
				end
				
				exports.logs:dbLog(player, 23, player, "TV STOP - VIEWERS: " .. watching .. " EARNINGS: " .. earnings)
				exports.bank:addBankTransactionLog(nil, -getElementData(exports.factions:getFactionFromID(20), "id"), earnings, 6, "Earnings from TV show")
			else
				outputChatBox("There's no TV Show running.", player, 255, 0, 0)
			end
		end
	end
)

addCommandHandler("watchers",
	function(player)
		if exports.factions:isPlayerInFaction(player, 20) then
			if isTVRunning() then
				local count = 0
				for k, v in ipairs( getElementsByType( "player" ) ) do
					if isPlayerFreecamEnabled(v) then
						count = count + 1
					end
				end
				
				outputChatBox("[TV] Viewers: " .. count .. " in TV.", player, 200, 100, 200)
				outputChatBox("[TV] Max. Viewers: " .. watching .. ", Earnings: $" .. exports.global:formatMoney(earnings), player, 200, 100, 200)
			else
				outputChatBox("There's no TV Show running.", player, 255, 0, 0)
			end
		end
	end
)

function isTVRunning()
	return getElementDimension(marker) ~= 65535
end

--[[
function isPlayerInCameraRadius(sourceplayer)
	local x,y,z = getElementPosition(sourceplayer)  
	local xx, xy, xz = getElementPosition(marker) 
	if (getDistanceBetweenPoints2D ( x, y, xx, xy ) < 15) then
		return true
	end
	return false
end
]]

isPlayerInCameraRadius = isPlayerFreecamEnabled

function add( affectedPlayers )
	if type(affectedPlayers) ~= 'table' then
		return
	end

	local shownto = 0
	for i, player in ipairs(affectedPlayers) do
		if type(player) == 'userdata' and isPlayerFreecamEnabled(player) then
			shownto = shownto + 1
		end
	end

	if isTVRunning() and shownto > 0 then
		watching = math.max( shownto, watching )
		earnings = earnings + LSN_MONEY * shownto
		
		exports.global:giveMoney(exports.factions:getFactionFromID(20), LSN_MONEY * shownto)
		--exports.logs:dbLog(player, 23, player, "TV $" .. ( 10 * shownto ) .. " " .. message)
	else
		--exports.logs:dbLog(player, 23, player, "TV OFF " .. message)
	end
end