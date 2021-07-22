info = {}
loadout = { primary = 31, secondary = 24, clothes = 0 }
paintballguns = {}
teams = {}

addEvent("event:showPaintballGUI", true)
addEventHandler("event:showPaintballGUI", getRootElement(), function(s_info, lobby, s_teams, s_paintballguns)
	if GUIEditor and GUIEditor.window[1] and isElement(GUIEditor.window[1]) then
		destroyElement(GUIEditor.window[1])
		showCursor(false)
	else
		
		GUIEditor = {
			label = {},
			button = {},
			window = {},
			gridlist = {},
			memo = {},
			combobox = {},
			staticimage = {}
		}

		showCursor(true)
		info = s_info
		teams = s_teams
		paintballguns = s_paintballguns
		
		GUIEditor.window[1] = guiCreateWindow(364, 308, 725, 418, "Paintball Matchmaking", false)
		guiWindowSetSizable(GUIEditor.window[1], false)
		exports.global:centerWindow(GUIEditor.window[1])

		-- Team A
		GUIEditor.label[1] = guiCreateLabel(8, 26, 315, 17, teams[info.teams[1]][1], false, GUIEditor.window[1])
		guiSetFont(GUIEditor.label[1], "default-bold-small")
		guiLabelSetHorizontalAlign(GUIEditor.label[1], "center", false)
		
		GUIEditor.gridlist[1] = guiCreateGridList(10, 49, 313, 191, false, GUIEditor.window[1])
		guiGridListAddColumn(GUIEditor.gridlist[1], "Player", 0.6)
		guiGridListAddColumn(GUIEditor.gridlist[1], "Ready", 0.3)
		
		-- Team B
		GUIEditor.label[2] = guiCreateLabel(400, 26, 315, 17, teams[info.teams[2]][1], false, GUIEditor.window[1])
		guiSetFont(GUIEditor.label[2], "default-bold-small")
		guiLabelSetHorizontalAlign(GUIEditor.label[2], "center", false)
		
		GUIEditor.gridlist[2] = guiCreateGridList(402, 49, 313, 191, false, GUIEditor.window[1])
		guiGridListAddColumn(GUIEditor.gridlist[2], "Player", 0.6)
		guiGridListAddColumn(GUIEditor.gridlist[2], "Ready", 0.3)
		
		--
		
		local localTeam = 0
		for index, player in ipairs(info.players) do
			if player[1] == localPlayer then
				localTeam = player[2]
			end
			guiGridListAddRow(GUIEditor.gridlist[player[2]], getPlayerName(player[1]):gsub("_", " "), (player[3] and "Yes" or "No"))
			guiGridListSetItemColor(GUIEditor.gridlist[player[2]], index-1, 2, (player[3] and 0 or 255), (player[3] and 255 or 0), 0)
		end
	
		loadout.clothes = teams[info.teams[localTeam]][5][1]
		
		GUIEditor.label[3] = guiCreateLabel(11, 247, 704, 15, "Each team may have up to 5 members. Each team requires a minimum of 2 players to begin.", false, GUIEditor.window[1])
		guiSetFont(GUIEditor.label[3], "default-bold-small")
		guiLabelSetHorizontalAlign(GUIEditor.label[3], "center", false)
		GUIEditor.memo[1] = guiCreateMemo(10, 272, 705, 90, "The aim of the game is to defeat all opponents on the opposing team. The last team standing wins and all surviving team members will have their win/loss ratio updated. The overall player with the best wins and kills at the end of the event will win an overall prize for their dedication and talent in the event.\n\nWe thank everyone for their participation.", false, GUIEditor.window[1])
		guiSetEnabled(GUIEditor.memo[1], false)
		GUIEditor.button[3] = guiCreateButton(11, 379, 127, 29, "Exit", false, GUIEditor.window[1])
		GUIEditor.button[4] = guiCreateButton(588, 379, 127, 29, "Ready", false, GUIEditor.window[1])
		GUIEditor.button[5] = guiCreateButton((725/2)-(127/2), 379, 127, 29, "Loadout", false, GUIEditor.window[1])
		
		addEventHandler("onClientGUIClick", GUIEditor.window[1], function()
			if source == GUIEditor.button[3] then
				triggerServerEvent("event:exitPlayerLobby", localPlayer, lobby)
				destroyElement(GUIEditor.window[1])
				if GUIEditor.window[2] and isElement(GUIEditor.window[2]) then
					destroyElement(GUIEditor.window[2])
				end
				showCursor(false)
			elseif source == GUIEditor.button[4] then
				guiSetEnabled(GUIEditor.button[4], false)
				local team = 0
				for _, player in ipairs(info.players) do
					if player[1] == localPlayer then
						team = player[2]
						break
					end
				end
				triggerServerEvent("event:readyPlayer", localPlayer, lobby)
			elseif source == GUIEditor.button[5] then
				guiSetVisible(GUIEditor.window[1], false)
				
				if GUIEditor.window[2] and isElement(GUIEditor.window[2]) then
					guiSetVisible(GUIEditor.window[2], true)
				else
					GUIEditor.window[2] = guiCreateWindow(684, 273, 643, 309, "Paintball Matchmaking - Loadout", false)
					guiWindowSetSizable(GUIEditor.window[2], false)
					exports.global:centerWindow(GUIEditor.window[2])
					
					GUIEditor.button[6] = guiCreateButton(10, 267, 130, 33, "Back", false, GUIEditor.window[2])
					GUIEditor.button[7] = guiCreateButton(503, 266, 130, 33, "Save Loadout", false, GUIEditor.window[2])
					GUIEditor.combobox[1] = guiCreateComboBox(11, 51, 194, 100, "", false, GUIEditor.window[2])
					GUIEditor.label[4] = guiCreateLabel(15, 33, 130, 18, "Primary Weapon:", false, GUIEditor.window[2])
					guiSetFont(GUIEditor.label[4], "default-bold-small")
					GUIEditor.combobox[2] = guiCreateComboBox(223, 51, 194, 100, "", false, GUIEditor.window[2])
					GUIEditor.label[5] = guiCreateLabel(233, 33, 130, 18, "Secondary Weapon:", false, GUIEditor.window[2])
					guiSetFont(GUIEditor.label[5], "default-bold-small")
					GUIEditor.label[6] = guiCreateLabel(445, 33, 130, 18, "Team Clothes:", false, GUIEditor.window[2])
					guiSetFont(GUIEditor.label[6], "default-bold-small")
					GUIEditor.combobox[3] = guiCreateComboBox(435, 51, 198, 100, "", false, GUIEditor.window[2])
					
					GUIEditor.label[7] = guiCreateLabel(200, 275, 250, 18, "", false, GUIEditor.window[2])
					guiLabelSetColor(GUIEditor.label[7], 255, 0, 0)
					guiSetFont(GUIEditor.label[7], "default-bold-small")
					
					for i, v in pairs(paintballguns) do
						guiComboBoxAddItem(GUIEditor.combobox[((v[3] == 1) and 1 or 2)], v[1])
					end
					
					for i, v in pairs(teams[info.teams[localTeam]][5]) do
						guiComboBoxAddItem(GUIEditor.combobox[3], tostring(v))
					end
					
					guiComboBoxSetSelected(GUIEditor.combobox[1], 0)
					guiComboBoxSetSelected(GUIEditor.combobox[2], 1)
					guiComboBoxSetSelected(GUIEditor.combobox[3], 0)
					
					local item = guiComboBoxGetSelected(GUIEditor.combobox[3])
					local skin = guiComboBoxGetItemText(GUIEditor.combobox[3], item)
					skin = (string.len(skin) == 1 and "00" .. skin) or (string.len(skin) == 2 and "0" .. skin) or (skin)
					GUIEditor.staticimage[1] = guiCreateStaticImage(518, 160, 100, 85, ":account/img/" .. skin .. ".png", false, GUIEditor.window[2])
				
					addEventHandler("onClientGUIClick", GUIEditor.window[2], function()
						if source == GUIEditor.button[6] then
							guiSetVisible(GUIEditor.window[2], false)
							guiSetVisible(GUIEditor.window[1], true)
						elseif source == GUIEditor.button[7] then
							guiSetVisible(GUIEditor.window[2], false)
							guiSetVisible(GUIEditor.window[1], true)
							
							local pItem = guiComboBoxGetSelected(GUIEditor.combobox[1])
							local pWeapon = guiComboBoxGetItemText(GUIEditor.combobox[1], pItem)
							local sItem = guiComboBoxGetSelected(GUIEditor.combobox[2])
							local sWeapon = guiComboBoxGetItemText(GUIEditor.combobox[2], sItem)
							
							for i, v in pairs(paintballguns) do
								if v[1] == pWeapon then
									loadout.primary = i
								elseif v[1] == sWeapon then
									loadout.secondary = i
								end
							end
							
							local item = guiComboBoxGetSelected(GUIEditor.combobox[3])
							local skin = guiComboBoxGetItemText(GUIEditor.combobox[3], item)
							
							loadout.clothes = tonumber(skin)
						end
					end)
					
					addEventHandler("onClientGUIComboBoxAccepted", GUIEditor.window[2], function()
						if source == GUIEditor.combobox[3] then
							local item = guiComboBoxGetSelected(GUIEditor.combobox[3])
							local skin = guiComboBoxGetItemText(GUIEditor.combobox[3], item)
							skin = (string.len(skin) == 1 and "00" .. skin) or (string.len(skin) == 2 and "0" .. skin) or (skin)
							guiStaticImageLoadImage(GUIEditor.staticimage[1], ":account/img/" .. skin .. ".png")
						elseif source == GUIEditor.combobox[2] or source == GUIEditor.combobox[1] then
							local pItem = guiComboBoxGetSelected(GUIEditor.combobox[1])
							local sItem = guiComboBoxGetSelected(GUIEditor.combobox[2])
							if (sItem == 0 and pItem == 0) then
								guiSetText(GUIEditor.label[7], "You cannot have that weapon combination.")
								guiSetEnabled(GUIEditor.button[7], false)
							else
								guiSetText(GUIEditor.label[7], "")
								guiSetEnabled(GUIEditor.button[7], true)
							end
						end
					end)
				end
			end
		end)
	end
end)

