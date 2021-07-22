local localPlayer = getLocalPlayer()
local root = root
local IntsList1 = {}
local IntsSearchList = {}
local intID = nil
local intsTabPanel = false
local sx, sy = guiGetScreenSize()

function createIntManagerWindow(IntsList)
	if gWin then
		closeIntManager()
	end
	if (IntsList) then
		showCursor(true)
		--guiSetInputEnabled(true)
		--IntsList1 = IntsList
		gWin = guiCreateWindow(sx/2-400,sy/2-300,800,600,"Interiors Manager",false)
			guiWindowSetSizable(gWin,false)
			--guiSetProperty(gWin,"TitlebarEnabled","false")
		intsTabPanel = guiCreateTabPanel(0.0113,0.1417,0.9775,0.8633,true,gWin)

		bDelInt = guiCreateButton(0.0113,0.035,0.0938,0.045,"DELETE",true,gWin)
			guiSetFont(bDelInt,"default-bold-small")
		bRestoreInt = guiCreateButton(0.0113,0.085,0.0938,0.045,"RESTORE",true,gWin)
			guiSetFont(bRestoreInt,"default-bold-small")

		bToggleInt = guiCreateButton(0.1175,0.035,0.1,0.045,"TOGGLE",true,gWin)
			guiSetFont(bToggleInt,"default-bold-small")
		bGotoInt = guiCreateButton(0.1175,0.085,0.1,0.045,"GO TO",true,gWin)
			guiSetFont(bGotoInt,"default-bold-small")

		bForceSell = guiCreateButton(0.23,0.035,0.1,0.045,"FORCE-SELL",true,gWin)
			guiSetFont(bForceSell,"default-bold-small")
		bRemoveInt = guiCreateButton(0.23,0.085,0.1,0.045,"REMOVE",true,gWin)
			guiSetFont(bRemoveInt,"default-bold-small")

		bAdminNote = guiCreateButton(0.3425,0.035,0.1,0.045,"CHECK",true,gWin)
			guiSetFont(bAdminNote,"default-bold-small")
		bSearch = guiCreateButton(0.3425,0.085,0.1,0.045,"SEARCH",true,gWin)
			guiSetFont(bSearch,"default-bold-small")

		bClose = guiCreateButton(0.455,0.035,0.1,0.09,"CLOSE",true,gWin)
			guiSetFont(bClose,"default-bold-small")

		local lTotal = guiCreateLabel(460,25,164,17,"Total Interiors: ",false,gWin)
		local lActive = guiCreateLabel(460,42,164,17,"Active Interiors: ",false,gWin)
		local lDisableInts = guiCreateLabel(628,25,159,17,"Disabled Interiors: ",false,gWin)
		local lInactive = guiCreateLabel(628,42,159,17,"Inactive Interiors: ",false,gWin)
		local lOwnedbyCKs = guiCreateLabel(460,59,164,17,"Ints owned by CK-ed's: ",false,gWin)
		local lDeletedInts = guiCreateLabel(628,59,159,17,"Deleted Interiors: ",false,gWin)

		local targetTab = {}
		local targetList = {}
		local colID = {}
		local colType = {}
		local colName = {}
		local colPrice = {}
		local colOwner = {}
		local colLastUsed = {}
		local colAddress = {}--MS
		local colLocked = {}
		local colSupplies = {}
		local colSafeInstalled = {}
		local colDisabled = {}
		local colDeleted = {}
		local colCreatedBy = {}
		local colCreatedDate = {}
		local colAdminNote = {}

		targetTab[1] = guiCreateTab( "Active Interiors", intsTabPanel )
		targetTab[2] = guiCreateTab( "Inactive Interiors", intsTabPanel )
		targetTab[3] = guiCreateTab( "Disabled Interiors", intsTabPanel )
		targetTab[4] = guiCreateTab( "Interiors owned by CK-ed chars", intsTabPanel )
		targetTab[5] = guiCreateTab( "Deleted Interiors", intsTabPanel )
		targetTab[6] = guiCreateTab( "Search Results", intsTabPanel )

		targetList[1] = guiCreateGridList(0,0,1,1,true,targetTab[1])
		targetList[2] = guiCreateGridList(0,0,1,1,true,targetTab[2])
		targetList[3] = guiCreateGridList(0,0,1,1,true,targetTab[3])
		targetList[4] = guiCreateGridList(0,0,1,1,true,targetTab[4])
		targetList[5] = guiCreateGridList(0,0,1,1,true,targetTab[5])
		targetList[6] = guiCreateGridList(0,0,1,1,true,targetTab[6])

		for i = 1,6 do
			colID[i] = guiGridListAddColumn(targetList[i],"ID",0.07)
			colType[i] = guiGridListAddColumn(targetList[i],"Type",0.1)
			colName[i] = guiGridListAddColumn(targetList[i],"Name",0.25)
			colPrice[i] = guiGridListAddColumn(targetList[i],"Price",0.07)
			colOwner[i] = guiGridListAddColumn(targetList[i],"Owner",0.2)
			--local colLocation = guiGridListAddColumn(targetList[i],"Location",0.07)
			colLastUsed[i] = guiGridListAddColumn(targetList[i],"Last Used",0.08)
			colLocked[i] = guiGridListAddColumn(targetList[i],"Locked",0.06)
			colAddress[i] = guiGridListAddColumn(targetList[i], "Address", 0.2)--MS
			colSupplies[i] = guiGridListAddColumn(targetList[i],"Supplies",0.06)
			colSafeInstalled[i] = guiGridListAddColumn(targetList[i],"Safe Installed",0.06)
			colDisabled[i] = guiGridListAddColumn(targetList[i],"Disabled",0.06)
			colDeleted[i] = guiGridListAddColumn(targetList[i],"Deleted",0.08)
			colCreatedBy[i] = guiGridListAddColumn(targetList[i],"Created By",0.1)
			colCreatedDate[i] = guiGridListAddColumn(targetList[i],"Created Date",0.17)
			colAdminNote[i] = guiGridListAddColumn(targetList[i],"Admin Note",1)
		end
		local count = {[1]=0, [2] = 0, [3] = 0, [4] = 0, [5] = 0}
		for _, record in ipairs(IntsList) do
			local lastUsed, isInteriorInactive = formartDays(record[8])
			local i = 1 -- active ints
			if record[13] ~= "0" then --deleted ints
				i = 5
				count[5] = count[5] + 1
			elseif isInteriorInactive then -- inactive ints
				i = 2
				count[2] = count[2] + 1
			elseif record[12] == "1" then --disabled ints
				i = 3
				count[3] = count[3] + 1
			elseif record[7] == "1" then -- owned by CKed's
				i = 4
				count[4] = count[4] + 1
			else
				count[1] = count[1] + 1
			end

			local row = guiGridListAddRow(targetList[i])
			guiGridListSetItemText(targetList[i], row, colID[i], record[1] or "", false, true)
			guiGridListSetItemText(targetList[i], row, colType[i], intTypeName(record[2]), false, false)
			guiGridListSetItemText(targetList[i], row, colName[i], record[3] or "", false, false)
			guiGridListSetItemText(targetList[i], row, colPrice[i], record[4], false, true)
			guiGridListSetItemText(targetList[i], row, colOwner[i], charName(record[5])..cked(record[7])..accountName(record[6])..(record[20] or ""), false, false)
			guiGridListSetItemText(targetList[i], row, colLastUsed[i],lastUsed , false, false)
			guiGridListSetItemText(targetList[i], row, colAddress[i], record[21] or "", false, false) --MS
			guiGridListSetItemText(targetList[i], row, colLocked[i], record[9] == "0" and "Unlocked" or "Locked", false, false)
			guiGridListSetItemText(targetList[i], row, colSupplies[i], record[10] or "", false, false)
			guiGridListSetItemText(targetList[i], row, colSafeInstalled[i], record[11] and "Yes" or "No", false, false)
			guiGridListSetItemText(targetList[i], row, colDisabled[i], record[12] == "1" and "Yes" or "No", false, false)
			guiGridListSetItemText(targetList[i], row, colDeleted[i], record[13] == "0" and "No" or "by "..record[13], false, false)
			guiGridListSetItemText(targetList[i], row, colCreatedBy[i], record[16] or "", false, false)
			guiGridListSetItemText(targetList[i], row, colCreatedDate[i], record[15] or "", false, false)
			guiGridListSetItemText(targetList[i], row, colAdminNote[i], record[14] or "", false, false)

			--IntsSearchList[i] = {record[1] or "", intTypeName(record[2]), record[3] or "", record[4], charName(record[5])..cked(record[7])..accountName(record[6]), lastUsed, record[9] == "0" and "Unlocked" or "Locked", record[10] or "",  record[11] and "Yes" or "No", record[12] == "1" and "Yes" or "No", record[13] == "0" and "No" or "by "..record[13], record[16] or "", record[15] or "", record[14] or ""}
			--outputDebugString("IntsSearchList["..i.."] = "..IntsSearchList[i][1])
		end

		--fetching stats
		guiSetText( lTotal , "Total Interiors: "..count[1]+count[2]+count[3]+count[4]+count[5])
		guiSetText( lActive , "Active Interiors: "..count[1])
		guiSetText( lDisableInts , "Disabled Interiors: "..count[3])
		guiSetText( lInactive , "Inactive Interiors: "..count[2])
		guiSetText( lOwnedbyCKs , "Ints owned by CK-ed's: "..count[4])
		guiSetText( lDeletedInts , "Deleted Interiors: "..count[5])

		function getListFromActiveTab(intsTabPanel)
			if intsTabPanel then
				if guiGetSelectedTab (intsTabPanel ) == targetTab[1] then
					return targetList[1], 1
				elseif guiGetSelectedTab (intsTabPanel ) == targetTab[2] then
					return targetList[2], 2
				elseif guiGetSelectedTab (intsTabPanel ) == targetTab[3] then
					return targetList[3], 3
				elseif guiGetSelectedTab (intsTabPanel ) == targetTab[4] then
					return targetList[4], 4
				elseif guiGetSelectedTab (intsTabPanel ) == targetTab[5] then
					return targetList[5], 5
				elseif guiGetSelectedTab (intsTabPanel ) == targetTab[6] then
					return targetList[6], 6
				else
					return false, false
				end
			else
				return false, false
			end
		end

		addEventHandler("onClientGUIClick", bClose, singleClickedGate)

		addEventHandler( "onClientGUIClick", bSearch,
			function( button )
				if button == "left" then
					if wInteriorSearch then
						destroyElement(wInteriorSearch)
						wInteriorSearch = nil
					end
					showCursor(true)
					guiSetInputEnabled(true)
					wInteriorSearch = guiCreateWindow(sx/2-176,sy/2-52,352,104,"Interior Search",false)
					guiWindowSetSizable(wInteriorSearch,false)
					local lText = guiCreateLabel(10,22,341,16,"Input any related information about an interior (ID, Name, Owner, Price,...) :",false,wInteriorSearch)
					guiSetFont(lText,"default-small")
					local eSearch = guiCreateEdit(10,38,331,31,"Search...",false,wInteriorSearch)
					addEventHandler("onClientGUIFocus", eSearch, function ()
						guiSetText(eSearch , "")
					end, false)
					local bCancel = guiCreateButton(10,73,169,22,"CANCEL",false,wInteriorSearch)
					guiSetFont(bCancel,"default-bold-small")
					addEventHandler( "onClientGUIClick", bCancel, function( button )
						if button == "left" and wInteriorSearch then
							destroyElement(wInteriorSearch)
							wInteriorSearch = nil
							-- showCursor(false)
							-- guiSetInputEnabled(false)
						end
					end, false)
					local bGo = guiCreateButton(179,73,162,22,"GO",false,wInteriorSearch)
					guiSetFont(bGo,"default-bold-small")
					addEventHandler( "onClientGUIClick", bGo, function( button )
						if button == "left" and wInteriorSearch then
							triggerServerEvent("interiorManager:Search", localPlayer, guiGetText(eSearch))
							destroyElement(wInteriorSearch)
							wInteriorSearch = nil
							-- showCursor(false)
							-- guiSetInputEnabled(false)
						end
					end, false)
				end
			end,
		false)

		addEventHandler( "onClientGUIClick", bDelInt,
			function( button )
				if button == "left" then
					local row, col = -1, -1
					local activeList = getListFromActiveTab(intsTabPanel)
					if activeList then
						local row, col = guiGridListGetSelectedItem(activeList)
						if row ~= -1 and col ~= -1 then
							local gridID = guiGridListGetItemText( activeList , row, 1 )
							if triggerServerEvent("interiorManager:delint", getLocalPlayer(), getLocalPlayer(), gridID) then
								-- closeIntManager()
								-- triggerServerEvent("interiorManager:openit", getLocalPlayer(), getLocalPlayer())
							end
						else
							guiSetText(gWin, "You need to select an interior from the list below first.")
						end
					end
				end
			end,
		false)

		addEventHandler( "onClientGUIClick", bToggleInt,
			function( button )
				if button == "left" then
					local row, col = -1, -1
					local activeList = getListFromActiveTab(intsTabPanel)
					if activeList then
						local row, col = guiGridListGetSelectedItem(activeList)
						if row ~= -1 and col ~= -1 then
							local gridID = guiGridListGetItemText( activeList , row, 1 )
							if triggerServerEvent("interiorManager:disableInt", getLocalPlayer(), getLocalPlayer(), gridID) then
								-- closeIntManager()
								-- triggerServerEvent("interiorManager:openit", getLocalPlayer(), getLocalPlayer())
							end
						else
							guiSetText(gWin, "You need to select an interior from the list below first.")
						end
					end
				end
			end,
		false)

		addEventHandler( "onClientGUIClick", bGotoInt,
			function( button )
				if button == "left" then
					local row, col = -1, -1
					local activeList = getListFromActiveTab(intsTabPanel)
					if activeList then
						local row, col = guiGridListGetSelectedItem(activeList)
						if row ~= -1 and col ~= -1 then
							local gridID = guiGridListGetItemText( activeList , row, 1 )
							if triggerServerEvent("interiorManager:gotoInt", getLocalPlayer(), getLocalPlayer(), gridID) then
								--closeIntManager()
								--triggerServerEvent("interiorManager:openit", getLocalPlayer(), getLocalPlayer())
							end
						else
							guiSetText(gWin, "You need to select an interior from the list below first.")
						end
					end
				end
			end,
		false)

		addEventHandler( "onClientGUIClick", bRestoreInt,
			function( button )
				if button == "left" then
					local row, col = -1, -1
					local activeList = getListFromActiveTab(intsTabPanel)
					if activeList then
						local row, col = guiGridListGetSelectedItem(activeList)
						if row ~= -1 and col ~= -1 then
							local gridID = guiGridListGetItemText( activeList , row, 1 )
							if triggerServerEvent("interiorManager:restoreInt", getLocalPlayer(), getLocalPlayer(), gridID) then
								-- closeIntManager()
								-- triggerServerEvent("interiorManager:openit", getLocalPlayer(), getLocalPlayer())
							end
						else
							guiSetText(gWin, "You need to select an interior from the list below first.")
						end
					end
				end
			end,
		false)

		addEventHandler( "onClientGUIClick", bRemoveInt,
			function( button )
				if button == "left" then
					local row, col = -1, -1
					local activeList = getListFromActiveTab(intsTabPanel)
					if activeList then
						local row, col = guiGridListGetSelectedItem(activeList)
						if row ~= -1 and col ~= -1 then
							local gridID = guiGridListGetItemText( activeList , row, 1 )
							if triggerServerEvent("interiorManager:removeInt", getLocalPlayer(), getLocalPlayer(), gridID) then
								-- closeIntManager()
								-- triggerServerEvent("interiorManager:openit", getLocalPlayer(), getLocalPlayer())
							end
						else
							guiSetText(gWin, "You need to select an interior from the list below first.")
						end
					end
				end
			end,
		false)

		addEventHandler( "onClientGUIClick", bForceSell,
			function( button )
				if button == "left" then
					local row, col = -1, -1
					local activeList = getListFromActiveTab(intsTabPanel)
					if activeList then
						local row, col = guiGridListGetSelectedItem(activeList)
						if row ~= -1 and col ~= -1 then
							local gridID = guiGridListGetItemText( activeList , row, 1 )
							if triggerServerEvent("interiorManager:forceSellInt", getLocalPlayer(), getLocalPlayer(), gridID) then
								-- closeIntManager()
								-- triggerServerEvent("interiorManager:openit", getLocalPlayer(), getLocalPlayer())
							end
						else
							guiSetText(gWin, "You need to select an interior from the list below first.")
						end
					end
				end
			end,
		false)

		addEventHandler( "onClientGUIClick", bAdminNote,
			function( button )
				if button == "left" then
					local row, col = -1, -1
					local activeList = getListFromActiveTab(intsTabPanel)
					if activeList then
						local row, col = guiGridListGetSelectedItem(activeList)
						if row ~= -1 and col ~= -1 then
							local gridID = guiGridListGetItemText( activeList , row, 1 )
							if triggerServerEvent("interiorManager:openAdminNote", getLocalPlayer(), getLocalPlayer(), gridID) then
								--guiGridListRemoveRow ( activeList, row )
							end
						else
							guiSetText(gWin, "You need to select an interior from the list below first.")
						end
					end
				end
			end,
		false)

	function fetchSearchResults(interiorsResultList)
		if interiorsResultList then
			local i = 6
			guiGridListClear ( targetList[i] )
			local activeList, index = getListFromActiveTab(intsTabPanel)
			if index ~= i then
				guiSetSelectedTab ( intsTabPanel, targetTab[i] )
			end
			for _, record in ipairs(interiorsResultList) do
				local row = guiGridListAddRow(targetList[i])
				guiGridListSetItemText(targetList[i], row, colID[i], record[1] or "", false, true)
				guiGridListSetItemText(targetList[i], row, colType[i], intTypeName(record[2]), false, false)
				guiGridListSetItemText(targetList[i], row, colName[i], record[3] or "", false, false)
				guiGridListSetItemText(targetList[i], row, colPrice[i], record[4], false, true)
				guiGridListSetItemText(targetList[i], row, colOwner[i], charName(record[5])..cked(record[7])..accountName(record[6])..(record[20] or ""), false, false)
				local lastUsed, isInteriorInactive = formartDays(record[8])
				guiGridListSetItemText(targetList[i], row, colLastUsed[i],lastUsed , false, false)
				guiGridListSetItemText(targetList[i], row, colAddress[i], record[21] or "", false, false) --MS: Added in to add the address to search results
				guiGridListSetItemText(targetList[i], row, colLocked[i], record[9] == "0" and "Unlocked" or "Locked", false, false)
				guiGridListSetItemText(targetList[i], row, colSupplies[i], record[10] or "", false, false)
				guiGridListSetItemText(targetList[i], row, colSafeInstalled[i], record[11] and "Yes" or "No", false, false)
				guiGridListSetItemText(targetList[i], row, colDisabled[i], record[12] == "1" and "Yes" or "No", false, false)
				guiGridListSetItemText(targetList[i], row, colDeleted[i], record[13] == "0" and "No" or "by "..record[13], false, false)
				guiGridListSetItemText(targetList[i], row, colCreatedBy[i], record[16] or "", false, false)
				guiGridListSetItemText(targetList[i], row, colCreatedDate[i], record[15] or "", false, false)
				guiGridListSetItemText(targetList[i], row, colAdminNote[i], record[14] or "", false, false)
			end
		end
	end
	addEvent("interiorManager:FetchSearchResults", true)
	addEventHandler("interiorManager:FetchSearchResults", localPlayer, fetchSearchResults)
	triggerEvent("hud:convertUI", localPlayer, gWin)
	end
