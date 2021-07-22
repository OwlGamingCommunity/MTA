function throwPlayerThroughWindow(pos)
	if isVehicleLocked(source) then
		setVehicleLocked(source, false)
	end
	exports.anticheat:setEld( client, "realinvehicle", 0, 'one' )
	local seat = getPedOccupiedVehicleSeat( client )
	removePedFromVehicle( client, vehicle )
	setElementPosition( client, unpack(pos) )
	exports.global:applyAnimation( client, "ped", (seat == 0 or seat == 2) and 'CAR_rollout_LHS' or 'CAR_rollout_RHS', 20000, false, true, true, false )
end
addEvent("crashThrowPlayerFromVehicle", true)
addEventHandler("crashThrowPlayerFromVehicle", root, throwPlayerThroughWindow)

function unhookTrailer(thePlayer)
   if (isPedInVehicle(thePlayer)) then
        local theVehicle = getPedOccupiedVehicle(thePlayer)
        if theVehicle then
            detachTrailerFromVehicle(theVehicle)
        end
   end
end
addCommandHandler("detach", unhookTrailer)
addCommandHandler("unhook", unhookTrailer)

local noBelt = { [431] = true, [437] = true }
local helmetid = { 90, 171, 172}
function seatbelt(thePlayer)
	if getPedOccupiedVehicle(thePlayer) and getElementData(thePlayer, "realinvehicle") == 1 then
		local theVehicle = getPedOccupiedVehicle(thePlayer)
		if (getVehicleType(theVehicle) == "BMX") or (noBelt[getElementModel(theVehicle)] and getVehicleOccupant(theVehicle, 0) ~= thePlayer) then
			outputChatBox("Odd... There's no seatbelt on this vehicle!", thePlayer, 255, 0, 0)
		else
			local helmet = false
			if (getElementData(thePlayer, "seatbelt") == true) then
				if getVehicleType(theVehicle) ~= "Bike" then
					exports.anticheat:changeProtectedElementDataEx(thePlayer, "seatbelt", false, true)
					outputChatBox("You unbuckled your seatbelt.", thePlayer, 255, 0, 0)
					triggerEvent("sendAme", thePlayer, "unbuckles their seatbelt.")
				elseif getVehicleType(theVehicle) == "Bike" then
					local artifacts = exports.artifacts:getPlayerArtifacts(thePlayer)
					for k,v in pairs(artifacts) do
						if string.find(v, "helmet") then
							helmet = v
							break
						end
					end
					if helmet then
						triggerEvent("sendAme", thePlayer, "removes their helmet.")
						exports.anticheat:changeProtectedElementDataEx(thePlayer, helmet, false, true)
						if bikers[thePlayer] then
							if getElementType(bikers[thePlayer][1]) == "vehicle" then
								exports.global:giveItem(bikers[thePlayer][1], bikers[thePlayer][2], bikers[thePlayer][3])
							end
						end
						triggerEvent("artifacts:remove", thePlayer, thePlayer, helmet)
					end
				end
			else
				if getVehicleType(theVehicle) ~= "Bike" then
					exports.anticheat:changeProtectedElementDataEx(thePlayer, "seatbelt", true, true)
					outputChatBox("You buckled your seatbelt.", thePlayer, 0, 255, 0)
					triggerEvent("sendAme", thePlayer, "buckles in their seatbelt.")
				elseif getVehicleType(theVehicle) == "Bike" then
					for k,v in ipairs(helmetid) do
						local has, _, value = exports.global:hasItem(theVehicle, v) -- Check the vehicle first
						if has then
							addHelmet(thePlayer, v, value)
							bikers[thePlayer] = {theVehicle, v, value}
							exports.global:takeItem(theVehicle, v, value)
							break
						else
							local has, _, value = exports.global:hasItem(thePlayer, v) -- Now the player
							if has then
								addHelmet(thePlayer, v, value)
								bikers[thePlayer] = {thePlayer, v, value}
								break
							end
						end
					end
					local artifacts = exports.artifacts:getPlayerArtifacts(thePlayer)
					for k,v in pairs(artifacts) do
						if string.find(v, "helmet") then
							helmet = v
							break
						end
					end
					if helmet then
						exports.anticheat:changeProtectedElementDataEx(thePlayer, "seatbelt", true, true)
						triggerEvent("sendAme", thePlayer, "puts their helmet on.")
					end
				end
			end
		end
	end
end
addCommandHandler("seatbelt", seatbelt)
addCommandHandler("belt", seatbelt)
addEvent('realism:seatbelt:toggle', true)
addEventHandler('realism:seatbelt:toggle', root, seatbelt)