addEvent("event:readyPlayerClient", true)
addEventHandler("event:readyPlayerClient", getRootElement(), function(targetPlayer, allReady)
	if GUIEditor.window[1] and isElement(GUIEditor.window[1]) then
		local team = getElementData(targetPlayer, "paintball:team")
		for index = 0, guiGridListGetRowCount(GUIEditor.gridlist[team]) do
			if guiGridListGetItemText(GUIEditor.gridlist[team], index, 1) == getPlayerName(targetPlayer):gsub("_", " ") then
				guiGridListSetItemText(GUIEditor.gridlist[team], index, 2, "Yes", false, false)
				guiGridListSetItemColor(GUIEditor.gridlist[team], index, 2, 0, 220, 0)
			end
		end
		for index, value in ipairs(info.players) do
			if value[1] == targetPlayer then
				info.players[index][3] = true
			end
		end
		if allReady then
			-- Handle clientside countdown. The match preparation will be handled serverside.
			local counter = 6
			setTimer(function()
				counter = counter - 1
				if isElement(GUIEditor.window[1]) then
					guiSetEnabled(GUIEditor.button[3], false)
					guiSetText(GUIEditor.label[3], "Match is starting in .. " .. counter)
				end
				if counter == 0 then
					destroyElement(GUIEditor.window[1])
					if GUIEditor.window[2] and isElement(GUIEditor.window[2]) then	
						destroyElement(GUIEditor.window[2])
					end
					for i = 1, getChatboxLayout()["chat_lines"] do
						outputChatBox("")
					end
					showCursor(false)
					setElementFrozen(localPlayer, false)
					triggerServerEvent("event:handlePaintballGuns", localPlayer, loadout)
				elseif counter == 2 then
					fadeCamera(false, 2)
				elseif counter == 5 then
					guiLabelSetColor(GUIEditor.label[3], 0, 255, 0)
				end
			end, 1000, 6)
		end
	end
end)