end
addEvent("createIntManagerWindow", true)
addEventHandler("createIntManagerWindow", localPlayer, createIntManagerWindow)

function formartDays(days)
	if not days then
		return "Unknown", false
	elseif tonumber(days) == 0 then
		return "Today", false
	elseif tonumber(days) >= 14 then
		return days.." days ago (inactive)", true
	else
		return days.." days ago", false
	end
end

function intTypeName(intType)
	local intTypeName = "Unknown"
	if intType == "0" then
		intTypeName = "House"
	elseif intType == "1" then
		intTypeName = "Business"
	elseif intType == "2" then
		intTypeName = "Government"
	elseif intType == "3" then
		intTypeName = "Rentable"
	end
	return intTypeName
end

function cked(ckStatus)
	local cked = ""
	if ckStatus == "1" then
		cked = " - CKed"
	end
	return cked
end

function charName(name)
	local charName = ""
	if name then
		charName = name:gsub("_", " ")
	end
	return charName
end

function accountName(id)
	local accountName = ""
	if id then
		local name = exports.cache:getUsernameFromId(id)
		if name then
			accountName = " ("..name..")"
		end
	end
	return accountName
end

function closeIntManager()
	if gWin then
		removeEventHandler("onClientGUIClick", root, singleClickedGate)
		destroyElement(gWin)
		gWin = nil
		if wInteriorSearch then
			destroyElement(wInteriorSearch)
			wInteriorSearch = nil
		end
		showCursor(false)
		guiSetInputEnabled(false)
		intsTabPanel = nil
	end
