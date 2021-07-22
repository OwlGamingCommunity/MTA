--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

local online = { }
local offline = { }

--
-- Returns the current time
--
local time = 0
local timeSet = 0
function now()
	-- MTA precision sucks.
	local ticksec = ( getTickCount( ) - timeSet ) / 1000
	return math.floor( time + ticksec )
end

--
-- Sort algorithms
--
function byName( a, b )
	if a.player == localPlayer then
		return true
	elseif b.player == localPlayer then
		return false
	end
	return a.name:lower( ) < b.name:lower( )
end

-- returns the most recent time
-- this is mostly messy due to MTA client precision -> we send everything over 14 days as formatted string ("14 days")
function byTime( a, b )
	if a.lastOnline == b.lastOnline then
		return byName( a, b )
	end
	if type( a.lastOnline ) == "string" then
		if type( b.lastOnline ) == "number" then
			return false -- b.lastOnline is within 14 days, a.lastOnline is not
		else
			local ax = tonumber( a.lastOnline:sub( 1, a.lastOnline:find(" ") ) )
			local bx = tonumber( b.lastOnline:sub( 1, b.lastOnline:find(" ") ) )
			return ax < bx
		end
	else
		if type( b.lastOnline ) == "number" then
			return a.lastOnline > b.lastOnline
		else
			return true -- b.lastOnline isn't even within 14 days, so a is obviously more recent
		end
	end
end

local function testSort(a, b, a_more_recent)
	if byTime({lastOnline = a}, {lastOnline = b}) ~= a_more_recent then
		outputDebugString( "Sorting failed on " .. tostring( a ) .. " " .. tostring( b ) )
	end
end
testSort( 20, 10, true )
testSort( 20, "5 days", true )
testSort( "5 days", 10, false )
testSort( "14 days", "5 days", false )

