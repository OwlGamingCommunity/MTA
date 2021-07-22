mysql = exports.mysql
--[[
-- Dumping structure for table mta.stats
CREATE TABLE IF NOT EXISTS `stats` (
  `district` varchar(45) NOT NULL,
  `deaths` double DEFAULT '0',
  PRIMARY KEY (`district`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
]]

function getDistrictDeaths(district)
	local districtDeathsSQL = mysql:query_fetch_assoc("SELECT deaths FROM stats WHERE district = '" .. mysql:escape_string(district) .. "' LIMIT 1") -- Fetch the current deaths from MySQL
	if not districtDeathsSQL then
		mysql:query_insert_free("INSERT INTO stats SET district = '" .. mysql:escape_string(tostring(district)) .. "', deaths ='0'") -- If the district doesn't exist in the database, create it
		deaths = 0
	else
		deaths = tonumber(districtDeathsSQL["deaths"])
	end
	return deaths
end

function recordDistrictDeath( ammo, attacker, weapon, bodypart )
	local district = exports.global:getElementZoneName(source, false)
	local currentDeaths = getDistrictDeaths(district)
	local updatedDeaths = tonumber(currentDeaths) + 1
	local districtDeathsUpdateSQL = mysql:query_free("UPDATE stats SET deaths = " .. mysql:escape_string(tonumber(updatedDeaths)) .. " WHERE district = '" .. mysql:escape_string(tostring(district)) .. "'")
	exports.global:sendMessageToAdmins("[DISTRICT] Number of deaths in " .. tostring(district) .. ": " .. tonumber(updatedDeaths))
end
addEventHandler("onPlayerWasted", getRootElement(), recordDistrictDeath)

function showDistrictInformation(thePlayer, commandName)
	local district = exports.global:getElementZoneName(thePlayer, false)
	outputChatBox("District Information - " .. district, thePlayer)
	outputChatBox("Deaths: " .. getDistrictDeaths(district), thePlayer)
end
addCommandHandler("districtinfo", showDistrictInformation, false, false)
