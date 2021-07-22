mysql = exports.mysql

MTAoutputChatBox = outputChatBox
function outputChatBox( text, visibleTo, r, g, b, colorCoded )
	if string.len(text) > 128 then -- MTA Chatbox size limit
		MTAoutputChatBox( string.sub(text, 1, 127), visibleTo, r, g, b, colorCoded  )
		outputChatBox( string.sub(text, 128), visibleTo, r, g, b, colorCoded  )
	else
		MTAoutputChatBox( text, visibleTo, r, g, b, colorCoded  )
	end
end

function trunklateText(thePlayer, text, factor)
	--[[if getElementData(thePlayer,"alcohollevel") and getElementData(thePlayer,"alcohollevel") > 0 then
		local level = math.ceil( getElementData(thePlayer,"alcohollevel") * #text / ( factor or 15 ) )
		for i = 1, level do
			x = math.random( 1, #text )
			-- dont replace spaces
			if text.sub( x, x ) == ' ' then
				i = i - 1
			else
				local a, b = text:sub( 1, x - 1 ) or "", text:sub( x + 1 ) or ""
				local c = ""
				if math.random( 1, 6 ) == 1 then
					c = string.char(math.random(65,90))
				else
					c = string.char(math.random(97,122))
				end
				text = a .. c .. b
			end
		end
	end]]
	return (tostring(text):gsub("^%l", string.upper))
end

function getElementDistance( a, b )
	if not isElement(a) or not isElement(b) or getElementDimension(a) ~= getElementDimension(b) then
		return math.huge
	else
		local x, y, z = getElementPosition( a )
		return getDistanceBetweenPoints3D( x, y, z, getElementPosition( b ) )
	end
end

local factionsThatCanUseDepartmentRadio = { 1, 2, 3, 4, 20, 47, 50, 69, 81, 134, 142, 164 }
local factionsThatCanUseMedicalRadio = { 2, 164 }

-- support functions for writing in different languages without switching to them.
function getCurrentLanguage(player, command)
	-- by default we use the player's current language slot.
	local languageslot = getElementData(player, "languages.current") or 1

	-- unless the command explicitly asks for us to use another language slot
	-- for example, /s1 is equal to shouting with your first language
	if type(command) == 'string' and #command >= 2 then
		languageslot = tonumber(command:sub(#command, #command)) or languageslot
	end

	local language = getElementData(player, "languages.lang" .. languageslot) or 0
	local languagename = call(getResourceFromName("language-system"), "getLanguageName", language)
	return language, languagename
end

-- command handler with support for different language slots.
function addLocalizedCommandHandler(command, ...)
	addCommandHandler(command, ...)
	for i = 1, 3 do
		addCommandHandler(command .. i, ...)
	end
end

-- Main chat: Local IC, Me Actions & Faction IC Radio
function localIC(source, message, language)
	if exports['freecam-tv']:isPlayerFreecamEnabled(source) then return end
	local affectedElements = { }
	table.insert(affectedElements, source)
	local x, y, z = getElementPosition(source)
	local playerName = getPlayerName(source)

	message = string.gsub(message, "#%x%x%x%x%x%x", "") -- Remove colour codes
	local languagename = call(getResourceFromName("language-system"), "getLanguageName", language)
	message = trunklateText( source, message )

	local color = {0xEE,0xEE,0xEE}

	local focus = getElementData(source, "focus")
	local focusColor = false
	if type(focus) == "table" then
		for player, color2 in pairs(focus) do
			if player == source then
				color = color2
			end
		end
	end
	local playerVehicle = getPedOccupiedVehicle(source)
	if playerVehicle then
		if (exports.vehicle:isVehicleWindowUp(playerVehicle)) then
			table.insert(affectedElements, playerVehicle)
			outputChatBox( " [" .. languagename .. "] " .. playerName .. " ((In Car)) says: " .. message, source, unpack(color))
		else
			outputChatBox( " [" .. languagename .. "] " .. playerName .. " says: " .. message, source, unpack(color))
		end
	else
		if getElementData(source, "talk_anim") == "1" then
			exports.global:applyAnimation(source, "GANGS", "prtial_gngtlkA", 1, false, true, false)
		end
		outputChatBox( " [" .. languagename .. "] " .. playerName .. " says: " .. message, source, unpack(color))
		triggerClientEvent(source, "addChatBubble", source, message, "say")
	end

	local dimension = getElementDimension(source)
	local interior = getElementInterior(source)

	if dimension ~= 0 then
		table.insert(affectedElements, "in"..tostring(dimension))
	end


	for key, nearbyPlayer in ipairs(getElementsByType( "player" )) do
		local dist = getElementDistance( source, nearbyPlayer )

		if dist < 20 then
			local nearbyPlayerDimension = getElementDimension(nearbyPlayer)
			local nearbyPlayerInterior = getElementInterior(nearbyPlayer)

			if (nearbyPlayerDimension==dimension) and (nearbyPlayerInterior==interior) then
				local logged = tonumber(getElementData(nearbyPlayer, "loggedin"))
				if not (isPedDead(nearbyPlayer)) and (logged==1) and (nearbyPlayer~=source) then
					local pveh = getPedOccupiedVehicle(source)
					local nbpveh = getPedOccupiedVehicle(nearbyPlayer)
					local color = {0xEE,0xEE,0xEE}

					local focus = getElementData(nearbyPlayer, "focus")
					local focusColor = false
					if type(focus) == "table" then
						for player, color2 in pairs(focus) do
							if player == source then
								focusColor = true
								color = color2
							end
						end
					end

					if pveh then
						if (exports.vehicle:isVehicleWindowUp(pveh)) then
							for i = 0, getVehicleMaxPassengers(pveh) do
								local lp = getVehicleOccupant(pveh, i)

								if (lp) and (lp~=source) then
									local message2 = call(getResourceFromName("language-system"), "applyLanguage", source, lp, message, language)
									local message2 = trunklateText( lp, message2 )

									outputChatBox(" [" .. languagename .. "] " .. playerName .. " ((In Car)) says: " .. message2, lp, unpack(color))
									table.insert(affectedElements, lp)
								end
							end
							table.insert(affectedElements, pveh)
							exports.logs:dbLog(source, 7, affectedElements, languagename..": INCAR ".. message)
							exports['freecam-tv']:add(affectedElements)
							return
						end
					end

					if nbpveh and exports.vehicle:isVehicleWindowUp(nbpveh) == true then
						--[[if not focusColor then
							if dist < 3 then
							elseif dist < 6 then
								color = {0xDD,0xDD,0xDD}
							elseif dist < 9 then
								color = {0xCC,0xCC,0xCC}
							elseif dist < 12 then
								color = {0xBB,0xBB,0xBB}
							else
								color = {0xAA,0xAA,0xAA}
							end
						end
						-- for players in vehicle
						outputChatBox(" [" .. languagename .. "] " .. playerName .. " says: " .. message2, nearbyPlayer, unpack(color))]]
						--table.insert(affectedElements, nearbyPlayer)
					else
						if not focusColor then
							if dist < 4 then
							elseif dist < 8 then
								color = {0xDD,0xDD,0xDD}
							elseif dist < 12 then
								color = {0xCC,0xCC,0xCC}
							elseif dist < 16 then
								color = {0xBB,0xBB,0xBB}
							else
								color = {0xAA,0xAA,0xAA}
							end
						end
						local message2 = call(getResourceFromName("language-system"), "applyLanguage", source, nearbyPlayer, message, language)
						local message2 = trunklateText( nearbyPlayer, message2 )

						outputChatBox(" [" .. languagename .. "] " .. playerName .. " says: " .. message2, nearbyPlayer, unpack(color))
						triggerClientEvent(nearbyPlayer, "addChatBubble", source, message2, "say")
						table.insert(affectedElements, nearbyPlayer)
					end
				end
			end
		end
	end
	if getElementType(source) ~= "ped" then
		exports.logs:dbLog(source, 7, affectedElements, languagename..": ".. message)
	end
	exports['freecam-tv']:add(affectedElements)
end

for i = 1, 3 do
	addCommandHandler( tostring( i ),
		function( thePlayer, commandName, ... )
			local lang = tonumber( getElementData( thePlayer, "languages.lang" .. i ) )
			if lang ~= 0 then
				localIC( thePlayer, table.concat({...}, " "), lang )
			end
		end
	)
end

function meEmote(source, cmd, ...)
	local logged = getElementData(source, "loggedin")
	if logged == 1 then
		local message = table.concat({...}, " ")
		if not (...) then
			outputChatBox("SYNTAX: /me [Action]", source, 255, 194, 14)
		else
			local result, affectedPlayers = exports.global:sendLocalMeAction(source, message, true, true)
			local dimension = getElementDimension(source)

			if dimension ~= 0 then
				table.insert(affectedPlayers, "in"..tostring(dimension))
			end
			exports.logs:dbLog(source, 12, affectedPlayers, message)
		end
	end
end
addCommandHandler("ME", meEmote, false, true)
addCommandHandler("Me", meEmote, false, true)

function outputChatBoxCar( vehicle, target, text1, text2, color )
	if vehicle and exports.vehicle:isVehicleWindowUp( vehicle ) then
		if getPedOccupiedVehicle( target ) == vehicle then
			outputChatBox( text1 .. " ((In Car))" .. text2, target, unpack(color))
			return true
		else
			return false
		end
	end
	outputChatBox( text1 .. text2, target, unpack(color))
	return true
end

--speaker zones
zoneDragstrip = createColSphere(225, 2496, 16, 355)

function radio(source, radioID, message, cmd)
	local jailed = getElementData(source, "jailed") or 0
	if jailed > 0 then
		outputChatBox('You cannot use a radio in jail.', source, 255, 0, 0)
		return
	end

	local customSound = false
	local affectedElements = { }
	local found = {}
	local indirectlyAffectedElements = { }
	table.insert(affectedElements, source)
	radioID = tonumber(radioID) or 1
	
	if isPedDead(source) then
		outputChatBox(" You cannot use your radio when dead.", source, 255, 0, 0)
		return
	end
	
	local hasRadio, itemKey, itemValue, itemID = exports.global:hasItem(source, 6)
	if hasRadio or getElementType(source) == "ped" or radioID == -2 then
		local theChannel = itemValue
		if getElementType(source) == "ped" then itemValue = 1 end

		if radioID < 0 then
			theChannel = radioID
		elseif radioID == 1 and exports.integration:isPlayerTrialAdmin(source) and tonumber(message) and tonumber(message) >= 1 and tonumber(message) <= 10 then
			return
		elseif radioID ~= 1 then
			local count = 0
			local items = exports['item-system']:getItems(source)
			for k, v in ipairs(items) do
				if v[1] == 6 then
					count = count + 1
					if count == radioID then
						theChannel = v[2]
						break
					end
				end
			end
		end

		if theChannel == 1 or theChannel == 0 then
			outputChatBox("Please Tune your radio first with /tuneradio [channel]", source, 255, 194, 14)
		elseif not hasChannelAccess(source, theChannel) then
			outputChatBox("You are not allowed to access this channel. Please retune your radio.", source, 255, 194, 14)
		elseif (theChannel > 1 or radioID < 0) and itemValue > 0 then
			--triggerClientEvent (source, "playRadioSound", getRootElement())
			local username = getPlayerName(source)
			local languageslot = getElementData(source, "languages.current") or 1
			local language = getElementData(source, "languages.lang" .. languageslot)
			local languagename = call(getResourceFromName("language-system"), "getLanguageName", language)
			local channelName = "#" .. theChannel

			message = trunklateText( source, message )
			local r, g, b = 0, 102, 255
			local focus = getElementData(source, "focus")
			if type(focus) == "table" then
				for player, color in pairs(focus) do
					if player == source then
						r, g, b = unpack(color)
					end
				end
			end

			if radioID == -1 then
				for _, factionID in ipairs(factionsThatCanUseDepartmentRadio) do
					for key, value in ipairs(exports.factions:getPlayersInFaction(factionID) or {}) do
						if not found[value] then
							for _, itemRow in ipairs(exports['item-system']:getItems(value)) do
								--outputDebugString(tostring(itemRow[1]).." - "..tostring(itemRow[2]))
								if tonumber(itemRow[1]) and tonumber(itemRow[2]) and tonumber(itemRow[1]) == 6 and tonumber(itemRow[2]) > 0 and not found[value] then
									table.insert(affectedElements, value)
									found[value] = true
									break
								end
							end
						end
					end
				end
				r, g, b = 0,162,255
				channelName = "DEPARTMENT"
			elseif radioID == -2 then
				local a = {}
				for key, value in ipairs(exports.sfia:getPlayersInAircraft( )) do
					table.insert(affectedElements, value)
					a[value] = true
				end

				local canOverseeAirRadio = {}
				for key, value in ipairs(exports.factions:getPlayersInFaction(47) ) do
					table.insert(canOverseeAirRadio, value)
				end
				--[[
				for key, value in ipairs( getPlayersInTeam( getTeamFromName( "San Andreas Air National Guard" ) ) ) do
					table.insert(canOverseeAirRadio, value)
				end
				--]]
				for key, value in ipairs(canOverseeAirRadio) do
					if not a[value] then
						for _, itemRow in ipairs(exports['item-system']:getItems(value)) do
							if (itemRow[1] == 6 and itemRow[2] > 0) then
								table.insert(affectedElements, value)
								break
							end
						end
					end
				end
				r, g, b = 0,132,255
				channelName = "AIR"
				customSound = "atc.mp3"
			elseif radioID == -3 then --PA (speakers) in vehicles and interiors // Exciter
				local outputDim = getElementDimension(source)
				local vehicle
				if isPedInVehicle(source) then
					vehicle = getPedOccupiedVehicle(source)
					outputDim = tonumber(getElementData(vehicle, "dbid")) + 20000
				end
				if(outputDim > 0) then
					local canUsePA = false
					if(outputDim > 20000) then --vehicle interior
						local dbid = outputDim - 20000
						if not vehicle then
							for k,v in ipairs(exports.pool:getPoolElementsByType("vehicle")) do
								if getElementData( v, "dbid" ) == dbid then
									vehicle = v
									break
								end
							end
						end
						if vehicle then
							canUsePA = getElementData(source, "adminduty") == 1 or getPedOccupiedVehicleSeat(source) == 0 or getPedOccupiedVehicleSeat(source) == 1 or exports.factions:isPlayerInFaction(source, getElementData(vehicle, "faction"))
						end
					else
						canUsePA = getElementData(source, "adminduty") == 1 or exports.global:hasItem(source, 4, outputDim) or exports.global:hasItem(source, 5,outputDim)
					end
					--outputDebugString("canUsePA="..tostring(canUsePA))
					if not canUsePA then
						return false
					end

					local outputInt = getElementInterior(source)
					for key, value in ipairs(exports.pool:getPoolElementsByType("player")) do
						if(getElementDimension(value) == outputDim) then
							if(getElementInterior(value) == outputInt or vehicle) then
								table.insert(affectedElements, value)
							end
						end
					end
					if vehicle then
						for i = 0, getVehicleMaxPassengers( vehicle ) do
							local player = getVehicleOccupant( vehicle, i )
							if player then
								table.insert(affectedElements, player)
							end
						end
					end
					r, g, b = 0,149,255
					channelName = "SPEAKERS"
					customSound = "pa.mp3"
				else
					--Check exterior speaker zones
					if(getElementDimension(source) == 0 and getElementInterior(source) == 0) then
						if isElementWithinColShape(source, zoneDragstrip) then --Desert drag strip
							if exports.factions:hasMemberPermissionTo(source, 130, "add_member") then --if player is leader in SACMA
								for key, value in ipairs(getElementsWithinColShape(zoneDragstrip, "player")) do
									if(getElementDimension(value) == 0 and getElementInterior(value) == 0) then
										table.insert(affectedElements, value)
									end
								end
								r, g, b = 0,149,255
								channelName = "SPEAKERS"
								customSound = "pa.mp3"
							else
								return false
							end
						else
							return false
						end
					else
						return false
					end
				end
			elseif radioID == -4 then --PA (speakers) at airports // Exciter
				local x,y,z = getElementPosition(source)
				local zonename = getZoneName(x,y,z,false)
				local outputDim = getElementDimension(source)
				local allowedFactions = {
					47, --FAA
				}
				local allowedAirports = {
					["Easter Bay Airport"]=true,
					["Los Santos International"]=true,
					["Las Venturas Airport"]=true
				}
				allowedAirportDimensions = {
					[1317]=true, --LSA terminal
					[2337]=true, --LSA deaprture hall
					[2340]=true, --LSA terminal 2
					[2361]=true, --toilets male
					[2362]=true, --toilets female
					[2370]=true, --restaurant
					[2371]=true, --chuckin bell
					[2372]=true, --tax free
					[2373]=true, --jetbridge C
					[2376]=true, --jetbridge D
					[2379]=true, --jetbridge E
					[2382]=true, --jetbridge F
					[2386]=true, --jetbridge G
				}
				airportDimensionsSF = {}
				airportDimensionsLS = {
					[1317]=true, --terminal
					[2337]=true, --deaprture hall
					[2340]=true, --terminal 2
					[2361]=true, --toilets male
					[2362]=true, --toilets female
					[2370]=true, --restaurant
					[2371]=true, --chuckin bell
					[2372]=true, --tax free
					[2373]=true, --jetbridge C
					[2376]=true, --jetbridge D
					[2379]=true, --jetbridge E
					[2382]=true, --jetbridge F
					[2386]=true, --jetbridge G
				}
				airportDimensionsLV = {}
				local airportDimensions = {}
				local targetAirport = zonename
				if(zonename == "Easter Bay Airport" or airportDimensionsSF[outputDim]) then
					airportDimensions = airportDimensionsSF
				elseif(zonename == "Los Santos International" or airportDimensionsLS[outputDim]) then
					airportDimensions = airportDimensionsLS
				elseif(zonename == "Las Venturas Airport" or airportDimensionsLV[outputDim]) then
					airportDimensions = airportDimensionsLV
				end

				local inAllowedFaction = false
				for k,v in ipairs(allowedFactions) do
					if exports.factions:isPlayerInFaction(source, v) then
						inAllowedFaction = true
					end
				end

				if(inAllowedFaction) then
					if(allowedAirportDimensions[outputDim] or outputDim == 0 and allowedAirports[zonename]) then
						for key, value in ipairs(getElementsByType("player")) do
							x,y,z = getElementPosition(value)
							zonename = getZoneName(x,y,z,false)
							local dim = getElementDimension(value)
							if(airportDimensions[dim] or dim == 0 and zonename == targetAirport) then
								table.insert(affectedElements, value)
							end
						end
						r, g, b = 0,149,255
						channelName = "AIRPORT SPEAKERS"
						customSound = "pa.mp3"
					else
						return false
					end
				else
					return false
				end
			elseif radioID == -5 then --PA (speakers) at hospital // Exciter
				local isPed = getElementType(source) == "ped"
				local outputInt = getElementInterior(source)
				local outputDim = getElementDimension(source)
				local allowedFactions = {
					164, --Hospital
				}
				hospitalInteriors = {
					[2352]=true,
					[2353]=true,
					[2354]=true,
					[2355]=true,
					[2356]=true,
					[2359]=true,
					[2374]=true,
					[2378]=true,
					[2384]=true,
					[2407]=true,
				}

				local inAllowedFaction = false
				if isPed then
					inAllowedFaction = true
				else
					for k,v in ipairs(allowedFactions) do
						if exports.factions:isPlayerInFaction(source, v) then
							inAllowedFaction = true
						end
					end
				end

				if(inAllowedFaction) then
					if(outputInt > 0 and hospitalInteriors[outputDim]) then
						for key, value in ipairs(getElementsByType("player")) do
							local int = getElementInterior(value)
							local dim = getElementDimension(value)
							if(int > 0 and hospitalInteriors[dim]) then
								table.insert(affectedElements, value)
							end
						end
						r, g, b = 0,149,255
						channelName = "SPEAKERS"
						customSound = "pa.mp3"
					else
						return false
					end
				else
					return false
				end
			elseif radioID == -6 then
				for _, factionID in ipairs(factionsThatCanUseMedicalRadio) do
					for key, value in ipairs(exports.factions:getPlayersInFaction(factionID) or {}) do
						if not found[value] then
							for _, itemRow in ipairs(exports['item-system']:getItems(value)) do
								--outputDebugString(tostring(itemRow[1]).." - "..tostring(itemRow[2]))
								if tonumber(itemRow[1]) and tonumber(itemRow[2]) and tonumber(itemRow[1]) == 6 and tonumber(itemRow[2]) > 0 and not found[value] then
									table.insert(affectedElements, value)
									found[value] = true
									break
								end
							end
						end
					end
				end
				r, g, b = 60,179,113
				channelName = "COUNTY MED"
			else
				for key, value in ipairs(getElementsByType( "player" )) do
					if exports.global:hasItem(value, 6, theChannel) and hasChannelAccess(value, theChannel) then
						table.insert(affectedElements, value)
					end
				end
			end

			if channelName == "COUNTY MED" then
				outputChatBoxCar(getPedOccupiedVehicle( source ), source, "[" .. languagename .. "] [" .. channelName .. "] " .. username, " says: " .. message, {60,179,113})
			elseif channelName == "DEPARTMENT" then
				outputChatBoxCar(getPedOccupiedVehicle( source ), source, "[" .. languagename .. "] [" .. channelName .. "] " .. username, " says: " .. message, {r,162,b})
			else
				if cmd == "rlow" then
					outputChatBoxCar(getPedOccupiedVehicle( source ), source, "[" .. languagename .. "] [" .. channelName .. "] " .. username, " whispers: " .. message, {r,g,b})
					triggerEvent("sendAme", source, "whispers into their radio.")
				else
					outputChatBoxCar(getPedOccupiedVehicle( source ), source, "[" .. languagename .. "] [" .. channelName .. "] " .. username, " says: " .. message, {r,g,b})
				end
			end

			for i = #affectedElements, 1, -1 do
				if getElementData(affectedElements[i], "loggedin") ~= 1 then
					table.remove( affectedElements, i )
				end
			end

			for key, value in ipairs(affectedElements) do
				if customSound then
					triggerClientEvent(value, "playCustomChatSound", getRootElement(), customSound)
				else
					triggerClientEvent (value, "playRadioSound", getRootElement())
				end
				if value ~= source then
					local message2 = call(getResourceFromName("language-system"), "applyLanguage", source, value, message, language)
					local r, g, b = 0, 102, 255
					local focus = getElementData(value, "focus")
					if type(focus) == "table" then
						for player, color in pairs(focus) do
							if player == source then
								r, g, b = unpack(color)
							end
						end
					end
					if channelName == "COUNTY MED" then
						outputChatBoxCar( getPedOccupiedVehicle( value ), value, "[" .. languagename .. "] [" .. channelName .. "] " .. username, " says: " .. trunklateText( value, message2 ), {60,179,113} )
					elseif channelName == "DEPARTMENT" then
						outputChatBoxCar( getPedOccupiedVehicle( value ), value, "[" .. languagename .. "] [" .. channelName .. "] " .. username, " says: " .. trunklateText( value, message2 ), {r,162,b} )
					else
						outputChatBoxCar( getPedOccupiedVehicle( value ), value, "[" .. languagename .. "] [" .. channelName .. "] " .. username, " says: " .. trunklateText( value, message2 ), {r,g,b} )
					end

					--if not exports.global:hasItem(value, 88) == false then  ***Earpiece Fix***
					if exports.global:hasItem(value, 88) == false then
						-- Show it to people near who can hear his radio
						for k, v in ipairs(exports.global:getNearbyElements(value, "player",7)) do
							local logged2 = getElementData(v, "loggedin")
							if (logged2==1) then
								local found = false
								for kx, vx in ipairs(affectedElements) do
									if v == vx then
										found = true
										break
									end
								end

								if not found then
									local message2 = call(getResourceFromName("language-system"), "applyLanguage", source, v, message, language)
									local text1 = "[" .. languagename .. "] " .. getPlayerName(value) .. "'s Radio"
									local text2 = ": " .. trunklateText( v, message2 )

									if outputChatBoxCar( getPedOccupiedVehicle( value ), v, text1, text2, {255, 255, 255} ) then
										table.insert(indirectlyAffectedElements, v)
									end
								end
							end
						end
					end
				end
			end
			--
			--Show the radio to nearby listening in people near the speaker
			for key, value in ipairs(getElementsByType("player")) do
				if cmd == "rlow" and getElementDistance(source, value) < 3 or getElementDistance(source, value) < 10 then
					if (value~=source) then
						local message2 = call(getResourceFromName("language-system"), "applyLanguage", source, value, message, language)
						local text1 = "[" .. languagename .. "] " .. getPlayerName(source) .. " [RADIO]"
						if cmd == "rlow" then
							text2 = " whispers: " .. trunklateText( value, message2 )
						else
							text2 = " says: " .. trunklateText( value, message2 )
						end

						if outputChatBoxCar( getPedOccupiedVehicle( source ), value, text1, text2, {255, 255, 255} ) then
							table.insert(indirectlyAffectedElements, value)
						end
					end
				end
			end

			if #indirectlyAffectedElements > 0 then
				table.insert(affectedElements, "Indirectly Affected:")
				for k, v in ipairs(indirectlyAffectedElements) do
					table.insert(affectedElements, v)
				end
			end
			exports.logs:dbLog(source, radioID < 0 and 10 or 9, affectedElements, ( radioID < 0 and "" or ( theChannel .. " " ) ) ..languagename.." "..message)
		else
			outputChatBox("Your radio is off. ((/toggleradio))", source, 255, 0, 0)
		end
	else
		outputChatBox("You do not have a radio.", source, 255, 0, 0)
	end
end

function chatMain(message, messageType)
	if exports['freecam-tv']:isPlayerFreecamEnabled(source) then cancelEvent() return end

	local logged = getElementData(source, "loggedin")

	if (messageType == 1 or not (isPedDead(source))) and (logged==1) and not (messageType==2) then -- Player cannot chat while dead or not logged in, unless its OOC
		local dimension = getElementDimension(source)
		local interior = getElementInterior(source)
		-- Local IC
		if (messageType==0) then
			local languageslot = getElementData(source, "languages.current") or 1
			local language = getElementData(source, "languages.lang" .. languageslot)
			localIC(source, message, language)
		elseif (messageType==1) then -- Local /me action
			meEmote(source, "me", message)
		end
	elseif (messageType==2) and (logged==1) then -- Radio
		radio(source, 1, message)
	end
end
addEventHandler("onPlayerChat", getRootElement(), chatMain)

function msgRadio(thePlayer, commandName, ...)
	if getElementData(thePlayer, "loggedin") == 0 then return false end

	if (...) then
		local message = table.concat({...}, " ")
		radio(thePlayer, 1, message, commandName)
	else
		outputChatBox("SYNTAX: /" .. commandName .. " [Message]", thePlayer, 255, 194, 14)
	end
end
addCommandHandler("r", msgRadio, false, false)
addCommandHandler("radio", msgRadio, false, false)
addCommandHandler("rlow", msgRadio, false, false)

for i = 1, 20 do
	addCommandHandler( "r" .. tostring( i ),
		function( thePlayer, commandName, ... )
			if i <= exports['item-system']:countItems(thePlayer, 6) then
				if (...) then
					radio( thePlayer, i, table.concat({...}, " ") )
				else
					outputChatBox("SYNTAX: /" .. commandName .. " [Message]", thePlayer, 255, 194, 14)
				end
			end
		end
	)
end

function govAnnouncement(thePlayer, commandName, ...)
	local faction = exports.factions:getCurrentFactionDuty(thePlayer) or -1

	if faction > 0 then
		if (faction==1 or faction==2 or faction==3 or faction==47 or faction==59) then
			local message = table.concat({...}, " ")
			local _, factionRank = exports.factions:isPlayerInFaction(thePlayer, faction)
			local factionleader = exports.factions:hasMemberPermissionTo(thePlayer, faction, "add_member")

			if #message == 0 then
				outputChatBox("SYNTAX: /" .. commandName .. " [message]", thePlayer, 255, 194, 14)
				return false
			end

			if factionLeader then
				local theTeam = exports.factions:getFactionFromID(faction)
				local ranks = getElementData(theTeam,"ranks")
				local factionRankTitle = ranks[factionRank]

				exports.logs:dbLog(source, 16, source, message)
				for key, value in ipairs(exports.pool:getPoolElementsByType("player")) do
					local logged = getElementData(value, "loggedin")

					if (logged==1) then
						outputChatBox(">> Government Announcement from " .. factionRankTitle .. " " .. getPlayerName(thePlayer), value, 0, 183, 239)
						outputChatBox(message, value, 0, 183, 239)
					end
				end
			else
				outputChatBox("You do not have permission to use this command.", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("gov", govAnnouncement)

function playerToggleDonatorChat(thePlayer, commandName)
	local logged = getElementData(thePlayer, "loggedin")
	local hasPerk, perkValue = exports.donators:hasPlayerPerk(thePlayer, 9)
	if (logged==1 and hasPerk) then
		local enabled = getElementData(thePlayer, "donatorchat")
		if (tonumber(perkValue)==1) then
			outputChatBox("You have now hidden Donator Chat.", thePlayer, 255, 194, 14)
			exports.donators:updatePerkValue(thePlayer, 9, 0)
		else
			outputChatBox("You have now enabled Donator Chat.", thePlayer, 255, 194, 14)
			exports.donators:updatePerkValue(thePlayer, 9, 1)
		end
	end
end
addCommandHandler("toggledonatorchat", playerToggleDonatorChat, false, false)
addCommandHandler("toggledon", playerToggleDonatorChat, false, false)
addCommandHandler("toggledchat", playerToggleDonatorChat, false, false)

function donatorchat(thePlayer, commandName, ...) -- MAXIME
	local hasDonChat, togDonChatState = exports.donators:hasPlayerPerk(thePlayer, 10)
	if hasDonChat or exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) then
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Message]", thePlayer, 255, 194, 14)
		else
			local logged = tonumber(getElementData(thePlayer, "loggedin"))
			if (logged ~= 1) then
				return
			end

			local affectedElements = { }
			table.insert(affectedElements, thePlayer)
			local message = table.concat({...}, " ")
			local title = ""
			local hidden = getElementData(thePlayer, "hiddenadmin") or 0

			if (tonumber(togDonChatState) == 0) then
				outputChatBox("[Donator] You're sending a message while having your donator chat channel toggled off.", thePlayer, 200, 200, 200)
			end

			for key, value in ipairs(getElementsByType("player")) do
				local hasAccess, isEnabled = exports.donators:hasPlayerPerk(value, 10)
				local logged = tonumber(getElementData(value, "loggedin"))
				if (logged == 1) and (hasAccess or exports.integration:isPlayerTrialAdmin(value) or exports.integration:isPlayerScripter(value) ) then
					if ( tonumber(isEnabled) ~= 0 ) or (value == thePlayer) then
						table.insert(affectedElements, value)
						outputChatBox("[Donator] " .. exports.global:getPlayerFullIdentity(thePlayer) .. ": " .. message, value, 160, 164, 104)
					end
				end
			end
			exports.logs:dbLog(thePlayer, 17, affectedElements, message)
		end
	end
end
addCommandHandler("donator", donatorchat, false, false)
addCommandHandler("don", donatorchat, false, false)
addCommandHandler("dchat", donatorchat, false, false)

function departmentradio(thePlayer, commandName, ...)
	local tollped = getElementType(thePlayer) == "ped" and getElementData(thePlayer, "toll:key")
	local inAnyDepFaction = false
	if not tollped then
		local teamIDs = getElementData(thePlayer, "faction") or {}
		for _, factionID in ipairs(factionsThatCanUseDepartmentRadio) do
			if teamIDs[factionID] then
				inAnyDepFaction = true
				break
			end
		end
	end

	if (inAnyDepFaction or tollped) then
		if (...) then
			local message = table.concat({...}, " ")
			radio(thePlayer, -1, message)
		elseif not tollped then
			outputChatBox("SYNTAX: /" .. commandName .. " [Message]", thePlayer, 255, 194, 14)
		end
	end
end
addCommandHandler("dep", departmentradio, false, false)
addCommandHandler("department", departmentradio, false, false)

function medicalRadio(thePlayer, commandName, ...)
	local inAnyMedFaction = false
	if not tollped then
		local teamIDs = getElementData(thePlayer, "faction") or {}
		for _, factionID in ipairs(factionsThatCanUseMedicalRadio) do
			if teamIDs[factionID] then
				inAnyMedFaction = true
				break
			end
		end
	end

	if (inAnyMedFaction) then
		if (...) then
			local message = table.concat({...}, " ")
			radio(thePlayer, -6, message)
		elseif not tollped then
			outputChatBox("SYNTAX: /" .. commandName .. " [Message]", thePlayer, 255, 194, 14)
		end
	end
end
addCommandHandler("med", medicalRadio, false, false)
addCommandHandler("medical", medicalRadio, false, false)

function airradio(thePlayer, commandName, ...)
	local playersInAir = exports.sfia:getPlayersInAircraft( )
	if playersInAir then
		local found = false
		if exports.factions:isPlayerInFaction(thePlayer, 47) then
			for _, itemRow in ipairs(exports['item-system']:getItems(thePlayer)) do
				if (itemRow[1] == 6 and itemRow[2] > 0) then
					found = true
					break
				end
			end
		end

		if not found then
			for k, v in ipairs( playersInAir ) do
				if v == thePlayer then
					found = true
					break
				end
			end
		end

		if found then
			if not ... then
				outputChatBox("SYNTAX: /" .. commandName .. " [Message]", thePlayer, 255, 194, 14)
			else
				radio(thePlayer, -2, table.concat({...}, " "))
			end
		else
			outputChatBox("You weren't able to speak over the air frequency.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("air", airradio, false, false)
addCommandHandler("airradio", airradio, false, false)

 --PA (speakers) in vehicles and interiors // Exciter
function ICpublicAnnouncement(thePlayer, commandName, ...)
	if not ... then
		outputChatBox("SYNTAX: /" .. commandName .. " [Message]", thePlayer, 255, 194, 14)
	else
		radio(thePlayer, -3, table.concat({...}, " "))
	end
end
addCommandHandler("pa", ICpublicAnnouncement, false, false)

 --PA (speakers) at airports // Exciter
function ICAirportAnnouncement(thePlayer, commandName, ...)
	if not ... then
		outputChatBox("SYNTAX: /" .. commandName .. " [Message]", thePlayer, 255, 194, 14)
	else
		radio(thePlayer, -4, table.concat({...}, " "))
	end
end
addCommandHandler("airportpa", ICAirportAnnouncement, false, false)

 --PA (speakers) at hospital // Exciter
function ICHospitalAnnouncement(thePlayer, commandName, ...)
	if not ... then
		outputChatBox("SYNTAX: /" .. commandName .. " [Message]", thePlayer, 255, 194, 14)
	else
		radio(thePlayer, -5, table.concat({...}, " "))
	end
end
addCommandHandler("hospitalpa", ICHospitalAnnouncement, false, false)

function blockChatMessage()
	cancelEvent()
end
addEventHandler("onPlayerChat", getRootElement(), blockChatMessage)
-- End of Main Chat

function globalOOC(thePlayer, commandName, ...)
	local logged = tonumber(getElementData(thePlayer, "loggedin"))

	if (logged==1) then
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Message]", thePlayer, 255, 194, 14)
		else
			local oocEnabled = exports.global:getOOCState()
			message = table.concat({...}, " ")
			local muted = getElementData(thePlayer, "muted")
			if (oocEnabled==0) and not exports.integration:isPlayerTrialAdmin(thePlayer) and not exports.integration:isPlayerScripter(thePlayer) then
				outputChatBox("OOC Chat is currently disabled.", thePlayer, 255, 0, 0)
			elseif (muted==1) then
				outputChatBox("You are currently muted from the OOC Chat.", thePlayer, 255, 0, 0)
			else
				local affectedElements = { }
				local players = exports.pool:getPoolElementsByType("player")
				local playerName = getPlayerName(thePlayer)
				local playerID = getElementData(thePlayer, "playerid")

				for k, arrayPlayer in ipairs(players) do
					local logged = tonumber(getElementData(arrayPlayer, "loggedin"))
					local targetOOCEnabled = getElementData(arrayPlayer, "globalooc")

					if (logged==1) and (targetOOCEnabled==1) then
						table.insert(affectedElements, arrayPlayer)
						if exports.integration:isPlayerTrialAdmin(thePlayer) then
                            local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
							if getElementData(thePlayer, "hiddenadmin") then
								outputChatBox("(( "..exports.global:getPlayerFullIdentity(thePlayer)..": " .. message .. " ))", arrayPlayer, 196, 255, 255)
							else
								outputChatBox("(( "..exports.global:getPlayerFullIdentity(thePlayer)..": " .. message .. " ))", arrayPlayer, 196, 255, 255)
							end
                        else
							outputChatBox("(( "..exports.global:getPlayerFullIdentity(thePlayer)..": " .. message .. " ))", arrayPlayer, 196, 255, 255)
                        end
					end
				end
				exports.logs:dbLog(thePlayer, 18, affectedElements, message)
			end
		end
	end
end
addCommandHandler("ooc", globalOOC, false, false)
addCommandHandler("GlobalOOC", globalOOC)

function playerToggleOOC(thePlayer, commandName)
	local logged = getElementData(thePlayer, "loggedin")

	if (logged==1) then
		local playerOOCEnabled = getElementData(thePlayer, "globalooc")

		if (playerOOCEnabled==1) then
			outputChatBox("You have now hidden Global OOC Chat.", thePlayer, 255, 194, 14)
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "globalooc", 0, false)
		else
			outputChatBox("You have now enabled Global OOC Chat.", thePlayer, 255, 194, 14)
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "globalooc", 1, false)
		end
		mysql:query_free("UPDATE account_details SET globalooc=" .. mysql:escape_string(getElementData(thePlayer, "globalooc")) .. " WHERE account_id = " .. mysql:escape_string(getElementData(thePlayer, "account:id")))
	end
end
addCommandHandler("toggleooc", playerToggleOOC, false, false)

local advertisementMessages = { "samp", "SA-MP", "Kye", "shodown", "Vedic", "vedic","ventro","Ventro", "server", "sincityrp", "ls-rp", "sincity", "tri0n3", "www.", ".com", "co.cc", ".net", ".co.uk", "everlast", "neverlast", "www.everlastgaming.com", "trueliferp", "truelife", "mtarp", "mta:rp", "mta-rp"}

function isFriendOf(thePlayer, targetPlayer)
	return exports.social:isFriendOf( getElementData( thePlayer, "account:id"), getElementData( targetPlayer, "account:id" ))
end

function scripterChat(thePlayer, commandName, ...)
    local logged = getElementData(thePlayer, "loggedin")

    if(logged==1) and (exports.integration:isPlayerScripter(thePlayer))  then
        if not (...) then
            outputChatBox("SYNTAX: /ss [Message]", thePlayer, 255, 194, 14)
        else
            local message = table.concat({...}, " ")
            local players = exports.pool:getPoolElementsByType("player")
            local username = getElementData(thePlayer,"account:username")

            for k, arrayPlayer in ipairs(players) do
                local logged = getElementData(arrayPlayer, "loggedin")

                if(exports.integration:isPlayerScripter(arrayPlayer)) and (logged==1) then
                    outputChatBox("[Scripter] ("..getElementData(thePlayer, "playerid")..") " .. username .. ": " .. message, arrayPlayer, 222, 222, 31)
                end
            end
        end
    end
end
addCommandHandler("ss", scripterChat, false, false)
addCommandHandler("u", scripterChat, false, false)

local vctEnabled = true

function vctChat(thePlayer, commandName, ...)
    local logged = getElementData(thePlayer, "loggedin")

    if(logged==1) and (exports.integration:isPlayerVCTMember(thePlayer))  then
        if not (...) then
            outputChatBox("SYNTAX: /v [Message]", thePlayer, 255, 194, 14)
        else
            local message = table.concat({...}, " ")
            local players = exports.pool:getPoolElementsByType("player")
            local username = getElementData(thePlayer,"account:username")

			if not vctEnabled then
				outputChatBox( "VCT chat is disabled by a leader.", thePlayer, 255, 100, 100 )
				return
			end

            for k, arrayPlayer in ipairs(players) do
                local logged = getElementData(arrayPlayer, "loggedin")

                if exports.integration:isPlayerVCTMember(arrayPlayer) and (logged==1) and vctEnabled then
                    outputChatBox("[VCT] ("..getElementData(thePlayer, "playerid")..") "..(exports.integration:isPlayerVehicleConsultant(thePlayer) and "Leader" or "Member" ).." " .. username .. ": " .. message, arrayPlayer, 222, 222, 31)
                end
            end
        end
    end
end
addCommandHandler("v", vctChat, false, false)
addCommandHandler("vct", vctChat, false, false)

function toggleVCT( player, command )
	if exports.integration:isPlayerVehicleConsultant( player ) and (getElementData(player, "loggedin") == 1) then
		vctEnabled = not vctEnabled
		if vctEnabled then
			outputChatBox( "VCT chat enabled.", player, 0, 255, 0 )
		else
			outputChatBox( "VCT chat disabled.", player, 255, 0, 0 )
		end
	end
end
addCommandHandler("togglevct", toggleVCT)
addCommandHandler("togvct", toggleVCT)

function mappingTeamChat(thePlayer, commandName, ...)
    local logged = getElementData(thePlayer, "loggedin")

    if(logged==1) and (exports.integration:isPlayerMappingTeamMember(thePlayer))  then
        if not (...) then
            outputChatBox("SYNTAX: /mt [Message]", thePlayer, 255, 194, 14)
        else
            local message = table.concat({...}, " ")
            local players = exports.pool:getPoolElementsByType("player")
            local username = getElementData(thePlayer,"account:username")

            for k, arrayPlayer in ipairs(players) do
                local logged = getElementData(arrayPlayer, "loggedin")

                if exports.integration:isPlayerMappingTeamMember(arrayPlayer) and (logged==1) then
                    outputChatBox("[MT] ("..getElementData(thePlayer, "playerid")..") "..(exports.integration:isPlayerMappingTeamLeader(thePlayer) and "Leader" or "Member" ).." " .. username .. ": " .. message, arrayPlayer, 222, 222, 31)
                end
            end
        end
    end
end
addCommandHandler("mt", mappingTeamChat, false, false)

function fmtChat(thePlayer, commandName, ...)
    local logged = getElementData(thePlayer, "loggedin")

    if(logged==1) and (exports.integration:isPlayerFMTMember(thePlayer))  then
        if not (...) then
            outputChatBox("SYNTAX: /fmt [Message]", thePlayer, 255, 194, 14)
        else
            local message = table.concat({...}, " ")
            local players = exports.pool:getPoolElementsByType("player")
            local username = getElementData(thePlayer,"account:username")

            for k, arrayPlayer in ipairs(players) do
                local logged = getElementData(arrayPlayer, "loggedin")

                if exports.integration:isPlayerFMTMember(arrayPlayer) and (logged==1) then
                    outputChatBox("[FMT] ("..getElementData(thePlayer, "playerid")..") "..(exports.integration:isPlayerFMTLeader(thePlayer) and "Leader" or "Member" ).." " .. username .. ": " .. message, arrayPlayer, 255, 69, 0)
                end
            end
        end
    end
end
addCommandHandler("fmt", fmtChat, false, false)


ignoreList = {}
function ignoreOnePlayer(thePlayer, commandName, targetPlayerNick)
	local logged = getElementData(thePlayer, "loggedin")
	if (logged==1) then
		if not (targetPlayerNick) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayerNick)
			if exports.integration:isPlayerStaff(targetPlayer) then
				outputChatBox("You may not ignore staff.", thePlayer, 255, 0, 0)
				return
			end

			local existed = false
			for k, v in ipairs(ignoreList[thePlayer] or {}) do
				if v == targetPlayer then
					table.remove(ignoreList[thePlayer], k)
					outputChatBox("You're no longer ignoring whispers from " .. targetPlayerName .. ".", thePlayer, 0, 255, 0)
					existed = true
					break
				end
			end
			if not existed then
				if not ignoreList[thePlayer] then
					ignoreList[thePlayer] = {}
				end
				table.insert(ignoreList[thePlayer], targetPlayer)
				outputChatBox("You're ignoring whispers from " .. targetPlayerName .. ".", thePlayer, 0, 255, 0)
				outputChatBox("Type /ignorelist for a full list of players you're ignoring.", thePlayer, 0, 255, 0)
			end
		end
	end