addEvent("event:addPlayerLobby", true)
addEventHandler("event:addPlayerLobby", getRootElement(), function(targetPlayer, team)
	if GUIEditor and GUIEditor.window[1] and isElement(GUIEditor.window[1]) then
		table.insert(info.players, { targetPlayer, team, false })
		local index = guiGridListAddRow(GUIEditor.gridlist[team], getPlayerName(targetPlayer):gsub("_", " "), "No")
		guiGridListSetItemColor(GUIEditor.gridlist[team], index, 2, 255, 0, 0)
	end
end)

addEvent("event:removePlayerLobby", true)
addEventHandler("event:removePlayerLobby", getRootElement(), function(targetPlayer, team)
	if GUIEditor.window[1] and isElement(GUIEditor.window[1]) then
		for index, value in ipairs(info.players) do
			if value[1] == targetPlayer then
				table.remove(info.players, index)
			end
		end
		for index = 0, guiGridListGetRowCount(GUIEditor.gridlist[team]) do
			if string.find(guiGridListGetItemText(GUIEditor.gridlist[team], index, 1), getPlayerName(targetPlayer):gsub("_", " ")) then
				guiGridListRemoveRow(GUIEditor.gridlist[team], index)
			end
		end
	end
end)

addEventHandler("onClientRender", getRootElement(), function()
	if getElementData(localPlayer, "paintball") == 2 then
		local screenW, screenH = guiGetScreenSize()
		local x, y = screenW - 84, (screenH / 5)
		for i = 2, 9 do
			local weapon = getPedWeapon(localPlayer, i)
			if weapon and weapon ~= 0 then
				dxDrawRectangle(x, y, 80, 80, tocolor(0, 0, 0, 100))
				local shade = tocolor(150, 150, 150, 80)
				if getPedWeapon(localPlayer) == getPedWeapon(localPlayer, i) then
					shade = tocolor(51, 173, 51, 80)
				end
				dxDrawRectangle(x + 4, y + 4, 72, 72, shade)
				dxDrawImage(x + 4, y + 4, 72, 72, ":item-system/images/-" .. weapon .. ".png")
				if getPedWeapon(localPlayer) == getPedWeapon(localPlayer, i) then
					local text = "Clip empty."
					if getPedTotalAmmo(localPlayer, i) == 1 then
						text = "No ammo."
					elseif getPedAmmoInClip(localPlayer, i) > 0 then
						text = getPedAmmoInClip(localPlayer, i) .. " loaded."
					end
					dxDrawText(text, x, y + 82, x + 82, y + 90, tocolor(255, 255, 255, 200), 1.0, "default", "center")
					y = y + 100
				else
					y = y + 84
				end
			end
		end
	end
end)

