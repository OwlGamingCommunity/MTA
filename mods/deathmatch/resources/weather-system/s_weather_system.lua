--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

local weatherArray = {}
local weatherStartTime = 0
local currentWeather = { 1, 1000, 10 }
local weatherTimer = nil
--[[local weatherStates = {
	sunny = { 0, 1, 2, 3, 4, 5, 6, 10, 13, 14, 23, 24, 25, 26, 27, 29, 33, 34, 40, 46, 52, 302, 12800 }, --  11, 17, 18  has heat waves
	clouds = { 7, 12, 15, 31, 30, 35, 36, 37, 41, 43, 47, 48, 49, 50, 51, 53, 56, 60 },
	rainy = { 8, 16, 306 },
	fog = { 9, 20, 28, 32, 38, 42, 55, 65, 88, 800 },
	dull = { 12, 54 },
	--sandstorm = { 19 },
}]]

local weatherStates = {
 { 1, 2, 3, 4, 5, 6, 8, 9, 10, 13, 14}, -- 23, 24, 25,  27, 29, 33, 34, 40, 46, 52, 302, 12800 }, --  0, 11, 17, 18  has heat waves
 { 7, 12, 15 }, -- 31, 30, 35, 36, 37, 41, 43, 47, 48, 49, 50, 51, 53, 56, 60 },
 { 8, 16 }, --, 306 },
 { 9, 20, 28, 32}, -- 38, 42, 55, 65, 88, 800 },
 { 12}, --, 54 },
	--sandstorm = { 19 },
}

