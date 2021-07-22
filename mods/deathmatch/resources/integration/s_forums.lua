--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]
-- These are post processing functions to run after the thread has been posted. You can't pass functions through triggerEvent
-- 	so this is kinda the next best way to do it. Loadstring is not a good idea here.
local functions = {
	-- [forumID] = function() end
	[61] = (function(id, url, ...) -- Bans
		local banRecordID = {...}
		local banRecordID = tonumber(banRecordID[1])
		if url then
			exports.global:sendMessageToAdmins("[BAN] Ban topic created: "..url)
		end
		if id and banRecordID then
			dbExec( exports.mysql:getConn('core'), "UPDATE `bans` SET `threadid`=? WHERE `id`=?", id, banRecordID )
		end
	end),
}

function forumCallback(data, errno, ...)
	if not errno.success then
		outputDebugString("integration / createInForumID / Error response: ".. errno.statusCode)
	else
		local data = fromJSON(data)
		if data then
			local func_to_run = functions[data.forum.id]
			if func_to_run then
				func_to_run(data.id, data.url, ...)
			end
		end
	end
end

function createForumThread(createInForumID, fTitle, fContent, ...)
	--Validate
	if not createInForumID or not fTitle or not fContent or not tonumber(createInForumID) or string.len(fTitle) < 1 then
		outputDebugString("integration / createInForumID / Invalid parameters.")
		return false
	end

	-- Preconfigured settings
	local title = tostring(fTitle)
	local posterID = 39015 --Bot AI
	local key = tostring(get("forumsAPIKey"))

	-- Generate content, a table will run through as key, value pairs to generate a template. Otherwise use string
	-- {{"Banned User:", "Chaos"}, {"Banning Admin:", "Maxime"}} etc
	-- HEADER
	local content =
		[[
		<div style="text-align: center;">
			<img alt="OwlGaming.png" class="ipsImage" src="http://files.owlgaming.net/Logo/OwlGaming.png">
			<p></p>

			<p style="text-align: center;">
				<strong><span style="font-size:18px;">]] .. fTitle .. [[</span></strong>
			</p>
		</div>
		]]
	-- BODY
	if type(fContent) == "table" then
		for _, list in ipairs(fContent) do
			content = (content ..
				[[
				<strong>]] .. list[1] .. [[</strong>
					<p style="margin-left: 40px;">
						]] .. list[2] .. [[
					</p>
				]])
		end
	else
		content = (content ..
			[[
			<p>
				]] .. fContent .. [[
			</p>
			]])
	end
	-- FOOTER
	local content = (content ..
		[[
		<br>
		<u>Note: Please make a reply to this post with any additional information you may have.</u>
		]])

	-- Setup the remote call
	local options = {
		connectionAttempts = 5,
		method = "POST",
		formFields = {
			forum = createInForumID,
			author = posterID,
			title = title,
			post = content
		}
	}

	fetchRemote("https://forums.owlgaming.net/api/forums/topics?key="..key, options, forumCallback, {...})
end
addEvent('integration:createForumThread', false)
addEventHandler('integration:createForumThread', root, createForumThread)
