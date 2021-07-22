--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

function getNearbyInteriors(thePlayer, commandName)
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerMappingTeamMember(thePlayer)) then
		local posX, posY, posZ = getElementPosition(thePlayer)
		local dimension = getElementDimension(thePlayer)
		outputChatBox("Nearby Interiors:", thePlayer, 255, 126, 0)
		local count = 0
		local possibleInteriors = exports.pool:getPoolElementsByType('interior')
		for _, interior in ipairs(possibleInteriors) do
			local interiorEntrance = getElementData(interior, "entrance")
			local interiorExit = getElementData(interior, "exit")

			for _, point in ipairs( { interiorEntrance, interiorExit } ) do
				if (point.dim == dimension) then
					local distance = getDistanceBetweenPoints3D(posX, posY, posZ, point.x, point.y, point.z)
					if (distance <= 11) then
						local dbid = getElementData(interior, "dbid")
						local interiorName = getElementData(interior, "name")
						outputChatBox(" ID " .. dbid .. ": " .. interiorName, thePlayer, 255, 126, 0)
						count = count + 1
					end
				end
			end
		end

		if (count==0) then
			outputChatBox("   None.", thePlayer, 255, 126, 0)
		end
	end
end
addCommandHandler("nearbyinteriors", getNearbyInteriors, false, false)
addCommandHandler("nearbyints", getNearbyInteriors, false, false)

function delNearbyInteriors(thePlayer, commandName)
	if exports.integration:isPlayerAdmin( thePlayer ) then
		local posX, posY, posZ = getElementPosition(thePlayer)
		local dimension = getElementDimension(thePlayer)
		outputChatBox("Deleting Nearby Interiors:", thePlayer, 255, 126, 0)
		local count = 0
		local possibleInteriors = exports.pool:getPoolElementsByType('interior')
		for _, interior in ipairs(possibleInteriors) do
			local interiorEntrance = getElementData(interior, "entrance")
			local interiorExit = getElementData(interior, "exit")

			for _, point in ipairs( { interiorEntrance, interiorExit } ) do
				if (point.dim == dimension) then
					local distance = getDistanceBetweenPoints3D(posX, posY, posZ, point.x, point.y, point.z)
					if (distance <= 6) then
						local dbid = getElementData(interior, "dbid")
						local interiorName = getElementData(interior, "name")
						if deleteInterior(thePlayer, "mass" , dbid) then
							exports.logs:dbLog(thePlayer, 37, { "in"..tostring(dbid) } , commandName)
							count = count + 1
						end
					end
				end
			end
		end
		exports.anticheat:changeProtectedElementDataEx(thePlayer, "interiormarker", false, false, false)

		if (count==0) then
			outputChatBox("   None was deleted", thePlayer, 255, 126, 0)
		else
			outputChatBox("   "..count.." interiors have been deleted!", thePlayer, 255, 126, 0)
		end
	end
end
addCommandHandler("delnearbyinteriors", delNearbyInteriors, false, false)
addCommandHandler("delnearbyints", delNearbyInteriors, false, false)

function gotoHouse( thePlayer, commandName, houseID, target )
	if exports.integration:isPlayerTrialAdmin( thePlayer ) or exports.integration:isPlayerSupporter(thePlayer) or exports.integration:isPlayerMappingTeamMember(thePlayer) then
		local houseID = tonumber( houseID )
		if not houseID then
			outputChatBox( "SYNTAX: /" .. commandName .. " [House/Biz ID] (Player)", thePlayer, 255, 194, 14 )
		else
			local dbid, entrance, exit, type, interiorElement = findProperty( thePlayer, houseID )
			if entrance then
				if target then
					targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, target)
					if targetPlayer and getElementData(targetPlayer, "loggedin") == 1 then
						local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
						local adminUsername = getElementData(thePlayer, "account:username")

						setPlayerInsideInterior(interiorElement, targetPlayer, entrance, (getElementDimension(targetPlayer) == 0) or false)
						outputChatBox("You sent " .. targetPlayerName .. " to house #" .. houseID, thePlayer, 231, 217, 176)
						outputChatBox("You were sent to house #" .. houseID .. " by " .. adminTitle .. " " .. adminUsername ..".", targetPlayer, 231, 217, 176)

						exports["interior-manager"]:addInteriorLogs(dbid, commandName, targetPlayer)
						exports.logs:dbLog(thePlayer, 37, { "in"..tostring(dbid), targetPlayer } , commandName )
						return true
					else
						outputChatBox("No player found.", thePlayer, 255, 0, 0)
						return
					end
				else
					setPlayerInsideInterior(interiorElement, thePlayer, entrance, (getElementDimension(thePlayer) == 0) or false)
					outputChatBox( "Teleported to House #" .. houseID, thePlayer, 0, 255, 0 )

					exports["interior-manager"]:addInteriorLogs(dbid, commandName, thePlayer)
					exports.logs:dbLog(thePlayer, 37, { "in"..tostring(dbid) } , commandName)
					return true
				end
			else
				outputChatBox( "Invalid House.", thePlayer, 255, 0, 0 )
				return false
			end
		end
	end
end
addCommandHandler( "gotohouse", gotoHouse )
addCommandHandler( "gotoint", gotoHouse )

function gotoHouseInside( thePlayer, commandName, houseID, target )
	if exports.integration:isPlayerTrialAdmin( thePlayer ) or exports.integration:isPlayerMappingTeamMember(thePlayer) then
		local houseID = tonumber( houseID )
		if not houseID then
			outputChatBox( "SYNTAX: /" .. commandName .. " [House/Biz ID] (Player)", thePlayer, 255, 194, 14 )
		else
			local dbid, entrance, exit, type, interiorElement = findProperty( thePlayer, houseID )
			if exit then
				if target then
					targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, target)
					if targetPlayer and getElementData(targetPlayer, "loggedin") == 1 then
						local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
						local adminUsername = getElementData(thePlayer, "account:username")

						setPlayerInsideInterior(interiorElement, targetPlayer, exit, (getElementDimension(targetPlayer) == dbid) or false)
						
						outputChatBox("You sent " .. targetPlayerName .. " inside house #" .. houseID, thePlayer, 231, 217, 176)
						outputChatBox("You were sent inside house #" .. houseID .. " by " .. adminTitle .. " " .. adminUsername ..".", targetPlayer, 231, 217, 176)

						exports["interior-manager"]:addInteriorLogs(dbid, commandName, targetPlayer)
						exports.logs:dbLog(thePlayer, 37, { "in"..tostring(dbid), targetPlayer } , commandName )
						return true
					else
						outputChatBox("No player found.", thePlayer, 255, 0, 0)
						return
					end
				else
					setPlayerInsideInterior(interiorElement, thePlayer, exit, (getElementDimension(thePlayer) == dbid) or false)
					
					exports["interior-manager"]:addInteriorLogs(dbid, commandName, thePlayer)
					exports.logs:dbLog(thePlayer, 37, { "in"..tostring(dbid) } , commandName)
					outputChatBox( "Teleported inside House #" .. houseID, thePlayer, 0, 255, 0 )
					return true
				end
			else
				outputChatBox( "Invalid House.", thePlayer, 255, 0, 0 )
				return
			end
		end
	end
