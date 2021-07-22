--dupont fashion show
--areaData = { x = 596.59997558594, y = -1251.0999755859, z = 74, interior = 3, dimension = 491, radius = 100 }

--stadium sacma
areaData = { x = -1446.0996, y = 992.09961, z = 1038.7, interior = 15, dimension = 1124, radius = 1000 }

local allowedAccounts = { [ "Socialz" ] = true, [ "FAILCAKEZ" ] = true, [ "Maxime" ] = true }
local areaShape

addCommandHandler( "restartsg",
	function( player, cmd )
		if ( allowedAccounts[ tostring( getElementData( player, "account:username" ) ) ] ) then
			restartResource( resource )
			
			outputChatBox( "Restarting resource...", player, 220, 180, 20, false )
		end
	end
)

addCommandHandler( "stopsg",
	function( player, cmd )
		if ( allowedAccounts[ tostring( getElementData( player, "account:username" ) ) ] ) then
			stopResource( resource )
			
			outputChatBox( "Stopping resource...", player, 220, 180, 20, false )
		end
	end
)

addEventHandler( "onResourceStart", resourceRoot,
	function( )
		areaShape = createColSphere( areaData.x, areaData.y, areaData.z, areaData.radius )
		setElementInterior( areaShape, areaData.interior )
		setElementDimension( areaShape, areaData.dimension )
		
		addEventHandler( "onColShapeHit", areaShape,
			function( hitElement, matchingDimension )
				if ( getElementType( hitElement ) == "player" ) and ( matchingDimension ) then
					triggerClientEvent( hitElement, "soundgroup:synchronize.map", hitElement, areaData )
				end
			end
		)
	end
)

addEvent( "soundgroup:ready", true )
addEventHandler( "soundgroup:ready", root,
	function( )
		if ( client ~= source ) then
			return
		end
		
		if ( isElementWithinColShape( client, areaShape ) ) then
			triggerClientEvent( client, "soundgroup:synchronize.map", client, areaData )
		end
	end
)

