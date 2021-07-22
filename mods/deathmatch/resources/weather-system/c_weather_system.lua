
local currentWeather = 10
local timeSavedHour, timeSavedMinute
local x, y, z = nil

function ChangePlayerWeather(weather, forced)
	if forced or getElementData(localPlayer, 'loggedin') == 1 and getElementInterior( localPlayer ) == 0 and getElementDimension(localPlayer) == 0  then
		currentWeather = weather
		setWeather( currentWeather )
		setWeatherBlended( currentWeather )
	end
end
addEvent( "weather:update", true )
addEventHandler( "weather:update", root, ChangePlayerWeather )

function updateInterior()
	if getElementInterior( getLocalPlayer( ) ) > 0 then
		if getWeather( ) ~= 3 then
			setWeather( 3 )
			setSkyGradient( 0, 0, 0, 0, 0, 0 )
		end
	else
		local currentWeatherID, blended = getWeather( )
		if currentWeatherID ~= currentWeather and not blended then
			setWeather( currentWeather )
			resetSkyGradient( )
		end
	end
end
setTimer( updateInterior, 2000, 0)

function forceWeather(  )
	setWeather( currentWeather )
	resetSkyGradient()
	setTime(timeSavedHour, timeSavedMinute+1)
end

function resetWeather( )
	setWeather(1)
	setWeatherBlended(1)
	outputDebugString('Reset client weather.')
end

addEventHandler( "onClientResourceStart", resourceRoot, function()
	resetWeather()
	addEventHandler( 'account:character:select', root, resetWeather )
end )

addEventHandler( 'onClientResourceStop', resourceRoot, function()
	resetWeather()
	removeEventHandler( 'account:character:select', root, resetWeather )
end)

addCommandHandler("fw", function()
	if exports.integration:isPlayerAdmin(localPlayer) then
	outputChatBox("Fireworks created!", getRootElement())
	fxAddSparks(x, y, z+1, 0, 0, 0, 5, 1000, 0, 0, 1, false, 2, 2)
	--fxAddGunshot(x, y+0.5, z+1, 1, 3, 2, true)
	--fxAddTankFire(x, y+0.5, z+1, 1, 3, 2, true)
	--fxAddGunshot(x, y+0.5, z+1, 1, 3, 2, true)
	--fxAddTyreBurst(x, y+0.5, z+1, 1, 3, 2)
	--fxAddTyreBurst(x, y+0.5, z+1, 1, 3, 2)
	outputChatBox("Fireworks created!", getRootElement())
	else
	end
end)

addCommandHandler("setfw", function()
	if exports.integration:isPlayerAdmin(localPlayer) then
	x, y, z = getElementPosition(localPlayer)
	outputChatBox("Fireworks position set!", getRootElement())
	else
	end
end)

addCommandHandler("resetfw", function()
	if exports.integration:isPlayerAdmin(localPlayer) then
	x, y, z = nil, nil, nil
	outputChatBox("Fireworks position reset!", getRootElement())
	else
	end
end)