end
addCommandHandler( "gotointi", gotoHouseInside )

function setInteriorID( thePlayer, commandName, interiorID )
	if exports.integration:isPlayerAdmin( thePlayer ) or exports.integration:isPlayerMappingTeamMember(thePlayer) then
		local interiors = exports["official-interiors"].getInteriorsList() --/MAXIME
		interiorID = tonumber( interiorID )
		if not interiorID then
			outputChatBox( "SYNTAX: /" .. commandName .. " [interior id] - changes the house interior", thePlayer, 255, 194, 14 )
		elseif not interiors[interiorID] then
			outputChatBox( "Invalid ID.", thePlayer, 255, 0, 0 )
			return false
		else
			local dbid, entrance, exit, _, intElement = findProperty( thePlayer )
			if exit then
				local interior = interiors[interiorID]
				local ix = interior[2]
				local iy = interior[3]
				local iz = interior[4]
				local optAngle = interior[5]
				local interiorw = interior[1]

				local query = mysql:query_free( "UPDATE interiors SET interior_id="..interiorID..", interior=" .. interiorw .. ", interiorx=" .. ix .. ", interiory=" .. iy .. ", interiorz=" .. iz .. ", angle=" .. optAngle .. " WHERE id=" .. dbid)
				if query then
					exports.anticheat:setEld(intElement, 'interior_id', interiorID, 'all')
					cleanupProperty(dbid)
					realReloadInterior(dbid)

					for key, value in pairs( exports.pool:getPoolElementsByType('player') ) do
						if isElement( value ) and getElementDimension( value ) == dbid then
							setElementPosition( value, ix, iy, iz )
							setElementInterior( value, interiorw )
							setCameraInterior( value, interiorw )
						end
					end

					outputChatBox( "You have sucessfully changed interior of house #"..dbid.." to ID "..interiorID..".", thePlayer, 0, 255, 0 )
					exports.logs:dbLog(thePlayer, 4, { "in"..tostring(dbid) } , "SETINTERIORID "..interiorID)
					local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
					local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
					local adminUsername = getElementData(thePlayer, "account:username")

					if hiddenAdmin == 0 then
						exports.global:sendMessageToAdmins("[INTERIOR]: "..adminTitle.." ".. getPlayerName(thePlayer):gsub("_", " ").." ("..adminUsername..") has changed interior of house #"..dbid.." to ID "..interiorID..".")
					else
						exports.global:sendMessageToAdmins("[INTERIOR]: A hidden admin has changed interior of house #"..dbid.." to ID "..interiorID..".")
					end

					exports["interior-manager"]:addInteriorLogs(dbid, commandName.." "..interiorID, thePlayer)

					return true
				else
					outputChatBox( "Interior Update failed.", thePlayer, 255, 0, 0 )
					return false
				end
			else
				outputChatBox( "You are not in an interior.", thePlayer, 255, 0, 0 )
				return false
			end
		end
	end
end
addCommandHandler( "setinteriorid", setInteriorID )
addCommandHandler( "setintid", setInteriorID )

function setInteriorPrice( thePlayer, commandName, cost )
	if exports.integration:isPlayerTrialAdmin( thePlayer ) or exports.integration:isPlayerMappingTeamMember(thePlayer) then
		cost = tonumber( cost )
		if not cost then
			outputChatBox( "SYNTAX: /" .. commandName .. " [price]", thePlayer, 255, 194, 14 )
		else
			local dbid, entrance, exit, interiorType, interiorElement = findProperty( thePlayer )
			if exit then
				local query = mysql:query_free("UPDATE interiors SET cost=" .. cost .. " WHERE id=" .. dbid)
				if query then
					local interiorStatus = getElementData(interiorElement, "status")
					interiorStatus.cost = cost
					exports.anticheat:changeProtectedElementDataEx(interiorElement, "status", interiorStatus, true)
					outputChatBox( "Interior cost is now $" .. exports.global:formatMoney(cost) .. ".", thePlayer, 0, 255, 0 )
					local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
					local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
					local adminUsername = getElementData(thePlayer, "account:username")

					if hiddenAdmin == 0 then
						exports.global:sendMessageToAdmins("[INTERIOR]: "..adminTitle.." ".. getPlayerName(thePlayer):gsub("_", " ").." ("..adminUsername..") has changed interior price of house #"..dbid.." to $"..cost..".")
					else
						exports.global:sendMessageToAdmins("[INTERIOR]: A hidden admin has changed interior price of house #"..dbid.." to $"..cost..".")
					end

					exports["interior-manager"]:addInteriorLogs(dbid, commandName.." "..tostring(cost), thePlayer)
					exports.logs:dbLog(thePlayer, 37, { "in"..tostring(dbid) } , commandName.." "..tostring(cost))
					return true
				else
					outputChatBox( "Interior Update failed.", thePlayer, 255, 0, 0 )
				end
			else
				outputChatBox( "You are not in an interior.", thePlayer, 255, 0, 0 )
			end
		end
	end
end
addCommandHandler( "setinteriorprice", setInteriorPrice )
addCommandHandler( "setintprice", setInteriorPrice )

function getInteriorPrice( thePlayer )
	if exports.integration:isPlayerTrialAdmin( thePlayer ) or exports.integration:isPlayerMappingTeamMember(thePlayer)  then
		local dbid, entrance, exit, interiorType, interiorElement = findProperty( thePlayer )
		if exit then
			local interiorStatus = getElementData(interiorElement, "status")
			outputChatBox( "This Interior costs $" .. exports.global:formatMoney(interiorStatus.cost) .. ".", thePlayer, 255, 194, 14 )
		else
			outputChatBox( "You are not in an interior.", thePlayer, 255, 0, 0 )
		end
	end
end
addCommandHandler( "getinteriorprice", getInteriorPrice )
addCommandHandler( "getintprice", getInteriorPrice )

