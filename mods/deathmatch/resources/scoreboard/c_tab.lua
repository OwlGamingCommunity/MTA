--
-- vgScoreboard v1.0
-- Client-side script.
-- By Alberto "ryden" Alonso
--

--[[ Configuration ]]--
local SCOREBOARD_WIDTH				= 400				-- The scoreboard window width
local SCOREBOARD_HEIGHT				= 600				-- The scoreboard window height
local SCOREBOARD_HEADER_HEIGHT		= 30				-- Height for the header in what you can see the server info
local SCOREBOARD_TOGGLE_CONTROL		= "tab"				-- Control/Key to toggle the scoreboard visibility
local SCOREBOARD_PGUP_CONTROL		= "mouse_wheel_up"	-- Control/Key to move one page up
local SCOREBOARD_PGDN_CONTROL		= "mouse_wheel_down"-- Control/Key to move one page down
local SCOREBOARD_DISABLED_CONTROLS	= { "next_weapon",	-- Controls that are disabled when the scoreboard is showing
										"previous_weapon",
										"aim_weapon",
										"radio_next",
										"radio_previous" }
local SCOREBOARD_TOGGLE_TIME		= 200				-- Time in miliseconds to make the scoreboard (dis)appear
local SCOREBOARD_POSTGUI			= true				-- Set to true if it must be drawn over the GUI
local SCOREBOARD_INFO_BACKGROUND	= { 0, 0, 0, 150 }			-- RGBA color for the info header background
local SCOREBOARD_SERVER_NAME_COLOR	= { 255, 255, 255, 255 }		-- RGBA color for the server name text
local SCOREBOARD_PLAYERCOUNT_COLOR	= { 255, 255, 255, 255 }	-- RGBA color for the server player count text
local SCOREBOARD_BACKGROUND			= { 0, 0, 0, 140 }			-- RGBA color for the background
local SCOREBOARD_BACKGROUND_IMAGE	= { 255, 255, 255, 40 }		-- RGBA color for the background image
local SCOREBOARD_HEADERS_COLOR		= { 255, 255, 255, 180 }	-- RGBA color for the headers
local SCOREBOARD_SEPARATOR_COLOR	= { 82, 82, 82, 140 }		-- RGBA color for the separator line between headers and body content
local SCOREBOARD_SCROLL_BACKGROUND	= { 0, 10, 20, 100 }		-- RGBA color for the scroll background
local SCOREBOARD_SCROLL_BACKGROUND	= { 0, 10, 20, 100 }		-- RGBA color for the scroll background
local SCOREBOARD_SCROLL_FOREGROUND	= { 255, 255, 255, 255 }		-- RGBA color for the scroll foreground
local SCOREBOARD_SCROLL_HEIGHT		= 40						-- Size for the scroll marker
local SCOREBOARD_COLUMNS_WIDTH		= { 0.08, 0.59, 0.15, 0.14, 0.04 }	-- Relative width for each column: id, player name, hours, ping and scroll position
local SCOREBOARD_ROW_GAP			= 1							-- Gap between rows

--[[ Uncomment to test with dummies ]]--
--[[
local _getPlayerName = getPlayerName
local _getPlayerPing = getPlayerPing
local _getPlayerNametagColor = getPlayerNametagColor

function getPlayerName ( player )
	if getElementType ( player ) == "player" then return _getPlayerName ( player ) end
	return getElementData ( player, "name" )
end

function getPlayerPing ( player )
	if getElementType ( player ) == "player" then return _getPlayerPing ( player ) end
	return getElementData ( player, "ping" )
end

function getPlayerNametagColor ( player )
	if getElementType ( player ) == "player" then return _getPlayerNametagColor ( player )
	else return unpack(getElementData(player, "color")) end
end
--]]


--[[ Global variables to this context ]]--
local g_isShowing = false		-- Marks if the scoreboard is showing
local g_currentWidth = 0		-- Current window width. Used for the fade in/out effect.
local g_currentHeight = 0		-- Current window height. Used for the fade in/out effect.
local g_scoreboardDummy			-- Will contain the scoreboard dummy element to gather info from.
local g_windowSize = { guiGetScreenSize () }	-- The window size
local g_localPlayer = getLocalPlayer ()			-- The local player...
local g_currentPage = 0			-- The current scroll page
local g_players					-- We will keep a cache of the conected player list
local g_oldControlStates		-- To save the old control states before disabling them for scrolling

