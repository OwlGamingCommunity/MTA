local ablauf = {}
local ped = {}
local stat = {}
local firetimer = {}
local timer = {}
local jx, jy, jz = {}, {}, {}
local pedSayTimer = {}
--[[

CREATE TABLE `owl_mta`.`dog_users` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `charactername` VARCHAR(45) NOT NULL,
  `attack` INT NOT NULL,
  PRIMARY KEY (`id`));

]]

addEventHandler("onResourceStart", resourceRoot,
	function()
		dbQuery(function(qh)
			local result = dbPoll(qh, 0)
			local result_table = { }
			for _, row in ipairs(result) do 
				table.insert(result_table, row)
			end
			setElementData(resourceRoot, "dogs:table", result_table)
		end, exports.mysql:getConn("mta"), "SELECT `id`, `charactername`, `attack` FROM `dog_users`")
	end)

function doQuery(thetype, name, attack)
	if thetype == 1 then
		dbExec(exports.mysql:getConn("mta"), "INSERT INTO `dog_users` SET `charactername`=?, `attack`=?", name, attack)
	elseif thetype == 2 then
		dbExec(exports.mysql:getConn("mta"), "DELETE FROM `dog_users` WHERE `charactername` = ?", name)
	end
end
addEvent("dogs:doquery", true)
addEventHandler("dogs:doquery", resourceRoot, doQuery)