function setInteriorType( thePlayer, commandName, type )
	if exports.integration:isPlayerTrialAdmin( thePlayer ) or exports.integration:isPlayerMappingTeamMember(thePlayer) then
		type = math.ceil( tonumber( type ) or -1 )
		if not type or type < 0 or type > 3 then
			outputChatBox( "SYNTAX: /" .. commandName .. " [type (0-3)]", thePlayer, 255, 194, 14 )
		else
			local dbid, entrance, exit, interiorType, interiorElement = findProperty( thePlayer )
			if exit then
				if type ~= interiorType then
					local query = mysql:query_free("UPDATE interiors SET type=" .. type .. " WHERE id='" .. mysql:escape_string(dbid) .."'")
					if query then
						local interiorStatus = getElementData(interiorElement, "status")
						interiorStatus.type = type
						outputChatBox( "Interior type is now " .. type .. ".", thePlayer, 0, 255, 0 )
						exports.logs:dbLog(thePlayer, 37, { "in"..tostring(dbid) } , "SETINTERIORTYPE "..type .. " (was "..interiorType.." / ".. interiorStatus.owner ..")")
						if type == 2 then
							local query2 = mysql:query_free("UPDATE interiors SET owner=0 WHERE id='" .. mysql:escape_string(dbid) .."'")
							if query2 then
								interiorStatus.owner = 0
								outputChatBox( "Set the interior type to no-one due interior type 2.", thePlayer, 0, 255, 0 )
							end
						end
						local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
						local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
						local adminUsername = getElementData(thePlayer, "account:username")

						if hiddenAdmin == 0 then
							exports.global:sendMessageToAdmins("[INTERIOR]: "..adminTitle.." ".. getPlayerName(thePlayer):gsub("_", " ").." ("..adminUsername..") has changed interior type of house #"..dbid.." to type "..type..".")
						else
							exports.global:sendMessageToAdmins("[INTERIOR]: A hidden admin has changed interior type of house #"..dbid.." to type "..type..".")
						end
						exports.anticheat:changeProtectedElementDataEx(interiorElement, "status", interiorStatus, true)

						exports["interior-manager"]:addInteriorLogs(dbid, commandName.." "..tostring(type), thePlayer)

						return true
					else
						outputChatBox( "Interior Update failed.", thePlayer, 255, 0, 0 )
					end
				else
					outputChatBox( "Interior has this type already.", thePlayer, 255, 0, 0 )
				end
			else
				outputChatBox( "You are not in an interior.", thePlayer, 255, 0, 0 )
			end
		end
	end
end
addCommandHandler( "setinteriortype", setInteriorType )
addCommandHandler( "setinttype", setInteriorType )

function getInteriorType( thePlayer )
	if exports.integration:isPlayerTrialAdmin( thePlayer ) or exports.integration:isPlayerMappingTeamMember(thePlayer) then
		local dbid, entrance, exit, interiorType, interiorElement = findProperty( thePlayer )
		if exit then
			outputChatBox( "This Interior's type is " .. interiorType .. ".", thePlayer, 255, 194, 14 )
		else
			outputChatBox( "You are not in an interior.", thePlayer, 255, 0, 0 )
		end
	end
end
addCommandHandler( "getinteriortype", getInteriorType )
addCommandHandler( "getinttype", getInteriorType )

function getInteriorID( thePlayer, commandName )
	local theId = nil
	local myDim = getElementDimension(thePlayer)
	if myDim > 0 then
		local theInterior = exports.pool:getElement('interior', myDim)
		theId = theInterior and getElementData(theInterior, 'interior_id') or nil
		if not theId then
			local interior = getElementInterior( thePlayer )
			local x, y, z = getElementPosition( thePlayer )
			local interiors = exports["official-interiors"]:getInteriorsList()
			for k, v in pairs( interiors ) do
				if interior == v[1] and getDistanceBetweenPoints3D( x, y, z, v[2], v[3], v[4] ) < 10 then
					theId = k
					-- now fix it.
					dbExec( exports.mysql:getConn('mta'), "UPDATE interiors SET interior_id=? WHERE `id`=?", k, myDim )
					exports.anticheat:setEld(theInterior, 'interior_id', k, 'all')
					break
				end
			end
		end
	end
	if theId then
		outputChatBox( "Interior ID: " .. theId, thePlayer )
	else
		outputChatBox( "Interior ID not found.", thePlayer, 255,0,0 )
	end
end
addCommandHandler( "getinteriorid", getInteriorID )
addCommandHandler( "getintid", getInteriorID )

function toggleInterior( thePlayer, commandName, id )
	if exports.integration:isPlayerTrialAdmin( thePlayer ) or exports.integration:isPlayerMappingTeamMember(thePlayer) then
		id = tonumber( id )
		if not id then
			outputChatBox( "SYNTAX: /" .. commandName .. " [ID]", thePlayer, 255, 194, 14 )
		else
			local dbid, entrance, exit, inttype, interiorElement = findProperty( thePlayer, id )
			if entrance then
				local interiorStatus = getElementData(interiorElement, "status")
				local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
				local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
				local adminUsername = getElementData(thePlayer, "account:username")

				if interiorStatus.disabled then
					mysql:query_free("UPDATE interiors SET disabled = 0 WHERE id = " .. dbid )
					outputChatBox("Interior "..dbid.." is now enabled", thePlayer)
					if hiddenAdmin == 0 then
						exports.global:sendMessageToAdmins("[INTERIOR]: "..adminTitle.." ".. getPlayerName(thePlayer):gsub("_", " ").." ("..adminUsername..") has enabled Interior #"..dbid..".")
					else
						exports.global:sendMessageToAdmins("[INTERIOR]: A hidden admin has enabled Interior #"..dbid..".")
					end

					exports["interior-manager"]:addInteriorLogs(dbid, commandName.." on", thePlayer)
				else
					mysql:query_free("UPDATE interiors SET disabled = 1 WHERE id = " .. dbid )
					outputChatBox("Interior "..dbid.." is now disabled", thePlayer)
					if hiddenAdmin == 0 then
						exports.global:sendMessageToAdmins("[INTERIOR]: "..adminTitle.." ".. getPlayerName(thePlayer):gsub("_", " ").." ("..adminUsername..") has disabled Interior #"..dbid..".")
					else
						exports.global:sendMessageToAdmins("[INTERIOR]: A hidden admin has disabled Interior #"..dbid..".")
					end

					exports["interior-manager"]:addInteriorLogs(dbid, commandName.." off", thePlayer)
				end
				realReloadInterior(dbid)
				exports.logs:dbLog(thePlayer, 37, { "in"..tostring(dbid) } , "TOGGLEINTERIOR "..dbid)
			end
		end
	end
end
addCommandHandler( "toggleinterior", toggleInterior )
addCommandHandler( "togint", toggleInterior )

function reloadInterior(thePlayer, commandName, interiorID)
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerMappingTeamMember(thePlayer)) then
		if not interiorID then
			outputChatBox("SYNTAX: /" .. commandName .. " [Interior ID]", thePlayer, 255, 194, 14)
		else
			local dbid, entrance, exit, interiorType = findProperty( thePlayer, tonumber(interiorID) )
			if dbid ~= 0 then
				realReloadInterior(dbid)
				outputChatBox("Reloaded Interior #" .. dbid, thePlayer, 0, 255, 0)
			else
				if exports.interior_load:loadOne(tonumber(interiorID), false) then
					outputChatBox("Loaded Interior #" .. tonumber(interiorID), thePlayer, 0, 255, 0)
				end
			end
		end
	end
end
addCommandHandler("reloadinterior", reloadInterior, false, false)
addCommandHandler("reloadint", reloadInterior, false, false)