--[[ Pre-calculate some stuff ]]--
-- Scoreboard position
local SCOREBOARD_X = math.floor ( ( g_windowSize[1] - SCOREBOARD_WIDTH ) / 2 )
local SCOREBOARD_Y = math.floor ( ( g_windowSize[2] - SCOREBOARD_HEIGHT ) / 2 )
-- Scoreboard colors
SCOREBOARD_INFO_BACKGROUND = tocolor ( unpack ( SCOREBOARD_INFO_BACKGROUND ) )
SCOREBOARD_SERVER_NAME_COLOR = tocolor ( unpack ( SCOREBOARD_SERVER_NAME_COLOR ) )
SCOREBOARD_PLAYERCOUNT_COLOR = tocolor ( unpack ( SCOREBOARD_PLAYERCOUNT_COLOR ) )
SCOREBOARD_BACKGROUND = tocolor ( unpack ( SCOREBOARD_BACKGROUND ) )
SCOREBOARD_BACKGROUND_IMAGE = tocolor ( unpack ( SCOREBOARD_BACKGROUND_IMAGE ) )
SCOREBOARD_HEADERS_COLOR = tocolor ( unpack ( SCOREBOARD_HEADERS_COLOR ) )
SCOREBOARD_SCROLL_BACKGROUND = tocolor ( unpack ( SCOREBOARD_SCROLL_BACKGROUND ) )
SCOREBOARD_SCROLL_FOREGROUND = tocolor ( unpack ( SCOREBOARD_SCROLL_FOREGROUND ) )
SCOREBOARD_SEPARATOR_COLOR = tocolor ( unpack ( SCOREBOARD_SEPARATOR_COLOR ) )
-- Columns width in absolute units
for k=1,#SCOREBOARD_COLUMNS_WIDTH do
	SCOREBOARD_COLUMNS_WIDTH[k] = math.floor ( SCOREBOARD_COLUMNS_WIDTH[k] * SCOREBOARD_WIDTH )
end
-- Pre-calculate each row horizontal bounding box.
local rowsBoundingBox = { { SCOREBOARD_X, -1 }, { -1, -1 }, { -1, -1 }, { -1, -1 }, { -1, -1 } }
-- ID
rowsBoundingBox[1][2] = SCOREBOARD_X + SCOREBOARD_COLUMNS_WIDTH[1]
-- Name
rowsBoundingBox[2][1] = rowsBoundingBox[1][2]
rowsBoundingBox[2][2] = rowsBoundingBox[2][1] + SCOREBOARD_COLUMNS_WIDTH[2]
-- Hours
rowsBoundingBox[3][1] = rowsBoundingBox[2][2]
rowsBoundingBox[3][2] = rowsBoundingBox[3][1] + SCOREBOARD_COLUMNS_WIDTH[3]
-- Ping
rowsBoundingBox[4][1] = rowsBoundingBox[3][2]
rowsBoundingBox[4][2] = rowsBoundingBox[4][1] + SCOREBOARD_COLUMNS_WIDTH[4]
-- Scrollbar
rowsBoundingBox[5][1] = rowsBoundingBox[4][2]
rowsBoundingBox[5][2] = SCOREBOARD_X + SCOREBOARD_WIDTH


--[[ Pre-declare some functions ]]--
local onRender
local fadeScoreboard
local drawBackground
local drawScoreboard


--[[
* clamp
Clamps a value into a range.
--]]
local function clamp ( valueMin, current, valueMax )
	if current < valueMin then
		return valueMin
	elseif current > valueMax then
		return valueMax
	else
		return current
	end
end

