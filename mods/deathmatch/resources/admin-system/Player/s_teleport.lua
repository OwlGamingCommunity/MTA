local locs = {}

function canViewTPS(thePlayer)
    -- groups who can open /tps
    if exports.integration:isPlayerSupporter(thePlayer) or exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) or exports.integration:isPlayerVCTMember(thePlayer) then
        return true
    else
        return false
    end
end

function canManageTPS(thePlayer)
    -- groups who can manage (add, delete) /tps
    -- same definition as checkElementUse()
    if exports.integration:isPlayerLeadAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) then
        return true
    else
        return false
    end
end

function updateLocationData()
    locs = {}
    local locations = exports.mysql:query("SELECT `id`, `location_value`, `location_description`, `posX`, `posY`, `posZ`, `rot`, `int`, `dim`, `location_creator` FROM `admin_teleports`")
    while true do
        local r = exports.mysql:fetch_assoc(locations)
        if not r then
            break
        end

        locs[r.location_value] = r
    end
end
addEventHandler("onResourceStart", resourceRoot, updateLocationData)

function checkLocationDuplication(loc)
    local check = exports.mysql:query_fetch_assoc("SELECT `location_value` FROM `admin_teleports` WHERE `location_value`='"..exports.global:toSQL(loc).."'")

    if check and check["location_value"] == tostring(loc) then
        return true
    else
        return false
    end
end

function openLocationManager(thePlayer)
    if canViewTPS(thePlayer) then
        triggerClientEvent(thePlayer, "client:openLocationManager", thePlayer, locs)
    else
        return nil
    end
end
addEvent("server:openLocationManager", true)
addEventHandler("server:openLocationManager", root, openLocationManager)
addCommandHandler("tps", openLocationManager)

function addNewLocation(thePlayer, newValue, newDesc)
    if canManageTPS(thePlayer) then
        if not newValue or not newDesc then
            return nil
        else
            newValue = string.upper(tostring(newValue)) -- prevent duplications, looks more neat
        end

        if string.len(newValue) >= 10 or string.len(newDesc) >= 25 then
            -- should have already been detected anyway
            return nil
        end

        local isDuplicate = checkLocationDuplication(newValue)
        if isDuplicate then
            exports.hud:sendBottomNotification(thePlayer, "Location Manager", tostring(newValue) .. " is already marked! Try a different name.")
            return nil
        end

        local x, y, z = getElementPosition(thePlayer)
        local rx, ry, rz = getElementRotation(thePlayer)
        local dimension, interior = getElementDimension(thePlayer), getElementInterior(thePlayer)

        local accountID = getElementData(thePlayer, "account:id")

        local newValue = exports.mysql:escape_string(newValue)
        local newDesc = exports.mysql:escape_string(newDesc)

        if exports.mysql:query_free("INSERT INTO `admin_teleports` SET `location_value`='"..newValue.."', `location_description`='"..newDesc.."', `location_creator`='"..accountID.."', `posX`='"..x.."', `posY`='"..y.."', `posZ`='"..z.."', `rot`='"..rz.."', `int`='"..interior.."', `dim`='"..dimension.."'") then
            exports.hud:sendBottomNotification(thePlayer, "Location Manager", "You added "..newValue.." as a teleport location successfully.")
            updateLocationData()
        else
            outputChatBox("ERROR: An error occured when trying to update database. Contact a scripter with reference code #ASTP_S3", thePlayer, 255, 0, 0)
        end
    end
end
addEvent("addNewLocation", true)
addEventHandler("addNewLocation", root, addNewLocation)

function deleteLocation(thePlayer, id)
    if canManageTPS(thePlayer) then
        if not id and not tonumber(id) then
            return nil
        end

        local loc = exports.mysql:query_fetch_assoc("SELECT `location_value` FROM `admin_teleports` WHERE `id`='"..id.."'")

        if not loc or not loc["location_value"] or not checkLocationDuplication(loc["location_value"]) then
            exports.hud:sendBottomNotification(thePlayer, "Location Manager", "The row selected does not exist in the database or has already been deleted.")
            return nil
        end

        if exports.mysql:query_free("DELETE FROM `admin_teleports` WHERE `id`='"..id.."'") then
            exports.hud:sendBottomNotification(thePlayer, "Location Manager", "You have deleted location "..loc["location_value"].." successfully.")
            updateLocationData()
        else
            outputChatBox("ERROR: A mysql error happened. Contact a scripter with error code: #ADMTP02", thePlayer, 255, 0, 0)
        end
    end