local function functionscheck()
	for index, p in next, ped do
		if(isElement(p)) then
			if getElementData(p, "k9:status") == 0 then
				if getElementData(p, "k9:sits") ~= true then
					setPedAnimation( p, "INT_OFFICE", "OFF_Sit_Crash") -- sits
					setElementData(p, "k9:sits", true)
				end
				return
			end -- so it holds
			if getElementData(p, "k9:status") == 2 then

				local player = getPlayerFromName(getElementData(p, "besitzer"))
				local targetElement = getElementData(p, "k9:target")
				if not isElement(targetElement) then
					setElementData(p, "k9:status", 1)
					return
				end
				if(targetElement) and (ped[player]) then
					if(isElement(p)) and (isElement(targetElement)) then
						if not(stat[p]) then
							stat[p] = {}
							timer[p] = {}
						end
						local owner = targetElement
						if(owner) then
							local x, y, z = getElementPosition(owner)
							local x2, y2, z2 = getElementPosition(p)

							if(getDistanceBetweenPoints3D(x, y, z, x2, y2, z2) > 1) then
								-- SPRINT CHECK --
								stat[p]["running"] = true
								if(getDistanceBetweenPoints3D(x, y, z, x2, y2, z2) > 10) then
									if(stat[p]["jumping"] ~= true) and (stat[p]["inveh"] ~= true) then
										setPedAnimation(p, "ped" , "sprint_civi", -1, true, true, false) -- Sprintet
									end
								else
									if(stat[p]["jumping"] ~= true) and (stat[p]["inveh"] ~= true) then
										setPedAnimation(p, "ped" , "JOG_maleA", -1, true, true, false) -- Joggt
									end
								end
								-- ROTATION --
								local x1, y1 = getElementPosition(p)
								local x2, y2 = getElementPosition(owner)
								local rot = math.atan2(y2 - y1, x2 - x1) * 180 / math.pi
								rot = rot-90
								setPedRotation(p, rot)
								-- CAR --
								local inveh = false
								if(isPedInVehicle(player)) then
									inveh = true
								end
								if(inveh == true) and (getDistanceBetweenPoints3D(x, y, z, x2, y2, z2) < 4) then
									if(stat[p]["inveh"] ~= true) and (stat[p]["enterveh"] ~= true) then
										stat[p]["enterveh"] = true
										setPedAnimation(p)
										triggerClientEvent(getRootElement(), "doPedEnter", player, p, true)
										setTimer(function()
											local occupants = getVehicleOccupants(getPedOccupiedVehicle(player))
											for i = 1, getVehicleMaxPassengers(getPedOccupiedVehicle(player)), 1 do
												if not(occupants[i]) then
													warpPedIntoVehicle(p, getPedOccupiedVehicle(player), i)
													stat[p]["inveh"] = true
													break;
												end
											end
											stat[p]["enterveh"] = false
										end, 2000, 1)
									end
								else
									if(stat[p]["inveh"] == true) and (stat[p]["enterveh"] == false) and(isPedInVehicle(player) == false) then -- er ist nicht im auto aber ich bin es
										stat[p]["enterveh"] = true
										triggerClientEvent(getRootElement(), "doPedExitVeh", player, p, true)
										setTimer(function()
											removePedFromVehicle(p)
											stat[p]["enterveh"] = false
											stat[p]["inveh"] = false
										end, 1000, 1)
									end
								end
								-- JUMP CHECK  --
								if(inveh == false) then
									if((z-z2) > 0.8) and (getDistanceBetweenPoints3D(x, y, z, x2, y2, z2) < 4) and (stat[p]["jumping"] ~= true) then -- er ist oben
										stat[p]["jumping"] = true
										setPedAnimation(p)
										triggerClientEvent(getRootElement(), "doPedJump", player, p, true)
										if(isTimer(timer[p]["jump"])) then killTimer(timer[p]["jump"]) end
										timer[p]["jump"] = setTimer(function()
											stat[p]["jumping"] = false
											triggerClientEvent(getRootElement(), "doPedJump", player, p, false)
										end, 800, 1)
									end
								end
							else
								if (stat[p]["running"] == true)then
									stat[p]["running"] = false
									setPedAnimation(p)

									setPedAnimation(owner, "ped", "FLOOR_hit_f")
									exports.global:sendLocalDoAction(owner, string.gsub(getPlayerName(owner), "_", " ").." has been tackled down by "..getElementData(p, "name")..".", true)
									setElementFrozen(owner, true)
									setTimer( function()
										if isElement(owner) then
											setElementFrozen(owner, false)
											setPedAnimation(owner)
										end
									end, 3000, 1)
								end
							end
						else
							destroyElement(p)
						end
					end
				end
			else
				local player = type(getElementData(p, "besitzer")) == "string" and getPlayerFromName(getElementData(p, "besitzer")) or nil
				if(player) and (ped[player]) then
					if(isElement(p)) and (ablauf[player] == true) then
						if not(stat[p]) then
							stat[p] = {}
							timer[p] = {}
						end
						local owner = player
						if(owner) then


							local x, y, z = getElementPosition(owner)
							local x2, y2, z2 = getElementPosition(p)

							-- int / dim checker
							local playerDim = getElementDimension(owner)
							local playerInt = getElementInterior(owner)
							local dogDim = getElementDimension(p)
							local dogInt = getElementInterior(p)

							if playerDim ~= dogDim or playerInt ~= dogInt then
								setElementDimension(p, playerDim)
								setElementInterior(p, playerInt)
								setElementPosition(p, x, y + 0.5, z)
								x2, y2, z2 = getElementPosition(p)
							end
							-- end of int dim checker

							if(getDistanceBetweenPoints3D(x, y, z, x2, y2, z2) > 3) then
								-- SPRINT CHECK --
								stat[p]["running"] = true
								if(getDistanceBetweenPoints3D(x, y, z, x2, y2, z2) > 10) then
									if(stat[p]["jumping"] ~= true) and (stat[p]["inveh"] ~= true) then
										setPedAnimation(p, "ped" , "sprint_civi", -1, true, true, false) -- Sprintet
									end
								else
									if(stat[p]["jumping"] ~= true) and (stat[p]["inveh"] ~= true) then
										setPedAnimation(p, "ped" , "JOG_maleA", -1, true, true, false) -- Joggt
									end
								end
								-- ROTATION --
								local x1, y1 = getElementPosition(p)
								local x2, y2 = getElementPosition(owner)
								local rot = math.atan2(y2 - y1, x2 - x1) * 180 / math.pi
								rot = rot-90
								setPedRotation(p, rot)
								-- CAR --
								local inveh = false
								if(isPedInVehicle(player)) then
									inveh = true
								end
								if(inveh == true) and (getDistanceBetweenPoints3D(x, y, z, x2, y2, z2) < 4) then
									if(stat[p]["inveh"] ~= true) and (stat[p]["enterveh"] ~= true) then
										stat[p]["enterveh"] = true
										setPedAnimation(p)
										triggerClientEvent(getRootElement(), "doPedEnter", player, p, true)
										setTimer(function()
											if getPedOccupiedVehicle( player ) then
												local occupants = getVehicleOccupants(getPedOccupiedVehicle(player))
												for i = 1, getVehicleMaxPassengers(getPedOccupiedVehicle(player)), 1 do
													if not(occupants[i]) then
														warpPedIntoVehicle(p, getPedOccupiedVehicle(player), i)
														stat[p]["inveh"] = true
														break;
													end
												end
												stat[p]["enterveh"] = false
											end
										end, 2000, 1)
									end
								else
									if(stat[p]["inveh"] == true) and (stat[p]["enterveh"] == false) and(isPedInVehicle(player) == false) then -- er ist nicht im auto aber ich bin es
										stat[p]["enterveh"] = true
										triggerClientEvent(getRootElement(), "doPedExitVeh", player, p, true)
										setTimer(function()
											removePedFromVehicle(p)
											stat[p]["enterveh"] = false
											stat[p]["inveh"] = false
										end, 1000, 1)
									end
								end
								-- JUMP CHECK  --
								if(inveh == false) then
									if((z-z2) > 0.8) and (getDistanceBetweenPoints3D(x, y, z, x2, y2, z2) < 4) and (stat[p]["jumping"] ~= true) then -- er ist oben
										stat[p]["jumping"] = true
										setPedAnimation(p)
										triggerClientEvent(getRootElement(), "doPedJump", player, p, true)
										if(isTimer(timer[p]["jump"])) then killTimer(timer[p]["jump"]) end
										timer[p]["jump"] = setTimer(function()
											stat[p]["jumping"] = false
											triggerClientEvent(getRootElement(), "doPedJump", player, p, false)
										end, 800, 1)
									end
								end
							else
								if (stat[p]["running"] == true)then
									stat[p]["running"] = false
									setPedAnimation(p)
								end
							end
						else
							destroyElement(p)
						end
					end
				end
			end
		else
			if(isElement(p)) then
				destroyElement(p)
			end
			p = nil
		end
	end