addEventHandler("onClientPlayerWeaponFire", getRootElement(), function(weapon, ammo, ammoInClip, hitX, hitY, hitZ, hitElement)
	if getElementData(localPlayer, "paintball") == 2 then
		local localTeam = getElementData(localPlayer, "paintball:team")
		local marker = createMarker(hitX, hitY, hitZ, "corona", 0.2, teams[info.teams[localTeam]][2], teams[info.teams[localTeam]][3], teams[info.teams[localTeam]][4], 255)
		setElementInterior(marker, getElementInterior(localPlayer))
		setElementDimension(marker, getElementDimension(localPlayer))
		setTimer(destroyElement, 5000, 1, marker)
	end
end)

addEventHandler("onClientPlayerDamage", getRootElement(), function(attacker, weapon, bodypart, loss)
	if getElementData(source, "paintball") == 2 then
		cancelEvent() -- no real damage taken
		triggerServerEvent("event:onPlayerDamage", source, attacker, weapon, bodypart, loss)
		--[[if getElementData(source, "paintball:hp") > 0 and weapon then
		
			if getElementData(source, "paintball:team") == getElementData(attacker, "paintball:team") and attacker ~= source then 
				outputChatBox("Friendly fire is not allowed!", 255, 0, 0)
				return false
			end
			
			loss = (weapon and paintballguns[weapon][4]) or loss
			if (getElementData(source, "paintball:hp") - loss) > 0 then
				setElementData(source, "paintball:hp", getElementData(source, "paintball:hp") - loss)
			else -- player out			
				setElementData(source, "paintball:hp", 0)
				local localTeam = getElementData(source, "paintball:team")
				setElementFrozen(source, true)
				exports.global:applyAnimation(source, "ped", "floor_hit", -1, false, false, false)
				outputDebugString("[CLIENT-PAINTBALL] handleDeath - localPlayer: " .. getPlayerName(localPlayer) .. ", source: " .. getPlayerName(source) .. ", attacker: " .. getPlayerName(attacker))
				triggerServerEvent("event:handleDeath", source, attacker)
			end
		end]]
	end
end)

