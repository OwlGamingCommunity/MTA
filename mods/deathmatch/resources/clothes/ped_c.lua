--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

list_ = {}
dupont_ped = createPed(12, 594.7294921875, -1255.7529296875, 68.9921875)
setElementInterior(dupont_ped, 3)
setElementDimension(dupont_ped, 546)
--[[
dupont_ped = createPed(12, 589.7587890625, -1238.7373046875, 17.848987579346)
setElementInterior(dupont_ped, 0)
setElementDimension(dupont_ped, 0)
]]
setPedRotation(dupont_ped, 93.519805908203)
setElementData(dupont_ped, 'name', "Melina Dupont", false)
setElementData( dupont_ped, "talk", 1, false )
setPedAnimation ( dupont_ped, "COP_AMBIENT", "Coplook_loop", -1, true, false, false )
setElementFrozen(dupont_ped, true)

local selected_collection, selected_behalf = nil

local GUIEditor = {
    button = {},
    window = {}
}

function openClothesWizard(ped)
	closeClothesWizard()

	default_ped.ped = ped
	default_ped.model = getElementModel ( ped )
	default_ped.rotz = getPedRotation(ped, 'ZYX')
	default_ped.cloth = getElementData(ped, 'clothing:id')

	local y = 0
	local fid = canUploadForFaction(localPlayer)
	if fid then
		y = 36
	end

	GUIEditor.window[1] = guiCreateWindow(1031, 453, 262, 147+y, "Welcome to Dupont Fashion!", false)
	exports.global:centerWindow(GUIEditor.window[1])
	guiWindowSetSizable(GUIEditor.window[1], false)

	GUIEditor.button[1] = guiCreateButton(9, 32, 243, 32, "My personal designs.", false, GUIEditor.window[1])
	if y > 0 then
		GUIEditor.button[4] = guiCreateButton(9, 68, 243, 32, "My faction designs.", false, GUIEditor.window[1])
	end
	GUIEditor.button[2] = guiCreateButton(9, 68+y, 243, 32, "Submit a new design proposal "..(isModerator(localPlayer) and '' or '($25)'), false, GUIEditor.window[1])
	GUIEditor.button[3] = guiCreateButton(9, 104+y, 243, 32, "No, thanks.", false, GUIEditor.window[1])

	addEventHandler('onClientGUIClick', GUIEditor.window[1], function ()
		if source == GUIEditor.button[3] then
			closeClothesWizard()
		elseif source == GUIEditor.button[2] then
			if isModerator(localPlayer) then
				startWizard_1()
			else
				startWizard_1()
			end
		elseif source == GUIEditor.button[1] then
			listMyClothes()
		elseif source == GUIEditor.button[4] then
			listMyClothes(nil, fid)
		end
	end)

	addEventHandler('account:changingchar', root, closeClothesWizard)
	triggerServerEvent('clothes:pedSay', localPlayer, getElementData(dupont_ped, 'name'), 'greet')
end

function closeClothesWizard()
	if GUIEditor.window[1] and isElement(GUIEditor.window[1]) then
		removeEventHandler('account:changingchar', root, closeClothesWizard)
		destroyElement(GUIEditor.window[1])
		GUIEditor.window[1] = nil
		selected_collection = nil
		resetPed()
	end
end

function callback_startWizard_1(ok)
	if ok then

	else
		guiSetText(GUIEditor.button[2], "Submit a new design proposal "..(isModerator(localPlayer) and '' or '($25)'))
		guiSetEnabled(GUIEditor.window[1], true)
		playSoundFrontEnd(4)
	end
end
addEvent('clothes:uploadQuotaCheck', true)
addEventHandler('clothes:uploadQuotaCheck', localPlayer, callback_startWizard_1)

local GUIEditor1 = {
    staticimage = {},
    label = {},
    button = {},
    window = {},
    combobox = {}
}

