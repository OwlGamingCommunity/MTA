--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local mysql = exports.mysql
local staffTitles = exports.integration:getStaffTitles()
function getStaffInfo(username, error)
	local thePlayer = source
	local error1 = error
	dbQuery(function(qh, username, error, source)
		local result = dbPoll(qh, 0)
		if result and #result > 0 then
			local changelogs = {}
			local mQuery1 = nil
			mQuery1 = mysql:query("SELECT (CASE WHEN to_rank>from_rank THEN 1 ELSE 0 END) AS promoted, s.id, s.userid, team, from_rank, to_rank, s.`by` AS `by`, details, DATE_FORMAT(date,'%b %d, %Y %h:%i %p') AS date FROM staff_changelogs s WHERE s.userid="..result[1]["id"].." ORDER BY id DESC")
			while true do
				local row = mysql:fetch_assoc(mQuery1)
				if not row then break end
				row.userid = exports.cache:getUsernameFromId(row.userid)
				row.by = exports.cache:getUsernameFromId(row.by)
				table.insert(changelogs, row )
			end
			mysql:free_result(mQuery1)
			local staffInfo = {}
			staffInfo.user = result[1]
			staffInfo.changelogs = changelogs
			staffInfo.error = error1
			triggerClientEvent(thePlayer, "openStaffManager", thePlayer, staffInfo)
		end
	end, {username, error, source}, exports.mysql:getConn("core"), "SELECT id, username, admin, supporter, vct, scripter, mapper, fmt FROM accounts WHERE username=?", username)
end
addEvent("staff:getStaffInfo", true)
addEventHandler("staff:getStaffInfo", root, getStaffInfo)

function getTeamsData()
	local thePlayer = source
	staffTitles = exports.integration:getStaffTitles()
	local users = {}
	dbQuery(
		function(qh, staffTitles, users)
			local result = dbPoll(qh, 0)
			if result then
				for _, row in pairs(result) do
					for i, k in ipairs(staffTitles) do
						if not users[i] then users[i] = {} end
						-- fetch report count
						local reportsQuery = dbQuery(exports.mysql:getConn("mta"), "SELECT adminreports FROM account_details WHERE account_id = ?", row.id)
						local reportsResult = dbPoll(reportsQuery, -1)
						row.adminreports = (reportsResult[1] and reportsResult[1].adminreports) or 0
						dbFree(reportsQuery)
						--
						if tonumber(row.admin) > 0 and i == 1 then
							if not row.rank then row.rank = {} end
							row.rank[i] = tonumber(row.admin)
							table.insert(users[i], row)
						end
						if tonumber(row.supporter) > 0 and i == 2 then
							if not row.rank then row.rank = {} end
							row.rank[i] = tonumber(row.supporter)
							table.insert(users[i], row)
						end
						if tonumber(row.vct) > 0 and i == 3 then
							if not row.rank then row.rank = {} end
							row.rank[i] = tonumber(row.vct)
							table.insert(users[i], row)
						end
						if tonumber(row.scripter) > 0 and i == 4 then
							if not row.rank then row.rank = {} end
							row.rank[i] = tonumber(row.scripter)
							table.insert(users[i], row)
						end
						if tonumber(row.mapper) > 0 and i == 5 then
							if not row.rank then row.rank = {} end
							row.rank[i] = tonumber(row.mapper)
							table.insert(users[i], row)
						end
						if tonumber(row.fmt) > 0 and i == 6 then
							if not row.rank then row.rank = {} end
							row.rank[i] = tonumber(row.fmt)
							table.insert(users[i], row)
						end
					end
				end
				triggerClientEvent(thePlayer, "openStaffManager", thePlayer, nil, users )
			else
				dbFree(qh)
			end
		end
	, {staffTitles, users}, exports.mysql:getConn("core"), "SELECT id, username, admin, supporter, vct, scripter, mapper, fmt FROM accounts  WHERE admin > 0 OR supporter > 0 OR vct > 0 OR scripter>0 OR mapper>0 OR fmt>0 GROUP BY id ORDER BY admin DESC, supporter DESC, vct DESC, scripter DESC, mapper DESC")
end
addEvent("staff:getTeamsData", true)
addEventHandler("staff:getTeamsData", root, getTeamsData)

function getChangelogs()
	local changelogs = {}
	local mQuery1 = nil
	mQuery1 = mysql:query("SELECT (CASE WHEN to_rank>from_rank THEN 1 ELSE 0 END) AS promoted, s.id, s.userid, team, from_rank, to_rank, s.`by` AS `by`, details, DATE_FORMAT(date,'%b %d, %Y %h:%i %p') AS date FROM staff_changelogs s ORDER BY id DESC")
	while true do
		local row = mysql:fetch_assoc(mQuery1)
		if not row then break end
		row.userid = exports.cache:getUsernameFromId(row.userid)
		row.by = exports.cache:getUsernameFromId(row.by)
		table.insert(changelogs, row )
	end
	mysql:free_result(mQuery1)
	triggerClientEvent(source, "openStaffManager", source, nil, nil, changelogs )
