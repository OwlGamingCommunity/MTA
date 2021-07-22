gFactionWindow, gMemberGrid, gMOTDLabel, colName, colRank, colWage, colDuty, colLastLogin, --[[colLocation,]] colOnline, colPhone, gButtonKick, gButtonPromote, gButtonDemote, gButtonEditRanks, gButtonEditMOTD, gButtonInvite, gButtonLeader, gButtonQuit, gButtonExit, wConfirmQuit, eNote = nil
theMotd, theTeam, arrUsernames, arrRanks, arrPerks, arrLeaders, arrOnline, arrFactionRanks, --[[arrLocations,]] arrFactionWages, arrLastLogin, membersOnline, membersOffline, gButtonRespawn, gButtonPerk = nil
tabVehicles, gVehicleGrid, colVehID, colVehModel, colVehPlates, colVehLocation, gButtonVehRespawn, gButtonAllVehRespawn, gButtonYes, gButtonNo, showrespawnUI = nil
local tmpPhone = nil
local promotionWindow = {}
local promotionButton = {}
local promotionLabel = {}
local promotionRadio = {}
local ftab = {}

local function checkF3( )
	if not f3state and getKeyState( "f3" ) then
		hideFactionMenu( )
	else
		f3state = getKeyState( "f3" )
	end
end

function showFactionMenu(motd, memberUsernames, memberRanks, memberPerks, memberLeaders, memberOnline, memberLastLogin, --[[memberLocation,]] factionRanks, factionWages, factionTheTeam, note, fnote, vehicleIDs, vehicleModels, vehiclePlates, vehicleLocations, memberOnDuty, towstats, phone, membersPhone, fromShowF, factionID, properties, factionRankID, rankOrder)
	if (gFactionWindow==nil) then
		invitedPlayer = nil
		arrUsernames = memberUsernames
		arrRanks = memberRanks
		arrLeaders = memberLeaders
		arrPerks = memberPerks
		arrOnline = memberOnline
		arrLastLogin = memberLastLogin
		faction_tab = factionID
		--arrLocations = memberLocation
		arrFactionRanks = factionRanks
		arrFactionWages = factionWages
		financeLoaded = false

		if (motd) == nil then motd = "" end
		theMotd = motd
		tmpPhone = phone

		local thePlayer = getLocalPlayer()
		theTeam = factionTheTeam
		local teamName = getTeamName(theTeam)
		local playerName = getPlayerName(thePlayer)
		triggerEvent( 'hud:blur', resourceRoot, 6, false, 0.5, nil )
		gFactionWindow = guiCreateWindow(0.1, 0.25, 0.85, 0.525, "Faction Menu", true)
		local width, height = guiGetSize(gFactionWindow, false)
		if height < 500 then
			guiSetSize(gFactionWindow, width, 500, false)
			local posx, posy = guiGetPosition(gFactionWindow, false)
			local screenx, screeny = guiGetScreenSize( )
			guiSetPosition(gFactionWindow, posx, (screeny - 500) / 2, false)
		end
		guiWindowSetSizable(gFactionWindow, false)
		guiSetInputEnabled(true)

		ftabs = guiCreateTabPanel(0, 0.04, 1, 1, true, gFactionWindow)
		ftab[factionID] = guiCreateTab(teamName, ftabs)
		setElementData(ftab[factionID], "factionID", factionID)
		addEventHandler("onClientGUITabSwitched", ftab[factionID], loadFaction, false)

		local factionTable = getElementData(getLocalPlayer(), "faction")
		local organizedTable = {}
		for i, k in pairs(factionTable) do
			organizedTable[k.count] = i
		end

		for k, id in ipairs(organizedTable) do
			if id ~= factionID then
				ftab[id] = guiCreateTab(getFactionName(id), ftabs)
				setElementData(ftab[id], "factionID", id)
				addEventHandler("onClientGUITabSwitched", ftab[id], loadFaction, false)
			end
		end
		--[[ftab[-1] = guiCreateTab("+", ftabs)
		addEventHandler("onClientGUITabSwitched", ftab[-1], function()
			outputChatBox("This feature is for beta testers only.", 255, 0, 0)
		end, false)]]

		tabs = guiCreateTabPanel(0.008, 0.01, 0.985, 0.97, true, ftab[factionID])
		tabOverview = guiCreateTab("Overview", tabs)

		-- Make members list
		gMemberGrid = guiCreateGridList(0.01, 0.015, 0.8, 0.905, true, tabOverview)

		colName = guiGridListAddColumn(gMemberGrid, "Name", 0.20)
		colRank = guiGridListAddColumn(gMemberGrid, "Rank", 0.20)
		colOnline = guiGridListAddColumn(gMemberGrid, "Status", 0.115)
		colLastLogin = guiGridListAddColumn(gMemberGrid, "Last Login", 0.13)

		local factionType = tonumber(getElementData(theTeam, "type"))

		if (factionType==2) or (factionType==3) or (factionType==4) or (factionType==5) or (factionType==6) or (factionType==7) then -- Added Mechanic type \ Adams
			--colLocation = guiGridListAddColumn(gMemberGrid, "Location", 0.12)
			colWage = guiGridListAddColumn(gMemberGrid, "Wage ($)", 0.06)
		--else
			--colLocation = guiGridListAddColumn(gMemberGrid, "Location", 0.1)
		end

		if phone then
			colPhone = guiGridListAddColumn(gMemberGrid, "Phone No.", 0.08)
		end

		local factionPackages = exports.duty:getFactionPackages(factionID)
		if factionPackages and factionType >= 2 then
			colDuty = guiGridListAddColumn(gMemberGrid, "Duty", 0.06)
		end

		local localPlayerIsLeader = nil
		local counterOnline, counterOffline = 0, 0

		for k, v in ipairs(rankOrder) do
			local rID = tonumber(v)
			for x,y in pairs(memberRanks) do
				local y = tonumber(y)
				if rID == y then
					local row = guiGridListAddRow(gMemberGrid)
					guiGridListSetItemText(gMemberGrid, row, colName, string.gsub(tostring(memberUsernames[x]), "_", " "), false, false)

					local theRank = tonumber(rID)
					local rankName = factionRanks[theRank]
					guiGridListSetItemText(gMemberGrid, row, colRank, tostring(rankName), false, false)
					guiGridListSetItemData(gMemberGrid, row, colRank, tostring(theRank))
			
					local login = "Never"
					if (not memberLastLogin[x]) then
						login = "Never"
					else
						if (memberLastLogin[x]==0) then
							login = "Today"
						elseif (memberLastLogin[x]==1) then
							login = tostring(memberLastLogin[x]) .. " day ago"
						else
							login = tostring(memberLastLogin[x]) .. " days ago"
						end
					end
					guiGridListSetItemText(gMemberGrid, row, colLastLogin, login, false, false)
					--guiGridListSetItemText(gMemberGrid, row, colLocation, memberLocation[x], false, false)

					if (factionType==2) or (factionType==3) or (factionType==4) or (factionType==5) or (factionType==6) or (factionType==7) then -- Added Mechanic type \ Adams
						local rankWage = factionWages[theRank] or 0
						guiGridListSetItemText(gMemberGrid, row, colWage, tostring(rankWage), false, true)
					end

					if (memberOnline[x]) then
						guiGridListSetItemText(gMemberGrid, row, colOnline, "Online", false, false)
						guiGridListSetItemColor(gMemberGrid, row, colOnline, 0, 255, 0)
						counterOnline = counterOnline + 1
					else
						guiGridListSetItemText(gMemberGrid, row, colOnline, "Offline", false, false)
						guiGridListSetItemColor(gMemberGrid, row, colOnline, 255, 0, 0)
						counterOffline = counterOffline + 1
					end



					if colDuty then
						if memberOnDuty[x] then
							guiGridListSetItemText(gMemberGrid, row, colDuty, "On duty", false, false)
							guiGridListSetItemColor(gMemberGrid, row, colDuty, 0, 255, 0)
						else
							guiGridListSetItemText(gMemberGrid, row, colDuty, "Off duty", false, false)
							guiGridListSetItemColor(gMemberGrid, row, colDuty, 255, 0, 0)
						end
					end

					if phone and colPhone then
						if membersPhone[x] then
							guiGridListSetItemText(gMemberGrid, row, colPhone, tostring(phone) .. "-" .. tostring(membersPhone[x]), false, true)
						else
							guiGridListSetItemText(gMemberGrid, row, colPhone, "", false, true)
						end
					end
				end
			end
		end	

		membersOnline = counterOnline
		membersOffline = counterOffline

		-- Update the window title
		guiSetText(ftab[factionID], tostring(teamName) .. " (" .. counterOnline .. " of " .. (counterOnline+counterOffline) .. " Members Online)")

		-- Make the buttons
		if (hasMemberPermissionTo(localPlayer, factionID, "del_member")) then
			gButtonKick = guiCreateButton(0.825, 0.076, 0.16, 0.06, "Boot Member", true, tabOverview)
			addEventHandler("onClientGUIClick", gButtonKick, btKickPlayer, false)
		end	
		if (hasMemberPermissionTo(localPlayer, factionID, "change_member_rank")) then
			gButtonPromote = guiCreateButton(0.825, 0.1526, 0.16, 0.06, "Promote/Demote Member", true, tabOverview)
			addEventHandler("onClientGUIClick", gButtonPromote, btPromotePlayer, false)	
		end
		
		if (factionType==2) or (factionType==3) or (factionType==4) or (factionType==5) or (factionType==6) or (factionType==7) then -- Added Mechanic type \ Adams
			if (hasMemberPermissionTo(localPlayer, factionID, "modify_ranks")) then
				gButtonEditRanks = guiCreateButton(0.825, 0.2292, 0.16, 0.06, "Edit Ranks and Wages", true, tabOverview)
				addEventHandler("onClientGUIClick", gButtonEditRanks, btEditRanks, false)
			end	
		else
			if (hasMemberPermissionTo(localPlayer, factionID, "modify_ranks")) then
				gButtonEditRanks = guiCreateButton(0.825, 0.2292, 0.16, 0.06, "Edit Ranks", true, tabOverview)
				addEventHandler("onClientGUIClick", gButtonEditRanks, btEditRanks, false)
			end	
		end
		if (hasMemberPermissionTo(localPlayer, factionID, "edit_motd")) then
			gButtonEditMOTD = guiCreateButton(0.825, 0.3058, 0.16, 0.06, "Edit MOTD", true, tabOverview)
			addEventHandler("onClientGUIClick", gButtonEditMOTD, btEditMOTD, false)
		end	
		if (hasMemberPermissionTo(localPlayer, factionID, "add_member")) then
			gButtonInvite = guiCreateButton(0.825, 0.3824, 0.16, 0.06, "Invite Member", true, tabOverview)
			addEventHandler("onClientGUIClick", gButtonInvite, btInvitePlayer, false)
		end	
		if (hasMemberPermissionTo(localPlayer, factionID, "respawn_vehs")) then
			gButtonRespawnui = guiCreateButton(0.825, 0.459, 0.16, 0.06, "Respawn Vehicles", true, tabOverview)
			addEventHandler("onClientGUIClick", gButtonRespawnui, showrespawn, false)
		end

			local _y = 0.5356
			if phone then
				gAssignPhone = guiCreateButton(0.825, _y, 0.16, 0.06, "Phone No.", true, tabOverview)
				addEventHandler("onClientGUIClick", gAssignPhone, btPhoneNumber, false)
				_y = _y + 0.0766
			end

			if factionType >= 2 then 
				if (hasMemberPermissionTo(localPlayer, factionID, "set_member_duty")) then
					gButtonPerk = guiCreateButton(0.825, _y, 0.16, 0.06, "Manage Duty Perks", true, tabOverview)
					addEventHandler("onClientGUIClick", gButtonPerk, btButtonPerk, false)
				end	
			end

			

			if (hasMemberPermissionTo(localPlayer, factionID, "respawn_vehs")) then
				tabVehicles = guiCreateTab("(Leader) Vehicles", tabs)

				gVehicleGrid = guiCreateGridList(0.01, 0.015, 0.8, 0.905, true, tabVehicles)

				colVehID = guiGridListAddColumn(gVehicleGrid, "ID (VIN)", 0.1)
				colVehModel = guiGridListAddColumn(gVehicleGrid, "Model", 0.30)
				colVehPlates = guiGridListAddColumn(gVehicleGrid, "Plate", 0.1)
				colVehLocation = guiGridListAddColumn(gVehicleGrid, "Location", 0.4)
				gButtonVehRespawn = guiCreateButton(0.825, 0.076, 0.16, 0.06, "Respawn Vehicle", true, tabVehicles)
				gButtonAllVehRespawn = guiCreateButton(0.825, 0.1526, 0.16, 0.06, "Respawn All Vehicles", true, tabVehicles)

				for index, vehID in ipairs(vehicleIDs) do
					local row = guiGridListAddRow(gVehicleGrid)
					guiGridListSetItemText(gVehicleGrid, row, colVehID, tostring(vehID), false, true)
					guiGridListSetItemText(gVehicleGrid, row, colVehModel, tostring(vehicleModels[index]), false, false)
					guiGridListSetItemText(gVehicleGrid, row, colVehPlates, tostring(vehiclePlates[index]), false, false)
					guiGridListSetItemText(gVehicleGrid, row, colVehLocation, tostring(vehicleLocations[index]), false, false)
				end
				addEventHandler("onClientGUIClick", gButtonVehRespawn, btRespawnOneVehicle, false)
				addEventHandler("onClientGUIClick", gButtonAllVehRespawn, showrespawn, false)
			end	

			if (hasMemberPermissionTo(localPlayer, factionID, "manage_interiors")) then
				tabProperties = guiCreateTab("(Leader) Properties", tabs)

				gPropertyGrid = guiCreateGridList(0.01, 0.015, 0.8, 0.905, true, tabProperties)

				colProID = guiGridListAddColumn(gPropertyGrid, "ID", 0.1)
				colName = guiGridListAddColumn(gPropertyGrid, "Name", 0.30)
				colProLocation = guiGridListAddColumn(gPropertyGrid, "Location", 0.4)

				for index, int in ipairs(properties) do
					local row = guiGridListAddRow(gPropertyGrid)
					guiGridListSetItemText(gPropertyGrid, row, colProID, tostring(int[1]), false, true)
					guiGridListSetItemText(gPropertyGrid, row, colName, tostring(int[2]), false, false)
					guiGridListSetItemText(gPropertyGrid, row, colProLocation, tostring(int[3]), false, false)
				end
			end
			if (hasMemberPermissionTo(localPlayer, factionID, "modify_factionl_note")) then
				tabNote = guiCreateTab("(Leader) Note", tabs)
				eNote = guiCreateMemo(0.01, 0.02, 0.98, 0.87, note or "", true, tabNote)
				gButtonSaveNote = guiCreateButton(0.79, 0.90, 0.2, 0.08, "Save", true, tabNote)
				addEventHandler("onClientGUIClick", gButtonSaveNote, btUpdateNote, false)
			end	
	
			-- towstats
			if towstats then
				if (hasMemberPermissionTo(localPlayer, factionID, "see_towstats")) then
					tabTowstats = guiCreateTab("(Leader) Towstats", tabs)
					gTowGrid = guiCreateGridList(0.01, 0.015, 0.8, 0.905, true, tabTowstats)
					local totals = {[0] = 0, [-1] = 0, [-2] = 0, [-3] = 0, [-4] = 0}
					local colName = guiGridListAddColumn(gTowGrid, 'Name', 0.2)
					local colRank = guiGridListAddColumn(gTowGrid, 'Rank', 0.2)
					local cols = {
						[0] = guiGridListAddColumn(gTowGrid, 'this week', 0.1),
						[-1] = guiGridListAddColumn(gTowGrid, 'last week', 0.1),
						[-2] = guiGridListAddColumn(gTowGrid, '2 weeks ago', 0.1),
						[-3] = guiGridListAddColumn(gTowGrid, '3 weeks ago', 0.1),
						[-4] = guiGridListAddColumn(gTowGrid, '4 weeks ago', 0.1)
					}
					for k, v in ipairs(memberUsernames) do
						local row = guiGridListAddRow(gTowGrid)
						guiGridListSetItemText(gTowGrid, row, colName, v:gsub("_", " "), false, false)
						local theRank = tonumber(memberRanks[k])
						local rankName = factionRanks[theRank]
						guiGridListSetItemText(gTowGrid, row, colRank, tostring(rankName), false, false)
						local stats = towstats[v] or {}
						for week, col in pairs(cols) do
							guiGridListSetItemText(gTowGrid, row, col, tostring(stats[week] or ""), false, true)
							totals[week] = totals[week] + (stats[week] or 0)
						end
					end
					local row = guiGridListAddRow(gTowGrid)
					guiGridListSetItemText(gTowGrid, row, colName, "Totals", true, false)
					for week, col in pairs(cols) do
						guiGridListSetItemText(gTowGrid, row, col, tostring(totals[week] or 0), true, true)
					end
				end	
			end
	
	
			-- for faction-wide note
			if hasMemberPermissionTo(localPlayer, factionID, "modify_faction_note") then
				tabFNote = guiCreateTab("Note", tabs)
				fNote = guiCreateMemo(0.01, 0.02, 0.98, 0.87, fnote or "", true, tabFNote)
				guiMemoSetReadOnly(fNote, false)
	
				gButtonSaveFNote = guiCreateButton(0.79, 0.90, 0.2, 0.08, "Save", true, tabFNote)
				addEventHandler("onClientGUIClick", gButtonSaveFNote, btUpdateFNote, false)
			else -- for faction-wide note
				tabFNote = guiCreateTab("Note", tabs)
				fNote = guiCreateMemo(0.01, 0.02, 0.98, 0.87, fnote or "", true, tabFNote)
				guiMemoSetReadOnly(fNote, true)
			end	
	
			if hasMemberPermissionTo(localPlayer, factionID, "manage_finance") then
				tabFinance = guiCreateTab("(Leader) Finance", tabs)
				addEventHandler("onClientGUITabSwitched", tabFinance, loadFinance)
			end	
	
			if factionType >= 2 then
				if (hasMemberPermissionTo(localPlayer, factionID, "modify_duty_settings")) then	
					tabDuty = guiCreateTab("(Leader) Duty Settings", tabs)
					addEventHandler("onClientGUITabSwitched", tabDuty, createDutyMain)
				end
			end

		

			gButtonQuit = guiCreateButton(0.825, 0.7834, 0.16, 0.06, "Leave Faction", true, tabOverview)
			gButtonExit = guiCreateButton(0.825, 0.86, 0.16, 0.06, "Exit Menu", true, tabOverview)
			gMOTDLabel = guiCreateLabel(0.015, 0.935, 0.95, 0.15, tostring(motd), true, tabOverview)
			guiSetFont(gMOTDLabel, "default-bold-small")

			addEventHandler("onClientGUIClick", gButtonQuit, btQuitFaction, false)
			addEventHandler("onClientGUIClick", gButtonExit, hideFactionMenu, false)

			guiSetEnabled(gButtonQuit, isPlayerInFaction(getLocalPlayer(), factionID))

			addEventHandler("onClientRender", getRootElement(), checkF3)
			f3state = getKeyState( "f3" )

			triggerEvent("hud:convertUI", localPlayer, gFactionWindow)
	else
		hideFactionMenu()
	end
	showCursor(true)
