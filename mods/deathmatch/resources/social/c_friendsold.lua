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
		table.insert( online, { accountID = getElementData( localPlayer, "account:id"), name = getElementData( localPlayer, "account:username" ), message = ownMessage, player = localPlayer, editable = true })
		
		for _, data in ipairs( friendsList ) do
			if type( data[4] ) == "number" or type( data[4] ) == "string" then
				table.insert( offline, { accountID = data[1], name = data[2], message = data[3], lastOnline = data[4] } )
			else
				table.insert( online, { accountID = data[1], name = data[2], message = data[3], player = data[4] } )
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
			outputDebugString( "Why did we receive friend info for account " .. accountID .. "?" )
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

-- Drawing stuff
local container_width, container_height, padding = 220, 120, 10
local white = tocolor( 255, 255, 255, 255 )
local font = dxCreateFont( "segoeuil.ttf", 12 )
local small = "default"

local scroll_y = 0.1
local min_scroll_y = -5
local max_scroll_y = 0.1

-- calculate the maximum numbers of stuff to fit on one line
local screen_x, screen_y = guiGetScreenSize( )
local max_containers = math.floor( screen_x / ( container_width + padding ) )
local container_start_x = ( screen_x - ( max_containers * ( container_width + padding ) ) + padding ) / 2
local max_containers_y = screen_y / ( ( container_height ) + padding )
local can_scroll_down = false
local justClicked = false

local title_size = 0.3 * container_height
function drawFriends( )
	local cursorX, cursorY
	if isCursorShowing( ) then
		cursorX, cursorY = getCursorPosition( )
		cursorX, cursorY = cursorX * screen_x, cursorY * screen_y
	end
		
	local line = scroll_y
	for _, data in ipairs( { { title = "Online", items = online }, { title = "Offline", items = offline } }) do
		-- render title
		dxDrawText( data.title, 0, line * ( padding + container_height ), screen_x, line * ( padding + container_height ) + title_size - 10, white, 2, "default-bold", "center", "bottom", false, false, true )
		line = line + title_size / container_height
		
		-- render all items
		local justForcedNewLine = false
		for key, value in ipairs( data.items ) do
			local pos = ( key - 1 ) % max_containers
			
			local x, y, w, h = container_start_x + ( padding + container_width ) * pos, line * ( padding + container_height ), container_width, container_height
			dxDrawRectangle( x, y, w, h, tocolor( 0, 0, 0, 192 ), true )
			
			w = x + w - 5
			h = y + h - 5
			x = x + 8
			y = y + 5
			-- draw name
			dxDrawText( value.name, x, y, w, 15, white, 1, font, "left", "top", false, false, true )

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
			dxDrawText( text, x + 10, y, w - 10, 15, white, 1, small, "left", "top", false, false, true )
			y = y + 30

			-- draw message
			if value.message then
				dxDrawText( value.message, x + 10, y, w - 10, h, white, 1, small, "left", "top", true, true, true )
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
	if state then
		addEventHandler( "onClientRender", root, drawFriends )
	else
		removeEventHandler( "onClientRender", root, drawFriends )
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