end
addEvent("staff:getChangelogs", true)
addEventHandler("staff:getChangelogs", root, getChangelogs)

function editStaff(userid, ranks, details)
	local error = nil
	if not userid or not tonumber(userid) then
		outputChatBox("Internal Error!", source, 255, 0, 0)
		return false
	else
		userid = tonumber(userid)
	end
	local target = false
	for i, player in pairs(getElementsByType("player")) do
		if getElementData(player, "account:id") == userid then
			target = player
			break
		end
	end
	staffTitles = exports.integration:getStaffTitles()
	local thePlayer = source
	dbQuery(function(qh, userid, staffTitles, target, userid, ranks, details, thePlayer)
		local result = dbPoll(qh, 0)
		if result then
			local user = result[1]
			local tail = ''
			if details and string.len(details)>0 then
				details = "'"..mysql:escape_string(details).."'"
			else
				details = "NULL"
			end
			if ranks[1] and ranks[1] ~= tonumber(user.admin) then
				tail = tail.."admin="..ranks[1]..","
				mysql:query_free("INSERT INTO staff_changelogs SET userid="..userid..", details="..details..", `by`="..getElementData(thePlayer, "account:id")..", team=1, from_rank="..user.admin..", to_rank="..ranks[1])
				exports.global:sendMessageToStaff("[STAFF UPDATE] "..exports.global:getPlayerFullIdentity(thePlayer, 1, true).." has "..(ranks[1] > tonumber(user.admin) and "promoted" or "demoted").." '"..user.username.."' from "..staffTitles[1][tonumber(user.admin)].." to "..staffTitles[1][ranks[1]]..".", true)
				exports.announcement:makePlayerNotification(target or user.id, "Staff Rank Updated", exports.global:getPlayerFullIdentity(thePlayer, 1, true).." has "..(ranks[1] > tonumber(user.admin) and "promoted" or "demoted").." you from "..staffTitles[1][tonumber(user.admin)].." to "..staffTitles[1][ranks[1]]..". \n" .. (ranks[1] > tonumber(user.admin) and "Congratulations!" or "Sorry!"))
				if target then exports.anticheat:changeProtectedElementDataEx(target, "admin_level", ranks[1], true) end
				if ranks[1] == 0 then -- Remove all tickets if they get removed from admin
					dbExec(exports.mysql:getConn("core"), "UPDATE `tc_tickets` SET `assign_to`=NULL WHERE `assign_to`=?", userid)
				end
			end
			if ranks[2] and ranks[2] ~= tonumber(user.supporter) then
				tail = tail.."supporter="..ranks[2]..","
				mysql:query_free("INSERT INTO staff_changelogs SET userid="..userid..", details="..details..", `by`="..getElementData(thePlayer, "account:id")..", team=2, from_rank="..user.supporter..", to_rank="..ranks[2])
				exports.global:sendMessageToStaff("[STAFF UPDATE] "..exports.global:getPlayerFullIdentity(thePlayer, 1, true).." has "..(ranks[2] > tonumber(user.supporter) and "promoted" or "demoted").." '"..user.username.."' from "..staffTitles[2][tonumber(user.supporter)].." to "..staffTitles[2][ranks[2]]..".", true)
				exports.announcement:makePlayerNotification(target or user.id, "Staff Rank Updated", exports.global:getPlayerFullIdentity(thePlayer, 1, true).." has "..(ranks[2] > tonumber(user.supporter) and "promoted" or "demoted").." you from "..staffTitles[2][tonumber(user.supporter)].." to "..staffTitles[2][ranks[2]]..". \n" .. (ranks[2] > tonumber(user.supporter) and "Congratulations!" or "Sorry!"))
				if target then exports.anticheat:changeProtectedElementDataEx(target, "supporter_level", ranks[2], true) end
		
			end
			if ranks[3] and ranks[3] ~= tonumber(user.vct) then
				tail = tail.."vct="..ranks[3]..","
				mysql:query_free("INSERT INTO staff_changelogs SET userid="..userid..", details="..details..", `by`="..getElementData(thePlayer, "account:id")..", team=3, from_rank="..user.vct..", to_rank="..ranks[3])
				exports.global:sendMessageToStaff("[STAFF UPDATE] "..exports.global:getPlayerFullIdentity(thePlayer, 1, true).." has "..(ranks[3] > tonumber(user.vct) and "promoted" or "demoted").." '"..user.username.."' from "..staffTitles[3][tonumber(user.vct)].." to "..staffTitles[3][ranks[3]]..".", true)
				exports.announcement:makePlayerNotification(target or user.id, "Staff Rank Updated", exports.global:getPlayerFullIdentity(thePlayer, 1, true).." has "..(ranks[3] > tonumber(user.vct) and "promoted" or "demoted").." you from "..staffTitles[3][tonumber(user.vct)].." to "..staffTitles[3][ranks[3]]..". \n" .. (ranks[3] > tonumber(user.vct) and "Congratulations!" or "Sorry!"))
				if target then exports.anticheat:changeProtectedElementDataEx(target, "vct_level", ranks[3], true) end
		
			end
			if ranks[4] and ranks[4] ~= tonumber(user.scripter) then
				tail = tail.."scripter="..ranks[4]..","
				mysql:query_free("INSERT INTO staff_changelogs SET userid="..userid..", details="..details..", `by`="..getElementData(thePlayer, "account:id")..", team=4, from_rank="..user.scripter..", to_rank="..ranks[4])
				exports.global:sendMessageToStaff("[STAFF UPDATE] "..exports.global:getPlayerFullIdentity(thePlayer, 1, true).." has "..(ranks[4] > tonumber(user.scripter) and "promoted" or "demoted").." '"..user.username.."' from "..staffTitles[4][tonumber(user.scripter)].." to "..staffTitles[4][ranks[4]]..".", true)
				exports.announcement:makePlayerNotification(target or user.id, "Staff Rank Updated", exports.global:getPlayerFullIdentity(thePlayer, 1, true).." has "..(ranks[4] > tonumber(user.scripter) and "promoted" or "demoted").." you from "..staffTitles[4][tonumber(user.scripter)].." to "..staffTitles[4][ranks[4]]..". \n" .. (ranks[4] > tonumber(user.scripter) and "Congratulations!" or "Sorry!"))
				if target then exports.anticheat:changeProtectedElementDataEx(target, "scripter_level", ranks[4], true) end
		
			end
			if ranks[5] and ranks[5] ~= tonumber(user.mapper) then
				tail = tail.."mapper="..ranks[5]..","
				mysql:query_free("INSERT INTO staff_changelogs SET userid="..userid..", details="..details..", `by`="..getElementData(thePlayer, "account:id")..", team=5, from_rank="..user.mapper..", to_rank="..ranks[5])
				exports.global:sendMessageToStaff("[STAFF UPDATE] "..exports.global:getPlayerFullIdentity(thePlayer, 1, true).." has "..(ranks[5] > tonumber(user.mapper) and "promoted" or "demoted").." '"..user.username.."' from "..staffTitles[5][tonumber(user.mapper)].." to "..staffTitles[5][ranks[5]]..".", true)
				exports.announcement:makePlayerNotification(target or user.id, "Staff Rank Updated", exports.global:getPlayerFullIdentity(thePlayer, 1, true).." has "..(ranks[5] > tonumber(user.mapper) and "promoted" or "demoted").." you from "..staffTitles[5][tonumber(user.mapper)].." to "..staffTitles[5][ranks[5]]..". \n" .. (ranks[5] > tonumber(user.mapper) and "Congratulations!" or "Sorry!"))
				if target then exports.anticheat:changeProtectedElementDataEx(target, "mapper_level", ranks[5], true) end
		
			end
			if ranks[6] and ranks[6] ~= tonumber(user.fmt) then
				tail = tail.."fmt="..ranks[6]..","
				mysql:query_free("INSERT INTO staff_changelogs SET userid="..userid..", details="..details..", `by`="..getElementData(thePlayer, "account:id")..", team=6, from_rank="..user.fmt..", to_rank="..ranks[6])
				exports.global:sendMessageToStaff("[STAFF UPDATE] "..exports.global:getPlayerFullIdentity(thePlayer, 1, true).." has "..(ranks[6] > tonumber(user.fmt) and "promoted" or "demoted").." '"..user.username.."' from "..staffTitles[6][tonumber(user.fmt)].." to "..staffTitles[6][ranks[6]]..".", true)
				exports.announcement:makePlayerNotification(target or user.id, exports.global:getPlayerFullIdentity(thePlayer, 1, true).." has "..(ranks[6] > tonumber(user.fmt) and "promoted" or "demoted").." you from "..staffTitles[6][tonumber(user.fmt)].." to "..staffTitles[6][ranks[6]]..".", (ranks[6] > tonumber(user.fmt) and "Congratulations!" or "Sorry!"))
				if target then exports.anticheat:changeProtectedElementDataEx(target, "fmt_level", ranks[6], true) end
		
			end
			if tail ~= '' then
				tail = string.sub(tail, 1, string.len(tail)-1)
				if not dbExec(mysql:getConn("core"), dbPrepareString(mysql:getConn("core"), "UPDATE accounts SET " .. tail .. " WHERE id=" .. userid)) then
					outputChatBox("Internal Error!", thePlayer, 255, 0, 0)
					return false
				end
			end
			triggerEvent("staff:getStaffInfo", thePlayer, user.username, "Staff rank for "..user.username.." has been set!")
		end
	end, {userid, staffTitles, target, userid, ranks, details, thePlayer}, exports.mysql:getConn("core"), "SELECT id, username, admin, supporter, vct, scripter, mapper, fmt FROM accounts WHERE id=?", userid)

