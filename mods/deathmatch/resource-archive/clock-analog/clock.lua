---------------------------------- DO NOT CHANGE THESE ----------------------------------

local SCREEN_WIDTH, SCREEN_HEIGHT = guiGetScreenSize()

local CLOCK_IMG,CLOCK_DEFAULT_X,CLOCK_DEFAULT_Y,CLOCK_DIAMETER,CLOCK_COLOR,CLOCK_POST_GUI
local CLOCK_RADIUS,CLOCK_CENTER_X,CLOCK_CENTER_Y
local CLOCK_HOUR_IMG,CLOCK_HOUR_W,CLOCK_HOUR_H,CLOCK_HOUR_X,CLOCK_HOUR_Y,CLOCK_HOUR_ROT_POS_X,CLOCK_HOUR_ROT_POS_Y,CLOCK_HOUR_COLOR
local CLOCK_MINUTE_IMG,CLOCK_MINUTE_W,CLOCK_MINUTE_H,CLOCK_MINUTE_X,CLOCK_MINUTE_Y,CLOCK_MINUTE_ROT_POS_X,CLOCK_MINUTE_ROT_POS_Y,CLOCK_MINUTE_COLOR
local CLOCK_SECOND_IMG,CLOCK_SECOND_W,CLOCK_SECOND_H,CLOCK_SECOND_X,CLOCK_SECOND_Y,CLOCK_SECOND_ROT_POS_X,CLOCK_SECOND_ROT_POS_Y,CLOCK_SECOND_COLOR
local CLOCK_SETTING_FILE,CLOCK_SETTING_DEFAULT_TOGGLE

local CLOCK_X,CLOCK_Y = 0,0

---------------------------------- SETTINGS (do change these) ----------------------------------

CLOCK_SETTING_FILE           = "clock.xml"
CLOCK_SETTING_DEFAULT_TOGGLE = true

CLOCK_DEFAULT_X = SCREEN_WIDTH - SCREEN_WIDTH*0.2 + ( 70/1280 )  * SCREEN_WIDTH
CLOCK_DEFAULT_Y = ( 140/1024 ) * SCREEN_HEIGHT

-- These settings are inside this function so they can be reloaded later on
-- Changing the values shouldn't do any harm
function setSettings()
	CLOCK_IMG       = "clock.png"
	CLOCK2_IMG       = "clock2.png"
	CLOCK_DIAMETER  = SCREEN_HEIGHT * 0.13
	CLOCK1_COLOR     = tocolor(0,0,0, 255)
	CLOCK2_COLOR     = tocolor(255,255,255,255)
	CLOCK_POST_GUI  = false

	CLOCK_RADIUS   = CLOCK_DIAMETER / 2
	CLOCK_CENTER_X = CLOCK_X + CLOCK_RADIUS
	CLOCK_CENTER_Y = CLOCK_Y + CLOCK_RADIUS

	CLOCK_HOUR_IMG       = "whyzerbig.png"
	CLOCK_HOUR_W         = CLOCK_DIAMETER / 2.3 / 300 * 22
	CLOCK_HOUR_H         = CLOCK_DIAMETER / 2.3
	CLOCK_HOUR_X         = CLOCK_CENTER_X - CLOCK_HOUR_W / 2
	CLOCK_HOUR_Y         = CLOCK_Y + CLOCK_HOUR_H / 300 * 50 * 3
	CLOCK_HOUR_ROT_POS_X = 0
	CLOCK_HOUR_ROT_POS_Y = CLOCK_HOUR_H / 300 * 50
	CLOCK_HOUR_COLOR     = tocolor(255,255,255,255)

	CLOCK_MINUTE_IMG       = "whyzerbig.png"
	CLOCK_MINUTE_W         = CLOCK_DIAMETER / 2 / 300 * 22
	CLOCK_MINUTE_H         = CLOCK_DIAMETER / 2
	CLOCK_MINUTE_X         = CLOCK_CENTER_X-- - CLOCK_MINUTE_W / 2
	CLOCK_MINUTE_Y         = CLOCK_Y + CLOCK_MINUTE_H / 300 * 50 * 2
	CLOCK_MINUTE_ROT_POS_X = 0
	CLOCK_MINUTE_ROT_POS_Y = CLOCK_MINUTE_H / 300 * 50
	CLOCK_MINUTE_COLOR     = tocolor(255,255,255,255)

	CLOCK_SECOND_IMG       = "whyzerseconds.png"
	CLOCK_SECOND_W         = CLOCK_DIAMETER / 1.7 / 280 * 13
	CLOCK_SECOND_H         = CLOCK_DIAMETER / 1.7
	CLOCK_SECOND_X         = CLOCK_CENTER_X - CLOCK_SECOND_W / 2
	CLOCK_SECOND_Y         = CLOCK_Y + CLOCK_SECOND_H / 280 * 40 * 1.5
	CLOCK_SECOND_ROT_POS_X = 0
	CLOCK_SECOND_ROT_POS_Y = CLOCK_SECOND_H / 280 * 40
	CLOCK_SECOND_COLOR     = tocolor(255,255,255,255)