function startWizard_1()
	if (getElementData(localPlayer, 'hoursplayed') or 0) < 15 then
		playSoundFrontEnd(4)
		outputChatBox("You must have played at least 15 hours on this character or activate '"..exports.donators:getPerks(32)[1].."' perk to submit a new design.", 255,0,0)
	elseif not exports.global:hasMoney(localPlayer, 25) then
		playSoundFrontEnd(4)
		outputChatBox("You need $25 to submit a new design proposal.", 255,0,0)
	else
		closeWizard_1()
		closeClothesWizard()
		closeWindow()
		--playSoundFrontEnd(11)

		GUIEditor1.window[1] = guiCreateWindow(639, 397, 193, 300, "New design proposal", false)
		guiWindowSetSizable(GUIEditor1.window[1], false)
		exports.global:centerWindow(GUIEditor1.window[1])

		GUIEditor1.label[1] = guiCreateLabel(20, 26, 154, 21, "Please choose a collection:", false, GUIEditor1.window[1])

		GUIEditor1.combobox[1] = guiCreateComboBox(20, 47, 154, 21, "", false, GUIEditor1.window[1])
		local count = 0
		for collection=1, 312 do
			if collection ~= 300 then
				local skinImg = ":account/img/" .. ("%03d"):format(tonumber(collection)) .. ".png"
				if fileExists ( skinImg ) then
					guiComboBoxAddItem(GUIEditor1.combobox[1], collection)
					count = count + 1
				end
			end
		end
		exports.global:guiComboBoxAdjustHeight ( GUIEditor1.combobox[1], count )

		GUIEditor1.staticimage[1] = guiCreateStaticImage(20, 78, 155, 151, ":account/img/newchar.png", false, GUIEditor1.window[1])
		GUIEditor1.button[1] = guiCreateButton(15, 250, 74, 32, "Cancel", false, GUIEditor1.window[1])
		GUIEditor1.button[2] = guiCreateButton(101, 250, 74, 32, "Next", false, GUIEditor1.window[1])
		guiSetEnabled(GUIEditor1.button[2], false)

		GUIEditor1.label.skininfo = guiCreateLabel(20,78+151,155,20, '' , false, GUIEditor1.window[1])
		guiLabelSetHorizontalAlign(GUIEditor1.label.skininfo, 'center')

		addEventHandler('onClientGUIClick', GUIEditor1.window[1], clickWizard_1)
		addEventHandler('account:changingchar', root, closeWizard_1)
		addEventHandler('onClientGUIComboBoxAccepted', GUIEditor1.combobox[1], collectionSelect)
	end
end

function closeWizard_1()
	if GUIEditor1.window[1] and isElement(GUIEditor1.window[1]) then
		removeEventHandler('onClientGUIClick', GUIEditor1.window[1], clickWizard_1)
		removeEventHandler('account:changingchar', root, closeWizard_1)
		removeEventHandler('onClientGUIComboBoxAccepted', GUIEditor1.combobox[1], collectionSelect)
		destroyElement(GUIEditor1.window[1])
		GUIEditor1.window[1] = nil
		resetPed()
	end
end

function clickWizard_1()
	if source == GUIEditor1.button[1] then
		closeWizard_1()
	elseif source == GUIEditor1.button[2] then
		local fid = canUploadForFaction(localPlayer)
		if fid then
			startWizard_2_faction(fid)
		else
			startWizard_2()
		end
	end
end

local GUIEditor2 = {
    button = {},
    window = {},
    edit = {},
    label = {},
    radiobutton = {},
}

function startWizard_2_faction(fid)
	closeWizard_2_faction()
	closeWizard_1()
	playSoundFrontEnd(12)
	GUIEditor2.window[1] = guiCreateWindow(709, 366, 323, 135, "New design proposal", false)
	guiWindowSetSizable(GUIEditor2.window[1], false)
	exports.global:centerWindow(GUIEditor2.window[1])

	GUIEditor2.button[1] = guiCreateButton(11, 98, 147, 27, "Back", false, GUIEditor2.window[1])
	GUIEditor2.button[2] = guiCreateButton(165, 98, 147, 27, "Next", false, GUIEditor2.window[1])

	local fname = exports.factions:getFactionName(fid)
	GUIEditor2.label[1] = guiCreateLabel(10, 27, 303, 18, "I am submiting this for benefits on behalf of...", false, GUIEditor2.window[1])
    GUIEditor2.radiobutton[1] = guiCreateRadioButton(27, 48, 286, 15, exports.global:getPlayerName(localPlayer), false, GUIEditor2.window[1])
    GUIEditor2.radiobutton[2] = guiCreateRadioButton(27, 69, 286, 15, exports.factions:getFactionName(fid) , false, GUIEditor2.window[1])
    guiRadioButtonSetSelected(GUIEditor2.radiobutton[1], true)

    addEventHandler('onClientGUIClick', GUIEditor2.window[1], function ()
		if source == GUIEditor2.button[1] then
			closeWizard_2_faction()
			startWizard_1()
		elseif source == GUIEditor2.button[2] then
			selected_behalf = guiRadioButtonGetSelected(GUIEditor2.radiobutton[2]) -- faction
			startWizard_2()
		end
	end)

	addEventHandler('account:changingchar', root, closeWizard_2_faction)
end