end

setTimer(functionscheck, 200, 0)

addCommandHandler("k9", function(p, command, name)
	local t = getElementData(resourceRoot, "dogs:table")
	local player = string.gsub(getPlayerName(p), "_", " ")
	local allow = false
	for k, v in pairs(t) do
		if v["charactername"] == player then
			allow = true
			break
		end
	end
	if not allow then return false end
	if(ablauf[p] == true) then
		destroyElement(ped[p])
		ablauf[p] = false
		return
	end
	ablauf[p] = true
	local x, y, z = getElementPosition(p)
	local dim = getElementDimension(p)
	local int = getElementInterior(p)
	ped[p] = createPed(300, x, y+1, z)
	setElementDimension(ped[p], dim)
	setElementInterior(ped[p], int)
	setElementData(ped[p], "besitzer", getPlayerName(p))
	setElementData(ped[p], "bodyguard", true)
	setElementData(ped[p], "k9:status", 1) -- 2 = attacking, 1 = following, 0 = holding
	setElementData(ped[p], "k9:sits", false)
	setPedStat (ped[p], 72, 999)
	setPedStat (ped[p], 76, 999)
	setPedStat (ped[p], 74, 999)
	setElementData(ped[p], "rpp.npc.type", "k9")
	setElementData(ped[p], "name", name or "Dog")
	setElementData(ped[p], "nametag", true)
	--addEventHandler("onClientPedDamage", ped, on_damage_check)
	addEventHandler("onPedWasted", ped[p], function()
		local ped = source
		setTimer(destroyElement, 1000, 1, ped)
		ablauf[p] = false

	end)
end)

addCommandHandler("k9status", function (p)
	if not ped[p] then return false end
	local t = getElementData(resourceRoot, "dogs:table")
	local name = string.gsub(getPlayerName(p), "_", " ")
	local allow = false
	for k, v in pairs(t) do
		if v["charactername"] == name then
			allow = true
			break
		end
	end
	if not allow then return false end
	local currentStatus = getElementData(ped[p], "k9:status")
	if currentStatus == 1 then
		setElementData(ped[p], "k9:status", 0)
		setElementData(ped[p], "k9:sits", false)
		outputChatBox("The dog is now holding.", p)
	elseif currentStatus == 0 then
		setElementData(ped[p], "k9:status", 1)
		outputChatBox("The dog is now following you.", p)
	else
		setElementData(ped[p], "k9:status", 1)
		setElementData(ped[p], "k9:sits", false)
		outputChatBox("The dog is now following you.", p)
	end
end)

addCommandHandler("k9attack", function (p, cmd, target)
	if not ped[p] then return false end

	local t = getElementData(resourceRoot, "dogs:table")
	local name = string.gsub(getPlayerName(p), "_", " ")
	local allow = false
	for k, v in pairs(t) do
		if v["charactername"] == name and tonumber(v["attack"]) == 1 then
			allow = true
			break
		end
	end
	if not allow then return false end


	local state = getElementData(ped[p], "k9:status")
	if state == 2 then
		setElementData(ped[p], "k9:status", 1)
		setElementData(ped[p], "k9:sits", false)
		outputChatBox("The dog is now following you.", p)
		return
	end

	if not target then
		outputChatBox("SYNTAX: /"..cmd.." [target]", p)
		return
	end

	local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(p, target)

	if isElement(targetPlayer) then
		local x,y,z = getElementPosition(ped[p])
		local tx,ty,tz = getElementPosition(targetPlayer)
		if getDistanceBetweenPoints3D(x,y,z,tx,ty,tz) > 500 then
			outputChatBox("Your dog fails to spot a target.",p)
			triggerEvent("sendAme", ped[p], "looks around obviously seeming confused.")
			return false
		end

		setElementData(ped[p], "k9:status", 2)
		setElementData(ped[p], "k9:target", targetPlayer)
		outputChatBox("The dog is now against "..targetPlayerName, p)
	else
		outputChatBox("No player found.", p, 255, 0, 0)
	end
end)

function resetK9()
	local p = source
	if(ablauf[p] == true) then
		destroyElement(ped[p])
		ablauf[p] = false
		return
	end
end

addEventHandler( "onPlayerQuit", getRootElement(), resetK9 )
addEventHandler( "savePlayer", getRootElement(),
	function( reason )
		if reason == "Change Character" then
			resetK9()
		end
	end
)