end
addEvent("deleteLocation", true)
addEventHandler("deleteLocation", root, deleteLocation)

-- Teleport to location

function teleportToLocation(thePlayer, commandName, target, optionalPlayer)
    if (exports.integration:isPlayerTrialAdmin(thePlayer) or
            exports.integration:isPlayerSupporter(thePlayer) or
            exports.integration:isPlayerScripter(thePlayer) or
            exports.integration:isPlayerVehicleConsultant(thePlayer)) then
        if not (target) then
			outputChatBox("SYNTAX: /" .. commandName .. " [place] [player to teleport (optional)]", thePlayer, 255, 194, 14)
            outputChatBox("All /gotoplace locations can be viewed in /tps.", thePlayer, 255, 194, 14)
			triggerEvent("showPlaces", root, thePlayer)
		elseif not optionalPlayer and target then
			local target = string.upper(tostring(target))
            if locs[target] then
                locVal = locs[target]["location_value"]
                locDesc = locs[target]["location_description"]
                locCreator = locs[target]["location_creator"]
                locX = locs[target]["posX"]
                locY = locs[target]["posY"]
                locZ = locs[target]["posZ"]
                locRotate = locs[target]["rot"]
                locInt = locs[target]["int"]
                locDim = locs[target]["dim"]
                outputChatBox("You have teleported to " .. tostring(locVal) .. ".", thePlayer, 0, 255, 0)
                if (isPedInVehicle(thePlayer)) then
					local veh = getPedOccupiedVehicle(thePlayer)
					setElementAngularVelocity(veh, 0, 0, 0)
					setElementPosition(veh, locX, locY, locZ)
					setVehicleRotation(veh, 0, 0, locRotate)
					setTimer(setElementAngularVelocity, 50, 20, veh, 0, 0, 0)

					setElementDimension(veh, locDim)
					setElementInterior(veh, locInt)

					setElementDimension(thePlayer, locDim)
					setElementInterior(thePlayer, locInt)
					setCameraInterior(thePlayer, locInt)
				else
					detachElements(thePlayer)
					setElementPosition(thePlayer, locX, locY, locZ)
					setPedRotation(thePlayer, locRotate)
					setElementDimension(thePlayer, locDim)
					setCameraInterior(thePlayer, locInt)
					setElementInterior(thePlayer, locInt)
				end
			else
				outputChatBox("Invalid location entered, see /tps for /gotoplace locations.", thePlayer, 255, 0, 0)
			end
		elseif optionalPlayer and target then
			local target = string.upper(tostring(target))
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, optionalPlayer)
			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				if (logged==0) then
					outputChatBox("Player is not logged in!", thePlayer, 255, 0 , 0)
				elseif locs[target] then
                    locVal = locs[target]["location_value"]
                    locDesc = locs[target]["location_description"]
                    locCreator = locs[target]["location_creator"]
                    locX = locs[target]["posX"]
                    locY = locs[target]["posY"]
                    locZ = locs[target]["posZ"]
                    locRotate = locs[target]["rot"]
                    locInt = locs[target]["int"]
                    locDim = locs[target]["dim"]
					outputChatBox("You have been teleported to "..tostring(locVal).." by "..exports.global:getPlayerFullIdentity(thePlayer)..".", targetPlayer, 255, 194, 14)
					outputChatBox("You have teleported "..exports.global:getPlayerFullIdentity(targetPlayer).." to "..tostring(locVal)..".", thePlayer, 255, 194, 14)
					if (isPedInVehicle(targetPlayer)) then
						local veh = getPedOccupiedVehicle(targetPlayer)
						setElementAngularVelocity(veh, 0, 0, 0)
						setElementPosition(veh, locX, locY, locZ)
						setVehicleRotation(veh, 0, 0, locRotate)
						setTimer(setElementAngularVelocity, 50, 20, veh, 0, 0, 0)

						setElementDimension(veh, locDim)
						setElementInterior(veh, locInt)

						setElementDimension(targetPlayer, locDim)
						setElementInterior(targetPlayer, locInt)
						setCameraInterior(targetPlayer, locInt)
					else
						detachElements(targetPlayer)
						setElementPosition(targetPlayer, locX, locY, locZ)
						setPedRotation(targetPlayer, locRotate)
						setElementDimension(targetPlayer, locDim)
						setCameraInterior(targetPlayer, locInt)
						setElementInterior(targetPlayer, locInt)
					end
				else
					outputChatBox("Invalid location entered, see /places for help.", thePlayer, 255, 0, 0)
				end
			end
		else
			outputChatBox("ERROR: Contact a scripter with code #T97sA", thePlayer, 255)
		end
	end