--[[
* createPlayerCache
Generates a new player cache.
--]]
local function createPlayerCache ( ignorePlayer )
	-- Optimize the function in case of not having to ignore a player
	if ignorePlayer then
		-- Clear the gloal table
		g_players = {}

		-- Get the list of connected players
		local players = getElementsByType ( "player" )

		-- Dump them to the global table
		for k, player in ipairs(players) do
			if ignorePlayer ~= player then
				table.insert ( g_players, player )
			end
		end
	else
		g_players = getElementsByType ( "player" )
	end

	--[[ Uncomment to test with dummies ]]--
	--[[
	for k,v in ipairs(getElementsByType("playerDummy")) do
		table.insert(g_players, v)
	end
	--]]

	-- Sort the player list by their ID, giving priority to the local player
	table.sort ( g_players, function ( a, b )
		local idA = getElementData ( a, "playerid" ) or 0
		local idB = getElementData ( b, "playerid" ) or 0

		-- Perform the checks to always set the local player at the beggining
		if a == g_localPlayer then
			idA = -1
		elseif b == g_localPlayer then
			idB = -1
		end

		return tonumber(idA) < tonumber(idB)
	end )
end

--[[
* onClientResourceStart
Handles the resource start event to create the initial player cache
--]]
addEventHandler ( "onClientResourceStart", getResourceRootElement(getThisResource()), function ()
	createPlayerCache ()
end, false )

--[[
* onClientElementDataChange
Handles the element data changes event to update the player cache
if the playerid was changed.
--]]
addEventHandler ( "onClientElementDataChange", root, function ( dataName, dataValue )
	if dataName == "playerid" then
		createPlayerCache ()
	end
end )

--[[
* onClientPlayerQuit
Handles the player quit event to update the player cache.
--]]
addEventHandler ( "onClientPlayerQuit", root, function ()
	createPlayerCache ( source )
end )

--[[
* toggleScoreboard
Toggles the visibility of the scoreboard.
--]]
local function toggleScoreboard ( show )
	if not getPedControlState( localPlayer, 'aim_weapon' ) then
		-- Force the parameter to be a boolean
		local show = show == true

		-- Check if the status has changed
		if show ~= g_isShowing then
			g_isShowing = show

			if g_isShowing and g_currentWidth == 0 and g_currentHeight == 0 then
				-- Handle the onClientRender event to start drawing the scoreboard.
				addEventHandler ( "onClientPreRender", root, onRender, false )
			end

			-- Little hack to avoid switching weapons while moving through the scoreboard pages.
			if g_isShowing then
				g_oldControlStates = {}
				for k, control in ipairs ( SCOREBOARD_DISABLED_CONTROLS ) do
					g_oldControlStates[k] = isControlEnabled ( control )
					toggleControl ( control, false )
				end
			else
				for k, control in ipairs ( SCOREBOARD_DISABLED_CONTROLS ) do
					toggleControl ( control, g_oldControlStates[k] )
				end
				g_oldControlStates = nil
			end
		end
	end
end

--[[
* onToggleKey
Function to bind to the appropiate key the function to toggle the scoreboard visibility.
--]]
local function onToggleKey ( key, keyState )
	-- Check if the scoreboard element has been created
	if not g_scoreboardDummy then
		local elementTable = getElementsByType ( "scoreboard" )
		if #elementTable > 0 then
			g_scoreboardDummy = elementTable[1]
		else
			return
		end
	end

	-- Toggle the scoreboard, and check that it's allowed.
	toggleScoreboard ( keyState == "down" and getElementData ( g_scoreboardDummy, "allow" ) )
end
bindKey ( SCOREBOARD_TOGGLE_CONTROL, "both", onToggleKey )

--[[
* onScrollKey
Function to bind to the appropiate key the function to change the current page.
--]]
local function onScrollKey ( direction )
	if g_isShowing then
		if direction then
			g_currentPage = g_currentPage + 1
		else
			g_currentPage = g_currentPage - 1
			if g_currentPage < 0 then
				g_currentPage = 0
			end
		end
	end
end
bindKey ( SCOREBOARD_PGUP_CONTROL, "down", function () onScrollKey ( false ) end )
bindKey ( SCOREBOARD_PGDN_CONTROL, "down", function () onScrollKey ( true ) end )

--[[
* onRender
Event handler for onClientPreRender. It will forward the flow to the most appropiate
function: fading-in, fading-out or drawScoreboard.
--]]
onRender = function ( timeshift )
	-- Boolean to check if we must draw the scoreboard.
	local drawIt = false

	if g_isShowing then
		-- Check if the scoreboard has been disallowed
		if not getElementData ( g_scoreboardDummy, "allow" ) then
			toggleScoreboard ( false )
		-- If it's showing, check if it got fully faded in. Else, draw it normally.
		elseif g_currentWidth < SCOREBOARD_WIDTH or g_currentHeight < SCOREBOARD_HEIGHT then
			drawIt = fadeScoreboard ( timeshift, 1 )
		else
			-- Allow drawing the full scoreboard
			drawIt = true
		end
	else
		-- If it shouldn't be showing, make another step to fade it out.
		drawIt = fadeScoreboard ( timeshift, -1 )
	end

	-- Draw the scoreboard if allowed.
	if drawIt then
		drawScoreboard ()
	end
