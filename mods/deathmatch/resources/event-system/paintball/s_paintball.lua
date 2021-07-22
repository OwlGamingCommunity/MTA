--[[ NOTE FOR SCRIPTERS:

	* weapon/weapons_c.lua > traceBullet
	
		getElementData(localPlayer, "paintball") ~= 2
		
	Above snippet must be checked before executing the function.
	 
	* weapon/weapons_selector_c.lua > renderWeaponSelector
		
		getElementData(localPlayer, "paintball") ~= 2

	Above snippet must be checked before executing the function.
	
	* es-system/s_injuries.lua > injuries
		
		if getElementData(source, "paintball") and getElementData(source, "paintball") == 2 then
			return
		end
		
	Above snippet must be added at the top of the function so the headshot and injury script isn't ran when shot with a paintball gun.
	
	* ped-system/c_peds_rightclick.lua > clickPed
	
	This function has a quoted out snippet which is used to access the paintball lobbies, leaderboard & feedback script.
	
	* weapon/C_Sounds.lua > playGunfireSound
	
	Above function has been modified to play paintball sounds when firing.
	
	* pd-system/c_wDistrict > onClientPlayerWeaponFire
	
	Disabled weapon districts if player is in paintball.
	
]]

local MATCH_COUNT = 4 -- Number of matches that can be operating at once.
local MATCH_PLAYERS = 10 -- Number of players per match. Splits into 2 for per team.
local MONEY = 0 -- Money generated total.

local PRIMARY_MAGS = 4 -- How many magazines the players primary weapon starts with
local SECONDARY_MAGS = 3 -- Same as above, for secondary weapons

local paintballguns = { 
	[31] = { "Milsig M17 Elite Marker", 3, 1 }, -- M4
	[25] = { "APS RAM .68CAL Shotgun Marker", 5, 1 }, -- Shotgun
	[24] = { "Valken Blackhawk Marker", 8, 2 }, -- Deagle
	[34] = { "RAP4 Sidewinder Sniper Marker", 25, 1 }, -- Sniper
	[29] = { "Kriss Vector Paintball Marker", 3, 2 }, -- MP5
}

local teams = {
	[1] = { "Grove Street Families", 0, 153, 0, { 105, 106, 107 } },
	[2] = { "Ballas", 255, 0, 255, { 102, 103, 104 } },
	[3] = { "Varrios Los Aztecas", 0, 128, 255, { 114, 115, 116 } },
	[4] = { "Los Santos Vagos", 255, 255, 0, { 108, 109, 110 } },
	[5] = { "Fast Food Crew", 255, 0, 0, { 155, 167, 205 } },
	[6] = { "Police", 0, 0, 220, { 280, 281, 282 } },
	-- name, r, g, b, skins
}

local leaderboard = {}

local function getPaintballDamage(weaponID, thePlayer, theTarget)
	if thePlayer and theTarget then
		local x, y, z = getElementPosition(thePlayer)
		local tx, ty, tz = getElementPosition(theTarget)
		local distance = getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)
		-- range specific damages
		if weaponID == 25 then
			if distance < 10 then
				return 60
			elseif distance < 5 then
				return 80
			else
				return 40
			end
		end
	end
	
	-- other
	return (weaponID == 31 and 20) or (weaponID == 24 and 30) or (weaponID == 34 and 75) or (weaponID == 29 and 20) or 0
end