end
addCommandHandler("gotoplace", teleportToLocation, false, false)

----------------------------[GO TO PLAYER]---------------------------------------
function gotoPlayer(thePlayer, commandName, target)
	if exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer) or exports.integration:isPlayerScripter(thePlayer) or exports.integration:isPlayerVCTMember(thePlayer) or exports.integration:isPlayerMappingTeamMember(thePlayer) then
		if commandName:lower() == "goto" then
			if not (target) then
				outputChatBox("SYNTAX: /" .. commandName .. " [Partial Player Nick]", thePlayer, 255, 194, 14)
			else
				local username = getPlayerName(thePlayer)
				local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, target)
				
				if targetPlayer then
					local logged = getElementData(targetPlayer, "loggedin")
					
					if (logged==0) then
						outputChatBox("Player is not logged in.", thePlayer, 255, 0 , 0)
					else
						detachElements(thePlayer)
						local x, y, z = getElementPosition(targetPlayer)
						local interior = getElementInterior(targetPlayer)
						local dimension = getElementDimension(targetPlayer)
						local r = getPedRotation(targetPlayer)
						
						-- Maths calculations to stop the player being stuck in the target
						x = x + ( ( math.cos ( math.rad ( r ) ) ) * 2 )
						y = y + ( ( math.sin ( math.rad ( r ) ) ) * 2 )
						
						-- Only allow MT members to TP to people who are on the report they're handling.
						if not (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) or exports.integration:isPlayerVCTMember(thePlayer)) and (exports.integration:isPlayerMappingTeamMember(thePlayer)) then
                            local reporter = exports['report']:grabReporter(getPlayerName(thePlayer))
                            if isPedInVehicle(thePlayer) then
                                outputChatBox("You cannot be in a vehicle when using this command.", thePlayer, 255, 0, 0)
                                return 
                            end

                            if targetPlayer ~= reporter then
                                outputChatBox("You can only teleport to the reporting player.", thePlayer, 255, 0, 0)
                                return
                            end

                            setElementPosition(thePlayer, x, y, z)
                            setElementInterior(thePlayer, interior)
                            setElementDimension(thePlayer, dimension)
                            outputChatBox(username.." has teleported to you.", targetPlayer)
                            return 
                        end
						
						setCameraInterior(thePlayer, interior)
						
						if (isPedInVehicle(thePlayer)) then
							local veh = getPedOccupiedVehicle(thePlayer)
							setElementAngularVelocity(veh, 0, 0, 0)
							setElementInterior(thePlayer, interior)
							setElementDimension(thePlayer, dimension)
							setElementInterior(veh, interior)
							setElementDimension(veh, dimension)
							setElementPosition(veh, x, y, z + 1)
							warpPedIntoVehicle ( thePlayer, veh ) 
							setTimer(setElementAngularVelocity, 50, 20, veh, 0, 0, 0)
						elseif getElementData(thePlayer, "recontp") then
							triggerClientEvent(thePlayer, "recon:goto", thePlayer, x, y, z, interior, dimension, r)
						else
							setElementPosition(thePlayer, x, y, z)
							setElementInterior(thePlayer, interior)
							setElementDimension(thePlayer, dimension)
						end
						outputChatBox(" You have teleported to player " .. targetPlayerName .. ".", thePlayer)
						
						if exports.integration:isPlayerSupporter(thePlayer) then
							outputChatBox(" Supporter " .. username .. " has teleported to you. ", targetPlayer)
						else
							local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
							if hiddenAdmin == 0 then
								outputChatBox(" Admin " .. username .. " has teleported to you. ", targetPlayer)
							end
						end
					end
				end
			end
		else
			local username = getPlayerName(thePlayer)
			local logged = getElementData(target, "loggedin")	
			if (logged==0) then
				outputChatBox("Player is not logged in.", thePlayer, 255, 0 , 0)
			else
				detachElements(thePlayer)
				local x, y, z = getElementPosition(target)
				local interior = getElementInterior(target)
				local dimension = getElementDimension(target)
				local r = getPedRotation(target)
				
				-- Maths calculations to stop the player being stuck in the target
				x = x + ( ( math.cos ( math.rad ( r ) ) ) * 2 )
				y = y + ( ( math.sin ( math.rad ( r ) ) ) * 2 )
				
				setCameraInterior(thePlayer, interior)
				
				if (isPedInVehicle(thePlayer)) then
					local veh = getPedOccupiedVehicle(thePlayer)
					setElementAngularVelocity(veh, 0, 0, 0)
					setElementInterior(thePlayer, interior)
					setElementDimension(thePlayer, dimension)
					setElementInterior(veh, interior)
					setElementDimension(veh, dimension)
					setElementPosition(veh, x, y, z + 1)
					warpPedIntoVehicle ( thePlayer, veh ) 
					setTimer(setElementAngularVelocity, 50, 20, veh, 0, 0, 0)
				else
					setElementPosition(thePlayer, x, y, z)
					setElementInterior(thePlayer, interior)
					setElementDimension(thePlayer, dimension)
				end
				outputChatBox(" You have accepted teleport request from " .. getPlayerName(target):gsub("_", " ") .. ".", thePlayer)
				
				if exports.integration:isPlayerSupporter(thePlayer) then
					outputChatBox(" Supporter " .. username .. " has accepted your teleport request. ", target)
				else
					outputChatBox(" Admin " .. username .. " has accepted your teleport request.", target)
				end
			end
		end
	end
