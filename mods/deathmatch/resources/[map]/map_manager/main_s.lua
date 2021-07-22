--[[
* ***********************************************************************************************************************
* Copyright (c) 2016 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

addEvent( 'maps:managerTabSync', true )
addEventHandler( 'maps:managerTabSync', resourceRoot, function( tabID, dontShowPopUp )
	if tabID == 1 then -- my reqs
		dbQuery( function( qh, client, tabID )
			local res, nums, id = dbPoll( qh, 0 )
			if res then
				triggerLatentClientEvent( client, 'maps:populateTab', resourceRoot, tabID, 'ok', res, dontShowPopUp )
			else
				dbFree( qh )
				triggerClientEvent( client, 'maps:populateTab', resourceRoot, tabID, 'Error code 21 occurred while synchronizing data.', nil, dontShowPopUp )
			end
		end , { client, tabID }, exports.mysql:getConn('mta'), "SELECT m.*, m.reviewer AS reviewer FROM maps m WHERE uploader=? ORDER BY m.approved, m.enabled, m.id DESC", getElementData( client, 'account:id' ) )
	elseif tabID == 3 then --mgmt
		dbQuery( function( qh, client, tabID )
			local res, nums, id = dbPoll( qh, 0 )
			if res then
				triggerLatentClientEvent( client, 'maps:populateTab', resourceRoot, tabID, 'ok', res, dontShowPopUp )
			else
				dbFree( qh )
				triggerClientEvent( client, 'maps:populateTab', resourceRoot, tabID, 'Error code 21 occurred while synchronizing data.', nil, dontShowPopUp )
			end
		end , { client, tabID }, exports.mysql:getConn('mta'), "SELECT m.*, m.reviewer AS reviewer_name, m.uploader AS uploader_name FROM maps m ORDER BY m.approved, m.enabled, m.id DESC" )
	end
end)

addEvent( 'maps:submitExteriorMapRequest', true )
addEventHandler( 'maps:submitExteriorMapRequest', resourceRoot, function( name, url, who, what, why, map ) 
	if not canAdminMaps( client ) then
		local check = dbQuery( exports.mysql:getConn('mta'), "SELECT COUNT(id) AS count FROM maps WHERE approved=0 AND type='exterior' AND uploader=?", getElementData( client, 'account:id' ) )
		local res1, nums1, id1 = dbPoll( check, 10000 )
		if res1 and nums1 > 0 then	
			if res1[1].count >= settings.external_map_max_concurrent_requests then
				return not triggerClientEvent( client, 'maps:exteriorMapRequestResponse', resourceRoot, "You're currently having "..res1[1].count.." pending approval maps. Please wait or cancel your previous requests." )
			end
		else
			dbFree( check )
			triggerClientEvent( client, 'maps:exteriorMapRequestResponse', resourceRoot, 'Internal Error. Code 34.' )
		end
	end

	local done, why_failed = submitExteriorMapRequest ( name, url, who, what, why, map, client ) 
	triggerClientEvent( client, 'maps:exteriorMapRequestResponse', resourceRoot, done and 'ok' or why_failed )
end )

addEvent( 'maps:updateReq', true )
addEventHandler( 'maps:updateReq', resourceRoot, function ( tabid, name, url, who, what, why, id ) 
	dbQuery( function( qh, client, tabid )
		local res, nums, id = dbPoll( qh, 0 )
		if res and nums > 0 then
			triggerClientEvent( client, 'maps:updateMyReqResponse', resourceRoot, 'ok', tabid )
		else
			triggerClientEvent( client, 'maps:updateMyReqResponse', resourceRoot, 'Errors occurred while updating map data. Code 64.' )
		end
	end , { client, tabid }, exports.mysql:getConn('mta'), "UPDATE maps SET name=?, preview=?, used_by=?, purposes=?, reasons=? WHERE id=?", name, url, who, what, why, id )
end )

addEvent( 'maps:delReq', true )
addEventHandler( 'maps:delReq', resourceRoot, function ( tabID, id ) 
	dbQuery( function( qh, client, tabID, id )
		local res, nums, id1 = dbPoll( qh, 0 )
		if res and nums > 0 then
			triggerClientEvent( client, 'maps:updateMyReqResponse', resourceRoot, 'ok', tabID )
			dbExec( exports.mysql:getConn('mta'), "DELETE FROM maps_objects WHERE map_id=?", id )
		else
			triggerClientEvent( client, 'maps:updateMyReqResponse', resourceRoot, 'Errors occurred while deleting map data. Code 73.' )
		end
	end , { client, tabID, id }, exports.mysql:getConn('mta'), "DELETE FROM maps WHERE id=?", id )
end )

addEvent( 'maps:testMap', true )
addEventHandler( 'maps:testMap', resourceRoot, function ( map_id ) 
	local res = exports.map_load:getMapObjects( map_id )
	if res then
		triggerLatentClientEvent( client, 'maps:testMap', resourceRoot, 'ok', res, map_id )
	else
		triggerClientEvent( client, 'maps:testMap', resourceRoot, 'Errors occurred while querying map contents. Code 97.' )
	end
end)

addEvent( 'maps:approveRequest', true )
addEventHandler( 'maps:approveRequest', resourceRoot, function( map_id, note, accepting )
	note = getCurrentTimeString().." "..exports.global:getPlayerFullIdentity( client, 1 )..": "..(accepting and "ACCEPTED" or "DECLINED")..". "..note.."\n"
	dbQuery( function( qh, client, map_id, note )
		local res, nums, id = dbPoll( qh, 0 )
		if res and nums > 0 then
			triggerClientEvent( client, 'maps:approveRequest', resourceRoot, 'ok', map_id, accepting )
			notifyPlayer( map_id, "Your exterior map addition request status updates.", "Hello <Username>!\n\nYour exterior map addition request #" .. map_id .. " has been "..(accepting and "ACCEPTED" or "DECLINED")..".\n\n"..note.."\nSincerely,\nOwlGaming Community\nOwlGaming Mapping Team" )
		else
			dbFree( qh )
			triggerClientEvent( client, 'maps:approveRequest', resourceRoot, 'Errors occurred while processing request. Code 110.' )
		end
	end , { client, map_id, note }, exports.mysql:getConn('mta'), "UPDATE maps SET approved=?, note=CONCAT(note, ?), reviewer=? WHERE id=?", accepting and 1 or 2, note, getElementData( client, 'account:id' ), map_id  )
end)

addEvent( 'maps:implement', true )
addEventHandler( 'maps:implement', resourceRoot, function( map_id, implementing )
	local note = getCurrentTimeString().." "..exports.global:getPlayerFullIdentity( client, 1 )..": "..(implementing and "Implemented map." or "Disabled map.").."\n"
	dbQuery( function( qh, client, map_id, note )
		local res, nums, id = dbPoll( qh, 0 )
		if res and nums > 0 then
			if implementing and exports.map_load:loadMap( map_id ) or exports.map_load:unloadMap( map_id ) then
				triggerClientEvent( client, 'maps:implement', resourceRoot, 'ok', map_id, implementing )
				notifyPlayer( map_id, "Your exterior map status updates.", "Hello <Username>!\n\nYour exterior map #" .. map_id .. " has been "..(implementing and "IMPLEMENTED" or "DISABLED")..".\n\n"..note.."\nSincerely,\nOwlGaming Community\nOwlGaming Mapping Team" )
			else
				triggerClientEvent( client, 'maps:implement', resourceRoot, 'Errors occurred while '..(implementing and 'implementing' or 'disabling')..' the map. Code 122.' )
			end
		else
			dbFree( qh )
			triggerClientEvent( client, 'maps:implement', resourceRoot, 'Errors occurred while '..(implementing and 'implementing' or 'disabling')..' the map. Code 124.' )
		end
	end , { client, map_id, note }, exports.mysql:getConn('mta'), "UPDATE maps SET enabled=?, approved=1, note=CONCAT(note, ?) WHERE id=?", implementing and 1 or 0, note, map_id )
end )
