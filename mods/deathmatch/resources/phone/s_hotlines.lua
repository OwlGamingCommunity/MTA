local easyHotlines = {
	[911] = {
		name = "Emergency Hotline",
		order = 5,
		factions = { 1, 2, 164 },
		require_radio = true,
		operator = "911 Operator",
		dialogue = {
			{
				q = "911 emergency, Which emergency service do you require?",
				as = "service",
				check = function(service)
					-- return which factions should receive the call
					local found, factions = checkService(service)
					return factions, found, "Sorry, I'm not sure what you mean."
				end
			},
			{ q = "Can you tell me your name please?", as = "name" },
			{ q = "Please state your emergency.", as = "emergency" },
			done = "Thanks for your call, we've dispatched a unit to your location."
		},
		done = function(caller, callstate, players)
			-- pick players depending on which service was dialled
			local players = collectReceivingPlayersForHotline { factions = callstate.service, require_radio = true }

			local zonelocation = string.gsub(exports.global:getElementZoneName(caller.element), "'", "''")
			local streetlocation = exports.gps:getPlayerStreetLocation(caller.element)

			local query = exports.mysql:query_insert_free("INSERT INTO `mdc_calls` (`caller`,`number`,`description`) VALUES ('" .. getElementData(caller.element, "dbid") .. "','" .. caller.phone .. "','" .. exports.mysql:escape_string(tostring(zonelocation) .. " - " .. callstate.emergency) .. "')")
			if query then

				log911("[911 Call] Player: " .. getPlayerName(caller.element) .. " || Situation: " .. callstate.emergency .. ", over.")
				players:send({
					"[RADIO] This is dispatch, we've got an emergency report from " .. callstate.name .. " (#" .. caller.phone .. "), over.",
					"[RADIO] Situation: '" .. callstate.emergency .. "', over.",
					streetlocation and ("[RADIO] Location: '" .. streetlocation .. " in " .. zonelocation .. "', out.") or ("[RADIO] Location: '" .. zonelocation .. "', out.")
				}, 0, 183, 239)
				players:beep()
			else
				caller:respond("There was an error processing your request. Try again later.")
			end
		end
	},
	[311] = {
		name = "LSPD Non-Emergency", -- name of the hotline shown on the client-side
		order = 10, -- sort order; smaller numbers are displayed first in the hotlines app on the client-side phone
		factions = { 1, 142, 50 }, -- which factions are going to receive notifications? this will later be used by .done; as players:send() will notify all players in those factions
		require_radio = true, -- to receive messages, players must have a turned-on radio
		operator = "LSPD Operator", -- name of the person responding to your calls
		dialogue = {
			{ q = "LSPD Hotline. Please state your location.", as = "location" },
			{ q = "Can you please describe the reason for your call?", as = "reason" },
			done = "Thanks for your call, we'll get in touch soon."
		},
		-- with the dialogue options above, callstate.location is the location and callstate.reason the reason.
		-- caller.element is the player who called, caller.phone is the player's phone number from which he called.
		-- players is simply a table of all players that should be notified, players:send a shortcut for outputChatBox'ing
		done = function(caller, callstate, players)
			players:send({
				"[RADIO] This is dispatch, We've got a report from #" .. caller.phone .. " via the #311 non-emergency line.",
				"[RADIO] Reason: '" .. callstate.reason .. "'.",
				"[RADIO] Location: '" .. callstate.location .. "'."
			}, 245, 40, 135)
		end
	},
	[411] = {
		name = "LSFD Non-Emergency",
		order = 20,
		factions = { 2 },
		require_radio = true,
		operator = "LSFD Operator",
		dialogue = {
			{ q = "LSFD Hotline. Please state your location.", as = "location" },
			{ q = "Can you please tell us the reason for your call?", as = "reason" },
			done = "Thanks for your call, we'll get in touch soon."
		},
		done = function(caller, callstate, players)
			players:send({
				"[RADIO] This is dispatch, We've got a report from #" .. caller.phone .. " via the #411 non-emergency line, over.",
				"[RADIO] Reason: '" .. callstate.reason .. "', over.",
				"[RADIO] Location: '" .. callstate.location .. "', out."
			}, 245, 40, 135)
		end
	},
	[511] = {
		name = "Los Santos Government",
		order = 30,
		factions = { 3 },
		require_radio = true,
		operator = "Gov Employee",
		dialogue = {
			{ q = "Government of Los Santos. How can we help you?", as = "reason" },
			done = "Thanks for your call."
		},
		done = function(caller, callstate, players)
			players:send({
				"[RADIO] This is LS Gov dispatch, we got a message from #" .. caller.phone .. ".",
				"[RADIO] Reason: '" .. callstate.reason .. "', over."
			}, 245, 40, 135)
		end
	},
	[711] = {
		name = "Report Stolen Vehicle",
		order = 2000,
		factions = { 1 },
		require_radio = true,
		operator = "Police Employee",
		dialogue = {
			{ q = "What is the VIN of the vehicle you would like to report stolen?", as = "vin", check = function(vin) return tonumber(vin), type(tonumber(vin)) == "number", "The VIN must be numeric." end }
		},
		done = function(caller, callstate, players)
			local query = exports.mysql:query("SELECT `stolen`, `owner`, `plate` FROM `vehicles` WHERE `id` = '" .. exports.mysql:escape_string(callstate.vin) .. "'")
			local row = exports.mysql:fetch_assoc(query)

			if row then
				if tonumber(row.owner) == getElementData(caller.element, "dbid") then
					if tonumber(row.stolen) == 0 then
						exports.mysql:update('vehicles', { stolen = 1 }, { id = callstate.vin })

						caller:respond("Thank you, we have marked that vehicle stolen.")
						players:send({
							"[RADIO] We got a vehicle reported stolen from #" .. caller.phone .. ".",
							"[RADIO] Vehicle VIN: '" .. callstate.vin .. "', Plate: '" .. row.plate .. "'"
						}, 245, 40, 135)
					else
						outputChatBox("Police Employee [Cellphone]: That vehicle has already been reported stolen, please contact 311 if the vehicle was found.", caller.element)
					end
				else
					caller:respond("You do not own the vehicle matching that VIN.")
				end
			else
				caller:respond("We could not find any vehicle matching that VIN.")
			end
		end
	},
	[7332] = {
		name = "San Andreas Network",
		order = 35,
		factions = { 20 },
		require_phone = true,
		operator = "SAN Worker",
		dialogue = {
			{ q = "Thanks for calling SAN. What message can I give through to our reporters?", as = "reason" },
			done = "Thanks for the message, we'll contact you back if needed."
		},
		done = function(caller, callstate, players)
			players:send("SMS from SAN: Message from " .. caller.phone .. ": " .. callstate.reason .. ".", 120, 255, 80)
		end
	},
	[9021] = {
		name = "Bureau of Traffic Services",
		order = 50,
		factions = { 4 },
		require_radio = true,
		operator = "Operator",
		dialogue = {
			{ q = "You've called the Bureau of Traffic Services. Please state your name.", as = "name" },
			{ q = "Can you describe the situation please?", as = "reason" },
			done = "Thanks for your call, we've dispatched a unit to your location.",
		},
		done = function(caller, callstate, players)
			local zonelocation = exports.global:getElementZoneName(caller.element)
			local streetlocation = exports.gps:getPlayerStreetLocation(caller.element)

			players:send({
				"[RADIO] This is dispatch, we've got an incident report from " .. callstate.name .. " (#" .. caller.phone .. "), via #9021 over.",
				"[RADIO] Situation: '" .. callstate.reason .. "', over.",
				streetlocation and ("[RADIO] Location: '" .. streetlocation .. " in " .. zonelocation .. "', out.") or ("[RADIO] Location: '" .. zonelocation .. "', out.")
			}, 0, 183, 239)
			players:beep()
		end,
		no_players = "Sorry, there are no units available. Call back later."
	},
	[8294] = {
		name = "Yellow Cab Co.",
		order = 40,
		operator = "Taxi Operator",
		job = { id = 2, vehicle_models = { 438, 420 } },
		dialogue = {
			{ q = "Yellow Cab Company here, where do you need a Taxi from?", as = "location" },
			done = "Alright then. We'll send a Taxi over."
		},
		done = function(caller, callstate, players)
			players:send("[RADIO] Taxi Operator Says: Units, we've got a fare from #" .. caller.phone .. ". They need a Taxi from " .. callstate.location .. ".", 0, 183, 239)
			players:beep()
		end,
		no_players = "Er', it would seem we don't have any Taxi's available in that area. Please try again later."
	},
	[2552] = {
		name = "RS Haul",
		operator = "RS Haul Operator",
		job = { id = 1 },
		require_phone = true,
		dialogue = {
			{ q = "RS Haul here. Please state your location.", as = "location" },
			done = "Thanks for your call, a truck of goods will be coming shortly."
		},
		done = function(caller, callstate, players)
			players:send("SMS from RS Haul: A customer has ordered a delivery at '" .. callstate.location .. "'. Please contact #" .. caller.phone .. " for details.", 120, 255, 80)
		end,
		no_players = "There is no trucker available at the moment, please try again later."
	},
	[211] = {
		name = "Superior Court",
		operator = "Operator",
		factions = { 50 },
		require_radio = true,
		dialogue = {
			{ q = "Superior Court of San Andreas, please state your name.", as = "name" },
			{ q = "What do you require?", as = "reason" },
			done = "Thanks for calling us, we'll get back to you as soon as possible."
		},
		done = function(caller, callstate, players)
			players:send({
				"[RADIO] This is dispatch, We've got a report from #" .. caller.phone .. " via the #211 hotline, over.",
				"[RADIO] Request: '" .. callstate.reason .. "', over.",
				"[RADIO] From: '" .. callstate.name .. "', out."
			}, 245, 40, 135)
		end
	},
	[5555] = {
		name = "Los Santos International Airport",
		order = 100,
		operator = "Operator",
		factions = { 47 },
		require_phone = true,
		dialogue = {
			{ q = "You've reached Los Santos International Airport. How may we help you?", as = "reason" },
			done = "Thanks for the message, we'll contact you back if needed."
		},
		done = function(caller, callstate, players)
			players:send("SMS from LSIA: Inquiry from #" .. caller.phone .. ": " .. callstate.reason .. ".", 120, 255, 80)
		end
	},
	[2200] = {
		name = "JGC",
		operator = "Receptionist",
		factions = { 74 },
		require_phone = true,
		dialogue = {
			{ q = "Welcome to JGC. Which company are you trying to reach?", as = "company" },
			{ q = "Alright. Can I get your name, please?", as = "name" },
			{ q = "Thanks. How can we help you?", as = "reason" },
			done = "Thank you for calling. I'll pass on the message and ask someone to call you back. Have a nice day!"
		},
		done = function(caller, callstate, players)
			players:send({
				"SMS from JGC: " .. callstate.name .. " is trying to reach " .. callstate.company .. ": " .. callstate.reason .. ".",
				"Call the customer back on phone #" .. caller.phone .. "."
			}, 120, 255, 80)
		end
	},
	[5500] = {
		name = "Dinoco",
		operator = "Operator",
		factions = { 147 },
		require_phone = true,
		dialogue = {
			{ q = "Hello, Dinoco here, how can we help you?", as = "reason" },
			{ q = "What is your name?", as = "name" },
			done = "Thanks for the call, an employee should call back soon!"
		},
		done = function(caller, callstate, players)
			players:send({
				"SMS from Dinoco.: " .. callstate.name .. " is requesting assistance: " .. callstate.reason .. ".",
				"Call the customer back on phone #" .. caller.phone .. "."
			}, 120, 255, 80)
		end
	},
	[2500] = {
		name = "Bank of Los Santos",
		order = 1900,
		operator = "Secretary",
		factions = { 17 },
		require_phone = true,
		dialogue = {
			{ q = "Welcome to the Bank of Los Santos. May I have your name, please?", as = "name" },
			{ q = "Alright, how can we help you?", as = "message" },
			done = "Okay, I'll notify someone. Have a good day."
		},
		done = function(caller, callstate, players)
			players:send({
				"SMS from Bank of LS: Inquiry from " .. callstate.name .. ": " .. callstate.message .. ".",
				"Call the customer back on phone #" .. caller.phone .. "."
			}, 120, 255, 80)
		end
	},
	[2600] = {
		name = "All Saints Hospital",
		operator = "Receptionist",
		factions = { 164 },
		require_radio = true,
		dialogue = {
			{ q = "You've reached All Saints Hospital. Can I get your name please?", as = "name" },
			{ q = "How can we help you?", as = "reason" },
			done = "Thank you for calling us, we'll get back to you as soon as possible."
		},
		done = function(caller, callstate, players)
			players:send({
				"[RADIO] This is dispatch, we've got a report from #" .. caller.phone .. " via the #2600 hotline, over.",
				"[RADIO] Name: '" .. callstate.name .. "', over.",
				"[RADIO] Request: '" .. callstate.reason .. "', out."
			}, 245, 40, 135)
			players:beep()
		end
	},
	[4200] = {
		name = "Western Solutions LLC",
		operator = "Fritz Speer",
		factions = { 159 },
		require_phone = true,
		dialogue = {
			{ q = "Welcome to Western Solutions, how can we help you?", as = "reason" },
			{ q = "What is your name?", as = "name" },
			done = "Thanks for the call, an employee should call back soon!"
		},
		done = function(caller, callstate, players)
			players:send({
				"SMS from Western Solutions: " .. callstate.name .. " is calling about: " .. callstate.reason .. ".",
				"Call the customer back at #" .. caller.phone .. "."
			}, 120, 255, 80)
		end
	},
	[2504] = {
		name = "Sparta Inc",
		operator = "Operator",
		factions = { 212 },
		require_phone = true,
		dialogue = {
			{ q = "Hello, Sparta Inc. here, how can we help you?", as = "reason" },
			{ q = "What is your name?", as = "name" },
			done = "Thanks for the call, an employee should call back soon!"
		},
		done = function(caller, callstate, players)
			players:send({
				"SMS from Sparta Inc.: " .. callstate.name .. " is requesting assistance: " .. callstate.reason .. ".",
				"Call the customer back on phone #" .. caller.phone .. "."
			}, 120, 255, 80)
		end
	},
}

