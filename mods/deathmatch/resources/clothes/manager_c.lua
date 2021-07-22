--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local mGui = {}

function clothesManager(item, list)
 	triggerEvent('npc:togShopWindow', source, false)
 	if mGui.window and isElement(mGui.window) then
 		if list then
 			list_ = list
 			outputDebugString("[CLOTHES] Client / listClothes / got list.")
 		end
 		guiSetEnabled(mGui.window, true)
 		guiSetVisible(loading_label, false)
 		listCreateGuiElements()
 	else
 		default_ped.ped = source
 		default_ped.model = getElementModel ( source )
 		default_ped.rotz = getPedRotation(source, 'ZYX')
 		default_ped.cloth = getElementData(source, 'clothing:id')
 		selected_skin = 0--item.itemValue
 		local margin = 30
 		mGui.window = guiCreateWindow(screen_width - width - 45, screen_height - height-110, width, height, "Colection ", false)
 		guiSetEnabled(mGui.window, false)
 		guiSetAlpha(mGui.window, 0.95)
 		guiSetSizable(mGui.window, false)

 		loading_label = guiCreateLabel(10, 25, width - 20, height - 60, "Loading.." ,false, mGui.window)
 		guiLabelSetHorizontalAlign(loading_label, 'center')
 		guiLabelSetVerticalAlign(loading_label, 'center')

 		local close = guiCreateButton(width - 110, height - 30, 100, 25, 'Close', false, mGui.window)
 		addEventHandler('onClientGUIClick', mGui.window, function ()
 			if source == close then
 				closeManager()
 			else
 				--
 			end
 		end)
 		addEventHandler('account:changingchar', root, closeManager)
	--Now request custom clothes from server
	--triggerServerEvent('clothes:list', source, item)
	--setSoundVolume(playSound(":resources/inv_open.mp3"), 0.3)
	end
end
addEvent('clothes:clothesManager', true)
addEventHandler('clothes:clothesManager', root, clothesManager)

function closeManager()
	if mGui.window and isElement(mGui.window) then
		destroyElement(mGui.window)
		mGui.window = nil
		removeEventHandler('account:changingchar', root, closeManager)
	end
end