GUIEditor = {
    tab = {},
    tabpanel = {},
    button = {},
    window = {},
    memo = {}
}
function snowInfoGUI()
	if isElement(GUIEditor.window[1]) then destroyElement(GUIEditor.window[1]) end
	GUIEditor.window[1] = guiCreateWindow(576, 198, 464, 522, "Snow Roleplay Information", false)
	guiWindowSetSizable(GUIEditor.window[1], false)

	GUIEditor.button[1] = guiCreateButton(11, 487, 436, 25, "Close", false, GUIEditor.window[1])
	addEventHandler("onClientGUIClick", GUIEditor.button[1], function ()
			if isElement(GUIEditor.window[1]) then destroyElement(GUIEditor.window[1]) end
		end, false)
	GUIEditor.tabpanel[1] = guiCreateTabPanel(9, 23, 439, 459, false, GUIEditor.window[1])

	GUIEditor.tab[1] = guiCreateTab("Home", GUIEditor.tabpanel[1])

	GUIEditor.memo[1] = guiCreateMemo(5, 7, 427, 424, [[ Hello,

	December is upon us, with winter just 2 weeks away and snowfall picking up around the globe. Our fictional roleplay zone, San Andreas is now beginning to experience snowfall and temperature of all ranges. This is indeed a server-wide event, whether or not you'd like to take part of it visually, you will be expected to follow the rules.

	Reminder:
	/snow to toggle snowfall.
	/groundsnow to toggle the ground snow shaders.
	/snowsettings to customize snowfall.

	*Note violation of these rules may result in administrative punishment for powergaming.
	*Note snowplows and snowmobiles may operate as if they have snow tires installed.
	*Note snowmobiles are not motorcycles in the instance of usage restrictions. ]], false, GUIEditor.tab[1])
	guiMemoSetReadOnly(GUIEditor.memo[1], true)

	GUIEditor.tab[2] = guiCreateTab("Level 0", GUIEditor.tabpanel[1])

	GUIEditor.memo[2] = guiCreateMemo(5, 7, 427, 424, [[ Frost, subzero temperatures (Level 0)

	Temperature: Ranging from -5?C to 0?C | Ranging from 23?F to 32?F

	Weather Notice: Snow tires advised

	Snow settings: 0 (just /snow, don't bother editing to 0)

	RULES
	Vehicle:
	Max speed on pavement: 120 km/h, 135 km/h with snow tires
	Max speed off road: 50 km/h, 60 km/h with snow tires.
	Show fear of ice
	Prefer usage of roads recently paved. (If paving service is advertised)
	Visibility range: Regular, controlled by fog density if any.

	Person:
	Winter ware
	Snow play, otherwise avoid loitering in the cold for no reason.\
	Visibility range: Regular, controlled by fog density if any. ]], false, GUIEditor.tab[2])
	guiMemoSetReadOnly(GUIEditor.memo[2], true)

	GUIEditor.tab[3] = guiCreateTab("Level 1", GUIEditor.tabpanel[1])

	GUIEditor.memo[3] = guiCreateMemo(5, 7, 427, 424, [[ Snow Flurry (Level 1)

	Temperature: Ranging from -12?C to -6?C | Ranging from 10?F to 21?F

	​Weather Notice: Snow tires advised

	Snow settings:
	Density; 1000
	Snowflake size: 1-3
	Snow Wind Speed: 7
	Snow Fall Speed: 1-3

	RULES
	Vehicle:
	Max speed on pavement: 80 km/h, 90 km/h with snow tires
	Max speed off road: 20 km/h, 30 km/h with snow tires.
	Show fear of ice
	Prefer usage of roads recently paved. (If paving service is advertised)
	Motorcycles used less.
	Visibility range: 80 feet (70 for motorcycles)

	Person:
	Winter ware
	Snow play, otherwise avoid loitering in the cold for no reason.
	Visibility range: 65 feet ]], false, GUIEditor.tab[3])
	guiMemoSetReadOnly(GUIEditor.memo[3], true)

	GUIEditor.tab[4] = guiCreateTab("Level 2", GUIEditor.tabpanel[1])

	GUIEditor.memo[4] = guiCreateMemo(5, 7, 427, 424, [[ Snow Storm (Level 2)

	Temperature: Ranging from -18?C to -9?C | Ranging from -0.4?F to 16?F

	​Weather Notice: Snow tires advised
	Weather Notice: Frostbite warning
	Weather Notice: Aircrafts Grounded (IC)

	Snow settings:
	Density; 3500
	Snowflake size: 2-4
	Snow Wind Speed: 40
	Snow Fall Speed: 5-9

	RULES
	Vehicle:
	Max speed on pavement: 50 km/h, 65 km/h with snow tires
	Max speed off road: 15 km/h, 20 km/h with snow tires
	Show fear of ice
	Prefer usage of roads recently paved. (If paving service is advertised)
	Motorcycles used less
	Visibility range: 50 feet (30 for motorcycles)

	Person:
	Winter ware mandatory
	Snow play, otherwise avoid loitering in the cold for no reason.
	Visibility range: 30 feet
	 ]], false, GUIEditor.tab[4])
	guiMemoSetReadOnly(GUIEditor.memo[4], true)

	GUIEditor.tab[5] = guiCreateTab("Level 3", GUIEditor.tabpanel[1])

	GUIEditor.memo[5] = guiCreateMemo(5, 7, 427, 424, [[ Blizzard (Level 3)

	Temperature: Ranging from -22?C to -9?C | Ranging from -7.6?F to 16?F

	​Weather Notice: Snow tires advised
	Weather Notice: Severe Frostbite warning
	Weather Notice: Aircrafts Grounded (IC)

	Snow settings:
	Density; 5000
	Snowflake size: 2-4
	Snow Wind Speed: 80
	Snow Fall Speed: 7-12

	RULES
	Vehicle:
	Max speed on pavement: 35 km/h, 45 km/h with snow tires
	Max speed off road: 10 km/h
	Show fear of ice
	Prefer usage of roads recently paved. (If paving service is advertised)
	Motorcycles unused.
	Aircrafts Grounded (OOC)
	Visibility range: 25 feet

	Person:
	Winter ware mandatory
	Snow play, otherwise avoid loitering in the cold for no reason.
	Dense snow, sprint impossible - jogging very tiresome.
	Sharp snow blowing against exposed skin.
	Visibility range: 15 feet ]], false, GUIEditor.tab[5])
	guiMemoSetReadOnly(GUIEditor.memo[5], true)

	GUIEditor.tab[6] = guiCreateTab("Level 4", GUIEditor.tabpanel[1])

	GUIEditor.memo[6] = guiCreateMemo(5, 7, 427, 424, [[ Whiteout (Level 4)

	Temperature: Ranging from -22?C to -9?C | Ranging from -7.6?F to 16?F

	​Weather Notice: Snow tires advised
	Weather Notice: Severe Frostbite warning
	Weather Notice: Aircrafts Grounded (IC)

	Snow settings:
	Density; 7000
	Snowflake size: 3-5
	Snow Wind Speed: 100
	Snow Fall Speed: 10-15

	RULES
	Vehicle:
	Max speed on pavement: 20 km/h, 30 km/h with snow tires
	Max speed off pavement: Off limits
	Show fear of ice
	Prefer usage of roads recently paved. (If paving service is advertised)
	Motorcycles unused.
	Aircrafts Grounded (OOC)
	Visibility range: 10 feet

	Person:
	Winter ware mandatory
	Snow play, otherwise avoid loitering in the cold for no reason.
	Dense snow, sprint impossible - jogging very tiresome.
	Sharp snow blowing against exposed skin.
	Visibility range: 5 feet ]], false, GUIEditor.tab[6])
	guiMemoSetReadOnly(GUIEditor.memo[6], true)
end
--addCommandHandler("snowinfo", snowInfoGUI, false, false)