end
addCommandHandler("ignore", ignoreOnePlayer)

function checkifiamfucked(thePlayer, commandName)
	outputChatBox(" ~~~~~~~~~ Ignore List ~~~~~~~~~ ", thePlayer, 237, 172, 19)
	outputChatBox("    -- CURRENTLY IGNORING --", thePlayer, 2, 172, 19)
	for k, v in ipairs(ignoreList[thePlayer] or {}) do
		-- Respect username setting
		if getElementData(v, "pm_username") == "0" then
			outputChatBox(getPlayerName(v):gsub("_"," "), thePlayer, 255, 255, 255)
		else
			outputChatBox(getPlayerName(v):gsub("_"," ") .. " (" .. getElementData(v, "account:username") .. ")", thePlayer, 255, 255, 255)
		end
	end
	outputChatBox(" ~~~~~~~~~~~~~~~~~~~~~~~~~~~ ", thePlayer, 237, 172, 19)
end
addCommandHandler("ignorelist", checkifiamfucked)

addEventHandler('onPlayerQuit', root,
	function()
		ignoreList[source] = nil
		for k, v in pairs(ignoreList) do
			for kx, vx in ipairs(v) do
				if vx == source then
					table.remove(vx, kx)
					break
				end
			end
		end
	end)
-- QUICK PM REPLY + PM SOUND FX / MAXIME
function pmPlayer(thePlayer, commandName, who, ...)
	local message = nil
	if tostring(commandName):lower() == "quickreply" and who then
		local target = getElementData(thePlayer, "targetPMer")
		if not target or not isElement(target) or not (getElementType(target) == "player") or not (getElementData(target, "loggedin") == 1) then
			outputChatBox("No one is PM'ing you.", thePlayer, 200,200,200)
			return false
		end
		message = who.." "..table.concat({...}, " ")
		who = target
	else
		if not (who) or not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick] [Message]", thePlayer, 255, 194, 14)
			outputChatBox("Press 'U' to quickly reply PMs.", thePlayer)
			return false
		end
		message = table.concat({...}, " ")
	end



	if who and message then

		local loggedIn = getElementData(thePlayer, "loggedin")
		if (loggedIn==0) then
			return
		end

		local targetPlayer, targetPlayerName
		if (isElement(who)) then
			if (getElementType(who)=="player") then
				targetPlayer = who
				targetPlayerName = getPlayerName(who)
				message = string.gsub(message, string.gsub(targetPlayerName, " ", "_", 1) .. " ", "", 1)
			end
		else
			targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, who)
		end

		if (targetPlayer) then
			if targetPlayer == thePlayer then
				outputChatBox("You clearly don't need to pm yourself.", thePlayer, 255, 0, 0)
				return false
			end

			if getElementData(targetPlayer, "loggedin") ~= 1 then
				outputChatBox("Player is not logged in yet.", thePlayer, 255, 255, 0)
				return false
			end

			local senderPmPerk, senderPmState = exports.donators:hasPlayerPerk(thePlayer, 1)
			local targetPmPerk, targetPmState = exports.donators:hasPlayerPerk(targetPlayer, 1)

			-- if target has pms off.
			if targetPmPerk and tonumber(targetPmState) == 1 then
				if exports.global:isStaffOnDuty(thePlayer) or (getElementData(thePlayer, "reportadmin") == targetPlayer) then
					-- Let pm go through
				else
					local are_they_friends = call(getResourceFromName("social"), "isFriendOf", getElementData(thePlayer, 'account:id'), getElementData(targetPlayer, 'account:id'))
					local allow_friends_pm = getElementData(targetPlayer, 'social_friends_bypass_pmblock') == '1'
					if are_they_friends and allow_friends_pm then
						-- Let pm go through
					else
						outputChatBox("Player is ignoring private messages.", thePlayer, 255, 255, 0)
						return false
					end
				end
			end

			-- check if ignored
			for k, v in ipairs(ignoreList[thePlayer] or {}) do
				if v == targetPlayer then
					outputChatBox('You are currently ignoring ' .. targetPlayerName .. '. Remove him from your ignore list to PM.', thePlayer, 255, 0, 0)
					return false
				end
			end
			for k, v in ipairs(ignoreList[targetPlayer] or {}) do
				if v == thePlayer then
					outputChatBox(targetPlayerName .. ' is ignoring private messages from you.', thePlayer, 255, 0, 0)
					return false
				end
			end

			setElementData(targetPlayer, "targetPMer", thePlayer, false)

			local playerName = getPlayerName(thePlayer):gsub("_", " ")
			local targetUsername1, username1 = getElementData(targetPlayer, "account:username"), getElementData(thePlayer, "account:username")

			local targetUsername = " ("..targetUsername1..")"
			local username = " ("..username1..")"


			--local hasPerk, value = not exports.integration:isPlayerTrialAdmin(targetPlayer), 1 --exports.donators:hasPlayerPerk(thePlayer, 9)
			--if hasPerk and tonumber(value) == 1 then
			if getElementData(thePlayer, "pm_username") == "0" and ((exports.integration:isPlayerSupporter(targetPlayer) and (getElementData(targetPlayer, "duty_supporter") ~= 1)) or (exports.integration:isPlayerTrialAdmin(targetPlayer) and (getElementData(targetPlayer, "duty_admin") ~= 1)) or (not exports.integration:isPlayerTrialAdmin(targetPlayer) and not exports.integration:isPlayerSupporter(targetPlayer))) and ((exports.integration:isPlayerSupporter(thePlayer) and (getElementData(thePlayer, "duty_supporter") ~= 1)) or (exports.integration:isPlayerTrialAdmin(thePlayer) and (getElementData(thePlayer, "duty_admin") ~= 1)) or (not exports.integration:isPlayerTrialAdmin(thePlayer) and not exports.integration:isPlayerSupporter(thePlayer))) then
				username = ""
			end

			--local hasPerk2, value2 = not exports.integration:isPlayerTrialAdmin(thePlayer), 1 --exports.donators:hasPlayerPerk(targetPlayer, 9)
			--if hasPerk2 and tonumber(value2) == 1 then
			if getElementData(targetPlayer, "pm_username") == "0" and ((exports.integration:isPlayerSupporter(targetPlayer) and (getElementData(targetPlayer, "duty_supporter") ~= 1)) or (exports.integration:isPlayerTrialAdmin(targetPlayer) and (getElementData(targetPlayer, "duty_admin") ~= 1)) or (not exports.integration:isPlayerTrialAdmin(targetPlayer) and not exports.integration:isPlayerSupporter(targetPlayer))) and ((exports.integration:isPlayerSupporter(thePlayer) and (getElementData(thePlayer, "duty_supporter") ~= 1)) or (exports.integration:isPlayerTrialAdmin(thePlayer) and (getElementData(thePlayer, "duty_admin") ~= 1)) or (not exports.integration:isPlayerTrialAdmin(thePlayer) and not exports.integration:isPlayerSupporter(thePlayer))) then
				targetUsername = ""
			end
			--[[
			if exports.global:isStaffOnDuty(thePlayer) then
				targetUsername = " ("..tostring(getElementData(targetPlayer, "account:username"))..")"
			end
			if exports.global:isStaffOnDuty(targetPlayer) then
				username = " ("..tostring(getElementData(thePlayer, "account:username"))..")"
			end
			]]
			if not exports.integration:isPlayerLeadAdmin(thePlayer) and not exports.integration:isPlayerLeadAdmin(targetPlayer) then
				-- Check for advertisements
				for k,v in ipairs(advertisementMessages) do
					local found = string.find(string.lower(message), "%s" .. tostring(v))
					local found2 = string.find(string.lower(message), tostring(v) .. "%s")
					if (found) or (found2) or (string.lower(message)==tostring(v)) then
						exports.global:sendMessageToAdmins("AdmWrn: " .. tostring(playerName) .. " sent a possible advertisement PM to " .. tostring(targetPlayerName) .. ".")
						exports.global:sendMessageToAdmins("AdmWrn: Message: " .. tostring(message))
						break
					end
				end
			end

			-- Send the message
			local playerid = getElementData(thePlayer, "playerid")
			local targetid = getElementData(targetPlayer, "playerid")
			messageToTarget = "PM From (" .. playerid .. ") " .. playerName ..username..": " .. message
			outputChatBox(messageToTarget, targetPlayer, 255, 255, 0)
			outputChatBox("PM Sent to (" .. targetid .. ") " .. targetPlayerName ..targetUsername.. ": " .. message, thePlayer, 255, 255, 0)

			triggerClientEvent(targetPlayer,"pmClient",targetPlayer,messageToTarget)
			triggerClientEvent(thePlayer,"pmClient",thePlayer)

			--URL forwarder by MAXIME
			local url = exports.global:getUrlFromString(message)
			if url then
				exports.help:startUrlSender(thePlayer, "url", targetPlayer, url)
			end

			exports.logs:dbLog(thePlayer, 15, { thePlayer, targetPlayer }, message)

			local received = {}
			received[thePlayer] = true
			received[targetPlayer] = true
			for key, value in pairs( getElementsByType( "player" ) ) do
				if isElement( value ) and not received[value] then
					local listening = getElementData( value, "bigears" )
					if listening == thePlayer or listening == targetPlayer then
						received[value] = true
						outputChatBox("(" .. playerid .. ") " .. playerName .. " -> (" .. targetid .. ") " .. targetPlayerName .. ": " .. message, value, 255, 255, 0)
						triggerClientEvent(value,"pmClient",value)
					end
				end
			end

			if senderPmPerk and tonumber(senderPmState) == 1 and not (getElementData(targetPlayer, "reportadmin") == thePlayer) then -- if sender has pms off.
				outputChatBox("You're sending out private messages while ignoring incoming messages.", thePlayer, 200, 200, 200)
			end

			-- tells the PMing player if the target is afk.
			if getElementData(targetPlayer, "afk") then 
				outputChatBox("The player you're PMing is currently AFK.", thePlayer, 200, 200, 200)
			end
		end
	end
