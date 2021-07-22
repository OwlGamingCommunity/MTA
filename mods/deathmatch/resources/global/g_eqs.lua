-- Exciter Query String processing
-- Exciter Query String is a query string format used to define advanced, custom patterns for access checks on players. See documentation at the end of this file.

local debugMode, debugModeLocalOnly = false, false
local function godebug(arg1, arg2, arg3)
	local player
	local localMode = false
	local localOnly = false
	if isElement(arg1) then
		player = arg1
		localOnly = arg3
	else
		if isElement(localPlayer) then
			player = localPlayer
			localMode = true
			localOnly = arg2
		end
	end
	if not player then return end
	if exports.integration:isPlayerScripter(player) then
		debugMode = not debugMode
		outputChatBox("EQS debug set to "..tostring(debugMode))
	end
end
addCommandHandler("debugeqs", godebug)
local _outputDebugString = outputDebugString
local function outputDebugString(text, level, red, green, blue)
	if debugMode then
		_outputDebugString(text, level, red, green, blue)
	end
end

local function split(str, pat)
	local t = {}  -- NOTE: use {n = 0} in Lua-5.0
	local fpat = "(.-)" .. pat
	local last_end = 1
	local s, e, cap = str:find(fpat, 1)
	while s do
		if s ~= 1 or cap ~= "" then
			table.insert(t,cap)
		end
		last_end = e+1
		s, e, cap = str:find(fpat, last_end)
	end
	if last_end <= #str then
		cap = str:sub(last_end)
		table.insert(t, cap)
	end
	return t
end

local function isNumeric(a)
	if tonumber(a) ~= nil then return true else return false end
end

local function trim(s)
	s = s:gsub("^%s*(.-)%s*$", "%1")
	s = s:gsub("\n", "")
	return s
end

local function addVariables(s)
	local time = getRealTime()
	local month = time.month + 1
	local day = time.monthday
	local year = time.year + 1900
	local hour = time.hour
	local minute = time.minute
	local second = time.second
	local weekday = time.weekday

	local weekdays = {
		"Sunday",
		"Monday",
		"Tuesday",
		"Wednesday",
		"Thursday",
		"Friday",
		"Saturday"
	}
	local months = {
		"January",
		"February",
		"March",
		"April",
		"May",
		"June",
		"July",
		"August",
		"September",
		"October",
		"November",
		"December"
	}

	local d, m, yy, yyyy, hh, i, ss

	if(string.len(day) < 2) then
		d = "0"..tostring(day)
	else
		d = tostring(day)
	end
	
	if(string.len(month) < 2) then
		m = "0"..tostring(month)
	else
		m = tostring(month)
	end

	yyyy = tostring(year)
	yy = tostring(year):sub(-2)

	if(string.len(hour) < 2) then
		hh = "0"..tostring(hour)
	else
		hh = tostring(hour)
	end
	if(string.len(minute) < 2) then
		i = "0"..tostring(minute)
	else
		i = tostring(minute)
	end
	if(string.len(second) < 2) then
		ss = "0"..tostring(second)
	else
		ss = tostring(second)
	end

	--day
	s = s:gsub("{d}", tostring(d)) -- d 	Day of the month, 2 digits with leading zeros 	01 to 31
	s = s:gsub("{j}", tostring(day)) -- j 	Day of the month without leading zeros 	1 to 31
	s = s:gsub("{l}", tostring(weekdays[weekday])) -- l (lowercase 'L') 	A full textual representation of the day of the week 	Sunday through Saturday
	s = s:gsub("{D}", tostring(weekdays[weekday]:sub(1, 3))) -- D 	A textual representation of a day, three letters 	Mon through Sun

	--month
	s = s:gsub("{m}", m) -- m 	Numeric representation of a month, with leading zeros 	01 through 12
	s = s:gsub("{n}", tostring(month)) -- n 	Numeric representation of a month, without leading zeros 	1 through 12
	s = s:gsub("{F}", tostring(months[month])) -- F 	A full textual representation of a month, such as January or March 	January through December
	s = s:gsub("{M}", tostring(months[month]:sub(1, 3))) -- M 	A short textual representation of a month, three letters 	Jan through Dec

	--year
	s = s:gsub("{Y}", tostring(yyyy)) -- Y 	A full numeric representation of a year, 4 digits 	Examples: 1999 or 2003
	s = s:gsub("{y}", tostring(yy)) -- y 	A two digit representation of a year 	Examples: 99 or 03

	--Time
	s = s:gsub("{G}", tostring(hour)) -- G 	24-hour format of an hour without leading zeros 	0 through 23
	s = s:gsub("{H}", tostring(hh)) -- H 	24-hour format of an hour with leading zeros 	00 through 23
	s = s:gsub("{i}", tostring(i)) -- i 	Minutes with leading zeros 	00 to 59
	s = s:gsub("{s}", tostring(ss)) -- s 	Seconds, with leading zeros 	00 through 59

	return s