function addHelmet(source, itemID, itemValue)
	local itemID = tonumber(itemID)
	if itemID == 90 then -- Helmet
		if getElementData(source, "bikerhelmet") then
			exports.anticheat:changeProtectedElementDataEx(source, "bikerhelmet", false, true)
			triggerEvent("artifacts:remove", source, source, "bikerhelmet")
		end
		if getElementData(source, "fullfacehelmet") then
			exports.anticheat:changeProtectedElementDataEx(source, "fullfacehelmet", false, true)
			triggerEvent("artifacts:remove", source, source, "fullfacehelmet")
		end
		local customTexture = exports["item-system"]:getItemTexture(itemID, itemValue)
		exports.anticheat:changeProtectedElementDataEx(source, "helmet", true, true)
		triggerEvent("artifacts:add", source, source, "helmet", false, customTexture)
	elseif itemID == 171 then -- Biker Helmet
		if getElementData(source, "helmet") then
			exports.anticheat:changeProtectedElementDataEx(source, "helmet", false, true)
			triggerEvent("artifacts:remove", source, source, "helmet")
		end
		if getElementData(source, "fullfacehelmet") then
			exports.anticheat:changeProtectedElementDataEx(source, "fullfacehelmet", false, true)
			triggerEvent("artifacts:remove", source, source, "fullfacehelmet")
		end
		local customTexture = exports["item-system"]:getItemTexture(itemID, itemValue)
		exports.anticheat:changeProtectedElementDataEx(source, "bikerhelmet", true, true)
		triggerEvent("artifacts:add", source, source, "bikerhelmet", false, customTexture)
	elseif itemID == 172 then -- Full Face Helmet
		if getElementData(source, "helmet") then
			exports.anticheat:changeProtectedElementDataEx(source, "helmet", false, true)
			triggerEvent("artifacts:remove", source, source, "helmet")
		end
		if getElementData(source, "bikerhelmet") then
			exports.anticheat:changeProtectedElementDataEx(source, "bikerhelmet", false, true)
			triggerEvent("artifacts:remove", source, source, "bikerhelmet")
		end
		local customTexture = exports["item-system"]:getItemTexture(itemID, itemValue)
		exports.anticheat:changeProtectedElementDataEx(source, "fullfacehelmet", true, true)
		triggerEvent("artifacts:add", source, source, "fullfacehelmet", false, customTexture)
	end
end

addEventHandler("artifacts:remove", root, function(player, artifact)
	if getElementData(player, "seatbelt") then
		local veh = getPedOccupiedVehicle( player )
		if veh and getVehicleType(veh) == "Bike" then
			if artifact == "helmet" or artifact == "fullfacehelmet" or artifact == "bikerhelmet" then
				exports.anticheat:changeProtectedElementDataEx(player, "seatbelt", false, true)
				bikers[player] = nil
			end
		end
	end
end)

bikers = {}
addEventHandler("onVehicleStartExit", root, function(player)
	if getVehicleType(source) == "Bike" then
		if bikers[player] then
			local helmet = false
			local artifacts = exports.artifacts:getPlayerArtifacts(player)
			for k,v in pairs(artifacts) do
				if string.find(v, "helmet") then
					helmet = v
					break
				end
			end
			exports.anticheat:changeProtectedElementDataEx(player, helmet, false, true)
			triggerEvent("sendAme", player, "removes their helmet.")
			if getElementType(bikers[player][1]) == "vehicle" then
				exports.global:giveItem(bikers[player][1], bikers[player][2], bikers[player][3])
			end
			triggerEvent("artifacts:remove", player, player, helmet)
		end
	end
end)

function removeSeatbelt(thePlayer)
	if getElementData(thePlayer, "seatbelt") and not isPedInVehicle(thePlayer) then
		exports.anticheat:changeProtectedElementDataEx(thePlayer, "seatbelt", false, true)

		if bikers[thePlayer] then
			local helmet = false
			local artifacts = exports.artifacts:getPlayerArtifacts(thePlayer)
			for k,v in pairs(artifacts) do
				if string.find(v, "helmet") then
					helmet = v
					break
				end
			end
			exports.anticheat:changeProtectedElementDataEx(thePlayer, helmet, false, true)
			triggerEvent("sendAme", thePlayer, "removes their helmet.")
			if getElementType(bikers[thePlayer][1]) == "vehicle" then
				exports.global:giveItem(bikers[thePlayer][1], bikers[thePlayer][2], bikers[thePlayer][3])
			end
			triggerEvent("artifacts:remove", thePlayer, thePlayer, helmet)
		else
			triggerEvent("sendAme", thePlayer, "unbuckles their seatbelt.")
		end
	end
end
addEventHandler("onVehicleExit", getRootElement(), removeSeatbelt)

function addSeatbelt(thePlayer)
	if getVehicleType(source) ~= "Bike" then return end
	local helmet = false
	local artifacts = exports.artifacts:getPlayerArtifacts(thePlayer)
	for k,v in pairs(artifacts) do
		if string.find(v, "helmet") then
			helmet = v
			break
		end
	end
	if helmet then
		exports.anticheat:changeProtectedElementDataEx(thePlayer, "seatbelt", true, true)
		bikers[thePlayer] = {thePlayer, v, value}
		triggerEvent("sendAme", thePlayer, "secures their helmet.")
	end
end
addEventHandler("onVehicleEnter", getRootElement(), addSeatbelt)

function seatbeltFix()
	for _, thePlayer in ipairs(getElementsByType("player")) do
		exports.anticheat:changeProtectedElementDataEx(thePlayer, "seatbelt", false, true)
	end
	--outputDebugString("Fixed for " .. counter .. " players")
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), seatbeltFix)
--addCommandHandler("fixbelts", seatbeltFix, false, false)