end
addCommandHandler("pm", pmPlayer, false, false)
addCommandHandler("quickreply", pmPlayer, false, false)


function localOOC(thePlayer, commandName, ...)
	if exports['freecam-tv']:isPlayerFreecamEnabled(thePlayer) then return end

	local logged = getElementData(thePlayer, "loggedin")
	local dimension = getElementDimension(thePlayer)
	local interior = getElementInterior(thePlayer)

	if (logged==1) and not (isPedDead(thePlayer)) then
		local muted = getElementData(thePlayer, "muted")
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Message]", thePlayer, 255, 194, 14)
		elseif (muted==1) then
			outputChatBox("You are muted.", thePlayer, 255, 0, 0)
		else
			if(interior > 0 and dimension > 0) then
				local blockOOC = exports.interior_system:getInteriorSetting(dimension, "ooc")
				if blockOOC then
					if(exports.integration:isPlayerTrialAdmin(thePlayer) and exports.global:isStaffOnDuty(thePlayer) or exports.integration:isPlayerSupporter(thePlayer) and exports.global:isStaffOnDuty(thePlayer)) then
						--all okay
					else
						exports.hud:sendBottomNotification(thePlayer, "OOC chat disabled", "Local OOC chat is disabled in this interior, to promote in-character roleplay. Use /pm instead.")
						return false
					end
				end
			end

			--MAXIME
			local r,g,b = 196, 255, 255

			if exports.integration:isPlayerTrialAdmin(thePlayer) and getElementData(thePlayer, "duty_admin") == 1 and getElementData(thePlayer, "hiddenadmin") == 0 and not getElementData(thePlayer, "supervising") then
				r,g,b = getPlayerNametagColor( thePlayer )
				setElementData(thePlayer, "supervisorBchat", false)
			elseif exports.integration:isPlayerTrialAdmin(thePlayer) and getElementData(thePlayer, "duty_admin") == 1 and getElementData(thePlayer, "hiddenadmin") == 0 and getElementData(thePlayer, "supervising") then
				r,g,b = 100, 149, 237
				setElementData(thePlayer, "supervisorBchat", true)
			elseif exports.integration:isPlayerSupporter(thePlayer) and getElementData(thePlayer, "supervising") then
				r,g,b = 100, 149, 237
				setElementData(thePlayer, "supervisorBchat", true)
			elseif exports.integration:isPlayerSupporter(thePlayer) and not getElementData(thePlayer, "supervising") then
				r,g,b = 196, 255, 255
				setElementData(thePlayer, "supervisorBchat", false)
			end

			local message = table.concat({...}, " ")
			if getElementData(thePlayer, "supervisorBchat") == false or nil then -- The below locals were contained in the if, else statements. Therefore returned nil to the export db //Chaos
				result, affectedElements = exports.global:sendLocalText(thePlayer, getPlayerName(thePlayer) .. ": (( " .. message .. " ))", r,g,b)
			else
				result, affectedElements = exports.global:sendLocalText(thePlayer, exports.global:getPlayerFullIdentity(thePlayer) .. ": (( " .. message .. " ))", r,g,b)
			end
			exports.logs:dbLog(thePlayer, 8, affectedElements, message)
		end
	end