------------------------------------------------------------------------------------------------------------------------
local function count(t)
	local c = 0
	for k, v in pairs(t) do
		c = c + 1
	end
	return c
end

function hasTurnedOnRadio(player)
	for _, item in ipairs(exports['item-system']:getItems(player)) do
		if item[1] == 6 and type(item[2]) == 'number' and item[2] > 0 then
			return true
		end
	end
	return false
end

function collectReceivingPlayersForHotline(hotline)
	-- collect all players to have the message sent to
	local receivingPlayers = setmetatable({}, {
		__index = {
			-- players:send({messages}, r, g, b)
			-- this is akin to defining function send(t, ...) somewhere somewow
			send = function(t, message, ...)
				for player in pairs(t) do
					if type(message) == 'string' then
						outputChatBox(message, player, ...)
					else
						for _, m in ipairs(message) do
							outputChatBox(m, player, ...)
						end
					end
				end
			end,
			beep = function(t)
				for player in pairs(t) do
					triggerClientEvent(player, "phones:radioDispatchBeep", player)
				end
			end
		}
	})

	local temp = {}
	-- factions?
	for _, faction in ipairs(hotline.factions or {}) do
		for _, player in ipairs(exports.factions:getPlayersInFaction(faction)) do
			temp[player] = true
		end
	end

	-- job?
	if hotline.job then
		for _, player in ipairs(exports.pool:getPoolElementsByType("player")) do
			if getElementData(player, "job") == hotline.job.id then
				if hotline.job.vehicle_models then
					local car = getPedOccupiedVehicle(player)
					if car then
						local vm = getElementModel(car)
						for _, model in ipairs(hotline.job.vehicle_models) do
							if model == vm then
								temp[player] = true
								break
							end
						end
					end
				else
					temp[player] = true
				end
			end
		end
	end

	for player in pairs(temp) do
		local available = true
		if hotline.require_radio and not hasTurnedOnRadio(player) then
			available = false
		end

		if hotline.require_phone and not exports.global:hasItem(player, 2) then
			available = false
		end

		if available then
			receivingPlayers[player] = true
		end
	end
	return receivingPlayers
