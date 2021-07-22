-- ITEM CREATOR BY MAXIME
wItemList, bItemListClose, isTargetPlayerValid, targetPlayer , targetPlayerID, found , selectedItemName = nil
itemButton = {}
local localPlayer = getLocalPlayer()
function showItemList()
	if (exports.integration:isPlayerTrialAdmin(localPlayer) or exports.integration:isPlayerSupporter(localPlayer) or exports.integration:isPlayerScripter(localPlayer)) then
		if not (wItemsList) then
			local width, height = 800,600
			local scrWidth, scrHeight = guiGetScreenSize()
			local x = scrWidth/2 - (width/2)
			local y = scrHeight/2 - (height/2)
			wItemsList = guiCreateWindow(x, y, width, height,"Item Creator",false)
				guiWindowSetSizable(wItemsList,false)
			gridItems = guiCreateGridList(9,68,782,523,false,wItemsList)
				--guiGridListSetSelectionMode(gridItems,2)
			bItemListClose = guiCreateButton(680,22,111,46,"Close",false,wItemsList)
			eTargetPlayer = guiCreateEdit(9,41,140,21,"Player Partial Name/ID",false,wItemsList)
			lSpawnTo = guiCreateLabel(11,22,138,19,"Spawn to: ",false,wItemsList)
			bSpawnClose = guiCreateButton(569,45,111,23,"Spawn & Close",false,wItemsList)
			bSpawn = guiCreateButton(569,22,111,23,"Spawn",false,wItemsList)
			bSkinID = guiCreateButton(458,22,111,23,"Skin IDs List",false,wItemsList)
			bVisualMode = guiCreateButton(458,45,111,23,"Visualized Mode",false,wItemsList)
			lItemSearch = guiCreateLabel(308,22,140,19,"Item Search:",false,wItemsList)
			bItemSearch = guiCreateEdit(309,41,140,21,"Item Partial Name/ID/Desc",false,wItemsList)
			lItemValue = guiCreateLabel(159,22,140,19,"Item Value:",false,wItemsList)
			eItemValue = guiCreateEdit(159,41,140,21,"1",false,wItemsList)
				guiSetFont(lItemValue,"default-small")
				guiSetFont(lItemSearch,"default-small")
				guiSetFont(lSpawnTo,"default-small")
				
			local colID = guiGridListAddColumn(gridItems, "ID", 0.1)
			local colName = guiGridListAddColumn(gridItems, "Item Name", 0.3)
			local colDesc = guiGridListAddColumn(gridItems, "Description", 0.6)
			
			for key, value in pairs(g_items) do
				local row = guiGridListAddRow(gridItems)
				guiGridListSetItemText(gridItems, row, colID, tostring(key), false, true)
				guiGridListSetItemText(gridItems, row, colName, value[1], false, false)
				guiGridListSetItemText(gridItems, row, colDesc, value[2], false, false)
			end
			--BUTTON CLOSE
			addEventHandler("onClientGUIClick", bItemListClose, closeItemsList, false)
			
			--BUTTON SPAWN
			addEventHandler("onClientGUIClick", bSpawn, function () 
				if gridItems then 
					local row, col = guiGridListGetSelectedItem(gridItems)
					if (row==-1) or (col==-1) then
						--outputChatBox("[ITEM CREATOR] Please select an item first!", 255, 0, 0)
						guiSetText(wItemsList, "Please select an item first!")
					else
						if isTargetPlayerValid then
							local itemId = tostring(guiGridListGetItemText(gridItems, guiGridListGetSelectedItem(gridItems), 1))
							if itemId then
								local itemValue = tostring(guiGetText(eItemValue))
								if itemValue ~= "" then
									triggerServerEvent ("itemCreator:spawnItem", getLocalPlayer(), getLocalPlayer(), targetPlayerID, itemId, itemValue )
								else
									--outputChatBox("[ITEM CREATOR] Invalid Item Value..", 255, 0, 0)
									guiSetText(wItemsList, "Invalid Item Value!")
								end
							else
								--outputChatBox("[ITEM CREATOR] No such item (anymore)..", 255, 0, 0)
								guiSetText(wItemsList, "No such item (anymore)!")
							end
						else
							--outputChatBox("[ITEM CREATOR] No such player to spawn to..", 255, 0, 0)
							guiSetText(wItemsList, "No such player to spawn to..!")
						end
					end
				elseif panelItems then
					--do nothing
				else
					--do nothing
				end
			end, false)
			
			--BUTTON SPAWN & CLOSE
			addEventHandler("onClientGUIClick", bSpawnClose, function () 
				if gridItems then 
					local row, col = guiGridListGetSelectedItem(gridItems)
					if (row==-1) or (col==-1) then
						--outputChatBox("[ITEM CREATOR] Please select an item first!", 255, 0, 0)
						guiSetText(wItemsList, "Please select an item first!")
					else
						if isTargetPlayerValid then
							local itemId = tostring(guiGridListGetItemText(gridItems, guiGridListGetSelectedItem(gridItems), 1))
							if itemId then
								local itemValue = tostring(guiGetText(eItemValue))
								if itemValue ~= "" then
									triggerServerEvent ("itemCreator:spawnItem", getLocalPlayer(), getLocalPlayer(), targetPlayerID, itemId, itemValue )
									--closeItemsList
									showCursor(false)
									guiSetInputEnabled(false)
									destroyElement(bItemListClose)
									destroyElement(wItemsList)
									bItemListClose = nil
									wItemsList = nil
									gridItems = nil
								else
									--outputChatBox("[ITEM CREATOR] Invalid Item Value..", 255, 0, 0)
									guiSetText(wItemsList, "Invalid Item Value!")
								end
							else
								--outputChatBox("[ITEM CREATOR] No such item (anymore)..", 255, 0, 0)
								guiSetText(wItemsList, "No such item (anymore)!")
							end
						else
							--outputChatBox("[ITEM CREATOR] No such player to spawn to..", 255, 0, 0)
							guiSetText(wItemsList, "No such player to spawn to..!")
						end
					end
				elseif panelItems then
					--do nothing
				else
					--do nothing
				end
			end, false)
			
			--BUTTON SKIN IDS
			addEventHandler("onClientGUIClick", bSkinID, function () 
				outputChatBox("LOL! I didn't finish this =))")
			
			end, false)
			
			--BUTTON VISUALIZED MODE
			addEventHandler("onClientGUIClick", bVisualMode, function () 
				guiSetEnabled(bSpawn, false)
				guiSetEnabled(bSpawnClose, false)
				guiEditSetReadOnly(bItemSearch, true)
				guiSetVisible(bVisualMode, false) 
				bNormalMode = guiCreateButton(458,45,111,23,"Normal Mode",false,wItemsList)
				addEventHandler("onClientGUIClick", bNormalMode, backToNormal)
				
				destroyElement(gridItems)
				gridItems = nil
				itemImage = {}
				panelItems = guiCreateScrollPane(9,68,782,523,false,wItemsList)
				local delayTime = 100
				local x , y = 0, 0
				for key, value in pairs(g_items) do
					if key ~= 74 and key ~= 75 then
						local itemTitle = "("..tostring(key)..") "..value[1]
						itemButton[key] = guiCreateButton(x,y,64,64,itemTitle,false,panelItems)
						itemImage[key] = guiCreateStaticImage(0,0,64,64,"images/"..tostring(key)..".png",false,itemButton[key])
							if itemImage[key] then
								guiSetAlpha(itemImage[key], 0.8)
								guiSetProperty(itemImage[key],"MousePassThroughEnabled","true")
							end
						----itemLabel[key] = guiCreateLabel(x,66,64,20,itemTitle,false, panelItems)	
						x = x + 70
						if key == 11 or key == 22 or key == 33 or key  == 44 or key == 55 or key == 66 or key == 79 or key == 90 or key == 101 or key == 112 or key == 123 or key == 134 then
							x = 0 
							y = y + 70
						end
					end
				end
				addEventHandler("onClientGUIClick", panelItems, itemButtonInteracts)
			end, false)
			
			--ITEM SEARCH
			addEventHandler("onClientGUIFocus", bItemSearch, function ()
				if gridItems then
					guiSetText(bItemSearch , "")
				end
			end, false)
			addEventHandler("onClientGUIChanged", bItemSearch, function () 
				--outputChatBox("Searching..")
				guiGridListClear ( gridItems )
				for key, value in pairs(g_items) do
					if key ~= 74 and key ~= 75 and (tostring(value[1]):lower():find(guiGetText(bItemSearch):lower()) or tostring(value[2]):lower():find(guiGetText(bItemSearch):lower()) or tostring(key):lower():find(guiGetText(bItemSearch):lower()) ) then
						local row = guiGridListAddRow(gridItems)
						guiGridListSetItemText(gridItems, row, colID, tostring(key), false, true)
						guiGridListSetItemText(gridItems, row, colName, value[1], false, false)
						guiGridListSetItemText(gridItems, row, colDesc, value[2], false, false)
					end
				end
			end, false)

			--PLAYER SEARCH
			addEventHandler("onClientGUIFocus", eTargetPlayer, function ()
				guiSetText(eTargetPlayer , "")
			end, false)
			addEventHandler("onClientGUIChanged", eTargetPlayer, checkNameExists)
			
			--ITEM VALUE
			addEventHandler("onClientGUIFocus", eItemValue, function ()
				guiSetText(eItemValue , "")
			end, false)
			
			--ITEMLIST INTERACTIONS
			addEventHandler("onClientGUIDoubleClick", gridItems, function () 
				--if button == "left" and state == "up" then
					local row, col = guiGridListGetSelectedItem(gridItems)
					if (row==-1) or (col==-1) then
						outputChatBox("Please select an item first!", 255, 0, 0)
					else
						local id = tostring(guiGridListGetItemText(gridItems, guiGridListGetSelectedItem(gridItems), 1))
						local itemName = tostring(guiGridListGetItemText(gridItems, guiGridListGetSelectedItem(gridItems), 2))
						local itemDesc = tostring(guiGridListGetItemText(gridItems, guiGridListGetSelectedItem(gridItems), 3))
						if id then
							local copyingContent = "("..id..") "..itemName.." - "..itemDesc
							if setClipboard (copyingContent ) then
								outputChatBox("Copied to clipboard - '"..copyingContent.."'")
							end
						else
							outputChatBox("No such item (anymore)...", 255, 0, 0)
						end
					end
				--end
			end, false)
			
			showCursor(true)
			guiSetInputEnabled(true)
			
			
		else
			guiSetVisible(wItemsList, true)
			guiBringToFront(wItemsList)
			showCursor(true)
			guiSetInputEnabled(false)
		end
	end