-- FEEDBACK

addEvent("event:showFeedbackGUI", true)
addEventHandler("event:showFeedbackGUI", getRootElement(), function(feedback_info, alreadySubmitted)
	if feedback and feedback.window[1] and isElement(feedback.window[1]) then
		destroyElement(feedback.window[1])
	else
		feedback = {
			tab = {},
			tabpanel = {},
			label = {},
			button = {},
			window = {},
			gridlist = {},
			memo = {}
		}
		
		guiSetInputEnabled(true)
		
		feedback.window[1] = guiCreateWindow(452, 291, 655, 355, "Feedback Menu", false)
		guiWindowSetSizable(feedback.window[1], false)

		feedback.tabpanel[1] = guiCreateTabPanel(10, 23, 635, 322, false, feedback.window[1])
		feedback.tab[1] = guiCreateTab("Leave Feedback", feedback.tabpanel[1])

		feedback.memo[1] = guiCreateMemo(10, 27, 615, 82, "", false, feedback.tab[1])
		feedback.button[1] = guiCreateButton(10, 258, 121, 29, "Exit", false, feedback.tab[1])
		feedback.button[2] = guiCreateButton(504, 258, 121, 29, "Save", false, feedback.tab[1])
		feedback.label[1] = guiCreateLabel(20, 5, 403, 17, "What do you think of the Paintball Event and how could we improve it?", false, feedback.tab[1])
		feedback.label[2] = guiCreateLabel(20, 119, 403, 17, "What kind of events would you like to see in the future, if any?", false, feedback.tab[1])
		feedback.memo[2] = guiCreateMemo(10, 142, 615, 82, "", false, feedback.tab[1])
		feedback.label[3] = guiCreateLabel(20, 234, 403, 17, "All feedback is logged and reviewed by administrators and developers.", false, feedback.tab[1])
		
		if alreadySubmitted then
			guiSetEnabled(feedback.button[2], false)
		end

		if exports.integration:isPlayerTrialAdmin(localPlayer) or exports.integration:isPlayerScripter(localPlayer) then
			feedback.tab[2] = guiCreateTab("(Admin+) Feedback Results", feedback.tabpanel[1])
			feedback.gridlist[1] = guiCreateGridList(8, 10, 617, 277, false, feedback.tab[2])
			guiGridListAddColumn(feedback.gridlist[1], "User", 0.2)
			guiGridListAddColumn(feedback.gridlist[1], "Future Feedback", 0.35)    
			guiGridListAddColumn(feedback.gridlist[1], "Event Feedback", 0.35)    
			
			for i, v in ipairs(feedback_info) do
				guiGridListAddRow(feedback.gridlist[1], v[1], v[2], v[3])
			end
		end
		
		addEventHandler("onClientGUIClick", feedback.window[1], function()
			if source == feedback.button[1] then
				destroyElement(feedback.window[1])
				showCursor(false)
				guiSetInputEnabled(false)
			elseif source == feedback.button[2] then
				if string.len(guiGetText(feedback.memo[1])) < 5 or string.len(guiGetText(feedback.memo[2])) < 5 then
					outputChatBox(" Failed to submit feedback: answers are too short.", 255, 0, 0)
				else
					triggerServerEvent("event:saveFeedback", localPlayer, getElementData(localPlayer, "account:username"), guiGetText(feedback.memo[1]), guiGetText(feedback.memo[2]))
					destroyElement(feedback.window[1])
					showCursor(false)
					guiSetInputEnabled(false)
				end
			end
		end)
		
		addEventHandler("onClientGUIDoubleClick", feedback.window[1], function()
			if source == feedback.gridlist[1] then
				local row, col = -1, -1
				local row, col = guiGridListGetSelectedItem(feedback.gridlist[1])
				if row ~= -1 and col ~= -1 then
					local user = guiGridListGetItemText(feedback.gridlist[1], row, 1)
					for i, v in ipairs(feedback_info) do
						if v[1] == user then
							guiSetText(feedback.memo[1], v[2])
							guiSetText(feedback.memo[2], v[3])
							guiSetText(feedback.tab[1], "Feedback - " .. v[1])
							guiSetEnabled(feedback.button[2], false)
							guiSetSelectedTab(feedback.tabpanel[1], feedback.tab[1])
							break
						end
					end
				end
			end
		end)
	end
end)