function closeWizard_2_faction()
	if GUIEditor2.window[1] and isElement(GUIEditor2.window[1]) then
		destroyElement(GUIEditor2.window[1])
	end
	removeEventHandler('account:changingchar', root, closeWizard_2_faction)
end

function startWizard_2()
	closeWizard_2()
	closeWizard_2_faction()
	closeWizard_1()
	playSoundFrontEnd(12)
	guiSetInputEnabled(true)
	GUIEditor2.window[1] = guiCreateWindow(709, 366, 323, 135, "New design proposal", false)
	guiWindowSetSizable(GUIEditor2.window[1], false)
	exports.global:centerWindow(GUIEditor2.window[1])

	GUIEditor2.button[1] = guiCreateButton(11, 98, 147, 27, "Back", false, GUIEditor2.window[1])
	GUIEditor2.button[2] = guiCreateButton(165, 98, 147, 27, "Upload", false, GUIEditor2.window[1])

	GUIEditor2.label[1] = guiCreateLabel(10, 25, 105, 23, "Image file URL:", false, GUIEditor2.window[1])
	guiLabelSetVerticalAlign(GUIEditor2.label[1], "center")

	GUIEditor2.edit[1] = guiCreateEdit(115, 25, 197, 23, "", false, GUIEditor2.window[1])
	guiEditSetMaxLength(GUIEditor2.edit[1], 200)

	GUIEditor2.label[3] = guiCreateLabel(10, 50, 105, 23, "Clothes description:", false, GUIEditor2.window[1])
	guiLabelSetVerticalAlign(GUIEditor2.label[3], "center")

	GUIEditor2.edit[2] = guiCreateEdit(115, 50, 197, 23, "", false, GUIEditor2.window[1])
	guiEditSetMaxLength(GUIEditor2.edit[2], 100)

	GUIEditor2.label[2] = guiCreateLabel(10, 73, 302, 18, "Example: http://i.imgur.com/MG9pkfl.png; Maximum filesize: 100KB", false, GUIEditor2.window[1])
	guiSetFont(GUIEditor2.label[2], "default-small")
	guiLabelSetColor(GUIEditor2.label[2], 103, 103, 103)
	guiLabelSetHorizontalAlign(GUIEditor2.label[2], "right", false)
	guiLabelSetVerticalAlign(GUIEditor2.label[2], "center")

	addEventHandler('onClientGUIClick', GUIEditor2.window[1], function ()
		if source == GUIEditor2.button[1] then
			closeWizard_2()
			local fid = canUploadForFaction(localPlayer)
			if fid then
				startWizard_2_faction(fid)
			else
				startWizard_1()
			end
		elseif source == GUIEditor2.button[2] then
			local url = guiGetText(GUIEditor2.edit[1])
			local desc = guiGetText(GUIEditor2.edit[2])
			if string.len(url) < 1 then
				guiSetText(GUIEditor2.label[2], 'Please enter a direct image link.')
				playSoundFrontEnd(4)
			elseif string.len(desc) < 1 then
				guiSetText(GUIEditor2.label[2], 'Please describe how this design look like.')
				playSoundFrontEnd(4)
			elseif not exports.global:hasMoney(localPlayer, 25) then
				triggerServerEvent('clothes:pedSay', localPlayer, getElementData(dupont_ped, 'name'), "Could I have $25 please?")
				playSoundFrontEnd(4)
			else
				guiSetText(GUIEditor2.label[2], 'Retrieving image from URL. Please wait..')
				guiSetEnabled(GUIEditor2.window[1], false)
				triggerServerEvent('clothes:wizard2Result', resourceRoot, url, desc, selected_collection, selected_behalf)
				playSoundFrontEnd(12)
			end
		end
	end)

	addEventHandler('account:changingchar', root, closeWizard_2)
end

function closeWizard_2()
	if GUIEditor2.window[1] and isElement(GUIEditor2.window[1]) then
		destroyElement(GUIEditor2.window[1])
		GUIEditor2.window[1] = nil
		resetPed()
		guiSetInputEnabled(false)
	end
	removeEventHandler('account:changingchar', root, closeWizard_2)
end

function wizard2Result(result, for_faction)
	if result == 'ok' then
		playSoundFrontEnd(12)
		listMyClothes(nil, for_faction)
	else
		guiSetText(GUIEditor2.label[2], result)
		guiSetEnabled(GUIEditor2.window[1], true)
		playSoundFrontEnd(4)
	end
end
addEvent('clothes:wizard2Result', true)
addEventHandler('clothes:wizard2Result', resourceRoot, wizard2Result)

