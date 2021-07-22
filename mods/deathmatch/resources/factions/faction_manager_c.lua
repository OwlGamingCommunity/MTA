--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local function togWindow( win, state )
	if win and isElement( win ) then
		guiSetEnabled( win, state )
	end
end

local function canEditFaction( thePlayer )
	return exports.integration:isPlayerLeadAdmin(thePlayer) or exports.integration:isPlayerFMTLeader(thePlayer)
end

local fGUI = {
    gridlist = {},
    window = {},
    button = {},
    label = {}
}

local factions_tmp

local function getFactionTableFromId( id, table )	
	for _, fact in pairs( table ) do
		if fact.id == id then
			return fact
		end
	end
end

function showFactionList( factions )
	factions_tmp = factions
	-- create window if not created.
	if not fGUI.window[1] and not isElement( fGUI.window[1] ) then
		triggerEvent( 'hud:blur', resourceRoot, 6, false, 0.5, nil )
		fGUI.window[1] = guiCreateWindow(115, 175, 800, 600, "Faction Manager", false)
		guiWindowSetSizable(fGUI.window[1], false)
		exports.global:centerWindow( fGUI.window[1] )
		fGUI.button[1] = guiCreateButton(674, 552, 116, 38, "Close", false, fGUI.window[1])
		fGUI.button[2] = guiCreateButton(10, 552, 116, 38, "Create Faction", false, fGUI.window[1])
		fGUI.button[3] = guiCreateButton(136, 552, 116, 38, "Edit Faction", false, fGUI.window[1])
		fGUI.button[4] = guiCreateButton(262, 552, 116, 38, "List Members", false, fGUI.window[1])
		fGUI.button[5] = guiCreateButton(388, 552, 116, 38, "Delete Faction", false, fGUI.window[1])
		fGUI.button[6] = guiCreateButton(514, 552, 116, 38, "Refresh", false, fGUI.window[1])
		local canEdit = canEditFaction( localPlayer )
		guiSetEnabled( fGUI.button[2], canEdit )
		guiSetEnabled( fGUI.button[3], canEdit )
		guiSetEnabled( fGUI.button[5], canEdit )
		addEventHandler( 'onClientGUIClick', fGUI.window[1], function()
			if source == fGUI.button[1] then
				closeFactionList()
			elseif source == fGUI.button[2] then
				editFaction()
			elseif source ==  fGUI.button[3] and fGUI.gridlist[1]  then
				local row, col = guiGridListGetSelectedItem( fGUI.gridlist[1] )
				if row ~= -1 and col ~= -1 then
					local gridID = guiGridListGetItemText( fGUI.gridlist[1] , row, 1 )
					editFaction( gridID )
				else
					exports.global:playSoundError()
					outputChatBox( "You need to select an item from the list first.", 255, 0, 0 )
				end
			elseif source == fGUI.button[4] then
				local row, col = guiGridListGetSelectedItem( fGUI.gridlist[1] )
				if row ~= -1 and col ~= -1 then
					listMember( guiGridListGetItemText( fGUI.gridlist[1] , row, 1 ) )
				else
					exports.global:playSoundError()
					outputChatBox( "You need to select an item from the list first.", 255, 0, 0 )
				end
			elseif source == fGUI.button[5] then
				local row, col = guiGridListGetSelectedItem( fGUI.gridlist[1] )
				if row ~= -1 and col ~= -1 then
					local gridID = guiGridListGetItemText( fGUI.gridlist[1] , row, 1 )
					delConfirm( gridID )
				else
					exports.global:playSoundError()
					outputChatBox( "You need to select an item from the list first.", 255, 0, 0 )
				end
			elseif source == fGUI.button[6] then
				showFactionList()
			end
		end)
		addEventHandler( 'onClientGUIDoubleClick', fGUI.window[1], function ()
			if source == fGUI.gridlist[1] then
				local row, col = guiGridListGetSelectedItem( fGUI.gridlist[1] )
				if row ~= -1 and col ~= -1 then
					local text = guiGridListGetItemText( fGUI.gridlist[1] , row, col )
					if setClipboard( text ) then
						exports.global:playSoundSuccess()
						outputChatBox( "Copied '" .. text .. "'." )
					end
				end
			end
		end)
	end

	-- if data is not ready.
	if not factions then
		if not fGUI.label[1] then
			if fGUI.gridlist[1] and isElement( fGUI.gridlist[1] ) then
				destroyElement( fGUI.gridlist[1] )
				fGUI.gridlist[1] = nil
			end
			fGUI.label[1] = guiCreateLabel ( 0, 0, 1, 1, "Fetching information from server...", true, fGUI.window[1] )
			guiLabelSetHorizontalAlign( fGUI.label[1], 'center' )
			guiLabelSetVerticalAlign( fGUI.label[1], 'center' )
			triggerServerEvent( 'factions:fetchFactionList', resourceRoot )
			guiSetEnabled( fGUI.window[1], false )
		end
	else
		destroyElement( fGUI.label[1] )
		fGUI.label[1] = nil
		fGUI.gridlist[1] = guiCreateGridList(9, 26, 781, 520, false, fGUI.window[1])
		guiGridListSetSelectionMode ( fGUI.gridlist[1], 2 )
		fGUI.gridlist.colID = guiGridListAddColumn(fGUI.gridlist[1], "ID", 0.08)
		fGUI.gridlist.colName = guiGridListAddColumn(fGUI.gridlist[1], "Faction Name", 0.23)
		fGUI.gridlist.colPlayers = guiGridListAddColumn(fGUI.gridlist[1], "Online Members", 0.1)
		fGUI.gridlist.colType = guiGridListAddColumn(fGUI.gridlist[1], "Type", 0.1)
		fGUI.gridlist.colInts = guiGridListAddColumn(fGUI.gridlist[1], "Interiors", 0.07 )
		fGUI.gridlist.colVehs = guiGridListAddColumn(fGUI.gridlist[1], "Vehicles", 0.07 )
		fGUI.gridlist.colIntPerk = guiGridListAddColumn(fGUI.gridlist[1], "Free Custom Ints", 0.08)
		fGUI.gridlist.colSkinPerk = guiGridListAddColumn(fGUI.gridlist[1], "Free Custom Skins", 0.08)
		fGUI.gridlist.colBeforeTax = guiGridListAddColumn(fGUI.gridlist[1], "Amount Before Tax", 0.14)
		fGUI.gridlist.colFreeWage = guiGridListAddColumn(fGUI.gridlist[1], "Wage before faction is charged", 0.20)
		guiSetEnabled( fGUI.window[1], true )
		for _, value in ipairs(factions) do
			local row = guiGridListAddRow(fGUI.gridlist[1])
			guiGridListSetItemText(fGUI.gridlist[1], row, fGUI.gridlist.colID, value.id, false, true)
			guiGridListSetItemData ( fGUI.gridlist[1], row, fGUI.gridlist.colID, value.id )
			guiGridListSetItemText(fGUI.gridlist[1], row, fGUI.gridlist.colName, value.name, false, false)
			guiGridListSetItemText(fGUI.gridlist[1], row, fGUI.gridlist.colPlayers, value.members, false, false)
			guiGridListSetItemText(fGUI.gridlist[1], row, fGUI.gridlist.colType, getFactionTypes( value.type ), false, false)
			guiGridListSetItemText(fGUI.gridlist[1], row, fGUI.gridlist.colInts, value.ints .. ' / ' .. value.max_interiors , false, false)
			guiGridListSetItemText(fGUI.gridlist[1], row, fGUI.gridlist.colVehs, value.vehs .. ' / ' .. value.max_vehicles , false, false)
			guiGridListSetItemText(fGUI.gridlist[1], row, fGUI.gridlist.colIntPerk, value.free_custom_ints == 1 and 'Yes' or 'No', false, false)
			guiGridListSetItemText(fGUI.gridlist[1], row, fGUI.gridlist.colSkinPerk, value.free_custom_skins == 1 and 'Yes' or 'No', false, false)
			guiGridListSetItemText(fGUI.gridlist[1], row, fGUI.gridlist.colBeforeTax, '$' .. exports.global:formatMoney(value.before_tax), false, false)
			guiGridListSetItemText(fGUI.gridlist[1], row, fGUI.gridlist.colFreeWage, '$' .. exports.global:formatMoney(value.free_wage), false, false)
		end
	end