end
addCommandHandler("b", localOOC, false, false)
addCommandHandler("LocalOOC", localOOC)

function districtIC(thePlayer, commandName, ...)
	if exports['freecam-tv']:isPlayerFreecamEnabled(thePlayer) then return end

	local logged = getElementData(thePlayer, "loggedin")
	local dimension = getElementDimension(thePlayer)
	local interior = getElementInterior(thePlayer)

	if (logged==1) and not (isPedDead(thePlayer)) then
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Message]", thePlayer, 255, 194, 14)
		else
			local affectedElements = { }
			local playerName = getPlayerName(thePlayer)
			local message = table.concat({...}, " ")
			local zonename = exports.global:getElementZoneName(thePlayer)
			local x, y = getElementPosition(thePlayer)

			for key, value in pairs(getElementsByType("player")) do
				local playerzone = exports.global:getElementZoneName(value)
				local playerdimension = getElementDimension(value)
				local playerinterior = getElementInterior(value)

				if (zonename==playerzone) and (dimension==playerdimension) and (interior==playerinterior) and getDistanceBetweenPoints2D(x, y, getElementPosition(value)) < 200 then
					local logged = getElementData(value, "loggedin")
					if (logged==1) then
						table.insert(affectedElements, value)
						if exports.integration:isPlayerTrialAdmin(value) then
							outputChatBox("District IC: " .. message .. " ((".. playerName .."))", value, 255, 255, 255)
						else
							outputChatBox("District IC: " .. message, value, 255, 255, 255)
						end
					end
				end
			end
			exports.logs:dbLog(thePlayer, 13, affectedElements, message)
		end
	end
end
addCommandHandler("district", districtIC, false, false)

function localDo(thePlayer, commandName, ...)
	if exports['freecam-tv']:isPlayerFreecamEnabled(thePlayer) then return end

	local logged = getElementData(thePlayer, "loggedin")
	local dimension = getElementDimension(thePlayer)

	if logged==1 then
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Action/Event]", thePlayer, 255, 194, 14)
		else
			local message = table.concat({...}, " ")
			local result, affectedElements = exports.global:sendLocalDoAction(thePlayer, message, true)

			if dimension ~= 0 then
				table.insert(affectedElements, "in"..tostring(dimension))
			end
			exports.logs:dbLog(thePlayer, 14, affectedElements, message)
		end
	end
end
addCommandHandler("do", localDo, false, false)


