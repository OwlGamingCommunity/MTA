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

function showStaff(thePlayer, commandName)
	local logged = getElementData(thePlayer, "loggedin")
	local info = {}
	local isOverlayDisabled = getElementData(thePlayer, "hud:isOverlayDisabled")

	-- ADMINS --
	if(logged==1) then
		local players = exports.global:getAdmins()
		local counter = 0

		admins = {}

		if isOverlayDisabled then
			outputChatBox("ADMINISTRATORS:", thePlayer, 255, 194, 14)
		else
			table.insert(info, {"Administration Team:", 255, 194, 14, 255, 1, "title"})
			table.insert(info, {""})
		end

		for k, arrayPlayer in ipairs(players) do
			local hiddenAdmin = getElementData(arrayPlayer, "hiddenadmin")
			local logged = getElementData(arrayPlayer, "loggedin")

			if logged == 1 then
				if exports.integration:isPlayerTrialAdmin(arrayPlayer) and ( hiddenAdmin == 0 or (exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) ) ) then
					admins[ #admins + 1 ] = { arrayPlayer, getElementData( arrayPlayer, "admin_level" ), getElementData( arrayPlayer, "duty_admin" ), exports.global:getPlayerName( arrayPlayer ) }
				end
			end
		end

		table.sort( admins, sortTable )

		for k, v in ipairs(admins) do
			arrayPlayer = v[1]
			local adminTitle = exports.global:getPlayerAdminTitle(arrayPlayer)
			local hiddenAdmin = getElementData(arrayPlayer, "hiddenadmin")
			if hiddenAdmin == 0 or exports.integration:isPlayerTrialAdmin(thePlayer) then
				v[4] = v[4] .. " (" .. tostring(getElementData(arrayPlayer, "account:username")) .. ")"

				if(v[3]==1)then
					if isOverlayDisabled then
						outputChatBox("-    " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - On Duty", thePlayer, 0, 200, 10)
					else
						table.insert(info, {"-    " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - On Duty", 0, 255, 0, 255, 1, "default"})
					end
				else
					if isOverlayDisabled then
						outputChatBox("-    " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - Off Duty", thePlayer, 100, 100, 100)
					else
						table.insert(info, {"-    " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - Off Duty", 200, 200, 200, 255, 1, "default"})
					end
				end
			end
		end

		if #admins == 0 then
			if isOverlayDisabled then
				outputChatBox("-    Currently no administrators online.", thePlayer)
			else
				table.insert(info, {"-    Currently no administrators online.", 255, 255, 255, 255, 1, "default"})
			end
		end
		--outputChatBox("Use /gms to see a list of gamemasters.", thePlayer)
	end

	if not isOverlayDisabled then
		table.insert(info, {" ", 100, 100, 100, 255, 1, "default"})
	end

	--GMS--
	if(logged==1) then
		local players = exports.global:getGameMasters()
		local counter = 0

		admins = {}
		if isOverlayDisabled then
			outputChatBox("SUPPORTERS:", thePlayer, 255, 194, 14)
		else
			table.insert(info, {"Support Team:", 255, 194, 14, 255, 1, "title"})
			table.insert(info, {""})
		end
		for k, arrayPlayer in ipairs(players) do
			local logged = getElementData(arrayPlayer, "loggedin")
			if logged == 1 then
				if exports.integration:isPlayerSupporter(arrayPlayer) then
					admins[ #admins + 1 ] = { arrayPlayer, getElementData( arrayPlayer, "account:gmlevel" ), getElementData( arrayPlayer, "duty_supporter" ), exports.global:getPlayerName( arrayPlayer ) }
				end
			end
		end

		for k, v in ipairs(admins) do
			arrayPlayer = v[1]
			local adminTitle = exports.global:getPlayerAdminTitle(arrayPlayer)

			--if exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) then
				v[4] = v[4] .. " (" .. tostring(getElementData(arrayPlayer, "account:username")) .. ")"
			--end

			if(v[3] == 1)then
				if isOverlayDisabled then
					outputChatBox("-    " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - On Duty", thePlayer, 0, 200, 10)
				else
					table.insert(info, {"-    " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - On Duty", 0, 255, 0, 255, 1, "default"})
				end
			else
				if isOverlayDisabled then
					outputChatBox("-    " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - Off Duty", thePlayer, 100, 100, 100)
				else
					table.insert(info, {"-    " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - Off Duty", 200, 200, 200, 255, 1, "default"})
				end
			end
		end

		if #admins == 0 then
			if isOverlayDisabled then
				outputChatBox("-    Currently no supporter online.", thePlayer)
			else
				table.insert(info, {"-    Currently no supporter online.", 255, 255, 255, 255, 1, "default"})
			end
		end

	end

	if not isOverlayDisabled then
		table.insert(info, {" ", 100, 100, 100, 255, 1, "default"})
	end

	--VCTs--
	if(logged==1) then
		local players = getElementsByType("player")
		local counter = 0

		if isOverlayDisabled then
			outputChatBox("VEHICLE TEAM:", thePlayer, 255, 194, 14)
		else
			table.insert(info, {"Vehicle Team:", 255, 194, 14, 255, 1, "title"})
			table.insert(info, {""})
		end

		for k, arrayPlayer in ipairs(players) do
			local logged = getElementData(arrayPlayer, "loggedin")
			if logged == 1 then
				if exports.integration:isPlayerVCTMember(arrayPlayer) then
					local hiddenAdmin = getElementData(arrayPlayer, "hiddenadmin")
					local stuffToPrint
					if (hiddenAdmin == 1) and ( exports.integration:isPlayerVCTMember(thePlayer) or exports.integration:isPlayerSupporter(thePlayer) or exports.integration:isPlayerScripter(thePlayer) or exports.integration:isPlayerTrialAdmin(thePlayer) ) then
						stuffToPrint = "-    "..(exports.integration:isPlayerVehicleConsultant(arrayPlayer) and "Leader" or "Member").." (Hidden) "..exports.global:getPlayerName(arrayPlayer).." ("..getElementData(arrayPlayer, "account:username")..")"
					else
						stuffToPrint = "-    "..(exports.integration:isPlayerVehicleConsultant(arrayPlayer) and "Leader" or "Member").." "..exports.global:getPlayerName(arrayPlayer).." ("..getElementData(arrayPlayer, "account:username")..")"
					end
					if (hiddenAdmin == 0 or ( exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) ) ) then
						local r, g, b = 0, 255, 0 --hud colour
						local cR, cG, cB = 0, 200, 10 --chatbox colour
						if(hiddenAdmin == 1) then
							r, g, b = 200, 200, 200
							cR, cG, cB = 100, 100, 100
						end
						if isOverlayDisabled then
							outputChatBox(stuffToPrint, thePlayer, cR, cG, cB)
						else
							table.insert(info, {stuffToPrint, r, g, b, 255, 1, "default"})
						end
						counter = counter + 1
					end
				end
			end
		end

		if counter == 0 then
			if isOverlayDisabled then
				outputChatBox("-    Currently no members online.", thePlayer)
			else
				table.insert(info, {"-    Currently no members online.", 255, 255, 255, 255, 1, "default"})
			end
		end

		if not isOverlayDisabled then
			table.insert(info, {" ", 100, 100, 100, 255, 1, "default"})
		end
	end

	if logged == 1 then
		if not isOverlayDisabled then
			exports.hud:sendTopRightNotification(thePlayer, info, 350)
		end
	end
end
addCommandHandler("admins", showStaff, false, false)
addCommandHandler("gms", showStaff, false, false)

function showStaff2(thePlayer, commandName)
	local logged = getElementData(thePlayer, "loggedin")
	local info = {}
	local isOverlayDisabled = getElementData(thePlayer, "hud:isOverlayDisabled")

	-- ADMINS --
	if(logged==1) then
		local players = exports.global:getAdmins()
		local counter = 0

		admins = {}

		if isOverlayDisabled then
			outputChatBox("ADMINISTRATORS:", thePlayer, 255, 194, 14)
		else
			table.insert(info, {"Administration Team:", 255, 194, 14, 255, 1, "title"})
			table.insert(info, {""})
		end

		for k, arrayPlayer in ipairs(players) do
			local hiddenAdmin = getElementData(arrayPlayer, "hiddenadmin")
			local logged = getElementData(arrayPlayer, "loggedin")

			if logged == 1 then
				if exports.integration:isPlayerTrialAdmin(arrayPlayer) and ( hiddenAdmin == 0 or ( exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) ) ) then
					admins[ #admins + 1 ] = { arrayPlayer, getElementData( arrayPlayer, "admin_level" ), getElementData( arrayPlayer, "duty_admin" ), exports.global:getPlayerName( arrayPlayer ) }
				end
			end
		end

		table.sort( admins, sortTable )

		for k, v in ipairs(admins) do
			arrayPlayer = v[1]
			local adminTitle = exports.global:getPlayerAdminTitle(arrayPlayer)
			local hiddenAdmin = getElementData(arrayPlayer, "hiddenadmin")
			if hiddenAdmin == 0 or exports.integration:isPlayerTrialAdmin(thePlayer) then
				v[4] = v[4] .. " (" .. tostring(getElementData(arrayPlayer, "account:username")) .. ")"

				if(v[3]==1)then
					if isOverlayDisabled then
						outputChatBox("-    " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - On Duty", thePlayer, 0, 200, 10)
					else
						table.insert(info, {"-    " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - On Duty", 0, 255, 0, 255, 1, "default"})
					end
				else
					if isOverlayDisabled then
						outputChatBox("-    " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - Off Duty", thePlayer, 100, 100, 100)
					else
						table.insert(info, {"-    " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - Off Duty", 200, 200, 200, 255, 1, "default"})
					end
				end
			end
		end

		if #admins == 0 then
			if isOverlayDisabled then
				outputChatBox("-    Currently no administrators online.", thePlayer)
			else
				table.insert(info, {"-    Currently no administrators online.", 255, 255, 255, 255, 1, "default"})
			end
		end
		--outputChatBox("Use /gms to see a list of gamemasters.", thePlayer)
	end

	if not isOverlayDisabled then
		table.insert(info, {" ", 100, 100, 100, 255, 1, "default"})
	end

	--GMS--
	if(logged==1) then
		local players = exports.global:getGameMasters()
		local counter = 0

		admins = {}
		if isOverlayDisabled then
			outputChatBox("SUPPORTERS:", thePlayer, 255, 194, 14)
		else
			table.insert(info, {"Support Team:", 255, 194, 14, 255, 1, "title"})
			table.insert(info, {""})
		end
		for k, arrayPlayer in ipairs(players) do
			local logged = getElementData(arrayPlayer, "loggedin")
			if logged == 1 then
				if exports.integration:isPlayerSupporter(arrayPlayer) then
					admins[ #admins + 1 ] = { arrayPlayer, getElementData( arrayPlayer, "account:gmlevel" ), getElementData( arrayPlayer, "duty_supporter" ), exports.global:getPlayerName( arrayPlayer ) }
				end
			end
		end

		for k, v in ipairs(admins) do
			arrayPlayer = v[1]
			local adminTitle = exports.global:getPlayerAdminTitle(arrayPlayer)

			--if exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) then
				v[4] = v[4] .. " (" .. tostring(getElementData(arrayPlayer, "account:username")) .. ")"
			--end

			if(v[3] == 1)then
				if isOverlayDisabled then
					outputChatBox("-    " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - On Duty", thePlayer, 0, 200, 10)
				else
					table.insert(info, {"-    " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - On Duty", 0, 255, 0, 255, 1, "default"})
				end
			else
				if isOverlayDisabled then
					outputChatBox("-    " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - Off Duty", thePlayer, 100, 100, 100)
				else
					table.insert(info, {"-    " .. tostring(adminTitle) .. " " .. tostring(v[4]):gsub("_"," ").." - Off Duty", 200, 200, 200, 255, 1, "default"})
				end
			end
		end

		if #admins == 0 then
			if isOverlayDisabled then
				outputChatBox("-    Currently no supporter online.", thePlayer)
			else
				table.insert(info, {"-    Currently no supporter online.", 255, 255, 255, 255, 1, "default"})
			end
		end

	end

	if not isOverlayDisabled then
		table.insert(info, {" ", 100, 100, 100, 255, 1, "default"})
	end

	--VCTs--
	if(logged==1) then
		local players = exports.pool:getPoolElementsByType("player")
		local counter = 0

		if isOverlayDisabled then
			outputChatBox("VEHICLE TEAM:", thePlayer, 255, 194, 14)
		else
			table.insert(info, {"Vehicle Team:", 255, 194, 14, 255, 1, "title"})
			table.insert(info, {""})
		end

		for k, arrayPlayer in ipairs(players) do
			local logged = getElementData(arrayPlayer, "loggedin")
			if logged == 1 then
				if exports.integration:isPlayerVCTMember(arrayPlayer) then
					local hiddenAdmin = getElementData(arrayPlayer, "hiddenadmin")
					local stuffToPrint
					if (hiddenAdmin == 1) then
						stuffToPrint = "-    "..(exports.integration:isPlayerVehicleConsultant(arrayPlayer) and "Leader" or "Member").." (Hidden) "..exports.global:getPlayerName(arrayPlayer).." ("..getElementData(arrayPlayer, "account:username")..")"
					else
						stuffToPrint = "-    "..(exports.integration:isPlayerVehicleConsultant(arrayPlayer) and "Leader" or "Member").." "..exports.global:getPlayerName(arrayPlayer).." ("..getElementData(arrayPlayer, "account:username")..")"
					end
					if (hiddenAdmin == 0 or ( exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) ) ) then
						local r, g, b = 0, 255, 0 --hud colour
						local cR, cG, cB = 0, 200, 10 --chatbox colour
						if(hiddenAdmin == 1) then
							r, g, b = 200, 200, 200
							cR, cG, cB = 100, 100, 100
						end
						if isOverlayDisabled then
							outputChatBox(stuffToPrint, thePlayer, cR, cG, cB)
						else
							table.insert(info, {stuffToPrint, r, g, b, 255, 1, "default"})
						end
						counter = counter + 1
					end
				end
			end
		end

		if counter == 0 then
			if isOverlayDisabled then
				outputChatBox("-    Currently no members online.", thePlayer)
			else
				table.insert(info, {"-    Currently no members online.", 255, 255, 255, 255, 1, "default"})
			end
		end

		if not isOverlayDisabled then
			table.insert(info, {" ", 100, 100, 100, 255, 1, "default"})
		end


		-- MAPPING TEAM --
		--[[if isOverlayDisabled then
			outputChatBox("MAPPING TEAM:", thePlayer, 255, 194, 14)
		else
			table.insert(info, {"Mapping Team:", 255, 194, 14, 255, 1, "title"})
			table.insert(info, {""})
		end

		for k, arrayPlayer in ipairs(players) do
			local logged = getElementData(arrayPlayer, "loggedin")
			if logged == 1 then
				if exports.integration:isPlayerMappingTeamMember(arrayPlayer) then
					local hiddenAdmin = getElementData(arrayPlayer, "hiddenadmin")
					local stuffToPrint
					if (hiddenAdmin == 1) then
						stuffToPrint = "-    "..(exports.integration:isPlayerMappingTeamLeader(arrayPlayer) and "Leader" or "Member").." (Hidden) "..exports.global:getPlayerName(arrayPlayer).." ("..getElementData(arrayPlayer, "account:username")..")"
					else
						stuffToPrint = "-    "..(exports.integration:isPlayerMappingTeamLeader(arrayPlayer) and "Leader" or "Member").." "..exports.global:getPlayerName(arrayPlayer).." ("..getElementData(arrayPlayer, "account:username")..")"
					end
					if (hiddenAdmin == 0 or ( exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) ) ) then
						local r, g, b = 0, 255, 0 --hud colour
						local cR, cG, cB = 0, 200, 10 --chatbox colour
						if(hiddenAdmin == 1) then
							r, g, b = 200, 200, 200
							cR, cG, cB = 100, 100, 100
						end
						if isOverlayDisabled then
							outputChatBox(stuffToPrint, thePlayer, cR, cG, cB)
						else
							table.insert(info, {stuffToPrint, r, g, b, 255, 1, "default"})
						end
						counter = counter + 1
					end
				end
			end
		end

		if counter == 0 then
			if isOverlayDisabled then
				outputChatBox("-    Currently no members online.", thePlayer)
			else
				table.insert(info, {"-    Currently no members online.", 255, 255, 255, 255, 1, "default"})
			end
		end]]

		-- SCRIPTERS --
		if isOverlayDisabled then
			outputChatBox("SCRIPTERS:", thePlayer, 255, 194, 14)
		else
			table.insert(info, {"Scripters:", 255, 194, 14, 255, 1, "title"})
			table.insert(info, {""})
		end

		for k, arrayPlayer in ipairs(players) do
			local logged = getElementData(arrayPlayer, "loggedin")
			if logged == 1 then
				if exports.integration:isPlayerScripter(arrayPlayer) then
					local hiddenAdmin = getElementData(arrayPlayer, "hiddenadmin")
					local adminTitle = exports.global:getPlayerAdminTitle(arrayPlayer)
					local stuffToPrint
					if (hiddenAdmin == 1) then
						stuffToPrint = "-    (Hidden) "..tostring(adminTitle).." "..exports.global:getPlayerName(arrayPlayer).." ("..getElementData(arrayPlayer, "account:username")..")"
					else
						stuffToPrint = "-    "..tostring(adminTitle).." "..exports.global:getPlayerName(arrayPlayer).." ("..getElementData(arrayPlayer, "account:username")..")"
					end
					if (hiddenAdmin == 0 or ( exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) ) ) then
						local r, g, b = 0, 255, 0 --hud colour
						local cR, cG, cB = 0, 200, 10 --chatbox colour
						if(hiddenAdmin == 1) then
							r, g, b = 200, 200, 200
							cR, cG, cB = 100, 100, 100
						end
						if isOverlayDisabled then
							outputChatBox(stuffToPrint, thePlayer, cR, cG, cB)
						else
							table.insert(info, {stuffToPrint, r, g, b, 255, 1, "default"})
						end
						counter = counter + 1
					end
				end
			end
		end

		if counter == 0 then
			if isOverlayDisabled then
				outputChatBox("-    Currently no scripters online.", thePlayer)
			else
				table.insert(info, {"-    Currently no scripters online.", 255, 255, 255, 255, 1, "default"})
			end
		end

	end

	if logged == 1 then
		if not isOverlayDisabled then
			exports.hud:sendTopRightNotification(thePlayer, info, 350)
		end
	end
end
addCommandHandler("staff", showStaff2, false, false)

function toggleOverlay(thePlayer, commandName)
	if getElementData(thePlayer, "hud:isOverlayDisabled") then
		setElementData(thePlayer, "hud:isOverlayDisabled", false)
		outputChatBox("You enabled overlay menus.",thePlayer)
	else
		setElementData(thePlayer, "hud:isOverlayDisabled", true)
		outputChatBox("You disabled overlay menus.", thePlayer)
	end
end
addCommandHandler("toggleOverlay", toggleOverlay, false, false)
addCommandHandler("togOverlay", toggleOverlay, false, false)
