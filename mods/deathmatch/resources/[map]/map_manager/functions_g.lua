--[[
* ***********************************************************************************************************************
* Copyright (c) 2016 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

settings = {
	client_file = 'map.xml',
	map_content_max_length = 1000000,
	external_map_max_objects = 1000,
	external_map_max_concurrent_requests = 1,
}

function getReqStatus( v )
	if v.approved == 0 then
		return 'Pending', 255, 255, 255, 200
	elseif v.approved == 2 then
		return 'Declined', 255, 0, 0, 255
	else
		if v.enabled == 1 then 
			return 'Accepted & Implemented', 0, 255, 0, 255
		else
			return 'Accepted & Disabled', 255, 0, 0, 200
		end
	end
end

function getCurrentTimeString()
	local time = getRealTime()
	return "["..time.monthday.."/"..(time.month+1).."/"..(time.year+1900).."]"
end

function canAdminMaps( player )
	return exports.integration:isPlayerScripter( player, true ) or exports.integration:isPlayerMappingTeamMember( player, true ) or exports.integration:isPlayerHeadAdmin( player, true )
end

function canAccessMgmtTab( player )
	return exports.integration:isPlayerSupporter( player, true ) or exports.integration:isPlayerTrialAdmin( player, true ) or exports.integration:isPlayerScripter( player, true ) or exports.integration:isPlayerMappingTeamMember( player, true )
end

function canEditMap( player, map, tab_id )
	local isReqEditable = not exports.map_load:isMapLoaded( map.id ) and map.approved == 0
	if tab_id == 1 then
		return isReqEditable
	else
		return isReqEditable and canAdminMaps( player )
	end
end

function canDeleteMap( player, map, tab_id )
	if tab_id == 1 then
		return map.approved == 0 and map.enabled == 0 and not exports.map_load:isMapLoaded( map.id )
	elseif tab_id == 3 then
		return (not exports.map_load:isMapLoaded( map.id ) and map.enabled == 0) and canAdminMaps( player )
	end
	return false
end

function canAcceptMap( player, map, tab_id )
	return ( map.approved ~= 1 and map.enabled == 0 ) and canAdminMaps( player )
end

function canDeclineMap( player, map, tab_id )
	return ( map.approved ~= 2 and map.enabled == 0 ) and canAdminMaps( player )
end

function canImplementMap( player, map, tab_id ) 
	return map.approved == 1 and map.enabled ~= 1 and canAdminMaps( player )
end

function canDisableMap( player, map, tab_id )
	return map.approved == 1 and map.enabled == 1 and canAdminMaps( player )
end

function processMapContent( content, max_objects, content_is_filepath )
	local map = content_is_filepath or fileCreate( settings.client_file )                -- attempt to create a new file
	result, message = false, 'Errors occurred while processing map content. Code 341'
	if map then   
		if not content_is_filepath then                                
	    	fileWrite(map, content)      
	    	fileClose(map)
	    end
	    local root = xmlLoadFile ( content_is_filepath and content or settings.client_file )
	    if root then
	    	local objects = xmlNodeGetChildren( root )
	    	if objects then
	    		if #objects < 1 or #objects > settings.external_map_max_objects then
	    			result, message = false, "Your map ("..#objects.." objs) must contain at least one object and at most "..max_objects.." objects (including world object removals)."
	    		else
	    			local submit_objects = {}
	    			local int, dim
		    		for index, object in ipairs( objects ) do
		    			local submit_one_object = {}
		    			for name, value in pairs ( xmlNodeGetAttributes ( object ) ) do
					        submit_one_object[ name ] = tonumber(value) or value
					        if submit_one_object[ name ] == 'true' then
					        	submit_one_object[ name ] = 1
					        elseif submit_one_object[ name ] == 'false' then
					        	submit_one_object[ name ] = 0
					        end
					        -- validating
					        if name == 'interior' and value then
					        	if not int then
					        		int = value
					        	else
					        		if int ~= value then
					        			xmlUnloadFile( root )
					        			if not content_is_filepath then
		    								fileDelete( settings.client_file )
		    							end
		    							return false, 'All objects within one mapping must be in the same interior.'
		    						end
		    					end
		    				elseif name == 'dimension' and value then
		    					if not dim then
		    						dim = value
		    					else
		    						if dim ~= value then
		    							xmlUnloadFile( root )
		    							if not content_is_filepath then
		    								fileDelete( settings.client_file )
		    							end
		    							return false, 'All objects within one mapping must be in the same dimension.'
		    						end
		    					end
		    				end
					    end
					    table.insert( submit_objects, submit_one_object )
		    		end
		    		xmlUnloadFile( root )
		    		if not content_is_filepath then
		    			fileDelete( settings.client_file )
		    		end
		    		return submit_objects
		    	end
	    	else
	    		result, message = false, 'Error occurred while processing map content. Code 136.'
	    	end
	    	xmlUnloadFile( root )
	    else
	    	result, message = false, 'Error occurred while processing map content. Code 133.'
	    end
	    if not content_is_filepath then
	    	fileDelete( settings.client_file )
	    end
	end
	return result, message
end