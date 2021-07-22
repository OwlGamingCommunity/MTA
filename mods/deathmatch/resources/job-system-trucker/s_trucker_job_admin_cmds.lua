--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]
 
function getJobTitleFromID(jobID)
	return exports["job-system"]:getJobTitleFromID(jobID)
end

function givePlayerJob(thePlayer, commandName, targetPlayer, jobID, jobLevel, jobProgress)
	jobID = tonumber(jobID)
	if exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer) then
		local jobTitle = getJobTitleFromID(jobID)
		if not (targetPlayer) then
			printSetJobSyntax(thePlayer, commandName)
			return
		else
			
			if jobTitle == "Unemployed" then
				jobID = 0
			end
			
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				local username = getPlayerName(thePlayer)
				
				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				else
					if (jobID==4) then -- CITY MAINTENANCE
						exports.global:giveItem(targetPlayer, 115, "41:1:Spraycan", 2500)
						outputChatBox("Use this spray to paint over the graffiti you find.", targetPlayer, 255, 194, 14)
						exports.anticheat:changeProtectedElementDataEx(targetPlayer, "tag", 9, true)
						mysql:query_free("UPDATE characters SET tag=9 WHERE id = " .. mysql:escape_string(getElementData(targetPlayer, "dbid")) )
					end
					
					mysql:query_free("UPDATE `characters` SET `job`='" .. mysql:escape_string(jobID) .. "' WHERE `id`='"..tostring(getElementData(targetPlayer, "dbid")).."' " )
					
					exports["job-system"]:fetchJobInfoForOnePlayer(targetPlayer)
					
					local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
					local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
					if hiddenAdmin == 0 then
						outputChatBox("Your job has been set to '" .. jobTitle .. "' by "..tostring(adminTitle) .. " " .. getPlayerName(thePlayer):gsub("_", " ") ..". ", targetPlayer, 0, 255,0)
					else
						outputChatBox("Your job has been set to '" .. jobTitle .. "' by a hidden admin. ", targetPlayer, 0, 255,0)
					end
					outputChatBox("You have set " .. targetPlayerName .. "'s job to '"..jobTitle.."'.", thePlayer)
				end
			end
		end
	end
end
addCommandHandler("setjob", givePlayerJob, false, false)

function printSetJobSyntax(thePlayer, commandName)
	outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID] [Job ID, 0 = Unemployed]", thePlayer, 255, 194, 14)
	outputChatBox("ID#1: Delivery Driver", thePlayer)
	outputChatBox("ID#2: Taxi Driver", thePlayer)
	outputChatBox("ID#3: Bus Driver", thePlayer)
	outputChatBox("ID#4: City Maintenance", thePlayer)
	outputChatBox("ID#5: Mechanic", thePlayer)
	outputChatBox("ID#6: Locksmith", thePlayer)
	outputChatBox("ID#7: Long Haul Truck Driver", thePlayer)
end

function setjobLevel(thePlayer, commandName, target, level, progress )
	if exports.integration:isPlayerLeadAdmin(thePlayer) then
		if not target or not tonumber(level) or (tonumber(level) < 1) then
			outputChatBox( "SYNTAX: /" .. commandName .. " [player ID or Name] [Level] [Progress, optional]", thePlayer, 255, 194, 14 )
			return false
		end
		
		if not tonumber(progress) or (tonumber(progress) < 0) then
			progress = 0
		end
		
		level = math.floor(tonumber(level))
		local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, target)
			
		if not targetPlayer then
			outputChatBox("Player '"..target.."' not found.", thePlayer, 255,0,0)
			return false
		end
		
		jobID = getElementData(targetPlayer, "job")
		
		if jobID <=0 then
			outputChatBox("Player is currently unemployed, please use /setjob first.", thePlayer, 255,0,0)
			return false
		end
		
		local sucess, msg = setPlayerJobLevel(targetPlayer, jobID, level, progress)
		if (getPlayerName(thePlayer) ~= getPlayerName(targetPlayer)) then
			outputChatBox(msg, thePlayer, 255, 194, 14)
			outputChatBox(msg, targetPlayer, 255, 194, 14)
		else
			outputChatBox(msg, targetPlayer, 255, 194, 14)
		end
		
		if sucess then
			return true
		else
			return false
		end
	end
end
addCommandHandler("setjoblevel", setjobLevel, false, false)

function setPlayerJobLevel(targetPlayer, jobID, level, progress)
	if mysql:query_free("UPDATE `jobs` SET `jobLevel`='"..level.."', `jobProgress`='"..progress.."' WHERE `jobCharID`='"..getElementData(targetPlayer, "dbid").."' AND `jobID`='"..jobID.."' " ) then
		exports["job-system"]:fetchJobInfoForOnePlayer(targetPlayer)
		return true, getPlayerName(targetPlayer):gsub("_", " ").." now has '"..getJobTitleFromID(jobID).."' job (Level: "..level..", Progress: "..progress..")"
	else
		return false, "Database Error, please report as bug"
	end
end

function delJob( thePlayer, commandName, targetPlayerName )
	if (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer)) then
		if targetPlayerName then
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick( thePlayer, targetPlayerName )
			if targetPlayer then
				if getElementData( targetPlayer, "loggedin" ) == 1 then
					local result = mysql:query_free("UPDATE `characters` SET `job`='0' WHERE `id`='"..tostring(getElementData(targetPlayer, "dbid")).."' " )
					
					exports["job-system"]:fetchJobInfoForOnePlayer(targetPlayer)
					if result then
						outputChatBox( "Deleted job for " .. targetPlayerName..".", thePlayer)
						local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
						if hiddenAdmin == 0 then
							local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
							outputChatBox("Your job has been deleted by "..tostring(adminTitle) .. " " .. getPlayerName(thePlayer)..". Please relog (F10) to get it affected.", targetPlayer, 0, 255,0)
						else
							outputChatBox("Your job has been deleted by a hidden admin.", targetPlayer, 0, 255,0)
						end
					else
						outputChatBox( "Failed to delete job.", thePlayer, 255, 0, 0 )
					end
				else
					outputChatBox( "Player is not logged in.", thePlayer, 255, 0, 0 )
				end
			end
		else
			outputChatBox( "SYNTAX: /" .. commandName .. " [player]", thePlayer, 255, 194, 14 )
		end
	end
end
addCommandHandler("deljob", delJob, false, false)

function adminRespawnAllTrucks(thePlayer, commandName)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		outputChatBox("Respawned " .. tostring(respawnAllTrucks()) .. " Trucks.", thePlayer)
	else
		outputChatBox("Only Admin and above can access /"..commandName..".", thePlayer, 255,0,0)
	end
end
addCommandHandler("respawntrucks", adminRespawnAllTrucks, false, false)

function scripterSkipRoute(thePlayer, commandName, target)
	if not exports.integration:isPlayerTrialAdmin(thePlayer) then
		outputChatBox("Only Super Admin and above can access /"..commandName..".", thePlayer, 255,0,0)
		return false
	end
	if not target then
		outputChatBox("SYNTAX: /" .. commandName .. " [Player/ID]", thePlayer, 255, 194, 14)
		return
	end
	local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, target)
	if targetPlayer then
		spawnRoute(targetPlayer, true)
	end
end
addCommandHandler("skiproute", scripterSkipRoute, false, false)