function deleteInterior( thePlayer, commandName, houseID )
	if exports.integration:isPlayerTrialAdmin( thePlayer ) or exports.integration:isPlayerMappingTeamMember(thePlayer) then
		houseID = tonumber( houseID )
		if not houseID then
			outputChatBox( "SYNTAX: /" .. commandName .. " [House/Biz ID]", thePlayer, 255, 194, 14 )
			return false
		else
			local dbid, entrance, exit, type, interiorElement = findProperty( thePlayer, tonumber(houseID) )
			local protected, details = isProtected(interiorElement)
			if protected then
				outputChatBox("This interior is protected. Inactivity protection remaining: "..details, thePlayer, 255, 0,0)
				return false
			end
			local active, details2 = isActive(interiorElement)
			if commandName ~= 'mass' and active and getElementData(thePlayer, "confirm:delint") ~= houseID then
				outputChatBox("You are about to delete an interior while it's appearing to be an active interior.", thePlayer)
				outputChatBox("Please type /"..commandName.." "..houseID.." once again to proceed.", thePlayer)
				setElementData(thePlayer, "confirm:delint", houseID)
				return false
			end
			if dbid ~= 0 then
				-- move all players outside
				sendPlayersOutside( interiorElement )

				-- db delete.
				dbExec( exports.mysql:getConn('mta'), "UPDATE `interiors` SET `deleted`=?, `deletedDate`=NOW() WHERE id=? ", getElementData(thePlayer, "account:username"), dbid )
				setElementData( thePlayer, "mostRecentDeletedInterior", dbid, false )

				-- destroy the entrance and exit
				exports.interior_load:unload( dbid )

				-- notify
				outputChatBox("[DELINT] Interior #" .. dbid .. " has been deleted!", thePlayer, 0, 255, 0)
				outputChatBox("To restore this interior, do '/restoreint " .. dbid .. "'.", thePlayer, 255, 194, 14 )
				exports.global:sendMessageToAdmins("[INTERIOR] "..exports.global:getPlayerFullIdentity( thePlayer ).." has deleted Interior #"..dbid..".")

				-- logs
				exports.logs:dbLog( thePlayer, 37, { "in"..tostring(dbid) } , "DELETEINTERIOR "..dbid )
				exports["interior-manager"]:addInteriorLogs( dbid, commandName, thePlayer )

				removeElementData( thePlayer, "confirm:delint" )
				return true
			else
				return false
			end
		end
	end
end
addCommandHandler("delinterior", deleteInterior, false, false)
addCommandHandler("delint", deleteInterior, false, false)

function restoreInt(thePlayer, commandName, houseID)
	if exports.integration:isPlayerTrialAdmin( thePlayer ) or exports.integration:isPlayerMappingTeamMember(thePlayer) then
		if not showLoadingProgressTimer then
			houseID = tonumber( houseID )
			if not houseID then
				outputChatBox( "SYNTAX: /" .. commandName .. " [House/Biz ID]", thePlayer, 255, 194, 14 )
			else
				if houseID ~= 0 then
					local query = mysql:query("SELECT `deleted` FROM interiors WHERE id='" .. houseID .. "'")
					local row = false
					if (query) then
						row = mysql:fetch_assoc(query)
						mysql:free_result(query)
					else
						outputChatBox("[RESTOREINT] Int #"..houseID.." not found in Database!", thePlayer, 255, 0 ,0)
						return
					end

					if not row then
						outputChatBox("[RESTOREINT] Int #"..houseID.." not found in Database!", thePlayer, 255, 0 ,0)
						return
					else
						if row["deleted"] == "0" then
							outputChatBox("[RESTOREINT] Interior #"..houseID.." isn't deleted!", thePlayer, 255, 0 ,0)
							return
						end
					end

					local query = mysql:query_free("UPDATE `interiors` SET `deleted` = '0' WHERE id='" .. houseID .. "' ")
					if (query) then
						exports.interior_load:loadOne(houseID)
						outputChatBox("[RESTOREINT] Interior #" .. houseID .. " has been restored!", thePlayer, 0, 255, 0)
						exports.logs:dbLog(thePlayer, 37, { "in"..tostring(houseID) } , "RESTOREINT "..houseID)
						local adminUsername = getElementData(thePlayer, "account:username")
						local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
						local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)

						if hiddenAdmin == 0 then
							exports.global:sendMessageToAdmins("[INTERIOR]: "..adminTitle.." ".. getPlayerName(thePlayer):gsub("_", " ").. " ("..adminUsername..") has restored Interior #"..houseID..".")
						else
							exports.global:sendMessageToAdmins("[INTERIOR]: A hidden admin has restored Interior #"..houseID..".")
						end

						exports["interior-manager"]:addInteriorLogs(houseID, commandName, thePlayer)

						return true
					else
						outputChatBox("[RESTOREINT] Database Error!", thePlayer, 255, 0, 0)
					end
				end
			end
		else
			outputChatBox("Please wait until the interior system loading is done..", thePlayer, 255, 0, 0)
			return false
		end
	end
end
addCommandHandler("restoreint", restoreInt, false, false)
addCommandHandler("restoreinterior", restoreInt, false, false)