end

---------------------------------- END OF SETTINGS ----------------------------------

local toggle = CLOCK_SETTING_DEFAULT_TOGGLE
local repos  = false

function handleClockStart()
	-- Load the settings file
	local xmlFile = xmlLoadFile(CLOCK_SETTING_FILE)
	if xmlFile then
		-- Load the settings, and apply them
		toggle  = xmlNodeGetAttribute(xmlFile,"enabled") ~= "false"
		CLOCK_X = tonumber(xmlNodeGetAttribute(xmlFile,"posX")) or CLOCK_DEFAULT_X
		CLOCK_Y = tonumber(xmlNodeGetAttribute(xmlFile,"posY")) or CLOCK_DEFAULT_Y
		
		-- Close the XML file (pretty important)
		xmlUnloadFile(xmlFile)
	else
		-- Set the default position as the clock position
		CLOCK_X = CLOCK_DEFAULT_X
		CLOCK_Y = CLOCK_DEFAULT_Y
		
		-- Save the default settings, because the file doesn't exist yet
		handleXMLSave()
	end
	
	-- Apply all settings
	setSettings()
	
	-- Clock enabled? If so, render it
	if toggle then
		addEventHandler("onClientRender",getRootElement(),renderClock)
	end
end
addEventHandler("onClientResourceStart",getResourceRootElement(),handleClockStart)

function handleXMLSave()
	-- Load the settings file
	local xmlFile = xmlLoadFile(CLOCK_SETTING_FILE)
	if not xmlFile then
		-- If it doesn't exist, create it
		xmlFile = xmlCreateFile("clock.xml","settings")
		
		if not xmlFile then
			-- If it manages to fuck up, then wtf?
			outputDebugString("Clock settings could not be saved",1)
			return
		end
	end
	
	-- Store the data
	xmlNodeSetAttribute(xmlFile,"enabled",tostring(toggle))
	xmlNodeSetAttribute(xmlFile,"posX",tostring(CLOCK_X))
	xmlNodeSetAttribute(xmlFile,"posY",tostring(CLOCK_Y))
	
	-- Make sure the data is actually saved, and close the file
	xmlSaveFile(xmlFile)
	xmlUnloadFile(xmlFile)
end

function toggleClock()
	-- Invert the toggle ( true -> false, false -> true )
	toggle = not toggle
	
	-- See if the rendering should be enabled, or disabled
	if toggle then
		addEventHandler("onClientRender",getRootElement(),renderClock)
	else
		removeEventHandler("onClientRender",getRootElement(),renderClock)
	end
	
	-- Store it in the settings file
	handleXMLSave()
end
addCommandHandler("clock",toggleClock)

local REPOS_CLOCK_X_BACKUP,REPOS_CLOCK_Y_BACKUP