function listMyClothes(list, for_faction)
	triggerEvent('npc:togShopWindow', localPlayer, false)
	closeClothesWizard()
	closeWizard_2()
	if window and isElement(window) then
		if list and exports.global:countTable(list) > 0 then
			list_ = list
		end
		guiSetEnabled(window, true)
		guiSetVisible(loading_label, false)
		listCreateGuiElements(true)
	else
		local margin = 30
		window = guiCreateWindow(screen_width - width - 45, screen_height - height-110, width, height, for_faction and (exports.factions:getFactionName(for_faction).."'s collection") or (exports.global:getPlayerName(localPlayer).."'s personal collection"), false)
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
		triggerServerEvent('clothes:list', localPlayer, nil, for_faction)
		setSoundVolume(playSound(":resources/inv_open.mp3"), 0.3)
	end

	--setSoundVolume(playSound(":resources/inv_open.mp3"), 0.3)
end
addEvent('clothes:listMyClothes', true)
addEventHandler('clothes:listMyClothes', root, listMyClothes)

local GUIEditor3 = {
    staticimage = {},
    edit = {},
    button = {},
    window = {},
    label = {},
    combobox = {}
}

function editMyClothes(index)
	close_editMyClothes()
	local clothes = list_[index]
	if clothes then
		toggleGui( window, false )
		guiSetInputEnabled(true)
		GUIEditor3.window[1] = guiCreateWindow(1031, 640, 338, 235, "Editing design #"..index, false)
		guiWindowSetSizable(GUIEditor3.window[1], false)
		guiSetAlpha(GUIEditor3.window[1], 0.95)
		exports.global:centerWindow(GUIEditor3.window[1])

		GUIEditor3.button[1] = guiCreateButton(175, 136, 149, 25, "Save", false, GUIEditor3.window[1])

		GUIEditor3.label[1] = guiCreateLabel(16, 36, 149, 18, "Please choose a collection:", false, GUIEditor3.window[1])
		GUIEditor3.combobox[1] = guiCreateComboBox(16, 54, 149, 25, "", false, GUIEditor3.window[1])
		guiComboBoxAddItem(GUIEditor3.combobox[1], clothes.skin)
		local count = 0
		for collection=1, 312 do
			if collection ~= 300 then
				local skinImg = ":account/img/" .. ("%03d"):format(tonumber(collection)) .. ".png"
				if fileExists ( skinImg ) then
					guiComboBoxAddItem(GUIEditor3.combobox[1], collection)
					count = count + 1
				end
			end
		end
		exports.global:guiComboBoxAdjustHeight ( GUIEditor3.combobox[1], count )
		guiComboBoxSetSelected ( GUIEditor3.combobox[1], 0 )
		guiSetEnabled(GUIEditor3.combobox[1], canEditModel(clothes))

		GUIEditor3.staticimage[1] = guiCreateStaticImage(16, 79, 149, 141, ":account/img/" .. ("%03d"):format(tonumber(clothes.skin)) .. ".png", false, GUIEditor3.window[1])
		GUIEditor3.label.skininfo = guiCreateLabel(16,80,149,20, getSkinBasicInfo(tonumber(clothes.skin)) , false, GUIEditor3.window[1])

		GUIEditor3.label[2] = guiCreateLabel(175, 36, 149, 18, "Price: ($50~$10,000)", false, GUIEditor3.window[1])
		GUIEditor3.edit[1] = guiCreateEdit(175, 54, 149, 25, clothes.price or 50, false, GUIEditor3.window[1])
		guiEditSetMaxLength(GUIEditor3.edit[1], 5)
		guiSetEnabled(GUIEditor3.edit[1], canEditPrice(clothes))

		GUIEditor3.label[3] = guiCreateLabel(175, 83, 149, 18, "Clothes description:", false, GUIEditor3.window[1])
		GUIEditor3.edit[2] = guiCreateEdit(175, 101, 149, 25, clothes.description or "A set of clean clothes", false, GUIEditor3.window[1])
		guiEditSetMaxLength(GUIEditor3.edit[2], 200)

		GUIEditor3.button[2] = guiCreateButton(175, 165, 149, 25, "Delete", false, GUIEditor3.window[1])
		--guiSetEnabled(GUIEditor3.button[2],isDeletable(clothes))

		GUIEditor3.button[3] = guiCreateButton(175, 195, 149, 25, "Cancel", false, GUIEditor3.window[1])


		addEventHandler('account:changingchar', root, close_editMyClothes)
		addEventHandler('onClientGUIComboBoxAccepted', GUIEditor3.combobox[1], collectionSelect)

		addEventHandler('onClientGUIClick', GUIEditor3.window[1], function ()
			-- close
			if source == GUIEditor3.button[3] then
				close_editMyClothes()
			-- save
			elseif source == GUIEditor3.button[1] then
				local citem = guiComboBoxGetSelected ( GUIEditor3.combobox[1] )
				local skin = tonumber( guiComboBoxGetItemText ( GUIEditor3.combobox[1] , citem ))
				local price = guiGetText(GUIEditor3.edit[1])
				price = tonumber(price) and math.ceil(tonumber(price)) or nil
				local desc = guiGetText(GUIEditor3.edit[2])
				if not price or price > 10000 or price < 50 then
					playSoundFrontEnd(4)
					guiSetText(GUIEditor3.window[1], "Error! Price must be ranging from $50 up to $10,000.")
				elseif string.len(desc) < 1 then
					playSoundFrontEnd(4)
					guiSetText(GUIEditor3.window[1], "Error! Description is required.")
				else
					list_[index].price=price
					list_[index].description=desc
					list_[index].skin=skin
					triggerServerEvent('clothing:save', resourceRoot, list_[index], localPlayer)
					close_editMyClothes()
					closeWindow()
				end
			-- delete
			elseif source == GUIEditor3.button[2] then
				if isDeletable( clothes ) then
					deleteMyClothes( index, true )
				else
					-- Checking on server if there's any clothes item for this instance existed anywhere in game.
					triggerServerEvent( 'clothes:deleteMyClothes', resourceRoot, index )
					guiSetText( GUIEditor3.button[2], 'Deleting...' )
					toggleGui( GUIEditor3.window[1], false )
				end
			end
		end)
	end
