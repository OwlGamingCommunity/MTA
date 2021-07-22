function showStats(thePlayer, commandName, targetPlayerName)
	if getElementData(thePlayer, "loggedin") ~= 1 then
		outputChatBox("You are not logged in.", thePlayer, 255, 0, 0)
		return
	end

	local showPlayer = thePlayer
	if exports.integration:isPlayerTrialAdmin(thePlayer) and targetPlayerName then
		targetPlayer = exports.global:findPlayerByPartialNick(thePlayer, targetPlayerName)
		if targetPlayer then
			if getElementData(targetPlayer, "loggedin") == 1 then
				thePlayer = targetPlayer
			else
				outputChatBox("Player is not logged in.", showPlayer, 255, 0, 0)
				return
			end
		else
			return
		end
	end
	
	local isOverlayDisabled = getElementData(showPlayer, "hud:isOverlayDisabled")
	--LICNESES
	local carlicense = getElementData(thePlayer, "license.car")
	local bikelicense = getElementData(thePlayer, "license.bike")
	local boatlicense = getElementData(thePlayer, "license.boat")
	--local pilotlicense = getElementData(thePlayer, "license.pilot")
	local fishlicense = getElementData(thePlayer, "license.fish")
	local gunlicense = getElementData(thePlayer, "license.gun")
	local gun2license = getElementData(thePlayer, "license.gun2")
	if (carlicense==1) then
		carlicense = "Yes"
	elseif (carlicense==3) then
		carlicense = "Theory test passed"
	else
		carlicense = "No"
	end
	if (bikelicense==1) then
		bikelicense = "Yes"
	elseif (bikelicense==3) then
		bikelicense = "Theory test passed"
	else
		bikelicense = "No"
	end
	if (boatlicense==1) then
		boatlicense = "Yes"
	else
		boatlicense = "No"
	end
	
	local pilotLicenses = exports.mdc:getPlayerPilotLicenses(thePlayer) or {}
	local pilotlicense = ""
	local maxShow = 5
	local numAdded = 0
	local numOverflow = 0
	local typeratings = 0
	for k,v in ipairs(pilotLicenses) do
		local licenseID = v[1]
		local licenseValue = v[2]
		local licenseName = v[3]
		if licenseID == 7 then --if typerating
			if licenseValue then
				typeratings = typeratings + 1
			end
		else
			if numAdded >= maxShow then
				numOverflow = numOverflow + 1
			else
				if numAdded == 0 then
					pilotlicense = pilotlicense..tostring(licenseName)
				else
					pilotlicense = pilotlicense..", "..tostring(licenseName)
				end
				numAdded = numAdded + 1
			end
		end
	end
	if(numAdded == 0) then
		pilotlicense = "No"
	else
		if numOverflow > 0 then
			pilotlicense = pilotlicense.." (+"..tostring(numOverflow+typeratings)..")"
		else
			if typeratings > 0 then
				pilotlicense = pilotlicense.." (+"..tostring(typeratings)..")"
			else
				pilotlicense = pilotlicense.."."
			end
		end
	end
	
	if (fishlicense==1) then
		fishlicense = "Yes"
	else
		fishlicense = "No"
	end
	if (gunlicense==1) then
		gunlicense = "Yes"
	else
		gunlicense = "No"
	end
	if (gun2license==1) then
		gun2license = "Yes"
	else
		gun2license = "No"
	end
	--VEHICLES
	local dbid = tonumber(getElementData(thePlayer, "dbid"))
	local carids = ""
	local numcars = 0
	local printCar = ""
	for key, value in ipairs(exports.pool:getPoolElementsByType("vehicle")) do
		local owner = tonumber(getElementData(value, "owner"))

		if (owner) and (owner==dbid) then
			local id = getElementData(value, "dbid")
			carids = carids .. id .. ", "
			numcars = numcars + 1
			exports.anticheat:changeProtectedElementDataEx(value, "owner_last_login", exports.datetime:now(), true)
		end
	end
	printCar = numcars .. "/" .. getElementData(thePlayer, "maxvehicles")

	-- PROPERTIES
	local properties = ""
	local numproperties = 0
	for key, value in ipairs(getElementsByType("interior")) do
		local stt = getElementData(value, "status")
		if stt.owner and stt.owner == dbid and getElementData(value, "name") then
			local id = getElementData(value, "dbid")
			properties = properties .. id .. ", "
			numproperties = numproperties + 1
			--Update owner last login / MAXIME 2015.01.07
			exports.anticheat:changeProtectedElementDataEx(value, "owner_last_login", exports.datetime:now(), true)
		end
	end

	if (properties=="") then properties = "None.  " end
	if (carids=="") then carids = "None.  " end
	--FETCH ABOVE
	local hoursplayed = getElementData(thePlayer, "hoursplayed")
	local info = {}
	if isOverlayDisabled then
		outputChatBox(getPlayerName(thePlayer):gsub("_", " "), showPlayer , 255, 194, 14)
		outputChatBox(" Drivers License: " .. carlicense, showPlayer)
		outputChatBox(" Motorcycle License: " .. bikelicense, showPlayer)
		outputChatBox(" Boating License: " .. boatlicense, showPlayer)
		outputChatBox(" Pilots License: " .. pilotlicense, showPlayer)
		outputChatBox(" Tier 1 Firearms License: " .. gunlicense , showPlayer)
		outputChatBox(" Tier 2 Firearms License: " .. gun2license , showPlayer)
		outputChatBox(" Fishing Permit: " .. fishlicense, showPlayer)
		outputChatBox(" Vehicles (" .. printCar .. "): " .. string.sub(carids, 1, string.len(carids)-2) , showPlayer)
		outputChatBox(" Properties (" .. numproperties .. "/"..(getElementData(thePlayer, "maxinteriors") or 10).."): " .. string.sub(properties, 1, string.len(properties)-2) , showPlayer)
		outputChatBox(" Time spent on this character: " .. hoursplayed .. " hours." , showPlayer)
		outputChatBox(" Languages: " , showPlayer)
	else
		info = {
			{getPlayerName(thePlayer):gsub("_", " ")},
			{""},
			{" Date of birth: "..exports.global:getPlayerDoB(thePlayer)},
			{" Drivers License: " .. carlicense},
			{" Motorcycle License: " .. bikelicense},
			{" Boating License: " .. boatlicense},
			{" Pilots License: " .. pilotlicense},
			{" Tier 1 Firearms License: " .. gunlicense},
			{" Tier 2 Firearms License: " .. gun2license},
			{" Fishing Permit: " .. fishlicense},
			{" Vehicles (" .. printCar .. "): " .. string.sub(carids, 1, string.len(carids)-2)},
			{" Properties (" .. numproperties .. "/"..(getElementData(thePlayer, "maxinteriors") or 10).."): " .. string.sub(properties, 1, string.len(properties)-2)},
			{" Time spent on this character: " .. hoursplayed .. " hours."},
			{" Languages: "},
		}
	end
	--LANGUAGES
	for i = 1, 3 do
		local lang = getElementData(thePlayer, "languages.lang" .. i)
		if lang and lang ~= 0 then
			local skill = getElementData(thePlayer, "languages.lang" .. i .. "skill")
			local langname = exports['language-system']:getLanguageName( lang )
			if langname then
				if isOverlayDisabled then
					outputChatBox("   - "..langname.." (" .. skill .. "%)", showPlayer)
				else
					table.insert(info, {"   - "..langname.." (" .. skill .. "%)"})
				end
			end
		end
	end
	--CAREER
	local job = getElementData(thePlayer, "job") or 0
	if job == 0 then
		if isOverlayDisabled then
			outputChatBox(" Career: Unemployed", showPlayer)
		else
			table.insert(info, {" Career: Unemployed"})
		end
	else
		local jobName = exports["job-system"]:getJobTitleFromID(job)
		local joblevel = getElementData(thePlayer, "jobLevel") or 1
		local jobProgress = getElementData(thePlayer, "jobProgress") or 0
		if isOverlayDisabled then
			outputChatBox(" Career: "..jobName, showPlayer)
			outputChatBox("   - Skill Level: "..joblevel, showPlayer)
			outputChatBox("   - Progress: "..jobProgress, showPlayer)
		else
			table.insert(info, {" Career: "..jobName})
			table.insert(info, {"   - Skill Level: "..joblevel})
			table.insert(info, {"   - Progress: "..jobProgress})
		end
	end
	--CARRIED
	local carried = " Carried Weight: "..("%.2f/%.2f" ):format( exports["item-system"]:getCarriedWeight( thePlayer ), exports["item-system"]:getMaxWeight( thePlayer ) ).." kg(s)"
	if isOverlayDisabled then
		outputChatBox( carried, showPlayer)
	else
		table.insert(info, {carried})
	end
	--FINANCE
	local currentGC = getElementData(thePlayer, "credits") or 0
	local bankmoney = getElementData(thePlayer, "bankmoney") or 0
	local money = getElementData(thePlayer, "money") or 0
	if isOverlayDisabled then
		outputChatBox( " Finance: ", showPlayer)
		outputChatBox( "   - GCs: "..exports.global:formatMoney(currentGC), showPlayer)
		outputChatBox( "   - Money: $"..exports.global:formatMoney(money), showPlayer)
		outputChatBox( "   - Bank money: $"..exports.global:formatMoney(bankmoney), showPlayer)
	else
		table.insert(info, {" Finance: "})
		table.insert(info, {"   - GCs: "..exports.global:formatMoney(currentGC)})
		table.insert(info, {"   - Money: $"..exports.global:formatMoney(money)})
		table.insert(info, {"   - Bank money: $"..exports.global:formatMoney(bankmoney)})
	end
	
	if not isOverlayDisabled then
		triggerClientEvent(showPlayer, "hudOverlay:drawOverlayTopRight", showPlayer, info ) 
	end
end
addCommandHandler("stats", showStats, false, false)
addEvent("showStats", true)
addEventHandler("showStats", root, showStats)
