function doGMPost(thePlayer, theCommand)
	if (exports['global']:isPlayerGameMaster(thePlayer)) or (exports['global']:isPlayerAdmin(thePlayer)) then
		triggerClientEvent(thePlayer, "gmpost:opengui", getRootElement())
	end
end
addCommandHandler("gmschool", doGMPost)

function GMForumPost(gmPlayers, gmNotes)
	--[[
	local username = getElementData(source, "account:username")
	local realTime = getRealTime()
	local notes = gmNotes:gsub("'","''")
	local fags1 = gmPlayers:gsub("'","''")
	local faggots = fags1:gsub(";",", ")
	local date = string.format("%04d/%02d/%02d", realTime.year + 1900, realTime.month + 1, realTime.monthday )
	local time = string.format("%02d:%02d", realTime.hour, realTime.minute )
	
	local threadTitle = ("[GM-School] "..username)
	local postID = exports.mysql:forum_query_insert_free("insert into post set threadid = '9999', parentid = '0', username = 'Chuevo', userid = '2', title = '" .. threadTitle .. "', dateline = unix_timestamp(), pagetext = '[CENTER][UGLOGO]-[/UGLOGO][/CENTER]<br>[SIZE=5][FONT=Franklin Gothic Medium][CENTER][B][COLOR=#FFF0F5]GameMaster School Executed[/COLOR][/B][/CENTER]<br>[/FONT][/SIZE][CENTER][IMG]http://i47.tinypic.com/2najk01.png[/IMG][/center]<br><br>[COLOR=#ffffff][FONT=Franklin Gothic Medium][COLOR=#FF8C00]GameMasters Username: [/COLOR] "..username.."<br>[COLOR=#FF8C00]Player Name: [/COLOR]"..faggots.."<br>[COLOR=#FF8C00]Date & Time: [/COLOR]"..date.." "..time.."<br>[COLOR=#FF8C00]Notes: [/COLOR]<br>"..notes.."[/font][/color]', allowsmilie = '1', showsignature = '0', ipaddress = '127.0.0.1', iconid = '0', visible = '1', attach = '0', infraction = '0', reportthreadid = '0'")
	local secondShit = exports.mysql:forum_query_insert_free("insert into thread set title = '" .. threadTitle .. "', firstpostid = '" .. postID .. "', lastpostid = '19285', lastpost = unix_timestamp(), forumid = '560', pollid = '0', open = '1', replycount = '0', postercount = '1', hiddencount = '0', deletedcount = '0', postusername = 'Chuevo', postuserid = '2', lastposter = 'Chuevo', lastposterid = '2', dateline = unix_timestamp(), views = '0', iconid = '0', visible = '1', sticky = '0', votenum = '0', votetotal = '0', attach = '0', force_read = '0', force_read_order = '10', force_read_expire_date = '0'")
		exports.mysql:forum_query_free("update post set threadid = '"..secondShit.."' where postid = '"..postID.."'")
		exports.mysql:forum_query_free("update `user` set posts = posts + 1 where userid = '2'")
		exports.mysql:forum_query_free("UPDATE forum set replycount = replycount + 1, lastpost = unix_timestamp(), lastposter = 'Chuevo', lastposterid='2', lastpostid='"..postID.."', lastthread='"..threadTitle.."', lastthreadid='"..secondShit.."', threadcount = threadcount + 1 WHERE forumid = 548")
		exports.mysql:forum_query_free("UPDATE forum set replycount = replycount + 1, lastpost = unix_timestamp(), lastposter = 'Chuevo', lastposterid='2', lastpostid='"..postID.."', lastthread='"..threadTitle.."', lastthreadid='"..secondShit.."', threadcount = threadcount + 1 WHERE forumid = 94")
		--exports.mysql:forum_query_free("UPDATE forum set replycount = replycount + 1, lastpost = unix_timestamp(), lastposter = 'Chuevo', lastposterid='2', lastpostid='"..postID.."', lastthread='"..threadTitle.."', lastthreadid='"..secondShit.."', threadcount = threadcount + 1 WHERE forumid = 93")
		exports.mysql:forum_query_free("UPDATE forum set replycount = replycount + 1, lastpost = unix_timestamp(), lastposter = 'Chuevo', lastposterid='2', lastpostid='"..postID.."', lastthread='"..threadTitle.."', lastthreadid='"..secondShit.."', threadcount = threadcount + 1 WHERE forumid = 28")
		exports.mysql:forum_query_free("UPDATE forum set replycount = replycount + 1, lastpost = unix_timestamp(), lastposter = 'Chuevo', lastposterid='2', lastpostid='"..postID.."', lastthread='"..threadTitle.."', lastthreadid='"..secondShit.."', threadcount = threadcount + 1 WHERE forumid = 560")
	for k, v in ipairs(exports.global:getGameMasters()) do
			outputChatBox("[GM-School] Automatic thread successfully created: http://www.forums.owlgaming.net/showthread.php/"..secondShit, v, 250, 217, 5)
	end
	for k, v in ipairs(exports.global:getAdmins()) do
		outputChatBox("[GM-School] Automatic thread successfully created: http://www.forums.owlgaming.net/showthread.php/"..secondShit, v, 250, 217, 5)
	end
	]]
end
addEvent("gmpost:submit", true)
addEventHandler("gmpost:submit", getRootElement(), GMForumPost)