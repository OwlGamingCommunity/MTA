--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

window, editing_window, selected_index, selected_skin = nil
default_ped = {}

-- gui to show all clothing items
screen_width, screen_height = guiGetScreenSize()
width, height = 700, math.min(400, math.max(180, math.ceil(screen_height / 4)))
checkbox, grid, editing_item = nil

function resetPed()
	local previewPed = default_ped.ped
	if previewPed and isElement(previewPed) then
		setElementModel(previewPed, default_ped.model)
		setElementData(previewPed, 'clothing:id', default_ped.cloth, false)
		setElementRotation(previewPed, 0, 0, default_ped.rotz)
		setPedAnimation ( previewPed, "COP_AMBIENT", "Coplook_loop", -1, true, false, false )
	end
end

local function closeEditingWindow()
	if editing_window then
		destroyElement(editing_window)
		editing_window = nil
		guiSetInputMode('allow_binds')
		editing_item = nil
	end
end

function closeWindow()
	if window then
		destroyElement(window)
		window = nil
		setSoundVolume(playSound(":resources/inv_close.mp3"), 0.3)
		triggerEvent('npc:togShopWindow', resourceRoot, true)
		removeEventHandler('account:changingchar', root, closeWindow)
	end
	closeEditingWindow()
	resetPed()
end

-- forcibly close the window upon streaming out
addEventHandler('onClientElementStreamOut', resourceRoot, closeWindow)
addEventHandler('onClientResourceStop', resourceRoot, closeWindow)

-- returns the table by [skin] = true
local function getFittingSkins()
	local race, gender = getElementData(localPlayer, 'race'), getElementData(localPlayer, 'gender')
	local temp = exports.npc:getFittingSkins()

	local t = {}
	for k, v in ipairs(temp[gender][race]) do
		t[v] = true
	end
	return t
end

-- called every once in a while when (de-)selecting the 'only show fitting' checkbox
function updateGrid(dopont_npc)
	-- clean up a little beforehand
	guiGridListClear(grid)

	-- insert the default skin
	if not dopont_npc then
		local row = guiGridListAddRow(grid)
		local v = {id=0, description="Original", creator_charname=getGtaDesigners(), creator_char=0, price=50, skin=selected_skin, date="Unknown"}
		guiGridListSetItemText(grid, row, 1, v.id, false, true)
		guiGridListSetItemText(grid, row, 2, v.description.." designed by "..v.creator_charname, false, false)
		guiGridListSetItemText(grid, row, 3, tostring(v.skin), false, true)
		guiGridListSetItemText(grid, row, 4, v.price == 0 and 'N/A' or ('$' .. exports.global:formatMoney(v.price)), false, false)
		guiGridListSetItemText(grid, row, 5, v.date , false, false)
	end

	for index, v in pairs(list_) do
		if dopont_npc or isForSale(v) then
			local row = guiGridListAddRow(grid)
			guiGridListSetItemText(grid, row, 1, v.id, false, true)
			guiGridListSetItemText(grid, row, 2, v.description.." designed by "..v.creator_charname, false, false)
			guiGridListSetItemText(grid, row, 3, tostring(v.skin), false, true)
			guiGridListSetItemText(grid, row, 4, v.price == 0 and 'N/A' or ('$' .. exports.global:formatMoney(v.price)), false, false)
			if dopont_npc then
				guiGridListSetItemText(grid, row, 5, getStatus(v), false, false)
				guiGridListSetItemText(grid, row, 6, formatManuDate(v), false, false)
				guiGridListSetItemText(grid, row, 7, v.fdate or exports.datetime:formatTimeInterval(v.date), false, false)
			else
				guiGridListSetItemText(grid, row, 5, v.fdate or exports.datetime:formatTimeInterval(v.date), false, false)
			end
		end
	end
end


function listClothes(item, list)
	triggerEvent('npc:togShopWindow', source, false)
	if window and isElement(window) then
		if list then
			list_ = list
			outputDebugString("[CLOTHES] Client / listClothes / got list.")
		end
		guiSetEnabled(window, true)
		guiSetVisible(loading_label, false)
		listCreateGuiElements()
	else
		default_ped.ped = source
		default_ped.model = getElementModel ( source )
		default_ped.rotz = getPedRotation(source, 'ZYX')
		default_ped.cloth = getElementData(source, 'clothing:id')
		selected_skin = item.itemValue
		local margin = 30
		window = guiCreateWindow(screen_width - width - 45, screen_height - height-110, width, height, "Colection #"..(item.itemValue or ""), false)
		guiSetEnabled(window, false)
		guiSetAlpha(window, 0.95)
		guiWindowSetSizable(window, false)

		loading_label = guiCreateLabel(10, 25, width - 20, height - 60, "Loading.." ,false, window)
		guiLabelSetHorizontalAlign(loading_label, 'center')
		guiLabelSetVerticalAlign(loading_label, 'center')

		local close = guiCreateButton(width - 110, height - 30, 100, 25, 'Close', false, window)
		addEventHandler('onClientGUIClick', close, closeWindow, false)
		addEventHandler('account:changingchar', root, closeWindow)
		--Now request custom clothes from server
		triggerServerEvent('clothes:list', source, item)
		--setSoundVolume(playSound(":resources/inv_open.mp3"), 0.3)
	end
end
addEvent('clothes:list', true)
addEventHandler('clothes:list', root, listClothes)