end

local function finishCall(caller)
	-- finish up the call
	triggerEvent("phone:cancelPhoneCall", caller.element)
	removeElementData(caller.element, "calls:hotline:state")
	removeElementData(caller.element, "callprogress")
end

function handleEasyHotlines(caller, callingPhoneNumber, startingCall, message)
	local hotline = easyHotlines[callingPhoneNumber]
	if not hotline then
		return "error"
	end

	caller = setmetatable(caller, {
		__index = {
			-- caller:respond(message)
			respond = function(t, message)
				outputChatBox(hotline.operator .. " [Phone]: " .. message, t.element, 200, 255, 200)
			end
		}
	})

	local callstate = not startingCall and getElementData(caller.element, "calls:hotline:state") or { progress = 1 }

	if hotline.no_players then
		local players = collectReceivingPlayersForHotline(hotline)
		if count(players) == 0 then
			caller:respond(hotline.no_players)
			finishCall(caller)
			return
		end
	end

	if not startingCall then
		-- we've presumably answered a question.
		local dialogue = hotline.dialogue[callstate.progress]
		if dialogue.check then
			local okay, err
			message, okay, err = dialogue.check(message)
			if not okay then
				caller:respond(err or "Sorry, no can do.")

				-- finish up the call
				finishCall(caller)
				return
			end
		end

		callstate[dialogue.as] = message
		callstate.progress = callstate.progress + 1
	end

	-- have we exhausted the dialogue yet?
	if callstate.progress <= #(hotline.dialogue or {}) then
		caller:respond(hotline.dialogue[callstate.progress].q)

		exports.anticheat:changeProtectedElementDataEx(caller.element, "calls:hotline:state", callstate, false)

		-- this prevents a global phone message from being sent.
		exports.anticheat:changeProtectedElementDataEx(caller.element, "callprogress", callstate.progress, false)
	else
		-- do we have a "done" dialogue?
		if hotline.dialogue and hotline.dialogue.done then
			caller:respond(hotline.dialogue.done)
		end

		if hotline.done then
			callstate = setmetatable(callstate, {
				-- fallback for non-existent keys
				__index = function(t, key)
					return "(( Error: '" .. key .. "' missing ))"
				end
			})

			local players = collectReceivingPlayersForHotline(hotline)
			hotline.done(caller, callstate, players)
		end

		finishCall(caller)
	end
