function doIntTheft(thePlayer, theCommand, targetPlayerName)
	if (exports['global']:isPlayerAdmin(thePlayer)) then
		if not (targetPlayerName) then
			outputChatBox("SYNTAX: /" .. theCommand .. " [Target Partial Name / ID]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick( thePlayer, targetPlayerName )
			if (targetPlayerName) then
				local logged = getElementData(targetPlayer, "loggedin")
				if (logged==1) then
					local intID = getElementDimension(targetPlayer)
					if intID == 0 then
						outputChatBox("This player is not in an interior.", thePlayer, 255, 0, 0)
					else
						triggerClientEvent(thePlayer, "intpost:render", getRootElement(), targetPlayerName, intID, targetPlayer)
					end
				end
			end
		end
	end
end
-- Disabled temporarly.
--addCommandHandler("intpost", doIntTheft)

function intPost(intNotes, targetPlayer, targetPlayerName, interiorID)
	--[[
	local targetUsername = getElementData(targetPlayer, "account:username")
	local adminUsername = getElementData(source, "account:username")
	local realTime = getRealTime()
	local noteEdit = intNotes
	local notes = intNotes
	local date = string.format("%04d/%02d/%02d", realTime.year + 1900, realTime.month + 1, realTime.monthday )
	local time = string.format("%02d:%02d", realTime.hour, realTime.minute )
	local result3 = exports.mysql:query("SELECT `adminnote` FROM `interiors` WHERE `id`='" .. interiorID .."'")
	local note2 = " "
	if result3 then
		note2 = tostring(exports.mysql:fetch_assoc(result3)["adminnote"])
		exports.mysql:free_result(result3)
	end
	local plustext = ("--------- Interior Break-in --------- \r\nCharacter: " .. getPlayerName(targetPlayer):gsub("'","''"):gsub("_"," ") .. "\r\nDate: " .. date:gsub("'","''") .. "\r\nApproved by: " ..adminUsername:gsub("'","''").. "\r\nItems taken: \r\n" .. notes:gsub("'","''") .. "\r\n--------------------------------------")
	local result4 = exports.mysql:query_free("UPDATE `interiors` SET `adminnote`='" ..plustext:gsub("'","''").. "\r\n \r\n" ..note2:gsub("'","''").."' WHERE `id`=" ..interiorID)
	if result4 then
		outputChatBox("House ID " .. interiorID .. "'s /checkint updated.", source, 0, 255, 0)
	else
		outputChatBox("House ID " .. interiorID .. "'s /checkint failed to update.", source, 255, 0, 0)
	end
	exports["interior-manager"]:addInteriorLogs(interiorID, "approved break-in", source)
	exports.mysql:free_result(result4)

	local threadTitle = ("Interior " .. interiorID.. " - " ..getPlayerName(targetPlayer):gsub("_"," "))
	local postID = exports.mysql:forum_query_insert_free("insert into post set threadid = '9999', parentid = '0', username = 'Chuevo', userid = '2', title = '" .. threadTitle .. "', dateline = unix_timestamp(), pagetext = '[B]Players Name: [/B]" ..getPlayerName(targetPlayer):gsub("_"," ").." (" ..targetUsername..") <br>[B]Date: [/B] ".. date .. " <br>[B]Time: [/B] " ..time.. " <br> [B]House ID: [/B] " .. interiorID .. "<br>[B]Approved by: [/B]" .. adminUsername .. " <br>[B]Contents taken: [/B]<br> " .. notes .. "', allowsmilie = '1', showsignature = '0', ipaddress = '127.0.0.1', iconid = '0', visible = '1', attach = '0', infraction = '0', reportthreadid = '0'")
	local secondShit = exports.mysql:forum_query_insert_free("insert into thread set title = '" .. threadTitle .. "', firstpostid = '" .. postID .. "', lastpostid = '19285', lastpost = unix_timestamp(), forumid = '562', pollid = '0', open = '1', replycount = '0', postercount = '1', hiddencount = '0', deletedcount = '0', postusername = 'Chuevo', postuserid = '2', lastposter = 'Chuevo', lastposterid = '2', dateline = unix_timestamp(), views = '0', iconid = '0', visible = '1', sticky = '0', votenum = '0', votetotal = '0', attach = '0', force_read = '0', force_read_order = '10', force_read_expire_date = '0'")
		exports.mysql:forum_query_free("update post set threadid = '"..secondShit.."' where postid = '"..postID.."'")
		exports.mysql:forum_query_free("update `user` set posts = posts + 1 where userid = '2'")
		exports.mysql:forum_query_free("UPDATE forum set replycount = replycount + 1, lastpost = unix_timestamp(), lastposter = 'Chuevo', lastposterid='2', lastpostid='"..postID.."', lastthread='"..threadTitle.."', lastthreadid='"..secondShit.."', threadcount = threadcount + 1 WHERE forumid = 562")
		exports.mysql:forum_query_free("UPDATE forum set replycount = replycount + 1, lastpost = unix_timestamp(), lastposter = 'Chuevo', lastposterid='2', lastpostid='"..postID.."', lastthread='"..threadTitle.."', lastthreadid='"..secondShit.."', threadcount = threadcount + 1 WHERE forumid = 40")
		exports.mysql:forum_query_free("UPDATE forum set replycount = replycount + 1, lastpost = unix_timestamp(), lastposter = 'Chuevo', lastposterid='2', lastpostid='"..postID.."', lastthread='"..threadTitle.."', lastthreadid='"..secondShit.."', threadcount = threadcount + 1 WHERE forumid = 38")
		exports.mysql:forum_query_free("UPDATE forum set replycount = replycount + 1, lastpost = unix_timestamp(), lastposter = 'Chuevo', lastposterid='2', lastpostid='"..postID.."', lastthread='"..threadTitle.."', lastthreadid='"..secondShit.."', threadcount = threadcount + 1 WHERE forumid = 31")
	for k, v in ipairs(exports.global:getAdmins()) do
		local adminduty = getElementData(v, "duty_admin")
		if adminduty == 1 then
		outputChatBox("[INT-POST] " .. adminUsername .. " has approved an interior break-in for " .. getPlayerName(targetPlayer):gsub("_", " ").. " on interior ID " .. interiorID .. ".", v, 250, 217, 5)
		end
	end
	]]
end
addEvent("forum:intpost", true)
addEventHandler("forum:intpost", getRootElement(), intPost)