--[[
local currentMapFilePath = "maps/dupont-fashion-show.map"
local mapObjects, stageSound = { }, { }
local stageSetups = { "whitey", "negro" }
local currentStageSetup = 1
local settings = { lights = true, led = true }

local function isDynamicSetupElement( element )
	for _, setupName in ipairs( stageSetups ) do
		if ( getElementID( element ):find( setupName ) ) then
			return true
		end
	end
	
	return false
end

local function synchronizeMap( player )
	return triggerClientEvent( player, "soundgroup:synchronize.map", player, mapObjects, areaData )
end

local function loadMapFile( filePath, forceEnd, skipSynchronization )
	for _, element in pairs( mapObjects ) do
		destroyElement( element )
	end
	
	if ( forceFalse ) then
		return
	end
	
	for _, element in ipairs( getElementsByType( "object", getResourceMapRootElement( resource, filePath or currentMapFilePath ) ) ) do
		if ( isDynamicSetupElement( element ) ) and ( not getElementID( element ):find( stageSetups[ currentStageSetup ] ) ) then
			setElementDimension( element, 1337 )
		end
		
		table.insert( mapObjects, element )
	end
	
	if ( not skipSynchronization ) then
		for _, player in ipairs( getElementsByType( "player" ) ) do
			if ( isElementWithinColShape( player, areaShape ) ) then
				synchronizeMap( player )
			end
		end
	end
	
	return true
end

local function synchronizeSound( player )
	return triggerClientEvent( player, "soundgroup:synchronize.sound", player, stageSound )
end

local function playStageSound( filePath, forceEnd, skipSynchronization, x, y, z, interior, dimension, minDistance, maxDistance, volume )
	stageSound = { }
	
	if ( forceEnd ) then
		return
	end
	
	stageSound = { filePath = filePath, x = x or areaData.x, y = y or areaData.y, z = z or areaData.z, interior = interior or areaData.interior, dimension = dimension or areaData.dimension, minDistance = minDistance or 65, maxDistance = maxDistance or 200, volume = volume or 1 }
	
	if ( not skipSynchronization ) then
		for _, player in ipairs( getElementsByType( "player" ) ) do
			if ( isElementWithinColShape( player, areaShape ) ) then
				synchronizeSound( player )
			end
		end
	end
	
	return true
end

local function cautionMessage( player )
	outputChatBox( "OOC CAUTION! You have entered an organized event area. This area may cause real-life seizures, and to avoid this from happening read the following instructions.", player, 255, 0, 0, false )
	outputChatBox( "OOC CAUTION! You can shut down effects to prevent any seizures with the following commands:", player, 255, 0, 0, false )
	
	executeCommandHandler( "effecthelp", player )
	
	outputChatBox( "You can do these commands again to toggle on/off the effect. By seeing this message you agree that we are not responsible for any damage whatsoever.", player, 220, 180, 20, false )
	outputChatBox( "You can bring up the commands with the /effecthelp command.", player, 255, 0, 0, false )
end

addEvent( "soundgroup:synchronize.map", true )
addEventHandler( "soundgroup:synchronize.map", root,
	function( )
		if ( client ~= source ) then
			return
		end
		
		synchronizeMap( client )
	end
)

addEvent( "soundgroup:synchronize.sound", true )
addEventHandler( "soundgroup:synchronize.sound", root,
	function( )
		if ( client ~= source ) then
			return
		end
		
		synchronizeSound( client )
	end
)

addCommandHandler( "effecthelp",
	function( player, cmd )
		outputChatBox( "All effects off: /noeffects", player, 220, 180, 20, false )
		outputChatBox( "Led screen animations off: /noanimations", player, 220, 180, 20, false )
		outputChatBox( "Led screen off completely: /noled", player, 220, 180, 20, false )
		outputChatBox( "Flashing lights off: /nolights", player, 220, 180, 20, false )
		outputChatBox( "Less objects (less lag): /lessobjects", player, 220, 180, 20, false )
		outputChatBox( "No music: /nomusic", player, 220, 180, 20, false )
		outputChatBox( "Music volume: /musicvolume", player, 220, 180, 20, false )
	end
)

addCommandHandler( "playstagesound",
	function( player, cmd, filePath, volume, minDistance, maxDistance, x, y, z, interior, dimension )
		if ( allowedAccounts[ tostring( getElementData( player, "account:username" ) ) ] ) then
			if ( filePath ) then
				playStageSound( filePath, false, false, tonumber( x ) or nil, tonumber( y ) or nil, tonumber( z ) or nil, tonumber( interior ) or nil, tonumber( dimension ) or nil, tonumber( minDistance ) or nil, tonumber( maxDistance ) or nil, tonumber( volume ) or nil )
				outputChatBox( "Playing " .. filePath .. ".", player, 220, 180, 20, false )
			else
				outputChatBox( "SYNTAX: /" .. cmd .. " [file path]", player, 220, 180, 20, false )
			end
		end
	end
)

addCommandHandler( "togstagesetup",
	function( player, cmd )
		if ( allowedAccounts[ tostring( getElementData( player, "account:username" ) ) ] ) then
			for _, element in ipairs( mapObjects ) do
				if ( isDynamicSetupElement( element ) ) and ( getElementID( element ):find( stageSetups[ currentStageSetup ] ) ) then
					setElementDimension( element, 1337 )
				else
					setElementDimension( element, areaData.dimension or 0 )
				end
			end
			
			currentStageSetup = stageSetups[ currentStageSetup + 1 ] and currentStageSetup + 1 or 1
			
			outputChatBox( "Current stage setup is " .. stageSetups[ currentStageSetup ] .. " (" .. currentStageSetup .. ").", player, 220, 180, 20, false )
		end
	end
)

addCommandHandler( "toglightspls",
	function( player, cmd )
		if ( allowedAccounts[ tostring( getElementData( player, "account:username" ) ) ] ) then
			settings.lights = not settings.lights
			
			for _, player in ipairs( getElementsByType( "player" ) ) do
				triggerClientEvent( player, "soundgroup:synchronize.settings", player, settings )
			end
			
			outputChatBox( "Stage lighting is now " .. ( settings.lights and "on" or "off" ) .. ".", player, 220, 180, 20, false )
		end
	end
)

addCommandHandler( "togledpls",
	function( player, cmd )
		if ( allowedAccounts[ tostring( getElementData( player, "account:username" ) ) ] ) then
			settings.led = not settings.led
			
			for _, player in ipairs( getElementsByType( "player" ) ) do
				triggerClientEvent( player, "soundgroup:synchronize.settings", player, settings )
			end
			
			outputChatBox( "Stage LED wall is now " .. ( settings.led and "on" or "off" ) .. ".", player, 220, 180, 20, false )
		end
	end
)]]