end

(function()
	-- remove all hotlines that have factions assigned, but where none of those factions actually still exist on
	-- the server.
	local removedHotlines = {}

	local working, broken = 0, 0
	for number, hotline in pairs(easyHotlines) do
		if hotline.factions and #hotline.factions > 0 then
			local found = false
			for _, faction in ipairs(hotline.factions) do
				if isElement(exports.factions:getFactionFromID(faction)) then
					found = true
					working = working + 1
					break
				end
			end

			if not found then
				broken = broken + 1
				removedHotlines[number] = hotline
			end
		end

		if (not hotline.factions and not hotline.job) or not hotline.dialogue then
			broken = broken + 1
			removedHotlines[number] = hotline
		end
	end

	-- does not take the job numbers into account, so this check indicates -some- of the factions exist.
	if working > 0 then
		for number, hotline in pairs(removedHotlines) do
			easyHotlines[number] = {
				operator = "Service Announcement",
				dialogue = { done = "This number is currently not in service." }
			}
			outputDebugString("Hotline " .. number .. " has no eligible faction for receiving messages.", 2)
		end
		return removedHotlines
	else
		return {}
	end
end)();

(function()
	-- sort all hotlines into a table containing { name, number, order }
	local hotlines = {}
	for number, hotline in pairs(easyHotlines) do
		if hotline.name then
			table.insert(hotlines, { hotline.name, number, hotline.order or 1000 })
		end
	end
	table.sort(hotlines, function(a, b) return a[3] < b[3] end)
	exports.anticheat:changeProtectedElementDataEx(resourceRoot, "hotlines:names", hotlines)
end)();