end

--[[
* fadeScoreboard
Makes a step of the fade effect. Gets a multiplier to make it either fading in or out.
--]]
fadeScoreboard = function ( timeshift, multiplier )
	-- Get the percentage of the final size that it should grow for this step.
	local growth = ( timeshift / SCOREBOARD_TOGGLE_TIME ) * multiplier

	-- Apply the growth to the scoreboard size
	g_currentWidth = clamp ( 0, g_currentWidth + ( SCOREBOARD_WIDTH * growth ), SCOREBOARD_WIDTH )
	g_currentHeight = clamp ( 0, g_currentHeight + ( SCOREBOARD_HEIGHT * growth ), SCOREBOARD_HEIGHT )

	-- Check if the scoreboard has collapsed. If so, unregister the onClientRender event.
	if g_currentWidth == 0 or g_currentHeight == 0 then
		g_currentWidth = 0
		g_currentHeight = 0
		removeEventHandler ( "onClientPreRender", root, onRender )
		return false
	else
		return true
	end
end

--[[
* drawBackground
Draws the scoreboard background.
--]]
drawBackground = function ()
	-- Draw the header
	local headerHeight = clamp ( 0, SCOREBOARD_HEADER_HEIGHT, g_currentHeight )
	dxDrawRectangle ( SCOREBOARD_X, SCOREBOARD_Y,
					  g_currentWidth, headerHeight,
					  SCOREBOARD_INFO_BACKGROUND, SCOREBOARD_POSTGUI )

	-- Draw the body background
	if g_currentHeight > SCOREBOARD_HEADER_HEIGHT then
		-- Draw the background image
		--[[
		dxDrawImage ( SCOREBOARD_X+120, SCOREBOARD_Y + 150,
					  SCOREBOARD_WIDTH - 220, SCOREBOARD_HEIGHT - 357,
					  ":resources/OGLogo.png", 0, 0, 0, SCOREBOARD_BACKGROUND_IMAGE, SCOREBOARD_POSTGUI ) -- Maxime on 31/3/2013, Removed logo in tab
		]]
		-- Overlay
		dxDrawRectangle ( SCOREBOARD_X, SCOREBOARD_Y + SCOREBOARD_HEADER_HEIGHT,
						  g_currentWidth, g_currentHeight - SCOREBOARD_HEADER_HEIGHT,
						  SCOREBOARD_BACKGROUND, SCOREBOARD_POSTGUI )
	end
end

--[[
* drawRowBounded
Draws a scoreboard body row with the pre-calculated row bounding boxes.
--]]
local function drawRowBounded ( id, name, hours, ping, colors, font, top )
	-- Precalculate some constants
	local bottom = clamp ( 0, top + dxGetFontHeight ( 1, font ), SCOREBOARD_Y + g_currentHeight )
	local maxWidth = SCOREBOARD_X + g_currentWidth

	-- If the row doesn't fit, just avoid any further calculations.
	if bottom < top then return end

	-- ID
	local left = rowsBoundingBox[1][1]
	local right = clamp ( 0, rowsBoundingBox[1][2], maxWidth )
	if left < right then
		dxDrawText ( id, left, top, right, bottom,
					 colors[1], 1, font, "right", "top",
					 true, false, SCOREBOARD_POSTGUI )

		-- Name
		left = rowsBoundingBox[2][1] + 17 -- Grant some padding to the name column
		right = clamp ( 0, rowsBoundingBox[2][2], maxWidth )
		if left < right then
			dxDrawText ( name, left, top, right, bottom,
						 colors[2], 1, font, "left", "top",
						 true, false, SCOREBOARD_POSTGUI )

			-- Hours
			left = rowsBoundingBox[3][1]
			right = clamp ( 0, rowsBoundingBox[3][2], maxWidth )
			if left < right then
				dxDrawText ( hours, left, top, right, bottom,
							 colors[3], 1, font, "left", "top",
							 true, false, SCOREBOARD_POSTGUI )

				-- Ping
				left = rowsBoundingBox[4][1]
				right = clamp ( 0, rowsBoundingBox[4][2], maxWidth )
				if left < right then
					dxDrawText ( ping, left, top, right, bottom,
								colors[3], 1, font, "left", "top",
								true, false, SCOREBOARD_POSTGUI )
				end
			end
		end
	end