end
addCommandHandler("itemlist", showItemList)
addCommandHandler("items", showItemList)

function closeItemsList(button, state)
	if (source==bItemListClose) and (button=="left") and (state=="up") then
		showCursor(false)
		guiSetInputEnabled(false)
		destroyElement(bItemListClose)
		destroyElement(wItemsList)
		bItemListClose = nil
		wItemsList = nil
		gridItems = nil
	end
end

function itemButtonInteracts( button, state) 
    if button == "left" then
		for key, value in pairs(g_items) do
			if source == itemButton[key] then
				selectedItemName = value[1]
				backToNormal(key)
			else
				--do nothing
			end
		end
	end
end

function backToNormal()
	guiSetEnabled(bSpawn, true)
	guiSetEnabled(bSpawnClose, true)
	guiEditSetReadOnly(bItemSearch, false)
	guiSetVisible(bVisualMode, true) 
	guiSetVisible(bNormalMode, false) 
	destroyElement(bNormalMode)
	bNormalMode = nil
	destroyElement(panelItems)
	panelItems = nil
	
	gridItems = guiCreateGridList(9,68,782,523,false,wItemsList)
	local colID = guiGridListAddColumn(gridItems, "ID", 0.1)
	local colName = guiGridListAddColumn(gridItems, "Item Name", 0.3)
	local colDesc = guiGridListAddColumn(gridItems, "Description", 0.6)
	
	for key, value in pairs(g_items) do
		if key ~= 74 and key ~= 75 then
			local row = guiGridListAddRow(gridItems)
			guiGridListSetItemText(gridItems, row, colID, tostring(key), false, true)
			guiGridListSetItemText(gridItems, row, colName, value[1], false, false)
			guiGridListSetItemText(gridItems, row, colDesc, value[2], false, false)
		end
	end
	if selectedItemName then
		guiSetText(bItemSearch,selectedItemName)
		guiGridListSetSelectedItem ( gridItems, 0, 1 )
		selectedItemName = nil
	end