--
-- receives all friends
--
addEvent( "social:friends", true )
addEventHandler( "social:friends", localPlayer,
	function( friendsList, ownMessage, currentTimestamp )
		-- calculate the difference between server time and client time so we can actually display the correct time
		time = currentTimestamp
		timeSet = getTickCount( )
		-- MTA precision breaks this. is this slightly accurate on all timezones?

		-- save the friends list
		online = { }
		offline = { }

		-- insert yourself :o
		table.insert( online, { accountID = getElementData( localPlayer, "account:id"), name = getElementData( localPlayer, "account:username" ), message = tostring(ownMessage), player = localPlayer, editable = true })

		for _, data in ipairs( friendsList ) do
			if type( data[4] ) == "number" or type( data[4] ) == "string" then
				table.insert( offline, { accountID = data[1], name = data[2], message = tostring(data[3]), lastOnline = data[4] } )
			else
				table.insert( online, { accountID = data[1], name = data[2], message = tostring(data[3]), player = data[4] } )
			end
		end
		table.sort( online, byName )
		table.sort( offline, byTime )
		outputDebugString( "Received " .. #friendsList .. " friends.")
	end
)

--
-- account logged in
--
addEvent( "social:account", true )
addEventHandler( "social:account", root,
	function( accountID )
		-- find offline account
		local data = nil
		for k, v in ipairs( offline ) do
			if v.accountID == accountID then
				data = v
				table.remove( offline, k )
				break
			end
		end

		if not data then
			return
		end

		data.lastOnline = nil
		data.player = source
		table.insert( online, data )
		table.sort( online, byName )
	end
)

--
-- account logged out
--
--[[
			addEvent( "social:off", true ) - test code, evidently.
			addEventHandler( "social:off", root,
				function( accountID )
]]
addEventHandler( "onClientPlayerQuit", root,
	function( )
		-- find online account
		local data = nil
		for k, v in ipairs( online ) do
			-- if v.accountID == accountID then
			if v.player == source then
				data = v
				table.remove( online, k )
				break
			end
		end

		if not data then
			return
		end

		-- set as offline
		data.lastOnline = now( )
		data.player = nil
		table.insert( offline, data )
		table.sort( offline, byTime )
	end
)

--
-- tell the server we're ready to receive notifications.
--
addEventHandler( "onClientResourceStart", resourceRoot,
	function( )
		triggerServerEvent( "social:ready", localPlayer )
	end
)

--
-- Your friend changed his message
--
addEvent( "social:message", true )
addEventHandler( "social:message", root,
	function( accountID, message )
		for _, lists in ipairs( { online, offline } ) do
			for k, v in ipairs( lists ) do
				if v.accountID == accountID then
					v.message = message
					return
				end
			end
		end
	end
)

--
-- Your friend got removed.
--
addEvent( "social:remove", true )
addEventHandler( "social:remove", root,
	function( accountID )
		for _, lists in ipairs( { online, offline } ) do
			for k, v in ipairs( lists ) do
				if v.accountID == accountID then
					table.remove( lists, k )
					return
				end
			end
		end
	end
)

--------------------------------------------------------------------------------
local function isInBox( x, y, xmin, xmax, ymin, ymax )
	return x and y and x >= xmin and x <= xmax and y >= ymin and y <= ymax
end


local white = tocolor( 255, 255, 255, 255 )
function makeFonts(new_style)
	font = font or dxCreateFont( ":resources/segoeuil.ttf", 12 ) or "default"
	font2 = font2 or dxCreateFont(':interior_system/intNameFont.ttf', 10) or "default"
	font3 = font3 or "default" --dxCreateFont(':resources/segoeuil.ttf')
	font4 = font4 or "default" --dxCreateFont(':resources/clashofclans.ttf') or "default"
end

local scroll_y = 0.1
local min_scroll_y = -5
local max_scroll_y = 0.1

-- Drawing stuff
local container_width, container_height, padding = 250, 100, 10
-- calculate the maximum numbers of stuff to fit on one line
local screen_x, screen_y = guiGetScreenSize( )
local max_containers = math.floor( screen_x / ( container_width + padding ) )
local container_start_x = ( screen_x - ( max_containers * ( container_width + padding ) ) + padding ) / 2
local max_containers_y = screen_y / ( ( container_height ) + padding )
local can_scroll_down = false
local justClicked = false
local disabled_controls_while_active = { "next_weapon", "previous_weapon", "radio_next", "radio_previous" }

local title_size = 0.3 * container_height

function recalculateSizes(dataName, old_value)
	if source == localPlayer and dataName == "social_classic_user_interface" then
		if old_value ~= '0' then
			container_width, container_height, padding = 250, 100, 10
		else
			container_width, container_height, padding = 220, 120, 10
		end
		-- calculate the maximum numbers of stuff to fit on one line
		screen_x, screen_y = guiGetScreenSize( )
		max_containers = math.floor( screen_x / ( container_width + padding ) )
		container_start_x = ( screen_x - ( max_containers * ( container_width + padding ) ) + padding ) / 2
		max_containers_y = screen_y / ( ( container_height ) + padding )
		can_scroll_down = false
		justClicked = false

		title_size = 0.3 * container_height
	end
end
addEventHandler ( "onClientElementDataChange", getRootElement(), recalculateSizes)

function drawFriends( )
	local cursorX, cursorY
	if isCursorShowing() then
		cursorX, cursorY = getCursorPosition()
		cursorX, cursorY = cursorX * screen_x, cursorY * screen_y
	end
	-- allow players to switch between new/classic layouts
	local new_style = getElementData(localPlayer, 'social_classic_user_interface') ~= '1'

	-- this ensures all fonts will still be working in case of other resources that has the fonts restart
	makeFonts()

	local line = scroll_y
	for _, data in ipairs( { { title = "Online", items = online }, { title = "Offline", items = offline } }) do
		-- render title
		dxDrawText( data.title, 0, line * ( padding + container_height ), screen_x, line * ( padding + container_height ) + title_size - 10, white, 2, "default-bold", "center", "bottom", false, false, true )
		line = line + title_size / container_height

		-- render all items
		local justForcedNewLine = false
		for key, value in ipairs( data.items ) do
			if new_style then
				local pos = ( key - 1 ) % max_containers
				local x, y, w, h = container_start_x + ( padding + container_width ) * pos, line * ( padding + container_height ), container_width, container_height

				dxDrawRectangle( x, y, w, h, tocolor( 0, 0, 0, 100 ), true )

				local avatar = exports.cache:getImage(value.accountID)
				dxDrawImage ( x, y, h, h, (avatar and avatar.tex or ':cache/default.png'), 0,0,0, tocolor(255,255,255,255), true)
				local avatar_size = h
				--w = x + w -5
				--h = y + h -5
				--x = x + 8
				--y = y + 5

				w = x + w
				h = y + h

				local margin = 3
				local name_ox = margin--+avatar_size
				local name_oy = margin
				local name_l = x+name_ox
				local name_t = y+name_oy
				local name_r = name_l+avatar_size
				local name_b = name_t+dxGetFontHeight(1, font2)*2
				local shadow = 2
				dxDrawText(value.name ,name_l+shadow ,name_t+shadow, name_r+shadow, name_b+shadow, tocolor ( 0, 0, 0, 255 ), 1, font2, "left", "top", true, true, true ) -- shadow
				if value.player then
					r, g, b = getPlayerNametagColor( value.player )
					dxDrawText( value.name, name_l ,name_t , name_r, name_b, tocolor ( r, g, b, 255 ), 1, font2, "left", "top", true, true, true )
				else
					dxDrawText( value.name, name_l ,name_t , name_r, name_b, white, 1, font2, "left", "top", true, true, true )
				end


				-- draw removal 'X'
				local str = "X"
				local strwidth = 8
				if value.pending then
					str = "..."
					strwidth = 12
				elseif value.editable then
					str = "Edit"
					strwidth = 20
				end
				local inBox = isInBox( cursorX, cursorY, w - strwidth, w, y, y + 11 )
				dxDrawText( str, w - strwidth, y, w, y + 14, inBox and tocolor( 255, 0, 0, 255 ) or white, 0.8, "default-bold", "right", "top", true, false, true )
				if inBox and justClicked then
					if value.pending then
						-- do nothing D:
					elseif not value.editable then
						triggerServerEvent( "social:remove", localPlayer, value.accountID )
						value.pending = true
					else
						toggleFriends( false )
						guiSetInputEnabled( true )

						friends_message_window = guiCreateWindow( screen_x / 2 - 200, screen_y / 2 - 30, 400, 60, "Update your friends message", false )
						local e = guiCreateEdit( 5, 25, 290, 30, value.message, false, friends_message_window )
						guiEditSetMaxLength(e,500)
						local c = guiCreateButton( 300, 25, 45, 30, "Save", false, friends_message_window )
						local d = guiCreateButton( 350, 25, 45, 30, "Cancel", false, friends_message_window )
						addEventHandler( "onClientGUIClick", c,
							function( )
								triggerServerEvent( "social:message", localPlayer, guiGetText( e ) )
								value.message = guiGetText( e )
								destroyElement( friends_message_window )
								friends_message_window = nil
								guiSetInputEnabled( false )
							end,
							false
						)
						addEventHandler( "onClientGUIClick", d,
							function( )
								destroyElement( friends_message_window )
								friends_message_window = nil
								guiSetInputEnabled( false )
							end,
							false
						)
					end
				end

				shadow = shadow-1
				local char_ox = margin
				local char_oy = margin
				local one_line = dxGetFontHeight(1, font4)
				local char_l = x+margin
				local char_t = h-one_line*2
				local char_r = char_l+avatar_size-margin
				local char_b = char_t+one_line*2

				-- draw offline counter/playing as
				local text = ""
				if value.player then
					text = getPlayerName( value.player ):gsub( "_", " " ) .. " (" .. getElementData( value.player, "playerid" ) .. ")"
				else
					text = "Last online\n"..( formatTimeInterval( value.lastOnline ) .. " ago." ):gsub( "  ", " " )
				end
				dxDrawText( text, char_l-shadow , char_t-shadow, char_r-shadow, char_b-shadow, tocolor ( 0, 0, 0, 255 ), 1, font4, "left", "bottom", true, true, true ) -- shadow
				dxDrawText( text, char_l+shadow , char_t+shadow, char_r+shadow, char_b+shadow, tocolor ( 0, 0, 0, 255 ), 1, font4, "left", "bottom", true, true, true ) -- shadow
				dxDrawText( text, char_l-shadow , char_t+shadow, char_r-shadow, char_b+shadow, tocolor ( 0, 0, 0, 255 ), 1, font4, "left", "bottom", true, true, true ) -- shadow
				dxDrawText( text, char_l+shadow , char_t-shadow, char_r+shadow, char_b-shadow, tocolor ( 0, 0, 0, 255 ), 1, font4, "left", "bottom", true, true, true ) -- shadow
				dxDrawText( text, char_l , char_t, char_r, char_b, white, 1, font4, "left", "bottom", true, true, true )


				-- draw message
				dxDrawText( value.message or "Hi!", name_r+margin*2, y+margin*2, w-margin*2, h-margin*2, white, 1, font3, "left", "top", true, true, true )

				-- increase y thing
				if key % max_containers == 0 then
					line = line + 1
					justForcedNewLine = true
				else
					justForcedNewLine = false
				end
			else -- classic layout
				local pos = ( key - 1 ) % max_containers
				local x, y, w, h = container_start_x + ( padding + container_width ) * pos, line * ( padding + container_height ), container_width, container_height
				dxDrawRectangle( x, y, w, h, tocolor( 0, 0, 0, 100 ), true )
				dxDrawRectangle( x, y, w, 22, tocolor( 0, 0, 0, 100 ), true )

				w = x + w -5
				h = y + h -5
				x = x + 8
				y = y + 5
				--draw avatar
				--dxDrawImage(x, y, 65, 65, ":account/img/044.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)

				-- draw name
				if value.player then
					r, g, b = getPlayerNametagColor( value.player )
					dxDrawText( value.name, x, y, w, 15, tocolor ( r, g, b, 255 ), 1, font2, "left", "top", false, false, true )
				else
					dxDrawText( value.name, x, y, w, 15, white, 1, font2, "left", "top", false, false, true )
				end

				-- draw removal 'X'
				local str = "X"
				local strwidth = 8
				if value.pending then
					str = "..."
					strwidth = 12
				elseif value.editable then
					str = "Edit"
					strwidth = 20
				end
				local inBox = isInBox( cursorX, cursorY, w - strwidth, w, y, y + 11 )
				dxDrawText( str, w - strwidth, y, w, y + 14, inBox and tocolor( 255, 0, 0, 255 ) or white, 0.8, "default-bold", "right", "top", true, false, true )
				if inBox and justClicked then
					if value.pending then
						-- do nothing D:
					elseif not value.editable then
						triggerServerEvent( "social:remove", localPlayer, value.accountID )
						value.pending = true
					else
						toggleFriends( false )
						guiSetInputEnabled( true )

						friends_message_window = guiCreateWindow( screen_x / 2 - 200, screen_y / 2 - 30, 400, 60, "Update your friends message", false )
						local e = guiCreateEdit( 5, 25, 290, 30, value.message, false, friends_message_window )
						local c = guiCreateButton( 300, 25, 45, 30, "Save", false, friends_message_window )
						local d = guiCreateButton( 350, 25, 45, 30, "Cancel", false, friends_message_window )
						addEventHandler( "onClientGUIClick", c,
							function( )
								triggerServerEvent( "social:message", localPlayer, guiGetText( e ) )
								value.message = guiGetText( e )
								destroyElement( friends_message_window )
								friends_message_window = nil
								guiSetInputEnabled( false )
							end,
							false
						)
						addEventHandler( "onClientGUIClick", d,
							function( )
								destroyElement( friends_message_window )
								friends_message_window = nil
								guiSetInputEnabled( false )
							end,
							false
						)
					end
				end

				y = y + 20

				-- draw offline counter/playing as
				local text = ""
				if value.player then
					text = "playing as " .. getPlayerName( value.player ):gsub( "_", " " ) .. " (" .. getElementData( value.player, "playerid" ) .. ")."
				else
					text = ( formatTimeInterval( value.lastOnline ) .. " ago." ):gsub( "  ", " " )
				end
				dxDrawText( text, x + 10, y, w - 10, 15, white, 1, font3, "left", "top", false, false, true )
				y = y + 30

				-- draw message
				if value.message then
					dxDrawText( value.message, x + 10, y, w - 10, h, white, 1, font4, "left", "top", true, true, true )
				else
					dxDrawText( "Hi!", x + 10, y, w - 10, h, white, 1, small, "left", "top", true, true, true )
				end

				-- increase y thing
				if key % max_containers == 0 then
					line = line + 1
					justForcedNewLine = true
				else
					justForcedNewLine = false
				end
			end
		end
		if not justForcedNewLine then
			line = line + 1
		end
	end

	can_scroll_down = line > max_containers_y -- that's a pretty hacky bugfix for a flickering bug that happens if you do NOT have enough friends to fill your screen (poor soul)
	min_scroll_y = - ( line - scroll_y - max_containers_y ) -- adjust the maximum scrolling position.
	scroll_y = math.min( max_scroll_y, math.max( min_scroll_y, scroll_y ) ) -- make sure scrolling position is (still) within our limit.

	justClicked = false
end

--------------------------------------------------------------------------------
-- Binds
bindKey( "o", "down", "friends" )

local show = false
addCommandHandler( "friends",
	function( )
		toggleFriends( not show )
	end
)

function toggleFriends( state )
	if state and getElementData(localPlayer, "loggedin")==1 then
		showChat(false)
		addEventHandler( "onClientRender", root, drawFriends )
	else
		if getElementData(localPlayer, "loggedin")==1 then
			showChat(true)
		end
		removeEventHandler( "onClientRender", root, drawFriends )
	end

	for _, control in ipairs(disabled_controls_while_active) do
		toggleControl( control, not state )
	end
	show = state
end
toggleFriends( show )

local scroll_speed = 0.2
bindKey( "mouse_wheel_up", "down",
	function( )
		if show then
			scroll_y = math.min( max_scroll_y, scroll_y + scroll_speed )
		end
	end
)

-- The scrolling part
bindKey( "mouse_wheel_down", "down",
	function( )
		if show and can_scroll_down then
			scroll_y = math.max( min_scroll_y, scroll_y - scroll_speed )
		end
	end
)

addEventHandler( "onClientClick", root,
	function( button, state )
		if show and button == "left" and state == "up" then
			justClicked = true
		end
	end
)

--
-- Cleanup
--
addEventHandler( "onClientResourceStop", resourceRoot,
	function( )
		-- if we had this window open, it has input enabled
		if friends_message_window then
			guiSetInputEnabled( false )
		end
	end
)

--
-- Utility function for right-click menu
--
function isFriendOf( accountID )
	for _, data in ipairs( {online, offline} ) do
		for k, v in ipairs( data ) do
			if v.accountID == accountID then
				return true
			end
		end
	end
	return false
end



--
-- Utility function for chat system
--

function getFriends()
	return online, offline
end