end
addEvent("showFactionMenu", true)
addEventHandler("showFactionMenu", getRootElement(), showFactionMenu)

function showrespawn()
	local sx, sy = guiGetScreenSize()

	showrespawnUI = guiCreateWindow(sx/2 - 150,sy/2 - 50,300,100,"Vehicle respawn", false)
	local lQuestion = guiCreateLabel(0.05,0.25,0.9,0.3,"Are you sure you want to respawn the faction vehicles?",true,showrespawnUI)
	guiLabelSetHorizontalAlign (lQuestion,"center",true)
	gButtonRespawn = guiCreateButton(0.1,0.65,0.37,0.23,"Yes",true,showrespawnUI)
	gButtonNo = guiCreateButton(0.53,0.65,0.37,0.23,"No",true,showrespawnUI)

	addEventHandler("onClientGUIClick", gButtonRespawn, btRespawnVehicles, false)
	addEventHandler("onClientGUIClick", gButtonNo, btRespawnVehicles, false)
	triggerEvent("hud:convertUI", localPlayer, showrespawnUI)
end
addEvent("showrespawn",true)
addEventHandler("showrespawn", getRootElement(), showrespawn)

-- BUTTON EVENTS

-- RANKS/WAGES

lRanks = { }
tRanks = { }
tRankWages = { }
wRanks = nil
bRanksSave, bRanksClose = nil

--[[function btEditRanks(button, state)
	if (source==gButtonEditRanks) and (button=="left") and (state=="up") then
		local factionType = tonumber(getElementData(theTeam, "type"))
		lRanks = { }
		tRanks = { }
		tRankWages = { }

		guiSetInputEnabled(true)

		local wages = (factionType==2) or (factionType==3) or (factionType==4) or (factionType==5) or (factionType==6) or (factionType==7)  -- Added Mechanic type \ Adams
		local width, height = 400, 540
		local scrWidth, scrHeight = guiGetScreenSize()
		local x = scrWidth/2 - (width/2)
		local y = scrHeight/2 - (height/2)

		wRanks = guiCreateWindow(x, y, width, height, "Ranks & Wages", false)

		local y = 0
		for i=1, 20 do
			y = ( y or 0 ) + 23
			lRanks[i] = guiCreateLabel(0.05 * width, y + 3, 0.4 * width, 20, "Rank #" .. i .. " Title & Wage: ", false, wRanks)
			guiSetFont(lRanks[i], "default-bold-small")
			tRanks[i] = guiCreateEdit(0.4 * width, y, ( wages and 0.33 or 0.55 ) * width, 20, arrFactionRanks[i], false, wRanks)
			if wages then
				tRankWages[i] = guiCreateEdit(0.75 * width, y, 0.2 * width, 20, tostring(arrFactionWages[i]), false, wRanks)
			end
		end

		bRanksSave = guiCreateButton(0.05, 0.900, 0.9, 0.045, "Save!", true, wRanks)
		bRanksClose = guiCreateButton(0.05, 0.950, 0.9, 0.045, "Close", true, wRanks)

		addEventHandler("onClientGUIClick", bRanksSave, saveRanks, false)
		addEventHandler("onClientGUIClick", bRanksClose, closeRanks, false)

		triggerEvent("hud:convertUI", localPlayer, wRanks)
	end
end]]--

function saveRanks(button, state)
	if (source==bRanksSave) and (button=="left") and (state=="up") then
		local found = false
		local isNumber = true
		for key, value in ipairs(tRanks) do
			if (string.find(guiGetText(tRanks[key]), ";")) or (string.find(guiGetText(tRanks[key]), "'")) then
				found = true
			end
		end

		local factionType = tonumber(getElementData(theTeam, "type"))
		if (factionType==2) or (factionType==3) or (factionType==4) or (factionType==5) or (factionType==6) or (factionType==7) then -- Added Mechanic type \ Adams
			for key, value in ipairs(tRankWages) do
				if not (tostring(type(tonumber(guiGetText(tRankWages[key])))) == "number") then
					isNumber = false
				end
			end
		end

		if (found) then
			outputChatBox("Your ranks contain invalid characters, please ensure it does not contain characters such as '@.;", 255, 0, 0)
		elseif not (isNumber) then
			outputChatBox("Your wages are not numbers, please ensure you entered a number and no currency symbol.", 255, 0, 0)
		else
			local sendRanks = { }
			local sendWages = { }

			for key, value in ipairs(tRanks) do
				sendRanks[key] = guiGetText(tRanks[key])
			end

			if (factionType==2) or (factionType==3) or (factionType==4) or (factionType==5) or (factionType==6) or (factionType==7) then -- Added Mechanic type \ Adams
				for key, value in ipairs(tRankWages) do
					sendWages[key] = guiGetText(tRankWages[key])
				end
			end

			hideFactionMenu()
			if (factionType==2) or (factionType==3) or (factionType==4) or (factionType==5) or (factionType==6) or (factionType==7) then -- Added Mechanic type \ Adams
				triggerServerEvent("cguiUpdateRanks", getLocalPlayer(), sendRanks, sendWages, faction_tab)
			else
				triggerServerEvent("cguiUpdateRanks", getLocalPlayer(), sendRanks, nil, faction_tab)
			end
		end
	end
end

function closeRanks(button, state)
	if (source==bRanksClose) and (button=="left") and (state=="up") then
		if (wRanks) then
			destroyElement(wRanks)
			lRanks, tRanks, tRankWages, wRanks, bRanksSave, bRanksClose = nil, nil, nil, nil, nil, nil
			guiSetInputEnabled(false)
		end
	end
end

-- MOTD
wMOTD, tMOTD, bUpdate, bMOTDClose = nil
function btEditMOTD(button, state)
	if (source==gButtonEditMOTD) and (button=="left") and (state=="up") then
		if not (wMOTD) then
			local width, height = 300, 200
			local scrWidth, scrHeight = guiGetScreenSize()
			local x = scrWidth/2 - (width/2)
			local y = scrHeight/2 - (height/2)

			wMOTD = guiCreateWindow(x, y, width, height, "Message of the Day", false)
			tMOTD = guiCreateEdit(0.1, 0.2, 0.85, 0.1, tostring(theMotd), true, wMOTD)

			guiSetInputEnabled(true)

			bUpdate = guiCreateButton(0.1, 0.6, 0.85, 0.15, "Update!", true, wMOTD)
			addEventHandler("onClientGUIClick", bUpdate, sendMOTD, false)

			bMOTDClose= guiCreateButton(0.1, 0.775, 0.85, 0.15, "Close Window", true, wMOTD)
			addEventHandler("onClientGUIClick", bMOTDClose, closeMOTD, false)

			triggerEvent("hud:convertUI", localPlayer, wMOTD)
		else
			guiBringToFront(wMOTD)
		end
	end
end

function closeMOTD(button, state)
	if (source==bMOTDClose) and (button=="left") and (state=="up") then
		if (wMOTD) then
			destroyElement(wMOTD)
			wMOTD, tMOTD, bUpdate, bMOTDClose = nil, nil, nil, nil
		end
	end
end

function sendMOTD(button, state)
	if (source==bUpdate) and (button=="left") and (state=="up") then
		local motd = guiGetText(tMOTD)

		local found1 = string.find(motd, ";")
		local found2 = string.find(motd, "'")

		if (found1) or (found2) then
			outputChatBox("Your message contains invalid characters.", 255, 0, 0)
		else
			guiSetText(gMOTDLabel, tostring(motd))
			theMOTD = motd -- Store it clientside
			triggerServerEvent("cguiUpdateMOTD", getLocalPlayer(), motd, faction_tab)
		end
	end
end

-- NOTE
function btUpdateNote(button, state)
	if button == "left" and state == "up" then
		triggerServerEvent("faction:note", getLocalPlayer(), guiGetText(eNote), faction_tab)
	end
end

-- FACTION NOTE
function btUpdateFNote(button, state)
	if button == "left" and state == "up" then
		triggerServerEvent("faction:fnote", getLocalPlayer(), guiGetText(fNote), faction_tab)
	end
end

-- INVITE
wInvite, tInvite, lNameCheck, bInvite, bInviteClose, invitedPlayer = nil
function btInvitePlayer(button, state)
	if (source==gButtonInvite) and (button=="left") and (state=="up") then
		if not (wInvite) then
			local width, height = 300, 200
			local scrWidth, scrHeight = guiGetScreenSize()
			local x = scrWidth/2 - (width/2)
			local y = scrHeight/2 - (height/2)

			wInvite = guiCreateWindow(x, y, width, height, "Invite a Player", false)
			tInvite = guiCreateEdit(0.1, 0.2, 0.85, 0.1, "Partial Player Name", true, wInvite)
			addEventHandler("onClientGUIChanged", tInvite, checkNameExists)

			lNameCheck = guiCreateLabel(0.1, 0.325, 0.8, 0.3, "Player not found or multiple were found.", true, wInvite)
			guiSetFont(lNameCheck, "default-bold-small")
			guiLabelSetColor(lNameCheck, 255, 0, 0)
			guiLabelSetHorizontalAlign(lNameCheck, "center")

			guiSetInputEnabled(true)

			bInvite = guiCreateButton(0.1, 0.6, 0.85, 0.15, "Invite!", true, wInvite)
			guiSetEnabled(bInvite, false)
			addEventHandler("onClientGUIClick", bInvite, sendInvite, false)

			bCloseInvite = guiCreateButton(0.1, 0.775, 0.85, 0.15, "Close Window", true, wInvite)
			addEventHandler("onClientGUIClick", bCloseInvite, closeInvite, false)

			triggerEvent("hud:convertUI", localPlayer, wInvite)
		else
			guiBringToFront(wInvite)
		end
	end
end

function closeInvite(button, state)
	if (source==bCloseInvite) and (button=="left") and (state=="up") then
		if (wInvite) then
			destroyElement(wInvite)
			wInvite, tInvite, lNameCheck, bInvite, bInviteClose, invitedPlayer = nil, nil, nil, nil, nil, nil
		end
	end
end

function sendInvite(button, state)
	if (source==bInvite) and (button=="left") and (state=="up") then
		triggerServerEvent("cguiInvitePlayer", getLocalPlayer(), invitedPlayer, faction_tab)
	end
end

function checkNameExists(theEditBox)
	local found = nil
	local foundstr = ""
	local count = 0

	local players = getElementsByType("player")
	for key, value in ipairs(players) do
		local username = string.lower(tostring(getPlayerName(value)))
		if (string.find(username, string.lower(tostring(guiGetText(theEditBox))))) and (guiGetText(theEditBox)~="") then
			count = count + 1
			found = value
			foundstr = username
		end
	end

	if (count>1) then
		guiSetText(lNameCheck, "Multiple Found.")
		guiLabelSetColor(lNameCheck, 255, 255, 0)
		guiSetEnabled(bInvite, false)
	elseif (count==1) then
		guiSetText(lNameCheck, "Player Found. ("..foundstr..")")
		guiLabelSetColor(lNameCheck, 0, 255, 0)
		invitedPlayer = found
		guiSetEnabled(bInvite, true)
	elseif (count==0) then
		guiSetText(lNameCheck, "Player not found or multiple were found.")
		guiLabelSetColor(lNameCheck, 255, 0, 0)
		guiSetEnabled(bInvite, false)
	end
	guiLabelSetHorizontalAlign(lNameCheck, "center")
end

function btQuitFaction(button, state)
	if (button=="left") and (state=="up") and (source==gButtonQuit) then
		local numLeaders = 0
		local isLeader = false
		local localUsername = getPlayerName(getLocalPlayer())

		for k, v in ipairs(arrUsernames) do -- Find the player
			if (v==localUsername) then -- Found
				isLeader = arrLeaders[k]
			end
		end

		for k, v in ipairs(arrLeaders) do
			numLeaders = numLeaders + 1
		end

		--if (numLeaders==1) and (isLeader) then
			--outputChatBox("You must promote someone to lead this faction before quitting. You are the only leader.", 255, 0, 0)
		--else
			local sx, sy = guiGetScreenSize()
			wConfirmQuit = guiCreateWindow(sx/2 - 125,sy/2 - 50,250,100,"Leaving Confirmation", false)
			local lQuestion = guiCreateLabel(0.05,0.25,0.9,0.3,"Do you really want to leave " .. getTeamName(theTeam) .. "?",true,wConfirmQuit)
			guiLabelSetHorizontalAlign (lQuestion,"center",true)
			local bYes = guiCreateButton(0.1,0.65,0.37,0.23,"Yes",true,wConfirmQuit)
			local bNo = guiCreateButton(0.53,0.65,0.37,0.23,"No",true,wConfirmQuit)
			addEventHandler("onClientGUIClick", getRootElement(),
				function(button)
					if button=="left" and ( source == bYes or source == bNo ) then
						if source == bYes then
							hideFactionMenu()
							triggerServerEvent("cguiQuitFaction", getLocalPlayer(), faction_tab)
						end
						if wConfirmQuit then
							destroyElement(wConfirmQuit)
							wConfirmQuit = nil
						end
					end
				end
			)

			triggerEvent("hud:convertUI", localPlayer, wConfirmQuit)
		--end
	end
end

function btKickPlayer(button, state)
	if (button=="left") and (state=="up") and (source==gButtonKick) then
		local playerName = string.gsub(guiGridListGetItemText(gMemberGrid, guiGridListGetSelectedItem(gMemberGrid), 1), " ", "_")

		--if (playerName==getPlayerName(getLocalPlayer())) then
			--outputChatBox("You cannot kick yourself, quit instead.", thePlayer)
		--[[else]]if (playerName~="") then
			local row = guiGridListGetSelectedItem(gMemberGrid)
			guiGridListRemoveRow(gMemberGrid, row)

			local theTeamName = getTeamName(theTeam)

			outputChatBox("You removed " .. playerName:gsub("_", " ") .. " from the faction '" .. tostring(theTeamName) .. "'.", 0, 255, 0)
			triggerServerEvent("cguiKickPlayer", getLocalPlayer(), playerName, faction_tab)
		else
			outputChatBox("Please select a member to kick.")
		end
	end
end

function btButtonPerk(button, state)
	if (button=="left") and (state=="up") and (source==gButtonPerk) then
		local bPerkActivePlayer = guiGridListGetItemText(gMemberGrid, guiGridListGetSelectedItem(gMemberGrid), 1)
		local playerName = string.gsub(bPerkActivePlayer, " ", "_")
		if (playerName == "") then
			outputChatBox("Please select a member to manage.")
			return
		end
		triggerServerEvent("Duty:GetPackages", resourceRoot, faction_tab)
	end
end

wPerkWindow, bPerkSave, bPerkClose, bPerkChkTable, bPerkActivePlayer = nil
function gotPackages(factionPackages)
	bPerkChkTable = { }
	local bPerkActivePlayer = guiGridListGetItemText(gMemberGrid, guiGridListGetSelectedItem(gMemberGrid), 1)
	local playerName = string.gsub(bPerkActivePlayer, " ", "_")

	guiSetInputEnabled(true)

	local width, height = 500, 540
	local scrWidth, scrHeight = guiGetScreenSize()
	local x = scrWidth/2 - (width/2)
	local y = scrHeight/2 - (height/2)

	wPerkWindow = guiCreateWindow(x, y, width, height, "Faction perks for "..playerName, false)

	local factionPerks = false
	for k, v in ipairs(arrUsernames) do -- Find the player
		if (v==playerName) then -- Found
			factionPerks = arrPerks[k]
			--outputDebugString(getElementType(factionPerks))
			--outputDebugString(tostring(factionPerks))
		end
	end

	if not factionPerks then
		outputChatBox("Failed to load "..playerName.. " his faction perks")
		factionPerks = { }
	end

	local y = 0
	for index, factionPackage in pairs ( factionPackages ) do
		y = ( y or 0 ) + 20
		local tmpChk = guiCreateCheckBox(0.05 * width, y + 3, 0.4 * width, 17, factionPackage[2], false, false, wPerkWindow)
		guiSetFont(tmpChk, "default-bold-small")
		setElementData(tmpChk, "factionPackage:ID", factionPackage[1], false)
		setElementData(tmpChk, "factionPackage:selected", bPerkActivePlayer, false)

		for index, permissionID in pairs(factionPerks) do
			--outputDebugString(tostring(factionPackage["grantID"]) .. " vs "..tostring(permissionID))
			if (permissionID == factionPackage[1]) then
				--outputDebugString("win!")
				guiCheckBoxSetSelected (tmpChk, true)
			end
		end

		table.insert(bPerkChkTable, tmpChk)
	end

	bPerkSave = guiCreateButton(0.05, 0.900, 0.9, 0.045, "Save", true, wPerkWindow)
	bPerkClose = guiCreateButton(0.05, 0.950, 0.9, 0.045, "Close", true, wPerkWindow)
	addEventHandler("onClientGUIClick", bPerkSave,
		function (button, state)
			if (source == bPerkSave) and (button=="left") and (state=="up") then
				if (wPerkWindow) then
					local collectedPerks = { }
					for _, checkBox in ipairs ( bPerkChkTable ) do
						if ( guiCheckBoxGetSelected( checkBox ) ) then
							table.insert(collectedPerks, getElementData(checkBox, "factionPackage:ID") or -1 )
						end
					end

					triggerServerEvent("faction:perks:edit", getLocalPlayer(), collectedPerks, playerName, faction_tab)
					destroyElement(wPerkWindow)
					wPerkWindow, bPerkSave, bPerkClose, bPerkChkTable, bPerkActivePlayer = nil
					guiSetInputEnabled(false)
				end
			end
		end
	, false)
	addEventHandler("onClientGUIClick", bPerkClose,
		function (button, state)
			if (source == bPerkClose) and (button=="left") and (state=="up") then
				if (wPerkWindow) then
					destroyElement(wPerkWindow)
					wPerkWindow, bPerkSave, bPerkClose, bPerkChkTable, bPerkActivePlayer = nil
					guiSetInputEnabled(false)
				end
			end
		end
	, false)

	triggerEvent("hud:convertUI", localPlayer, wPerkWindow)
end
addEvent("Duty:GotPackages", true)
addEventHandler("Duty:GotPackages", resourceRoot, gotPackages)

function btRespawnOneVehicle(button, state)
	if button == "left" and state == "up" then
		local vehID = guiGridListGetItemText(gVehicleGrid, guiGridListGetSelectedItem(gVehicleGrid), 1)
		if vehID then
			triggerServerEvent("cguiRespawnOneVehicle", getLocalPlayer(), vehID, faction_tab)
		else
			outputChatBox("Please select a vehicle to respawn.", 255, 0, 0)
		end
	end
end