------------------------------------------------------------------------------------------------------------------------
function log911( message )
	local logMeBuffer = getElementData(getRootElement(), "911log") or { }
	local r = getRealTime()
	table.insert(logMeBuffer,"["..("%02d:%02d"):format(r.hour,r.minute).. "] " ..  message)

	if #logMeBuffer > 30 then
		table.remove(logMeBuffer, 1)
	end
	setElementData(getRootElement(), "911log", logMeBuffer)
end

function read911Log(thePlayer)
	if exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer) then
		local logMeBuffer = getElementData(getRootElement(), "911log") or { }
		outputChatBox("Recent 911 calls:", thePlayer)
		for a, b in ipairs(logMeBuffer) do
			outputChatBox("- "..b, thePlayer)
		end
		outputChatBox("  END", thePlayer)
	end
end
addCommandHandler("show911", read911Log)

function checkService(service)
	t = { "both", 		--1: all
		  "all", 		--2: all
		  "pd", 		--3: PD
		  "police", 	--4: PD
		  "lspd",		--5: PD
		  "lscsd",		--6: PD
		  "sasd", 		--7: PD
		  "es",			--8: ES/FD
		  "medic",		--9: ES/FD
		  "ems",		--10: ES/FD
		  "ambulance",	--11: ES/FD
		  "lsfd",		--12: FD
		  "fire",		--13: FD
		  "fd",			--14: FD
		  "hospital",	--15: ES
	}
	for row, names in ipairs(t) do
		if names == string.lower(service) then
			if row >= 1 and row <= 2 then
				return true, { 1, 2, 50, 164 } -- All!
			elseif row >= 3 and row <= 7 then
				return true, { 1, 50 } -- PD and SCoSA
			elseif row >= 8 and row <= 11 then
				return true, { 2, 164 } -- ES and FD
			elseif row >= 12 and row <= 14 then
				return true, { 2 } -- FD
			elseif row == 15 then
				return true, { 164 } -- ES
			end
		end
	end
	return false
end