end

-- delete the file client side.
function deleteClientside(id)
    local path = getPath( id )
    if fileExists( path ) then
        fileDelete( path )
    end
end
addEvent("clothes:deleteFile", true)
addEventHandler("clothes:deleteFile", resourceRoot, deleteClientside)

function deleteMyClothes( index, ok, why )
	if ok then
		-- delete the file client side.
		deleteClientside(index)
		-- delete server side
		triggerServerEvent( 'clothing:delete', resourceRoot, index, "deleteMyClothes" )
		close_editMyClothes()
		closeWindow()
	else
		exports.global:playSoundError()
		exports.hud:sendBottomNotification( localPlayer, "Dupont Fashion", "This clothing design can not be removed. "..why )
		if GUIEditor3.button[2] and isElement( GUIEditor3.button[2] ) then
			guiSetText( GUIEditor3.button[2], "Delete" )
		end
		toggleGui( GUIEditor3.window[1], true )
	end
end
addEvent( 'clothes:deleteMyClothes', true )
addEventHandler( 'clothes:deleteMyClothes', resourceRoot, deleteMyClothes )

function close_editMyClothes()
	if GUIEditor3.window[1] and isElement(GUIEditor3.window[1]) then
		removeEventHandler('account:changingchar', root, close_editMyClothes)
		removeEventHandler('onClientGUIComboBoxAccepted', GUIEditor3.combobox[1], collectionSelect)
		destroyElement(GUIEditor3.window[1])
		GUIEditor3.window[1] = nil
		guiSetInputEnabled(false)
		toggleGui( window, true )
	end
end

function collectionSelect()
	if source == GUIEditor1.combobox[1] then
		local item = guiComboBoxGetSelected ( source )
		selected_collection = tonumber( guiComboBoxGetItemText ( source , item ))
		local skinImg = ":account/img/" .. ("%03d"):format(selected_collection) .. ".png"
		guiStaticImageLoadImage ( GUIEditor1.staticimage[1], skinImg )
		guiSetEnabled(GUIEditor1.button[2], true)
		guiSetText(GUIEditor1.label.skininfo , getSkinBasicInfo(selected_collection))
	elseif source == GUIEditor3.combobox[1] then
		local item = guiComboBoxGetSelected ( source )
		selected_collection = tonumber( guiComboBoxGetItemText ( source , item ))
		local skinImg = ":account/img/" .. ("%03d"):format(selected_collection) .. ".png"
		guiStaticImageLoadImage ( GUIEditor3.staticimage[1], skinImg )
		guiSetText(GUIEditor3.label.skininfo , getSkinBasicInfo(selected_collection))
	end
end

local GUIEditor4 = {
    button = {},
    window = {},
    label = {}
}

