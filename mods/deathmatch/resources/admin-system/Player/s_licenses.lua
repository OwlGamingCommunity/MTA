
--give player license
function givePlayerLicense(thePlayer, commandName, targetPlayerName, licenseType)
	if exports.integration:isPlayerTrialAdmin(thePlayer) then
		if not targetPlayerName or not (licenseType and (licenseType == "1" or licenseType == "2" or licenseType == "3" or licenseType == "4" or licenseType == "5") or licenseType == "6" or licenseType == "7" or licenseType == "8" or licenseType == "9" or licenseType == "10" or licenseType == "11" or licenseType == "12" or licenseType == "13") then
			outputChatBox("SYNTAX: /" .. commandName .. " [Partial Player Nick] [Type]", thePlayer, 255, 194, 14)
			outputChatBox("Type 1 = Drivers License", thePlayer, 255, 194, 14)
			outputChatBox("Type 2 = Motorcycle License", thePlayer, 255, 194, 14)
			outputChatBox("Type 3 = Boating License", thePlayer, 255, 194, 14)
			--[[
			outputChatBox("Type 4 = Pilots License - ROT", thePlayer, 255, 194, 14)
			outputChatBox("Type 5 = Pilots License - SER", thePlayer, 255, 194, 14)
			outputChatBox("Type 6 = Pilots License - ROT+SER", thePlayer, 255, 194, 14)
			outputChatBox("Type 7 = Pilots License - MER", thePlayer, 255, 194, 14)
			outputChatBox("Type 8 = Pilots License - TER", thePlayer, 255, 194, 14)
			outputChatBox("Type 9 = Pilots License - ROT+MER", thePlayer, 255, 194, 14)
			outputChatBox("Type 10 = Pilots License - ROT+TER", thePlayer, 255, 194, 14)
			--]]
			outputChatBox("Type 11 = Fishing Permit", thePlayer, 255, 194, 14)
			outputChatBox("Type 12 = Tier 1 F/A", thePlayer, 255, 194, 14)
			outputChatBox("Type 13 = Tier 2 F/A", thePlayer, 255, 194, 14)
			--[[outputChatBox("Type 10 = OCW permit (weapon)", thePlayer, 255, 194, 14)
			outputChatBox("Type 11 = CCW permit (weapon)", thePlayer, 255, 194, 14)--]]
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayerName)
			local username = getPlayerName(thePlayer)
			local user = getElementData(thePlayer, "account:username")

			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")
				local name = getPlayerName(targetPlayer):gsub("_", " ")

				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				elseif (logged==1) then
					if licenseType == "1" then licenseTypeOutput = "Drivers License"	licenseType = "car" end
					if licenseType == "2" then licenseTypeOutput = "Motorcycle License"	licenseType = "bike" end
					if licenseType == "3" then licenseTypeOutput = "Boating License"	licenseType = "boat" end
					--[[
					if licenseType == "4" then licenseTypeOutput = "Pilots License - ROT"	licenseType = "pilot.rot" end
					if licenseType == "5" then licenseTypeOutput = "Pilots License - SER"	licenseType = "pilot.ser" end
					if licenseType == "6" then licenseTypeOutput = "Pilots License - ROT+SER" licenseType = "pilot.rot-ser" end
					if licenseType == "7" then licenseTypeOutput = "Pilots License - MER" licenseType = "pilot.mer" end
					if licenseType == "8" then licenseTypeOutput = "Pilots License - TER" licenseType = "pilot.ter" end
					if licenseType == "9" then licenseTypeOutput = "Pilots License - ROT+MER" licenseType = "pilot.rot-mer" end
					if licenseType == "10" then licenseTypeOutput = "Pilots License - ROT+TER" licenseType = "pilot.rot-ter" end
					--]]
					if licenseType == "11" then licenseTypeOutput = "Fishing Permit"	licenseType = "fish" end
					if licenseType == "12" then licenseTypeOutput = "Tier 1 F/A License"	licenseType = "gun" end
					if licenseType == "13" then licenseTypeOutput = "Tier 2 F/A License"	licenseType = "gun2" end


					if getElementData(targetPlayer, "license."..licenseType) == 1 then
						outputChatBox(getPlayerName(targetPlayer).." has already a "..licenseTypeOutput.." license.", thePlayer, 255, 255, 0)
					else
						if (licenseType == "car") then -- DRIVERS LICENSE
							exports.anticheat:changeProtectedElementDataEx(targetPlayer, "license."..licenseType, 1, false)
							mysql:query_free("UPDATE characters SET "..mysql:escape_string(licenseType).."_license='1' WHERE id = "..mysql:escape_string(getElementData(targetPlayer, "dbid")).." LIMIT 1")

							outputChatBox("Admin "..getPlayerName(thePlayer):gsub("_"," ").." gives you a "..licenseTypeOutput.." license.", targetPlayer, 0, 255, 0)
							exports.logs:dbLog(thePlayer, 4, targetPlayer, "GIVELICENSE CAR")
							local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")

							if (hiddenAdmin==0) then
								local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
								exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " gave " .. targetPlayerName .. " a drivers license.")
							else
								outputChatBox("Player "..targetPlayerName.." now has a "..licenseTypeOutput.." license.", thePlayer, 0, 255, 0)
							end
						elseif (licenseType == "bike") then -- BIKE LICENSE
							exports.anticheat:changeProtectedElementDataEx(targetPlayer, "license."..licenseType, 1, false)
							mysql:query_free("UPDATE characters SET "..mysql:escape_string(licenseType).."_license='1' WHERE id = "..mysql:escape_string(getElementData(targetPlayer, "dbid")).." LIMIT 1")

							outputChatBox("Admin "..getPlayerName(thePlayer):gsub("_"," ").." gives you a "..licenseTypeOutput.." license.", targetPlayer, 0, 255, 0)
							exports.logs:dbLog(thePlayer, 4, targetPlayer, "GIVELICENSE BIKE")
							local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")

							if (hiddenAdmin==0) then
								local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
								exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " gave " .. targetPlayerName .. " a motorcycle license.")
							else
								outputChatBox("Player "..targetPlayerName.." now has a "..licenseTypeOutput.." license.", thePlayer, 0, 255, 0)
							end
						elseif (licenseType == "boat") then -- BOATING LICENSE
							exports.anticheat:changeProtectedElementDataEx(targetPlayer, "license."..licenseType, 1, false)
							mysql:query_free("UPDATE characters SET "..mysql:escape_string(licenseType).."_license='1' WHERE id = "..mysql:escape_string(getElementData(targetPlayer, "dbid")).." LIMIT 1")

							outputChatBox("Admin "..getPlayerName(thePlayer):gsub("_"," ").." gives you a "..licenseTypeOutput.." license.", targetPlayer, 0, 255, 0)
							exports.logs:dbLog(thePlayer, 4, targetPlayer, "GIVELICENSE BOAT")
							local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")

							if (hiddenAdmin==0) then
								local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
								exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " gave " .. targetPlayerName .. " a boating license.")
							else
								outputChatBox("Player "..targetPlayerName.." now has a "..licenseTypeOutput.." license.", thePlayer, 0, 255, 0)
							end
						--[[
						elseif (licenseType == "pilot.rot") then -- Pilot ROT (helicopters)
							exports.anticheat:changeProtectedElementDataEx(targetPlayer, "license.pilot", 1, false)
							mysql:query_free("UPDATE characters SET pilot_license='1' WHERE id = "..mysql:escape_string(getElementData(targetPlayer, "dbid")).." LIMIT 1")

							outputChatBox("Admin "..getPlayerName(thePlayer):gsub("_"," ").." gives you a "..licenseTypeOutput.." license.", targetPlayer, 0, 255, 0)
							exports.logs:dbLog(thePlayer, 4, targetPlayer, "GIVELICENSE PILOT")
							local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")

							if (hiddenAdmin==0) then
								local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
								exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " gave " .. targetPlayerName .. " a pilots license.")
							else
								outputChatBox("Player "..targetPlayerName.." now has a "..licenseTypeOutput.." license.", thePlayer, 0, 255, 0)
							end
						elseif (licenseType == "pilot.ser") then -- Pilot SER (small planes)
							exports.anticheat:changeProtectedElementDataEx(targetPlayer, "license.pilot", 2, false)
							mysql:query_free("UPDATE characters SET pilot_license='2' WHERE id = "..mysql:escape_string(getElementData(targetPlayer, "dbid")).." LIMIT 1")

							outputChatBox("Admin "..getPlayerName(thePlayer):gsub("_"," ").." gives you a "..licenseTypeOutput.." license.", targetPlayer, 0, 255, 0)
							exports.logs:dbLog(thePlayer, 4, targetPlayer, "GIVELICENSE PILOT")
							local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")

							if (hiddenAdmin==0) then
								local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
								exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " gave " .. targetPlayerName .. " a pilots license.")
							else
								outputChatBox("Player "..targetPlayerName.." now has a "..licenseTypeOutput.." license.", thePlayer, 0, 255, 0)
							end
						elseif (licenseType == "pilot.rot-ser") then -- Pilot ROT+SER (helicopters and small planes)
							exports.anticheat:changeProtectedElementDataEx(targetPlayer, "license.pilot", 3, false)
							mysql:query_free("UPDATE characters SET pilot_license='3' WHERE id = "..mysql:escape_string(getElementData(targetPlayer, "dbid")).." LIMIT 1")

							outputChatBox("Admin "..getPlayerName(thePlayer):gsub("_"," ").." gives you a "..licenseTypeOutput.." license.", targetPlayer, 0, 255, 0)
							exports.logs:dbLog(thePlayer, 4, targetPlayer, "GIVELICENSE PILOT")
							local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")

							if (hiddenAdmin==0) then
								local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
								exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " gave " .. targetPlayerName .. " a pilots license.")
							else
								outputChatBox("Player "..targetPlayerName.." now has a "..licenseTypeOutput.." license.", thePlayer, 0, 255, 0)
							end
						elseif (licenseType == "pilot.mer") then -- Pilot MER (medium planes)
							exports.anticheat:changeProtectedElementDataEx(targetPlayer, "license.pilot", 4, false)
							mysql:query_free("UPDATE characters SET pilot_license='4' WHERE id = "..mysql:escape_string(getElementData(targetPlayer, "dbid")).." LIMIT 1")

							outputChatBox("Admin "..getPlayerName(thePlayer):gsub("_"," ").." gives you a "..licenseTypeOutput.." license.", targetPlayer, 0, 255, 0)
							exports.logs:dbLog(thePlayer, 4, targetPlayer, "GIVELICENSE PILOT")
							local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")

							if (hiddenAdmin==0) then
								local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
								exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " gave " .. targetPlayerName .. " a pilots license.")
							else
								outputChatBox("Player "..targetPlayerName.." now has a "..licenseTypeOutput.." license.", thePlayer, 0, 255, 0)
							end
						elseif (licenseType == "pilot.ter") then -- Pilot TER (big planes)
							exports.anticheat:changeProtectedElementDataEx(targetPlayer, "license.pilot", 5, false)
							mysql:query_free("UPDATE characters SET pilot_license='5' WHERE id = "..mysql:escape_string(getElementData(targetPlayer, "dbid")).." LIMIT 1")

							outputChatBox("Admin "..getPlayerName(thePlayer):gsub("_"," ").." gives you a "..licenseTypeOutput.." license.", targetPlayer, 0, 255, 0)
							exports.logs:dbLog(thePlayer, 4, targetPlayer, "GIVELICENSE PILOT")
							local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")

							if (hiddenAdmin==0) then
								local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
								exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " gave " .. targetPlayerName .. " a pilots license.")
							else
								outputChatBox("Player "..targetPlayerName.." now has a "..licenseTypeOutput.." license.", thePlayer, 0, 255, 0)
							end
						elseif (licenseType == "pilot.rot-mer") then -- Pilot ROT+MER (helicopters and medium planes)
							exports.anticheat:changeProtectedElementDataEx(targetPlayer, "license.pilot", 6, false)
							mysql:query_free("UPDATE characters SET pilot_license='6' WHERE id = "..mysql:escape_string(getElementData(targetPlayer, "dbid")).." LIMIT 1")

							outputChatBox("Admin "..getPlayerName(thePlayer):gsub("_"," ").." gives you a "..licenseTypeOutput.." license.", targetPlayer, 0, 255, 0)
							exports.logs:dbLog(thePlayer, 4, targetPlayer, "GIVELICENSE PILOT")
							local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")

							if (hiddenAdmin==0) then
								local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
								exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " gave " .. targetPlayerName .. " a pilots license.")
							else
								outputChatBox("Player "..targetPlayerName.." now has a "..licenseTypeOutput.." license.", thePlayer, 0, 255, 0)
							end
						elseif (licenseType == "pilot.rot-ter") then -- Pilot ROT+TER (helicopters and big planes)
							exports.anticheat:changeProtectedElementDataEx(targetPlayer, "license.pilot", 7, false)
							mysql:query_free("UPDATE characters SET pilot_license='7' WHERE id = "..mysql:escape_string(getElementData(targetPlayer, "dbid")).." LIMIT 1")

							outputChatBox("Admin "..getPlayerName(thePlayer):gsub("_"," ").." gives you a "..licenseTypeOutput.." license.", targetPlayer, 0, 255, 0)
							exports.logs:dbLog(thePlayer, 4, targetPlayer, "GIVELICENSE PILOT")
							local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")

							if (hiddenAdmin==0) then
								local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
								exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " gave " .. targetPlayerName .. " a pilots license.")
							else
								outputChatBox("Player "..targetPlayerName.." now has a "..licenseTypeOutput.." license.", thePlayer, 0, 255, 0)
							end
						--]]
						elseif (licenseType == "fish") then -- BOATING LICENSE
							exports.anticheat:changeProtectedElementDataEx(targetPlayer, "license."..licenseType, 1, false)
							mysql:query_free("UPDATE characters SET "..mysql:escape_string(licenseType).."_license='1' WHERE id = "..mysql:escape_string(getElementData(targetPlayer, "dbid")).." LIMIT 1")

							outputChatBox("Admin "..getPlayerName(thePlayer):gsub("_"," ").." gives you a "..licenseTypeOutput.." license.", targetPlayer, 0, 255, 0)
							exports.logs:dbLog(thePlayer, 4, targetPlayer, "GIVELICENSE FISH")
							local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")

							if (hiddenAdmin==0) then
								local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
								exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " gave " .. targetPlayerName .. " a fishing permit.")
							else
								outputChatBox("Player "..targetPlayerName.." now has a "..licenseTypeOutput.." license.", thePlayer, 0, 255, 0)
							end
						elseif (licenseType == "gun") then
							if exports.integration:isPlayerAdmin(thePlayer) then
								--[[exports.anticheat:changeProtectedElementDataEx(targetPlayer, "license."..licenseType, 1, false)
								mysql:query_free("UPDATE characters SET "..mysql:escape_string(licenseType).."_license='1' WHERE id = "..mysql:escape_string(getElementData(targetPlayer, "dbid")).." LIMIT 1")

								outputChatBox("Admin "..getPlayerName(thePlayer):gsub("_"," ").." gives you a "..licenseTypeOutput.." license.", targetPlayer, 0, 255, 0)
								exports.logs:dbLog(thePlayer, 4, targetPlayer, "GIVELICENSE GUN")
								local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")

								if (hiddenAdmin==0) then
									local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
									exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " gave " .. targetPlayerName .. " a Tier 1 Firearms license.")
								else
									outputChatBox("Player "..targetPlayerName.." now has a "..licenseTypeOutput.." license.", thePlayer, 0, 255, 0)
								end]]
								outputChatBox("Please use /weaponlicenses.", thePlayer)
							else
								outputChatBox("You are not allowed to spawn Tier 1 licenses.", thePlayer, 255, 0, 0)
							end
						elseif (licenseType == "gun2") then
							if exports.integration:isPlayerAdmin(thePlayer) then
								--[[exports.anticheat:changeProtectedElementDataEx(targetPlayer, "license."..licenseType, 1, false)
								mysql:query_free("UPDATE characters SET "..mysql:escape_string(licenseType).."_license='1' WHERE id = "..mysql:escape_string(getElementData(targetPlayer, "dbid")).." LIMIT 1")

								outputChatBox("Admin "..getPlayerName(thePlayer):gsub("_"," ").." gives you a "..licenseTypeOutput.." license.", targetPlayer, 0, 255, 0)
								exports.logs:dbLog(thePlayer, 4, targetPlayer, "GIVELICENSE GUN2")
								local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")

								if (hiddenAdmin==0) then
									local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
									exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " gave " .. targetPlayerName .. " a Tier 2 Firearms license.")
								else
									outputChatBox("Player "..targetPlayerName.." now has a "..licenseTypeOutput.." license.", thePlayer, 0, 255, 0)
								end]]
								outputChatBox("Please use /weaponlicenses.", thePlayer)
							else
								outputChatBox("You are not allowed to spawn Tier 2 licenses.", thePlayer, 255, 0, 0)
							end
						end
					end
				end
			end
		end
	end