end
addEvent( "showFactionList", true )
addEventHandler( "showFactionList", resourceRoot, showFactionList )

function showFactionListCmd()
	if exports.integration:isPlayerTrialAdmin( localPlayer ) or exports.integration:isPlayerSupporter( localPlayer ) or exports.integration:isPlayerScripter( localPlayer ) or exports.integration:isPlayerFMTMember( localPlayer ) then
		showFactionList()
	end
end
addCommandHandler( "showfactions", showFactionListCmd, false, false )
addCommandHandler( "factions", showFactionListCmd, false, false )
addCommandHandler( "makefaction", showFactionListCmd, false, false )
addCommandHandler( "renamefaction", showFactionListCmd, false, false )
addCommandHandler( "delfaction", showFactionListCmd, false, false )

function closeFactionList()
	if fGUI.window[1] and isElement( fGUI.window[1] ) then
		destroyElement( fGUI.window[1] )
		fGUI.window[1] = nil
		closeEditFaction()
		closeDelConfirm()
		closeListMember()
		triggerEvent( 'hud:blur', resourceRoot, 'off' )
	end
end


local editFact = {
    checkbox = {},
    edit = {},
    button = {},
    window = {},
    label = {},
    combobox = {}
}

function editFaction( fact_id )
	closeEditFaction()
	guiSetInputEnabled( true )
	local data = fact_id and getFactionTableFromId( tonumber(fact_id), factions_tmp ) or nil
    editFact.window[1] = guiCreateWindow(155, 453, 385, 300, fact_id and "Edit Faction" or "Create new faction", false)
    guiWindowSetSizable(editFact.window[1], false)
    exports.global:centerWindow( editFact.window[1] )
    togWindow( fGUI.window[1], false )

    editFact.label[1] = guiCreateLabel(20, 26, 97, 29, "Faction Name:", false, editFact.window[1])
    guiLabelSetVerticalAlign(editFact.label[1], "center")
    editFact.edit.name = guiCreateEdit(117, 26, 246, 29, data and data.name or "", false, editFact.window[1])
    guiEditSetMaxLength( editFact.edit.name, 200 )
    editFact.label[2] = guiCreateLabel(20, 65, 97, 29, "Faction ID:", false, editFact.window[1])
	guiLabelSetVerticalAlign(editFact.label[2], "center")

	editFact.label[6] = guiCreateLabel(20, 130, 140, 29, "Asset value before tax:", false, editFact.window[1])
	guiLabelSetVerticalAlign(editFact.label[6], "center")

	editFact.edit.beforeTax = guiCreateEdit(172, 130, 190, 29, data and data.before_tax or "0", false, editFact.window[1])

	editFact.label[7] = guiCreateLabel(20, 162, 140, 29, "Wage amount before\nfaction is charged:", false, editFact.window[1])
	guiLabelSetVerticalAlign(editFact.label[7], "center")

	editFact.edit.freeWage = guiCreateEdit(172, 165, 190, 29, data and data.free_wage or "0", false, editFact.window[1])

    editFact.combobox[1] = guiCreateComboBox(120, 100, 245, 29, "Select a faction type", false, editFact.window[1])
    local types = getFactionTypes()
    for id, name in pairs( types ) do
    	guiComboBoxAddItem( editFact.combobox[1], name )
    end
    exports.global:guiComboBoxAdjustHeight( editFact.combobox[1], exports.global:countTable( types ) )
    if data then
    	guiSetText( editFact.combobox[1], types[ tostring(data.type or 5) ] )
    end
    editFact.edit.id = guiCreateEdit(117, 65, 246, 29, data and data.id or "auto", false, editFact.window[1])
    guiSetEnabled( editFact.edit.id, false )
    guiEditSetMaxLength( editFact.edit.id, 10 )
    editFact.label[3] = guiCreateLabel(20, 100, 97, 29, "Faction Type:", false, editFact.window[1])
    guiLabelSetVerticalAlign(editFact.label[3], "center")
    editFact.label[4] = guiCreateLabel(20, 205, 97, 29, "Max Interiors:", false, editFact.window[1])
    guiLabelSetVerticalAlign(editFact.label[4], "center")
    editFact.edit.max_interiors = guiCreateEdit(117, 205, 62, 29, data and data.max_interiors or "20", false, editFact.window[1])
    guiEditSetMaxLength( editFact.edit.max_interiors, 10 )
    editFact.label[5] = guiCreateLabel(204, 205, 97, 29, "Max Vehicles:", false, editFact.window[1])
    guiLabelSetVerticalAlign(editFact.label[5], "center")
    editFact.edit.max_vehicles = guiCreateEdit( 301, 205, 62, 29, data and data.max_vehicles or "40", false, editFact.window[1] )
    guiEditSetMaxLength( editFact.edit.max_vehicles, 10 )
    editFact.checkbox[1] = guiCreateCheckBox(20, 238, 144, 29, "Free custom interiors", data and data.free_custom_ints == 1 or false, false, editFact.window[1])
    editFact.checkbox[2] = guiCreateCheckBox(20, 260, 144, 29, "Free custom skins", data and data.free_custom_skins == 1 or false, false, editFact.window[1])
    editFact.button[1] = guiCreateButton(179, 250, 88, 40, "Cancel", false, editFact.window[1])
    editFact.button[2] = guiCreateButton(277, 250, 88, 40, "Submit", false, editFact.window[1])
    addEventHandler( 'onClientGUIClick', editFact.window[1], function()
    	if source == editFact.button[1] then
    		closeEditFaction()
    	elseif source == editFact.button[2] then
    		local submit_data = {}
    		submit_data.name = guiGetText( editFact.edit.name )
    		submit_data.type = nil
    		for type_id, type_name in pairs( types ) do
    			if guiGetText( editFact.combobox[1] ) == type_name then
    				submit_data.type = tonumber( type_id )
    				break
    			end
    		end
    		submit_data.max_interiors = tonumber( guiGetText( editFact.edit.max_interiors ) )
    		submit_data.max_vehicles = tonumber( guiGetText( editFact.edit.max_vehicles ) )
    		submit_data.free_custom_ints = guiCheckBoxGetSelected( editFact.checkbox[1] ) and 1 or 0
			submit_data.free_custom_skins = guiCheckBoxGetSelected( editFact.checkbox[2] ) and 1 or 0
			submit_data.before_tax_value = tonumber( guiGetText( editFact.edit.beforeTax ) )
			submit_data.free_wage_amount = tonumber( guiGetText( editFact.edit.freeWage ) )

    		if string.len( submit_data.name ) < 3 then
    			exports.global:playSoundError()
    			return not outputChatBox( "Faction name must be in 3 characters length or longer.", 255, 0, 0 )
    		elseif not submit_data.type then
    			exports.global:playSoundError()
    			return not outputChatBox( "Invalid faction type.", 255, 0, 0 )
    		elseif not submit_data.max_interiors or submit_data.max_interiors < 0 then 
    			exports.global:playSoundError()
    			return not outputChatBox( "Max interiors must be positive. ", 255, 0, 0 )
    		elseif not submit_data.max_vehicles or submit_data.max_vehicles < 0 then
    			exports.global:playSoundError()
				return not outputChatBox( "Max vehicles must be positive. ", 255, 0, 0 )
    		else
    			triggerServerEvent( 'factions:editFaction', resourceRoot, submit_data, fact_id )
    			togWindow( editFact.window[1], false )
    		end
    	end
    end)    