function removeInterior(thePlayer, commandName, houseID)
	if exports.integration:isPlayerLeadAdmin( thePlayer ) or commandName == "MOVETOLS" then
		if not showLoadingProgressTimer then
			houseID = tonumber( houseID ) or getElementData(thePlayer, "mostRecentDeletedInterior")
			if not houseID then
				outputChatBox( "SYNTAX: /" .. commandName .. " [House/Biz ID]", thePlayer, 255, 194, 14 )
			else
				if houseID ~= 0 then
					if commandName ~= "MOVETOLS" then
						local query = mysql:query("SELECT `deleted` FROM interiors WHERE id='" .. houseID .. "'")
						local row = false
						if (query) then
							row = mysql:fetch_assoc(query)
							mysql:free_result(query)
						else
							outputChatBox("[REMOVEINT] Int #"..houseID.." not found in Database!", thePlayer, 255, 0 ,0)
							return
						end

						if not row then
							outputChatBox("[REMOVEINT] Int #"..houseID.." not found in Database!", thePlayer, 255, 0 ,0)
							return
						else
							if row["deleted"] == "0" then
								outputChatBox("[REMOVEINT] To remove this Interior permanently from Database, please use '/delint "..houseID.."' first.", thePlayer, 255, 0 ,0)
								return
							end
						end
					end

					local query1 = mysql:query_free("DELETE FROM `interiors` WHERE `id`='" .. houseID .. "' ")
					local query2 = mysql:query_free("DELETE FROM `interior_textures` WHERE `interior`='" .. houseID .. "' ")
					if query1 and query2 then
						clearSafe( houseID, true )
						intTable[houseID] = nil
						cleanupProperty(houseID)
						outputChatBox("[REMOVEINT] Interior #" .. houseID .. " has been removed completely from Database!", thePlayer, 0, 255, 0)
						exports.logs:dbLog(thePlayer, 37, { "in"..tostring(houseID) } , "REMOVEINT "..houseID)
						local adminUsername = getElementData(thePlayer, "account:username")
						local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
						local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
						local adminID = getElementData(thePlayer, "account:id")
						if hiddenAdmin == 0 then
							exports.global:sendMessageToAdmins("[INTERIOR]: "..adminTitle.." ".. getPlayerName(thePlayer):gsub("_", " ").. " ("..adminUsername..") has removed Interior #"..houseID.." permanently from database.")
						else
							exports.global:sendMessageToAdmins("[INTERIOR]: A hidden admin has removed Interior #"..houseID.." permanently from database.")
						end

						if not mysql:query_free("DELETE FROM `interior_logs` WHERE `intID`='"..tostring(houseID).. "'") then
							outputDebugString("[INTERIOR MANAGER] Failed to clean previous logs #"..houseID.." from `interior_logs`.")
						end
						-- if not mysql:query_free("DELETE FROM `logtable` WHERE `affected`='in"..tostring(houseID).. ";'") then
							-- outputDebugString("[INTERIOR MANAGER] Failed to clean previous logs #"..houseID.." from `logtable`.")
						-- end -- Lags server as hell, I won't touch that shit then / MAXIME
						if not mysql:query_free("DELETE FROM `interior_business` WHERE `intID`='"..tostring(houseID).. "'") then
							outputDebugString("[INTERIOR MANAGER] Failed to clean previous logs #"..houseID.." from `interior_business`.")
						end

						if not mysql:query_free("DELETE FROM `interior_notes` WHERE `intid`='"..tostring(houseID).. "'") then
							outputDebugString("[INTERIOR MANAGER] Failed to clean previous notes #"..houseID.." from `interior_notes`.")
						end

						if commandName == "MOVETOLS" then
							realReloadInterior(houseID)
						end

						local mQuery1 = mysql:query("SELECT id FROM `interiors` WHERE `dimensionwithin`='".. mysql:escape_string(houseID) .."'")
						while true do
							local row = mysql:fetch_assoc(mQuery1)
							if not row then break end
							removeInterior(thePlayer, "MOVETOLS", row["id"])
						end
						mysql:free_result(mQuery1)
					else
						outputChatBox("[REMOVEINT] Database Error!", thePlayer, 255, 0, 0)
					end
				end
			end
		else
			outputChatBox("Please wait until the interior system loading is done..", thePlayer, 255, 0, 0)
			return false
		end
	end
end
addCommandHandler("removeint", removeInterior, false, false)
addCommandHandler("removeinterior", removeInterior, false, false)

function removeDeletedInteriors(thePlayer, commandName)
	if exports.integration:isPlayerLeadAdmin( thePlayer ) then
		if not getElementData(thePlayer, "confirm:removeDeletedInteriors") then
			outputChatBox( "Removes all deleted interiors completely and permanently from SQL.", thePlayer, 255, 194, 14 )
			outputChatBox( "And there will be no way to recover them, /"..commandName.." again to start it. /cancelremovedeletedints to cancel.", thePlayer, 255, 194, 14 )
			setElementData(thePlayer, "confirm:removeDeletedInteriors", true)
		else
			removeElementData(thePlayer, "confirm:removeDeletedInteriors")
			local mQuery1 = mysql:query("SELECT `id` FROM `interiors` WHERE `deleted` != '0'")
			local count = 0
			if mQuery1 then
				while true do
					local row = mysql:fetch_assoc(mQuery1)
					if not row then break end
					removeInterior(thePlayer, "MOVETOLS", row["id"])
					count = count + 1
				end
				mysql:free_result(mQuery1)
				local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
				local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
				local adminUsername = getElementData(thePlayer, "account:username")
				if hiddenAdmin == 0 then
					exports.global:sendMessageToAdmins("[INTERIOR]: "..adminTitle.." ".. getPlayerName(thePlayer):gsub("_", " ").. " ("..adminUsername..") has executed a massive int remove command on "..count.." deleted interiors permanently from database.", root, 255,0,0)
				else
					exports.global:sendMessageToAdmins("[INTERIOR]: A hidden admin has executed a massive int remove command on "..count.." deleted interiors permanently from database.", root, 255,0,0)
				end
			end
		end
	end
end
addCommandHandler("removedeletedints", removeDeletedInteriors, false, false)
addCommandHandler("removedeletedinteriors", removeDeletedInteriors, false, false)

function removeForSaleInteriors(thePlayer, commandName)
	if exports.integration:isPlayerLeadAdmin( thePlayer ) then
		if not getElementData(thePlayer, "confirm:removeForSaleInteriors") then
			outputChatBox( "Removes all for-sale interiors completely and permanently from SQL.", thePlayer, 255, 194, 14 )
			outputChatBox( "And there will be no way to recover them, /"..commandName.." again to start it. /cancelremoveforsaleints to cancel.", thePlayer, 255, 194, 14 )
			setElementData(thePlayer, "confirm:removeForSaleInteriors", true)
		else
			removeElementData(thePlayer, "confirm:removeForSaleInteriors")
			local mQuery1 = mysql:query("SELECT `id` FROM `interiors` WHERE `owner` = '-1'")
			local count = 0
			if mQuery1 then
				while true do
					local row = mysql:fetch_assoc(mQuery1)
					if not row then break end
					removeInterior(thePlayer, "MOVETOLS", row["id"])
					count = count + 1
				end
				mysql:free_result(mQuery1)
				local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
				local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
				local adminUsername = getElementData(thePlayer, "account:username")
				if hiddenAdmin == 0 then
					exports.global:sendMessageToAdmins("[INTERIOR]: "..adminTitle.." ".. getPlayerName(thePlayer):gsub("_", " ").. " ("..adminUsername..") has executed a massive int remove command on "..count.." for-sale interiors permanently from database.", root, 255,0,0)
				else
					exports.global:sendMessageToAdmins("[INTERIOR]: A hidden admin has executed a massive int remove command on "..count.." for-sale interiors permanently from database.")
				end
			end
		end
	end
end
addCommandHandler("removeforsaleints", removeForSaleInteriors, false, false)
addCommandHandler("removeforsaleinteriors", removeForSaleInteriors, false, false)


function cancelRemoveDeletedInts(thePlayer)
	if exports.integration:isPlayerLeadAdmin( thePlayer ) and getElementData(thePlayer, "confirm:removeDeletedInteriors") then
		if removeElementData(thePlayer, "confirm:removeDeletedInteriors") then
			outputChatBox("Request to remove all deleted interiors has been cancelled.", thePlayer)
		end
	end
end
addCommandHandler("cancelremovedeletedints", cancelRemoveDeletedInts, false, false)
addCommandHandler("cancelremovedeletedints", cancelRemoveDeletedInts, false, false)

function cancelRemoveForSaleInts(thePlayer)
	if exports.integration:isPlayerLeadAdmin( thePlayer ) and getElementData(thePlayer, "confirm:removeForSaleInteriors") then
		if removeElementData(thePlayer, "confirm:removeForSaleInteriors") then
			outputChatBox("Request to remove all for-sale interiors has been cancelled.", thePlayer)
		end
	end
