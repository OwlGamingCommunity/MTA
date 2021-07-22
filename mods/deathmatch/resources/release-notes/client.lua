
--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

local cache = 1000*60*5 -- 5 mins
local last = getTickCount()
local releases = nil

local GUIEditor = {
    button = {},
    window = {},
    label = {},
    memo = {}
}

function showReleases(releases1)
	if GUIEditor.window[1] and isElement(GUIEditor.window[1]) then
		if releases1 then
			releases = releases1
			guiSetText(GUIEditor.memo[1], releases)
		end
	else 
		GUIEditor.window[1] = guiCreateWindow(567, 297, 604, 298, "Live Release Notes ♦ Current Script Version "..exports.global:getScriptVersion(), false)
		guiWindowSetSizable(GUIEditor.window[1], false)
		exports.global:centerWindow(GUIEditor.window[1])
		GUIEditor.memo[1] = guiCreateMemo(9, 22, 585, 237, releases or "Retrieving information from server..", false, GUIEditor.window[1])
		guiMemoSetReadOnly(GUIEditor.memo[1], true)
		GUIEditor.label[1] = guiCreateLabel(9, 264, 468, 23, "♦ If you discover a bug/glitch while playing, please report it on http://bugs.owlgaming.net\n♦ Your feedback goes a long way towards making OwlGaming even better!" , false, GUIEditor.window[1])
		guiSetFont(GUIEditor.label[1], "default-small")
		guiLabelSetVerticalAlign(GUIEditor.label[1], "center")
		GUIEditor.button[1] = guiCreateButton(477, 264, 117, 23, "Close", false, GUIEditor.window[1])
		guiSetFont(GUIEditor.button[1], "default-bold-small")
		addEventHandler('onClientGUIClick', GUIEditor.button[1], function()
			if source == GUIEditor.button[1] then
				closeRelease()
			end
		end)
		if not releases or getTickCount() - last > cache then
			triggerServerEvent('debug:releases', source)
			last = getTickCount()
		end
	end
end
addEvent('debug:releases', true)
addEventHandler('debug:releases', root, showReleases)

function closeRelease()
	if GUIEditor.window[1] and isElement(GUIEditor.window[1]) then
		destroyElement(GUIEditor.window[1])
		GUIEditor.window[1] = nil
	end
end