function openManu(cid)
	if window and isElement(window) then
		guiSetEnabled(window, false)
	end
	GUIEditor4.window[1] = guiCreateWindow(1002, 246, 500, 400, "Welcome to Dupont Clothing Manufactor!", false)
	guiWindowSetSizable(GUIEditor4.window[1], false)
	exports.global:centerWindow(GUIEditor4.window[1])

	GUIEditor4.button[1] = guiCreateButton(388, 354, 87, 27, "Next", false, GUIEditor4.window[1])
	GUIEditor4.button[2] = guiCreateButton(291, 354, 87, 27, "Close", false, GUIEditor4.window[1])
    GUIEditor4.button[3] = guiCreateButton(20, 354, 250, 27, "Manufacture Instantly ((50 GCs))", false, GUIEditor4.window[1])
    guiSetVisible(GUIEditor4.button[3], false)

	local intro = "Welcome to Dupont Clothing Manufactor!\n\nOur goal is to help you, our clients, to manufacture new or existing clothing lines"
		.." in an ethically responsible way.\n\nWe are able to source all materials you will need to make your clothing, we're able to ship your merchandise worldwide after production "
		.."is completed. We can be your agent and do all this work for you. We save you time and money by taking the hassle out of having to communicate with multiple people, we will be"
		.." your main contact point for everything you need.\n\nWe have a well established network and team of suppliers and manufacturers that we have built strong working relationships"
		.." with which will all be necessary to get your brand off to a strong start. Whether you are an established professional designer or someone with a great idea that you want your"
		.." shot in fashion, the team at Dupont Clothing Manufacturing can help you!"
	local cloth_info = nil
	GUIEditor4.label[1] = guiCreateLabel(26, 34, 443, 302, intro, false, GUIEditor4.window[1])
	guiLabelSetHorizontalAlign(GUIEditor4.label[1], "left", true)
	guiLabelSetVerticalAlign(GUIEditor4.label[1], "center")

	addEventHandler('onClientGUIClick', GUIEditor4.window[1], function ()
		if source == GUIEditor4.button[1] then
			if guiGetText(GUIEditor4.button[1]) == 'Next' then
				local clothing = list_[cid]
				if clothing and not cloth_info then
					cloth_info = 	"Clothes ID: "..clothing.id.."\n"..
									"Collection ((Base skin)): "..clothing.skin.."\n"..
									"Description: "..clothing.description.."\n"..
									"Designer: "..clothing.creator_charname.."\n"..
									"Designed Date: "..(clothing.fdate or exports.datetime:formatTimeInterval(clothing.date)).."\n"..
									"\n\n ((IMPORTANT: Each character can only manufacture 3 clothes designs. Once manuafactured, you will"
									.." -not- be able to edit or remove the manufactured clothes. So please make sure the draft is flawless before manufacturing!))"
				end
				guiSetText(GUIEditor4.label[1], cloth_info or "Errors occurred while fetching design info.")
				guiLabelSetHorizontalAlign(GUIEditor4.label[1], "center", true)
				guiSetText(GUIEditor4.button[2], 'Back')
				guiSetText(GUIEditor4.button[1], 'Manufacture')
                guiSetVisible(GUIEditor4.button[3], true)
			elseif guiGetText(GUIEditor4.button[1]) == 'Manufacture' then
				playSoundFrontEnd(6)
				if triggerServerEvent('clothes:manufacture', resourceRoot, cid) then
					guiSetEnabled(GUIEditor4.window[1], false)
					guiSetEnabled(GUIEditor4.button[1], false)
				end
			end
		elseif source == GUIEditor4.button[2] then
			if guiGetText(GUIEditor4.button[2]) == 'Close' then
				closeManu()
			elseif guiGetText(GUIEditor4.button[2]) == 'Back' then
				guiSetText(GUIEditor4.button[1], 'Next')
				guiSetText(GUIEditor4.button[2], 'Close')
				guiSetText(GUIEditor4.label[1], intro)
				guiLabelSetHorizontalAlign(GUIEditor4.label[1], "left", true)
			end
        elseif source == GUIEditor4.button[3] and guiGetVisible(GUIEditor4.button[3]) then
            playSoundFrontEnd(6)
            if triggerServerEvent('clothes:manufacture', resourceRoot, cid, true) then
                guiSetEnabled(GUIEditor4.window[1], false)
                guiSetEnabled(GUIEditor4.button[1], false)
            end
		end
	end)

	addEventHandler('account:changingchar', root, closeManu)
end

function closeManu()
	if GUIEditor4.window[1] and isElement(GUIEditor4.window[1]) then
		removeEventHandler('account:changingchar', root, closeManu)
		destroyElement(GUIEditor4.window[1])
		GUIEditor4.window[1] = nil
		if window and isElement(window) then
			guiSetEnabled(window, true)
		end
	end
end