end
addCommandHandler("cancelremoveforsaleints", cancelRemoveForSaleInts, false, false)
addCommandHandler("cancelremoveforsaleints", cancelRemoveForSaleInts, false, false)
---

function deleteThisInterior(thePlayer, commandName)
	if exports.integration:isPlayerAdmin( thePlayer )   then
		local interior = getElementInterior(thePlayer)

		if (interior==0) then
			outputChatBox("You are not in an interior.", thePlayer, 255, 0, 0)
		else
			local dbid, entrance, exit = findProperty( thePlayer )
			deleteInterior(thePlayer, "delint" , dbid)
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "interiormarker", false, false, false)
		end
	end
end
addCommandHandler("delthisint", deleteThisInterior, false, false)
addCommandHandler("delthisinterior", deleteThisInterior, false, false)

function updateInteriorEntrance(thePlayer, commandName, intID)
	if exports.integration:isPlayerTrialAdmin( thePlayer ) or exports.integration:isPlayerMappingTeamMember(thePlayer)  then
		local intID = tonumber(intID)
		if not (intID) then
			outputChatBox( "SYNTAX: /" .. commandName .. " [Interior ID]", thePlayer, 255, 194, 14 )
		else
			local dbid, entrance, exit = findProperty(thePlayer, intID)
			if entrance then
				local dw = getElementDimension(thePlayer)
				local iw = getElementInterior(thePlayer)
				local x, y, z = getElementPosition(thePlayer)
				local rot = getPedRotation(thePlayer)
				local query = mysql:query_free("UPDATE interiors SET x='" .. x .. "', y='" .. y .. "', z='" .. z .. "', angle='" .. rot .. "', dimensionwithin='" .. dw .. "', interiorwithin='" .. iw .. "' WHERE id='" .. dbid .. "'")

				if (query) then
					realReloadInterior(dbid)

					outputChatBox("Interior Entrance #" .. dbid .. " has been Updated!", thePlayer, 0, 255, 0)
					exports.logs:dbLog(thePlayer, 37, { "in"..tostring(dbid) } , "SETINTERIORENTRANCE ("..dw.."/"..iw..") "..x.."/"..y.."/"..z)
					local adminUsername = getElementData(thePlayer, "account:username")
					local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
					local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)

					if hiddenAdmin == 0 then
						exports.global:sendMessageToAdmins("[INTERIOR]: "..adminTitle.." ".. getPlayerName(thePlayer):gsub("_", " ").. " ("..adminUsername..") has moved Interior #"..dbid.." to new location.")
					else
						exports.global:sendMessageToAdmins("[INTERIOR]: A hidden admin has moved Interior #"..dbid.." to new location.")
					end


					exports["interior-manager"]:addInteriorLogs(dbid, commandName, thePlayer)

					return true
				else
					outputChatBox("Error with the query.", thePlayer, 255, 0, 0)
				end
			else
				outputChatBox( "Invalid Interior ID.", thePlayer, 255, 0, 0 )
			end
		end
	end
end
addCommandHandler("setinteriorentrance", updateInteriorEntrance, false, false)
addCommandHandler("setintentrance", updateInteriorEntrance, false, false)

function createInterior(thePlayer, commandName, interiorId, inttype, cost, ...)
	if exports.integration:isPlayerTrialAdmin( thePlayer ) or exports.integration:isPlayerMappingTeamMember(thePlayer) then
		local cost = tonumber(cost)
		if (not (interiorId) or not (inttype) or not (cost) or not (...) or ((tonumber(inttype)<0) or (tonumber(inttype)>3))) and (commandName:lower() == "addint" or commandName:lower() == "addinterior") then
			outputChatBox("SYNTAX: /" .. commandName .. " [Interior ID] [TYPE] [Cost] [Name] [Admin Note - Optional]", thePlayer, 255, 194, 14)
			outputChatBox("TYPE 0: House", thePlayer, 255, 194, 14)
			outputChatBox("TYPE 1: Business", thePlayer, 255, 194, 14)
			outputChatBox("TYPE 2: Government (Unbuyable)", thePlayer, 255, 194, 14)
			outputChatBox("TYPE 3: Rentable", thePlayer, 255, 194, 14)
			outputChatBox("/addnewint to create an interior quickly.", thePlayer, 255, 194, 0)
		else
			local owner, locked = nil, nil
			local x, y, z = getElementPosition(thePlayer)
			local dimension = getElementDimension(thePlayer)
			local interiorwithin = getElementInterior(thePlayer)

			if commandName:lower() == "addnewint" then
				name = "Garage"
				inttype = 0
				owner = -1
				locked = 1
				cost = 8000
				interiorId = 119
			else
				name = table.concat({...}, " ")

				inttype = tonumber(inttype)
				owner = nil
				locked = nil

				if (inttype==2) then
					owner = 0
					locked = 0
				else
					owner = -1
					locked = 1
				end

			end
			local interiors = exports["official-interiors"].getInteriorsList()
			interior = interiors[tonumber(interiorId)]
			if interior then
				local ix = interior[2]
				local iy = interior[3]
				local iz = interior[4]
				local optAngle = interior[5]
				local interiorw = interior[1]
				local defaultSupplies = "[ [ ] ]"

				local rot = getPedRotation(thePlayer)
				local qh = dbQuery( exports.mysql:getConn('mta'), "INSERT INTO interiors SET interior_id=?, creator=?, id=" .. exports.mysql:getSmallestID( 'interiors' ) .. ", x=?, y=?, z=?, "
				.." type=?, owner=?, locked=?, cost=?, name=?, interior=?, interiorx=?, interiory=?, interiorz=?, dimensionwithin=?, interiorwithin=?, angle=?, angleexit=?, supplies=?, createdDate=NOW() "
				, interiorId, getElementData( thePlayer, "account:username" ), x, y, z, inttype, owner, locked, cost, name, interiorw, ix, iy, iz, dimension, interiorwithin, optAngle, rot, defaultSupplies )
				local res, rows, inserted_id = dbPoll( qh, 10000 )
				if res and rows > 0 then
					local uid = tonumber(inserted_id)
					if(uid and uid > 20000) then
						--All scripts handles interiors over ID 20,000 as vehicle interiors.
						outputChatBox("Failed to create interior: Reached max limit.", thePlayer, 255, 0, 0)
						outputChatBox("This script version supports a maximum of 20,000 interiors (current: "..tostring(uid)..").", thePlayer, 255, 0, 0)
						dbExec( exports.mysql:getConn('mta'), "DELETE FROM `interiors` WHERE `id`=? LIMIT 1;", inserted_id )
						dbFree( qh )
						return false
					end
					if tonumber(inttype) == 1 then
						dbExec( exports.mysql:getConn('mta'), "INSERT INTO `interior_business` SET `intID`=? ", inserted_id )
					end
					outputChatBox("Created Interior with ID " .. inserted_id .. ".", thePlayer, 255, 194, 14)
					exports.logs:dbLog(thePlayer, 37, { "in"..tostring(inserted_id) } , "ADDINTERIOR T:".. inttype .." I:"..interiorId.." C:"..cost)
					exports.interior_load:loadOne( inserted_id )
					exports.global:sendMessageToAdmins("[INTERIOR]: "..exports.global:getPlayerFullIdentity( thePlayer ).." has created Interior #"..inserted_id.." with name '"..name.."', type "..inttype..", price: $"..cost..").")
					exports["interior-manager"]:addInteriorLogs(inserted_id, commandName.." - id "..interiorId.." - price $"..cost.." - name "..name, thePlayer)
					return true
				end
				dbFree( qh )
			else
				outputChatBox("Failed to create interior - There is no such interior (" .. ( interiorID or "??" ) .. ").", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("addinterior", createInterior, false, false)
addCommandHandler("addint", createInterior, false, false)
addCommandHandler("addnewint", createInterior, false, false)

function updateInteriorExit(thePlayer, commandName)
	if exports.integration:isPlayerTrialAdmin( thePlayer ) or exports.integration:isPlayerMappingTeamMember(thePlayer) then
		local dimension = getElementDimension(thePlayer)

		if (dimension==0) then
			outputChatBox("You are not in an interior.", thePlayer, 255, 0, 0)
		else
			local dbid = getElementDimension(thePlayer)
			local x, y, z = getElementPosition(thePlayer)
			local interior = getElementInterior(thePlayer)
			local _, _, rot = getElementRotation(thePlayer)
			local query = mysql:query_free("UPDATE interiors SET interiorx='" .. x .. "', interiory='" .. y .. "', interiorz='" .. z .. "', angleexit='" .. rot .. "', `interior`='".. tostring(interior) .."' WHERE id='" .. dbid .. "'")
			outputChatBox("Interior Exit Position Updated!", thePlayer, 0, 255, 0)
			exports.logs:dbLog(thePlayer, 37, { "in"..tostring(dbid) } , "SETINTERIOREXIT "..x.."/"..y.."/"..z)

			exports["interior-manager"]:addInteriorLogs(dbid, commandName, thePlayer)

			realReloadInterior(dbid)
			return true
		end
	end
end
addCommandHandler("setinteriorexit", updateInteriorExit, false, false)
addCommandHandler("setintexit", updateInteriorExit, false, false)

function changeInteriorName( thePlayer, commandName, ...)
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerMappingTeamMember(thePlayer)) then -- Is the player an admin?
		local id = getElementDimension(thePlayer)
		if not (...) then -- is the command complete?
			outputChatBox("SYNTAX: /" .. commandName .." [New Name]", thePlayer, 255, 194, 14) -- if command is not complete show the syntax.
		elseif (dimension==0) then
			outputChatBox("You are not inside an interior.", thePlayer, 255, 0, 0)
		else
			name = table.concat({...}, " ")

			mysql:query_free("UPDATE interiors SET name='" .. mysql:escape_string( name) .. "' WHERE id='" .. id .. "'") -- Update the name in the sql.
			outputChatBox("Interior name changed to ".. name ..".", thePlayer, 0, 255, 0) -- Output confirmation.
			exports.logs:dbLog(thePlayer, 37, { "in"..tostring(dbid) } , "SETINTERIORNAME '"..name.."'")
			local adminUsername = getElementData(thePlayer, "account:username")
			local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
			local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)

			if hiddenAdmin == 0 then
				exports.global:sendMessageToAdmins("[INTERIOR]: "..adminTitle.." ".. getPlayerName(thePlayer):gsub("_", " ").. " ("..adminUsername..") has changed Interior #"..id.."'s name to '"..name.."'.")
			else
				exports.global:sendMessageToAdmins("[INTERIOR]: A hidden admin has changed Interior #"..id.."'s name to '"..name.."'.")
			end


			exports["interior-manager"]:addInteriorLogs(id, commandName.." "..name, thePlayer)

			realReloadInterior(id)
			return true
		end
	end