-- LEADERBOARD

addEvent("event:showLeaderboardGUI", true)
addEventHandler("event:showLeaderboardGUI", getRootElement(), function(leaderboard_info, money)
	if leaderboard and leaderboard.window[1] and isElement(leaderboard.window[1]) then
		destroyElement(leaderboard.window[1])
	else
		leaderboard = {
			gridlist = {},
			window = {},
			button = {},
			label = {}
		}
		
		leaderboard.window[1] = guiCreateWindow(553, 208, 602, 366, "Leaderboard", false)
		guiWindowSetSizable(leaderboard.window[1], false)

		leaderboard.gridlist[1] = guiCreateGridList(9, 27, 583, 291, false, leaderboard.window[1])
		guiGridListAddColumn(leaderboard.gridlist[1], "Position", 0.15)
		guiGridListAddColumn(leaderboard.gridlist[1], "User", 0.4)
		guiGridListAddColumn(leaderboard.gridlist[1], "Kills", 0.2)
		guiGridListAddColumn(leaderboard.gridlist[1], "Wins", 0.2)
		leaderboard.button[1] = guiCreateButton(9, 324, 138, 32, "Exit", false, leaderboard.window[1])
		leaderboard.label[1] = guiCreateLabel(199, 324, 350, 16, "", false, leaderboard.window[1]) 
		leaderboard.label[2] = guiCreateLabel(199, 342, 350, 16, "We have raised a total of $" .. exports.global:formatMoney(money) .. "!", false, leaderboard.window[1])
		guiSetFont(leaderboard.label[1], "default-bold-small")    
		guiSetFont(leaderboard.label[2], "default-bold-small") 
		guiLabelSetHorizontalAlign(leaderboard.label[1], "center", false)
		guiLabelSetHorizontalAlign(leaderboard.label[2], "center", false)
		
		local index = 1
		local row = 0
		for id, value in pairs(leaderboard_info) do
			row = guiGridListAddRow(leaderboard.gridlist[1])
			guiGridListSetItemText(leaderboard.gridlist[1], row, 1, tostring(index), false, true)
			guiGridListSetItemText(leaderboard.gridlist[1], row, 2, value[3], false, false)
			guiGridListSetItemText(leaderboard.gridlist[1], row, 3, tostring(value[1]), false, true)
			guiGridListSetItemText(leaderboard.gridlist[1], row, 4, tostring(value[2]), false, true)
			index = index + 1
		end
		
		guiSetText(leaderboard.label[1], "A total of " .. (index - 1) .. " players have participated in the event so far!")
		
		addEventHandler("onClientGUIClick", getRootElement(), function()
			if source == leaderboard.button[1] then
				destroyElement(leaderboard.window[1])
			end
		end)
	end
end)