end

--[[
* drawScrollBar
Draws the scroll bar. Position ranges from 0 to 1.
--]]
local function drawScrollBar ( top, position )
	-- Get the bounding box
	local left = rowsBoundingBox[5][1]
	local right = clamp ( 0, rowsBoundingBox[5][2], SCOREBOARD_X + g_currentWidth )
	local bottom = clamp ( 0, SCOREBOARD_Y + SCOREBOARD_HEIGHT, SCOREBOARD_Y + g_currentHeight )

	-- Make sure that it'd be visible.
	if left < right and top < bottom then
		-- Draw the background
		dxDrawRectangle ( left, top, right - left, bottom - top, SCOREBOARD_SCROLL_BACKGROUND, SCOREBOARD_POSTGUI )

		-- Get the current Y position for the scroll marker
		local top = top + position * ( SCOREBOARD_Y + SCOREBOARD_HEIGHT - SCOREBOARD_SCROLL_HEIGHT - top )
		bottom = clamp ( 0, top + SCOREBOARD_SCROLL_HEIGHT, SCOREBOARD_Y + g_currentHeight )

		-- Make sure that it'd be visible
		if top < bottom then
			dxDrawRectangle ( left, top, right - left, bottom - top, SCOREBOARD_SCROLL_FOREGROUND, SCOREBOARD_POSTGUI )
		end
	end
end

function makeFont()
	if not theFont then
		theFont = "default-bold"
	end
	return theFont
end