function localShout(thePlayer, commandName, ...)
	if exports['freecam-tv']:isPlayerFreecamEnabled(thePlayer) then return end
	local affectedElements = { }
	table.insert(affectedElements, thePlayer)
	local logged = getElementData(thePlayer, "loggedin")
	local dimension = getElementDimension(thePlayer)
	local interior = getElementInterior(thePlayer)

	if not (isPedDead(thePlayer)) and (logged==1) then
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Message]", thePlayer, 255, 194, 14)
		else
			local playerName = getPlayerName(thePlayer)

			local language, languagename = getCurrentLanguage(thePlayer, commandName)
			if language == 0 then
				return
			end

			local message = trunklateText(thePlayer, table.concat({...}, " "))
			local r, g, b = 255, 255, 255
			local focus = getElementData(thePlayer, "focus")
			if type(focus) == "table" then
				for player, color in pairs(focus) do
					if player == thePlayer then
						r, g, b = unpack(color)
					end
				end
			end
			outputChatBox("[" .. languagename .. "] " .. playerName .. " shouts: " .. message .. "!", thePlayer, r, g, b)
			for index, nearbyPlayer in ipairs(getElementsByType("player")) do
				if getElementDistance( thePlayer, nearbyPlayer ) < 40 then
					local nearbyPlayerDimension = getElementDimension(nearbyPlayer)
					local nearbyPlayerInterior = getElementInterior(nearbyPlayer)

					if (nearbyPlayerDimension==dimension) and (nearbyPlayerInterior==interior) and (nearbyPlayer~=thePlayer) then
						local logged = getElementData(nearbyPlayer, "loggedin")

						if (logged==1) and not (isPedDead(nearbyPlayer)) then
							table.insert(affectedElements, nearbyPlayer)
							local message2 = call(getResourceFromName("language-system"), "applyLanguage", thePlayer, nearbyPlayer, message, language)
							message2 = trunklateText(nearbyPlayer, message2)
							local r, g, b = 255, 255, 255
							local focus = getElementData(nearbyPlayer, "focus")
							if type(focus) == "table" then
								for player, color in pairs(focus) do
									if player == thePlayer then
										r, g, b = unpack(color)
									end
								end
							end
							outputChatBox("[" .. languagename .. "] " .. playerName .. " shouts: " .. message2 .. "!", nearbyPlayer, r, g, b)
						end
					end
				end
			end
			exports.logs:dbLog(thePlayer, 19, affectedElements, languagename.." "..message)
		end
	end
end
addLocalizedCommandHandler("s", localShout, false, false)

function megaphoneShout(thePlayer, commandName, ...)
	if exports['freecam-tv']:isPlayerFreecamEnabled(thePlayer) then return end

	local logged = getElementData(thePlayer, "loggedin")
	local dimension = getElementDimension(thePlayer)
	local interior = getElementInterior(thePlayer)
	local vehicle = getPedOccupiedVehicle(thePlayer)
	local seat = getPedOccupiedVehicleSeat(thePlayer)

	if not (isPedDead(thePlayer)) and (logged==1) then
		local types = exports.factions:getPlayerFactionTypes(thePlayer)
		if types[2] or types[3] or types[4] or (exports.global:hasItem(thePlayer, 141)) or ( isElement(vehicle) and exports.global:hasItem(vehicle, 141) and (seat==1 or seat==0)) then
			local affectedElements = { }

			if not (...) then
				outputChatBox("SYNTAX: /" .. commandName .. " [Message]", thePlayer, 255, 194, 14)
			else
				local playerName = getPlayerName(thePlayer)
				local message = trunklateText(thePlayer, table.concat({...}, " "))

				local languageslot = getElementData(thePlayer, "languages.current") or 1
				local language = getElementData(thePlayer, "languages.lang" .. languageslot)
				local langname = call(getResourceFromName("language-system"), "getLanguageName", language)

				for index, nearbyPlayer in ipairs(getElementsByType("player")) do
					if getElementDistance( thePlayer, nearbyPlayer ) < 40 then
						local nearbyPlayerDimension = getElementDimension(nearbyPlayer)
						local nearbyPlayerInterior = getElementInterior(nearbyPlayer)

						if (nearbyPlayerDimension==dimension) and (nearbyPlayerInterior==interior) then
							local logged = getElementData(nearbyPlayer, "loggedin")

							if (logged==1) and not (isPedDead(nearbyPlayer)) then
								local message2 = message
								if nearbyPlayer ~= thePlayer then
									message2 = call(getResourceFromName("language-system"), "applyLanguage", thePlayer, nearbyPlayer, message, language)
								end
								table.insert(affectedElements, nearbyPlayer)
								outputChatBox(" [" .. langname .. "] ((" .. playerName .. ")) Megaphone <O: " .. trunklateText(nearbyPlayer, message2), nearbyPlayer, 255, 255, 0)
							end
						end
					end
				end
				exports.logs:dbLog(thePlayer, 20, affectedElements, langname.." "..message)
			end
		else
			outputChatBox("Believe it or not, it's hard to shout through a megaphone you do not have.", thePlayer, 255, 0 , 0)
		end
	end
end
addCommandHandler("m", megaphoneShout, false, false)

local togState = { }
function toggleFaction(thePlayer, commandName)
	local factionDetails = getElementData(thePlayer, "faction")

	local organizedTable = {}
	for i, k in pairs(factionDetails) do
		organizedTable[k.count] = i
	end

	if commandName == "togglef" or commandName == "togf" then
		commandName = "togf1"
	end

	local pF = organizedTable[tonumber(string.sub(commandName, 5)) or tonumber(string.sub(commandName, 8))]
	if not pF then return end

	local fL = exports.factions:hasMemberPermissionTo(thePlayer, pF, "toggle_chat")
	local theTeam = exports.factions:getFactionFromID(pF)
	local theTeamName = getTeamName(theTeam)

	if fL then
		if togState[pF] == false or not togState[pF] then
			togState[pF] = true
			outputChatBox("Faction chat is now disabled.", thePlayer)
			for index, arrayPlayer in ipairs( exports.pool:getPoolElementsByType( "player" ) ) do
				if isElement( arrayPlayer ) then
					if exports.factions:isPlayerInFaction(arrayPlayer, pF) and getElementData(thePlayer, "loggedin") == 1 then
						outputChatBox("((".. theTeamName .. ")) OOC Faction Chat Disabled", arrayPlayer, 255, 0, 0)
					end
				end
			end
		else
			togState[pF] = false
			outputChatBox("Faction chat is now enabled.", thePlayer)
			for index, arrayPlayer in ipairs( exports.pool:getPoolElementsByType( "player" ) ) do
				if isElement( arrayPlayer ) then
					if exports.factions:isPlayerInFaction(arrayPlayer, pF) and getElementData(thePlayer, "loggedin") == 1 then
						outputChatBox("((".. theTeamName .. ")) OOC Faction Chat Enabled", arrayPlayer, 0, 255, 0)
					end
				end
			end
		end
	end
end
addCommandHandler("togglef", toggleFaction)
addCommandHandler("togf", toggleFaction)
addCommandHandler("togglef1", toggleFaction)
addCommandHandler("togf1", toggleFaction)
addCommandHandler("togglef2", toggleFaction)
addCommandHandler("togf2", toggleFaction)
addCommandHandler("togglef3", toggleFaction)
addCommandHandler("togf3", toggleFaction)
addCommandHandler("togglef4", toggleFaction)
addCommandHandler("togf4", toggleFaction)
addCommandHandler("togglef5", toggleFaction)
addCommandHandler("togf5", toggleFaction)

function toggleFactionSelf(thePlayer, commandName)
	local logged = getElementData(thePlayer, "loggedin")

	if(logged==1) then
		local factionDetails = getElementData(thePlayer, "faction")

		local organizedTable = {}
		for i, k in pairs(factionDetails) do
			organizedTable[k.count] = i
		end

		if commandName == "togglefaction" or commandName == "togfaction" then
			commandName = "togfaction1"
		end

		local pF = organizedTable[tonumber(string.sub(commandName, 14)) or tonumber(string.sub(commandName, 11))]
		if not pF then return end

		local teamName = exports.factions:getFactionName(pF)
		local factionBlocked = getElementData(thePlayer, "chat-system:blockF"..pF)
		if (factionBlocked==1) then
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "chat-system:blockF"..pF, 0, false)
			outputChatBox("((".. teamName ..")) Faction chat is now enabled for yourself.", thePlayer, 0, 255, 0)
		else
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "chat-system:blockF"..pF, 1, false)
			outputChatBox("((".. teamName ..")) Faction chat is now disabled for yourself.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("togglefaction", toggleFactionSelf)
addCommandHandler("togfaction", toggleFactionSelf)
addCommandHandler("togglefaction1", toggleFactionSelf)
addCommandHandler("togfaction1", toggleFactionSelf)
addCommandHandler("togglefaction2", toggleFactionSelf)
addCommandHandler("togfaction2", toggleFactionSelf)
addCommandHandler("togglefaction3", toggleFactionSelf)
addCommandHandler("togfaction3", toggleFactionSelf)
addCommandHandler("togglefaction4", toggleFactionSelf)
addCommandHandler("togfaction4", toggleFactionSelf)
addCommandHandler("togglefaction5", toggleFactionSelf)
addCommandHandler("togfaction5", toggleFactionSelf)

function factionOOC(thePlayer, commandName, ...)
	local logged = getElementData(thePlayer, "loggedin")

	if (logged==1) then
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Message]", thePlayer, 255, 194, 14)
		else
			local playerName = getPlayerName(thePlayer)
			local factionDetails = getElementData(thePlayer, "faction")

			if commandName == "f" then
				commandName = "f1"
			end
			local message = table.concat({...}, " ")

			local organizedTable = {}
			for i, k in pairs(factionDetails) do
				organizedTable[k.count] = i
			end

			local playerFaction = organizedTable[tonumber(string.sub(commandName, 2))]
			if not playerFaction then
				outputChatBox("You are not in this faction.", thePlayer)
				return
			end

			local theTeam = exports.factions:getFactionFromID(playerFaction)
			local theTeamName = getTeamName(theTeam)

			if (togState[playerFaction]) == true or not theTeam then
				return
			end
			local affectedElements = { }
			table.insert(affectedElements, theTeam)

			for index, arrayPlayer in ipairs( exports.pool:getPoolElementsByType( "player" ) ) do
				if isElement( arrayPlayer ) then
					if getElementData( arrayPlayer, "bigearsfaction" ) == theTeam then
						outputChatBox("((" .. theTeamName .. ")) " .. playerName .. ": " .. message, arrayPlayer, 3, 157, 157)
					elseif exports.factions:isPlayerInFaction(arrayPlayer, playerFaction) and getElementData(arrayPlayer, "loggedin") == 1 and getElementData(arrayPlayer, "chat-system:blockF"..playerFaction) ~= 1 then
						table.insert(affectedElements, arrayPlayer)
						outputChatBox("((" .. theTeamName .. ")) " .. playerName .. ": " .. message, arrayPlayer, 3, 237, 237)
					end
				end
			end
			exports.logs:dbLog(thePlayer, 11, affectedElements, message)
		end
	end
end
addCommandHandler("f1", factionOOC, false, false)
addCommandHandler("f", factionOOC, false, false)
addCommandHandler("f2", factionOOC, false, false)
addCommandHandler("f3", factionOOC, false, false)
addCommandHandler("f4", factionOOC, false, false)
addCommandHandler("f5", factionOOC, false, false)

--HQ CHAT FOR PD / MAXIME
function sfpdHq(thePlayer, commandName, ...)
	local factionID = exports.factions:getCurrentFactionDuty(thePlayer) or -1
	if factionID > 0 then
		theTeam = exports.factions:getFactionFromID(factionID)
		local fType = getElementData(theTeam, "type")
		if fType ~= 2 and fType ~= 3 and fType ~= 4 then
			return
		end
	else
		outputChatBox("You have to be on-duty to use this command.", thePlayer, 255, 0, 0)	
		return
	end

	local message = table.concat({...}, " ")

	if not exports.factions:hasMemberPermissionTo(thePlayer, factionID, "use_hq") then
		outputChatBox("You do not have permission to use this command.", thePlayer, 255, 0, 0)
	elseif #message == 0 then
		outputChatBox("SYNTAX: /hq [message]", thePlayer, 255, 194, 14)
	else

		local teamPlayers = exports.factions:getPlayersInFaction(factionID)
		local factionRanks = getElementData(theTeam, "ranks")
		local factionRankTitle = factionRanks[factionRank]
		local username = getPlayerName(thePlayer)

		for key, value in ipairs(teamPlayers) do
			triggerClientEvent (value, "playHQSound", getRootElement())
			outputChatBox("HQ: ".. (factionRankTitle or "").." ".. username ..": ".. message .."", value, 0, 197, 205)
		end
	end
end
addCommandHandler("hq", sfpdHq)

function factionLeaderOOC(thePlayer, commandName, ...)
	local logged = getElementData(thePlayer, "loggedin")

	if (logged==1) then
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Message]", thePlayer, 255, 194, 14)
		else
			local playerName = getPlayerName(thePlayer)
			local factionDetails = getElementData(thePlayer, "faction")

			if commandName == "fl" then
				commandName = "fl1"
			end

			local organizedTable = {}
			for i, k in pairs(factionDetails) do
				organizedTable[k.count] = i
			end

			local playerFaction = organizedTable[tonumber(string.sub(commandName, 3))]
			if not playerFaction then
				outputChatBox("You are not in this faction.", thePlayer)
				return
			end

			if not exports.factions:hasMemberPermissionTo(thePlayer, playerFaction, "use_fl") then
				outputChatBox("You are not a faction leader.", thePlayer, 255, 0, 0)
			else
				local theTeam = exports.factions:getFactionFromID(playerFaction)
				local theTeamName = getTeamName(theTeam)

				local affectedElements = { }
				table.insert(affectedElements, theTeam)
				local message = table.concat({...}, " ")

				for index, arrayPlayer in ipairs( getElementsByType( "player" ) ) do
					if isElement( arrayPlayer ) then
						local isIn, _ = exports.factions:isPlayerInFaction(arrayPlayer, playerFaction)
						if getElementData( arrayPlayer, "bigearsfaction" ) == theTeam then
							outputChatBox("((" .. theTeamName .. " Leader)) " .. playerName .. ": " .. message, arrayPlayer, 3, 157, 157)
						elseif isIn and getElementData(arrayPlayer, "loggedin") == 1 and getElementData(arrayPlayer, "chat-system:blockF"..playerFaction) ~= 1 and exports.factions:hasMemberPermissionTo(arrayPlayer, playerFaction, "use_fl") then
							table.insert(affectedElements, arrayPlayer)
							outputChatBox("((" .. theTeamName .. " Leader)) " .. playerName .. ": " .. message, arrayPlayer, 3, 180, 200)
						end
					end
				end
				exports.logs:dbLog(thePlayer, 11, affectedElements, "Leader: " .. message)
			end
		end
	end
end
addCommandHandler("fl", factionLeaderOOC, false, false)
addCommandHandler("fl1", factionLeaderOOC, false, false)
addCommandHandler("fl2", factionLeaderOOC, false, false)
addCommandHandler("fl3", factionLeaderOOC, false, false)
addCommandHandler("fl4", factionLeaderOOC, false, false)
addCommandHandler("fl5", factionLeaderOOC, false, false)