end
addCommandHandler("goto", gotoPlayer, false, false)

function getPlayer(thePlayer, commandName, from, to)
	if exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer) or exports.integration:isPlayerScripter(thePlayer) or exports.integration:isPlayerVCTMember(thePlayer) then
		if(not from or not to) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Sending Player] [To Player]", thePlayer, 255, 194, 14)
		else
			local admin = getPlayerName(thePlayer):gsub("_"," ")
			local fromplayer, targetPlayerName1 = exports.global:findPlayerByPartialNick(thePlayer, from)
			local toplayer, targetPlayerName2 = exports.global:findPlayerByPartialNick(thePlayer, to)

			if(fromplayer and toplayer) then
				local logged1 = getElementData(fromplayer, "loggedin")
				local logged2 = getElementData(toplayer, "loggedin")

				if(not logged1 or not logged2) then
					outputChatBox("At least one of the players is not logged in.", thePlayer, 255, 0 , 0)
				else

					local playerAdmLvl = getElementData( thePlayer, "admin_level" ) or 0
					local targetAdmLvl = getElementData( fromplayer, "admin_level" ) or 0
					if (playerAdmLvl < targetAdmLvl) then
						outputChatBox("Sending "..targetPlayerName.." teleporting request as they're higher rank than you.", thePlayer, 255, 194, 14)
						outputChatBox(getPlayerName(thePlayer):gsub("_", " ").." wants to teleport you to them. /atp to accept, /dtp to deny.", targetPlayer, 255, 194, 14)
						setElementData(targetPlayer, "teleport:targetPlayer", thePlayer)
						return
					end

					detachElements(fromplayer)
					local x, y, z = getElementPosition(toplayer)
					local interior = getElementInterior(toplayer)
					local dimension = getElementDimension(toplayer)
					local r = getPedRotation(toplayer)

					-- Maths calculations to stop the target being stuck in the player
					x = x + ( ( math.cos ( math.rad ( r ) ) ) * 2 )
					y = y + ( ( math.sin ( math.rad ( r ) ) ) * 2 )

					if (isPedInVehicle(fromplayer)) then
						local veh = getPedOccupiedVehicle(fromplayer)
						setElementAngularVelocity(veh, 0, 0, 0)
						setElementPosition(veh, x, y, z + 1)
						setTimer(setElementAngularVelocity, 50, 20, veh, 0, 0, 0)
						setElementInterior(veh, interior)
						setElementDimension(veh, dimension)

					else
						setElementPosition(fromplayer, x, y, z)
						setElementInterior(fromplayer, interior)
						setElementDimension(fromplayer, dimension)
					end

					outputChatBox(" You have teleported player " .. targetPlayerName1:gsub("_"," ") .. " to " .. targetPlayerName2:gsub("_"," ") .. ".", thePlayer)

					local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
					if hiddenAdmin == 0 then
						outputChatBox(" An admin " .. admin .. " has teleported you to " .. targetPlayerName2:gsub("_"," ") .. ". ", fromplayer)
						outputChatBox(" An admin " .. admin .. " has teleported " .. targetPlayerName1:gsub("_"," ") .. " to you.", toplayer)
					else
						outputChatBox(" An hidden admin has teleported you to " .. targetPlayerName2:gsub("_"," ") .. ". ", fromplayer)
						outputChatBox(" An hidden admin has teleported " .. targetPlayerName1:gsub("_"," ") .. " to you.", toplayer)
					end
				end
			end
		end
	end