end

function closeEditFaction()
	if editFact.window[1] and isElement( editFact.window[1] ) then
		destroyElement( editFact.window[1] )
		editFact.window[1] = nil
		togWindow( fGUI.window[1], true )
		guiSetInputEnabled( false )
	end
end

addEvent( 'factions:editFaction:callback', true )
addEventHandler( 'factions:editFaction:callback', resourceRoot, function ( response )
	if response == 'ok' then
		exports.global:playSoundSuccess()
		closeEditFaction()
		showFactionList()
	else
		exports.global:playSoundError()
		outputChatBox( response, 255, 0, 0 )
		togWindow( editFact.window[1], true )
	end
end )


local delGUI = {
    button = {},
    window = {},
    label = {}
}
function delConfirm( fact_id )
	closeDelConfirm()
	togWindow( fGUI.window[1], false )
	local fact = getFactionTableFromId( tonumber(fact_id), factions_tmp )
    delGUI.window[1] = guiCreateWindow(429, 298, 437, 206, "Delete Faction", false)
    guiWindowSetSizable(delGUI.window[1], false)
    exports.global:centerWindow( delGUI.window[1] )

    delGUI.label[1] = guiCreateLabel(15, 43, 412, 110, "You're about to delete faction ID #" .. fact.id .. " (" .. fact.name .. ").\n\nEverything associated with the faction including interiors, vehicles, items, etc owned by the faction will also be destroyed.\nThis action can not be undone.\n\nAre you sure you want to continue?", false, delGUI.window[1])
    guiLabelSetHorizontalAlign(delGUI.label[1], "left", true)
    delGUI.button[1] = guiCreateButton(17, 158, 200, 33, "Cancel", false, delGUI.window[1])
    delGUI.button[2] = guiCreateButton(223, 158, 200, 33, "Proceed", false, delGUI.window[1])    
    addEventHandler( 'onClientGUIClick', delGUI.window[1], function ()
    	if source == delGUI.button[1] then
    		closeDelConfirm()
    	elseif source == delGUI.button[2] then
    		closeDelConfirm()
    		triggerServerEvent( 'factions:delete', resourceRoot, fact_id )
    	end
    end)