end
addCommandHandler("agivelicense", givePlayerLicense)
addCommandHandler("agl", givePlayerLicense)
addCommandHandler("givelicense", givePlayerLicense)

--take player license
function takePlayerLicense(thePlayer, commandName, dtargetPlayerName, licenseType, hours)
	if exports.integration:isPlayerTrialAdmin(thePlayer) then
		if not dtargetPlayerName or not (licenseType and (licenseType == "1" or licenseType == "2" or licenseType == "3" or licenseType == "4" or licenseType == "5" or licenseType == "6" or licenseType == "7")) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Nick] [Type] (Hours - leave blank for indefinitely)", thePlayer, 255, 194, 14)
			outputChatBox("Type 1 = Drivers License", thePlayer, 255, 194, 14)
			outputChatBox("Type 2 = Motorcycle License", thePlayer, 255, 194, 14)
			outputChatBox("Type 3 = Boating License", thePlayer, 255, 194, 14)
			--outputChatBox("Type 4 = Pilots License (Any)", thePlayer, 255, 194, 14)
			outputChatBox("Type 5 = Fishing Permit", thePlayer, 255, 194, 14)
			outputChatBox("Type 6 = Tier 1 F/A", thePlayer, 255, 194, 14)
			outputChatBox("Type 7 = Tier 2 F/A", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, dtargetPlayerName)
			local username = getPlayerName(thePlayer)
			local hours = tonumber(hours)
			if not hours then hours = 9999 end

			if licenseType == "1" then licenseTypeOutput = "Drivers License"	licenseType = "car" end
			if licenseType == "2" then licenseTypeOutput = "Motorcycle License"	licenseType = "bike" end
			if licenseType == "3" then licenseTypeOutput = "Boating License"	licenseType = "boat" end
			--if licenseType == "4" then licenseTypeOutput = "Pilots License"	licenseType = "pilot" end
			if licenseType == "5" then licenseTypeOutput = "Fishing Permit"	licenseType = "fish" end
			if licenseType == "6" then licenseTypeOutput = "Tier 1 F/A License"	licenseType = "gun" end
			if licenseType == "7" then licenseTypeOutput = "Tier 2 F/A License"	licenseType = "gun2" end

			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")

				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				elseif (logged==1) then
					if getElementData(targetPlayer, "license."..licenseType) == 0 then
						outputChatBox(getPlayerName(thePlayer).." has no "..licenseTypeOutput.." license.", thePlayer, 255, 255, 0)
					else
						if (licenseType == "car") then
							exports.anticheat:changeProtectedElementDataEx(targetPlayer, "license."..licenseType, -(hours+1), false)
							mysql:query_free("UPDATE characters SET "..mysql:escape_string(licenseType).."_license='"..mysql:escape_string(-(hours+1)).."' WHERE id = "..mysql:escape_string(getElementData(targetPlayer, "dbid")).." LIMIT 1")
							outputChatBox("Admin "..getPlayerName(thePlayer):gsub("_"," ").." revokes your "..licenseTypeOutput.." license for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".", targetPlayer, 0, 255, 0)
							exports.logs:dbLog(thePlayer, 4, targetPlayer, "TAKELICENSE CAR FOR"..(hours == 9999 and "EVER" or tostring(" "..hours.." hour(s)")))

							local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
							if (hiddenAdmin==0) then
								local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
								exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " revoked " .. targetPlayerName .. " "..licenseTypeOutput.." license for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".")
							end
							outputChatBox("Player "..targetPlayerName.." now has their "..licenseTypeOutput.." license revoked for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".", thePlayer, 0, 255, 0)
						elseif (licenseType == "bike") then
							exports.anticheat:changeProtectedElementDataEx(targetPlayer, "license."..licenseType, -(hours+1), false)
							mysql:query_free("UPDATE characters SET "..mysql:escape_string(licenseType).."_license='"..mysql:escape_string(-(hours+1)).."' WHERE id = "..mysql:escape_string(getElementData(targetPlayer, "dbid")).." LIMIT 1")
							outputChatBox("Admin "..getPlayerName(thePlayer):gsub("_"," ").." revokes your "..licenseTypeOutput.." license for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".", targetPlayer, 0, 255, 0)
							exports.logs:dbLog(thePlayer, 4, targetPlayer, "TAKELICENSE BIKE FOR"..(hours == 9999 and "EVER" or tostring(" "..hours.." hour(s)")))

							local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
							if (hiddenAdmin==0) then
								local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
								exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " revoked " .. targetPlayerName .. " "..licenseTypeOutput.." license for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".")
							end
							outputChatBox("Player "..targetPlayerName.." now has their "..licenseTypeOutput.." license revoked for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".", thePlayer, 0, 255, 0)
						elseif (licenseType == "boat") then
							exports.anticheat:changeProtectedElementDataEx(targetPlayer, "license."..licenseType, -(hours+1), false)
							mysql:query_free("UPDATE characters SET "..mysql:escape_string(licenseType).."_license='"..mysql:escape_string(-(hours+1)).."' WHERE id = "..mysql:escape_string(getElementData(targetPlayer, "dbid")).." LIMIT 1")
							outputChatBox("Admin "..getPlayerName(thePlayer):gsub("_"," ").." revokes your "..licenseTypeOutput.." license for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".", targetPlayer, 0, 255, 0)
							exports.logs:dbLog(thePlayer, 4, targetPlayer, "TAKELICENSE BOAT FOR"..(hours == 9999 and "EVER" or tostring(" "..hours.." hour(s)")))

							local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
							if (hiddenAdmin==0) then
								local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
								exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " revoked " .. targetPlayerName .. " "..licenseTypeOutput.." license for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".")
							end
							outputChatBox("Player "..targetPlayerName.." now has their "..licenseTypeOutput.." license revoked for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".", thePlayer, 0, 255, 0)
						--[[
						elseif (licenseType == "pilot") then
							exports.anticheat:changeProtectedElementDataEx(targetPlayer, "license."..licenseType, 0, false)
							mysql:query_free("UPDATE characters SET "..mysql:escape_string(licenseType).."_license='0' WHERE id = "..mysql:escape_string(getElementData(targetPlayer, "dbid")).." LIMIT 1")
							outputChatBox("Admin "..getPlayerName(thePlayer):gsub("_"," ").." revokes your "..licenseTypeOutput.." license.", targetPlayer, 0, 255, 0)
							exports.logs:dbLog(thePlayer, 4, targetPlayer, "TAKELICENSE GUN")

							local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
							if (hiddenAdmin==0) then
								local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
								exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " revoked " .. targetPlayerName .. " "..licenseTypeOutput.." license.")
							else
								outputChatBox("Player "..targetPlayerName.." now  has their  "..licenseTypeOutput.." license revoked.", thePlayer, 0, 255, 0)
							end
						--]]
						elseif (licenseType == "fish") then
							exports.anticheat:changeProtectedElementDataEx(targetPlayer, "license."..licenseType, -(hours+1), false)
							mysql:query_free("UPDATE characters SET "..mysql:escape_string(licenseType).."_license='"..mysql:escape_string(-(hours+1)).."' WHERE id = "..mysql:escape_string(getElementData(targetPlayer, "dbid")).." LIMIT 1")
							outputChatBox("Admin "..getPlayerName(thePlayer):gsub("_"," ").." revokes your "..licenseTypeOutput.." license for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".", targetPlayer, 0, 255, 0)
							exports.logs:dbLog(thePlayer, 4, targetPlayer, "TAKELICENSE FISH FOR"..(hours == 9999 and "EVER" or tostring(" "..hours.." hour(s)")))

							local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
							if (hiddenAdmin==0) then
								local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
								exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " revoked " .. targetPlayerName .. " "..licenseTypeOutput.." license for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".")
							end
							outputChatBox("Player "..targetPlayerName.." now has their "..licenseTypeOutput.." license revoked for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".", thePlayer, 0, 255, 0)
						elseif (licenseType == "gun") then
							exports.anticheat:changeProtectedElementDataEx(targetPlayer, "license."..licenseType, -(hours+1), false)
							mysql:query_free("UPDATE characters SET "..mysql:escape_string(licenseType).."_license='"..mysql:escape_string(-(hours+1)).."' WHERE id = "..mysql:escape_string(getElementData(targetPlayer, "dbid")).." LIMIT 1")
							outputChatBox("Admin "..getPlayerName(thePlayer):gsub("_"," ").." revokes your "..licenseTypeOutput.." license for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".", targetPlayer, 0, 255, 0)
							exports.logs:dbLog(thePlayer, 4, targetPlayer, "TAKELICENSE GUN FOR"..(hours == 9999 and "EVER" or tostring(" "..hours.." hour(s)")))

							local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
							if (hiddenAdmin==0) then
								local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
								exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " revoked " .. targetPlayerName .. " "..licenseTypeOutput.." license for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".")
							end
							outputChatBox("Player "..targetPlayerName.." now has their "..licenseTypeOutput.." license revoked for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".", thePlayer, 0, 255, 0)
						elseif (licenseType == "gun2") then
							exports.anticheat:changeProtectedElementDataEx(targetPlayer, "license."..licenseType, -(hours+1), false)
							mysql:query_free("UPDATE characters SET "..mysql:escape_string(licenseType).."_license='"..mysql:escape_string(-(hours+1)).."' WHERE id = "..mysql:escape_string(getElementData(targetPlayer, "dbid")).." LIMIT 1")
							outputChatBox("Admin "..getPlayerName(thePlayer):gsub("_"," ").." revokes your "..licenseTypeOutput.." license for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".", targetPlayer, 0, 255, 0)
							exports.logs:dbLog(thePlayer, 4, targetPlayer, "TAKELICENSE GUN2 FOR"..(hours == 9999 and "EVER" or tostring(" "..hours.." hour(s)")))

							local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
							if (hiddenAdmin==0) then
								local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
								exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " revoked " .. targetPlayerName .. " "..licenseTypeOutput.." license for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".")
							end
							outputChatBox("Player "..targetPlayerName.." now has their "..licenseTypeOutput.." license revoked for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".", thePlayer, 0, 255, 0)
						end
					end
				end
			else
				local resultSet = mysql:query_fetch_assoc("SELECT `id`,`car_license`,`gun_license`,`gun2_license`, `fish_license`, `bike_license`, `boat_license` FROM `characters` where `charactername`='"..mysql:escape_string(dtargetPlayerName).."'")
				if resultSet then
					if (tonumber(resultSet[licenseType.."_license"]) ~= 0) then
						local resultQry = mysql:query_free("UPDATE `characters` SET `"..licenseType.."_license`="..mysql:escape_string(-(hours+1)).." WHERE `charactername`='"..mysql:escape_string(dtargetPlayerName).."'")
						if (resultQry) then
							exports.logs:dbLog(thePlayer, 4, { "ch"..resultSet["id"] }, "TAKELICENSE "..licenseType.." FOR"..(hours == 9999 and "EVER" or tostring(" "..hours)))
							local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
							if (hiddenAdmin==0) then
								local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
								exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " revoked " .. dtargetPlayerName .. " his ".. licenseType .." license for"..(hours == 9999 and "ever" or tostring(" "..hours))..".")
							else
								outputChatBox("Player "..dtargetPlayerName.." now  has his  "..licenseType.." license revoked for"..(hours == 9999 and "ever" or tostring(" "..hours))..".", thePlayer, 0, 255, 0)
							end
						else
							outputChatBox("Wups, atleast something went wrong there..", thePlayer, 255, 0, 0)
						end
					else
						outputChatBox("The player doesn't have this license.", thePlayer, 255, 0, 0)
					end
				else
					outputChatBox("No player found.", thePlayer, 255, 0, 0)
				end
			end
		end
	elseif exports.factions:isInFactionType(thePlayer, 2) then
		if not dtargetPlayerName or not (licenseType and (licenseType == "1" or licenseType == "2" or licenseType == "3" or licenseType == "4" or licenseType == "5")) or not tonumber(hours) then
			outputChatBox("SYNTAX: /" .. commandName .. " [Player Nick] [Type] [Hours or 0 for indefinitely]", thePlayer, 255, 194, 14)
			outputChatBox("Type 1 = Drivers License", thePlayer, 255, 194, 14)
			outputChatBox("Type 2 = Motorcycle License", thePlayer, 255, 194, 14)
			outputChatBox("Type 3 = Boating License", thePlayer, 255, 194, 14)
			outputChatBox("Type 5 = Fishing Permit", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, dtargetPlayerName)
			local username = getPlayerName(thePlayer)
			local hours = tonumber(hours)

			if licenseType == "1" then licenseTypeOutput = "Drivers License"	licenseType = "car" end
			if licenseType == "2" then licenseTypeOutput = "Motorcycle License"	licenseType = "bike" end
			if licenseType == "3" then licenseTypeOutput = "Boating License"	licenseType = "boat" end
			if licenseType == "5" then licenseTypeOutput = "Fishing Permit"	licenseType = "fish" end

			if targetPlayer then
				local logged = getElementData(targetPlayer, "loggedin")

				if (logged==0) then
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				elseif (logged==1) then
					if getElementData(targetPlayer, "license."..licenseType) == 0 then
						outputChatBox(getPlayerName(thePlayer).." has no "..licenseTypeOutput.." license.", thePlayer, 255, 255, 0)
					else
						if (licenseType == "car") then
							exports.anticheat:changeProtectedElementDataEx(targetPlayer, "license."..licenseType, -(hours+1), false)
							mysql:query_free("UPDATE characters SET "..mysql:escape_string(licenseType).."_license='"..mysql:escape_string(-(hours+1)).."' WHERE id = "..mysql:escape_string(getElementData(targetPlayer, "dbid")).." LIMIT 1")
							outputChatBox("Admin "..getPlayerName(thePlayer):gsub("_"," ").." revokes your "..licenseTypeOutput.." license for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".", targetPlayer, 0, 255, 0)
							exports.logs:dbLog(thePlayer, 4, targetPlayer, "TAKELICENSE CAR FOR"..(hours == 9999 and "EVER" or tostring(" "..hours.." hour(s)")))

							local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
							exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " revoked " .. targetPlayerName .. " "..licenseTypeOutput.." license for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".")
							outputChatBox("Player "..targetPlayerName.." now has their "..licenseTypeOutput.." license revoked for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".", thePlayer, 0, 255, 0)
						elseif (licenseType == "bike") then
							exports.anticheat:changeProtectedElementDataEx(targetPlayer, "license."..licenseType, -(hours+1), false)
							mysql:query_free("UPDATE characters SET "..mysql:escape_string(licenseType).."_license='"..mysql:escape_string(-(hours+1)).."' WHERE id = "..mysql:escape_string(getElementData(targetPlayer, "dbid")).." LIMIT 1")
							outputChatBox("Admin "..getPlayerName(thePlayer):gsub("_"," ").." revokes your "..licenseTypeOutput.." license for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".", targetPlayer, 0, 255, 0)
							exports.logs:dbLog(thePlayer, 4, targetPlayer, "TAKELICENSE BIKE FOR"..(hours == 9999 and "EVER" or tostring(" "..hours.." hour(s)")))

							local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
							exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " revoked " .. targetPlayerName .. " "..licenseTypeOutput.." license for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".")
							outputChatBox("Player "..targetPlayerName.." now has their "..licenseTypeOutput.." license revoked for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".", thePlayer, 0, 255, 0)
						elseif (licenseType == "boat") then
							exports.anticheat:changeProtectedElementDataEx(targetPlayer, "license."..licenseType, -(hours+1), false)
							mysql:query_free("UPDATE characters SET "..mysql:escape_string(licenseType).."_license='"..mysql:escape_string(-(hours+1)).."' WHERE id = "..mysql:escape_string(getElementData(targetPlayer, "dbid")).." LIMIT 1")
							outputChatBox("Admin "..getPlayerName(thePlayer):gsub("_"," ").." revokes your "..licenseTypeOutput.." license for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".", targetPlayer, 0, 255, 0)
							exports.logs:dbLog(thePlayer, 4, targetPlayer, "TAKELICENSE BOAT FOR"..(hours == 9999 and "EVER" or tostring(" "..hours.." hour(s)")))

							local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
							exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " revoked " .. targetPlayerName .. " "..licenseTypeOutput.." license for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".")
							outputChatBox("Player "..targetPlayerName.." now has their "..licenseTypeOutput.." license revoked for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".", thePlayer, 0, 255, 0)
						elseif (licenseType == "fish") then
							exports.anticheat:changeProtectedElementDataEx(targetPlayer, "license."..licenseType, -(hours+1), false)
							mysql:query_free("UPDATE characters SET "..mysql:escape_string(licenseType).."_license='"..mysql:escape_string(-(hours+1)).."' WHERE id = "..mysql:escape_string(getElementData(targetPlayer, "dbid")).." LIMIT 1")
							outputChatBox("Admin "..getPlayerName(thePlayer):gsub("_"," ").." revokes your "..licenseTypeOutput.." license for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".", targetPlayer, 0, 255, 0)
							exports.logs:dbLog(thePlayer, 4, targetPlayer, "TAKELICENSE FISH FOR"..(hours == 9999 and "EVER" or tostring(" "..hours.." hour(s)")))

							local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
							exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getPlayerName(thePlayer) .. " revoked " .. targetPlayerName .. " "..licenseTypeOutput.." license for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".")
							outputChatBox("Player "..targetPlayerName.." now has their "..licenseTypeOutput.." license revoked for"..(hours == 9999 and "ever" or tostring(" "..hours.." hour(s)"))..".", thePlayer, 0, 255, 0)
						end
					end
				end
			end
		end
	end
end
addCommandHandler("takelicense", takePlayerLicense)
addCommandHandler("atakelicense", takePlayerLicense)
addCommandHandler("atl", takePlayerLicense)

--LSIA: Issue pilot certificate (for leaders of faction ID 47)
local pilotLicenseNames = {"ROT", "SER", "ROT+SER", "MER", "TER", "ROT+MER", "ROT+TER"}
function issuePilotCertificate(thePlayer, commandName, targetPlayer, pilotLevel)
	local isMember, _ = exports.factions:isPlayerInFaction(thePlayer, 47)
	local leader = exports.factions:hasMemberPermissionTo(thePlayer, 47, "add_member")
	if (isMember and leader) or exports.integration:isPlayerLeadAdmin(thePlayer) then
		outputChatBox("This cmd is depreceated. Use MDC with a FAA account to issue licenses.", thePlayer, 255, 0, 0)
		--[[
		pilotLevel = tonumber(pilotLevel)
		if not (targetPlayer) or not pilotLevel or (pilotLevel < 0) or (pilotLevel > 7) then
			outputChatBox("SYNTAX: /" .. commandName .. " [player] [level]", thePlayer, 255, 194, 14)
			outputChatBox("  Level 0: No license (revoke)", thePlayer, 255, 194, 14)
			outputChatBox("  Level 1: ROT (Helicopters)", thePlayer, 255, 194, 14)
			outputChatBox("  Level 2: SER (Small planes)", thePlayer, 255, 194, 14)
			outputChatBox("  Level 3: ROT+SER (Helicopters + small planes)", thePlayer, 255, 194, 14)
			outputChatBox("  Level 4: MER (Medium planes)", thePlayer, 255, 194, 14)
			outputChatBox("  Level 5: TER (Big planes)", thePlayer, 255, 194, 14)
			outputChatBox("  Level 6: ROT+MER (Helicopters + med planes)", thePlayer, 255, 194, 14)
			outputChatBox("  Level 7: ROT+TER (Helicopters + big planes)", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
			if targetPlayer then -- is the player online?
				local logged = getElementData(targetPlayer, "loggedin")
				if (logged==0) then -- Are they logged in?
					outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
				else
					if(pilotLevel > 0) then
						outputChatBox("You have issued a "..pilotLicenseNames[tonumber(pilotLevel)].." pilot certificate to " .. targetPlayerName .. ".", thePlayer, 0, 158, 0)
						outputChatBox("You have been issued a "..pilotLicenseNames[tonumber(pilotLevel)].." pilot certificate by " .. getPlayerName(thePlayer):gsub("_", " ") .. ".", targetPlayer, 0, 158, 0)

						exports.anticheat:changeProtectedElementDataEx(targetPlayer, "license.pilot", pilotLevel, false)
						mysql:query_free("UPDATE characters SET pilot_license='"..pilotLevel.."' WHERE id = "..mysql:escape_string(getElementData(targetPlayer, "dbid")).." LIMIT 1")

					elseif(pilotLevel == 0) then
						outputChatBox("You have revoked the pilot certificate of " .. tostring(targetPlayerName) .. ".", thePlayer, 0, 158, 0)
						outputChatBox("Your pilot certificate was revoked by " .. getPlayerName(thePlayer):gsub("_", " ") .. ".", targetPlayer, 255, 0, 0)
						exports.anticheat:changeProtectedElementDataEx(targetPlayer, "license.pilot", 0, false)
						mysql:query_free("UPDATE characters SET pilot_license='0' WHERE id = "..mysql:escape_string(getElementData(targetPlayer, "dbid")).." LIMIT 1")
					end
				end
			else
				outputChatBox("Player not found.", thePlayer, 255, 0, 0)
			end
		end
		--]]
	end
end
addCommandHandler("issuepilotcertificate", issuePilotCertificate, false, false)
addCommandHandler("issuepilotcert", issuePilotCertificate, false, false)
addCommandHandler("issuepc", issuePilotCertificate, false, false)
addCommandHandler("issuepilot", issuePilotCertificate, false, false)

function getOldPilotLicense(thePlayer, commandName, targetPlayer)
	if not targetPlayer then
		outputChatBox("SYNTAX: /" .. commandName .. " [Partial Player Nick]", thePlayer, 255, 194, 14)
		return
	end
	local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(thePlayer, targetPlayer)
	if targetPlayer then
		local isMember, _ = exports.factions:isPlayerInFaction(thePlayer, 47)
		local leader = exports.factions:hasMemberPermissionTo(thePlayer, 47, "add_member")
		if (isMember and leader) or exports.integration:isPlayerTrialAdmin(thePlayer) or (targetPlayer == thePlayer) then
			local oldLicense = tonumber(getElementData(targetPlayer, "license.pilot")) or 0
			local licenseName
			if oldLicense == 0 then
				licenseName = "None"
			else
				licenseName = pilotLicenseNames[oldLicense]
			end
			outputChatBox("Pre-FAA pilot license for "..tostring(targetPlayerName)..":  (no longer valid)", thePlayer, 255, 194, 14)
		else
			outputChatBox("No access.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("oldpilot", getOldPilotLicense, false, false)