-- PHONE
local wPhone, tPhone
function btPhoneNumber(button, state)
	if (button=="left") and (state=="up") and (source==gAssignPhone) then
		local row = guiGridListGetSelectedItem(gMemberGrid)
		local playerName = guiGridListGetItemText(gMemberGrid, guiGridListGetSelectedItem(gMemberGrid), 1)
		if playerName ~= "" then
			local currentPhone = guiGridListGetItemText(gMemberGrid, row, colPhone):gsub(tmpPhone .. "%-", "")

			if not (wPhone) then
				local width, height = 300, 200
				local scrWidth, scrHeight = guiGetScreenSize()
				local x = scrWidth/2 - (width/2)
				local y = scrHeight/2 - (height/2)

				wPhone = guiCreateWindow(x, y, width, height, "Phone Number", false)
				tPhone = guiCreateEdit(0.3, 0.325, 0.85, 0.1, currentPhone, true, wPhone)
				guiSetProperty(tPhone, "ValidationString","[0-9]{0,2}")

				local tPre = guiCreateLabel(0.1, 0.325, 0.18, 0.1, tostring(tmpPhone) .. " -", true, wPhone)
				guiLabelSetHorizontalAlign(tPre, "right")
				guiSetFont(tPre, "default-bold-small")
				guiLabelSetVerticalAlign(tPre, "center")

				guiCreateLabel(0.1, 0.2, 0.8, 0.08, "Phone number for " .. playerName .. ":", true, wPhone)

				guiSetInputEnabled(true)

				bSet = guiCreateButton(0.1, 0.6, 0.85, 0.15, "Assign Phone No.", true, wPhone)
				addEventHandler("onClientGUIClick", bSet, setPhoneNumber, false)

				bClosePhone = guiCreateButton(0.1, 0.775, 0.85, 0.15, "Close Window", true, wPhone)
				addEventHandler("onClientGUIClick", bClosePhone, closePhone, false)


				addEventHandler("onClientGUIChanged", tPhone, function(element)
					guiSetEnabled(bSet, guiGetText(element) == "" or (#guiGetText(element) == 2 and type(tonumber(guiGetText(element))) == 'number' and numberIsUnused(tonumber(guiGetText(element)))))
					end, false)

				triggerEvent("hud:convertUI", localPlayer, wPhone)
			else
				guiBringToFront(wPhone)
			end
		else
			outputChatBox("Please select a member to toggle leader on.")
		end
	end
end

function closePhone(button, state)
	if (wPhone) then
		destroyElement(wPhone)
		wPhone = nil
	end
end

function setPhoneNumber(button, state)
	local text = guiGetText(tPhone)
	local num = tonumber(text)

	if text == "" then
		guiGridListSetItemText(gMemberGrid, guiGridListGetSelectedItem(gMemberGrid), colPhone, "", false, false)
	elseif #text and num then
		guiGridListSetItemText(gMemberGrid, guiGridListGetSelectedItem(gMemberGrid), colPhone, tostring(tmpPhone) .. "-" .. ("%02d"):format(num), false, true)
	else
		return "Invalid Format"
	end
	local playerName = guiGridListGetItemText(gMemberGrid, guiGridListGetSelectedItem(gMemberGrid), 1):gsub(" ", "_")

	triggerServerEvent("factionmenu:setphone", getLocalPlayer(), playerName, num, faction_tab)
	closePhone(button, state)
end

function numberIsUnused(number)
	local testText = tostring(tmpPhone) .. "-" .. ("%02d"):format(number)
	for i = 0, guiGridListGetRowCount(gMemberGrid) do
		if guiGridListGetItemText(gMemberGrid, i, colPhone) == testText and i ~= guiGridListGetSelectedItem(gMemberGrid) then
			return false
		end
	end
	return true
end

--

function btPromotePlayer(button, state)
	if (button=="left") and (state=="up") and (source==gButtonPromote) then
		local rfunction btPromotePlayer()
		local row = guiGridListGetSelectedItem(gMemberGrid)
		local playerName = string.gsub(guiGridListGetItemText(gMemberGrid, guiGridListGetSelectedItem(gMemberGrid), 1), " ", "_")
		local currentRank = guiGridListGetItemText(gMemberGrid, row, 2)
		if (playerName == "") then
			outputChatBox("Select the player you wish to change the rank of first.", 255, 125, 0)
			return
		end
		triggerServerEvent("faction-system.showChangeRankGUI", resourceRoot, playerName, faction_tab)
	end
end	
	
	
function setPromotionRanks(rankTbl, rankName, playerName)
	local row = guiGridListGetSelectedItem(gMemberGrid)
	local playerName = string.gsub(guiGridListGetItemText(gMemberGrid, guiGridListGetSelectedItem(gMemberGrid), 1), " ", "_")
	local currentRank = guiGridListGetItemText(gMemberGrid, row, 2)
	if (playerName~="") then
		local currRankNumber = tonumber( guiGridListGetItemData(gMemberGrid, row, colRank) )
		-- Window
		local sX, sY = guiGetScreenSize()
		local wX, wY = 210, 316
		local sX, sY, wX, wY = (sX/2)-(wX/2),(sY/2)-(wY/2),wX,wY
		-- sX, sY, wX, wY = 699, 287, 210, 316
		wPromotions = guiCreateWindow(sX, sY, wX, wY, "Change Faction Rank", false)
		guiWindowSetSizable(wPromotions, false)
		-- Labels
		lPromotions1 = guiCreateLabel(14, 26, 150, 15, "Selected Member:", false, wPromotions)
		lPromotions2 = guiCreateLabel(13, 45, 182, 15, playerName, false, wPromotions)
		guiLabelSetHorizontalAlign(lPromotions2, "center", false)
		lPromotions3 = guiCreateLabel(14, 65, 89, 15, "Current Rank:", false, wPromotions)
		lPromotions4 = guiCreateLabel(13, 85, 182, 15, currentRank, false, wPromotions)
		guiLabelSetHorizontalAlign(lPromotions4, "center", false)
		-- Gridlist
		promotionsGridlist = guiCreateGridList(9, 105, 192, 168, false, wPromotions)
		guiGridListAddColumn(promotionsGridlist, "Rank List", 0.9)
		-- Button
		bPromotionsUpdate = guiCreateButton(9, 280, 93, 27, "Update Rank", false, wPromotions)
		bPromotionsCancel = guiCreateButton(112, 280, 89, 27, "Cancel", false, wPromotions)
		for i,rank in ipairs(rankTbl) do
			local row = guiGridListAddRow(promotionsGridlist)
			guiGridListSetItemText(promotionsGridlist, row, 1, rank[2], false, false)
		end

		addEventHandler("onClientGUIClick", bPromotionsUpdate, saveNewRank, false)
		addEventHandler("onClientGUIClick", bPromotionsCancel, function() destroyElement(wPromotions) end, false)
		triggerEvent("hud:convertUI", localPlayer, wPromotions)
	else
		outputChatBox("Please select a member to promote / demote.", 255, 0, 0)
	end
end
addEvent("faction-system.showChangeRankGUI", true)
addEventHandler("faction-system.showChangeRankGUI", root, setPromotionRanks)
	
	-- Change Member Rank -->>
function saveNewRank()
	local playerName = guiGetText(lPromotions2)
	local oldRank = guiGetText(lPromotions4)
	
	local row = guiGridListGetSelectedItem(promotionsGridlist)
	if (not row or row == -1) then
		outputChatBox("Select a rank that you want to set this person's rank to.", 255, 125, 0)
		return
	end
		
	local newRank = guiGridListGetItemText(promotionsGridlist, row, 1)
	triggerServerEvent("faction-system.saveNewRank", resourceRoot, playerName, oldRank, newRank, faction_tab)
	hideFactionMenu( )
	destroyElement(wPromotions)
end
	

function reselectItem(grid, row, col)
	guiGridListSetSelectedItem(grid, row, col)
end

function loadFaction(tab)
	if (wInvite) then
		destroyElement(wInvite)
		wInvite, tInvite, lNameCheck, bInvite, bInviteClose, invitedPlayer = nil, nil, nil, nil, nil, nil
	end

	if wPhone then
		destroyElement(wPhone)
		wPhone = nil
	end

	if (wMOTD) then
		destroyElement(wMOTD)
		wMOTD, tMOTD, bUpdate, bMOTDClose = nil, nil, nil, nil
	end

	if (isElement(wRanks)) then
		destroyElement(wRanks)
		lRanks, tRanks, tRankWages, wRanks, bRanksSave, bRanksClose = nil, nil, nil, nil, nil, nil
	end

	local t = getElementData(resourceRoot, "DutyGUI") or {}
	if t[getLocalPlayer()] then
		t[getLocalPlayer()] = nil
		setElementData(resourceRoot, "DutyGUI", t)
	end

	if isElement(DutyCreate.window[1]) then
		destroyElement(DutyCreate.window[1])
	end
	if isElement(DutyLocations.window[1]) then
		destroyElement(DutyLocations.window[1])
	end
	if isElement(DutySkins.window[1]) then
		destroyElement(DutySkins.window[1])
	end
	if isElement(DutyLocationMaker.window[1]) then
		destroyElement(DutyLocationMaker.window[1])
	end
	if isElement(DutyVehicleAdd.window[1]) then
		destroyElement(DutyVehicleAdd.window[1])
	end

	if isElement(promotionWindow[1]) then
		destroyElement(promotionWindow[1])
	end

	if tabs then
		destroyElement(tabs)
	end

	tabs = guiCreateTabPanel(0.008, 0.01, 0.985, 0.97, true, tab)
	tabOverview = guiCreateTab("Overview", tabs)
	-- Make members list
	gMemberGrid = guiCreateGridList(0.01, 0.015, 0.8, 0.905, true, tabOverview)
	colName = guiGridListAddColumn(gMemberGrid, "Name", 0.20)
	colRank = guiGridListAddColumn(gMemberGrid, "Rank", 0.20)
	colOnline = guiGridListAddColumn(gMemberGrid, "Status", 0.115)
	colLastLogin = guiGridListAddColumn(gMemberGrid, "Last Login", 0.13)

	-- Some buttons
	gButtonQuit = guiCreateButton(0.825, 0.7834, 0.16, 0.06, "Leave Faction", true, tabOverview)
	gButtonExit = guiCreateButton(0.825, 0.86, 0.16, 0.06, "Exit Menu", true, tabOverview)
	addEventHandler("onClientGUIClick", gButtonQuit, btQuitFaction, false)
	addEventHandler("onClientGUIClick", gButtonExit, hideFactionMenu, false)

	triggerServerEvent("faction:loadFaction", resourceRoot, getElementData(tab, "factionID"))
	faction_tab = getElementData(tab, "factionID")
	guiSetText(tab, "Loading...")
end

function fillFactionMenu(motd, memberUsernames, memberRanks, memberPerks, memberLeaders, memberOnline, memberLastLogin, factionRanks, factionWages, factionTheTeam, note, fnote, vehicleIDs, vehicleModels, vehiclePlates, vehicleLocations, memberOnDuty, towstats, phone, membersPhone, fromShowF, factionID, properties, factionRankID, rankOrder)
	if faction_tab ~= factionID or not isElement(tabs) then
		return
	end
	invitedPlayer = nil
	arrUsernames = memberUsernames
	arrRanks = memberRanks
	arrLeaders = memberLeaders
	arrPerks = memberPerks
	arrOnline = memberOnline
	arrLastLogin = memberLastLogin
	arrFactionRanks = factionRanks
	arrFactionWages = factionWages
	financeLoaded = false

	if (motd) == nil then motd = "" end
	theMotd = motd
	tmpPhone = phone
	local thePlayer = getLocalPlayer()
	theTeam = factionTheTeam
	local teamName = getTeamName(theTeam)
	local playerName = getPlayerName(thePlayer)

	local factionType = tonumber(getElementData(theTeam, "type"))
	if (factionType==2) or (factionType==3) or (factionType==4) or (factionType==5) or (factionType==6) or (factionType==7) then -- Added Mechanic type \ Adams
		colWage = guiGridListAddColumn(gMemberGrid, "Wage ($)", 0.06)
	end

	if phone then
		colPhone = guiGridListAddColumn(gMemberGrid, "Phone No.", 0.08)
	end

	local factionPackages = exports.duty:getFactionPackages(factionID)
	if factionPackages and factionType >= 2 then
		colDuty = guiGridListAddColumn(gMemberGrid, "Duty", 0.06)
	end

	local localPlayerIsLeader = nil
	local counterOnline, counterOffline = 0, 0
	for k, v in ipairs(rankOrder) do
		local rID = tonumber(v)
		for x,y in pairs(memberRanks) do
			local y = tonumber(y)
			if rID == y then
				local row = guiGridListAddRow(gMemberGrid)
				guiGridListSetItemText(gMemberGrid, row, colName, string.gsub(tostring(memberUsernames[x]), "_", " "), false, false)

				local theRank = tonumber(rID)
				local rankName = factionRanks[theRank]
				guiGridListSetItemText(gMemberGrid, row, colRank, tostring(rankName), false, false)
				guiGridListSetItemData(gMemberGrid, row, colRank, tostring(theRank))
		
				local login = "Never"
				if (not memberLastLogin[x]) then
					login = "Never"
				else
					if (memberLastLogin[x]==0) then
						login = "Today"
					elseif (memberLastLogin[x]==1) then
						login = tostring(memberLastLogin[x]) .. " day ago"
					else
						login = tostring(memberLastLogin[x]) .. " days ago"
					end
				end
				guiGridListSetItemText(gMemberGrid, row, colLastLogin, login, false, false)
				--guiGridListSetItemText(gMemberGrid, row, colLocation, memberLocation[x], false, false)

				if (factionType==2) or (factionType==3) or (factionType==4) or (factionType==5) or (factionType==6) or (factionType==7) then -- Added Mechanic type \ Adams
					local rankWage = factionWages[theRank] or 0
					guiGridListSetItemText(gMemberGrid, row, colWage, tostring(rankWage), false, true)
				end
				
				if (memberOnline[x]) then
					guiGridListSetItemText(gMemberGrid, row, colOnline, "Online", false, false)
					guiGridListSetItemColor(gMemberGrid, row, colOnline, 0, 255, 0)
					counterOnline = counterOnline + 1
				else
					guiGridListSetItemText(gMemberGrid, row, colOnline, "Offline", false, false)
					guiGridListSetItemColor(gMemberGrid, row, colOnline, 255, 0, 0)
					counterOffline = counterOffline + 1
				end
				
				-- Check if this is the local player
				if (tostring(memberUsernames[x])==playerName) then
					localPlayerIsLeader = memberLeaders[x]
				elseif fromShowF then
					localPlayerIsLeader = fromShowF
				end
				
				if colDuty then
					if memberOnDuty[x] then
						guiGridListSetItemText(gMemberGrid, row, colDuty, "On duty", false, false)
						guiGridListSetItemColor(gMemberGrid, row, colDuty, 0, 255, 0)
					else
						guiGridListSetItemText(gMemberGrid, row, colDuty, "Off duty", false, false)
						guiGridListSetItemColor(gMemberGrid, row, colDuty, 255, 0, 0)
					end
				end

				if phone and colPhone then
					if membersPhone[x] then
						guiGridListSetItemText(gMemberGrid, row, colPhone, tostring(phone) .. "-" .. tostring(membersPhone[x]), false, true)
					else
						guiGridListSetItemText(gMemberGrid, row, colPhone, "", false, true)
					end
				end
			end	
		end		
	end
	membersOnline = counterOnline
	membersOffline = counterOffline

	-- Update the window title
	guiSetText(ftab[factionID], tostring(teamName) .. " (" .. counterOnline .. " of " .. (counterOnline+counterOffline) .. " Members Online)")

	-- Make the buttons

		-- Make the buttons
		if (hasMemberPermissionTo(localPlayer, factionID, "del_member")) then
			gButtonKick = guiCreateButton(0.825, 0.076, 0.16, 0.06, "Boot Member", true, tabOverview)
			addEventHandler("onClientGUIClick", gButtonKick, btKickPlayer, false)
		end	

		if (hasMemberPermissionTo(localPlayer, factionID, "change_member_rank")) then
			gButtonPromote = guiCreateButton(0.825, 0.1526, 0.16, 0.06, "Promote/Demote Member", true, tabOverview)
			addEventHandler("onClientGUIClick", gButtonPromote, btPromotePlayer, false)	
		end
		
		if (factionType==2) or (factionType==3) or (factionType==4) or (factionType==5) or (factionType==6) or (factionType==7) then -- Added Mechanic type \ Adams
			if (hasMemberPermissionTo(localPlayer, factionID, "modify_ranks")) then
				gButtonEditRanks = guiCreateButton(0.825, 0.2292, 0.16, 0.06, "Edit Ranks and Wages", true, tabOverview)
				addEventHandler("onClientGUIClick", gButtonEditRanks, btEditRanks, false)
			end	
		else
			if (hasMemberPermissionTo(localPlayer, factionID, "modify_ranks")) then
				gButtonEditRanks = guiCreateButton(0.825, 0.2292, 0.16, 0.06, "Edit Ranks", true, tabOverview)
				addEventHandler("onClientGUIClick", gButtonEditRanks, btEditRanks, false)
			end	
		end

		if (hasMemberPermissionTo(localPlayer, factionID, "edit_motd")) then
			gButtonEditMOTD = guiCreateButton(0.825, 0.3058, 0.16, 0.06, "Edit MOTD", true, tabOverview)
			addEventHandler("onClientGUIClick", gButtonEditMOTD, btEditMOTD, false)
		end	
		
		if (hasMemberPermissionTo(localPlayer, factionID, "add_member")) then
			gButtonInvite = guiCreateButton(0.825, 0.3824, 0.16, 0.06, "Invite Member", true, tabOverview)
			addEventHandler("onClientGUIClick", gButtonInvite, btInvitePlayer, false)
		end	

		local _y = 0.5356
		if phone then
			gAssignPhone = guiCreateButton(0.825, _y, 0.16, 0.06, "Phone No.", true, tabOverview)
			addEventHandler("onClientGUIClick", gAssignPhone, btPhoneNumber, false)
			_y = _y + 0.0766
		end

		if factionType >= 2 then 
			if (hasMemberPermissionTo(localPlayer, factionID, "set_member_duty")) then
				gButtonPerk = guiCreateButton(0.825, _y, 0.16, 0.06, "Manage Duty Perks", true, tabOverview)
				addEventHandler("onClientGUIClick", gButtonPerk, btButtonPerk, false)
			end	
		end
		if (hasMemberPermissionTo(localPlayer, factionID, "respawn_vehs")) then
			gButtonRespawnui = guiCreateButton(0.825, 0.459, 0.16, 0.06, "Respawn Vehicles", true, tabOverview)
			addEventHandler("onClientGUIClick", gButtonRespawnui, showrespawn, false)

			tabVehicles = guiCreateTab("(Leader) Vehicles", tabs)

			gVehicleGrid = guiCreateGridList(0.01, 0.015, 0.8, 0.905, true, tabVehicles)

			colVehID = guiGridListAddColumn(gVehicleGrid, "ID (VIN)", 0.1)
			colVehModel = guiGridListAddColumn(gVehicleGrid, "Model", 0.30)
			colVehPlates = guiGridListAddColumn(gVehicleGrid, "Plate", 0.1)
			colVehLocation = guiGridListAddColumn(gVehicleGrid, "Location", 0.4)
			gButtonVehRespawn = guiCreateButton(0.825, 0.076, 0.16, 0.06, "Respawn Vehicle", true, tabVehicles)
			gButtonAllVehRespawn = guiCreateButton(0.825, 0.1526, 0.16, 0.06, "Respawn All Vehicles", true, tabVehicles)

			for index, vehID in ipairs(vehicleIDs) do
				local row = guiGridListAddRow(gVehicleGrid)
				guiGridListSetItemText(gVehicleGrid, row, colVehID, tostring(vehID), false, true)
				guiGridListSetItemText(gVehicleGrid, row, colVehModel, tostring(vehicleModels[index]), false, false)
				guiGridListSetItemText(gVehicleGrid, row, colVehPlates, tostring(vehiclePlates[index]), false, false)
				guiGridListSetItemText(gVehicleGrid, row, colVehLocation, tostring(vehicleLocations[index]), false, false)
			end
			addEventHandler("onClientGUIClick", gButtonVehRespawn, btRespawnOneVehicle, false)
			addEventHandler("onClientGUIClick", gButtonAllVehRespawn, showrespawn, false)
		end	

		if (hasMemberPermissionTo(localPlayer, factionID, "manage_interiors")) then
			tabProperties = guiCreateTab("(Leader) Properties", tabs)

			gPropertyGrid = guiCreateGridList(0.01, 0.015, 0.8, 0.905, true, tabProperties)

			colProID = guiGridListAddColumn(gPropertyGrid, "ID", 0.1)
			colName = guiGridListAddColumn(gPropertyGrid, "Name", 0.30)
			colProLocation = guiGridListAddColumn(gPropertyGrid, "Location", 0.4)

			for index, int in ipairs(properties) do
				local row = guiGridListAddRow(gPropertyGrid)
				guiGridListSetItemText(gPropertyGrid, row, colProID, tostring(int[1]), false, true)
				guiGridListSetItemText(gPropertyGrid, row, colName, tostring(int[2]), false, false)
				guiGridListSetItemText(gPropertyGrid, row, colProLocation, tostring(int[3]), false, false)
			end
		end	

		if (hasMemberPermissionTo(localPlayer, factionID, "modify_factionl_note")) then
			tabNote = guiCreateTab("(Leader) Note", tabs)
			eNote = guiCreateMemo(0.01, 0.02, 0.98, 0.87, note or "", true, tabNote)
			gButtonSaveNote = guiCreateButton(0.79, 0.90, 0.2, 0.08, "Save", true, tabNote)
			addEventHandler("onClientGUIClick", gButtonSaveNote, btUpdateNote, false)
		end	

		-- towstats
		if towstats then
			if (hasMemberPermissionTo(localPlayer, factionID, "see_towstats")) then
				tabTowstats = guiCreateTab("(Leader) Towstats", tabs)
				gTowGrid = guiCreateGridList(0.01, 0.015, 0.8, 0.905, true, tabTowstats)
				local totals = {[0] = 0, [-1] = 0, [-2] = 0, [-3] = 0, [-4] = 0}
				local colName = guiGridListAddColumn(gTowGrid, 'Name', 0.2)
				local colRank = guiGridListAddColumn(gTowGrid, 'Rank', 0.2)
				local cols = {
					[0] = guiGridListAddColumn(gTowGrid, 'this week', 0.1),
					[-1] = guiGridListAddColumn(gTowGrid, 'last week', 0.1),
					[-2] = guiGridListAddColumn(gTowGrid, '2 weeks ago', 0.1),
					[-3] = guiGridListAddColumn(gTowGrid, '3 weeks ago', 0.1),
					[-4] = guiGridListAddColumn(gTowGrid, '4 weeks ago', 0.1)
				}
				for k, v in ipairs(memberUsernames) do
					local row = guiGridListAddRow(gTowGrid)
					guiGridListSetItemText(gTowGrid, row, colName, v:gsub("_", " "), false, false)
					local theRank = tonumber(memberRanks[k])
					local rankName = factionRanks[theRank]
					guiGridListSetItemText(gTowGrid, row, colRank, tostring(rankName), false, false)
					local stats = towstats[v] or {}
					for week, col in pairs(cols) do
						guiGridListSetItemText(gTowGrid, row, col, tostring(stats[week] or ""), false, true)
						totals[week] = totals[week] + (stats[week] or 0)
					end
				end
				local row = guiGridListAddRow(gTowGrid)
				guiGridListSetItemText(gTowGrid, row, colName, "Totals", true, false)
				for week, col in pairs(cols) do
					guiGridListSetItemText(gTowGrid, row, col, tostring(totals[week] or 0), true, true)
				end
			end	
		end


		-- for faction-wide note
		if hasMemberPermissionTo(localPlayer, factionID, "modify_faction_note") then
			tabFNote = guiCreateTab("Note", tabs)
			fNote = guiCreateMemo(0.01, 0.02, 0.98, 0.87, fnote or "", true, tabFNote)
			guiMemoSetReadOnly(fNote, false)

			gButtonSaveFNote = guiCreateButton(0.79, 0.90, 0.2, 0.08, "Save", true, tabFNote)
			addEventHandler("onClientGUIClick", gButtonSaveFNote, btUpdateFNote, false)
		else -- for faction-wide note
			tabFNote = guiCreateTab("Note", tabs)
			fNote = guiCreateMemo(0.01, 0.02, 0.98, 0.87, fnote or "", true, tabFNote)
			guiMemoSetReadOnly(fNote, true)
		end	

		if hasMemberPermissionTo(localPlayer, factionID, "manage_finance") then
			tabFinance = guiCreateTab("(Leader) Finance", tabs)
			addEventHandler("onClientGUITabSwitched", tabFinance, loadFinance)
		end	

		if factionType >= 2 then
			if (hasMemberPermissionTo(localPlayer, factionID, "modify_duty_settings")) then	
				tabDuty = guiCreateTab("(Leader) Duty Settings", tabs)
				addEventHandler("onClientGUITabSwitched", tabDuty, createDutyMain)
			end
		end

	gMOTDLabel = guiCreateLabel(0.015, 0.935, 0.95, 0.15, tostring(motd), true, tabOverview)
	guiSetFont(gMOTDLabel, "default-bold-small")
	guiSetEnabled(gButtonQuit, isPlayerInFaction(getLocalPlayer(), factionID))
	triggerEvent("hud:convertUI", localPlayer, getElementParent(tabOverview))
end
addEvent("faction:fillFactionMenu", true)
addEventHandler("faction:fillFactionMenu", resourceRoot, fillFactionMenu)

function hideFactionMenu()
	showCursor(false)
	guiSetInputEnabled(false)

	if (gFactionWindow) then
		destroyElement(gFactionWindow)
		triggerEvent( 'hud:blur', resourceRoot, 'off' )
	end

	gFactionWindow, gMemberGrid = nil
	triggerServerEvent("factionmenu:hide", getLocalPlayer())

	if (wInvite) then
		destroyElement(wInvite)
		wInvite, tInvite, lNameCheck, bInvite, bInviteClose, invitedPlayer = nil, nil, nil, nil, nil, nil
	end

	if wPhone then
		destroyElement(wPhone)
		wPhone = nil
	end

	if (wMOTD) then
		destroyElement(wMOTD)
		wMOTD, tMOTD, bUpdate, bMOTDClose = nil, nil, nil, nil
	end

	if (isElement(wRanks)) then
		destroyElement(wRanks)
		lRanks, tRanks, tRankWages, wRanks, bRanksSave, bRanksClose = nil, nil, nil, nil, nil, nil
	end

	--[[if (showrespawn) then
		destroyElement(showrespawn)
		gButtonRespawn, bButtonNo = nil, nil

	end]]--
	local t = getElementData(resourceRoot, "DutyGUI") or {}
	if t[getLocalPlayer()] then
		t[getLocalPlayer()] = nil
		setElementData(resourceRoot, "DutyGUI", t)
	end

	if isElement(DutyCreate.window[1]) then
		destroyElement(DutyCreate.window[1])
	end
	if isElement(DutyLocations.window[1]) then
		destroyElement(DutyLocations.window[1])
	end
	if isElement(DutySkins.window[1]) then
		destroyElement(DutySkins.window[1])
	end
	if isElement(DutyLocationMaker.window[1]) then
		destroyElement(DutyLocationMaker.window[1])
	end
	if isElement(DutyVehicleAdd.window[1]) then
		destroyElement(DutyVehicleAdd.window[1])
	end

	if isElement(promotionWindow[1]) then
		destroyElement(promotionWindow[1])
	end

	-- Clear variables (should reduce lag a tiny bit clientside)
	gFactionWindow, gMemberGrid, gMOTDLabel, colName, colRank, colWage, colLastLogin, --[[colLocation,]] colOnline, gButtonKick, gButtonPromote, gButtonDemote, gButtonEditRanks, gButtonEditMOTD, gButtonInvite, gButtonLeader, gButtonQuit, gButtonExit = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
	theMotd, theTeam, arrUsernames, arrRanks, arrLeaders, arrOnline, arrFactionRanks, --[[arrLocations,]] arrFactionWages, arrLastLogin, membersOnline, membersOffline = nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil
	removeEventHandler("onClientRender", getRootElement(), checkF3)
end
addEvent("hideFactionMenu", true)
addEventHandler("hideFactionMenu", getRootElement(), hideFactionMenu)

function resourceStopped()
	showCursor(false)
	guiSetInputEnabled(false)

	setElementData(getLocalPlayer(), "savedLocations", false)
	setElementData(getLocalPlayer(), "savedSkins", false)
end
addEventHandler("onClientResourceStop", getResourceRootElement(), resourceStopped)

function btRespawnVehicles(button, state)
	if (button=="left") then
		if source == gButtonRespawn then
			hideFactionMenu()
			destroyElement(showrespawnUI)
			triggerServerEvent("cguiRespawnVehicles", getLocalPlayer(), faction_tab)
		elseif source == gButtonNo then
			hideFactionMenu()
			destroyElement(showrespawnUI)
		end
	end
end

function loadFinance()
	if source == tabFinance then
		if not financeLoaded then
			local label = guiCreateLabel(0,0,1,1,"Loading...",true,tabFinance)
			guiLabelSetHorizontalAlign(label, "center", false)
			guiLabelSetVerticalAlign(label, "center")
			triggerServerEvent("factionmenu:getFinance", getResourceRootElement(), faction_tab)
		end
	end
end

function fillFinance(factionID, bankThisWeek, bankPrevWeek, bankmoney, vehiclesvalue, propertiesvalue)
	financeLoaded = true
	for k,v in ipairs(getElementChildren(tabFinance)) do
		destroyElement(v)
	end

	local financeTabs = guiCreateTabPanel(10, 16, 1124, 380, false, tabFinance)
	--[[
	financeCombo = guiCreateComboBox(12, 8, 123, 70, "This week", false, tabFinance)
	guiComboBoxAddItem(financeCombo, "This week")
	guiComboBoxAddItem(financeCombo, "Last week")
	--]]

	tabWeeklyStatement = guiCreateTab("Weekly Statement", financeTabs)

		weeklyStatementGridlist = guiCreateGridList(13, 11, 395, 298, false, tabWeeklyStatement)
		statementColText = guiGridListAddColumn(weeklyStatementGridlist, "", 0.4)
		statementColLast = guiGridListAddColumn(weeklyStatementGridlist, "Last week", 0.25)
		statementColThis = guiGridListAddColumn(weeklyStatementGridlist, "This week", 0.25)

		assetsGridlist = guiCreateGridList(639, 11, 395, 298, false, tabWeeklyStatement)
		guiGridListAddColumn(assetsGridlist, "Assets", 0.65)
		guiGridListAddColumn(assetsGridlist, "Value", 0.25)

		local row = guiGridListAddRow(assetsGridlist)
		guiGridListSetItemText(assetsGridlist, row, 1, "Bank Account", false, false)
		if not bankmoney then bankmoney = 0 end
		guiGridListSetItemText(assetsGridlist, row, 2, "$"..tostring(exports.global:formatMoney(bankmoney)), false, false)
		local row = guiGridListAddRow(assetsGridlist)
		guiGridListSetItemText(assetsGridlist, row, 1, "Vehicles", false, false)
		if not vehiclesvalue then vehiclesvalue = 0 end
		guiGridListSetItemText(assetsGridlist, row, 2, "$"..tostring(exports.global:formatMoney(vehiclesvalue)), false, false)
		local row = guiGridListAddRow(assetsGridlist)
		guiGridListSetItemText(assetsGridlist, row, 1, "Properties", false, false)
		if not propertiesvalue then propertiesvalue = 0 end
		guiGridListSetItemText(assetsGridlist, row, 2, "$"..tostring(exports.global:formatMoney(propertiesvalue)), false, false)

		local row = guiGridListAddRow(assetsGridlist)
		guiGridListSetItemText(assetsGridlist, row, 1, "TOTAL", false, false)
		guiGridListSetItemText(assetsGridlist, row, 2, "$"..tostring(exports.global:formatMoney(bankmoney+vehiclesvalue+propertiesvalue)), false, false)

        local label1 = guiCreateLabel(413, 10, 156, 30, "Faction finance information goes maximum 2 weeks back.", false, tabWeeklyStatement)
        	guiSetFont(label1, "default-small")
        	guiLabelSetHorizontalAlign(label1, "left", true)

        local label2 = guiCreateLabel(413, 292, 156, 15, "Double-click a line to show details.", false, tabWeeklyStatement)
        	guiSetFont(label2, "default-small")

	tabTransactions = guiCreateTab("Transactions", financeTabs)
		transactionsGridlist = guiCreateGridList(0, 0, 1, 1, true, tabTransactions)
		local transactionColumns = {
			{ "ID", 0.09 },
			{ "Type", 0.03 },
			{ "From", 0.2 },
			{ "To", 0.2 },
			{ "Amount", 0.07 },
			{ "Date", 0.1 },
			{ "Week", 0.03 },
			{ "Reason", 0.24 }
		}
		for key, value in ipairs(transactionColumns) do
			guiGridListAddColumn(transactionsGridlist, value[1], value[2] or 0.1)
		end

	local factionName = getFactionName(factionID)

	thisWeek_income = {}
	thisWeek_expenses = {}
	lastWeek_income = {}
	lastWeek_expenses = {}

	for k,v in ipairs(bankThisWeek) do
		--outputDebugString("v.to = "..tostring(v.to))
		--[[
		if v.to == factionName then
			if v.amount > 0 then
				table.insert(thisWeek_income, v)
			elseif v.amount < 0 then
				table.insert(thisWeek_expenses, v)
			end
		elseif v.from == factionName then
			if v.amount > 0 then
				table.insert(thisWeek_expenses, v)
			elseif v.amount < 0 then
				table.insert(thisWeek_income, v)
			end
		end
		--]]
		if v.to == factionName then
			table.insert(thisWeek_income, v)
		elseif v.from == factionName then
			table.insert(thisWeek_expenses, v)
		end
	end
	for k,v in ipairs(bankPrevWeek) do
		if v.to == factionName then
			table.insert(lastWeek_income, v)
		elseif v.from == factionName then
			table.insert(lastWeek_expenses, v)
		end
	end

	--outputDebugString("#thisWeek_income="..tostring(#thisWeek_income))
	--outputDebugString("#thisWeek_expenses="..tostring(#thisWeek_expenses))
	--outputDebugString("#lastWeek_income="..tostring(#lastWeek_income))
	--outputDebugString("#lastWeek_expenses="..tostring(#lastWeek_expenses))

	transactionsByCategories = {
		["Income"] = {
			["Incoming Transfers"] = { ["thisWeek"] = {}, ["lastWeek"] = {} },
			["Bank Deposits"] = { ["thisWeek"] = {}, ["lastWeek"] = {} },
			["Sales"] = { ["thisWeek"] = {}, ["lastWeek"] = {} },
			["Bank Interest"] = { ["thisWeek"] = {}, ["lastWeek"] = {} },
			["Taxes"] = { ["thisWeek"] = {}, ["lastWeek"] = {} },
			["Insurance"] = { ["thisWeek"] = {}, ["lastWeek"] = {} },
			["Impound"] = { ["thisWeek"] = {}, ["lastWeek"] = {} },
			["Other"] = { ["thisWeek"] = {}, ["lastWeek"] = {} },
		},
		["Expenses"] = {
			["Outgoing Transfers"] = { ["thisWeek"] = {}, ["lastWeek"] = {} },
			["Bank Withdrawals"] = { ["thisWeek"] = {}, ["lastWeek"] = {} },
			["Wages"] = { ["thisWeek"] = {}, ["lastWeek"] = {} },
			["Fuel"] = { ["thisWeek"] = {}, ["lastWeek"] = {} },
			["Repair"] = { ["thisWeek"] = {}, ["lastWeek"] = {} },
			["Taxes"] = { ["thisWeek"] = {}, ["lastWeek"] = {} },
			["Bank Interest"] = { ["thisWeek"] = {}, ["lastWeek"] = {} },
			["Insurance"] = { ["thisWeek"] = {}, ["lastWeek"] = {} },
			["Supplies"] = { ["thisWeek"] = {}, ["lastWeek"] = {} },
			["Impound"] = { ["thisWeek"] = {}, ["lastWeek"] = {} },
			["Other"] = { ["thisWeek"] = {}, ["lastWeek"] = {} },
		}
	}
--[[
	Transaction Types:
	0: Withdraw Personal
	1: Deposit Personal
	2: Transfer from Personal to Personal
	3: Transfer from Business to Personal
	4: Withdraw Business
	5: Deposit Business
	6: Wage/State Benefits
	7: everything in payday except Wage/State Benefits
	8: faction budget
	9: fuel
	10: repair
	11: taxes
	12: bank interest
	13: Sales
	14: Insurance
	15: Supplies
	16: Impound
]]
	for k,v in ipairs(thisWeek_income) do
		local doWeek = "thisWeek"
		if v.type == 2 or v.type == 3 then
			table.insert(transactionsByCategories["Income"]["Incoming Transfers"][doWeek], v)
		elseif v.type == 1 or v.type == 5 then
			table.insert(transactionsByCategories["Income"]["Bank Deposits"][doWeek], v)
		elseif v.type == 11 then
			table.insert(transactionsByCategories["Income"]["Taxes"][doWeek], v)
		elseif v.type == 12 then
			table.insert(transactionsByCategories["Income"]["Bank Interest"][doWeek], v)
		elseif v.type == 13 then
			table.insert(transactionsByCategories["Income"]["Sales"][doWeek], v)
		elseif v.type == 14 then
			table.insert(transactionsByCategories["Income"]["Insurance"][doWeek], v)
		elseif v.type == 16 then
			table.insert(transactionsByCategories["Income"]["Impound"][doWeek], v)
		else
			table.insert(transactionsByCategories["Income"]["Other"][doWeek], v)
		end
	end
	for k,v in ipairs(thisWeek_expenses) do
		local doWeek = "thisWeek"
		if v.type == 2 or v.type == 3 then
			table.insert(transactionsByCategories["Expenses"]["Outgoing Transfers"][doWeek], v)
		elseif v.type == 0 or v.type == 4 then
			table.insert(transactionsByCategories["Expenses"]["Bank Withdrawals"][doWeek], v)
		elseif v.type == 6 then
			table.insert(transactionsByCategories["Expenses"]["Wages"][doWeek], v)
		elseif v.type == 9 then
			table.insert(transactionsByCategories["Expenses"]["Fuel"][doWeek], v)
		elseif v.type == 10 then
			table.insert(transactionsByCategories["Expenses"]["Repair"][doWeek], v)
		elseif v.type == 11 then
			table.insert(transactionsByCategories["Expenses"]["Taxes"][doWeek], v)
		elseif v.type == 12 then
			table.insert(transactionsByCategories["Expenses"]["Bank Interest"][doWeek], v)
		elseif v.type == 14 then
			table.insert(transactionsByCategories["Expenses"]["Insurance"][doWeek], v)
		elseif v.type == 15 then
			table.insert(transactionsByCategories["Expenses"]["Supplies"][doWeek], v)
		elseif v.type == 16 then
			table.insert(transactionsByCategories["Expenses"]["Impound"][doWeek], v)
		else
			table.insert(transactionsByCategories["Expenses"]["Other"][doWeek], v)
		end
	end
	for k,v in ipairs(lastWeek_income) do
		local doWeek = "lastWeek"
		if v.type == 2 or v.type == 3 then
			table.insert(transactionsByCategories["Income"]["Incoming Transfers"][doWeek], v)
		elseif v.type == 1 or v.type == 5 then
			table.insert(transactionsByCategories["Income"]["Bank Deposits"][doWeek], v)
		elseif v.type == 11 then
			table.insert(transactionsByCategories["Income"]["Taxes"][doWeek], v)
		elseif v.type == 12 then
			table.insert(transactionsByCategories["Income"]["Bank Interest"][doWeek], v)
		elseif v.type == 13 then
			table.insert(transactionsByCategories["Income"]["Sales"][doWeek], v)
		elseif v.type == 14 then
			table.insert(transactionsByCategories["Income"]["Insurance"][doWeek], v)
		elseif v.type == 16 then
			table.insert(transactionsByCategories["Income"]["Impound"][doWeek], v)
		else
			table.insert(transactionsByCategories["Income"]["Other"][doWeek], v)
		end
	end
	for k,v in ipairs(lastWeek_expenses) do
		local doWeek = "lastWeek"
		if v.type == 2 or v.type == 3 then
			table.insert(transactionsByCategories["Expenses"]["Outgoing Transfers"][doWeek], v)
		elseif v.type == 0 or v.type == 4 then
			table.insert(transactionsByCategories["Expenses"]["Bank Withdrawals"][doWeek], v)
		elseif v.type == 6 then
			table.insert(transactionsByCategories["Expenses"]["Wages"][doWeek], v)
		elseif v.type == 9 then
			table.insert(transactionsByCategories["Expenses"]["Fuel"][doWeek], v)
		elseif v.type == 10 then
			table.insert(transactionsByCategories["Expenses"]["Repair"][doWeek], v)
		elseif v.type == 11 then
			table.insert(transactionsByCategories["Expenses"]["Taxes"][doWeek], v)
		elseif v.type == 12 then
			table.insert(transactionsByCategories["Expenses"]["Bank Interest"][doWeek], v)
		elseif v.type == 14 then
			table.insert(transactionsByCategories["Expenses"]["Insurance"][doWeek], v)
		elseif v.type == 15 then
			table.insert(transactionsByCategories["Expenses"]["Supplies"][doWeek], v)
		elseif v.type == 16 then
			table.insert(transactionsByCategories["Expenses"]["Impound"][doWeek], v)
		else
			table.insert(transactionsByCategories["Expenses"]["Other"][doWeek], v)
		end
	end

	local totals = {}
	for k,v in pairs(transactionsByCategories) do
		local row = guiGridListAddRow(weeklyStatementGridlist)
		guiGridListSetItemText(weeklyStatementGridlist, row, statementColText, k, false, false)

		local total = { ["thisWeek"] = 0, ["lastWeek"] = 0 }
		--outputDebugString("k="..tostring(k).." v="..tostring(v))
		for k2, v2 in pairs(v) do
			--outputDebugString("k2="..tostring(k2).." v2="..tostring(v2))
			for k3, v3 in pairs(v2) do
				--outputDebugString("k3="..tostring(k3).." v3="..tostring(v3))
				for k4, v4 in ipairs(v3) do
					total[k3] = total[k3] + v4.amount
				end
			end
		end
		guiGridListSetItemText(weeklyStatementGridlist, row, statementColLast, "$"..tostring(exports.global:formatMoney(total["lastWeek"])), false, false)
		guiGridListSetItemText(weeklyStatementGridlist, row, statementColThis, "$"..tostring(exports.global:formatMoney(total["thisWeek"])), false, false)

		if total["lastWeek"] > 0 then
			guiGridListSetItemColor(weeklyStatementGridlist, row, statementColLast, 0, 148, 0)
		elseif total["lastWeek"] < 0 then
			guiGridListSetItemColor(weeklyStatementGridlist, row, statementColLast, 171, 0, 0)
		else
			guiGridListSetItemColor(weeklyStatementGridlist, row, statementColLast, 122, 122, 122)
		end
		if total["thisWeek"] > 0 then
			guiGridListSetItemColor(weeklyStatementGridlist, row, statementColThis, 0, 255, 0)
		elseif total["thisWeek"] < 0 then
			guiGridListSetItemColor(weeklyStatementGridlist, row, statementColThis, 255, 0, 0)
		else
			guiGridListSetItemColor(weeklyStatementGridlist, row, statementColThis, 255, 255, 255)
		end

		totals[k] = total
	end

	local profit_thisWeek = totals["Income"]["thisWeek"] + totals["Expenses"]["thisWeek"]
	local profit_lastWeek = totals["Income"]["lastWeek"] + totals["Expenses"]["lastWeek"]

	local row = guiGridListAddRow(weeklyStatementGridlist)
	guiGridListSetItemText(weeklyStatementGridlist, row, statementColText, "Profit", false, false)
	guiGridListSetItemText(weeklyStatementGridlist, row, statementColLast, "$"..tostring(exports.global:formatMoney(profit_lastWeek)), false, false)
	guiGridListSetItemText(weeklyStatementGridlist, row, statementColThis, "$"..tostring(exports.global:formatMoney(profit_thisWeek)), false, false)

	if profit_lastWeek > 0 then
		guiGridListSetItemColor(weeklyStatementGridlist, row, statementColLast, 0, 148, 0)
	elseif profit_lastWeek < 0 then
		guiGridListSetItemColor(weeklyStatementGridlist, row, statementColLast, 171, 0, 0)
	else
		guiGridListSetItemColor(weeklyStatementGridlist, row, statementColLast, 122, 122, 122)
	end
	if profit_thisWeek > 0 then
		guiGridListSetItemColor(weeklyStatementGridlist, row, statementColThis, 0, 255, 0)
	elseif profit_thisWeek < 0 then
		guiGridListSetItemColor(weeklyStatementGridlist, row, statementColThis, 255, 0, 0)
	else
		guiGridListSetItemColor(weeklyStatementGridlist, row, statementColThis, 255, 255, 255)
	end

	weeklyStatementGridlistMode = "overview"

	addEventHandler("onClientGUIDoubleClick", weeklyStatementGridlist, function()
		local selectedRow, selectedCol = guiGridListGetSelectedItem(weeklyStatementGridlist)
		local rowName = guiGridListGetItemText(weeklyStatementGridlist, selectedRow, statementColText)

		if(transactionsByCategories[rowName]) then

			weeklyStatementGridlistMode = rowName

			if tabStatementDetails then
				guiDeleteTab(tabStatementDetails, financeTabs)
				tabStatementDetails = nil
			end
			guiGridListClear(weeklyStatementGridlist)

			local row = guiGridListAddRow(weeklyStatementGridlist)
			guiGridListSetItemText(weeklyStatementGridlist, row, statementColText, "...", false, false)

			--outputDebugString("transactionsByCategories["..tostring(rowName).."] = "..tostring(transactionsByCategories[rowName]))
			--outputDebugString("#transactionsByCategories["..tostring(rowName).."] = "..tostring(#transactionsByCategories[rowName]))
			for k2, v2 in pairs(transactionsByCategories[rowName]) do
				--outputDebugString("k2="..tostring(k2).." v2="..tostring(v2))
				if(#v2["thisWeek"] > 0 or #v2["lastWeek"] > 0) then
					local row = guiGridListAddRow(weeklyStatementGridlist)
					guiGridListSetItemText(weeklyStatementGridlist, row, statementColText, k2, false, false)

					local total = { ["thisWeek"] = 0, ["lastWeek"] = 0 }
					for k3, v3 in pairs(v2) do
						--outputDebugString("k3="..tostring(k3).." v3="..tostring(v3))
						for k4, v4 in ipairs(v3) do
							--outputDebugString("k4="..tostring(k4).." v4="..tostring(v4))
							total[k3] = total[k3] + v4.amount
						end
					end

					guiGridListSetItemText(weeklyStatementGridlist, row, statementColLast, "$"..tostring(exports.global:formatMoney(total["lastWeek"])), false, false)
					guiGridListSetItemText(weeklyStatementGridlist, row, statementColThis, "$"..tostring(exports.global:formatMoney(total["thisWeek"])), false, false)

					if total["lastWeek"] > 0 then
						guiGridListSetItemColor(weeklyStatementGridlist, row, statementColLast, 0, 148, 0)
					elseif total["lastWeek"] < 0 then
						guiGridListSetItemColor(weeklyStatementGridlist, row, statementColLast, 171, 0, 0)
					else
						guiGridListSetItemColor(weeklyStatementGridlist, row, statementColLast, 122, 122, 122)
					end
					if total["thisWeek"] > 0 then
						guiGridListSetItemColor(weeklyStatementGridlist, row, statementColThis, 0, 255, 0)
					elseif total["thisWeek"] < 0 then
						guiGridListSetItemColor(weeklyStatementGridlist, row, statementColThis, 255, 0, 0)
					else
						guiGridListSetItemColor(weeklyStatementGridlist, row, statementColThis, 255, 255, 255)
					end
				end
			end

		elseif(rowName == "...") then

			weeklyStatementGridlistMode = "overview"

			if tabStatementDetails then
				guiDeleteTab(tabStatementDetails, financeTabs)
				tabStatementDetails = nil
			end
			guiGridListClear(weeklyStatementGridlist)

			local totals = {}
			for k,v in pairs(transactionsByCategories) do
				local row = guiGridListAddRow(weeklyStatementGridlist)
				guiGridListSetItemText(weeklyStatementGridlist, row, statementColText, k, false, false)

				local total = { ["thisWeek"] = 0, ["lastWeek"] = 0 }
				--outputDebugString("k="..tostring(k).." v="..tostring(v))
				for k2, v2 in pairs(v) do
					--outputDebugString("k2="..tostring(k2).." v2="..tostring(v2))
					for k3, v3 in pairs(v2) do
						--outputDebugString("k3="..tostring(k3).." v3="..tostring(v3))
						for k4, v4 in ipairs(v3) do
							total[k3] = total[k3] + v4.amount
						end
					end
				end
				guiGridListSetItemText(weeklyStatementGridlist, row, statementColLast, "$"..tostring(exports.global:formatMoney(total["lastWeek"])), false, false)
				guiGridListSetItemText(weeklyStatementGridlist, row, statementColThis, "$"..tostring(exports.global:formatMoney(total["thisWeek"])), false, false)

				if total["lastWeek"] > 0 then
					guiGridListSetItemColor(weeklyStatementGridlist, row, statementColLast, 0, 148, 0)
				elseif total["lastWeek"] < 0 then
					guiGridListSetItemColor(weeklyStatementGridlist, row, statementColLast, 171, 0, 0)
				else
					guiGridListSetItemColor(weeklyStatementGridlist, row, statementColLast, 122, 122, 122)
				end
				if total["thisWeek"] > 0 then
					guiGridListSetItemColor(weeklyStatementGridlist, row, statementColThis, 0, 255, 0)
				elseif total["thisWeek"] < 0 then
					guiGridListSetItemColor(weeklyStatementGridlist, row, statementColThis, 255, 0, 0)
				else
					guiGridListSetItemColor(weeklyStatementGridlist, row, statementColThis, 255, 255, 255)
				end

				totals[k] = total
			end

			local profit_thisWeek = totals["Income"]["thisWeek"] + totals["Expenses"]["thisWeek"]
			local profit_lastWeek = totals["Income"]["lastWeek"] + totals["Expenses"]["lastWeek"]

			local row = guiGridListAddRow(weeklyStatementGridlist)
			guiGridListSetItemText(weeklyStatementGridlist, row, statementColText, "Profit", false, false)
			guiGridListSetItemText(weeklyStatementGridlist, row, statementColLast, "$"..tostring(exports.global:formatMoney(profit_lastWeek)), false, false)
			guiGridListSetItemText(weeklyStatementGridlist, row, statementColThis, "$"..tostring(exports.global:formatMoney(profit_thisWeek)), false, false)

			if profit_lastWeek > 0 then
				guiGridListSetItemColor(weeklyStatementGridlist, row, statementColLast, 0, 148, 0)
			elseif profit_lastWeek < 0 then
				guiGridListSetItemColor(weeklyStatementGridlist, row, statementColLast, 171, 0, 0)
			else
				guiGridListSetItemColor(weeklyStatementGridlist, row, statementColLast, 122, 122, 122)
			end
			if profit_thisWeek > 0 then
				guiGridListSetItemColor(weeklyStatementGridlist, row, statementColThis, 0, 255, 0)
			elseif profit_thisWeek < 0 then
				guiGridListSetItemColor(weeklyStatementGridlist, row, statementColThis, 255, 0, 0)
			else
				guiGridListSetItemColor(weeklyStatementGridlist, row, statementColThis, 255, 255, 255)
			end

		elseif(rowName == "Profit") then

			--do nothing

		else

			if tabStatementDetails then
				guiDeleteTab(tabStatementDetails, financeTabs)
				tabStatementDetails = nil
			end

			tabStatementDetails = guiCreateTab("Details: "..tostring(rowName), financeTabs)
			transactionDetailsGridlist = guiCreateGridList(0, 0, 1, 1, true, tabStatementDetails)
			local transactionColumns = {
				{ "ID", 0.09 },
				{ "Type", 0.03 },
				{ "From", 0.2 },
				{ "To", 0.2 },
				{ "Amount", 0.07 },
				{ "Date", 0.1 },
				{ "Week", 0.03 },
				{ "Reason", 0.24 }
			}
			for key, value in ipairs(transactionColumns) do
				guiGridListAddColumn(transactionDetailsGridlist, value[1], value[2] or 0.1)
			end

			for k4,v4 in ipairs(transactionsByCategories[weeklyStatementGridlistMode][rowName]["thisWeek"]) do
				local row = guiGridListAddRow(transactionDetailsGridlist)
				guiGridListSetItemText(transactionDetailsGridlist, row, 1, tostring(v4.id), false, false)
				guiGridListSetItemText(transactionDetailsGridlist, row, 2, tostring(v4.type), false, false)
				guiGridListSetItemText(transactionDetailsGridlist, row, 3, tostring(v4.from), false, false)
				guiGridListSetItemText(transactionDetailsGridlist, row, 4, tostring(v4.to), false, false)
				guiGridListSetItemText(transactionDetailsGridlist, row, 5, tostring(exports.global:formatMoney(v4.amount)), false, false)
				if v4.amount > 0 then
					guiGridListSetItemColor(transactionDetailsGridlist, row, 5, 0, 255, 0)
				elseif v4.amount < 0 then
					guiGridListSetItemColor(transactionDetailsGridlist, row, 5, 255, 0, 0)
				end
				guiGridListSetItemText(transactionDetailsGridlist, row, 6, tostring(v4.time), false, false)
				guiGridListSetItemText(transactionDetailsGridlist, row, 7, tostring(v4.week), false, false)
				guiGridListSetItemText(transactionDetailsGridlist, row, 8, tostring(v4.reason), false, false)
			end
			for k4,v4 in ipairs(transactionsByCategories[weeklyStatementGridlistMode][rowName]["lastWeek"]) do
				local row = guiGridListAddRow(transactionDetailsGridlist)
				guiGridListSetItemText(transactionDetailsGridlist, row, 1, tostring(v4.id), false, false)
				guiGridListSetItemText(transactionDetailsGridlist, row, 2, tostring(v4.type), false, false)
				guiGridListSetItemText(transactionDetailsGridlist, row, 3, tostring(v4.from), false, false)
				guiGridListSetItemText(transactionDetailsGridlist, row, 4, tostring(v4.to), false, false)
				guiGridListSetItemText(transactionDetailsGridlist, row, 5, tostring(exports.global:formatMoney(v4.amount)), false, false)
				if v4.amount > 0 then
					guiGridListSetItemColor(transactionDetailsGridlist, row, 5, 0, 255, 0)
				elseif v4.amount < 0 then
					guiGridListSetItemColor(transactionDetailsGridlist, row, 5, 255, 0, 0)
				end
				guiGridListSetItemText(transactionDetailsGridlist, row, 6, tostring(v4.time), false, false)
				guiGridListSetItemText(transactionDetailsGridlist, row, 7, tostring(v4.week), false, false)
				guiGridListSetItemText(transactionDetailsGridlist, row, 8, tostring(v4.reason), false, false)
			end

			guiSetSelectedTab(financeTabs, tabStatementDetails)

		end
	end, false)

	for k,v in ipairs(bankThisWeek) do
		local row = guiGridListAddRow(transactionsGridlist)
		guiGridListSetItemText(transactionsGridlist, row, 1, tostring(v.id), false, false)
		guiGridListSetItemText(transactionsGridlist, row, 2, tostring(v.type), false, false)
		guiGridListSetItemText(transactionsGridlist, row, 3, tostring(v.from), false, false)
		guiGridListSetItemText(transactionsGridlist, row, 4, tostring(v.to), false, false)
		guiGridListSetItemText(transactionsGridlist, row, 5, tostring(exports.global:formatMoney(v.amount)), false, false)
		if v.amount > 0 then
			guiGridListSetItemColor(transactionsGridlist, row, 5, 0, 255, 0)
		elseif v.amount < 0 then
			guiGridListSetItemColor(transactionsGridlist, row, 5, 255, 0, 0)
		end
		guiGridListSetItemText(transactionsGridlist, row, 6, tostring(v.time), false, false)
		guiGridListSetItemText(transactionsGridlist, row, 7, tostring(v.week), false, false)
		guiGridListSetItemText(transactionsGridlist, row, 8, tostring(v.reason), false, false)
	end
	for k,v in ipairs(bankPrevWeek) do
		local row = guiGridListAddRow(transactionsGridlist)
		guiGridListSetItemText(transactionsGridlist, row, 1, tostring(v.id), false, false)
		guiGridListSetItemText(transactionsGridlist, row, 2, tostring(v.type), false, false)
		guiGridListSetItemText(transactionsGridlist, row, 3, tostring(v.from), false, false)
		guiGridListSetItemText(transactionsGridlist, row, 4, tostring(v.to), false, false)
		guiGridListSetItemText(transactionsGridlist, row, 5, tostring(exports.global:formatMoney(v.amount)), false, false)
		if v.amount > 0 then
			guiGridListSetItemColor(transactionsGridlist, row, 5, 0, 255, 0)
		elseif v.amount < 0 then
			guiGridListSetItemColor(transactionsGridlist, row, 5, 255, 0, 0)
		end
		guiGridListSetItemText(transactionsGridlist, row, 6, tostring(v.time), false, false)
		guiGridListSetItemText(transactionsGridlist, row, 7, tostring(v.week), false, false)
		guiGridListSetItemText(transactionsGridlist, row, 8, tostring(v.reason), false, false)
	end
	triggerEvent("hud:convertUI", localPlayer, financeTabs)
end
addEvent("factionmenu:fillFinance", true)
addEventHandler("factionmenu:fillFinance", getResourceRootElement(), fillFinance)

-- Made by Chaos for OwlGaming - Custom Duties
Duty = {
    gridlist = {},
    button = {},
    label = {}
}

customEditID = 0
locationEditID = 0

-- 35 for logs
function centerWindow (center_window)
    local screenW, screenH = guiGetScreenSize()
    local windowW, windowH = guiGetSize(center_window, false)
    local x, y = (screenW - windowW) /2,(screenH - windowH) /2
    guiSetPosition(center_window, x, y, false)
end

function beginLoad()
	guiGridListAddRow(Duty.gridlist[1])
	guiGridListSetItemText(Duty.gridlist[1], 0, 2, "Loading", false, false)

	guiGridListAddRow(Duty.gridlist[2])
	guiGridListSetItemText(Duty.gridlist[2], 0, 1, "Loading", false, false)

	guiGridListAddRow(Duty.gridlist[3])
	guiGridListSetItemText(Duty.gridlist[3], 0, 1, "Loading", false, false)

	--[[guiGridListAddRow(Duty.gridlist[4])
	guiGridListSetItemText(Duty.gridlist[4], 0, 1, "Loading", false, false)]]

	triggerServerEvent("fetchDutyInfo", resourceRoot, faction_tab)
end

function importData(custom, locations, factionID, message)
	if not isElement(gFactionWindow) then
		return
	end

	custom = custom or {}
	locations = locations or {}

	customg = custom
	locationsg = locations
	factionIDg = factionID
	forceDutyClose = true
	forceLocationClose = true
	if locationEditID == 0 then
		forceLocationClose = false
	end
	if customEditID == 0 then
		forceDutyClose = false
	end
	guiGridListClear( Duty.gridlist[1] )
	guiGridListClear( Duty.gridlist[2] )
	guiGridListClear( Duty.gridlist[3] )
	for k,v in pairs(custom) do
		local row = guiGridListAddRow(Duty.gridlist[2])

		guiGridListSetItemText(Duty.gridlist[2], row, 1, tostring(v[1]), false, true)
		guiGridListSetItemText(Duty.gridlist[2], row, 2, v[2], false, false)
		t = {}
		for key, val in pairs(v[4]) do
			table.insert(t, key)
		end
		guiGridListSetItemText(Duty.gridlist[2], row, 3, table.concat(t, ", "), false, false)
		if customEditID == tonumber(v[1]) then
			forceDutyClose = false
		end
	end
	for k,v in pairs(locations) do
		if not v[10] then
			local row = guiGridListAddRow(Duty.gridlist[1])

			guiGridListSetItemText(Duty.gridlist[1], row, 1, tostring(v[1]), false, true)
			guiGridListSetItemText(Duty.gridlist[1], row, 2, tostring(v[2]), false, false)
			guiGridListSetItemText(Duty.gridlist[1], row, 3, tostring(v[6]), false, false)
			guiGridListSetItemText(Duty.gridlist[1], row, 4, tostring(v[8]), false, false)
			guiGridListSetItemText(Duty.gridlist[1], row, 5, tostring(v[7]), false, false)
			guiGridListSetItemText(Duty.gridlist[1], row, 6, tostring(v[3]), false, false)
			guiGridListSetItemText(Duty.gridlist[1], row, 7, tostring(v[4]), false, false)
			guiGridListSetItemText(Duty.gridlist[1], row, 8, tostring(v[5]), false, false)
		else
			local row = guiGridListAddRow(Duty.gridlist[3])

			guiGridListSetItemText(Duty.gridlist[3], row, 1, tostring(v[1]), false, true)
			guiGridListSetItemText(Duty.gridlist[3], row, 2, tostring(v[9]), false, true)
			guiGridListSetItemText(Duty.gridlist[3], row, 3, getVehicleNameFromModel(v[10]), false, false)
			--[[table.insert(vehlocal, tostring(v[10]), v[11])
			table.remove(locations, k)]]
		end
		if locationEditID == tonumber(v[1]) then
			forceLocationClose = false
		end
	end
	if forceLocationClose or forceDutyClose then
		outputChatBox(message, 255, 0, 0)
		if forceDutyClose then
			if DutyCreate.window[1] then
				destroyElement(DutyCreate.window[1])
			end
			if DutyLocations.window[1] then
				destroyElement(DutyLocations.window[1])
			end
			if DutySkins.window[1] then
				destroyElement(DutySkins.window[1])
			end
		end
		if forceLocationClose then
			if DutyLocationMaker.window[1] then
				destroyElement(DutyLocationMaker.window[1])
			end
		end
	end
end
addEvent("importDutyData", true)
addEventHandler("importDutyData", resourceRoot, importData)

function refreshUI()
	guiGridListClear( Duty.gridlist[1] )
	guiGridListClear( Duty.gridlist[2] )
	guiGridListClear( Duty.gridlist[3] )
	for k,v in pairs(customg) do
		local row = guiGridListAddRow(Duty.gridlist[2])

		guiGridListSetItemText(Duty.gridlist[2], row, 1, tostring(v[1]), false, true)
		guiGridListSetItemText(Duty.gridlist[2], row, 2, v[2], false, false)
		t = {}
		for key, val in pairs(v[4]) do
			table.insert(t, key)
		end
		guiGridListSetItemText(Duty.gridlist[2], row, 3, table.concat(t, ", "), false, false)
	end
	for k,v in pairs(locationsg) do
		if not v[10] then
			local row = guiGridListAddRow(Duty.gridlist[1])

			guiGridListSetItemText(Duty.gridlist[1], row, 1, tostring(v[1]), false, true)
			guiGridListSetItemText(Duty.gridlist[1], row, 2, v[2], false, false)
			guiGridListSetItemText(Duty.gridlist[1], row, 3, v[6], false, false)
			guiGridListSetItemText(Duty.gridlist[1], row, 4, v[8], false, false)
			guiGridListSetItemText(Duty.gridlist[1], row, 5, v[7], false, false)
			guiGridListSetItemText(Duty.gridlist[1], row, 6, v[3], false, false)
			guiGridListSetItemText(Duty.gridlist[1], row, 7, v[4], false, false)
			guiGridListSetItemText(Duty.gridlist[1], row, 8, v[5], false, false)
		else
			local row = guiGridListAddRow(Duty.gridlist[3])

			guiGridListSetItemText(Duty.gridlist[3], row, 1, tostring(v[1]), false, true)
			guiGridListSetItemText(Duty.gridlist[3], row, 2, tostring(v[9]), false, true)
			guiGridListSetItemText(Duty.gridlist[3], row, 3, getVehicleNameFromModel(v[10]), false, false)
			--[[table.insert(vehlocal, tostring(v[10]), v[11])
			table.remove(locations, k)]]
		end
	end
end

function processLocationEdit()
	local r, c = guiGridListGetSelectedItem ( Duty.gridlist[1] )
	if r >= 0 then
		local x = guiGridListGetItemText ( Duty.gridlist[1], r, 6 )
		local y = guiGridListGetItemText ( Duty.gridlist[1], r, 7 )
		local z = guiGridListGetItemText ( Duty.gridlist[1], r, 8 )
		local rot = guiGridListGetItemText ( Duty.gridlist[1], r, 3 )
		local i = guiGridListGetItemText ( Duty.gridlist[1], r, 4 )
		local d = guiGridListGetItemText ( Duty.gridlist[1], r, 5 )
		local name = guiGridListGetItemText ( Duty.gridlist[1], r, 2 )
		locationEditID = tonumber(guiGridListGetItemText ( Duty.gridlist[1], r, 1 ))
		createDutyLocationMaker(x, y, z, rot, i, d, name)
	end
end

function processDutyEdit()
	local r, c = guiGridListGetSelectedItem ( Duty.gridlist[2] )
	if r >= 0 then
		local id = guiGridListGetItemText(Duty.gridlist[2], r, 1)
		customEditID = tonumber(id)
		createDuty()
	end
end

function createDutyMain()
	if isElement(Duty.gridlist[1]) then
		beginLoad()
		return
	end
    Duty.gridlist[1] = guiCreateGridList(0.0047, 0.046, 0.3, 0.89, true, tabDuty)
    guiGridListAddColumn(Duty.gridlist[1], "ID", 0.1)
    guiGridListAddColumn(Duty.gridlist[1], "Name", 0.2)
    guiGridListAddColumn(Duty.gridlist[1], "Radius", 0.1)
    guiGridListAddColumn(Duty.gridlist[1], "Interior", 0.1)
    guiGridListAddColumn(Duty.gridlist[1], "Dimension", 0.12)
    guiGridListAddColumn(Duty.gridlist[1], "X", 0.1)
    guiGridListAddColumn(Duty.gridlist[1], "Y", 0.1)
    guiGridListAddColumn(Duty.gridlist[1], "Z", 0.1)

    Duty.button[1] = guiCreateButton(0.005, 0.939, 0.09, 0.0504, "Add location", true, tabDuty)
    guiSetProperty(Duty.button[1], "NormalTextColour", "FFAAAAAA")
    addEventHandler("onClientGUIClick", Duty.button[1], createDutyLocationMaker, false)

    Duty.label[1] = guiCreateLabel(0.0059, 0.0076, 0.2625, 0.03, "Duty Locations", true, tabDuty)
    guiLabelSetHorizontalAlign(Duty.label[1], "center", false)
    Duty.button[2] = guiCreateButton(0.1, 0.939, 0.099, 0.0504, "Remove location", true, tabDuty)
    guiSetProperty(Duty.button[2], "NormalTextColour", "FFAAAAAA")
    addEventHandler("onClientGUIClick", Duty.button[2], removeLocation, false)

    Duty.button[3] = guiCreateButton(0.205, 0.939, 0.099, 0.0504, "Edit Duty Location", true, tabDuty)
    guiSetProperty(Duty.button[3], "NormalTextColour", "FFAAAAAA")
    addEventHandler("onClientGUIClick", Duty.button[3], processLocationEdit, false)
    addEventHandler("onClientGUIDoubleClick", Duty.gridlist[1], processLocationEdit, false)

    Duty.gridlist[2] = guiCreateGridList(0.66, 0.046, 0.3, 0.89, true, tabDuty)
    guiGridListAddColumn(Duty.gridlist[2], "ID", 0.2)
    guiGridListAddColumn(Duty.gridlist[2], "Name", 0.3)
    guiGridListAddColumn(Duty.gridlist[2], "Locations", 0.4)

    Duty.label[2] = guiCreateLabel(0.68, 0.0076, 0.2636, 0.03, "Duty Perks", true, tabDuty)
    guiLabelSetHorizontalAlign(Duty.label[2], "center", false)
    Duty.button[4] = guiCreateButton(0.66, 0.939, 0.09, 0.0504, "Add new duty", true, tabDuty)
    guiSetProperty(Duty.button[4], "NormalTextColour", "FFAAAAAA")
    addEventHandler("onClientGUIClick", Duty.button[4], createDuty, false)

    Duty.button[5] = guiCreateButton(0.765, 0.939, 0.09, 0.0504, "Remove Duty", true, tabDuty)
    guiSetProperty(Duty.button[5], "NormalTextColour", "FFAAAAAA")
    addEventHandler("onClientGUIClick", Duty.button[5], removeDuty, false)

    Duty.button[6] = guiCreateButton(0.869, 0.939, 0.09, 0.0504, "Edit Duty Perks", true, tabDuty)
    guiSetProperty(Duty.button[6], "NormalTextColour", "FFAAAAAA")
    addEventHandler("onClientGUIClick", Duty.button[6], processDutyEdit, false)
    addEventHandler("onClientGUIDoubleClick", Duty.gridlist[2], processDutyEdit, false)

    Duty.gridlist[3] = guiCreateGridList(0.3355, 0.046, 0.282, 0.472, true, tabDuty)
    guiGridListAddColumn(Duty.gridlist[3], "ID", 0.1)
    guiGridListAddColumn(Duty.gridlist[3], "Vehicle ID", 0.4)
    guiGridListAddColumn(Duty.gridlist[3], "Vehicle", 0.5)

    Duty.label[3] = guiCreateLabel(0.325, 0.0076, 0.2886, 0.03, "Duty Vehicle Locations", true, tabDuty)
    guiLabelSetHorizontalAlign(Duty.label[3], "center", false)
    Duty.button[8] = guiCreateButton(0.3355, 0.5304, 0.1, 0.0504, "Add Duty Vehicle", true, tabDuty)
    guiSetProperty(Duty.button[8], "NormalTextColour", "FFAAAAAA")
    addEventHandler("onClientGUIClick", Duty.button[8], createVehicleAdd, false)

    Duty.button[9] = guiCreateButton(0.5177, 0.5304, 0.1, 0.0504, "Remove Duty Vehicle", true, tabDuty)
    guiSetProperty(Duty.button[9], "NormalTextColour", "FFAAAAAA")
    addEventHandler("onClientGUIClick", Duty.button[9], removeVehicle, false)

   --[[Duty.gridlist[4] = guiCreateGridList(0.3355, 0.6, 0.282, 0.35, true, tabDuty) Was going to be for logs but meh UCP.
    guiGridListAddColumn(Duty.gridlist[4], "ID", 0.1)
    guiGridListAddColumn(Duty.gridlist[4], "Name", 0.3)
    guiGridListAddColumn(Duty.gridlist[4], "Action", 0.5)]]

    beginLoad()
	triggerEvent("hud:convertUI", localPlayer, tabDuty)
end

DutyCreate = {
    label = {},
    button = {},
    window = {},
    gridlist = {},
    edit = {}
}
function grabDetails(dutyID)
	triggerServerEvent("Duty:Grab", resourceRoot, faction_tab)

	guiGridListAddRow(DutyCreate.gridlist[1])
	guiGridListSetItemText(DutyCreate.gridlist[1], 0, 2, "Loading", false, false)

	guiGridListAddRow(DutyCreate.gridlist[2])
	guiGridListSetItemText(DutyCreate.gridlist[2], 0, 2, "Loading", false, false)

	guiGridListAddRow(DutyCreate.gridlist[3])
	guiGridListSetItemText(DutyCreate.gridlist[3], 0, 1, "Loading", false, false)

	guiGridListAddRow(DutyCreate.gridlist[4])
	guiGridListSetItemText(DutyCreate.gridlist[4], 0, 1, "Loading", false, false)
end

function isItemAllowed(id)
	for k,v in pairs(allowListg) do
		if tonumber(id) == tonumber(v[1]) then
			return true
		end
	end
	return false
end

function populateDuty(allowList)
	dutyItems = { }
	allowListg = allowList
	guiGridListClear( DutyCreate.gridlist[1] )
	guiGridListClear( DutyCreate.gridlist[2] )
	guiGridListClear( DutyCreate.gridlist[3] )
	guiGridListClear( DutyCreate.gridlist[4] )

	if customEditID ~= 0 then
		dutyItems = customg[customEditID][5]
		for k,v in pairs(customg[customEditID][5]) do
			if tonumber(v[2]) >= 0 then -- Items
				local row = guiGridListAddRow(DutyCreate.gridlist[4])

				guiGridListSetItemText(DutyCreate.gridlist[4], row, 1, exports["item-system"]:getItemName(v[2]), false, false) -- Item Name
				guiGridListSetItemText(DutyCreate.gridlist[4], row, 2, tostring(v[2]), false, true) -- Item ID
				guiGridListSetItemData(DutyCreate.gridlist[4], row, 1, { v[1], tonumber(v[2]), v[3] })

				if not isItemAllowed(v[1]) then
					guiGridListSetItemColor(DutyCreate.gridlist[4], row, 1, 255, 0, 0)
					guiGridListSetItemColor(DutyCreate.gridlist[4], row, 2, 255, 0, 0)
				end
			else -- Weapons
				local row = guiGridListAddRow(DutyCreate.gridlist[3])
				if tonumber(v[2]) == -100 then
					guiGridListSetItemText(DutyCreate.gridlist[3], row, 1, "Armor", false, false) -- Weapon Name
					guiGridListSetItemText(DutyCreate.gridlist[3], row, 2, tostring(v[3]), false, false) -- Ammo
					guiGridListSetItemData(DutyCreate.gridlist[3], row, 2, { v[1], tonumber(v[2]), v[3], v[4] })
				else
					guiGridListSetItemText(DutyCreate.gridlist[3], row, 1, exports["item-system"]:getItemName(v[2]), false, false) -- Weapon Name
					guiGridListSetItemText(DutyCreate.gridlist[3], row, 2, tostring(v[3]), false, false) -- Ammo
					guiGridListSetItemData(DutyCreate.gridlist[3], row, 2, { v[1], tonumber(v[2]), v[3], v[4] })
				end

				if not isItemAllowed(v[1]) then
					guiGridListSetItemColor(DutyCreate.gridlist[3], row, 1, 255, 0, 0)
					guiGridListSetItemColor(DutyCreate.gridlist[3], row, 2, 255, 0, 0)
				end
			end
		end
		guiSetText(DutyCreate.edit[3], customg[customEditID][2])
	end

	for k,v in pairs(allowList) do
		if tonumber(v[2]) >= 0 then -- Items
			if customEditID == 0 or (customEditID ~= 0 and not customg[customEditID][5][tostring(v[1])]) then
				local row = guiGridListAddRow(DutyCreate.gridlist[2])

				guiGridListSetItemText(DutyCreate.gridlist[2], row, 1, exports["item-system"]:getItemName(v[2]), false, false)
				guiGridListSetItemText(DutyCreate.gridlist[2], row, 2, exports["item-system"]:getItemDescription(v[2], v[3]), false, false)
				guiGridListSetItemData(DutyCreate.gridlist[2], row, 1, { v[1], tonumber(v[2]), v[3] })
			end
		else -- Weapons
			if customEditID == 0 or (customEditID ~= 0 and not customg[customEditID][5][tostring(v[1])]) then
				local row = guiGridListAddRow(DutyCreate.gridlist[1])
				if tonumber(v[2]) == -100 then
					guiGridListSetItemText(DutyCreate.gridlist[1], row, 1, "Armor", false, false)
					guiGridListSetItemText(DutyCreate.gridlist[1], row, 2, v[3], false, false)
					guiGridListSetItemData(DutyCreate.gridlist[1], row, 1, { v[1], tonumber(v[2]), v[3] })
				else
					guiGridListSetItemText(DutyCreate.gridlist[1], row, 1, exports["item-system"]:getItemName(v[2]), false, false)
					guiGridListSetItemText(DutyCreate.gridlist[1], row, 2, v[3], false, false)
					guiGridListSetItemData(DutyCreate.gridlist[1], row, 1, { v[1], tonumber(v[2]), v[3] })
				end
			end
		end
	end

end
addEvent("gotAllow", true)
addEventHandler("gotAllow", resourceRoot, populateDuty)

function populateLocations()
	if customEditID == 0 then
		tempLocations = getElementData(getLocalPlayer(), "savedLocations") or {}
	else
		tempLocations = getElementData(getLocalPlayer(), "savedLocations") or customg[customEditID][4]
	end

	for k,v in pairs(locationsg) do
		if not tempLocations[v[1]] then
			local row = guiGridListAddRow(DutyLocations.gridlist[1])

			guiGridListSetItemText(DutyLocations.gridlist[1], row, 1, tostring(v[1]), false, true)
			guiGridListSetItemText(DutyLocations.gridlist[1], row, 2, tostring(v[2]), false, false)
		end
	end

	for k,v in pairs(tempLocations) do
		local row = guiGridListAddRow(DutyLocations.gridlist[2])

		guiGridListSetItemText(DutyLocations.gridlist[2], row, 1, tostring(k), false, true)
		guiGridListSetItemText(DutyLocations.gridlist[2], row, 2, tostring(v), false, false)
	end
end

function checkAmmo()
	local r, c = guiGridListGetSelectedItem( DutyCreate.gridlist[1] )
	if r >= 0 then
		if tonumber(guiGetText(DutyCreate.edit[2])) then
			if tonumber(guiGridListGetItemText(DutyCreate.gridlist[1], r, 2)) >= tonumber(guiGetText( DutyCreate.edit[2] )) then
				guiLabelSetColor(DutyCreate.label[2], 0, 255, 0)
				guiSetText(DutyCreate.label[2], "Valid")
				guiSetEnabled(DutyCreate.button[3], true)
				return
			end
		end
	end
	guiLabelSetColor(DutyCreate.label[2], 255, 0, 0)
	guiSetText(DutyCreate.label[2], "Invalid")
	guiSetEnabled(DutyCreate.button[3], false)
end

function addDutyItem()
   	local r, c = guiGridListGetSelectedItem ( DutyCreate.gridlist[2] )
	if r >= 0 then
		local info = guiGridListGetItemData( DutyCreate.gridlist[2], r, 1 )
		local row = guiGridListAddRow(DutyCreate.gridlist[4])

		guiGridListSetItemText(DutyCreate.gridlist[4], row, 1, exports["item-system"]:getItemName(info[2]), false, false) -- Item Name
		guiGridListSetItemText(DutyCreate.gridlist[4], row, 2, tostring(info[2]), false, false) -- Item ID
		guiGridListSetItemData( DutyCreate.gridlist[4], row, 1, info )

		dutyItems[tostring(info[1])] = { info[1], tonumber(info[2]), info[3] }
		guiGridListRemoveRow( DutyCreate.gridlist[2], r )
	end
end

function removeDutyWeapon()
   	local r, c = guiGridListGetSelectedItem ( DutyCreate.gridlist[3] )
	if r >= 0 then
		local info = guiGridListGetItemData(DutyCreate.gridlist[3], r, 2)
		local red, g, b = guiGridListGetItemColor(DutyCreate.gridlist[3], r, 1)
		dutyItems[tostring(info[1])] = nil
		guiGridListRemoveRow( DutyCreate.gridlist[3], r)
		if red == 255 and g ~= 0 and b ~= 0 then
			local row = guiGridListAddRow(DutyCreate.gridlist[1])
			if tonumber(info[1]) == -100 then
				guiGridListSetItemText(DutyCreate.gridlist[1], row, 1, "Armor", false, false)
				guiGridListSetItemText(DutyCreate.gridlist[1], row, 2, tostring(info[4]), false, false)
				guiGridListSetItemData(DutyCreate.gridlist[1], row, 1, info)
			else
				guiGridListSetItemText(DutyCreate.gridlist[1], row, 1, exports["item-system"]:getItemName(info[2]), false, false)
				guiGridListSetItemText(DutyCreate.gridlist[1], row, 2, tostring(info[4]), false, false)
				guiGridListSetItemData(DutyCreate.gridlist[1], row, 1, info)
			end
		end
	end
end

function removeDutyItem()
   	local r, c = guiGridListGetSelectedItem ( DutyCreate.gridlist[4] )
	if r >= 0 then
		local info = guiGridListGetItemData(DutyCreate.gridlist[4], r, 1)
		local red, g, b = guiGridListGetItemColor(DutyCreate.gridlist[4], r, 1)
		dutyItems[tostring(info[1])] = nil
		guiGridListRemoveRow(DutyCreate.gridlist[4], r)
		if red == 255 and g ~= 0 and b ~= 0 then
			local row = guiGridListAddRow(DutyCreate.gridlist[2])

			guiGridListSetItemText(DutyCreate.gridlist[2], row, 1, exports["item-system"]:getItemName(tonumber(info[2])), false, false)
			guiGridListSetItemText(DutyCreate.gridlist[2], row, 2, exports["item-system"]:getItemDescription(tonumber(info[2]), info[3]), false, false)
			guiGridListSetItemData(DutyCreate.gridlist[2], row, 1, info)
		end
	end
end

function createDuty()
	if isElement(DutyCreate.window[1]) then
		destroyElement(DutyCreate.window[1])
		dutyItems = nil
	end

    DutyCreate.window[1] = guiCreateWindow(450, 310, 768, 566, "Duty Editing Window - Main", false)
    guiWindowSetSizable(DutyCreate.window[1], false)
    centerWindow(DutyCreate.window[1])

    DutyCreate.button[1] = guiCreateButton(600, 512, 158, 44, "Cancel", false, DutyCreate.window[1])
    guiSetProperty(DutyCreate.button[1], "NormalTextColour", "FFAAAAAA")
    addEventHandler("onClientGUIClick", DutyCreate.button[1], closeTheGUI, false)

    DutyCreate.button[2] = guiCreateButton(454, 512, 138, 44, "Save", false, DutyCreate.window[1])
    guiSetProperty(DutyCreate.button[2], "NormalTextColour", "FFAAAAAA")
    addEventHandler("onClientGUIClick", DutyCreate.button[2], saveGUI, false)

    DutyCreate.gridlist[1] = guiCreateGridList(11, 34, 427, 192, false, DutyCreate.window[1])
    --guiGridListAddColumn(DutyCreate.gridlist[1], "ID", 0.1)
    guiGridListAddColumn(DutyCreate.gridlist[1], "Weapon Name", 0.5)
    guiGridListAddColumn(DutyCreate.gridlist[1], "Max Amount of Ammo", 0.5)

    DutyCreate.gridlist[2] = guiCreateGridList(12, 247, 426, 208, false, DutyCreate.window[1])
   --guiGridListAddColumn(DutyCreate.gridlist[2], "ID", 0.1)
    guiGridListAddColumn(DutyCreate.gridlist[2], "Item Name", 0.3)
    guiGridListAddColumn(DutyCreate.gridlist[2], "Description", 0.7)

    DutyCreate.button[3] = guiCreateButton(444, 34, 128, 41, "-->", false, DutyCreate.window[1])
    guiSetProperty(DutyCreate.button[3], "NormalTextColour", "FFAAAAAA")
    addEventHandler("onClientGUIClick", DutyCreate.gridlist[1], checkAmmo)
    addEventHandler("onClientGUIClick", DutyCreate.button[3], function()
    	 -- Add Duty Weapon
    	local r, c = guiGridListGetSelectedItem ( DutyCreate.gridlist[1] )
		if r >= 0 then
			local maxammo = guiGridListGetItemText( DutyCreate.gridlist[1], r, 2 )
			local info = guiGridListGetItemData( DutyCreate.gridlist[1], r, 1 )
			local ammo = guiGetText( DutyCreate.edit[2] )

			local row = guiGridListAddRow(DutyCreate.gridlist[3])
			if tonumber(info[2]) == -100 then
				guiGridListSetItemText(DutyCreate.gridlist[3], row, 1, "Armor", false, false) -- Weapon Name
				guiGridListSetItemData(DutyCreate.gridlist[3], row, 2, info)
				guiGridListSetItemText(DutyCreate.gridlist[3], row, 2, ammo, false, false) -- Ammo
			else
				guiGridListSetItemText(DutyCreate.gridlist[3], row, 1, exports["item-system"]:getItemName(tonumber(info[2])), false, false) -- Weapon Name
				guiGridListSetItemData(DutyCreate.gridlist[3], row, 2, info)
				guiGridListSetItemText(DutyCreate.gridlist[3], row, 2, ammo, false, false) -- Ammo
			end

			dutyItems[tostring(info[1])] = { info[1], tonumber(info[2]), tonumber(ammo), info[3] }

			guiGridListRemoveRow( DutyCreate.gridlist[1], r )
		end
    end, false)
    DutyCreate.button[4] = guiCreateButton(444, 249, 128, 41, "-->", false, DutyCreate.window[1])
    guiSetProperty(DutyCreate.button[4], "NormalTextColour", "FFAAAAAA")
    addEventHandler("onClientGUIClick", DutyCreate.button[4], addDutyItem, false) -- Add Duty Item
    addEventHandler("onClientGUIDoubleClick", DutyCreate.gridlist[2], addDutyItem, false)

    DutyCreate.gridlist[3] = guiCreateGridList(582, 34, 176, 192, false, DutyCreate.window[1])
    guiGridListAddColumn(DutyCreate.gridlist[3], "Weapon", 0.5)
    guiGridListAddColumn(DutyCreate.gridlist[3], "Ammo", 0.3)

    --[[DutyCreate.edit[1] = guiCreateEdit(445, 298, 127, 27, "Item Value", false, DutyCreate.window[1])
    DutyCreate.label[1] = guiCreateLabel(444, 325, 128, 89, "Invalid", false, DutyCreate.window[1])
    guiLabelSetColor(DutyCreate.label[1], 255, 0, 0)
    guiLabelSetHorizontalAlign(DutyCreate.label[1], "center", false)]]
    DutyCreate.edit[2] = guiCreateEdit(445, 81, 127, 27, "Amount of Ammo", false, DutyCreate.window[1])
    DutyCreate.label[2] = guiCreateLabel(444, 108, 128, 77, "Invalid", false, DutyCreate.window[1])
    guiLabelSetColor(DutyCreate.label[2], 255, 0, 0)
    addEventHandler("onClientGUIChanged", DutyCreate.edit[2], checkAmmo)

    DutyCreate.gridlist[4] = guiCreateGridList(582, 248, 176, 207, false, DutyCreate.window[1])
    guiGridListAddColumn(DutyCreate.gridlist[4], "Item", 0.5)
    guiGridListAddColumn(DutyCreate.gridlist[4], "ID", 0.3)
    guiLabelSetHorizontalAlign(DutyCreate.label[2], "center", false)

    DutyCreate.button[5] = guiCreateButton(444, 185, 128, 41, "<---", false, DutyCreate.window[1])
    guiSetProperty(DutyCreate.button[5], "NormalTextColour", "FFAAAAAA")
    addEventHandler("onClientGUIClick", DutyCreate.button[5], removeDutyWeapon, false)
    addEventHandler("onClientGUIDoubleClick", DutyCreate.gridlist[3], removeDutyWeapon, false)
    DutyCreate.button[6] = guiCreateButton(444, 414, 128, 41, "<--", false, DutyCreate.window[1])
    guiSetProperty(DutyCreate.button[6], "NormalTextColour", "FFAAAAAA")
    addEventHandler("onClientGUIClick", DutyCreate.button[6], removeDutyItem, false)
    addEventHandler("onClientGUIDoubleClick", DutyCreate.gridlist[4], removeDutyItem, false)
    DutyCreate.button[7] = guiCreateButton(12, 511, 138, 45, "Skins", false, DutyCreate.window[1])
    guiSetProperty(DutyCreate.button[7], "NormalTextColour", "FFAAAAAA")
    addEventHandler("onClientGUIClick", DutyCreate.button[7], createSkins, false)

    DutyCreate.button[8] = guiCreateButton(160, 512, 138, 44, "Locations", false, DutyCreate.window[1])
    guiSetProperty(DutyCreate.button[8], "NormalTextColour", "FFAAAAAA")
    addEventHandler("onClientGUIClick", DutyCreate.button[8], createLocations, false)

    DutyCreate.label[3] = guiCreateLabel(57, 19, 319, 15, "Available Weapons", false, DutyCreate.window[1])
    guiLabelSetHorizontalAlign(DutyCreate.label[3], "center", false)
    DutyCreate.label[4] = guiCreateLabel(582, 17, 176, 17, "Duty Weapons", false, DutyCreate.window[1])
    guiLabelSetHorizontalAlign(DutyCreate.label[4], "center", false)
    DutyCreate.label[5] = guiCreateLabel(57, 228, 319, 15, "Available Items", false, DutyCreate.window[1])
    guiLabelSetHorizontalAlign(DutyCreate.label[5], "center", false)
    DutyCreate.label[6] = guiCreateLabel(583, 227, 175, 21, "Duty Items", false, DutyCreate.window[1])
    guiLabelSetHorizontalAlign(DutyCreate.label[6], "center", false)
    DutyCreate.label[7] = guiCreateLabel(14, 463, 88, 32, "Duty Name:", false, DutyCreate.window[1])
    guiLabelSetVerticalAlign(DutyCreate.label[7], "center")
    DutyCreate.edit[3] = guiCreateEdit(83, 462, 240, 33, "", false, DutyCreate.window[1])

	guiSetEnabled(DutyCreate.button[3], false)
    grabDetails()

	triggerEvent("hud:convertUI", localPlayer, DutyCreate.window[1])
end


DutyLocations = {
    gridlist = {},
    window = {},
    button = {},
    label = {}
}

function addLocationToDuty()
   	local r, c = guiGridListGetSelectedItem ( DutyLocations.gridlist[1] )
	if r >= 0 then
		local id = guiGridListGetItemText(DutyLocations.gridlist[1], r, 1)
		local name = guiGridListGetItemText(DutyLocations.gridlist[1], r, 2)

		guiGridListRemoveRow(DutyLocations.gridlist[1], r)
		local row = guiGridListAddRow(DutyLocations.gridlist[2])

		guiGridListSetItemText(DutyLocations.gridlist[2], row, 1, tostring(id), false, true)
		guiGridListSetItemText(DutyLocations.gridlist[2], row, 2, tostring(name), false, false)
		tempLocations[id] = name
	end
end

function removeLocationFromDuty()
   	local r, c = guiGridListGetSelectedItem ( DutyLocations.gridlist[2] )
	if r >= 0 then
		local id = guiGridListGetItemText(DutyLocations.gridlist[2], r, 1)
		local name = guiGridListGetItemText(DutyLocations.gridlist[2], r, 2)

		guiGridListRemoveRow(DutyLocations.gridlist[2], r)
		local row = guiGridListAddRow(DutyLocations.gridlist[1])

		guiGridListSetItemText(DutyLocations.gridlist[1], row, 1, tostring(id), false, true)
		guiGridListSetItemText(DutyLocations.gridlist[1], row, 2, tostring(name), false, false)
		tempLocations[id] = nil
	end
end

function createLocations()
	if isElement(DutyLocations.window[1]) then
		destroyElement(DutyLocations.window[1])
		tempLocations = nil
	end
    DutyLocations.window[1] = guiCreateWindow(573, 285, 520, 423, "Duty Editing Window - Locations", false)
    guiWindowSetSizable(DutyLocations.window[1], false)
    centerWindow(DutyLocations.window[1])

    DutyLocations.gridlist[1] = guiCreateGridList(9, 36, 240, 297, false, DutyLocations.window[1])
    guiGridListAddColumn(DutyLocations.gridlist[1], "ID", 0.2)
    guiGridListAddColumn(DutyLocations.gridlist[1], "Name", 0.9)

    DutyLocations.gridlist[2] = guiCreateGridList(270, 36, 240, 297, false, DutyLocations.window[1])
    guiGridListAddColumn(DutyLocations.gridlist[2], "ID", 0.2)
    guiGridListAddColumn(DutyLocations.gridlist[2], "Name", 0.9)

    DutyLocations.button[1] = guiCreateButton(9, 332, 240, 27, "-->", false, DutyLocations.window[1])
    guiSetProperty(DutyLocations.button[1], "NormalTextColour", "FFAAAAAA")
    addEventHandler("onClientGUIClick", DutyLocations.button[1], addLocationToDuty, false)
    addEventHandler("onClientGUIDoubleClick", DutyLocations.gridlist[1], addLocationToDuty, false)
    DutyLocations.button[2] = guiCreateButton(270, 332, 240, 27, "<--", false, DutyLocations.window[1])
    guiSetProperty(DutyLocations.button[2], "NormalTextColour", "FFAAAAAA")
    addEventHandler("onClientGUIClick", DutyLocations.button[2], removeLocationFromDuty, false)
    addEventHandler("onClientGUIDoubleClick", DutyLocations.gridlist[2], removeLocationFromDuty, false)
    DutyLocations.label[1] = guiCreateLabel(10, 19, 233, 17, "All locations", false, DutyLocations.window[1])
    guiLabelSetHorizontalAlign(DutyLocations.label[1], "center", false)
    DutyLocations.label[2] = guiCreateLabel(270, 19, 233, 17, "Duty locations", false, DutyLocations.window[1])
    guiLabelSetHorizontalAlign(DutyLocations.label[2], "center", false)
    DutyLocations.button[3] = guiCreateButton(270, 367, 146, 36, "Save", false, DutyLocations.window[1])
    guiSetProperty(DutyLocations.button[3], "NormalTextColour", "FFAAAAAA")
    addEventHandler("onClientGUIClick", DutyLocations.button[3], saveGUI, false)

    DutyLocations.button[4] = guiCreateButton(103, 367, 146, 36, "Cancel", false, DutyLocations.window[1])
    guiSetProperty(DutyLocations.button[4], "NormalTextColour", "FFAAAAAA")
    addEventHandler("onClientGUIClick", DutyLocations.button[4], closeTheGUI, false)

    populateLocations()

	triggerEvent("hud:convertUI", localPlayer, DutyLocations.window[1])
end

DutySkins = {
    edit = {},
    button = {},
    window = {},
    label = {},
    gridlist = {}
}

function skinAlreadyExists(skin, dupont)
	for k,v in pairs(dutyNewSkins) do
		if skin == v[1] and dupont == v[2] then
			return true
		end
	end
end

function addSkin()
	local raw = guiGetText(DutySkins.edit[1])
	if string.find(raw, ":") then
		local howAboutIt = split(raw, ":")
		if tonumber(howAboutIt[1]) and tonumber(howAboutIt[2]) then
			if not skinAlreadyExists(tonumber(howAboutIt[1]), tonumber(howAboutIt[2])) then
				table.insert(dutyNewSkins, { howAboutIt[1], howAboutIt[2] })
				local row = guiGridListAddRow(DutySkins.gridlist[1])

				guiGridListSetItemText(DutySkins.gridlist[1], row, 1, tostring(howAboutIt[1]), false, false)
				guiGridListSetItemText(DutySkins.gridlist[1], row, 2, tostring(howAboutIt[2]), false, false)
			else
				outputChatBox("You cannot add the same skin twice.", 255, 0, 0)
			end
		else
			outputChatBox("Please use only numbers.", 255, 0, 0)
		end
	else
		local raw = tonumber(raw)
		if raw then
			if not skinAlreadyExists(raw, "N/A") then
				table.insert(dutyNewSkins, { raw, "N/A" })
				local row = guiGridListAddRow(DutySkins.gridlist[1])

				guiGridListSetItemText(DutySkins.gridlist[1], row, 1, tostring(raw), false, false)
				guiGridListSetItemText(DutySkins.gridlist[1], row, 2, "N/A", false, false)
			else
				outputChatBox("You cannot add the same skin twice.", 255, 0, 0)
			end
		else
			outputChatBox("Please use only numbers.", 255, 0, 0)
		end
	end
	guiSetText(DutySkins.edit[1], "")
end

function removeSkin()
   	local r, c = guiGridListGetSelectedItem ( DutySkins.gridlist[1] )
	if r >= 0 then
		local skin = guiGridListGetItemText(DutySkins.gridlist[1], r, 1)
		local dupont = guiGridListGetItemText(DutySkins.gridlist[1], r, 2) -- ew dupont!

		for k,v in pairs(dutyNewSkins) do
			if tonumber(v[1]) == tonumber(skin) and tostring(v[2]) == dupont then
				table.remove(dutyNewSkins, k)
				break
			end
		end

		guiGridListRemoveRow(DutySkins.gridlist[1], r)
	end
end

local function formatSkin(v)
	return v[1]..(v[2] ~= 'N/A' and (":"..v[2]) or "")
end

function createSkins(customSkins)
	if DutySkins.window[1] and isElement(DutySkins.window[1]) and customSkins and type(customSkins)=='table' then
		destroyElement(DutySkins.label[1])
		for k,v in pairs(customSkins) do
			local row = guiGridListAddRow(DutySkins.gridlist[1])
			guiGridListSetItemText(DutySkins.gridlist[1], row, 1, v , false, false)
		end
	else
		closeDutySkins()
		DutySkins.window[1] = guiCreateWindow(1101, 372, 295, 267, "Duty Skins", false)
	    guiWindowSetSizable(DutySkins.window[1], false)
	    exports.global:centerWindow(DutySkins.window[1])

	    DutySkins.gridlist[1] = guiCreateGridList(10, 80, 132, 138, false, DutySkins.window[1])
	    guiGridListAddColumn(DutySkins.gridlist[1], "Custom Skins", 0.85)
	    guiSetVisible(DutySkins.gridlist[1], true)

	    DutySkins.label[1] = guiCreateLabel(10, 80, 132, 138, "Loading...", false, DutySkins.window[1])
		guiLabelSetHorizontalAlign(DutySkins.label[1], "center", false)
		guiLabelSetVerticalAlign(DutySkins.label[1], "center", false)
		triggerServerEvent('clothes:duty:fetchFactionSkins', localPlayer)

	    DutySkins.label[2] = guiCreateLabel(10, 27, 132, 20, "Skin ID: ", false, DutySkins.window[1])
	    DutySkins.edit[1] = guiCreateEdit(10, 47, 132, 20, "", false, DutySkins.window[1])

	    DutySkins.gridlist[2] = guiCreateGridList(152, 27, 132, 191, false, DutySkins.window[1])
	    guiGridListAddColumn(DutySkins.gridlist[2], "Added", 0.85)
	    if customEditID == 0 then
			dutyNewSkins = getElementData(getLocalPlayer(), "savedSkins") or {}
		else
			dutyNewSkins = getElementData(getLocalPlayer(), "savedSkins") or customg[customEditID][3]
		end
		for k,v in pairs(dutyNewSkins) do
			local row = guiGridListAddRow(DutySkins.gridlist[2])
			guiGridListSetItemText(DutySkins.gridlist[2], row, 1, formatSkin(v) , false, false)
		end

	    DutySkins.button[1] = guiCreateButton(10, 228, 87, 25, "Cancel", false, DutySkins.window[1])
	    DutySkins.button[2] = guiCreateButton(103, 228, 87, 25, "Add", false, DutySkins.window[1])
	    guiSetVisible(DutySkins.button[2], false)
	    DutySkins.button[3] = guiCreateButton(197, 228, 87, 25, "Save", false, DutySkins.window[1])

	    local r, c
	    addEventHandler('onClientGUIClick', DutySkins.window[1], function()
	    	-- click 'available skins' grid
	    	if source == DutySkins.gridlist[1] then
	    		guiSetVisible(DutySkins.button[2], false)
	    		guiGridListSetSelectedItem ( DutySkins.gridlist[2], -1, -1 )
	    		r, c = guiGridListGetSelectedItem ( DutySkins.gridlist[1] )
				if r >= 0 then
					guiSetVisible(DutySkins.button[2], true)
					guiSetText(DutySkins.button[2], "Add")
					guiSetText(DutySkins.edit[1], "")
				end
			-- click 'added skins' grid
	    	elseif source == DutySkins.gridlist[2] then
	    		guiSetVisible(DutySkins.button[2], false)
	    		guiGridListSetSelectedItem ( DutySkins.gridlist[1], -1, -1 )
	    		r, c = guiGridListGetSelectedItem ( DutySkins.gridlist[2] )
				if r >= 0 then
					guiSetVisible(DutySkins.button[2], true)
					guiSetText(DutySkins.button[2], "Remove")
				end
			-- click new clothes edit
			elseif source == DutySkins.edit[1] then
				guiSetVisible(DutySkins.button[2], false)
				guiGridListSetSelectedItem ( DutySkins.gridlist[1], -1, -1 )
				guiGridListSetSelectedItem ( DutySkins.gridlist[2], -1, -1 )
				local text = guiGetText(DutySkins.edit[1])
				guiSetText(DutySkins.button[2], 'Add')
				guiSetVisible(DutySkins.button[2], tonumber(text) and true or false)
			-- click action btn
			elseif source == DutySkins.button[2] then
				if guiGetText(DutySkins.button[2]) == "Remove" then
					local value = guiGridListGetItemText(DutySkins.gridlist[2], r, 1)
					for k,v in pairs(dutyNewSkins) do
						if formatSkin(v) == value then
							table.remove(dutyNewSkins, k)
							break
						end
					end
					guiGridListRemoveRow(DutySkins.gridlist[2], r)
				elseif guiGetText(DutySkins.button[2]) == 'Add' then
					r, c = guiGridListGetSelectedItem ( DutySkins.gridlist[1] )
					if r >= 0 then
						local raw = guiGridListGetItemText(DutySkins.gridlist[1], r, 1)
						local howAboutIt = split(raw, ":")
						if not skinAlreadyExists(tonumber(howAboutIt[1]), tonumber(howAboutIt[2])) then
							table.insert(dutyNewSkins, { tonumber(howAboutIt[1]), tonumber(howAboutIt[2]) })
							local row = guiGridListAddRow(DutySkins.gridlist[2])
							guiGridListSetItemText(DutySkins.gridlist[2], row, 1, formatSkin(howAboutIt), false, false)
						else
							outputChatBox("You cannot add the same skin twice.", 255, 0, 0)
						end
					else
						local raw = tonumber(guiGetText(DutySkins.edit[1]))
						if raw then
							if not skinAlreadyExists(raw, "N/A") then
								table.insert(dutyNewSkins, { raw, "N/A" })
								local row = guiGridListAddRow(DutySkins.gridlist[2])
								guiGridListSetItemText(DutySkins.gridlist[2], row, 1, raw , false, false)
							else
								outputChatBox("You cannot add the same skin twice.", 255, 0, 0)
							end
						else
							outputChatBox("Please use only numbers.", 255, 0, 0)
						end
						guiSetText(DutySkins.edit[1], "")
					end
				end
			-- click save
			elseif source == DutySkins.button[3] then
				setElementData(getLocalPlayer(), "savedSkins", dutyNewSkins)
				closeDutySkins()
			-- click cancel
			elseif source == DutySkins.button[1] then
				closeDutySkins()
	    	end
	    end)

		addEventHandler('onClientGUIChanged', DutySkins.edit[1], validateDutySkinEdit, false)

		triggerEvent("hud:convertUI", localPlayer, DutySkins.window[1])
	end
end
addEvent('faction:dutySkins', true)
addEventHandler('faction:dutySkins', root, createSkins)

function validateDutySkinEdit()
	local text = guiGetText(source)
	guiSetText(DutySkins.button[2], 'Add')
	guiSetVisible(DutySkins.button[2], tonumber(text) and true or false)
end

function closeDutySkins()
	if isElement(DutySkins.window[1]) then
		removeEventHandler('onClientGUIChanged', DutySkins.edit[1], validateDutySkinEdit)
		destroyElement(DutySkins.window[1])
		dutyNewSkins = nil
	end
end



DutyVehicleAdd = {
    button = {},
    window = {},
    edit = {}
}
function createVehicleAdd()
	if isElement(DutyVehicleAdd.window[1]) then
		destroyElement(DutyVehicleAdd.window[1])
	end
    DutyVehicleAdd.window[1] = guiCreateWindow(685, 338, 335, 85, "Add new duty vehicle", false)
    guiWindowSetSizable(DutyVehicleAdd.window[1], false)
    centerWindow(DutyVehicleAdd.window[1])

    DutyVehicleAdd.edit[1] = guiCreateEdit(9, 26, 181, 40, "Vehicle ID", false, DutyVehicleAdd.window[1])
    DutyVehicleAdd.button[1] = guiCreateButton(192, 26, 62, 40, "Add", false, DutyVehicleAdd.window[1])
    guiSetProperty(DutyVehicleAdd.button[1], "NormalTextColour", "FFAAAAAA")
    addEventHandler("onClientGUIClick", DutyVehicleAdd.button[1], saveGUI, false)

    DutyVehicleAdd.button[2] = guiCreateButton(263, 26, 62, 40, "Close", false, DutyVehicleAdd.window[1])
    guiSetProperty(DutyVehicleAdd.button[2], "NormalTextColour", "FFAAAAAA")
    addEventHandler( "onClientGUIClick", DutyVehicleAdd.button[2], closeTheGUI, false )

	triggerEvent("hud:convertUI", localPlayer, DutyVehicleAdd.window[1])
end

DutyLocationMaker = {
    button = {},
    window = {},
    edit = {},
    label = {}
}
function createDutyLocationMaker(x, y, z, r, i, d, name)
	if isElement(DutyLocationMaker.window[1]) then
		destroyElement(DutyLocationMaker.window[1])
	end
    DutyLocationMaker.window[1] = guiCreateWindow(638, 285, 488, 198, "Add duty location", false)
    guiWindowSetSizable(DutyLocationMaker.window[1], false)
    centerWindow(DutyLocationMaker.window[1])

    DutyLocationMaker.label[1] = guiCreateLabel(8, 24, 44, 19, "X Value:", false, DutyLocationMaker.window[1])
    DutyLocationMaker.edit[1] = guiCreateEdit(56, 24, 135, 20, "", false, DutyLocationMaker.window[1])
    DutyLocationMaker.label[2] = guiCreateLabel(201, 24, 53, 19, "Y Value:", false, DutyLocationMaker.window[1])
    DutyLocationMaker.edit[2] = guiCreateEdit(253, 23, 88, 20, "", false, DutyLocationMaker.window[1])
    DutyLocationMaker.label[3] = guiCreateLabel(355, 25, 52, 18, "Z Value:", false, DutyLocationMaker.window[1])
    DutyLocationMaker.edit[3] = guiCreateEdit(406, 23, 71, 20, "", false, DutyLocationMaker.window[1])
    DutyLocationMaker.label[4] = guiCreateLabel(8, 60, 49, 18, "Radius:", false, DutyLocationMaker.window[1])
    DutyLocationMaker.edit[4] = guiCreateEdit(53, 58, 82, 20, "1-10", false, DutyLocationMaker.window[1])
    DutyLocationMaker.label[5] = guiCreateLabel(162, 61, 72, 17, "Interior:", false, DutyLocationMaker.window[1])
    DutyLocationMaker.edit[5] = guiCreateEdit(216, 58, 93, 20, "", false, DutyLocationMaker.window[1])
    DutyLocationMaker.label[6] = guiCreateLabel(336, 60, 60, 18, "Dimension:", false, DutyLocationMaker.window[1])
    DutyLocationMaker.edit[6] = guiCreateEdit(402, 58, 75, 20, "", false, DutyLocationMaker.window[1])
    DutyLocationMaker.label[7] = guiCreateLabel(9, 92, 57, 21, "Name:", false, DutyLocationMaker.window[1])
    DutyLocationMaker.label[8] = guiCreateLabel(10, 119, 467, 28, "The name of the duty is used strictly for your identification.", false, DutyLocationMaker.window[1])
    guiLabelSetHorizontalAlign(DutyLocationMaker.label[8], "center", false)
    DutyLocationMaker.edit[7] = guiCreateEdit(51, 91, 426, 22, "", false, DutyLocationMaker.window[1])
    DutyLocationMaker.button[1] = guiCreateButton(10, 149, 115, 37, "Insert Current Position", false, DutyLocationMaker.window[1])
    guiSetProperty(DutyLocationMaker.button[1], "NormalTextColour", "FFAAAAAA")
    addEventHandler("onClientGUIClick", DutyLocationMaker.button[1], curPos, false)

    DutyLocationMaker.button[2] = guiCreateButton(184, 149, 115, 37, "Close", false, DutyLocationMaker.window[1])
    guiSetProperty(DutyLocationMaker.button[2], "NormalTextColour", "FFAAAAAA")
    addEventHandler("onClientGUIClick", DutyLocationMaker.button[2], closeTheGUI, false)

    DutyLocationMaker.button[3] = guiCreateButton(357, 149, 115, 37, "Save", false, DutyLocationMaker.window[1])
    guiSetProperty(DutyLocationMaker.button[3], "NormalTextColour", "FFAAAAAA")
    addEventHandler("onClientGUIClick", DutyLocationMaker.button[3], saveGUI, false)

    -- Populate List
    if name then
    	guiSetText(DutyLocationMaker.edit[1], x)
		guiSetText(DutyLocationMaker.edit[2], y)
		guiSetText(DutyLocationMaker.edit[3], z)
		guiSetText(DutyLocationMaker.edit[4], r)
		guiSetText(DutyLocationMaker.edit[5], i)
		guiSetText(DutyLocationMaker.edit[6], d)
		guiSetText(DutyLocationMaker.edit[7], name)
	end

	triggerEvent("hud:convertUI", localPlayer, DutyLocationMaker.window[1])
end

function duplicateVeh(type, id, faction)
	for k,v in ipairs(locationsg) do
		if v[10] == id then
			return true
		end
	end
end

-- Closing!
function closeTheGUI()
	if source == DutyCreate.button[1] then -- Main
		destroyElement(DutyCreate.window[1])
		customEditID = 0
		tempLocations = nil
		dutyNewSkins = nil
		dutyItems = nil
		setElementData(getLocalPlayer(), "savedLocations", false)
		setElementData(getLocalPlayer(), "savedSkins", false)
	elseif source == DutyLocations.button[4] then -- Main > Locations
		tempLocations = nil
		destroyElement(DutyLocations.window[1])
	elseif source == DutyVehicleAdd.button[2] then -- Vehicle Add
		destroyElement(DutyVehicleAdd.window[1])
	elseif source == DutyLocationMaker.button[2] then -- Location Maker
		locationEditID = 0
		destroyElement(DutyLocationMaker.window[1])
	end
end

-- Save!
function saveGUI()
	if source == DutyCreate.button[2] then -- Main
		local name = guiGetText(DutyCreate.edit[3])
		if name ~= "" then
			if customEditID ~= 0 then
				triggerServerEvent("Duty:AddDuty", resourceRoot, dutyItems, getElementData(getLocalPlayer(), "savedLocations") or customg[customEditID][4], getElementData(getLocalPlayer(), "savedSkins") or customg[customEditID][3], name, factionIDg, customEditID)
			else
				triggerServerEvent("Duty:AddDuty", resourceRoot, dutyItems, getElementData(getLocalPlayer(), "savedLocations") or {}, getElementData(getLocalPlayer(), "savedSkins") or {}, name, factionIDg, customEditID)
			end
			tempLocations = nil
			dutyNewSkins = nil
			dutyItems = nil
			customEditID = 0
			setElementData(getLocalPlayer(), "savedLocations", false)
			setElementData(getLocalPlayer(), "savedSkins", false)
		else
			outputChatBox("Please enter in a name for this duty.", 255, 0, 0)
			return
		end
		destroyElement(DutyCreate.window[1])
	elseif source == DutyLocations.button[3] then -- Main > Locations
		setElementData(getLocalPlayer(), "savedLocations", tempLocations)
		tempLocations = nil
		destroyElement(DutyLocations.window[1])
	elseif source == DutyVehicleAdd.button[1] then -- Vehicle Add
		local id = guiGetText(DutyVehicleAdd.edit[1])
		if not duplicateVeh("location", id, factionIDg) then
			triggerServerEvent("Duty:AddVehicle", resourceRoot, tonumber(id), factionIDg)
			destroyElement(DutyVehicleAdd.window[1])
		else
			outputChatBox("This vehicle is already added.", 255, 0, 0)
		end
	elseif source == DutyLocationMaker.button[3] then -- Location Maker
		local x = tonumber(guiGetText(DutyLocationMaker.edit[1]))
		local y = tonumber(guiGetText(DutyLocationMaker.edit[2]))
		local z = tonumber(guiGetText(DutyLocationMaker.edit[3]))
		local r = tonumber(guiGetText(DutyLocationMaker.edit[4]))
		local i = tonumber(guiGetText(DutyLocationMaker.edit[5]))
		local d = tonumber(guiGetText(DutyLocationMaker.edit[6]))
		local name = guiGetText(DutyLocationMaker.edit[7])
		if (x and y and z and r and i and d and name) then
			if r >= 1 and r <=10 then
				if string.len(name) > 0 then
					triggerServerEvent("Duty:AddLocation", resourceRoot, x, y, z, r, i, d, name, factionIDg, (locationEditID ~= 0 and locationEditID or nil))
				else
					outputChatBox("You must enter a name.", 255, 0, 0)
					return
				end
			else
				outputChatBox("Radius must be between 1 and 10", 255, 0, 0)
				return
			end
		else
			outputChatBox("Please enter in all the information correctly.", 255, 0, 0)
			return
		end
		locationEditID = 0
		destroyElement(DutyLocationMaker.window[1])
	end
end

function curPos()
	local x, y, z = getElementPosition(getLocalPlayer())
	local dim = getElementDimension(getLocalPlayer())
	local int = getElementInterior(getLocalPlayer())
	return guiSetText(DutyLocationMaker.edit[1], x), guiSetText(DutyLocationMaker.edit[2], y), guiSetText(DutyLocationMaker.edit[3], z), guiSetText(DutyLocationMaker.edit[5], int), guiSetText(DutyLocationMaker.edit[6], dim)
end

function removeLocation()
	local r, c = guiGridListGetSelectedItem ( Duty.gridlist[1] )
	if r >= 0 then
		local removeid = guiGridListGetItemText ( Duty.gridlist[1], r, 1 )
		triggerServerEvent("Duty:RemoveLocation", resourceRoot, removeid, factionIDg)
		locationsg[tonumber(removeid)] = nil
		refreshUI()
	end
end

function removeDuty()
	local r, c = guiGridListGetSelectedItem ( Duty.gridlist[2] )
	if r >= 0 then
		local removeid = guiGridListGetItemText ( Duty.gridlist[2], r, 1 )
		triggerServerEvent("Duty:RemoveDuty", resourceRoot, removeid, factionIDg)
		customg[tonumber(removeid)] = nil
		refreshUI()
	end
end

function removeVehicle()
	local r, c = guiGridListGetSelectedItem ( Duty.gridlist[3] )
	if r >= 0 then
		local removeid = guiGridListGetItemText ( Duty.gridlist[3], r, 1 )
		triggerServerEvent("Duty:RemoveLocation", resourceRoot, removeid, factionIDg)
		locationsg[tonumber(removeid)] = nil
		refreshUI()
	end
end