local goocTogState = false
function togGovOOC(thePlayer, theCommand)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		if (goocTogState == false) then
			outputChatBox("Government OOC has now been disabled.", thePlayer, 0, 255, 0)
			goocTogState = true
		elseif (goocTogState == true) then
			outputChatBox("Goverment OOC has been enabled.", thePlayer, 0, 255, 0)
			goocTogState = false
		else
			outputChatBox("[TG-G-C-ERR-545] Please report on mantis.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("toggovooc", togGovOOC)
addCommandHandler("toggooc", togGovOOC)

function togGovOOCSelf(thePlayer, theCommand)
	local logged = getElementData(thePlayer, "loggedin")
	local types = exports.factions:getPlayerFactionTypes(thePlayer)
	if types[2] or types[3] or types[4] and (logged==1) then
		local selfState = getElementData(thePlayer, "chat.togGovOOCSelf") or false
		if (selfState == false) then
			outputChatBox("Government OOC has now been disabled for yourself. Use "..tostring(theCommand).." to re-enable.", thePlayer, 0, 255, 0)
			setElementData(thePlayer, "chat.togGovOOCSelf", true)
		elseif (selfState == true) then
			outputChatBox("Goverment OOC has been enabled for yourself.", thePlayer, 0, 255, 0)
			setElementData(thePlayer, "chat.togGovOOCSelf", false)
		else
			outputChatBox("[TG-G-C-ERR-546] Please report on mantis.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("toggov", togGovOOCSelf)

-- /govooc
function govooc(thePlayer, commandName, ...)
	local logged = getElementData(thePlayer, "loggedin")
	local types = exports.factions:getPlayerFactionTypes(thePlayer)
	if types[2] or types[3] or types[4] and (logged==1) then
		local selfState = getElementData(thePlayer, "chat.togGovOOCSelf") or false
		if selfState then
			outputChatBox("You have previously toggled government OOC chat off for yourself. Use /toggov to re-enable.", thePlayer, 255, 0, 0)
			return
		end
		if not (...) then
			outputChatBox("SYNTAX: /gooc [message]", thePlayer, 255, 194, 14)
		else
			local affectedElements = { }
			local message = table.concat({...}, " ")
			local players = exports.pool:getPoolElementsByType("player")
			local username = getPlayerName(thePlayer)

			if goocTogState == true then
				outputChatBox("This chat is currently disabled.", thePlayer, 255, 0, 0)
				return
			end

			for k, arrayPlayer in ipairs(players) do
				local logged = getElementData(arrayPlayer, "loggedin")
				if logged==1 then
					local types = exports.factions:getPlayerFactionTypes(arrayPlayer)
					if types[2] or types[3] or types[4] then
						local selfTog = getElementData(arrayPlayer, "chat.togGovOOCSelf") or false
						if not selfTog then
							table.insert(affectedElements, arrayPlayer)
							outputChatBox("[Government OOC] " .. username .. ": " .. message.."", arrayPlayer, 216, 191, 216)
						end
					end
				end
			end
			exports.logs:dbLog(thePlayer, 11, affectedElements, "GOV OOC: " .. message)
		end
	end
end
addCommandHandler("gooc", govooc)

function setRadioChannel(thePlayer, commandName, slot, channel)
	slot = tonumber( slot )
	channel = tonumber( channel )

	if not channel then
		channel = slot
		slot = 1
	end

	if not (channel) then
		outputChatBox("SYNTAX: /" .. commandName .. " [Radio Slot] [Channel Number]", thePlayer, 255, 194, 14)
	else
		if (exports.global:hasItem(thePlayer, 6)) then
			local count = 0
			local items = exports['item-system']:getItems(thePlayer)
			for k, v in ipairs( items ) do
				if v[1] == 6 then
					count = count + 1
					if count == slot then
						if tonumber(v[2]) > 0 then
							if channel > 1 and channel < 1000000000 and hasChannelAccess(thePlayer, channel) then
								if exports['item-system']:updateItemValue(thePlayer, k, channel) then
									outputChatBox("You retuned your radio to channel #" .. channel .. ".", thePlayer)
									triggerEvent('sendAme', thePlayer, "retunes their radio.")
								end
							else
								outputChatBox("You can't tune your radio to that frequency!", thePlayer, 255, 0, 0)
							end
						else
							outputChatBox("Your radio is off. ((/toggleradio))", thePlayer, 255, 0, 0)
						end
						return
					end
				end
			end
			outputChatBox("You do not have that many radios.", thePlayer, 255, 0, 0)
		else
			outputChatBox("You do not have a radio!", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("tuneradio", setRadioChannel, false, false)

function toggleRadio(thePlayer, commandName, slot)
	if (exports.global:hasItem(thePlayer, 6)) then
		local slot = tonumber( slot )
		local items = exports['item-system']:getItems(thePlayer)
		local titemValue = false
		local count = 0
		for k, v in ipairs( items ) do
			if v[1] == 6 then
				if slot then
					count = count + 1
					if count == slot then
						titemValue = v[2]
						break
					end
				else
					titemValue = v[2]
					break
				end
			end
		end

		-- gender switch for /me
		local genderm = getElementData(thePlayer, "gender") == 1 and "her" or "his"

		if titemValue < 0 then
			outputChatBox("You turned your radio on.", thePlayer, 255, 194, 14)
			triggerEvent('sendAme', thePlayer, "turns " .. genderm .. " radio on.")
		else
			outputChatBox("You turned your radio off.", thePlayer, 255, 194, 14)
			triggerEvent('sendAme', thePlayer, "turns " .. genderm .. " radio off.")
		end

		local count = 0
		for k, v in ipairs( items ) do
			if v[1] == 6 then
				if slot then
					count = count + 1
					if count == slot then
						exports['item-system']:updateItemValue(thePlayer, k, ( titemValue < 0 and 1 or -1 ) * math.abs( v[2] or 1))
						break
					end
				else
					exports['item-system']:updateItemValue(thePlayer, k, ( titemValue < 0 and 1 or -1 ) * math.abs( v[2] or 1))
				end
			end
		end
	else
		outputChatBox("You do not have a radio!", thePlayer, 255, 0, 0)
	end
end
addCommandHandler("toggleradio", toggleRadio, false, false)

-- Admin chat
function adminChat(thePlayer, commandName, ...)
	local logged = getElementData(thePlayer, "loggedin")

	if(logged==1) and (exports.integration:isPlayerTrialAdmin(thePlayer))  then
		if not (...) then
			outputChatBox("SYNTAX: /a [Message]", thePlayer, 255, 194, 14)
		else
			local affectedElements = { }
			local message = table.concat({...}, " ")
			local players = exports.pool:getPoolElementsByType("player")
			local username = getPlayerName(thePlayer)
			local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
			local account = getPlayerAccount(thePlayer)
			local playerid = getElementData(thePlayer, "playerid")
			local dude = getElementData(thePlayer, "account:username") -- Thats the right one ;)
			for k, arrayPlayer in ipairs(players) do
				local logged = getElementData(arrayPlayer, "loggedin")
				local hiddena = getElementData(arrayPlayer, "hidea") or "false"

				if(exports.integration:isPlayerTrialAdmin(arrayPlayer)) and (logged==1) and (hiddena ~= "true") then
					table.insert(affectedElements, arrayPlayer)
					outputChatBox("[ADM] ("..playerid..") ".. adminTitle .." " .. username .. " (".. dude .."): " .. message, arrayPlayer, 51, 255, 102)
				end
			end
			exports.logs:dbLog(thePlayer, 3, affectedElements, message)
		end
	end
end
addCommandHandler("a", adminChat, false, false)

addCommandHandler("a", adminChat, false, false)



function leadAdminChat(thePlayer, commandName, ...)
	local logged = getElementData(thePlayer, "loggedin")

	if(logged==1) and (exports.integration:isPlayerLeadAdmin(thePlayer)) then
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Message]", thePlayer, 255, 194, 14)
		else
			local affectedElements = { }
			local message = table.concat({...}, " ")
			local players = exports.pool:getPoolElementsByType("player")
			local playerid = getElementData(thePlayer, "playerid")
			local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
			local accountName = getElementData(thePlayer, "account:username")
			for k, arrayPlayer in ipairs(players) do
				local logged = getElementData(arrayPlayer, "loggedin")
				if (exports.integration:isPlayerLeadAdmin(arrayPlayer)) and (logged==1) then
					table.insert(affectedElements, arrayPlayer)
					outputChatBox("[UAT] ("..playerid..") " ..adminTitle .. " "..accountName.. ": " .. message, arrayPlayer, 204, 102, 255)
				end
			end
			exports.logs:dbLog(thePlayer, 2, affectedElements, message)
		end
	end
end

addCommandHandler("l", leadAdminChat, false, false)
addCommandHandler("uat", leadAdminChat, false, false)

-- Misc
local function sortTable( a, b )
	if b[2] < a[2] then
		return true
	end

	if b[2] == a[2] and b[4] > a[4] then
		return true
	end

	return false
end

--[[
function showGMs(thePlayer, commandName)
	local logged = getElementData(thePlayer, "loggedin")

	if(logged==1) then
		local players = exports.global:getGameMasters()
		local counter = 0

		admins = {}
		outputChatBox("GAMEMASTERS:", thePlayer, 255, 255, 255)
		for k, arrayPlayer in ipairs(players) do
			local logged = getElementData(arrayPlayer, "loggedin")

			if logged == 1 then
				if exports.integration:isPlayerSupporter(arrayPlayer) then
					admins[ #admins + 1 ] = { arrayPlayer, getElementData( arrayPlayer, "account:gmlevel" ), getElementData( arrayPlayer, "duty_supporter" ), getPlayerName( arrayPlayer ) }
				end
			end
		end

		table.sort( admins, sortTable )

		for k, v in ipairs(admins) do
			arrayPlayer = v[1]
			local adminTitle = exports.global:getPlayerGMTitle(arrayPlayer)

			--if exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) then
				v[4] = v[4] .. " (" .. tostring(getElementData(arrayPlayer, "account:username")) .. ")"
			--end

			if(v[3] == true)then
				outputChatBox("-    " .. tostring(adminTitle) .. " " .. v[4].." - On Duty", thePlayer, 0, 200, 10)
			else
				outputChatBox("-    " .. tostring(adminTitle) .. " " .. v[4].." - Off Duty", thePlayer, 100, 100, 100)
			end
		end

		if #admins == 0 then
			outputChatBox("-    Currently no game masters online.", thePlayer)
		end
		outputChatBox("Use /admins to see a list of administrators.", thePlayer)
	end
end
addCommandHandler("gms", showGMs, false, false)
]]

-- Admin chat
function gmChat(thePlayer, commandName, ...)
	local logged = getElementData(thePlayer, "loggedin")

	if(logged==1) and (exports.integration:isPlayerTrialAdmin(thePlayer)  or exports.integration:isPlayerSupporter(thePlayer))  then
		if not (...) then
			outputChatBox("SYNTAX: /".. commandName .. " [Message]", thePlayer, 255, 194, 14)
		else
			if getElementData(thePlayer, "hideg") then
				setElementData(thePlayer, "hideg", false)
				outputChatBox("Gamemaster Chat - SHOWING",thePlayer)
			end
			local affectedElements = { }
			local message = table.concat({...}, " ")
			local players = exports.pool:getPoolElementsByType("player")
			local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
			local playerid = getElementData(thePlayer, "playerid")
			local accountName = getElementData(thePlayer, "account:username")
			for k, arrayPlayer in ipairs(players) do
				local logged = getElementData(arrayPlayer, "loggedin")
				if logged==1 and (exports.integration:isPlayerTrialAdmin(arrayPlayer) or exports.integration:isPlayerSupporter(arrayPlayer)) then
					local hideg = getElementData(arrayPlayer, "hideg")
					if hideg then
						local string = string.lower(message)
						local account = string.lower(getElementData(arrayPlayer, "account:username"))
						if string.find(string, account) then
							table.insert(affectedElements, arrayPlayer)
							triggerClientEvent ( "playNudgeSound", arrayPlayer, "Meantioned in /g chat", "info")
							outputChatBox("Mentioned in /g chat - "..accountName..": "..message, arrayPlayer)
						end
					else
						table.insert(affectedElements, arrayPlayer)
						outputChatBox("[SUP] ("..playerid..") "..adminTitle .. " " .. accountName..": " .. message, arrayPlayer,  255, 100, 150)
					end
				end
			end
			exports.logs:dbLog(thePlayer, 24, affectedElements, message)
		end
	end
end
addCommandHandler("g", gmChat, false, false)

function toggleAdminChat(thePlayer, commandName)
	local logged = getElementData(thePlayer, "loggedin")
	if logged==1 and exports.integration:isPlayerLeadAdmin(thePlayer) then
		local hidea = getElementData(thePlayer, "hidea")
		if not hidea or hidea == "false" then
			setElementData(thePlayer, "hidea", "true")
			outputChatBox("Admin Chat stopped showing on your screen, /toga again to enable it.",thePlayer, 0,255,0)
		elseif hidea=="true" then
			setElementData(thePlayer, "hidea", "false")
			outputChatBox("Admin Chat started showing on your screen, /toga again to disable it.",thePlayer, 0,255,0)
		end
	end
end
addCommandHandler("toga", toggleAdminChat, false, false)
addCommandHandler("togglea", toggleAdminChat, false, false)

function toggleGMChat(thePlayer, commandName)
	local logged = getElementData(thePlayer, "loggedin")
	if logged==1 and (exports["integration"]:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer)) then
		local hideg = getElementData(thePlayer, "hideg") or false
		setElementData(thePlayer, "hideg", not hideg)
		outputChatBox("Gamemaster Chat - "..(hideg and "SHOWING" or "HIDDEN").." /togg to toggle it.",thePlayer)
	end
end
addCommandHandler("togg", toggleGMChat, false, false)
addCommandHandler("toggleg", toggleGMChat, false, false)