function listCreateGuiElements(dopont_npc)
	dopont_npc = dopont_npc and true or false
	if not window or not isElement(window) then return end
	grid = guiCreateGridList(10, 25, width - 20, height - 60, false, window)
	guiGridListAddColumn(grid, 'ID', 0.07)
	guiGridListAddColumn(grid, 'Description', 0.5)
	guiGridListAddColumn(grid, 'Collection', 0.07)
	guiGridListAddColumn(grid, 'Price', 0.1)
	if dopont_npc then
		guiGridListAddColumn(grid, 'Status', 0.3)
		guiGridListAddColumn(grid, 'Manufactured Date', 0.2)
	end
	guiGridListAddColumn(grid, 'Designed Date', 0.2)
	--guiGridListSetSortingEnabled ( grid, false ) -- disable sorting cuz it will cause indexing issue.

	local buy, add, make = nil
	if dopont_npc then
		add = guiCreateButton(width - 220, height - 30, 100, 25, 'Add', false, window)
		make = guiCreateButton(width - 330, height - 30, 100, 25, 'Manufacture', false, window)
		guiSetVisible(make, false)
	else
		buy = guiCreateButton(width - 220, height - 30, 100, 25, 'Buy', false, window)
		guiSetEnabled(buy, false)
	end

	--checkbox = guiCreateCheckBox(width - 380, height - 33, 155, 22, 'Only Skins you can wear', true, false, window)
	--addEventHandler('onClientGUIClick', checkbox, updateGrid, false)

	local scrollbar = guiCreateScrollBar(10, height - 32, 185, 22, true, false, window)
	guiSetProperty(scrollbar, "StepSize", "0.0028")
	addEventHandler('onClientGUIScroll', scrollbar,
		function()
			local rotation = tonumber(guiGetProperty(source, "ScrollPosition"))
			setElementRotation(default_ped.ped, 0, 0, 155 + rotation * 360)
		end, false)
	--[[
	local newedit = nil
	if canEdit(localPlayer) then
		newedit = guiCreateButton(width - 330, height - 30, 100, 25, 'New', false, window)
	end
	]]


	-- fill the skins list
	--list_ = sortList(list_)
	updateGrid(dopont_npc)

	-- event handler for previewing items
	addEventHandler('onClientGUIClick', grid,
		function(button)
			if button == 'left' then
				-- fetch some info
				local discount = exports.npc:getDiscount( localPlayer, 5 )
				local row, column = guiGridListGetSelectedItem(grid)
				selected_index = tonumber(guiGridListGetItemText(grid, row, 1))
				local cl = list_[selected_index]
				if dopont_npc then
					if cl then
						if row == -1 then
							resetPed()
							guiSetText(add, 'Add')
							guiSetVisible(make, false)
						else
							guiSetVisible(make, true)
							if cl.distribution == 1 then -- draft
								guiSetText(make, 'Manufacture')
								guiSetEnabled(make, true)
							else
								guiSetText(make, 'Distribute')
								guiSetEnabled(make, canDistribute(cl))
							end

							guiSetText(add, 'Edit')
							guiSetEnabled(add, cl and true or false)
							
							if cl then
								setElementModel(default_ped.ped, cl.skin)
								setElementData(default_ped.ped, 'clothing:id', cl.id , false)
								selected_skin = cl.skin
								setPedAnimation ( default_ped.ped )
							else
								outputDebugString('Clothing preview broke, aw.')
							end
						end
						-- we selected another row, so tweak that a bit
						closeEditingWindow()
					else
						if row ~= -1 then
							outputChatBox( "Internal Error. Code 249", 255, 0, 0 )
							triggerServerEvent( 'clothes:tempfix', localPlayer )
						end
					end
				else
					-- update the preview ped to reflect actual clothing changes
					if row == -1 then
						resetPed()
						guiSetEnabled(buy, false)
					else
						if row == 0 then -- default skin
							setElementModel(default_ped.ped, selected_skin)
							setElementData(default_ped.ped, 'clothing:id', nil , false)
							guiSetEnabled(buy, exports.global:hasMoney(localPlayer, math.ceil(50*discount)))
							setPedAnimation ( default_ped.ped )
						elseif cl then
							setElementModel(default_ped.ped, cl.skin)
							setElementData(default_ped.ped, 'clothing:id', cl.id , false)
							guiSetEnabled(buy, exports.global:hasMoney(localPlayer, math.ceil(cl.price*discount)))
							selected_skin = cl.skin
							setPedAnimation ( default_ped.ped )
						else
							outputDebugString('Clothing preview broke, aw.')
							guiSetEnabled(buy, false)
						end
					end
					-- we selected another row, so tweak that a bit
					closeEditingWindow()
				end
			end
		end, false)
	
	-- buying things
	if dopont_npc then
		addEventHandler('onClientGUIClick', add,
			function(button)
				if button == 'left' then
					if guiGetText(add) == 'Add' then
						startWizard_1()
					elseif guiGetText(add) == 'Edit' then
						editMyClothes(selected_index)
					end
				end
		end, false)

		addEventHandler('onClientGUIClick', make,
			function(button)
				if button == 'left' then
					if guiGetText(source) == 'Manufacture' then
						openManu(selected_index)
						playSoundFrontEnd(12)
					elseif guiGetText(source) == 'Distribute' then
						openDist(selected_index)
						playSoundFrontEnd(12)
					else
						playSoundFrontEnd(4)
						outputChatBox('This feature is currently under construction.', 255,0 ,0)
					end
				end
		end, false)

	else
		addEventHandler('onClientGUIClick', buy,
			function(button)
				if button == 'left' then
					local row, column = guiGridListGetSelectedItem(grid)
					if row ~= -1 then
						local index = tonumber(guiGridListGetItemText(grid, row, 1))
						local item = list_[index]
						if row == 0 then -- default skin
							triggerServerEvent('clothing:buy', default_ped.ped, -selected_skin)
						elseif item then
							triggerServerEvent('clothing:buy', default_ped.ped, item.id)
						end
					end
				end
		end, false)
	end
end