function callback_Manu(result, why)
	if GUIEditor4.window[1] and isElement(GUIEditor4.window[1]) then
		guiSetEnabled(GUIEditor4.window[1], true)
		guiSetEnabled(GUIEditor4.button[1], false)
        guiSetEnabled(GUIEditor4.button[3], false)
		guiSetText(GUIEditor4.button[2], 'Close')
		guiSetText(GUIEditor4.label[1], why)
	end
end
addEvent('clothes:callback_Manu', true)
addEventHandler('clothes:callback_Manu', resourceRoot, callback_Manu)

local GUIEditor5 = {
    button = {},
    window = {},
    label = {}
}

function openDist(cid)
	if window and isElement(window) then
		guiSetEnabled(window, false)
	end
	GUIEditor5.window[1] = guiCreateWindow(1002, 246, 500, 400, "Welcome to Dupont Distribution System!", false)
	guiWindowSetSizable(GUIEditor5.window[1], false)
	exports.global:centerWindow(GUIEditor5.window[1])

	GUIEditor5.button[1] = guiCreateButton(388, 354, 87, 27, "Close", false, GUIEditor5.window[1])
	GUIEditor5.button[2] = guiCreateButton(291, 354, 87, 27, "Get Product", false, GUIEditor5.window[1])
	GUIEditor5.button[3] = guiCreateButton(194, 354, 87, 27, "Distribute Globally", false, GUIEditor5.window[1])
	GUIEditor5.button[4] = guiCreateButton(97, 354, 87, 27, "Sell to Dupont", false, GUIEditor5.window[1])

	local intro = "Welcome to Dupont Distribution System!\n\nOur goal is to help you, our clients, to manufacture new or existing clothing lines"
		.." in an ethically responsible way.\n\nWe are able to source all materials you will need to make your clothing, we're able to ship your merchandise worldwide after production "
		.."is completed. We can be your agent and do all this work for you. We save you time and money by taking the hassle out of having to communicate with multiple people, we will be"
		.." your main contact point for everything you need.\n\nWe have a well established network and team of suppliers and manufacturers that we have built strong working relationships"
		.." with which will all be necessary to get your brand off to a strong start. Whether you are an established professional designer or someone with a great idea that you want your"
		.." shot in fashion, the team at Dupont Clothing Manufacturing can help you!"
	local cloth_info = nil
	GUIEditor5.label[1] = guiCreateLabel(26, 34, 443, 302, intro, false, GUIEditor5.window[1])
	guiLabelSetHorizontalAlign(GUIEditor5.label[1], "left", true)
	guiLabelSetVerticalAlign(GUIEditor5.label[1], "center")

	addEventHandler('onClientGUIClick', GUIEditor5.window[1], function ()
		if source == GUIEditor5.button[2] then
			if guiGetText(GUIEditor5.button[2]) == 'Get Product' then
				-- need space for it.
				local clothing = list_[cid]
				if not exports.global:hasSpaceForItem(localPlayer, 16, clothing.skin) then
					guiSetText(GUIEditor5.label[1], "Your invetory is full.")
					guiLabelSetHorizontalAlign(GUIEditor5.label[1], "center", true)
					playSoundFrontEnd(4)
					return
				end
				-- need money even for the first clothes.
				local price = 2^clothing.sold
				if not exports.global:hasMoney(localPlayer, price) then
					guiSetText(GUIEditor5.label[1], "You lack of money to get this product.")
					guiLabelSetHorizontalAlign(GUIEditor5.label[1], "center", true)
					playSoundFrontEnd(4)
					return
				end

				if clothing and not cloth_info then
					cloth_info = 	"Clothes ID: "..clothing.id.."\n"..
									"Collection ((Base skin)): "..clothing.skin.."\n"..
									"Description: "..clothing.description.."\n"..
									"Designer: "..clothing.creator_charname.."\n"..
									"Designed Date: "..(clothing.fdate or exports.datetime:formatTimeInterval(clothing.date)).."\n"..
									"Sold out: "..exports.global:formatMoney( clothing.sold ).."\n"..
									"Price: $"..exports.global:formatMoney( price ).."\n"..
									"\n\nIMPORTANT: This option will generate ONE set of clothes of this design.\n"
									.."The initial price is $1 and you can get unlimited sets of clothes. However, if this design is distribited privately (only accessible by you), everytime this design is sold out, the price will get doubled as you Get Product of your own design."
				end
				guiSetText(GUIEditor5.label[1], cloth_info or "Errors occurred while fetching design info.")
				guiLabelSetHorizontalAlign(GUIEditor5.label[1], "center", true)
				guiSetText(GUIEditor5.button[1], 'Back')
				guiSetText(GUIEditor5.button[2], 'Confirm')
				guiSetVisible(GUIEditor5.button[3], false)
				guiSetVisible(GUIEditor5.button[4], false)
			elseif guiGetText(GUIEditor5.button[2]) == 'Confirm' then
				playSoundFrontEnd(6)
				if triggerServerEvent('clothes:getProduct', resourceRoot, cid) then
					guiSetText(GUIEditor5.label[1], "Validating & Retrieving..")
					guiLabelSetHorizontalAlign(GUIEditor5.label[1], "center", true)
					guiSetEnabled(GUIEditor5.window[1], false)
				end
			elseif guiGetText(GUIEditor5.button[2]) == 'Sell' then
				playSoundFrontEnd(6)
				if triggerServerEvent('clothes:sellProduct', resourceRoot, cid) then
					guiSetText(GUIEditor5.label[1], "Validating & Selling..")
					guiLabelSetHorizontalAlign(GUIEditor5.label[1], "center", true)
					guiSetEnabled(GUIEditor5.window[1], false)
				end
			end
		elseif source == GUIEditor5.button[1] then
			if guiGetText(GUIEditor5.button[1]) == 'Close' then
				closeDist()
			elseif guiGetText(GUIEditor5.button[1]) == 'Back' then
				guiSetText(GUIEditor5.button[1], 'Close')
				guiSetText(GUIEditor5.button[2], 'Get Product')
				guiSetText(GUIEditor5.label[1], intro)
				guiLabelSetHorizontalAlign(GUIEditor5.label[1], "left", true)
				guiSetVisible(GUIEditor5.button[3], true)
				guiSetVisible(GUIEditor5.button[4], true)
			end
		elseif source == GUIEditor5.button[3] then
			playSoundFrontEnd(4)
			outputChatBox("This feature is currently under construction.", 255,0,0)
		elseif source == GUIEditor5.button[4] then
			local clothing = list_[cid]
			if clothing and not cloth_info then
				local price = 200
				cloth_info = 	"Clothes ID: "..clothing.id.."\n"..
								"Collection ((Base skin)): "..clothing.skin.."\n"..
								"Description: "..clothing.description.."\n"..
								"Designer: "..clothing.creator_charname.."\n"..
								"Designed Date: "..(clothing.fdate or exports.datetime:formatTimeInterval(clothing.date)).."\n"..
								"Sold out: "..exports.global:formatMoney( clothing.sold ).."\n"..
								"Pricetag in store: $"..exports.global:formatMoney( clothing.price ).."\n"..
								"\n\nIMPORTANT: After selling your design to Dupont, your clothing design will be distributed publicly & globally in all clothing stores.\n"..
								"This can only make you $"..exports.global:formatMoney( price ).." and you don't receive any profit cut from selling this kind of clothes in clothing stores around the city.\n"..
								"It will still take up a slot permanently in your collection."
			end
			guiSetText(GUIEditor5.label[1], cloth_info or "Errors occurred while fetching design info.")
			guiLabelSetHorizontalAlign(GUIEditor5.label[1], "center", true)
			guiSetText(GUIEditor5.button[1], 'Back')
			guiSetText(GUIEditor5.button[2], 'Sell')
			guiSetVisible(GUIEditor5.button[3], false)
			guiSetVisible(GUIEditor5.button[4], false)
		end
	end)

	addEventHandler('account:changingchar', root, closeDist)
