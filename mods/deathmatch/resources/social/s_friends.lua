--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

--[[ table is meant to be like
friends[accountID] = {
	name = name,
	message = message,
	lastOnline = timestamp,
	loadedFriends = false,
	player = nil
	[0] = first friend's account id,
	[1] = second friend's account id
]]
local friends = {}

--
-- Returns the current time
--
function now()
	return getRealTime().timestamp
end

--
-- loads data for an account
--
function loadAccountData( accountID )
	if accountID then
		local data = exports.mysql:query_fetch_assoc( "SELECT UNIX_TIMESTAMP(lastlogin) AS time, friendsmessage FROM account_details WHERE account_id = " .. exports.mysql:escape_string( accountID ) )
		if data then
			friends[ accountID ].name = exports.cache:getUsernameFromId(accountID) or "Unknown"
			friends[ accountID ].lastOnline = tonumber(data.time)
			friends[ accountID ].message = data.friendsmessage
			return true
		end
	end
	return false
end

--
-- loads all friends from the database
--
function loadFriends( accountID )
	if not friends[ accountID ] then
		return false, "Invalid data structure"
	end
	
	local result = exports.mysql:query( "SELECT friend_account_id FROM friends WHERE account_id = " .. exports.mysql:escape_string( accountID ) )
	if result then
		-- remove all existing friends
		while #friends[ accountID ] > 0 do
			table.remove( friends[ accountID ], 1 )
		end
		
		-- parse query information
		while true do
			local row = exports.mysql:fetch_assoc(result)
			if not (row) then
				break
			end
			
			table.insert( friends[ accountID ], tonumber( row.friend_account_id ) )
		end
		friends[ accountID ].loadedFriends = true
	else
		outputDebugString( "social:loadFriends - bad query " .. tostring( accountID ) .. " " .. type( accountID ) )
	end
	return false, "Query failed"
end

--
-- sends all his friends to the player himself.
--
local maxTime = 14 * 24 * 60 * 60
function sendFriends( player, accountID )
	if not accountID or not friends[ accountID ]then -- that happens.
		outputDebugString( "social:sendFriends - tried to call on non-existent ID " .. tostring( getPlayerName( player )) .. " " .. tostring( accountID ) .. " " .. tostring( friends[ accountID ]))
		return
	end
	
	local t = { }

	-- hacky workaround to get the lowest time, ideally making time calculations client-side workey.
	for _, otherAccount in ipairs( friends[ accountID ] ) do
		if not friends[ otherAccount ] then
			friends[ otherAccount ] = { }
		end
		
		if not friends[ otherAccount ].name then
			loadAccountData( otherAccount )
		end
		
		local friend = friends[ otherAccount ]
		if friend.name then
			-- this is a hack for horrible mta precision.
			local timestr = nil
			local la = friend.lastOnline or 0
			if now( ) - la > maxTime then
				timestr = formatTimeInterval( la )
			else
				la = maxTime - now( ) + la
			end
			
			table.insert( t, { otherAccount, friend.name, friend.message, friend.player or timestr or la } )
		else
			outputDebugString( "social:sendFriends: Account " .. otherAccount .. " does not exist?" )
			friends[ otherAccount ] = nil
		end
	end
	
	triggerClientEvent( player, "social:friends", player, t, friends[ accountID ].message, maxTime )
end

--
-- notifies all friends of his.
--
local status_on = 'Has logged on!'
local status_off = 'Has logged off.'
local status_msg = 'Has updated status message.'
local status_char = 'Is now playing as..'
function notifyFriendsOf( player, accountID, event, ... )
	for _, friend in ipairs( getElementsByType( "player" ) ) do
		local friendID = getElementData( friend, "account:id" )
		if friendID and friends[ friendID ] then
			for k, v in ipairs( friends[ friendID ] ) do
				if v == accountID then
					if event == 'social:statusUpdate' then
						if getElementData(friend, 'social_friend_updates') == '0' then
							break
						elseif ((...).noti == status_on or (...).noti == status_off) and getElementData(friend, 'social_friend_updates_on_off') == '0' then
							break
						elseif (...).noti == status_msg and getElementData(friend, 'social_friend_updates_msg') == '0' then
							break
						elseif (...).noti == status_char and getElementData(friend, 'social_friend_updates_char') == '0' then
							break
						end
					end
					triggerClientEvent( friend, event, player, accountID, ... )
					break
				end
			end
		end
	end
end


function onCharSpawn()
	if getElementData(source, 'loggedin') == 1 then
		local id = getElementData(source, 'account:id')
		local name = getElementData(source, 'account:username')
		local item = { time_out = 1000, alpha=255, accountID = id, name = name, player=source, message = friends[ id ].message, noti=status_char}
		notifyFriendsOf(source, id, 'social:statusUpdate', item)
	end
end
addEventHandler('account:character:spawned', root, onCharSpawn)

--
-- Logs into an account
--
addEvent("social:account")
addEventHandler("social:account", root,
	function( accountID )
		if not friends[ accountID ] then
			friends[ accountID ] = { }
		end
		
		-- load needed data name/message/lastonline, while maybe weird to load it -here- the same formula applies for all not-loggedin-yet accounts.
		if not friends[ accountID ].name then
			loadAccountData( accountID )
		end
		
		-- make sure a player's friends are loaded
		if not friends[ accountID ].loadedFriends then
			loadFriends( accountID )
		end
		
		friends[ accountID ].lastOnline = now( )
		friends[ accountID ].player = source
		
		sendFriends( source, accountID )
		notifyFriendsOf( source, accountID, "social:account" )
		local item = { time_out = 1000, alpha=255, accountID = accountID, name = getElementData( source, "account:username" ), player=source, message = friends[ accountID ].message, noti=status_on}
		notifyFriendsOf(source, accountID, 'social:statusUpdate', item)
	end
)

--
-- Log everyone who's ingame when starting this in
--
addEventHandler( "onResourceStart", resourceRoot,
	function( )
		for _, player in ipairs( getElementsByType( "player" ) ) do
			local accountID = getElementData( player, "account:id" )
			if accountID then
				friends[ accountID ] = { player = player, lastOnline = now( ) }
				loadAccountData( accountID )
				loadFriends( accountID )
			end
		end
	end
)

addEvent( "social:ready", true )
addEventHandler( "social:ready", root,
	function( )
		local accountID = getElementData( client, "account:id" )
		if accountID then
			sendFriends( client, accountID )
			notifyFriendsOf( client, accountID, "social:account" )
		end
	end
)

--
-- Delete old player references
--
addEventHandler( "onPlayerQuit", root,
	function( )
		local accountID = getElementData( source, "account:id" )
		if accountID and friends[ accountID ] then
			friends[ accountID ].player = nil
			friends[ accountID ].lastOnline = now( )
		end
		local item = { time_out = 1000, alpha=255, accountID = accountID, name = getElementData( source, "account:username" ), lastOnline=exports.datetime:now(), message = friends[ accountID ] and friends[ accountID ].message or '', noti=status_off}
		notifyFriendsOf(source, accountID, 'social:statusUpdate', item)
	end
)

--
-- Updating your own friends message
--
addEvent( "social:message", true )
addEventHandler( "social:message", root,
	function( message )
		local accountID = getElementData( client, "account:id" )
		if accountID and friends[ accountID ] then
			if mysql:query_free("UPDATE account_details SET friendsmessage = '" .. mysql:escape_string(message) .. "' WHERE account_id = " .. mysql:escape_string(accountID) ) then
				friends[ accountID ].message = message
				notifyFriendsOf( client, accountID, "social:message", message )
				triggerClientEvent( client, "social:message", client, accountID, message )
				local item = { time_out = 1000, alpha=255, accountID = accountID, name = getElementData( client, "account:username" ), player=client, message = friends[ accountID ].message, noti=status_msg}
				notifyFriendsOf(client, accountID, 'social:statusUpdate', item)
			end
		end
	end
)

--
-- Removing one of your friends
--
addEvent( "social:remove", true )
addEventHandler( "social:remove", root,
	function( otherAccount )
		local accountID = getElementData( client, "account:id" )
		if accountID and friends[ accountID ] and friends[ otherAccount ] then
			local found = false
			for k, v in ipairs( friends[ accountID ] ) do
				if v == otherAccount then
					found = k
				end
			end
			
			if not found then
				outputChatBox( "Not your friend.", client, 255, 0, 0 )
			else
				-- update the database accordingly
				mysql:query_free("DELETE FROM friends WHERE account_id = " .. mysql:escape_string(accountID) .. " AND friend_account_id = " .. mysql:escape_string(otherAccount) )
				mysql:query_free("DELETE FROM friends WHERE account_id = " .. mysql:escape_string(otherAccount) .. " AND friend_account_id = " .. mysql:escape_string(accountID) )
				
				-- remove the entries
				table.remove( friends[ accountID ], found )
				for k, v in ipairs( friends[ otherAccount ] or { } ) do
					if v == accountID then
						table.remove( friends[ otherAccount ], k )
						break
					end
				end
				
				-- let the people know
				triggerClientEvent( client, "social:remove", client, otherAccount )
				outputChatBox( "You removed " .. friends[ otherAccount ].name .. " from your friends list.", client, 0, 255, 0 )
				local other = friends[ otherAccount ].player
				if other then
					triggerClientEvent( other, "social:remove", other, accountID )
				end
			end
		end
	end
)

--
-- adding a player
--
local pendingFriends = { }
function new_addFriend( from, to )
	local fromID = getElementData( from, "account:id" )
	local toID = getElementData( to, "account:id" )
	if not fromID or not toID then
		outputChatBox( "Flying Unicorn Dipshit error. Did you try to login?", from, 255, 0, 0 )
		return
	end
	
	for k, v in ipairs({fromID, toID}) do
		if not friends[ v ] then
			friends[ v ] = { }
			outputDebugString( "Fixed friends list at the point A" .. tostring( v ))
		end
		
		if not friends[ v ].name then
			loadAccountData( v )
			outputDebugString( "Fixed friends list at the point B" .. tostring( v ))
		end
		
		-- make sure a palyer's friends are loaded
		if not friends[ v ].loadedFriends then
			loadFriends( v )
			outputDebugString( "Fixed friends list at the point C" .. tostring( v ))
		end
	end
	
	if fromID and friends[ fromID ] and toID and friends[ toID ] then
		local onFromList = false
		for k, v in ipairs( friends[ fromID ] ) do
			if v == toID then
				onFromList = true
			end
		end
		
		if onFromList then
			outputChatBox( getPlayerName( to ):gsub("_", " ") .. " is on your friends list as " .. friends[ toID ].name .. ".", from, 255, 194, 14 )
		else
			local onToList = false
			for k, v in ipairs( friends[ toID ] ) do
				if v == fromID then
					onToList = true
				end
			end
			
			if onToList then -- the OTHER player has him on his friends list. shouldn't happen, but oh well.
				mysql:query_free("INSERT INTO friends VALUES(" .. mysql:escape_string(fromID) .. ", " .. mysql:escape_string(toID) .. ")" )
				outputChatBox( getPlayerName( to ):gsub("_", " ") .. " has been added to your friends list as " .. friends[ toID ].name .. ".", from, 0, 255, 0 )
				table.insert( friends[ fromID ], toID )
				sendFriends( from, fromID )
			else
				-- need permissiosn first
				if getElementData(to,'social_invite_only') == '1' then
					outputChatBox(getPlayerName( to ):gsub("_", " ").." is ignoring all incoming friend requests. You must be invited by him to be his friend.", from, 255, 0, 0 )
				else
					triggerClientEvent( to, "askAcceptFriend", from )
					pendingFriends[ to ] = from
				end
			end
		end
	else
		outputChatBox( "Theoretically Impossible Error.", from, 255, 0, 0 )
	end
end

function addFriendCmd( thePlayer, commandName, targetPlayer )
   local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
   local fromID = getElementData( thePlayer, "account:id" )
   local toID = getElementData( targetPlayer, "account:id" )
   if not (targetPlayer) then
      outputChatBox( "SYNTAX: /" .. commandName .. " [ID]", thePlayer, 255, 194, 14)
      return
   elseif targetPlayer == thePlayer then
   		return not outputChatBox( "You can not add yourself.", thePlayer, 255, 0, 0 )
   end
   for k, v in ipairs({fromID, toID}) do
      if not friends[ v ] then
         friends[ v ] = { }
         outputDebugString( "Fixed friends list at the point A" .. tostring( v ))
      end
      
      if not friends[ v ].name then
         loadAccountData( v )
         outputDebugString( "Fixed friends list at the point B" .. tostring( v ))
      end
      
      -- make sure a palyer's friends are loaded
      if not friends[ v ].loadedFriends then
         loadFriends( v )
         outputDebugString( "Fixed friends list at the point C" .. tostring( v ))
      end
   end
   
   if fromID and friends[ fromID ] and toID and friends[ toID ] then
      local onFromList = false
      for k, v in ipairs( friends[ fromID ] ) do
         if v == toID then
            onFromList = true
         end
      end
      
      if onFromList then
         outputChatBox( getPlayerName( targetPlayer ):gsub("_", " ") .. " is on your friends list as " .. friends[ toID ].name .. ".", thePlayer, 255, 194, 14 )
      else
         local onToList = false
         for k, v in ipairs( friends[ toID ] ) do
            if v == fromID then
               onToList = true
            end
         end
         
         if onToList then -- the OTHER player has him on his friends list. shouldn't happen, but oh well.
            mysql:query_free("INSERT INTO friends VALUES(" .. mysql:escape_string(fromID) .. ", " .. mysql:escape_string(toID) .. ")" )
            outputChatBox( getPlayerName( targetPlayer ):gsub("_", " ") .. " has been added to your friends list as " .. friends[ toID ].name .. ".", thePlayer, 0, 255, 0 )
            table.insert( friends[ fromID ], toID )
            sendFriends( thePlayer, fromID )
         else
            -- need permissiosn first
            if getElementData(targetPlayer,'social_invite_only') == '1' then
            	outputChatBox(getPlayerName( targetPlayer ):gsub("_", " ").." is ignoring all incoming friend requests. You must be invited by him to be his friend.", thePlayer, 255, 0, 0 )
            else
	            outputChatBox("Friend request sent to "..getPlayerName( targetPlayer ):gsub("_", " ")..".", thePlayer, 0, 255, 0 )
	            triggerClientEvent( targetPlayer, "askAcceptFriend", thePlayer )
	            pendingFriends[ targetPlayer ] = thePlayer
	        end
         end
      end
   else
      outputChatBox( "Theoretically Impossible Error.", thePlayer, 255, 0, 0 )
   end
end
addCommandHandler("addfriend", addFriendCmd)
addEvent( "social:acceptFriend", true )
addEventHandler( "social:acceptFriend", root,
	function( )
		local to = client
		local from = pendingFriends[ client ]
		if not from or not to then
			outputChatBox( "You screwed this one up.", client, 255, 0, 0 )
		else
			local fromID = getElementData( from, "account:id" )
			local toID = getElementData( to, "account:id" )
			mysql:query_free("INSERT INTO friends VALUES(" .. mysql:escape_string(toID) .. ", " .. mysql:escape_string(fromID) .. ")" )
			mysql:query_free("INSERT INTO friends VALUES(" .. mysql:escape_string(fromID) .. ", " .. mysql:escape_string(toID) .. ")" )
			table.insert( friends[ fromID ], toID )
			table.insert( friends[ toID ], fromID )
			sendFriends( from, fromID )
			sendFriends( to, toID )
			outputChatBox( getPlayerName( to ):gsub("_", " ") .. " has been added to your friends list as " .. friends[ toID ].name .. ".", from, 0, 255, 0 )
			outputChatBox( getPlayerName( from ):gsub("_", " ") .. " has been added to your friends list as " .. friends[ fromID ].name .. ".", to, 0, 255, 0 )
		end
	end
)

--
-- exported function: isFriendOf
-- returns true if the player with toID has fromID on his friends list
--
function isFriendOf( fromID, toID )
	for k, v in ipairs( friends[ toID ] or {} ) do
		if v == fromID then
			return true
		end
	end
	return false
end