function toggleOOC(thePlayer, commandName)
	local logged = getElementData(thePlayer, "loggedin")

	if(logged==1) and (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		local players = exports.pool:getPoolElementsByType("player")
		local oocEnabled = exports.global:getOOCState()
		if (commandName == "togooc") then
			if (oocEnabled==0) then
				exports.global:setOOCState(1)

				for k, arrayPlayer in ipairs(players) do
					local logged = getElementData(arrayPlayer, "loggedin")

					if	(logged==1) then
						outputChatBox("OOC Chat Enabled by Admin.", arrayPlayer, 0, 255, 0)
					end
				end
			elseif (oocEnabled==1) then
				exports.global:setOOCState(0)

				for k, arrayPlayer in ipairs(players) do
					local logged = getElementData(arrayPlayer, "loggedin")

					if	(logged==1) then
						outputChatBox("OOC Chat Disabled by Admin.", arrayPlayer, 255, 0, 0)
					end
				end
			end
		elseif (commandName == "stogooc") then
			if (oocEnabled==0) then
				exports.global:setOOCState(1)

				for k, arrayPlayer in ipairs(players) do
					local logged = getElementData(arrayPlayer, "loggedin")
					local admin = getElementData(arrayPlayer, "admin_level")

					if	(logged==1) and (tonumber(admin)>0)then
						outputChatBox("OOC Chat Enabled Silently by Admin " .. getPlayerName(thePlayer) .. ".", arrayPlayer, 0, 255, 0)
					end
				end
			elseif (oocEnabled==1) then
				exports.global:setOOCState(0)

				for k, arrayPlayer in ipairs(players) do
					local logged = getElementData(arrayPlayer, "loggedin")
					local admin = getElementData(arrayPlayer, "admin_level")

					if	(logged==1) and (tonumber(admin)>0)then
						outputChatBox("OOC Chat Disabled Silently by Admin " .. getPlayerName(thePlayer) .. ".", arrayPlayer, 255, 0, 0)
					end
				end
			end
		end
	end
end

addCommandHandler("togooc", toggleOOC, false, false)
addCommandHandler("stogooc", toggleOOC, false, false)

function togglePM(thePlayer, commandName)
	local logged = getElementData(thePlayer, "loggedin")

	local hasPerk, value = exports.donators:hasPlayerPerk(thePlayer, 1)
	if logged~=1 then
		return false
	end

	if hasPerk or (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerFMTLeader(thePlayer)) then
		if tonumber(value)== 1 then
			--outputChatBox("PM's are now enabled.", thePlayer, 0, 255, 0)
			exports.donators:updatePerkValue(thePlayer, 1, 0)
		else
			--outputChatBox("PM's are now disabled.", thePlayer, 255, 0, 0)
			exports.donators:updatePerkValue(thePlayer, 1, 1)
		end
	else
		outputChatBox("You don't have this perk activated. Please visit OwlGaming store under F10 menu.", thePlayer)
	end
end
addEvent("chat:togpm", true)
addEventHandler("chat:togpm", root, togglePM)
addCommandHandler("togpm", togglePM)
addCommandHandler("togglepm", togglePM)

function toggleAds(thePlayer, commandName)
	if getElementData(thePlayer, "loggedin") ~= 1 then
		return false
	end
	local hasPerk, value = exports.donators:hasPlayerPerk(thePlayer, 2)

	if hasPerk then
		if tonumber(value) == 1 then --if ads is disabled
			exports.donators:updatePerkValue(thePlayer, 2, 0)
		else
			exports.donators:updatePerkValue(thePlayer, 2, 1)
		end
	else
		outputChatBox("You don't have this perk activated. Please visit OwlGaming store under F10 menu.", thePlayer)
	end
end
addEvent("chat:togad", true)
addEventHandler("chat:togad", root, toggleAds)
addCommandHandler("togad", toggleAds)
addCommandHandler("togglead", toggleAds)

-- /pay
function payPlayer(thePlayer, commandName, targetPlayerNick, amount)
	if exports['freecam-tv']:isPlayerFreecamEnabled(thePlayer) then return end

	local logged = getElementData(thePlayer, "loggedin")

	if (logged==1) then
		if not (targetPlayerNick) or not (amount) or not tonumber(amount) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick] [Amount]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayerNick)

			if targetPlayer then
				local x, y, z = getElementPosition(thePlayer)
				local tx, ty, tz = getElementPosition(targetPlayer)

				local distance = getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)

				if (distance<=10 and not getElementData(targetPlayer, "reconx")) then
					amount = math.floor(math.abs(tonumber(amount)))

					local hoursplayed = getElementData(thePlayer, "hoursplayed")

					if (targetPlayer==thePlayer) then
						outputChatBox("You cannot pay money to yourself.", thePlayer, 255, 0, 0)
					elseif amount == 0 then
						outputChatBox("You need to enter an amount larger than 0.", thePlayer, 255, 0, 0)
					elseif (hoursplayed<5) and (amount>50) and not exports.integration:isPlayerTrialAdmin(thePlayer) and not exports.integration:isPlayerTrialAdmin(targetPlayer) and not exports.integration:isPlayerSupporter(thePlayer) and not exports.integration:isPlayerSupporter(targetPlayer) then
						outputChatBox("You must play atleast 5 hours before transferring over $50.", thePlayer, 255, 0, 0)
					elseif exports.global:hasMoney(thePlayer, amount) then
						if hoursplayed < 5 and not exports.integration:isPlayerTrialAdmin(targetPlayer) and not exports.integration:isPlayerTrialAdmin(thePlayer) and not exports.integration:isPlayerSupporter(targetPlayer) and not exports.integration:isPlayerSupporter(thePlayer) then
							local totalAmount = ( getElementData(thePlayer, "payAmount") or 0 ) + amount
							if totalAmount > 200 then
								outputChatBox( "You can only /pay $200 per five minutes. /report for an admin to transfer a larger amount of cash.", thePlayer, 255, 0, 0 )
								return
							end
							exports.anticheat:changeProtectedElementDataEx(thePlayer, "payAmount", totalAmount, false)
							setTimer(
								function(thePlayer, amount)
									if isElement(thePlayer) then
										local totalAmount = ( getElementData(thePlayer, "payAmount") or 0 ) - amount
										exports.anticheat:changeProtectedElementDataEx(thePlayer, "payAmount", totalAmount <= 0 and false or totalAmount, false)
									end
								end,
								300000, 1, thePlayer, amount
							)
						end
						exports.logs:dbLog(thePlayer, 25, targetPlayer, "PAY " .. amount)

						if (hoursplayed<5) then
							exports.global:sendMessageToAdmins("AdmWarn: New Player '" .. getPlayerName(thePlayer) .. "' transferred $" .. exports.global:formatMoney(amount) .. " to '" .. targetPlayerName .. "'.")
						end

						-- DEAL!
						exports.global:takeMoney(thePlayer, amount)
						exports.global:giveMoney(targetPlayer, amount)

						local gender = getElementData(thePlayer, "gender")
						local genderm = "his"
						if (gender == 1) then
							genderm = "her"
						end
						triggerEvent('sendAme', thePlayer, "takes some dollar notes from " .. genderm .. " wallet and gives them to " .. targetPlayerName .. ".")
						outputChatBox("You gave $" .. exports.global:formatMoney(amount) .. " to " .. targetPlayerName .. ".", thePlayer)
						outputChatBox(getPlayerName(thePlayer) .. " gave you $" .. exports.global:formatMoney(amount) .. ".", targetPlayer)

						exports.global:applyAnimation(thePlayer, "DEALER", "shop_pay", 4000, false, true, true)
					else
						outputChatBox("You do not have enough money.", thePlayer, 255, 0, 0)
					end
				else
					outputChatBox("You are too far away from " .. targetPlayerName .. ".", thePlayer, 255, 0, 0)
				end
			end
		end
	end
end
addCommandHandler("pay", payPlayer, false, false)

function removeAnimation(thePlayer)
	exports.global:removeAnimation(thePlayer)
end

-- /w(hisper)
function localWhisper(thePlayer, commandName, targetPlayerNick, ...)
	if exports['freecam-tv']:isPlayerFreecamEnabled(thePlayer) then return end

	local logged = tonumber(getElementData(thePlayer, "loggedin"))

	if (logged==1) then
		if not (targetPlayerNick) or not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick / ID] [Message]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayerNick)

			if targetPlayer then
				local interior = getElementInterior(thePlayer)
				local dimension = getElementDimension(thePlayer)
				local targetPlayerDimension = getElementDimension(targetPlayer)
				local targetPlayerInterior = getElementInterior(targetPlayer)
				if (targetPlayerDimension==dimension) and (targetPlayerInterior==interior) then
					local x, y, z = getElementPosition(thePlayer)
					local tx, ty, tz = getElementPosition(targetPlayer)
					if (getDistanceBetweenPoints3D(x, y, z, tx, ty, tz)<3) then
						local name = getPlayerName(thePlayer)
						local message = table.concat({...}, " ")
						exports.logs:dbLog(thePlayer, 21, targetPlayer, message)
						message = trunklateText( thePlayer, message )


						local language, languagename = getCurrentLanguage(thePlayer, commandName)
						if language == 0 then
							return
						end

						message2 = trunklateText( targetPlayer, message2 )
						local message2 = call(getResourceFromName("language-system"), "applyLanguage", thePlayer, targetPlayer, message, language)

						triggerEvent('sendAme', thePlayer, "whispers to " .. targetPlayerName .. ".")
						local r, g, b = 255, 255, 255
						local focus = getElementData(thePlayer, "focus")
						if type(focus) == "table" then
							for player, color in pairs(focus) do
								if player == thePlayer then
									r, g, b = unpack(color)
								end
							end
						end
						outputChatBox("[" .. languagename .. "] " .. name .. " whispers: " .. message, thePlayer, r, g, b)
						local r, g, b = 255, 255, 255
						local focus = getElementData(targetPlayer, "focus")
						if type(focus) == "table" then
							for player, color in pairs(focus) do
								if player == thePlayer then
									r, g, b = unpack(color)
								end
							end
						end
						outputChatBox("[" .. languagename .. "] " .. name .. " whispers: " .. message2, targetPlayer, r, g, b)
						for i,p in ipairs(getElementsByType( "player" )) do
							--if (getElementData(p, "duty_admin") == 1) then
								if p ~= targetPlayer and p ~= thePlayer then
									local nearbyPlayerDimension = getElementDimension(p)
									local nearbyPlayerInterior = getElementInterior(p)
									if (nearbyPlayerDimension==dimension) and (nearbyPlayerInterior==interior) then
										local ax, ay, az = getElementPosition(p)
										if (getDistanceBetweenPoints3D(x, y, z, ax, ay, az)<4) then
											local playerVeh = getPedOccupiedVehicle( thePlayer )
											local targetVeh = getPedOccupiedVehicle( targetPlayer )
											local pVeh = getPedOccupiedVehicle( p )
											if playerVeh then
												if pVeh then
													if pVeh==playerVeh then
														outputChatBox("[" .. languagename .. "] " .. name .. " whispers to " .. getPlayerName(targetPlayer):gsub("_"," ") .. ": " .. message2, p, 255, 255, 255)
													end
												end
											else
												outputChatBox("[" .. languagename .. "] " .. name .. " whispers to " .. getPlayerName(targetPlayer):gsub("_"," ") .. ": " .. message2, p, 255, 255, 255)
											end
										end
									end
								end
							--end
						end
					else
						outputChatBox("You are too far away from " .. targetPlayerName .. ".", thePlayer, 255, 0, 0)
					end
				else
					outputChatBox("You are too far away from " .. targetPlayerName .. ".", thePlayer, 255, 0, 0)
				end
			end
		end
	end
end
addLocalizedCommandHandler("w", localWhisper, false, false)

-- /c(lose)
function localClose(thePlayer, commandName, ...)
	if exports['freecam-tv']:isPlayerFreecamEnabled(thePlayer) then return end

	local logged = tonumber(getElementData(thePlayer, "loggedin"))

	if (logged==1) and not isPedDead(thePlayer) then
		if not (...) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Message]", thePlayer, 255, 194, 14)
		else
			local affectedElements = { }
			local name = getPlayerName(thePlayer)
			local message = table.concat({...}, " ")
			message = trunklateText( thePlayer, message )


			local language, languagename = getCurrentLanguage(thePlayer, commandName)
			if language == 0 then
				return
			end

			local playerCar = getPedOccupiedVehicle(thePlayer)
			local interior = getElementInterior(thePlayer)
			local dimension = getElementDimension(thePlayer)
			for index, targetPlayers in ipairs( getElementsByType( "player" ) ) do
				local nearbyPlayerDimension = getElementDimension(targetPlayers)
				local nearbyPlayerInterior = getElementInterior(targetPlayers)
				if (nearbyPlayerDimension==dimension) and (nearbyPlayerInterior==interior) then
					if getElementDistance( thePlayer, targetPlayers ) < 3 then
						local message2 = message
						if targetPlayers ~= thePlayer then
							message2 = call(getResourceFromName("language-system"), "applyLanguage", thePlayer, targetPlayers, message, language)
							message2 = trunklateText( targetPlayers, message2 )
						end
						local r, g, b = 255, 255, 255
						local focus = getElementData(targetPlayers, "focus")
						if type(focus) == "table" then
							for player, color in pairs(focus) do
								if player == thePlayer then
									r, g, b = unpack(color)
								end
							end
						end
						local pveh = getPedOccupiedVehicle(targetPlayers)
						if playerCar then
							if not exports.vehicle:isVehicleWindowUp(playerCar) then
								if pveh then
									if playerCar == pveh then
										table.insert(affectedElements, targetPlayers)
										outputChatBox( " [" .. languagename .. "] " .. name .. " whispers: " .. message2, targetPlayers, r, g, b)
									elseif not (exports.vehicle:isVehicleWindowUp(pveh)) then
										table.insert(affectedElements, targetPlayers)
										outputChatBox( " [" .. languagename .. "] " .. name .. " whispers: " .. message2, targetPlayers, r, g, b)
									end
								else
									table.insert(affectedElements, targetPlayers)
									outputChatBox( " [" .. languagename .. "] " .. name .. " whispers: " .. message2, targetPlayers, r, g, b)
								end
							else
								if pveh then
									if pveh == playerCar then
										table.insert(affectedElements, targetPlayers)
										outputChatBox( " [" .. languagename .. "] " .. name .. " whispers: " .. message2, targetPlayers, r, g, b)
									end
								end
							end
						else
							if pveh then
								if playerCar then
									if playerCar == pveh then
										table.insert(affectedElements, targetPlayers)
										outputChatBox( " [" .. languagename .. "] " .. name .. " whispers: " .. message2, targetPlayers, r, g, b)
									end
								elseif not (exports.vehicle:isVehicleWindowUp(pveh)) then
									table.insert(affectedElements, targetPlayers)
									outputChatBox( " [" .. languagename .. "] " .. name .. " whispers: " .. message2, targetPlayers, r, g, b)
								end
							else
								table.insert(affectedElements, targetPlayers)
								outputChatBox( " [" .. languagename .. "] " .. name .. " whispers: " .. message2, targetPlayers, r, g, b)
							end
						end
					end
				end
			end
			exports.logs:dbLog(thePlayer, 22, affectedElements, languagename .. " "..message)
		end
	end
end
addLocalizedCommandHandler("c", localClose, false, false)

------------------
-- News Faction --
------------------
-- /tognews
function togNews(thePlayer, commandName)
	local logged = getElementData(thePlayer, "loggedin")

	if (logged==1) then
		local newsTog = getElementData(thePlayer, "tognews")

		if (newsTog~=1) then
			outputChatBox("/news disabled.", thePlayer, 255, 194, 14)
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "tognews", 1, false)
			exports.donators:updatePerkValue(thePlayer, 3, 1)
		else
			outputChatBox("/news enabled.", thePlayer, 255, 194, 14)
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "tognews", 0, false)
			exports.donators:updatePerkValue(thePlayer, 3, 0)
		end
	end
end
addCommandHandler("tognews", togNews, false, false)
addCommandHandler("togglenews", togNews, false, false)