function toggleReposClock()
	-- Invert the repositioning toggle ( true -> false, false -> true )
	repos = not repos
	
	-- Show the cursor, so players can indicate where they want the clock
	showCursor(repos)
	
	if repos then
		-- Store the current position, in case they cancel
		REPOS_CLOCK_X_BACKUP = CLOCK_X
		REPOS_CLOCK_Y_BACKUP = CLOCK_Y
		
		-- Notify them they're changing the position
		outputChatBox("Move the mouse to reposition the clock. Left-click to confirm the new position, right-click to cancel",255,128,0)
		
		-- Handle the repositioning every frame
		addEventHandler("onClientRender",getRootElement(),reposClockDoPulse)
	else
		-- Restore the position from backup
		CLOCK_X = REPOS_CLOCK_X_BACKUP
		CLOCK_Y = REPOS_CLOCK_Y_BACKUP
		
		-- Put all settings back to normal
		setSettings()
		
		-- Notify the player he just cancelled repositioning
		outputChatBox("Repositioning cancelled",255,128,0)
		
		-- Stop handling repositioning
		removeEventHandler("onClientRender",getRootElement(),reposClockDoPulse)
	end
end
addCommandHandler("reposclock",toggleReposClock)

function reposClockDoPulse()
	-- Get the cursor position every frame
	local cursorX, cursorY = getCursorPosition()
	
	-- Set the clock to the new position
	CLOCK_X = cursorX * SCREEN_WIDTH
	CLOCK_Y = cursorY * SCREEN_HEIGHT
	
	-- Apply new position settings
	setSettings()
	
	-- Did the player just press the left mouse button?
	if getKeyState("mouse1") then
		-- Save the new position
		handleXMLSave()
		
		-- Stop the repositioning process
		repos = false
		removeEventHandler("onClientRender",getRootElement(),reposClockDoPulse)
		
		-- Hide the cursor
		showCursor(false)
		
		-- Notify them the repositioning is successful :)
		outputChatBox("Repositioning successful",255,128,0)
	elseif getKeyState("mouse2") then
		-- Right mouse button? Cancel movement
		toggleReposClock()
	end
end

function renderClock()
	-- Getting time and processing to rotation
	local time = getRealTime()
	
	local hour   = time.hour % 12 -- There are only 12 possible hours on an analog clock
	local minute = time.minute
	local second = time.second
	
	minute = minute + second / 60 -- To make the minute pointer a lot smoother
	hour   = hour   + minute / 60 -- Same as the above
	
	local hourRot   = 360 * ( hour   / 12 )
	local minuteRot = 360 * ( minute / 60 )
	local secondRot = 360 * ( second / 60 )
	
	-- Render background
	dxDrawImage(CLOCK_X,CLOCK_Y,CLOCK_DIAMETER,CLOCK_DIAMETER,CLOCK_IMG,0,0,0,CLOCK1_COLOR,CLOCK_POST_GUI)
	dxDrawImage(CLOCK_X,CLOCK_Y,CLOCK_DIAMETER,CLOCK_DIAMETER,CLOCK2_IMG,0,0,0,CLOCK2_COLOR,CLOCK_POST_GUI)
	
	-- Render hour pointer
	dxDrawImage(CLOCK_HOUR_X,CLOCK_HOUR_Y,CLOCK_HOUR_W,CLOCK_HOUR_H,CLOCK_HOUR_IMG,hourRot,CLOCK_HOUR_ROT_POS_X,CLOCK_HOUR_ROT_POS_Y,CLOCK_HOUR_COLOR,CLOCK_POST_GUI)
	
	-- Render minute pointer
	dxDrawImage(CLOCK_MINUTE_X,CLOCK_MINUTE_Y,CLOCK_MINUTE_W,CLOCK_MINUTE_H,CLOCK_MINUTE_IMG,minuteRot,CLOCK_MINUTE_ROT_POS_X,CLOCK_MINUTE_ROT_POS_Y,CLOCK_MINUTE_COLOR,CLOCK_POST_GUI)
	
	-- Render second pointer
	dxDrawImage(CLOCK_SECOND_X,CLOCK_SECOND_Y,CLOCK_SECOND_W,CLOCK_SECOND_H,CLOCK_SECOND_IMG,secondRot,CLOCK_SECOND_ROT_POS_X,CLOCK_SECOND_ROT_POS_Y,CLOCK_SECOND_COLOR,CLOCK_POST_GUI)
end