end
addEvent("staff:editStaff", true)
addEventHandler("staff:editStaff", root, editStaff)

function makePlayerStaff(thePlayer, commandName, who, rank) --/ MAXIME
	if exports.integration:isPlayerSeniorAdmin(thePlayer) or exports.integration:isPlayerVehicleConsultant(thePlayer) or exports.integration:isPlayerLeadScripter(thePlayer) or exports.integration:isPlayerMappingTeamLeader(thePlayer) then
		if not (who) or not (tonumber(rank)) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Name/ID] [Staff Team ID] [Rank]", thePlayer, 255, 194, 14)
			outputChatBox("SYNTAX: /" .. commandName .. " [Exact Username] [Rank, -1 .. -4 = GMs, 1 .. 7 = Admins]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, who)
			local username = false
			local targetUsername = false
			local currentRank = false
			local adminID = false
			rank = tonumber(rank)

			if not targetPlayer then
				return false
			end

			targetUsername = getElementData(targetPlayer, "account:username")
			currentRank = getElementData(targetPlayer, "admin_level")
			adminID = getElementData(targetPlayer, "account:id")


			if (rank > 0) or (rank == -999999999) then
				exports.anticheat:changeProtectedElementDataEx(targetPlayer, "duty_admin", 1, true)
			else
				exports.anticheat:changeProtectedElementDataEx(targetPlayer, "duty_admin", 0, true)
			end

			if (rank < 0) then
				local gmrank = -rank
				outputChatBox("You set " .. targetPlayerName .. "'s GM rank to " .. tostring(gmrank) .. ".", thePlayer, 0, 255, 0)
				--outputChatBox(adminTitle .. " " .. username .. " set your GM rank to " .. gmrank .. ".", targetPlayer, 255, 194, 14)
				exports.anticheat:changeProtectedElementDataEx(targetPlayer, "account:gmlevel", gmrank, false)
				exports.anticheat:changeProtectedElementDataEx(targetPlayer, "duty_supporter", 1, true)
				exports.anticheat:changeProtectedElementDataEx(targetPlayer, "admin_level", 0, false)
				exports.anticheat:changeProtectedElementDataEx(targetPlayer, "duty_admin", 0, true)
			elseif rank == 0 then
				--outputChatBox(adminTitle .. " " .. username .. " removed your staff rank.", targetPlayer, 255, 194, 14)
				outputChatBox("You set " .. targetPlayerName .. " to Player.", thePlayer, 0, 255, 0)
				exports.anticheat:changeProtectedElementDataEx(targetPlayer, "admin_level", 0, false)
				exports.anticheat:changeProtectedElementDataEx(targetPlayer, "duty_admin", 0, true)
				exports.anticheat:changeProtectedElementDataEx(targetPlayer, "account:gmlevel", 0, false)
				exports.anticheat:changeProtectedElementDataEx(targetPlayer, "duty_supporter", 0, true)
			else
				--outputChatBox(adminTitle .. " " .. username .. " set your admin rank to " .. rank .. ".", targetPlayer, 255, 194, 14)
				outputChatBox("You set " .. targetPlayerName .. "'s Admin rank to " .. tostring(rank) .. ".", thePlayer, 0, 255, 0)
				exports.anticheat:changeProtectedElementDataEx(targetPlayer, "admin_level", rank, false)
				exports.anticheat:changeProtectedElementDataEx(targetPlayer, "duty_admin", 1, true)
				exports.anticheat:changeProtectedElementDataEx(targetPlayer, "account:gmlevel", 0, false)
				exports.anticheat:changeProtectedElementDataEx(targetPlayer, "duty_supporter", 0, true)
			end




			exports.logs:dbLog(thePlayer, 4, targetPlayer, "MAKEADMIN " .. rank)
			exports.global:updateNametagColor(targetPlayer)
		end
	end
end
--addCommandHandler("makestaff", makePlayerStaff, false, false)
