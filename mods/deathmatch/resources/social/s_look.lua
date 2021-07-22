--[[
	@title
		Advanced Look System
	@author
		Cyanide (well, except for it has been changed altogether)
		mabako
	@copyright
		2012 - Valhalla Gaming
	@description
		http://bugs.mta.vg/view.php?id=559
--]]

function padTable( t, size )
	for i = 1, size do
		if not t[i] then
			t[i] = ""
		end
	end
end
	
addCommandHandler( "look",
	function( thePlayer, commandName, targetPlayer )
		if not targetPlayer then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then
				triggerEvent( "social:look", targetPlayer, thePlayer )
			end
		end
	end
)

addCommandHandler( "editlook",
	function( player, command )
		triggerEvent( "social:look", player, player, ":edit" )
	end
)

addEvent( "social:look", true )
addEventHandler( "social:look", root,
	function( targetPlayer, event )
		local targetPlayer = client or targetPlayer

		if getElementData( source, "loggedin" ) ~= 1 or getElementData( targetPlayer, "loggedin" ) ~= 1 then
			return
		end
		

		event = "social:look" .. ( event or "" )
		
		local look = getElementData( source, "look" )
		padTable( look, 7 )
		
		look[8] = {}
		-- add all badge info
		for itemID, badge in pairs( exports['item-system']:getBadges() ) do
			if getElementData(source, badge[1]) then
				if itemID == 122 or itemID == 123 or itemID == 124 or itemID == 125 then
					local itemName = exports['item-system']:getItemName( itemID )
					--table.insert( look[8], badge[2]:sub( badge[2]:find( " " ) + 1 ) )
					table.insert( look[8], itemName )
				else
					table.insert( look[8], badge[2]:sub( badge[2]:find( " " ) + 1 ) .. " - " .. (getElementData( source, badge[1] ) or 'N/A') )
				end
			end
		end
		
		-- add all mask info
		for itemID, mask in pairs( exports['item-system']:getMasks() ) do
			if getElementData( source, mask[1] ) then
				table.insert( look[8], mask[1]:sub(1,1):upper() .. mask[1]:sub(2) )
			end
		end
		
		if exports.global:hasItem( source, 48 ) and exports.artifacts:isPlayerWearingArtifact(source, "backpack") then
			table.insert( look[8], "Backpack" )
		end

		if exports.global:hasItem( source, 163 ) and exports.artifacts:isPlayerWearingArtifact(source, "dufflebag") then 
			table.insert( look[8], "Dufflebag" )
		end
		
		if exports.global:hasItem( source, 164 ) and exports.artifacts:isPlayerWearingArtifact(source, "medicbag") then 
			table.insert( look[8], "Medicbag" )
		end

		if getElementData(source, "gloves") then
			table.insert(look[8], getElementData(source, "gloves:name") or "Gloves")
		end
		
		triggerClientEvent( targetPlayer, event, source, getElementData( source, "age" ), getElementData( source, "race" ), getElementData( source, "gender" ), getElementData( source, "weight" ), getElementData( source, "height" ), look )
	end
)


addEvent( "social:look:update", true )
addEventHandler( "social:look:update", root,
	function( key, value, player )
		if getElementData( client, "loggedin" ) ~= 1 then
			return
		end
		local admin = false
		if player and player ~= client then
			if exports.global:isAdminOnDuty(client) then
				admin = client
				client = player
				if getElementData( client, "loggedin" ) ~= 1 then
					return
				end
			end
		end
		
		local valid, stuff = false
		for k, v in ipairs( editables ) do
			if v.index == key then
				valid = v.verify( value )
				stuff = v
				break
			end
		end
		
		if not valid then
			if admin then
				outputChatBox( "Error LOOK-" .. tostring(key) .. "-" .. tostring(value) .. ".", admin, 255, 0, 0 )
			else
				outputChatBox( "Error LOOK-" .. tostring(key) .. "-" .. tostring(value) .. ".", client, 255, 0, 0 )
			end
		else
			if key == "weight" or key == "height" then
				if exports.mysql:query_free("UPDATE characters SET " .. exports.mysql:escape_string( key ) .. " = '" .. exports.mysql:escape_string( value ) .. "' WHERE id = " .. exports.mysql:escape_string( getElementData( client, "dbid" ) ) ) then
					exports.anticheat:changeProtectedElementDataEx( client, key, value, false)
					if admin then
						local targetPlayerName = getPlayerName(client)
						outputChatBox( "You set " .. targetPlayerName .. "'s " .. stuff.name .. " to " .. value .. ".", admin, 0, 255, 0 )
						exports.logs:dbLog(admin, 4, client, "editlook '" .. stuff.name .. "' set to '" .. value .. "'")
						local hiddenAdmin = getElementData(admin, "hiddenadmin")
						local adminTitle = exports.global:getPlayerAdminTitle(admin)
						if not value or value == "" then value = "none" end
						if (hiddenAdmin==0) then
							outputChatBox(tostring(adminTitle) .. " " .. getPlayerName(admin) .. " set your " .. stuff.name .. " to " .. value .. ".", client, 0, 255, 0)
						else
							outputChatBox("A Hidden Admin set your " .. stuff.name .. " to " .. value .. ".", client, 0, 255, 0)
						end
					else
						if not value or value == "" then value = "none" end
						outputChatBox( "Set your " .. stuff.name .. " to " .. value .. ".", client, 0, 255, 0 )
					end
				else
					outputChatBox( "Failed to update " .. stuff.name .. ".", client, 255, 0, 0 )
				end
			else
				local look = getElementData( client, "look" )
				look[ key ] = value
				padTable( look, 7 )
				
				if exports.mysql:query_free("UPDATE characters SET description = '" .. exports.mysql:escape_string( toJSON( look ) ) .. "' WHERE id = " .. exports.mysql:escape_string( getElementData( client, "dbid" ) ) ) then
					exports.anticheat:changeProtectedElementDataEx( client, "look", look, false)
					if admin then
						local targetPlayerName = getPlayerName(client)
						outputChatBox( "You set " .. targetPlayerName .. "'s " .. stuff.name .. " to " .. value .. ".", admin, 0, 255, 0 )
						exports.logs:dbLog(admin, 4, client, "editlook '" .. stuff.name .. "' set to '" .. value .. "'")
						local hiddenAdmin = getElementData(admin, "hiddenadmin")
						local adminTitle = exports.global:getPlayerAdminTitle(admin)
						if not value or value == "" then value = "none" end
						if (hiddenAdmin==0) then
							outputChatBox(tostring(adminTitle) .. " " .. getPlayerName(admin) .. " set your " .. stuff.name .. " to " .. value .. ".", client, 0, 255, 0)
						else
							outputChatBox("A Hidden Admin set your " .. stuff.name .. " to " .. value .. ".", client, 0, 255, 0)
						end
					else
						if not value or value == "" then value = "none" end
						outputChatBox( "Set your " .. stuff.name .. " to " .. value, client, 0, 255, 0 )
					end
				else
					if admin then
						outputChatBox( "Failed to update " .. stuff.name .. ".", admin, 255, 0, 0 )
					else
						outputChatBox( "Failed to update " .. stuff.name .. ".", client, 255, 0, 0 )
					end
				end
			end
		end
	end
)