-- /startinterview
function StartInterview(thePlayer, commandName, targetPartialPlayer)
	local logged = getElementData(thePlayer, "loggedin")
	if (logged==1) then
		local theTeam = getPlayerTeam(thePlayer)
		local factionType = getElementData(theTeam, "type")
		if exports.factions:isInFactionType(thePlayer, 6)then -- news faction
			if not (targetPartialPlayer) then
				outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick]", thePlayer, 255, 194, 14)
			else
				local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPartialPlayer)
				if targetPlayer then
					local targetLogged = getElementData(targetPlayer, "loggedin")
					if (targetLogged==1) then
						if(getElementData(targetPlayer,"interview"))then
							outputChatBox("This player is already being interviewed.", thePlayer, 255, 0, 0)
						else
							exports.anticheat:changeProtectedElementDataEx(targetPlayer, "interview", true, false)
							local playerName = getPlayerName(thePlayer)
							outputChatBox(playerName .." has offered you for an interview.", targetPlayer, 0, 255, 0)
							outputChatBox("((Use /i to talk during the interview.))", targetPlayer, 0, 255, 0)
							local NewsFaction = exports.factions:getPlayersInFaction(20)
							for key, value in ipairs(NewsFaction) do
								outputChatBox("((".. playerName .." has invited " .. targetPlayerName .. " for an interview.))", value, 0, 255, 0)
							end
						end
					end
				end
			end
		end
	end
end
addCommandHandler("interview", StartInterview, false, false)

-- /endinterview
function endInterview(thePlayer, commandName, targetPartialPlayer)
	local logged = getElementData(thePlayer, "loggedin")
	if (logged==1) then
		if exports.factions:isInFactionType(thePlayer, 6)then -- news faction
			if not (targetPartialPlayer) then
				outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick]", thePlayer, 255, 194, 14)
			else
				local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPartialPlayer)
				if targetPlayer then
					local targetLogged = getElementData(targetPlayer, "loggedin")
					if (targetLogged==1) then
						if not(getElementData(targetPlayer,"interview"))then
							outputChatBox("This player is not being interviewed.", thePlayer, 255, 0, 0)
						else
							exports.anticheat:changeProtectedElementDataEx(targetPlayer, "interview", false, false)
							local playerName = getPlayerName(thePlayer)
							outputChatBox(playerName .." has ended your interview.", targetPlayer, 255, 0, 0)

							local NewsFaction = exports.factions:getPlayersInFaction(20)
							for key, value in ipairs(NewsFaction) do
								outputChatBox("((".. playerName .." has ended " .. targetPlayerName .. "'s interview.))", value, 255, 0, 0)
							end
						end
					end
				end
			end
		end
	end
end
addCommandHandler("endinterview", endInterview, false, false)

-- /i
function interviewChat(thePlayer, commandName, ...)
	local logged = getElementData(thePlayer, "loggedin")
	if (logged==1) then
		if(getElementData(thePlayer, "interview"))then
			if not(...)then
				outputChatBox("SYNTAX: /" .. commandName .. "[Message]", thePlayer, 255, 194, 14)
			else
				local message = table.concat({...}, " ")
				local name = getPlayerName(thePlayer)

				local finalmessage = "[NEWS] Interview Guest " .. name .." says: ".. message
				if exports.factions:isInFactionType(thePlayer, 6)then -- news faction
					finalmessage = "[NEWS] " .. name .." says: ".. message
				end

				for key, value in ipairs(exports.pool:getPoolElementsByType("player")) do
					if (getElementData(value, "loggedin")==1) then
						if not (getElementData(value, "tognews")==1) then
							outputChatBox(finalmessage, value, 200, 100, 200)
						end
					end
				end
				exports.logs:dbLog(thePlayer, 23, thePlayer, "NEWS " .. message)
				exports.global:giveMoney(exports.factions:getFactionFromID(20), 200)
			end
		end
	end
end
addCommandHandler("i", interviewChat, false, false)

-- /charity
function charityCash(thePlayer, commandName, amount)
	if not (amount) then
		outputChatBox("SYNTAX: /" .. commandName .. " [Amount]", thePlayer, 255, 194, 14)
	else
		local donation = tonumber(amount)
		if (donation<=0) then
			outputChatBox("You must enter an amount greater than zero.", thePlayer, 255, 0, 0)
		else
			if not exports.global:takeMoney(thePlayer, donation) then
				outputChatBox("You don't have that much money to remove.", thePlayer, 255, 0, 0)
			else
				outputChatBox("You have donated $".. exports.global:formatMoney(donation) .." to charity.", thePlayer, 0, 255, 0)
				exports.global:sendMessageToAdmins("AdmWrn: " ..getPlayerName(thePlayer).. " charity'd $" ..exports.global:formatMoney(donation))
				exports.logs:dbLog(thePlayer, 25, thePlayer, "CHARITY $" .. amount)
			end
		end
	end
end
addCommandHandler("charity", charityCash, false, false)

-- /bigears
function bigEars(thePlayer, commandName, targetPlayerNick)
	if exports.integration:isPlayerTrialAdmin(thePlayer) then
		local current = getElementData(thePlayer, "bigears")
		if not current and not targetPlayerNick then
			outputChatBox("SYNTAX: /" .. commandName .. " [player]", thePlayer, 255, 194, 14)
		elseif current and not targetPlayerNick then
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "bigears", false, false)
			outputChatBox("Big Ears turned off.", thePlayer, 255, 0, 0)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayerNick)

			if targetPlayer then
				outputChatBox("Now Listening to " .. targetPlayerName .. ".", thePlayer, 0, 255, 0)
				exports.logs:dbLog(thePlayer, 4, targetPlayer, "BIGEARS "..targetPlayerName)
				exports.anticheat:changeProtectedElementDataEx(thePlayer, "bigears", targetPlayer, false)
			end
		end
	end
end
addCommandHandler("bigears", bigEars)

function removeBigEars()
	for key, value in pairs( getElementsByType( "player" ) ) do
		if isElement( value ) and getElementData( value, "bigears" ) == source then
			exports.anticheat:changeProtectedElementDataEx( value, "bigears", false, false )
			outputChatBox("Big Ears turned off (Player Left).", value, 255, 0, 0)
		end
	end
end
addEventHandler( "onPlayerQuit", getRootElement(), removeBigEars)

function bigEarsFaction(thePlayer, commandName, factionID)
	if exports.integration:isPlayerAdmin(thePlayer) then
		factionID = tonumber( factionID )
		local current = getElementData(thePlayer, "bigearsfaction")
		if not current and not factionID then
			outputChatBox("SYNTAX: /" .. commandName .. " [faction id]", thePlayer, 255, 194, 14)
		elseif current and not factionID then
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "bigearsfaction", false, false)
			outputChatBox("Big Ears turned off.", thePlayer, 255, 0, 0)
		else
			local team = exports.pool:getElement("team", factionID)
			if not team then
				outputChatBox("No faction with that ID found.", thePlayer, 255, 0, 0)
			else
				outputChatBox("Now Listening to " .. getTeamName(team) .. " OOC Chat.", thePlayer, 0, 255, 0)
				exports.anticheat:changeProtectedElementDataEx(thePlayer, "bigearsfaction", team, false)
				exports.logs:dbLog(thePlayer, 4, team, "BIGEARSF "..getTeamName(team))
			end
		end
	end
end
addCommandHandler("bigearsf", bigEarsFaction)

function disableMsg(message, player)
	cancelEvent()
	-- send it using 	our own PM etiquette instead
	pmPlayer(source, "pm", player, message)
end
addEventHandler("onPlayerPrivateMessage", getRootElement(), disableMsg)

-- /focus
function focus(thePlayer, commandName, targetPlayer, r, g, b)
	local focus = getElementData(thePlayer, "focus")
	if targetPlayer then
		local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
		if targetPlayer then
			if type(focus) ~= "table" then
				focus = {}
			end

			if focus[targetPlayer] and not r then
				outputChatBox( "You stopped highlighting " .. string.format("#%02x%02x%02x", unpack( focus[targetPlayer] ) ) .. targetPlayerName .. "#ffc20e.", thePlayer, 255, 194, 14, true )
				focus[targetPlayer] = nil
			else
				color = {tonumber(r) or math.random(63,255), tonumber(g) or math.random(63,255), tonumber(b) or math.random(63,255)}
				for _, v in ipairs(color) do
					if v < 0 or v > 255 then
						outputChatBox("Invalid Color: " .. v, thePlayer, 255, 0, 0)
						return
					end
				end

				focus[targetPlayer] = color
				outputChatBox( "You are now highlighting on " .. string.format("#%02x%02x%02x", unpack( focus[targetPlayer] ) ) .. targetPlayerName .. "#00ff00.", thePlayer, 0, 255, 0, true )
			end
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "focus", focus, false)
		end
	else
		if type(focus) == "table" then
			outputChatBox( "You are watching: ", thePlayer, 255, 194, 14 )
			for player, color in pairs( focus ) do
				outputChatBox( "  " .. getPlayerName( player ):gsub("_", " "), thePlayer, unpack( color ) )
			end
		end
		outputChatBox( "To add someone, /" .. commandName .. " [player] [optional red/green/blue], to remove just /" .. commandName .. " [player] again.", thePlayer, 255, 194, 14)
	end
end
addCommandHandler("focus", focus)
addCommandHandler("highlight", focus)

addEventHandler("onPlayerQuit", root,
	function( )
		for k, v in ipairs( getElementsByType( "player" ) ) do
			if v ~= source then
				local focus = getElementData( v, "focus" )
				if focus and focus[source] then
					focus[source] = nil
					exports.anticheat:changeProtectedElementDataEx(v, "focus", focus, false)
				end
			end
		end
	end
)

-- START of /st and /togglest and /togst

function isPlayerStaff(thePlayer)
	if exports.integration:isPlayerSupporter(thePlayer) then return true end
	if exports.integration:isPlayerTrialAdmin(thePlayer) then return true end
	if exports.integration:isPlayerScripter(thePlayer) then return true end
	if exports.integration:isPlayerVCTMember(thePlayer) then return true end
	if exports.integration:isPlayerMappingTeamMember(thePlayer) then return true end
	if exports.integration:isPlayerFMTMember(thePlayer) then return true
	else
		return false
	end
end

function staffChat(thePlayer, commandName, ...)
	local logged = getElementData(thePlayer, "loggedin")

	if(logged==1) and isPlayerStaff(thePlayer)  then
		if not (...) then
			outputChatBox("SYNTAX: /".. commandName .. " [Message]", thePlayer, 255, 194, 14)
		else
			if getElementData(thePlayer, "hideStaffChat") then
				setElementData(thePlayer, "hideStaffChat", false)
				outputChatBox("Staff Chat - SHOWING",thePlayer)
			end
			local affectedElements = { }
			local message = table.concat({...}, " ")
			local players = exports.pool:getPoolElementsByType("player")
			local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
			local playerid = getElementData(thePlayer, "playerid")
			local accountName = getElementData(thePlayer, "account:username")
			for k, arrayPlayer in ipairs(players) do
				local logged = getElementData(arrayPlayer, "loggedin")
				if logged==1 and isPlayerStaff(arrayPlayer) then
					local hideStaffChat = getElementData(arrayPlayer, "hideStaffChat")
					if hideStaffChat then
						local string = string.lower(message)
						local account = string.lower(getElementData(arrayPlayer, "account:username"))
						if string.find(string, account) then
							table.insert(affectedElements, arrayPlayer)
							triggerClientEvent ( "playNudgeSound", arrayPlayer, "Meantioned in /st chat", "info")
							outputChatBox("Mentioned in /st chat - "..accountName..": "..message, arrayPlayer)
						end
					else
						table.insert(affectedElements, arrayPlayer)
						outputChatBox("[STAFF] "..exports.global:getPlayerFullIdentity(thePlayer)..": "..message, arrayPlayer, 153, 51, 255)
					end
				end
			end
			exports.logs:dbLog(thePlayer, 42, affectedElements, "Staff chat - Msg: "..message)
		end
	end
end
addCommandHandler( "st", staffChat, false, false)

function toggleStaffChat(thePlayer, commandName)
	local logged = getElementData(thePlayer, "loggedin")
	if logged==1 and isPlayerStaff(thePlayer) then
		local hideStaffChat = getElementData(thePlayer, "hideStaffChat") or false
		setElementData(thePlayer, "hideStaffChat", not hideStaffChat)
		outputChatBox("Staff Chat - "..(hideStaffChat and "SHOWING" or "HIDDEN").." /"..commandName.." to toggle it.",thePlayer)
	end
end
addCommandHandler("togglestaff", toggleStaffChat, false, false)
addCommandHandler("togst", toggleStaffChat, false, false)
addCommandHandler("togglest", toggleStaffChat, false, false)


-- END of /st and /togglest and /togst

function businessOOC(thePlayer, commandName, business, ...)
	local logged = getElementData(thePlayer, "loggedin")

	if (logged==1) then
		if not business then
			outputChatBox("SYNTAX: /" .. commandName .. " [Message]", thePlayer, 255, 194, 14)
			outputChatBox("OR SYNTAX: /" .. commandName .. " [Business] [Message]", thePlayer, 255, 194, 14)
		else
			local playerName = getPlayerName( thePlayer ):gsub( "_", " ")
			local message = table.concat({...}, " ")
			if tonumber( business ) then
				business = tonumber( business )
			else
				message = business .. ' ' .. message
				business = 1
			end

			local b = exports.business:getPlayerBusinesses( thePlayer ) or { }
			local b = b[ business ]
			if b then
				local affectedElements = { }


				for index, arrayPlayer in ipairs( getElementsByType( "player" ) ) do
					if isElement( arrayPlayer ) then
						if getElementData( arrayPlayer, "bigearsbusiness" ) == b then
							outputChatBox("((" .. exports.business:getBusinessName( b ) .. ")) " .. playerName .. ": " .. message, arrayPlayer, 3, 157, 157)
						elseif exports.business:isPlayerInBusiness( arrayPlayer, b ) and getElementData(arrayPlayer, "loggedin") == 1 and getElementData(arrayPlayer, "chat-system:blockB") ~= 1 then
							table.insert(affectedElements, arrayPlayer)
							outputChatBox("((" .. exports.business:getBusinessName( b ) .. ")) " .. playerName .. ": " .. message, arrayPlayer, 255, 150, 255)
						end
					end
				end
				exports.logs:dbLog(thePlayer, 41, affectedElements, message)
			else
				outputChatBox( 'You have no business in slot ' .. business .. '.', thePlayer, 255, 100, 100 )
			end
		end
	end
end
addCommandHandler("bu", businessOOC, false, false)

function toggleBusinessSelf(thePlayer, commandName)
	local logged = getElementData(thePlayer, "loggedin")

	if(logged==1) then
		local BusinessBlocked = getElementData(thePlayer, "chat-system:blockB")

		if (BusinessBlocked==1) then
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "chat-system:blockB", 0, false)
			outputChatBox("Business chat is now enabled for yourself.", thePlayer, 0, 255, 0)
		else
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "chat-system:blockB", 1, false)
			outputChatBox("Business chat is now disabled for yourself.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("togglebusinesschat", toggleBusinessSelf)
addCommandHandler("togglebusiness", toggleBusinessSelf)
addCommandHandler("togbusiness", toggleBusinessSelf)

local mir = {
	"You have the right to remain silent.",
	"Anything you say or do may be used against you in a court of law.",
	"You have the right to an attorney.",
	"If you cannot afford an attorney, one will be appointed for you.",
}

function pdmir(source)
	local factions = getElementData(source, "faction")
	if factions[1] or factions[50] then
		local languageslot = getElementData(source, "languages.current") or 1
		local language = getElementData(source, "languages.lang" .. languageslot)
		for k,v in ipairs(mir) do
			localIC(source, v, language)
		end
	end
end
addCommandHandler("mir", pdmir, false, false)