end
addCommandHandler("sendto", getPlayer, false, false)

----------------------------[GET PLAYER HERE]---------------------------------------
function getPlayer(thePlayer, commandName, target)
	if exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer) or exports.integration:isPlayerScripter(thePlayer) then
		if not target then
			outputChatBox("SYNTAX: /" .. commandName .. " /gethere [Partial Player Nick]", thePlayer, 255, 194, 14)
		else
			local username = getPlayerName(thePlayer)
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, target)
			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0 , 0)
				else
					local playerAdmLvl = getElementData( thePlayer, "admin_level" ) or 0
					local targetAdmLvl = getElementData( targetPlayer, "admin_level" ) or 0
					if (playerAdmLvl < targetAdmLvl) then
						outputChatBox("Sending "..targetPlayerName.." teleporting request as they're higher rank than you.", thePlayer, 255, 194, 14)
						outputChatBox(getPlayerName(thePlayer):gsub("_", " ").." wants to teleport you to them. /atp to accept, /dtp to deny.", targetPlayer, 255, 194, 14)
						setElementData(targetPlayer, "teleport:targetPlayer", thePlayer)
						return
					end

					detachElements(targetPlayer)
					local x, y, z = getElementPosition(thePlayer)
					local interior = getElementInterior(thePlayer)
					local dimension = getElementDimension(thePlayer)
					local r = getPedRotation(thePlayer)
					setCameraInterior(targetPlayer, interior)

					-- Maths calculations to stop the target being stuck in the player
					x = x + ( ( math.cos ( math.rad ( r ) ) ) * 2 )
					y = y + ( ( math.sin ( math.rad ( r ) ) ) * 2 )

					if (isPedInVehicle(targetPlayer)) then
						local veh = getPedOccupiedVehicle(targetPlayer)
						setElementAngularVelocity(veh, 0, 0, 0)
						setElementPosition(veh, x, y, z + 1)
						setTimer(setElementAngularVelocity, 50, 20, veh, 0, 0, 0)
						setElementInterior(veh, interior)
						setElementDimension(veh, dimension)

					else
						setElementPosition(targetPlayer, x, y, z)
						setElementInterior(targetPlayer, interior)
						setElementDimension(targetPlayer, dimension)
					end
					outputChatBox(" You have teleported player " .. targetPlayerName .. " to you.", thePlayer)

					if exports.integration:isPlayerSupporter(thePlayer) then
						outputChatBox(" Supporter " .. username .. " has teleported you to them. ", targetPlayer)
					else
						local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
						if hiddenAdmin == 0 then
							outputChatBox(" Admin " .. username .. " has teleported you to them. ", targetPlayer)
						end
					end

				end
			end
		end
	end
end
addCommandHandler("gethere", getPlayer, false, false)

function acceptTeleport(thePlayer)
	local targetPlayer = false
	targetPlayer = getElementData(thePlayer, "teleport:targetPlayer")
	if not targetPlayer then
		outputChatBox("You don't have any teleport request pending.",thePlayer,255,0,0)
	else
		gotoPlayer(thePlayer, "LOL" , targetPlayer)
		removeElementData(thePlayer, "teleport:targetPlayer")
	end
end
addCommandHandler("atp", acceptTeleport, false, false)

function denyTeleport(thePlayer)
	local targetPlayer = false
	targetPlayer = getElementData(thePlayer, "teleport:targetPlayer")
	if not targetPlayer then
		outputChatBox("You don't have any teleport request pending.",thePlayer,255,0,0)
	else
		outputChatBox(" You have deny teleport request from " .. getPlayerName(targetPlayer):gsub("_", " ").. ".", thePlayer)
		outputChatBox(" "..getPlayerName(thePlayer):gsub("_", " ").." has deny your teleport request.", targetPlayer)
		removeElementData(thePlayer, "teleport:targetPlayer")
	end
end
addCommandHandler("dtp", denyTeleport, false, false)

