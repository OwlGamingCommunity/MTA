--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

-- keep track of all clothing items, used in shops afterwards
savedClothing = {}

addEventHandler('onResourceStart', resourceRoot, function()
	dbQuery(function (qh)
		local result, num_affected_rows, last_insert_id = dbPoll ( qh, 0 )
		if result then
			local count = 0
			for _, row in ipairs(result) do
				row.id = tonumber(row.id)
				row.skin = tonumber(row.skin)
				row.price = tonumber(row.price)
				row.creator_charname = row.creator_charname and string.gsub(row.creator_charname, "_", " ") or getGtaDesigners()
				row.creator_char = tonumber(row.creator_char)
				row.for_sale_until = tonumber(row.for_sale_until) or nil
				row.date = tonumber(row.date)
				row.mdate = tonumber(row.mdate) or 0
				row.fmdate = row.fmdate ~= mysql_null() and row.fmdate or nil
				row.distribution = tonumber(row.distribution)
				row.sold = tonumber(row.sold) or 0
				savedClothing[row.id] = row
				count = count + 1
			end
			outputDebugString('[CLOTHES] Server / Loaded ' .. count .. ' clothing items')
		end
	end, {}, exports.mysql:getConn('mta') , "SELECT cl.sold, cl.id, cl.skin, url, cl.description, cl.price, cl.creator_char, cl.distribution, "..
	"DATE_FORMAT(cl.date,'%b %d, %Y at %h:%i %p') AS fdate, "..
	"TO_SECONDS(cl.date) AS date, "..
	"DATE_FORMAT(cl.manufactured_date,'%b %d, %Y at %h:%i %p') AS fmdate, "..
	"TO_SECONDS(cl.manufactured_date) AS mdate, "..
	"CASE WHEN cl.creator_char>0 THEN c.charactername ELSE f.name END AS creator_charname, "..
	"CASE WHEN cl.for_sale_until IS NOT NULL THEN TO_SECONDS(cl.for_sale_until) ELSE 0 END AS for_sale_until "..
	"FROM clothing cl LEFT JOIN characters c ON cl.creator_char=c.id "..
	"LEFT JOIN factions f ON cl.creator_char=-f.id "..
	"ORDER BY cl.date DESC, cl.id DESC" )
end)

-- returns the file path for a texture file
function getPath(clothing)
	return 'cache/' .. tostring(clothing) .. '.tex'
end

-- loads a skin from an url
function loadFromURL(url, id)
	fetchRemote(url, "clothes", function(str, errno)
			if str == 'ERROR' then
				triggerEvent('clothing:delete', resourceRoot, id)
				outputDebugString('[CLOTHES] / Server / clothing:stream - unable to fetch removing #'..id..' ' .. url, 2)
			else
				local file = fileCreate(getPath(id))
				fileWrite(file, str)
				fileClose(file)

				if data and  data.pending then
					triggerLatentClientEvent(data.pending, 'clothing:file', resourceRoot, id, str)
					data.pending = nil
				end
			end
		end)
end

-- send clothing to the client
addEvent( 'clothing:stream', true )
addEventHandler( 'clothing:stream', resourceRoot,
	function(id)
		local id = tonumber(id)
		-- if its not a number, this'll fail
		if type(id) == 'number' then
			local data = savedClothing[id]
			if data then
				local path = getPath(id)
				if fileExists(path) then
					local file = fileOpen(path, true)
					if file then
						local size = fileGetSize(file)
						local content = fileRead(file, size)

						if #content == size then
							triggerLatentClientEvent(client, 'clothing:file', resourceRoot, id, content)
							fileClose(file)
						else
							outputDebugString('clothing:stream - file ' .. path .. ' read ' .. #content .. ' bytes, but is ' .. size .. ' bytes long')
							fileClose(file)
							fileDelete(path)
						end
					else
						outputDebugString('clothing:stream - file ' .. path .. ' existed but could not be opened?')
						fileClose(file)
						fileDelete(path)
					end
				else
					-- try to reload the file from the given url
					if data.pending then
						table.insert(data.pending, client)
					else
						data.pending = { client }
						loadFromURL(data.url, id)
					end
				end
			else
				--outputDebugString('[CLOTHES] Server / clothing:stream - clothes #' .. id .. ' does not exist.')
			end
		end
	end, false)

addEvent('clothes:duty:fetchFactionSkins', true)
addEventHandler('clothes:duty:fetchFactionSkins', root, function ()
	local fid = getElementData(source, 'faction')
	local tab = {}
	for id, value in pairs(savedClothing) do
		if value.distribution == 5 and fid[-value.creator_char] then
			table.insert(tab, value.skin..':'..id)
		end
	end
	triggerClientEvent( source, 'faction:dutySkins', source, tab)
end)

addEvent( 'clothes:tempfix', true )
addEventHandler( 'clothes:tempfix', resourceRoot, function ()
	local theResource = getResourceFromName("clothes")
	restartResource( theResource )
end)
