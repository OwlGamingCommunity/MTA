--[[
* ***********************************************************************************************************************
* Copyright (c) 2016 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

function submitExteriorMapRequest ( name, url, who, what, why, map, player, converter ) -- for some super weird reasons, mta built in mysql function refuses to work for half of the records if you loop it instantly, no idea why.
	local qh, res, nums, map_id
	if converter then
		local mysql = exports.mysql
		res, map_id = true, mysql:query_insert_free("INSERT INTO maps SET name='"..mysql:escape_string(name).."', preview='"..mysql:escape_string(url).."', purposes='"..mysql:escape_string(what).."', used_by='"..mysql:escape_string(who).."', reasons='"..mysql:escape_string(why).."', uploader='"..mysql:escape_string(getElementData( player, 'account:id' )).."', note='' ")
	else
		qh = dbQuery( exports.mysql:getConn('mta'), "INSERT INTO maps SET name=?, preview=?, purposes=?, used_by=?, reasons=?, uploader=?, note='' ", name, url, what, who, why, getElementData( player, 'account:id' ) )
		res, nums, map_id = dbPoll( qh, 10000 )
	end
	if res and map_id then
		for _, obj in ipairs( map ) do
			dbExec( exports.mysql:getConn('mta'), "INSERT INTO maps_objects SET map_id=?, id=?, interior=?, dimension=?, collisions=?, breakable=?, radius=?, model=?, lodModel=?, posX=?, posY=?, posZ=?, rotX=?, rotY=?, rotZ=?, doublesided=?, scale=?, alpha=?", map_id, obj.id, obj.interior, obj.dimension, obj.collisions, obj.breakable, obj.radius, obj.model, obj.lodModel, obj.posX, obj.posY, obj.posZ, obj.rotX, obj.rotY, obj.rotZ, obj.doublesided, obj.scale, obj.alpha )
		end
		return true
	else
		dbFree( qh )
		return false, 'Internal Error. Code 17.'
	end
end

function notifyPlayer( map_id, subject, content )
	local qh = dbQuery( exports.mysql:getConn('mta'), "SELECT m.uploader AS id FROM maps m WHERE m.id=? LIMIT 1", map_id )
	local res, nums, id2 = dbPoll( qh, 10000 )
	if res then
		if nums > 0 then
			if res[1].id and res[1].id > 0 then
				content = string.gsub( content, "<Username>", exports.cache:getUsernameFromId(res[1].id) )
				exports.announcement:makePlayerNotification( res[1].id, subject, content, 'map_manager' )
			end
		end
	else
		dbFree( qh )
	end
end

addCommandHandler( 'exportinteriormap', function ( player, cmd, dim )
	if ( exports.integration:isPlayerSeniorAdmin( player, true ) or exports.integration:isPlayerScripter( player, true ) ) and getElementData( player, 'loggedin' ) == 1 then
		if dim and tonumber(dim) and tonumber(dim) > 0 then
			dbQuery( function( qh, player, dim )
				local res , nums, inserted = dbPoll ( qh, 0 )
				if res then
					if nums > 0 then
						triggerClientEvent( player, 'map:exportinteriormap', resourceRoot, res )
						exports.logs:dbLog( player, 4, player, cmd.." int #"..dim )
					else
						outputChatBox( "No map objects found for interior #"..dim..".", player, 255, 0, 0 )
					end
				else
					outputChatBox( "Errors occurred while fetching map objects for interior #"..dim..".", player, 255, 0, 0 )
				end
			end, { player, dim }, exports.mysql:getConn('mta'), "SELECT * FROM objects WHERE dimension=? ", dim )
		else
			outputChatBox( "SYNTAX: /"..cmd.." [Interior ID]", player )
		end
	end
end, false, false )

addCommandHandler( 'exportexteriormap', function ( player, cmd, mapid )
	if ( exports.integration:isPlayerSeniorAdmin( player, true ) or exports.integration:isPlayerScripter( player, true ) or exports.integration:isPlayerMappingTeamLeader( player, true ) ) and getElementData( player, 'loggedin' ) == 1 then
		if mapid and tonumber(mapid) and tonumber(mapid) > 0 then
			dbQuery( function( qh, player, mapid )
				local res , nums, inserted = dbPoll ( qh, 0 )
				if res then
					if nums > 0 then
						triggerClientEvent( player, 'map:exportexteriormap', resourceRoot, res )
						exports.logs:dbLog( player, 4, player, cmd.." int #"..mapid )
					else
						outputChatBox( "No map objects found for map id #"..mapid..".", player, 255, 0, 0 )
					end
				else
					outputChatBox( "Errors occurred while fetching map objects for map id #"..mapid..".", player, 255, 0, 0 )
				end
			end, { player, mapid }, exports.mysql:getConn('mta'), "SELECT * FROM maps_objects WHERE map_id=? ", mapid )
		else
			outputChatBox( "SYNTAX: /"..cmd.." [Map ID from /maps]", player )
		end
	end
end, false, false )

addCommandHandler( 'convert_all_map_files', function ( player, cmd )
	if exports.integration:isPlayerScripter( player, true ) and getElementData( player, 'loggedin' ) == 1 then
		local count = { total = 0, processed = 0 }
		for _, map in ipairs( xmlNodeGetChildren( xmlLoadFile ( ':maps/meta.xml' ) ) ) do
			if xmlNodeGetName ( map ) == 'map' then
				count.total = count.total + 1
				for name, value in pairs ( xmlNodeGetAttributes ( map ) ) do
					if name == 'src' then
						local done, why_failed = processMapContent( ':maps/'..value, 9999, true )
						if done then
							local done2, why_failed2 = submitExteriorMapRequest ( value, 'N/A', 'N/A', 'N/A', 'Converted from previous map system.', done, player, true )
							if done2 then
								outputConsole( "[MAPS] convert_all_map_files / Processed map '"..value.."'.", player )
								count.processed = count.processed + 1
							else
								outputDebugString( "[MAPS] convert_all_map_files / Failed to process map '"..value.."'. Reason: "..why_failed2 )
								outputChatBox( "[MAPS] convert_all_map_files / Failed to process map '"..value.."'. Reason: "..why_failed2, player )
							end
						else
							outputDebugString( "[MAPS] convert_all_map_files / Failed to process map '"..value.."'. Reason: "..why_failed )
							outputChatBox( "[MAPS] convert_all_map_files / Failed to process map '"..value.."'. Reason: "..why_failed, player )
						end
					end
				end
			end
		end
		outputChatBox( "Converted "..count.processed.."/"..count.total.." files.", player, 255, 0, 0 )
	end
end, false, false )