end

function checkNameExists(theEditBox)
	local count = 0
	
	local text = guiGetText(theEditBox)
	if text and #text > 0 then
		local players = getElementsByType("player")
		if tonumber(text) then
			local id = tonumber(text)
			for key, value in ipairs(players) do
				if getElementData(value, "playerid") == id then
					found = value
					count = 1
					break
				end
			end
		else
			for key, value in ipairs(players) do
				local username = string.lower(tostring(getPlayerName(value)))
				if string.find(username, string.lower(text)) then
					count = count + 1
					found = value
					break
				end
			end
		end
	end
	
	if (count>1) then
		isTargetPlayerValid = false
		guiSetText(lSpawnTo, "Spawn to: ".."Multiple Found.")
		guiLabelSetColor(lSpawnTo, 255, 255, 0)
	elseif (count==1) then
		isTargetPlayerValid = true
		targetPlayerName = getPlayerName(found)
		guiSetText(lSpawnTo, "Spawn to: " .. getPlayerName(found) .. " (ID #" .. getElementData(found, "playerid") .. ")")
		guiLabelSetColor(lSpawnTo, 0, 255, 0)
		targetPlayerID = getElementData(found, "playerid") 
	elseif (count==0) then
		isTargetPlayerValid = false
		
		guiSetText(lSpawnTo, "Spawn to: ".."Player not found.")
		guiLabelSetColor(lSpawnTo, 255, 0, 0)
	end
end
