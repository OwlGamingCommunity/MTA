
--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

local cache = 1000*60*5 -- 5 mins
local last = getTickCount()
local releases = nil

function showReleases()
	if not releases or getTickCount() - last > cache then
		releases = ''
		local q = exports.mysql:query("SELECT title, DATE_FORMAT(FROM_UNIXTIME(date),'%b %d, %Y') AS fdate FROM ucp_release_notes ORDER BY date DESC LIMIT 500")
		while q do
			local row = exports.mysql:fetch_assoc(q)
			if not row then break end
			releases = releases.."■ "..row.fdate..": "..row.title.."\n"
		end
		exports.mysql:free_result(q)
		last = getTickCount()
	end
	triggerClientEvent(source, 'debug:releases', source, releases)
end
addEvent('debug:releases', true)
addEventHandler('debug:releases', root, showReleases)