end

function closeDelConfirm()
	if delGUI.window[1] and isElement( delGUI.window[1] ) then
		destroyElement( delGUI.window[1] )
		delGUI.window[1] = nil
		togWindow( fGUI.window[1], true )
	end
end


local listMemberGUI = {
    gridlist = {},
    window = {},
    button = {},
    label = {},
    col={},
}

local fact_id_tmp
function listMember( fact_id, response, data )
	closeListMember()
	togWindow( fGUI.window[1], false )
	local wExtend = 45
    listMemberGUI.window[1] = guiCreateWindow(519, 255, 555+wExtend, 372, "Listing Faction Members", false)
    guiWindowSetSizable(listMemberGUI.window[1], false)
    exports.global:centerWindow( listMemberGUI.window[1] )

    if data then
    	if listMemberGUI.label[1] and isElement( listMemberGUI.label[1] ) then
    		destroyElement( listMemberGUI.label[1] )
    		listMemberGUI.label[1] = nil
    	end
	    listMemberGUI.gridlist[1] = guiCreateGridList(9, 26, 536+wExtend, 299, false, listMemberGUI.window[1])
	    listMemberGUI.col.faction_leader = guiGridListAddColumn(listMemberGUI.gridlist[1], "Leader", 0.1)
	    listMemberGUI.col.faction_rank = guiGridListAddColumn(listMemberGUI.gridlist[1], "Rank", 0.33)
	    listMemberGUI.col.charactername = guiGridListAddColumn(listMemberGUI.gridlist[1], "Member", 0.27)
		listMemberGUI.col.username = guiGridListAddColumn(listMemberGUI.gridlist[1], "Account", 0.15)
		listMemberGUI.col.duty = guiGridListAddColumn(listMemberGUI.gridlist[1], "Duty", 0.08)
	    for _, member in ipairs( data ) do
			local row = guiGridListAddRow( listMemberGUI.gridlist[1] )
			guiGridListSetItemText(listMemberGUI.gridlist[1], row, listMemberGUI.col.faction_leader, member.faction_leader == 1 and 'Yes' or 'No', false, false)
			guiGridListSetItemText(listMemberGUI.gridlist[1], row, listMemberGUI.col.faction_rank, member.faction_rank_name or '', false, false)
			guiGridListSetItemText(listMemberGUI.gridlist[1], row, listMemberGUI.col.charactername, member.charactername and string.gsub( member.charactername, '_', ' ') or '', false, false)
			guiGridListSetItemText(listMemberGUI.gridlist[1], row, listMemberGUI.col.username, member.username or '', false, false)
			guiGridListSetItemColor ( listMemberGUI.gridlist[1], row, listMemberGUI.col.charactername, member.online == 1 and 0 or 255, 255, member.online == 1 and 0 or 255 , member.online == 1 and 255 or 200 )
			guiGridListSetItemText(listMemberGUI.gridlist[1], row, listMemberGUI.col.duty, member.duty and "On duty" or "Off duty", false, false)
			guiGridListSetItemColor ( listMemberGUI.gridlist[1], row, listMemberGUI.col.duty, member.duty and 0 or 255, 255, member.duty and 0 or 255, member.duty and 255 or 200 )
			--guiGridListSetItemColor ( listMemberGUI.gridlist[1], row, listMemberGUI.col.charactername, 255, member.faction_leader == 1 and 0 or 255, member.faction_leader == 1 and 0 or 255 , 255 )
		end
		addEventHandler( 'onClientGUIDoubleClick', listMemberGUI.gridlist[1], function ()
			local row, col = guiGridListGetSelectedItem( listMemberGUI.gridlist[1] )
			if row ~= -1 and col ~= -1 then
				local text = guiGridListGetItemText( listMemberGUI.gridlist[1] , row, 2 ) .. ' - ' .. guiGridListGetItemText( listMemberGUI.gridlist[1] , row, 3 ) .. ' (' .. guiGridListGetItemText( listMemberGUI.gridlist[1] , row, 4 ) .. ')'
				if setClipboard( text ) then
					outputChatBox( "Copied '" .. text .. "'.")
					exports.global:playSoundSuccess()
				end
			end
		end)
	    togWindow( listMemberGUI.window[1], true )
	else
		if response then
			if listMemberGUI.gridlist[1] and isElement( listMemberGUI.gridlist[1] ) then
	    		destroyElement( listMemberGUI.gridlist[1] )
	    		listMemberGUI.gridlist[1] = nil
	    	end
			if listMemberGUI.label[1] and isElement( listMemberGUI.label[1] ) then
    			guiSetText( listMemberGUI.label[1], response )
    		end
    		togWindow( listMemberGUI.window[1], true )
    	else
    		if listMemberGUI.gridlist[1] and isElement( listMemberGUI.gridlist[1] ) then
	    		destroyElement( listMemberGUI.gridlist[1] )
	    		listMemberGUI.gridlist[1] = nil
	    	end
	    	listMemberGUI.label[1] = guiCreateLabel ( 0, 0, 1, 1, "Fetching information from server...", true, listMemberGUI.window[1] )
			guiLabelSetHorizontalAlign( listMemberGUI.label[1], 'center' )
			guiLabelSetVerticalAlign( listMemberGUI.label[1], 'center' )
			--outputChatBox( tostring(fact_id))
	    	triggerServerEvent( 'factions:listMember', resourceRoot, fact_id )
			togWindow( listMemberGUI.window[1], false )
			fact_id_tmp = fact_id
    	end
    end

    listMemberGUI.button[1] = guiCreateButton(451+wExtend, 332, 94, 30, "Close", false, listMemberGUI.window[1])
    listMemberGUI.button[2] = guiCreateButton(350+wExtend, 332, 94, 30, "Refresh", false, listMemberGUI.window[1])    
    addEventHandler( 'onClientGUIClick', listMemberGUI.window[1], function()
    	if source == listMemberGUI.button[1] then
    		closeListMember()
    	elseif source == listMemberGUI.button[2] then
    		listMember( fact_id_tmp )
    	end
    end)