end

local function eqsProcessPart(thePlayer, part)
	local count = 0
	local theItem = split(part, "=")
	if isNumeric(theItem[1]) then --if number, then treat it as a itemID
		if theItem[2] then
			outputDebugString("value match requested")
			if(isNumeric(theItem[2])) then theItem[2] = tonumber(theItem[2]) else theItem[2] = addVariables(tostring(theItem[2])) end
			local hasItem, key, value2, value3 = hasItem(thePlayer, tonumber(theItem[1]), theItem[2])
			if hasItem then
				outputDebugString("has value, +1")
				return true				
			end
		else
			local hasItem, key, value2, value3 = hasItem(thePlayer, tonumber(theItem[1]))
			if hasItem then
				outputDebugString("has item")
				outputDebugString("badges["..tostring(theItem[1]).."] = "..tostring(badges[theItem[1]]))
				--if badges[theItem[1]] then
				--if exports["item-system"]:isBadge(theItem[1]) then
					--if(getElementData(thePlayer, badges[theItem[1]][1])) then
					--if exports["item-system"]:isWearingBadge(thePlayer, theItem[1]) then
					--	return true
						--outputDebugString("badge on, +1")
					--end
				--else
					return true
				--end
			end
		end
	else --if not numeric, check the text value agains the special conditions
		local textFunction = tostring(theItem[1])
		if textFunction == "F" or textFunction == "FACTION" then --check for faction membership
			outputDebugString("faction")
			if theItem[2] then --if a value is specified
				outputDebugString("value is "..theItem[2])
				local checkFaction = split(theItem[2], "-")
				if isNumeric(checkFaction[1]) then --if it is a number, we're checking for faction ID
					outputDebugString("numeric")
					if isNumeric(checkFaction[2]) then --if faction rank is specified and is a number (valid)
						if exports.factions:isPlayerInFaction(thePlayer, tonumber(checkFaction[1]), tonumber(checkFaction[2])) then
							return true
						end
					else
						outputDebugString("isPlayerInFaction = "..tostring(exports.factions:isPlayerInFaction(thePlayer, tonumber(checkFaction[1]))))
						if exports.factions:isPlayerInFaction(thePlayer, tonumber(checkFaction[1])) then
							return true
						end
					end
				else --if not a number, we're checking for faction name
					local checkFactionName = tostring(theItem[2]) --we cant check ranks on faction names, since the names may contain '-'
					local factionID = exports.factions:getFactionIDFromName(checkFactionName)
					if factionID then
						if exports.factions:isPlayerInFaction(thePlayer, factionID) then
							return true
						end
					end
				end
			end
		elseif textFunction == "FL" or textFunction == "FACTIONLEADER" then --check for faction leadership
			if theItem[2] then --if a value is specified
				local checkFaction = split(theItem[2], "-")
				if isNumeric(checkFaction[1]) then --if it is a number, we're checking for faction ID
					if isNumeric(checkFaction[2]) then --if faction rank is specified and is a number (valid)
						local isMember, rank = exports.factions:isPlayerInFaction(thePlayer, tonumber(checkFaction[1]), tonumber(checkFaction[2]))
						local isLeader = exports.factions:hasMemberPermissionTo(thePlayer, tonumber(checkFaction[1]), "add_member")
						if isMember and isLeader then
							return true
						end
					else
						local isMember, rank = exports.factions:isPlayerInFaction(thePlayer, tonumber(checkFaction[1]))
						local isLeader = exports.factions:hasMemberPermissionTo(thePlayer, tonumber(checkFaction[1]), "add_member")
						if isMember and isLeader then
							return true
						end
					end
				else --if not a number, we're checking for faction name
					local checkFactionName = tostring(theItem[2]) --we cant check ranks on faction names, since the names may contain '-'
					local factionID = exports.factions:getFactionIDFromName(checkFactionName)
					if factionID then
						local isMember, rank = exports.factions:isPlayerInFaction(thePlayer, factionID)
						local isLeader = exports.factions:hasMemberPermissionTo(thePlayer, tonumber(checkFaction[1]), "add_member")
						if isMember and isLeader then
							return true
						end
					end
				end
			end
		elseif textFunction == "PILOT" then --check for pilot licenses
			local pilotlicenses = exports.mdc:getPlayerPilotLicenses(thePlayer) or {}
			if theItem[2] then --if a value is specified
				local requireLicense = split(theItem[2], "-")
				if isNumeric(requireLicense[1]) then --if value is number, check against license IDs
					for licenseKey, licenseValue in ipairs(pilotlicenses) do
						if licenseValue[1] == tonumber(requireLicense[1]) then
							if licenseValue[1] == 7 and requireLicense[2] and tonumber(requireLicense[2]) then --if a second value is specified, also match typerating
								if tonumber(requireLicense[2]) == licenseValue[2] then
									return true
								end
							else
								return true
							end
						end
					end
				else --if not number, check against license names
					for licenseKey, licenseValue in ipairs(pilotlicenses) do
						if tostring(licenseValue[3]) == tostring(requireLicense[1]) then
							if licenseValue[1] == 7 and requireLicense[2] and tonumber(requireLicense[2]) then --if a second value is specified, also match typerating
								if tonumber(requireLicense[2]) == licenseValue[2] then
									return true
								end
							else
								return true
							end
						end
					end
				end
			else --if no value
				if #pilotlicenses > 0 then
					--check if player has one of the following licenses: ADP, ROT, SER (the lowest pilot licenses that any pilot will have also if they have higher ratings)
					for licenseKey,licenseValue in ipairs(pilotlicenses) do
						if licenseValue[1] == 2 or licenseValue[1] == 3 or licenseValue[1] == 4 then
							return true
						end
					end
				end
			end
		elseif textFunction == "VMAT" then --check for vehcile with VMAT
			local theVehicle = getPedOccupiedVehicle(thePlayer)
			if theVehicle then
				local vmatItemID = 264
				local hasItem, key, value2, value3 = exports.global:hasItem(theVehicle, vmatItemID)
				if hasItem then
					return true
				end
			end
		elseif textFunction == "C" or textFunction == "CHARACTER" then --check for character name
			outputDebugString("character")
			if theItem[2] then --if a value is specified
				local playerName = getPlayerName(thePlayer)
				outputDebugString("'"..tostring(playerName).."' = '"..tostring(theItem[2]).."'")
				if string.lower(playerName) == string.lower(theItem[2]) then
					outputDebugString("ok")
					return true
				end
			end
		end
	end

	return false