mysql = exports.mysql
function changeWeather()
	if  #weatherArray < 4 then
		while (#weatherArray < 8) do
			table.insert(weatherArray, { 1, generateRandomTime() } ) -- generateWeatherTypes()
		end
	end

	if weatherArray[1] then
		weatherStartTime = getRealTime().timestamp
		currentWeather = weatherArray[1]
		table.remove(weatherArray, 1)

		-- Generate new weatherstyle
		--outputDebugString("wtfman")
		local weatherStyle = currentWeather[1]
		--outputDebugString(tostring(#weatherStates[weatherStyle ]))
		--outputDebugString("wtfman2")
		currentWeather[3] = weatherStates[currentWeather[1]][math.random(1, #weatherStates[currentWeather[1]])]
		--outputDebugString("wtfman3")
		--exports.global:sendMessageToAdmins("Weather changing to "..currentWeather[1]..":"..currentWeather[3] .." for "..	currentWeather[2] .. " second(s).")
		--outputDebugString("wtfman4")
		-- Shift weather
		triggerClientEvent("weather:update", root, currentWeather[3])
		-- Update SQL - Chuevo
		local weatherID = getWeather()
		local weatherSQLUpdate = mysql:query_free("UPDATE `settings` SET `value`='" .. weatherID .. "' WHERE `name`='weather'")
		if weatherSQLUpdate then
			--exports.global:sendMessageToAdmins("[WEATHER] SQL Settings for weather successfully set to " .. weatherID .. ".")
			--outputDebugString("[WEATHER] / Line 57 / SQL Settings for weather successfully altered.")
		end
		if not weatherSQLUpdate then
			outputDebugString("[WEATHER] / Line 60 / SQL Settings for weather was not changed.")
		end
		-- Cleanup
		if weatherTimer and isTimer(weatherTimer) then
			killTimer(weatherTimer)
		end
		weatherTimer = setTimer(changeWeather, currentWeather[2]*1000, 1)
	end
end

function getWeatherRawr(tp)
	if exports.integration:isPlayerTrialAdmin(tp) then
		local weather = getWeather()
		outputChatBox("Weather: " .. weather, tp)
	end
end
addCommandHandler("getweather", getWeatherRawr)

function eta(tp)
	if exports.integration:isPlayerTrialAdmin(tp) then
		local timed = weatherStartTime + currentWeather[2]
		local realtime = getRealTime( timed - 3600  )
		outputChatBox("Time of next change: "..realtime.hour .. ":"..realtime.minute, tp)
	end
end
addCommandHandler("eta", eta)

function srl(tp, commandName, rainLevel)
	if exports.integration:isPlayerSeniorAdmin(tp) then
		if not rainLevel or tonumber(rainLevel) > 40 then
		outputChatBox("Invalid level entered.", tp)
		else
		setRainLevel(rainLevel)
		local rank = exports.global:getPlayerAdminTitle(tp)
		local name = getPlayerName(tp):gsub("_"," ")
		exports.global:sendMessageToAdmins("AdmCmd: "..rank.." "..name.." set the rain level to: "..rainLevel)
		outputChatBox("Set rain level to: "..rainLevel, tp)
		end
	end
end
addCommandHandler("srl", srl)

function sw(tp, commandName, weather)
	if exports.integration:isPlayerTrialAdmin(tp) then
		if not weather or not tonumber(weather) then
			outputChatBox("Invalid ID entered.", tp)
		else
			currentWeather[3] = tonumber(weather)
			triggerClientEvent("weather:update", root, tonumber(weather))
			local rank = exports.global:getPlayerAdminTitle(tp)
			local name = getPlayerName(tp):gsub("_"," ")
			exports.global:sendMessageToAdmins("AdmCmd: "..rank.." "..name.." set the weather to ID: "..weather)
			outputChatBox("Weather set to ID: "..weather, tp)
			mysql:query_free("UPDATE `settings` SET `value`='" .. weather .. "' WHERE `name`='weather'")
		end
	end
end
addCommandHandler("sw", sw)

function swb(tp, commandName, weather)
	if exports.integration:isPlayerAdmin(tp) then
		if not weather then
		outputChatBox("Invalid ID entered.", tp)
		else
			setWeatherBlended(tonumber(weather))
			local rank = exports.global:getPlayerAdminTitle(tp)
			local name = getPlayerName(tp):gsub("_"," ")
			exports.global:sendMessageToAdmins("AdmCmd: "..rank.." "..name.." blended the weather to ID: "..weather)
			outputChatBox("Blending weather to set ID: "..weather, tp)
		end
	end
end
addCommandHandler("swb", swb)

function swh(tp, commandName, height)
	if exports.integration:isPlayerAdmin(tp) then
		if not height and not height < 40 then
		outputChatBox("Invalid ID entered.", tp)
		else
			setWaveHeight(height)
			local rank = exports.global:getPlayerAdminTitle(tp)
			local name = getPlayerName(tp):gsub("_"," ")
			exports.global:sendMessageToAdmins("AdmCmd: "..rank.." "..name.." set the wave height to: "..height)
			outputChatBox("Setting wave height to: "..height, tp)
		end
	end
end
addCommandHandler("swh", swh)

--[[
function sf(tp, commandName, fogLevel)
	if exports.integration:isPlayerTrialAdmin(tp) then
	setFogDistance(fogLevel)
	local rank = exports.global:getPlayerAdminTitle(tp)
	local name = getPlayerName(tp):gsub("_"," ")
	exports.global:sendMessageToAdmins("AdmCmd: "..rank.." Admin "..name.." set the fog level to: "..fogLevel)
	outputChatBox("Set fog level to: "..fogLevel, tp)
	else
	end
end
addCommandHandler("sf", sf)

function swv(tp, commandName, x, y, z)
	if exports.integration:isPlayerAdmin(tp) then
	x = tonumber(x) or 0
	y = tonumber(y) or 0
	z = tonumber(z) or 0
	setWindVelocity(x, y, z)
	outputChatBox("Wind velocity set to: ("..x..", "..y..", "..z..").", tp)
	else
	end
end
addCommandHandler("swv", swv)

function st( tp, commandName, hour, minute )
	if exports.integration:isPlayerAdmin(tp) then
	setTime ( hour, minute )
	outputChatBox ( "Time set to: "..hour..":"..minute..".", tp)
	end
end
addCommandHandler("st", st)

function shh(tp, commandName, heathazeLevel)
	if exports.integration:isPlayerAdmin(tp) then
		setHeatHaze(heathazeLevel)
		outputChatBox("Set heat haze level to: "..heathazeLevel, tp)
	else
		--exports.global:sendMessageToAdmins("AdmWrn: " .. getPlayerName(tp):gsub("_"," ") .. " has attempted to use the /srl command!")
	end
end
addCommandHandler("shh", shh)

function swh(tp, commandName, whLevel)
	if exports.integration:isPlayerAdmin(tp) then
	setWaveHeight(whLevel)
	outputChatBox("Wave height level set to: "..whLevel, tp)
	else
	end
end
addCommandHandler("swh", swh)
]]--[[ Causes massive glitchout with vehicles that are lowered going over Santa Maria Beach Bridge
function swl(tp, commandName, waterLevel)
	if exports.integration:isPlayerScripter(tp) then
	if wata == 1 then
	destroyElement ( wata )
	else
	wata = createWater(-2998, -2998, 0, 2998, -2998, 0, -2998, 2998, 0, 2998, 2998, 0)
	setWaterLevel(wata, waterLevel)
	setWaterLevel(waterLevel, true, true)
	outputChatBox("Water level set to: "..waterLevel, tp)
	end
	else
	end
end
addCommandHandler("swl", swl)

function swr(tp)
	if exports.integration:isPlayerScripter(tp) then
	setWaterLevel(wata, 0)
	setWaterLevel(0, true, true)
	outputChatBox("Water level reset.", tp)
	destroyElement ( wata )
	else
	end
end
addCommandHandler("swr", swr)]]

--[[
function swb(tp, commandName, wb2)
	if exports.integration:isPlayerAdmin(tp) then
	local wb1 = getWeather()
	setWeatherBlended(wb2)
	outputChatBox("Weather blend set to IDs: "..wb1.." and "..wb2, tp)
	else
	end
end
addCommandHandler("swb", swb)
]]

function etan(tp, command)
	if exports.integration:isPlayerTrialAdmin(tp) then
		if not exports.integration:isPlayerAdmin(tp) then
			triggerEvent("ia:autosuspend", tp, tp, 5, "Abuse of /" ..command)
		else
			changeWeather()
			local timed = weatherStartTime + currentWeather[2]
			local realtime = getRealTime( timed - 3600  )
			outputChatBox("Time of change: "..realtime.hour .. ":"..realtime.minute, tp)
		end
	end
end
addCommandHandler("etanow", etan)

function generateWeatherTypes()
	return (math.random(1, #weatherStates) < #weatherStates / 1.5 and math.random(1, 2) or math.random(1, #weatherStates))
end

function generateRandomTime()
	return ((math.random(1, 6) == 1 and math.random(10, 26) or math.random(29, 120)) * 60) -- Generate time in seconds
end

function requestWeather()
	triggerClientEvent(source, "weather:update", source, currentWeather[3], true )
end
addEventHandler( 'account:character:spawned', root, requestWeather )

function parseWeatherDetails(condition, humidity, temperature, wind, icon)
	if condition == "ERROR" then
		return
	elseif condition == nil then
		return
	else
		if w == 'sunny' or w == 'mostly sunny' or w == 'chance of storm' then
			setWeatherEx( 'sunny' )
		elseif w == 'partly cloudy' or w == 'mostly cloudy' or w == 'smoke' or w == 'cloudy' then
			setWeatherEx( 'clouds' )
		elseif w == 'showers' or w == 'rain' or w == 'chance of rain' then
			setWeatherEx( 'rainy' )
		elseif w == 'storm' or w == 'thunderstorm' or w == 'chance of tstorm' then
			setWeatherEx( 'stormy' )
		elseif w == 'fog' or w == 'icy' or w == 'snow' or w == 'chance of snow' or w == 'flurries' or w == 'sleet' or w == 'mist' then
			setWeatherEx( 'fog' )
		elseif w == 'dust' or w == 'haze' then
			setWeatherEx( 'dull' )
		end
	end
end
setTimer( changeWeather, 5000, 1)


local weatherNames = {
-- [weatherID] = { str name, int temperatureMin, int temperatureMax }
[0] = { "Very Sunny", 30, 38 },
[1] = { "Sunny", 20, 32 },
[2] = { "Very Sunny with Smog", 30, 38 },
[3] = { "Sunny with Smog", 18, 30 },
[4] = { "Cloudy", 15, 25 },
[8] = { "Rainy", 15, 25 },
[9] = { "Foggy", 15, 25 },
[19] = { "Very Windy", 15, 20 }
}

function processWeatherNames(id)
	if (id == 0) or (id == 6) or (id == 11) or (id == 13) or (id == 17) then return 0 end -- very Sunny
	if (id == 1) or (id == 5) or (id == 10) or (id == 14) or (id == 18) then return 1 end -- Sunny
	if (id == 4) or (id == 7) or (id == 12) or (id == 15) then return 4 end -- cloudy
	if (id == 8) or (id == 16) then -- rainy
		return 8
	else
		return tonumber(id)
	end -- else
end

function randomTemp(id)
	if not id then return end
		local random = math.random(weatherNames[id][2], weatherNames[id][3])
	if random then return random end
end

--[[addCommandHandler("currentweather", function (thePlayer)
	local processedID = processWeatherNames(getWeather())
	outputChatBox(weatherNames[processedID][1].." with a temperature of "..tostring(randomTemp(processedID)), thePlayer)
end)]]

local currentW
function checkWeather()
	local processedID = processWeatherNames(getWeather())
	if processedID == currentW then return nil end

	local weatherInfo = {
	{"Weather"},
	{""},
	}

	table.insert(weatherInfo, {" Environment is ".. weatherNames[processedID][1]})
	table.insert(weatherInfo, {" Temperature is "..tostring(randomTemp(processedID)).." degrees."})

	triggerClientEvent(root, "hudOverlay:drawOverlayTopRight", root, weatherInfo )

	currentW = processedID
end

addEventHandler("onResourceStart", resourceRoot, function ()
	-- disable this during winter event (snow stuff)
	setTimer( checkWeather, 2000, 0 )
end)

-- snow level stuff
function showSnowInfo(thePlayer)
	local snowlevel = getElementData(root, "snowlevel") or "[NOT SET]"
	local temperature = getElementData(root, "temperature") or "[NOT SET]"

	local snowInfo = {
	{"Snow Information"},
	{""},
	}

	table.insert(snowInfo, {"	The current snow level is "..snowlevel.."."})
	table.insert(snowInfo, {"	The current temperature is "..temperature.." degrees celcius."})

	triggerClientEvent(thePlayer, "hudOverlay:drawOverlayTopRight", root, snowInfo)
end
--addCommandHandler("weatherinfo", showSnowInfo, false, false)
-- Disabled command (anumaz, 2015/03/23) due to the fact this was used for snow stuff.

function setSnowSettings(thePlayer, commandName, snowlevel, temperature)
	if exports.integration:isPlayerTrialAdmin(thePlayer) then
		if not snowlevel or not temperature then
			outputChatBox("SYNTAX: /"..commandName.." [snow level: 0 to 4] [temperature in celcius] -- Example: /setsnowlevel 4 -10", thePlayer)
		else
			if tonumber(snowlevel) and tonumber(temperature) and tonumber(snowlevel) >= 0 and tonumber(snowlevel) <= 4 then
				setElementData(root, "snowlevel", tonumber(snowlevel))
				setElementData(root, "temperature", tonumber(temperature))
				exports.global:sendMessageToAdmins(getPlayerName(thePlayer).." has set snow level to "..snowlevel.." and temperature to "..temperature)

				local snowInfo = {
				{"Snow Information"},
				{""},
				}

				table.insert(snowInfo, {"	The current snow level is "..snowlevel.."."})
				table.insert(snowInfo, {"	The current temperature is "..temperature.." degrees celcius."})

				triggerClientEvent(root, "hudOverlay:drawOverlayTopRight", root, snowInfo)
			else
				outputChatBox("Snow level can be 0, 1, 2, 3 or 4.", thePlayer)
			end
		end
	end
end
--addCommandHandler("setsnowlevel", setSnowSettings, false, false)