end
addCommandHandler("setinteriorname", changeInteriorName, false, false) -- the command "/setInteriorName".
addCommandHandler("setintname", changeInteriorName, false, false)

function forceSellProperty(thePlayer, commandName, intID)
	if exports.integration:isPlayerTrialAdmin(thePlayer)  then
		if not intID and getElementDimension(thePlayer) > 0 then
			intID = getElementDimension(thePlayer)
		end

		if not intID or not tonumber(intID) or (tonumber(intID)%1 ~= 0) or (tonumber(intID) <= 0) then
			outputChatBox("SYNTAX: /" .. commandName .." [ID]", thePlayer, 255, 194, 14)
			outputChatBox("Force sells a property.", thePlayer, 200, 194, 14)
			return
		end
		local possibleInteriors = exports.pool:getPoolElementsByType('interior')
		local foundInt = false
		for _, interior in ipairs(possibleInteriors) do
			if getElementData(interior, "dbid") == tonumber(intID) then
				foundInt = interior
				break
			end
		end
		if not foundInt then
			outputChatBox("Interior ID not found in game.", thePlayer, 255, 0,0)
			return
		end
		local protected, details = isProtected(foundInt)
		if protected then
			outputChatBox("This interior is protected. Inactivity protection remaining: "..details, thePlayer, 255, 0,0)
			return false
		end
		local active, details2 = isActive(foundInt)
		if active and getElementData(thePlayer, "confirm:fsell") ~= intID then
			outputChatBox("You are about to forcesell an interior while it's appearing to be an active interior.", thePlayer)
			outputChatBox("Please type /"..commandName.." "..intID.." once again to proceed.", thePlayer)
			setElementData(thePlayer, "confirm:fsell", intID)
			return false
		end

		local interiorEntrance = getElementData(foundInt, "entrance")
		local interiorExit = getElementData(foundInt, "exit")
		local interiorStatus = getElementData(foundInt, "status")

		if interiorStatus.type == 2 then
			outputChatBox("You cannot force-sell a government property.", thePlayer, 255, 0, 0)
		elseif interiorStatus.owner < 1 and interiorStatus.faction < 1 then
			outputChatBox("This property is not owned by anyone at the moment.", thePlayer, 255, 0, 0)
		else
			publicSellProperty(thePlayer, tonumber(intID), true, false, "FORCESELL")
			cleanupProperty(tonumber(intID), true)
			exports.logs:dbLog(thePlayer, 37, { "in"..tostring(intID) } , "FORCESELL "..intID)
			exports["interior-manager"]:addInteriorLogs(intID, commandName, thePlayer)
			setElementData(thePlayer, "confirm:fsell", nil)
		end
	end
end
addCommandHandler("forcesell", forceSellProperty, false, false)
addCommandHandler("fsell", forceSellProperty, false, false)