end

--exported
function exciterQueryString(thePlayer, query)
	outputDebugString("EQS: "..tostring(query))
	if not thePlayer or not query then return false end
	query = trim(tostring(query))
	local tempAccess = split(query, " AND ")
	local badges = exports["item-system"]:getBadges()
	local count = 0
	for _, itemID in ipairs(tempAccess) do
		local orString = split(itemID, " OR ")
		if(#orString > 1) then
			outputDebugString("or alternatives found")
			for k, v in ipairs(orString) do
				local match = eqsProcessPart(thePlayer, orString[k])
				if match then
					count = count + 1
					break
				end
			end
		else
			local match = eqsProcessPart(thePlayer, orString[1])
			if match then
				count = count + 1
			end
		end
	end
	outputDebugString("#tempAccess:"..tostring(#tempAccess).." count:"..tostring(count))
	if(#tempAccess == count) then
		outputDebugString("EQS returns true")
		return true
	else
		outputDebugString("EQS returns false")
		return false
	end
end

--[[

Introduction to Exciter Query String

	Exciter Query String (EQS) is a query string format used to define advanced, custom patterns for access checks on players. This can be applied to for example gates and item permissions.

	Check for items
		Simply enter the item ID of the item. You can also require a specific item value for the item, by adding = after the item ID, like this: 2=123456 (will grant access if player has a phone (item ID 2) with number 123456)
	Check all of multiple conditions: AND
		To check for multiple conditions and require them all to match, use the AND divider. Example "2 AND 7" will grant access for anyone who has both a cellphone and a phonebook in their inventory.
	Check any of multiple conditions: OR
		Like AND, but only one of the conditions need to be met. Note that OR is checked at the level below AND.
	Check for pilot licenses
		The text PILOT will grant access to anyone with pilot license of rating SER, ROT or higher, or a Airport Driving Permit (ADP). You can also check for a specific pilot license by adding a = and specifying either the 3-letter name of the license (example: "PILOT=TER"), the number ID of the license, or check for a typerating by using "PILOT=7-TYPERATINGID" (you find typerating IDs in the FAA forum, whereas the typerating ID is the 3-digit number of the MTA vehicle model).
	Check for faction
		Use the letter F, and a = followed by the faction ID or name. Example "F=1" will work for every member of the LSPD faction. To work for faction members of a specific rank, add a - followed by the rank number, like "F=1-2". If you want to only allow faction leaders, then use FL instead of F.
	Check for character name
		Use the letter C, and a = followed by the character name. Example "C=John Doe" will grant access to the character named John Doe.

Examples:

	"64 OR 65"
		Access granted to players with item ID 64 (LSPD badge) or 65 (LSES badge).
	"F=1 AND PILOT OR 127"
		Access granted to players that are member of faction 1 (LSPD) and have a pilot license, or who has item 127 (LSIA/FAA badge).

]]