end

function singleClickedGate()
	if source == bClose then
		closeIntManager()
	end
end

local notes = {}
local bAddNote = nil
local gAdminNote = nil
local newNoteLabel, newNoteMemo = nil
local currentNote = nil

function drawAdminNotes(tabAdminNote)
	if tabAdminNote and isElement(tabAdminNote) then
		cleanAllNotesGUI()
		guiSetText(bAddNote, "ADD NEW NOTE")
		gAdminNote = guiCreateGridList(0,0,1,1,true,tabAdminNote)
		local note_colDate = guiGridListAddColumn(gAdminNote,"Date",0.25)
		local note_colNote = guiGridListAddColumn(gAdminNote,"Content",0.5)
		local note_colCreator = guiGridListAddColumn(gAdminNote,"Creator",0.1)
		local note_colNoteId = guiGridListAddColumn(gAdminNote,"Note Entry",0.1)
		for i, note in ipairs(notes) do
			local row = guiGridListAddRow(gAdminNote)
			guiGridListSetItemText(gAdminNote, row, note_colDate, note.date , false, true)
			guiGridListSetItemText(gAdminNote, row, note_colNote, note.note, false, false)
			guiGridListSetItemText(gAdminNote, row, note_colCreator, note.creatorname, false, false)
			guiGridListSetItemText(gAdminNote, row, note_colNoteId, note.id, false, false)
		end
		addEventHandler("onClientGUIDoubleClick", gAdminNote, function (button, state)
			if source == gAdminNote then
				local row, col = guiGridListGetSelectedItem( source )
				if row ~= -1 and col ~= -1 then
					local noteId = guiGridListGetItemText( source , row, 4 )
					drawNewNote(tabAdminNote, #notes<1, noteId, button == "left")
				end
			end
		end)
	end
end

function drawNewNote(tabAdminNote, isNotesEmpty, noteId, editExiting)
	if tabAdminNote and isElement(tabAdminNote) then
		cleanAllNotesGUI()
		guiSetText(bAddNote, "SHOW NOTES")
		local margin = 0.01
		local textH = 0.1
		local text = "You can create a new note entry below:"
		if noteId then
			currentNote = getNoteFromId(noteId)
			if editExiting then
				text = "Editing note #"..noteId.." by "..currentNote.creatorname..". This note's creator will be transferred to you upon completion:"
				currentNote.edit = true
			else
				text = "Viewing note #"..noteId.." by "..currentNote.creatorname..". To edit, double LEFT click instead."
			end
		elseif isNotesEmpty then
			text = "There is no note found on this interior. "..text
		end
		local curMemo = currentNote and currentNote.note or nil
		newNoteLabel = guiCreateLabel(margin, margin*2, 1-margin*2, textH, text, true, tabAdminNote)
		newNoteMemo = guiCreateMemo(margin, margin*2+textH, 1-margin*2, 0.85, curMemo or "", true, tabAdminNote)
		if currentNote and not currentNote.edit then
			guiMemoSetReadOnly(newNoteMemo, true)
		end
	end
end

function getNoteFromId(id)
	for i, note in pairs(notes) do
		if tonumber(note.id) == tonumber(id) then
			return note
		end
	end
end

function cleanAllNotesGUI()
	if newNoteLabel and isElement(newNoteLabel) then destroyElement(newNoteLabel) newNoteLabel = nil destroyElement(newNoteMemo) newNoteMemo = nil end
	if gAdminNote and isElement(gAdminNote) then destroyElement(gAdminNote) gAdminNote = nil end
	currentNote = nil
end

function createCheckIntWindow(result, adminTitle, history, notes1, players)
	if checkIntWindow then
		closeCheckIntWindow()
	end
	showCursor(true)
	guiSetInputEnabled(true)
	notes = notes1
	checkIntWindow = guiCreateWindow(sx/2-300,sy/2-233,600,466,"Interior Manager - Interior Admin Note - "..adminTitle.." "..getElementData( getLocalPlayer(), "account:username" ),false)
	guiWindowSetSizable(checkIntWindow,false)
	local lIntNameID = guiCreateLabel(12,27,365,17,"Interior Name/ID: ",false,checkIntWindow)
	local lOwner = guiCreateLabel(12,44,365,17,"Owner: ",false,checkIntWindow)
	local lLastUsed = guiCreateLabel(12,112,163,17,"Last Used: ",false,checkIntWindow)
	local lLocked = guiCreateLabel(372,61,163,17,"Locked: ",false,checkIntWindow)
	--local lSupplies = guiCreateLabel(372,95,163,17,"Supplies: ",false,checkIntWindow) No longer in use can be repurposed
	local lDeleted = guiCreateLabel(372,27,163,17,"Deleted: ",false,checkIntWindow)
	local lPrice = guiCreateLabel(12,78,163,17,"Price: ",false,checkIntWindow)
	local lType = guiCreateLabel(12,61,163,17,"Type: ",false,checkIntWindow)
	local lDisabled = guiCreateLabel(372,44,163,17,"Disabled: ",false,checkIntWindow)
	local lHasSafe = guiCreateLabel(372,78,163,17,"Has Safe: ",false,checkIntWindow)
	local lCreateDate = guiCreateLabel(372,112,200,17,"Created Date: ",false,checkIntWindow)
	local lCreateBy = guiCreateLabel(372,129,200,17,"Created By: ",false,checkIntWindow)
	local lAddress = guiCreateLabel(12,95,365,17,"Address: ",false,checkIntWindow) -- MS: Changed from lLocation to lAddress (Location appended to end of address)
	--local lLocation = guiCreateLabel(12,95,163,17,"Location: ",false,checkIntWindow)
	local lToken = guiCreateLabel(372, 146, 365, 17,"Token Used: ",false,checkIntWindow)
	local lAdminNote = guiCreateLabel(12,133,80,17,"Admin Note: ",false,checkIntWindow)
	guiSetFont(lAdminNote,"default-bold-small")
	local checkIntTabPanel = guiCreateTabPanel(12,156,576,269,false,checkIntWindow)
	local tabAdminNote = guiCreateTab( "Admin Note", checkIntTabPanel )
	local bCopyAdminInfo = guiCreateButton(110,133,220,20,"Copy Your Admin Name & Current Date",false,checkIntWindow)

	local tabHistory = guiCreateTab( "History", checkIntTabPanel )
	local gHistory = guiCreateGridList(0,0,1,1,true,tabHistory)
	local colDate = guiGridListAddColumn(gHistory,"Date",0.25)
	local colAction = guiGridListAddColumn(gHistory,"Action",0.5)
	local colActor = guiGridListAddColumn(gHistory,"Actor",0.1)
	local colLogID = guiGridListAddColumn(gHistory,"Log Entry",0.1)
	
	local tabPlayers = guiCreateTab("Players", checkIntTabPanel)
	local gPlayers = guiCreateGridList(0, 0, 1, 1, true, tabPlayers)
	local colCharacter = guiGridListAddColumn(gPlayers, "Character", 0.35)
	local colAccount = guiGridListAddColumn(gPlayers, "Account", 0.35)
	local colLogged = guiGridListAddColumn(gPlayers, "Last seen", 0.25)
	
	for i, v in ipairs(players) do
		guiGridListAddRow(gPlayers, v[2]:gsub("_", " "), v[1], v[3])
	end
	
	
	--local district = getZoneName ( result[1][19], result[1][20], result[1][21], false ) .. ", " .. getZoneName ( result[1][19], result[1][20], result[1][21], true ) --MS: Added in, as location didn't even have anything to set it to begin with.

	--fetching shit
	guiSetText(lIntNameID, "Interior Name/ID: ("..result[1][1]..") "..result[1][3])
	guiSetText(lOwner, "Owner: "..charName(result[1][5])..cked(result[1][7])..accountName(result[1][6])..(result[1][22] or ""))
	guiSetText(lLastUsed, "Last Used: "..formartDays(result[1][8]))
	guiSetText(lLocked, "Locked: "..(result[1][9] == "0" and "Unlocked" or "Locked"))
	--guiSetText(lSupplies, "Supplies: "..result[1][10] or "") No longer in use due to the JSON supply update
	guiSetText(lDeleted, "Deleted: "..(result[1][15] == "0" and "No" or " by "..result[1][15]))
	guiSetText(lPrice, "Price: $"..result[1][4] or "")
	guiSetText(lType, "Type: "..intTypeName(result[1][2]) or "")
	guiSetText(lDisabled, "Disabled: "..(result[1][12] == "1" and "Yes" or "No"))
	guiSetText(lHasSafe, "Has Safe: "..(result[1][11] and "Yes" or "No"))
	guiSetText(lCreateDate, "Created Date: "..(result[1][17] or ""))
	guiSetText(lCreateBy, "Created By: "..(result[1][18] or ""))
	guiSetText(lToken, "Token Used: " .. (result[1][23] == "1" and "Yes" or "No"))
	guiSetText(lAddress, "Address: "..((result[1][23] and result[1][24]) or "")) --MS: Setting address text + location text onto it

	-- Fetching history
	if history then
		for _, h in ipairs(history) do
			local row = guiGridListAddRow(gHistory)
			guiGridListSetItemText(gHistory, row, colDate, h[1] or "N/A", false, true)
			guiGridListSetItemText(gHistory, row, colAction, h[2] or "N/A", false, false)
			guiGridListSetItemText(gHistory, row, colActor, h[3] or "N/A", false, false)
			guiGridListSetItemText(gHistory, row, colLogID, h[4] or "N/A", false, false)
		end
		-- guiGridListAutoSizeColumn ( gHistory, 1 )
		-- guiGridListAutoSizeColumn ( gHistory, 2 )
		-- guiGridListAutoSizeColumn ( gHistory, 3 )
		-- guiGridListAutoSizeColumn ( gHistory, 4 )
	end

	bAddNote = guiCreateButton(212+100,430,90,28,"ADD NEW NOTE",false,checkIntWindow)
		guiSetFont(bAddNote,"default-bold-small")
	addEventHandler( "onClientGUIClick", bAddNote,
		function( button )
			if button == "left" then
				if guiGetText(bAddNote) == "ADD NEW NOTE" then
					drawNewNote(tabAdminNote, #notes<1)
				else
					drawAdminNotes(tabAdminNote)
				end
			end
		end,
	false)
	if notes and #notes>0 then
		drawAdminNotes(tabAdminNote, notes)
	else
		drawNewNote(tabAdminNote, #notes<1)
	end



	local bToggleInt1 = guiCreateButton(212,430,90,28,"TOGGLE INT",false,checkIntWindow)
		guiSetFont(bToggleInt1,"default-bold-small")
	addEventHandler( "onClientGUIClick", bToggleInt1,
		function( button )
			if button == "left" then
				triggerServerEvent("interiorManager:disableInt", getLocalPlayer(), getLocalPlayer(), result[1][1])
			end
		end,
	false)

	--local bGotoSafe = guiCreateButton(312,430,90,28,"GO TO SAFE",false,checkIntWindow)
		--guiSetFont(bGotoSafe,"default-bold-small")
		--guiSetEnabled(bGotoSafe, false)

	local bGotoInt1, bRestoreInt1, bDelInt1 = nil
	if result[1][15] ~= "0" then --deleted
		bRestoreInt1 = guiCreateButton(12,430,90,28,"RESTORE INT",false,checkIntWindow)
		guiSetFont(bRestoreInt1,"default-bold-small")
		addEventHandler( "onClientGUIClick", bRestoreInt1,
			function( button )
				if button == "left" then
					if triggerServerEvent("interiorManager:restoreInt", getLocalPlayer(), getLocalPlayer(), result[1][1]) then
						--setTimer(function ()
							triggerServerEvent("interiorManager:checkint", getLocalPlayer(), getLocalPlayer(), "checkint", result[1][1])
						--end, 50, 1)
					end
				end
			end,
		false)
		bRemoveInt1 = guiCreateButton(112,430,90,28,"REMOVE INT",false,checkIntWindow)
		guiSetFont(bRemoveInt1,"default-bold-small")
		addEventHandler( "onClientGUIClick", bRemoveInt1,
			function( button )
				if button == "left" then
					if triggerServerEvent("interiorManager:removeInt", getLocalPlayer(), getLocalPlayer(), result[1][1]) then
						closeCheckIntWindow()
					end
				end
			end,
		false)
		if getElementData(localPlayer, "admin_level") < 6 then
			guiSetEnabled(bRemoveInt1, false)
		end
		guiSetEnabled(bToggleInt1, false)
	else
		bGotoInt1 = guiCreateButton(12,430,90,28,"GO TO INT",false,checkIntWindow)
		guiSetFont(bGotoInt1,"default-bold-small")
		addEventHandler( "onClientGUIClick", bGotoInt1,
			function( button )
				if button == "left" then
					triggerServerEvent("interiorManager:gotoInt", getLocalPlayer(), getLocalPlayer(), result[1][1])
				end
			end,
		false)
		bDelInt1 = guiCreateButton(112,430,90,28,"DEL INT",false,checkIntWindow)
		guiSetFont(bDelInt1,"default-bold-small")
		addEventHandler( "onClientGUIClick", bDelInt1,
			function( button )
				if button == "left" then
					if triggerServerEvent("interiorManager:delint", getLocalPlayer(), getLocalPlayer(), result[1][1]) then
						triggerServerEvent("interiorManager:checkint", getLocalPlayer(), getLocalPlayer(), "checkint", result[1][1])
					end
				end
			end,
		false)
	end

	if result[1][11] then --if has safe
		--guiSetEnabled(bGotoSafe, true)
	end

	local bSave = guiCreateButton(412,430,90,28,"SAVE",false,checkIntWindow)
		guiSetFont(bSave,"default-bold-small")
	local bClose = guiCreateButton(509,430,79,28,"CLOSE",false,checkIntWindow)
		guiSetFont(bClose,"default-bold-small")

	addEventHandler( "onClientGUIClick", bClose,
		function( button )
			if button == "left" then
				closeCheckIntWindow()
			end
		end,
	false)

	addEventHandler( "onClientGUIClick", bCopyAdminInfo,
		function( button )
			if button == "left" then
				local time = getRealTime()
				local date = time.monthday
				local month = time.month+1
				local year = time.year+1900
				local adminUsername = getElementData( getLocalPlayer(), "account:username" )
				local content = " ("..adminTitle.." "..adminUsername.." on "..date.."/"..month.."/"..year..")"
				if setClipboard(content) then
					guiSetText(checkIntWindow, "Copied: '"..content.."'")
				end
			end
		end,
	false)

	addEventHandler( "onClientGUIClick", bSave,
		function( button )
			if button == "left" then
				--if triggerServerEvent("interiorManager:saveAdminNote", getLocalPlayer(), getLocalPlayer(), guiGetText(mAdminNote),result[1][1] ) then
				--	outputChatBox("Admin Note on '("..result[1][1]..") "..result[1][3].."' has been successfully saved!", 0,255,0)
				--end
				local noteMemo = nil
				if newNoteMemo and isElement(newNoteMemo) then
					noteMemo = guiGetText(newNoteMemo) or nil
				end
				if noteMemo == "" or noteMemo == "\n" then
					noteMemo = nil
				end
				if noteMemo or (currentNote and currentNote.edit and currentNote.note~=noteMemo) then
					triggerServerEvent("interiorManager:saveAdminNote", localPlayer, result[1][1] , noteMemo, currentNote and currentNote.id)
					exports.global:playSoundSuccess()
					closeCheckIntWindow()
				else
					outputChatBox("Nothing to save.")
				end
			end
		end,
	false)
	
	triggerEvent("hud:convertUI", localPlayer, checkIntWindow)
end
addEvent("createCheckIntWindow", true)
addEventHandler("createCheckIntWindow", localPlayer, createCheckIntWindow)

function closeCheckIntWindow()
	if checkIntWindow then
		destroyElement(checkIntWindow)
		checkIntWindow = nil
		showCursor(false)
		guiSetInputEnabled(false)
		cleanAllNotesGUI()
	end
end