end

function closeDist()
	if GUIEditor5.window[1] and isElement(GUIEditor5.window[1]) then
		removeEventHandler('account:changingchar', root, closeDist)
		destroyElement(GUIEditor5.window[1])
		GUIEditor5.window[1] = nil
		if window and isElement(window) then
			guiSetEnabled(window, true)
		end
	end
end

function callback_Dis(result)
	if GUIEditor5.window[1] and isElement(GUIEditor5.window[1]) then
		guiSetEnabled(GUIEditor5.window[1], true)
		guiSetEnabled(GUIEditor5.button[2], false)
		guiSetText(GUIEditor5.button[1], 'Close')
		guiSetText(GUIEditor5.label[1], result.why)
		guiLabelSetHorizontalAlign(GUIEditor5.label[1], "center", true)
		if result and result.action == 'getProduct' and result.done then
			list_[result.id].sold = result.sold
		elseif result and result.action == 'sellProduct' and result.done then
			list_[result.id].distribution = result.dist
		end
	end
end
addEvent('clothes:callback_Dis', true)
addEventHandler('clothes:callback_Dis', resourceRoot, callback_Dis)

function toggleGui( gui, state )
	if gui and isElement( gui ) then
		return guiSetEnabled( gui, state and true or false )
	end
end

addEventHandler('onClientResourceStop', resourceRoot, function()
	guiSetInputEnabled(false)
end, false)