function forcesellFactionInterior(factionId, intId)
	if exports.integration:isPlayerTrialAdmin(source) then
		if not intId or not tonumber(intId) or (tonumber(intId)%1 ~= 0) or (tonumber(intId) <= 0) then
			return false
		end

		local possibleInteriors = exports.pool:getPoolElementsByType('interior')
		local foundInt = false
		for _, interior in ipairs(possibleInteriors) do
			if getElementData(interior, "dbid") == tonumber(intId) then
				foundInt = interior
				break
			end
		end
		if not foundInt then
			return false
		end

		local protected, details = isProtected(foundInt)
		if protected then
			return false
		end

		local interiorEntrance = getElementData(foundInt, "entrance")
		local interiorExit = getElementData(foundInt, "exit")
		local interiorStatus = getElementData(foundInt, "status")

		if interiorStatus.type == 2 then
			return false
		elseif interiorStatus.owner < 1 and interiorStatus.faction < 1 then
			return false
		else
			publicSellProperty(source, tonumber(intId), false, false, "FORCESELL")
			exports["interior-manager"]:addInteriorLogs(intId, "Interior forcesold upon faction deletion (Faction ID: " .. factionId .. ").", source)
			cleanupProperty(tonumber(intId), true)
		end
	end
end
addEvent("interior_system:factionfsell", false)
addEventHandler("interior_system:factionfsell", root, forcesellFactionInterior)

function changeInteriorAddress( thePlayer, commandName, id, ...) --MS: Adding command for setting address + logging it
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) or (exports.integration:isPlayerMappingTeamMember(thePlayer)) then -- Is the player a Trial Admin+ or Mapping Team?
		if not id or not (...) then -- is the command complete?
			outputChatBox("SYNTAX: /" .. commandName .." [Interior ID] [Address or 'reset']", thePlayer, 255, 194, 14) -- if command is not complete show the syntax.
			outputChatBox("SYNTAX: 'reset' will remove the interiors address.", thePlayer, 255, 194, 14)
		else
			if not tonumber(id) then
				if id == "*" and getElementDimension(thePlayer) > 0 then
					id = getElementDimension(thePlayer)
				else
					outputChatBox(" Invalid interior ID specified.", thePlayer, 255, 0, 0)
					return false
				end
			end
			address = table.concat({...}, " ")
			if address == "reset" then
				dbExec( exports.mysql:getConn('mta'), "UPDATE interiors SET address=NULL WHERE id=?", id) -- Remove Address
				outputChatBox("Interior (#" .. id ..") address has been reset.", thePlayer, 0, 255, 0)
			else
				dbExec( exports.mysql:getConn('mta'), "UPDATE interiors SET address=? WHERE id=?", address, id) -- Set address in DB to be called later
				outputChatBox("Interior (#" .. id ..") address changed to ".. address ..".", thePlayer, 0, 255, 0) -- Output confirmation.
				exports.logs:dbLog(thePlayer, 4, { "in"..tostring(dbid) } , "SETINTERIORADDRESS '"..address.."'")
			end
			local adminUsername = getElementData(thePlayer, "account:username")
			local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
			local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
			
			if hiddenAdmin == 0 then
				exports.global:sendMessageToAdmins("[INTERIOR]: "..adminTitle.." ".. getPlayerName(thePlayer):gsub("_", " ").. " ("..adminUsername..") has changed Interior #"..id.."'s address to '"..address.."'.")
			else
				exports.global:sendMessageToAdmins("[INTERIOR]: A hidden admin has changed Interior #"..id.."'s address to '"..address.."'.")
			end
			
			exports["interior-manager"]:addInteriorLogs(id, commandName.." "..address, thePlayer)
			
			realReloadInterior(id)
			return true
		end
	end
end
addCommandHandler("setinterioraddress", changeInteriorAddress)
addCommandHandler("setintaddress", changeInteriorAddress)

function teleportToMarker( thePlayer, commandName )

	if getElementData(thePlayer, "recovery") then 
		return outputChatBox("You cannot use this command while in recovery!", thePlayer, 255, 194, 14)
	end

	if getElementData(thePlayer, "jailed") then
		return outputChatBox("You cannot use this command in jail!", thePlayer, 255, 194, 14)
	end

    local houseID = getElementDimension(thePlayer)
    if not houseID or houseID == 0 then
        outputChatBox( "This command only works inside an interior.", thePlayer, 255, 0, 0 )
    else

        local dbid, entrance, exit, type, interiorElement = findProperty( thePlayer, houseID )
		if isPedInVehicle(thePlayer) then
			local theVehicle = getPedOccupiedVehicle(thePlayer)
			local respawnPos = getElementData(theVehicle, "vehicle_respawn_pos")
			if not respawnPos then return end
			local pos = {}
			local posTab = split(respawnPos, ",")
			for i,v in ipairs(posTab) do
				pos[i] = v
			end
			if dbid ~= houseID then
				outputChatBox("ERROR: Report at bugs.owlgaming.net", thePlayer, 255, 0, 0)
				return
			end
			
			setElementFrozen(thePlayer, true)
			setElementFrozen(theVehicle, true)
			setElementPosition(theVehicle, pos[1], pos[2], pos[3])	
			setTimer(function(thePlayer, theVehicle)
				setElementFrozen(thePlayer, false)
				setElementFrozen(theVehicle, false)
			end, 1000, 1, thePlayer, theVehicle)
			exports["interior-manager"]:addInteriorLogs(dbid, "VEHICLE ANTIFALL", thePlayer)
			local affectedElements = {}
			table.insert(affectedElements, interiorElement)
			for key, value in pairs(exports.pool:getPoolElementsByType("player")) do
				local playerdimension = getElementDimension(value)

				if (houseID==playerdimension) then
					local logged = getElementData(value, "loggedin")
					if (logged==1) then
						table.insert(affectedElements, value)
						outputChatBox("(( ".. getPlayerName(thePlayer):gsub("_", " ") .."'s vehicle ("..getElementData(theVehicle, "dbid").. ") teleported to the vehicle respawn point. ))", value, 196, 255, 255)
					end
				end
			end
			exports.logs:dbLog(thePlayer, 37, affectedElements, "VEHICLE ANTIFALL")
			return
		end
		local x, y, z = getElementPosition(thePlayer)	
        local difference = exit.z - z
		setElementPosition(thePlayer, exit.x, exit.y, exit.z)
				
		exports["interior-manager"]:addInteriorLogs(dbid, "ANTIFALL", thePlayer)
		
		local affectedElements = {}
		table.insert(affectedElements, interiorElement)
		for key, value in pairs(exports.pool:getPoolElementsByType("player")) do
			local playerdimension = getElementDimension(value)

			if (houseID==playerdimension) then
				local logged = getElementData(value, "loggedin")
				if (logged==1) then
					table.insert(affectedElements, value)
					outputChatBox("(( ".. getPlayerName(thePlayer):gsub("_", " ") .." teleported to the interior entrance. ))", value, 196, 255, 255)
				end
			end
		end
		exports.logs:dbLog(thePlayer, 37, affectedElements, "ANTIFALL")
    end
end
addCommandHandler( "goup", teleportToMarker )
addCommandHandler( "antifall", teleportToMarker )
addCommandHandler( "falling", teleportToMarker )
addCommandHandler( "lifealert", teleportToMarker )