end
addEvent( 'factions:listMember', true )
addEventHandler( 'factions:listMember', resourceRoot, listMember )

function closeListMember()
	if listMemberGUI.window[1] and isElement( listMemberGUI.window[1] ) then
		destroyElement( listMemberGUI.window[1] )
		listMemberGUI.window[1] = nil
		togWindow( fGUI.window[1], true )
	end
end

addCommandHandler( 'showfactionplayers', function ( cmd, fact_id )
	if canAccessFactionManager( localPlayer ) then
		if not fact_id or not tonumber(fact_id) or tonumber( fact_id ) < 1 then
			return not outputChatBox( "SYNTAX: /"..cmd.." [Faction ID]" )
		end
		listMember( fact_id )
	end
end, false, false)

--[[
if not (wFactionList) then
		wFactionList = guiCreateWindow(0.25, 0.25, 0.5, 0.5, "Faction List", true)
		fGUI.gridlist[1] = guiCreateGridList(0.025, 0.1, 0.95, 0.775, true, wFactionList)

		local colID = guiGridListAddColumn(fGUI.gridlist[1], "ID", 0.1)
		local colName = guiGridListAddColumn(fGUI.gridlist[1], "Faction Name", 0.6)
		local colPlayers = guiGridListAddColumn(fGUI.gridlist[1], "Players", 0.14)
		local colType = guiGridListAddColumn(fGUI.gridlist[1], "Type", 0.14)

		for key, value in pairs(factions) do
			local factionID = factions[key][1]
			local factionName = tostring(factions[key][2])
			local factionType = tonumber(factions[key][3])
			local factionPlayers = factions[key][4]

			-- Parse the type
			if (factionType==0) then
				factionType = "Gang"
			elseif (factionType==1) then
				factionType = "Mafia"
			elseif (factionType==2) then
				factionType = "Law"
			elseif (factionType==3) then
				factionType = "Government"
			elseif (factionType==4) then
				factionType = "Medical"
			elseif (factionType==5) then
				factionType = "Other"
			elseif (factionType==6) then
				factionType = "News"
			elseif (factionType==7) then  -- Added Mechanic type \ Adams
				factionType = "Mechanic"
			end

			local row = guiGridListAddRow(fGUI.gridlist[1])
			guiGridListSetItemText(fGUI.gridlist[1], row, colID, factionID, false, false)
			guiGridListSetItemText(fGUI.gridlist[1], row, colName, factionName, false, false)
			guiGridListSetItemText(fGUI.gridlist[1], row, colPlayers, factionPlayers, false, false)
			guiGridListSetItemText(fGUI.gridlist[1], row, colType, factionType, false, false)
		end

		addEventHandler( "onClientGUIDoubleClick", fGUI.gridlist[1],
			function( button )
				local row, col = guiGridListGetSelectedItem( source )
				if row ~= -1 and col ~= -1 then
					local gridID = guiGridListGetItemText( source , row, col )

					if button == "left" then
						triggerServerEvent("faction:admin:showplayers", getLocalPlayer(), gridID )
					elseif button == "right" then
						triggerServerEvent("faction:admin:showf3", getLocalPlayer(), gridID, exports.integration:isPlayerAdmin(getLocalPlayer()) )
					end
				else
					outputChatBox( "You need to pick an faction.", 255, 0, 0 )
				end
			end,
			false
		)

		bFactionListClose = guiCreateButton(0.025, 0.9, 0.95, 0.1, "Close", true, wFactionList)
		addEventHandler("onClientGUIClick", bFactionListClose, closeFactionList, false)
	else
		guiSetInputEnabled(false)
		destroyElement(wFactionList)
		wFactionList = nil
	end
end


]]

--triggerServerEvent("faction:admin:showf3", getLocalPlayer(), 1, exports.integration:isPlayerAdmin(getLocalPlayer()) )