--[[
* drawScoreboard
Draws the scoreboard contents.
--]]
drawScoreboard = function ()
	-- Check that we got the list of players
	if not g_players then return end

	-- First draw the background
	drawBackground ()

	-- Get the server information
	local serverName = getElementData ( g_scoreboardDummy, "serverName" ) or "MTA server"
	local maxPlayers = getElementData ( root, "server:Slots" ) or 1024
	serverName = tostring ( serverName )
	maxPlayers = tonumber ( maxPlayers )

	-- Render the header
	-- Calculate the bounding box for the header texts
	local left, top, right, bottom = SCOREBOARD_X + 2, SCOREBOARD_Y + 2, SCOREBOARD_X + g_currentWidth - 2, SCOREBOARD_Y + SCOREBOARD_HEADER_HEIGHT - 2

	-- Render the server name
	dxDrawText ( serverName, left, top, right, bottom,
				 SCOREBOARD_SERVER_NAME_COLOR, 1, makeFont() or "default-bold", "left", "center",
				 true, false, SCOREBOARD_POSTGUI )


	-- Render the player count
	local usagePercent = (#g_players / maxPlayers) * 100
	local strPlayerCount = "Players: " .. tostring(#g_players) .. "/" .. tostring(maxPlayers) .. " (" .. math.floor(usagePercent + 0.5) .. "%)"

	-- We need to recalculate the left position, to make it not move when fading.
	local offset = SCOREBOARD_WIDTH - dxGetTextWidth ( strPlayerCount, 1, makeFont() or "default" ) - 4
	left = left + offset
	-- Make sure of that it needs to be rendered now
	if left < right then
		dxDrawText ( strPlayerCount, left, top, right, bottom,
					SCOREBOARD_PLAYERCOUNT_COLOR, 1, makeFont() or "default", "left", "center",
					true, false, SCOREBOARD_POSTGUI )
	end

	-- Draw the body.
	-- Update the bounding box.
	left, top, bottom = SCOREBOARD_X, SCOREBOARD_Y + SCOREBOARD_HEADER_HEIGHT + 2, SCOREBOARD_Y + g_currentHeight - 2

	-- Pre-calculate how much height will each row have.
	local rowHeight = dxGetFontHeight ( 1, "default-bold" )

	-- Draw the headers
	drawRowBounded ( "ID", "Player Name", "Hours", "Ping",
					 { SCOREBOARD_HEADERS_COLOR, SCOREBOARD_HEADERS_COLOR, SCOREBOARD_HEADERS_COLOR },
					 "default-bold", top )


	-- Add the offset for a new row
	top = top + rowHeight + 3

	-- Draw the separator
	right = clamp ( 0, rowsBoundingBox[4][2] - 5, SCOREBOARD_X + g_currentWidth )
	if top < SCOREBOARD_Y + g_currentHeight then
		dxDrawLine ( SCOREBOARD_X + 5, top, right, top, SCOREBOARD_SEPARATOR_COLOR, 1, SCOREBOARD_POSTGUI )
	end
	top = top + 3

	-- Create a function to render a player entry
	local renderEntry = function ( player, seeUsername )
		-- Get the player data
		local playerID = getElementData ( player, "playerid" ) or 0
		playerID = tostring ( playerID )
		local playerUsername = ""
		if seeUsername then
			local uname = getElementData( player, 'account:username' )
			playerUsername = uname and (" ("..uname..")") or ""
		end
		local playerName = exports.global:getPlayerName( player )..playerUsername
		local playerHours = getElementData( player, 'hoursplayed' ) or 0
		local playerPing = getPlayerPing ( player )
		playerPing = tostring ( playerPing )
		--local r, g, b = getPlayerNametagColor ( player )
		local r, g, b = 255, 255, 255
		if getElementData(player, "loggedin") ~= 1 then -- Not logged in
			r, g, b =  127, 127, 127
		elseif getElementData(player, "donation:nametag") and getElementData(player, "nametag_on") then
			r, g, b = 167, 133, 63
		elseif tonumber(getElementData(player, "admin_level")) == 10 then
			r, g, b = 255, 255, 255
		end
		local playerColor = tocolor ( r, g, b, 255 )

		-- Create the table of colors
		local colors = { playerColor, playerColor, playerColor }

		-- Render it!
		drawRowBounded ( playerID, playerName, playerHours, playerPing, colors, "default-bold", top )
	end

	-- Calculate how much players can fit in the body window.
	local playersPerPage = math.floor ( ( SCOREBOARD_Y + SCOREBOARD_HEIGHT - top ) / ( rowHeight + SCOREBOARD_ROW_GAP ) )

	-- Get the amount of shifted players per page
	local playerShift = math.floor ( playersPerPage / 2 )

	-- Get the number of players to skip
	local playersToSkip = playerShift * g_currentPage
	if (#g_players - playersToSkip) < playersPerPage then
		-- Check that they didn't go to an invalid page
		if (#g_players - playersToSkip) < playerShift then
			g_currentPage = g_currentPage - 1
			if g_currentPage < 0 then g_currentPage = 0 end
		end

		-- Try to always fill pages
		playersToSkip = #g_players - playersPerPage + 1
	end

	-- Check for when there are too few players to fill one page.
	if playersToSkip < 0 then
		playersToSkip = 0
	end

	local isStaffOnDuty = exports.global:isStaffOnDuty( localPlayer )

	-- For every player in the cache, render a new entry.
	for k=playersToSkip + 1, #g_players do
		local player = g_players [ k ]
		local hasPerk, perkValue = exports.donators:hasPlayerPerk(player, 12)
		if not (hasPerk and tonumber(perkValue) == 1) or isStaffOnDuty then
			-- Check if it's gonna fit. If it doesn't stop rendering.
			if top < bottom - rowHeight - SCOREBOARD_ROW_GAP then
				renderEntry ( player, isStaffOnDuty )
				-- Update the height for the next entry
				top = top + rowHeight + SCOREBOARD_ROW_GAP
			else break end
		end
	end

	-- Draw the scrollbar. The maximum players to skip is #g_players - playersPerPage + 1, so when
	-- the scoreboard is fully scrolled it will become 1, while when it's not scrolled it will be
	-- 0 due to playersToSkip being 0.
	drawScrollBar ( SCOREBOARD_Y + SCOREBOARD_HEADER_HEIGHT + rowHeight + 10, playersToSkip / ( #g_players - playersPerPage + 1 ) )
end

--[[
* isVisible
Returns wherever or not the scoreboard is visible
--]]
function isVisible ( )
	return g_isShowing
end