local function getRandomTeams()
	local rTeam1 = math.random(1, #teams)
	local rTeam2 = math.random(1, #teams)
	if (rTeam1 == rTeam2) then
		if rTeam2 == #teams then
			rTeam2 = #teams - 1
		else
			rTeam2 = #teams
		end
	end
	return rTeam1, rTeam2
end

local matches = {}
for i = 1, MATCH_COUNT do
	local rTeam1, rTeam2 = getRandomTeams()
	table.insert(matches, { players = {}, teams = { rTeam1, rTeam2 }, state = 0 })
end

local arenas = {
	[1] = { "LikeMike's Car Cemetery", 10, 953, positions = {
			[1] = { 1552.0895, 1323.0459, 10.92667, 90 },
			[2] = { 1552.071, 1324.0208, 10.92667, 90 },
			[3] = { 1552.0533, 1324.970, 10.92667, 90 },
			[4] = { 1552.6376, 1324.5067, 10.92667, 90 },
			[5] = { 1552.6555, 1323.5569, 10.92667, 90 },
			
			[6] = { 1510.8328, 1338.3708, 10.90167, 270 },
			[7] = { 1510.8479, 1337.3182, 10.90167, 270 },
			[8] = { 1510.8922, 1336.218, 10.90167, 270 },
			[9] = { 1510.0193, 1336.7449, 10.90167, 270 },
			[10] = { 1510.0748, 1337.8539, 10.90167, 270 },
		},
	},
	
	[2] = { "MindScape's Battlefield", 10, 860, positions = {
			[1] = { 1462.93, 1465.83, 11, 140 },
			[2] = { 1458.13, 1467.29, 11, 140 },
			[3] = { 1463.79, 1461.02, 10.97, 140 },
			[4] = { 1457.47, 1462.76, 11, 140 },
			[5] = { 1459.8, 1460, 11, 140 },
	
			[6] = { 1412.82, 1427.37, 11, 320 },
			[7] = { 1411, 1431.1, 11, 320 },
			[8] = { 1417.21, 1425.84, 11, 320 },
			[9] = { 1415.14, 1431.17, 11, 320 },
			[10] = { 1412.75, 1434.4, 11, 320 },
		},
	},
	
	[3] = { "Unitts' Warehouse", 10, 885, positions = {
			[1] = { 1447, 1575, 11, 310 },
			[2] = { 1448.9, 1575, 11, 310 },
			[3] = { 1447.3, 1576.69, 11, 310 },
			[4] = { 1448.8, 1577.3, 11, 310 },
			[5] = { 1449.59, 1576.4, 11, 310 },
			
			[6] = { 1486.3, 1622.59, 11, 126 },
			[7] = { 1484.69, 1622.59, 11, 126 },
			[8] = { 1486.09, 1621, 11, 126 },
			[9] = { 1483.8, 1621.4, 11, 126 },
			[10] = { 1484.59, 1620.5, 11, 126 },
		},
	},
	
	[4] = { "Shipment", 8, 1470, positions = {
			[1] = { 2676.3, -1434.4, 286.6, 134 },
			[2] = { 2674.3, -1343.4, 286.6, 134 },
			[3] = { 2676.19, -1436.4, 286.6, 134 },
			[4] = { 2673.6, -1345.8, 286.6, 134 },
			[5] = { 2674.8, -1437.09, 286.6, 134 },
			
			[6] = { 2632, -1472.8, 286.6, 0 },
			[7] = { 2633.5, -1472.8, 286.6, 0 },
			[8] = { 2632.39, -1471.09, 286.6, 0 },
			[9] = { 2634.3, -1471.09, 286.6, 0 },
			[10] = { 2635, -1472.8, 286.6, 0 },
		},
	},
	
	-- name, interior, dimension, positions
}

-- DEV COMMANDS

local markers = {}
addCommandHandler("paintballmarkers", function(thePlayer)
	if exports.integration:isPlayerScripter(thePlayer) then
		local show = (not markers[1] and true) or false
		
		if show then
			for i = 1, #arenas do
				for index, value in ipairs(arenas[i].positions) do
					markers[index] = createMarker(value[1], value[2], value[3], "checkpoint", 1)
					setElementInterior(markers[index], arenas[i][2])
					setElementDimension(markers[index], arenas[i][3])
				end
			end
		else
			for index, marker in ipairs(markers) do
				if isElement(marker) then
					destroyElement(marker)
				end
			end
			markers = {}
		end
		outputChatBox(" [PAINTBALL] You have toggled the paintball markers " .. (show and "on" or "off") .. ".", thePlayer, 255, 0, 0)
	end
end)

addCommandHandler("resetleaderboard", function(thePlayer)
	if exports.integration:isPlayerScripter(thePlayer) or exports.integration:isPlayerLeadAdmin(thePlayer) then
		if getElementData(thePlayer, "paintball:reset") then
			setElementData(thePlayer, "paintball:reset", false)
			leaderboard = {}
			-- inform
			outputChatBox("You have successfully reset the paintball leaderboard.", thePlayer, 255, 0, 0)
		else
			outputChatBox("Are you sure you would like to reset the leaderboard? This cannot be undone. Type /resetleaderboard to continue.", thePlayer, 255, 0, 0)
			setElementData(thePlayer, "paintball:reset", true)
		end
	end
end)

addCommandHandler("resetlobby", function(thePlayer, command, lobby)
	if exports.integration:isPlayerScripter(thePlayer) or exports.integration:isPlayerLeadAdmin(thePlayer) then
		if not lobby or not tonumber(lobby) then
			outputChatBox("Syntax: /" .. command .. " [Lobby ID]", thePlayer)
		else
			lobby = tonumber(lobby)
			local rTeam1, rTeam2 = getRandomTeams()
			matches[lobby] = { players = {}, teams = { rTeam1, rTeam2 }, state = 0 }
			outputChatBox("You have successfully reset paintball lobby #" .. lobby .. ".", thePlayer, 0, 255, 0)
		end
	end
end)

addEvent("event:getPaintballGUI", true)
addEventHandler("event:getPaintballGUI", getRootElement(), function(interact)
	local pedInfo = exports.global:explode(":", interact)
	local lobby = tonumber(pedInfo[2])
	if not lobby then
		outputChatBox("This paintball lobby has been improperly configured. You can report this using the F1 menu.", source, 255, 0, 0)
		return false
	end
	if #matches[lobby].players < MATCH_PLAYERS and matches[lobby].state == 0 then
		if not exports.global:takeMoney(source, 50) then
			return outputChatBox("You require $50 to participate in paintball.", source, 255, 0, 0)
		end
		MONEY = MONEY + 50
		
		local team1, team2 = 1, 0, 0
		for _, player in ipairs(matches[lobby].players) do
			if player[2] == 1 then
				team1 = team1 + 1
			else
				team2 = team2 + 1
			end
		end
		table.insert(matches[lobby].players, { source, (team1 > team2 and 2) or 1, false })
		for _, player in ipairs(matches[lobby].players) do
			triggerClientEvent(player[1], "event:addPlayerLobby", player[1], source, (team1 > team2 and 2) or 1)
		end
		triggerClientEvent(source, "event:showPaintballGUI", source, matches[lobby], lobby, teams, paintballguns)
		--outputDebugString("Player " .. getPlayerName(source) .. " has joined lobby #" .. lobby)
		setElementData(source, "paintball", 1)
		setElementData(source, "paintball:hp", 100)
		setElementData(source, "paintball:team", (team1 > team2 and 2) or 1)
		setElementData(source, "paintball:lobby", lobby)
		-- save players current position & clothes
		local x, y, z = getElementPosition(source)
		local int, dim = getElementInterior(source), getElementDimension(source)
		setElementData(source, "paintball:position", { x, y, z + 0.1, int, dim })
		setElementData(source, "paintball:skin", { getElementModel(source), getElementData(source, "clothing:id") })
	else
		outputChatBox(" Sorry this lobby is currently full or in progress! Try again later.", source, 255, 0, 0)
	end
end)

addEvent("event:exitPlayerLobby", true)
addEventHandler("event:exitPlayerLobby", getRootElement(), function(lobby)
	local team = 0
	for index, value in ipairs(matches[lobby].players) do
		if value[1] == source then
			table.remove(matches[lobby].players, index)
			team = value[2]
			--outputDebugString("Player " .. getPlayerName(source) .. " has left lobby #" .. lobby)
			break
		end
	end
	for index, value in ipairs(matches[lobby].players) do
		triggerClientEvent(value[1], "event:removePlayerLobby", value[1], source, team)
	end
	setElementData(source, "paintball", 0)
end)

addEventHandler("onPlayerQuit", getRootElement(), function()
	if getElementData(source, "paintball") then
		handleDeath(source, source)
		triggerEvent("event:exitPlayerLobby", source, getElementData(source, "paintball:lobby"))
	end
end)

addEvent("event:readyPlayer", true)
addEventHandler("event:readyPlayer", getRootElement(), function(lobby)
	for index, value in ipairs(matches[lobby].players) do
		if value[1] == source then
			matches[lobby].players[index][3] = true
		end
		local team = 0
		for _, player in ipairs(matches[lobby].players) do
			if player[1] == source then
				team = player[2]
				break
			end
		end
		
		-- is everyone ready?
		local allReady = true
		for i, v in ipairs(matches[lobby].players) do
			if not v[3] then
				allReady = false
				break
			end
		end
		
		allReady = (#matches[lobby].players >= 4 and allReady) or false
		
		for i, v in ipairs(matches[lobby].players) do
			triggerClientEvent(v[1], "event:readyPlayerClient", v[1], source, allReady)
		end
		
		if allReady then
			matches[lobby].state = 1 -- in progress
			-- Allow 7 seconds for the clientside counter & fade them out.
			setTimer(function()
				local counter1, counter2 = 0, 5
				local x, y, z, rz = 0, 0, 0, 0
				for index, value in ipairs(matches[lobby].players) do
					-- Handle positioning
					if value[2] == 1 then
						counter1 = counter1 + 1
						x, y, z, rz = arenas[lobby].positions[counter1][1], arenas[lobby].positions[counter1][2], arenas[lobby].positions[counter1][3], arenas[lobby].positions[counter1][4]
					else
						counter2 = counter2 + 1
						x, y, z, rz = arenas[lobby].positions[counter2][1], arenas[lobby].positions[counter2][2], arenas[lobby].positions[counter2][3], arenas[lobby].positions[counter2][4]
					end
					setElementPosition(value[1], x, y, z)
					setElementRotation(value[1], 0, 0, rz, "default", true)
					setElementInterior(value[1], arenas[lobby][2])
					setElementDimension(value[1], arenas[lobby][3])
					setElementData(value[1], "paintball", 2)
					fadeCamera(value[1], true, 3)
				end
			end, 7000, 1)
		end
	end
	--outputDebugString("Player " .. getPlayerName(source) .. " is ready in lobby #" .. lobby)
end)

addEvent("event:handlePaintballGuns", true)
addEventHandler("event:handlePaintballGuns", getRootElement(), function(loadout)
	-- Handle weapons
	takeAllWeapons(source)
	giveWeapon(source, loadout.primary, (exports.weapon:getAmmoPerClip(loadout.primary) * PRIMARY_MAGS) + 1)
	giveWeapon(source, loadout.secondary, (exports.weapon:getAmmoPerClip(loadout.secondary) * SECONDARY_MAGS) + 1)
	setElementModel(source, loadout.clothes)
	exports.anticheat:setEld(source, "clothing:id", 0, 'all')
end)

addEvent("event:onPlayerDamage", true)
addEventHandler("event:onPlayerDamage", getRootElement(), function(attacker, weapon, bodypart, loss)
	if getElementData(source, "paintball") == 2 and getElementData(source, "paintball:hp") > 0 and weapon then
		if getElementData(source, "paintball:team") == getElementData(attacker, "paintball:team") and attacker ~= source then 
			outputChatBox("Friendly fire is not allowed!", attacker, 255, 0, 0)
			return false
		end
		
		loss = (getPaintballDamage(weapon, attacker, source) or loss)
		if (getElementData(source, "paintball:hp") - loss) > 0 then
			setElementData(source, "paintball:hp", getElementData(source, "paintball:hp") - loss)
		else -- player out
			setElementData(source, "paintball:hp", 0)
			local localTeam = getElementData(source, "paintball:team")
			setElementFrozen(source, true)
			exports.global:applyAnimation(source, "ped", "floor_hit", -1, false, false, false)
			outputDebugString("[PAINTBALL] handleDeath - source: " .. getPlayerName(source) .. ", attacker: " .. getPlayerName(attacker))
			handleDeath(source, attacker)
		end
	end
end)

function handleDeath(victim, attacker)
	local lobby, team = getElementData(victim, "paintball:lobby"), getElementData(victim, "paintball:team")
	local r, g, b = teams[matches[lobby].teams[team]][2], teams[matches[lobby].teams[team]][3], teams[matches[lobby].teams[team]][4]
	local teamOne, teamTwo = false, false
	takeAllWeapons(victim)
	for index, player in ipairs(matches[lobby].players) do
		if getElementData(player[1], "paintball:hp") > 0 then
			if getElementData(player[1], "paintball:team") == 1 then
				teamOne = true
			else
				teamTwo = true
			end
		end
		outputChatBox(" [PAINTBALL] " .. getPlayerName(victim):gsub("_", " ") .. " has been defeated by " .. (getPlayerName(attacker) or "Unknown"):gsub("_", " ") .. "!", player[1], r, g, b)
	end
	
	-- update leaderboard
	if attacker then
		if not leaderboard[getElementData(attacker, "account:id")] then
			leaderboard[getElementData(attacker, "account:id")] = { 1, 0 }
		else
			leaderboard[getElementData(attacker, "account:id")][1] = leaderboard[getElementData(attacker, "account:id")][1] + 1
		end
	end
	
	if not teamOne or not teamTwo then
		for index, player in ipairs(matches[lobby].players) do
			fadeCamera(player[1], false, 2)
			setElementFrozen(player[1], false) 
			setTimer(function()
				setElementData(player[1], "paintball", 0)
				setElementData(player[1], "paintball:hp", 0)
				setElementData(player[1], "paintball:team", 0)
				setElementData(player[1], "paintball:lobby", 0)
				local x, y, z, int, dim = unpack(getElementData(player[1], "paintball:position"))
				local model, dupontID = unpack(getElementData(player[1], "paintball:skin"))
				setElementPosition(player[1], x, y, z)
				setElementInterior(player[1], int)
				setElementDimension(player[1], dim)
				setElementModel(player[1], model)
				exports.anticheat:setEld(player[1], "clothing:id", dupontID, 'all')
				setElementCollisionsEnabled(player[1], false) -- temporarily disable collisions
				setTimer(setElementCollisionsEnabled, 10000, 1, player[1], true)
				exports.global:removeAnimation(player[1])
				takeAllWeapons(player[1])
				triggerEvent("updateLocalGuns", player[1])
				fadeCamera(player[1], true, 2)
				outputChatBox("Thanks for playing. You can leave some feedback by speaking to one of the peds by the door.", player[1], 0, 220, 0)
			end, 3500, 1)
			
			-- did they win? then update leaderboard
			if (teamOne and getElementData(player[1], "paintball:team") == 1) or (teamTwo and getElementData(player[1], "paintball:team") == 2) then
				if not leaderboard[getElementData(player[1], "account:id")] then
					leaderboard[getElementData(player[1], "account:id")] = { 0, 1 }
				else
					leaderboard[getElementData(player[1], "account:id")][2] = leaderboard[getElementData(player[1], "account:id")][2] + 1
				end
			end
		end
		-- reset the lobby
		local rTeam1, rTeam2 = getRandomTeams()
		matches[getElementData(victim, "paintball:lobby")] = { players = {}, teams = { rTeam1, rTeam2 }, state = 0 }
	end
end

-- LEADERBOARD

addEventHandler("onResourceStop", getResourceRootElement(getThisResource()), function()
	exports.data:save(leaderboard, "event:leaderboard")
	exports.data:save(MONEY, "event:money")
end)

addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), function()
	local data_leaderboard = exports.data:load("event:leaderboard")
	leaderboard = data_leaderboard or {}
	local data_money = exports.data:load("event:money")
	MONEY = data_money or 0
end)

addEvent("event:getLeaderboardGUI", true)
addEventHandler("event:getLeaderboardGUI", getRootElement(), function()
	local temp_leaderboard = leaderboard
	local pass_leaderboard = {}
	
	for id, value in pairs(temp_leaderboard) do
		table.insert(pass_leaderboard, { value[1], value[2], exports.cache:getUsernameFromId(id) })
	end
	
	table.sort(pass_leaderboard, function(a, b) return a[1] > b[1] end)
	triggerClientEvent(source, "event:showLeaderboardGUI", source, pass_leaderboard, MONEY)
end)

-- FEEDBACK

addEvent("event:getFeedbackGUI", true)
addEventHandler("event:getFeedbackGUI", getRootElement(), function()
	local feedback = {}
	local alreadySubmitted = false
	local file = xmlLoadFile("paintball/feedback.xml")
	local children = xmlNodeGetChildren(file)
	
	for _, entry in pairs(children) do
		local nodes = xmlNodeGetChildren(entry)
		table.insert(feedback, { xmlNodeGetValue(nodes[1]), xmlNodeGetValue(nodes[2]), xmlNodeGetValue(nodes[3]) })
		
		if xmlNodeGetValue(nodes[1]) == getElementData(source, "account:username") then
			alreadySubmitted = true
		end
	end
	
	xmlUnloadFile(file)
	triggerClientEvent(source, "event:showFeedbackGUI", source, feedback, alreadySubmitted)
end)

addEvent("event:saveFeedback", true)
addEventHandler("event:saveFeedback", getRootElement(), function(user, feedback_future, feedback_event)
	local file = xmlLoadFile("paintball/feedback.xml")
	if file then
		local entry = xmlCreateChild(file, "entry")
		
		local user_node = xmlCreateChild(entry, "info")
		xmlNodeSetValue(user_node, user)
		local future_node = xmlCreateChild(entry, "info")
		xmlNodeSetValue(future_node, feedback_future)
		local event_node = xmlCreateChild(entry, "info")
		xmlNodeSetValue(event_node, feedback_event)
		
		xmlSaveFile(file)
		outputChatBox(" Thank you for submitting feedback.", source, 0, 255, 0)
	else
		outputChatBox(" Failed to submit feedback: error loading file.", source, 255, 0, 0)
	end
end)