local teleportLocations = {
	-- 			x					y					z			int dim	rot
	ls = { 1479.9873046875, -1710.9453125, 13.36874961853, 	0, 	0,	0	},
	sf = { -1988.5693359375, 507.0029296875, 35.171875,	0, 	0,	90	},
	sfia = { -1689.0689697266, 	-536.7919921875, 	14.254997, 	0, 	0,	252	},
	lv = { 1691.6801757813, 	1449.1293945313, 	10.765375,	0, 	0,	268	},
	pc = { 2253.66796875, 		-85.0478515625, 	28.086093,	0, 	0,	180	},
	--bank = { 596.82421875, -1245.7109375, 18.19867515564, 0, 0, 24 }, old bank
	bank = { 1570.4228515625, -1337.3984375, 16.484375, 0, 0, 180 },
	cityhall = { 1481.578125, -1768.6279296875, 18.795755386353, 0, 0, 3 },
	crusher = { 2438.7314453125, -2092.6240234375, 13.546875, 0, 0, 267 },
	--dmv = {  -1978.2578125, 440.484375, 35.171875,  0,  0,  90 },
	bayside = {  -2620.103515625, 2271.232421875, 8.1442451477051, 0, 0, 360 },
	sfpd = {  -1607.71875, 722.9853515625, 12.368106842041, 0, 0, 360 },
	igs = {  1968.3681640625, -1764.0224609375, 13.546875, 0, 0, 120 },
	lsia = { 1967.7998046875, -2180.470703125, 13.546875, 0, 0, 165 },
	ash = { 1178.9794921875, -1324.212890625, 14.146828651428, 0, 0, 268 },
	dmv = { 1094.306640625, -1791.857421875, 13.617427825928, 0, 0, 255 },
	lstr = {  2668.1298828125, -2554.9990234375, 13.614336013794, 0, 0, 180 },
	vgs = { 996.34375, -920.4052734375, 42.1796875, 0, 0, 6 },
}

------------- [gotoMark]
addEvent( "gotoMark", true )
addEventHandler( "gotoMark", getRootElement( ),
	function( x, y, z, interior, dimension, name )
		if type( x ) == "number" and type( y ) == "number" and type( z ) == "number" and type( interior ) == "number" and type( dimension ) == "number" then
			if getElementData ( client, "loggedin" ) == 1 and ( exports.integration:isPlayerTrialAdmin(client) or exports.integration:isPlayerSupporter(client) or exports.integration:isPlayerVehicleConsultant( client ) or exports.integration:isPlayerMappingTeamMember( clientclient ) or exports.integration:isPlayerScripter(client)) then
				local vehicle = nil
				local seat = nil

				if(isPedInVehicle ( client )) then
					 vehicle =  getPedOccupiedVehicle ( client )
					seat = getPedOccupiedVehicleSeat ( client )
				end
				detachElements(client)

				if(vehicle and (seat ~= 0)) then
					removePedFromVehicle (client )
					exports.anticheat:changeProtectedElementDataEx(client, "realinvehicle", 0, false)
					setElementPosition(client, x, y, z)
					setElementInterior(client, interior)
					setElementDimension(client, dimension)
				elseif(vehicle and seat == 0) then
					removePedFromVehicle (client )
					exports.anticheat:changeProtectedElementDataEx(client, "realinvehicle", 0, false)
					setElementPosition(vehicle, x, y, z)
					setElementInterior(vehicle, interior)
					setElementDimension(vehicle, dimension)
					warpPedIntoVehicle ( client, vehicle, 0)
				else
					setElementPosition(client, x, y, z)
					setElementInterior(client, interior)
					setElementDimension(client, dimension)
				end

				outputChatBox( "Teleported to Mark" .. ( name and " '" .. name .. "'" or "" ) .. ".", client, 0, 255, 0 )
			end
		end
	end
)

function osendtoLS(thePlayer, commandName, ...)
	if exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer) or exports.integration:isPlayerScripter(thePlayer) then
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [exact character name]", thePlayer, 255, 0, 0)
		else
			local character = table.concat({...}, "_")
			if getPlayerFromName(character) then
				kickPlayer(getPlayerFromName(character), "Character Location Change")
			end

			local result = mysql:query_fetch_assoc("SELECT id, account FROM characters WHERE charactername='" .. mysql:escape_string(character) .. "'")
			local charid = tonumber(result["id"])
			local account = tonumber(result["account"])
            if charid then
            mysql:query_free("UPDATE characters SET x=1520.0029296875, y=-1701.2421875, z=13.546875, rotation=275.00024414063, interior_id=0, dimension_id=0 WHERE id = " .. mysql:escape_string(charid) )
            outputChatBox("Player offline sent to Pershing Square.", thePlayer, 0, 255, 0)
            else
            outputChatBox("Player not found.", thePlayer, 255, 0, 0)
            end
        end
    end
end
addCommandHandler("osendtols", osendtoLS, false, false)