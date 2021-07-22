--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

GUIEditor_Window = {}
GUIEditor_TabPanel = {}
GUIEditor_Tab = {}
GUIEditor_Button = {}
GUIEditor_Checkbox = {}
GUIEditor_Label = {}
local screenWidth, screenHeight = guiGetScreenSize()
settings = {}

function showSettingsWindow(tab)
	closeSettingsWindow()

	if wOptions and isElement(wOptions) then
		guiSetEnabled(wOptions, false)
	end

	if getElementData(getLocalPlayer(), "exclusiveGUI") or not isCameraOnPlayer()  then
		return false
	end

	setElementData(getLocalPlayer(), "exclusiveGUI", true, false)

	local w, h = 740,474
	local x, y = (screenWidth-w)/2, (screenHeight-h)/2
	GUIEditor_Window.main = guiCreateWindow(x,y,w,h,"Settings",false)
	guiWindowSetSizable(GUIEditor_Window.main, false)
	GUIEditor_TabPanel.main = guiCreateTabPanel(0.0122,0.0401,0.9757,0.8692,true,GUIEditor_Window.main)


	GUIEditor_Tab.graphicSettings = guiCreateTab("General",GUIEditor_TabPanel.main)
	local lineH = 0.0515
	local posY = lineH

	GUIEditor_Label.graphicSettingsgeneral = guiCreateLabel(0.0222,0.0361,0.313,lineH,"General Configurations:",true,GUIEditor_Tab.graphicSettings)
	guiSetFont(GUIEditor_Label.graphicSettingsgeneral,"default-bold-small")

	GUIEditor_Checkbox.graphic_motionblur = guiCreateCheckBox(0.036,0.1005,0.2992,lineH,"Enable motion blur",false,true,GUIEditor_Tab.graphicSettings)
	if getElementData(localPlayer, "graphic_motionblur") == "0" then
		guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_motionblur,false)
	else
		guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_motionblur,true)
	end

	GUIEditor_Checkbox.graphic_skyclouds = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable sky clouds",false,true,GUIEditor_Tab.graphicSettings)
	if getElementData(localPlayer, "graphic_skyclouds") == "0" then
		guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_skyclouds,false)
	else
		guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_skyclouds,true)
	end

	posY = posY + lineH

	GUIEditor_Checkbox.streams = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable streaming audio",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("carradio") then
		if getElementData(localPlayer, "streams") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.streams,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.streams,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.streams, false)
	end

	posY = posY + lineH

	GUIEditor_Checkbox.graphic_logs = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable client logging of chatbox",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("OwlGamingLogs") then
		if getElementData(localPlayer, "graphic_logs") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_logs,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_logs,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.graphic_logs, false)
	end

	posY = posY + lineH

	GUIEditor_Checkbox.cellphone_log = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable client logging of calls & SMS",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("OwlGamingLogs") and getResourceFromName("phone") then
		if getElementData(localPlayer, "cellphone_log") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.cellphone_log,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.cellphone_log,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.cellphone_log, false)
	end

	posY = posY + lineH

	GUIEditor_Checkbox.graphic_chatbub = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable chat bubbles",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("chat-system") then
		if getElementData(localPlayer, "graphic_chatbub") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_chatbub,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_chatbub,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.graphic_chatbub, false)
	end

	posY = posY + lineH

	GUIEditor_Checkbox.graphic_chatbub_square = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable chat bubble squares",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("chat-system") and guiCheckBoxGetSelected(GUIEditor_Checkbox.graphic_chatbub) then
		if getElementData(localPlayer, "graphic_chatbub_square") ~= "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_chatbub_square,true)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_chatbub_square,false)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.graphic_chatbub_square, false)
	end

	posY = posY + lineH

	GUIEditor_Checkbox.graphic_typingicon = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable typing icons",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("chat-system") then
		if getElementData(localPlayer, "graphic_typingicon") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_typingicon,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_typingicon,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.graphic_typingicon, false)
	end

	posY = posY + lineH

	GUIEditor_Checkbox.graphic_nametags = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable nametags",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("hud") then
		if getElementData(localPlayer, "graphic_nametags") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_nametags,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_nametags,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.graphic_nametags, false)
	end

	posY = posY + lineH

	GUIEditor_Checkbox.settings_hud_style = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable new HUD style",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("hud") then
		if getElementData(localPlayer, "settings_hud_style") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.settings_hud_style,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.settings_hud_style,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.settings_hud_style, false)
	end

	posY = posY + lineH

	GUIEditor_Checkbox.graphic_shaderradar = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable radar shader",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("shader_radar") then
		if getElementData(localPlayer, "graphic_shaderradar") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_shaderradar,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_shaderradar,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.graphic_shaderradar, false)
	end

	posY = posY + lineH

	GUIEditor_Checkbox.graphic_shaderwater = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable water shader",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("shader_water") then
		if getElementData(localPlayer, "graphic_shaderwater") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_shaderwater,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_shaderwater,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.graphic_shaderwater, false)
	end

	posY = posY + lineH

	GUIEditor_Checkbox.graphic_shaderveh = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable vehicle shader",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("shader_car_paint") then
		if getElementData(localPlayer, "graphic_shaderveh") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_shaderveh,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_shaderveh,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.graphic_shaderveh, false)
	end

	posY = posY + lineH

	GUIEditor_Checkbox.vehicle_hotkey = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable vehicle control hotkeys",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName('vehicle') then
		if getElementData(localPlayer, "vehicle_hotkey") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.vehicle_hotkey,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.vehicle_hotkey,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.vehicle_hotkey, false)
	end

	posY = posY + lineH

	GUIEditor_Checkbox.autopark = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Enable vehicle auto /park",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName('vehicle') then
		if getElementData(localPlayer, "autopark") ~= "1" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.autopark,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.autopark,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.autopark, false)
	end

	posY = posY + lineH

	-----------------------------------------------------------------------
	local lineW2 = 0.34
	local posX = lineW2
	posY = 0.1005

	GUIEditor_Checkbox.vehicle_rims = guiCreateCheckBox(0.0222+posX,posY,0.313,lineH,"Enable custom rim models",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("realism") then
		if getElementData(localPlayer, "vehicle_rims") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.vehicle_rims,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.vehicle_rims,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.vehicle_rims, false)
	end

	posY = posY + lineH
	GUIEditor_Checkbox.phone_anim = guiCreateCheckBox(0.0222+posX,posY,0.313,lineH,"Enable phone animation",false,true,GUIEditor_Tab.graphicSettings)
	if getElementData(localPlayer, "phone_anim") == "0" then
		guiCheckBoxSetSelected(GUIEditor_Checkbox.phone_anim,false)
	else
		guiCheckBoxSetSelected(GUIEditor_Checkbox.phone_anim,true)
	end

	posY = posY + lineH
	GUIEditor_Checkbox.talk_anim = guiCreateCheckBox(0.0222+posX,posY,0.313,lineH,"Enable /say animations",false,true,GUIEditor_Tab.graphicSettings)
	if not getElementData(localPlayer, "talk_anim") or getElementData(localPlayer, "talk_anim") == "0" then
		guiCheckBoxSetSelected(GUIEditor_Checkbox.talk_anim,false)
	else
		guiCheckBoxSetSelected(GUIEditor_Checkbox.talk_anim,true)
	end

	posY = posY + lineH
	GUIEditor_Checkbox.pm_username = guiCreateCheckBox(0.0222+posX,posY,0.313,lineH,"Show your /pm username.",false,true,GUIEditor_Tab.graphicSettings)
	if getElementData(localPlayer, "pm_username") == "0" then
		guiCheckBoxSetSelected(GUIEditor_Checkbox.pm_username,false)
	else
		guiCheckBoxSetSelected(GUIEditor_Checkbox.pm_username,true)
	end

	posY = posY + lineH
	GUIEditor_Checkbox.weapon_show_selector = guiCreateCheckBox(0.0222+posX,posY,0.313,lineH,"Show weapon selector while shooting.",false,true,GUIEditor_Tab.graphicSettings)
	if getElementData(localPlayer, "weapon_show_selector") == "0" then
		guiCheckBoxSetSelected(GUIEditor_Checkbox.weapon_show_selector,false)
	else
		guiCheckBoxSetSelected(GUIEditor_Checkbox.weapon_show_selector,true)
	end

	posY = posY + lineH
	GUIEditor_Checkbox.bind_indicators = guiCreateCheckBox(0.0222+posX,posY,0.313,lineH,"Enable rebindable indicators.",false,true,GUIEditor_Tab.graphicSettings)
	if getElementData(localPlayer, "bind_indicators") == "1" then
		guiCheckBoxSetSelected(GUIEditor_Checkbox.bind_indicators,true)
	else
		guiCheckBoxSetSelected(GUIEditor_Checkbox.bind_indicators,false)
	end

	posY = posY + lineH
	local dyn_light = exports.global:isResourceRunning('dynamic_lighting') and true or false
	GUIEditor_Checkbox.dynamic_lighting = guiCreateCheckBox(0.0222+posX,posY,0.313,lineH,"Enable dynamic lighting.",false,true,GUIEditor_Tab.graphicSettings)
	if getElementData(localPlayer, "dynamic_lighting") == "1" then
		guiCheckBoxSetSelected(GUIEditor_Checkbox.dynamic_lighting,true)
	else
		guiCheckBoxSetSelected(GUIEditor_Checkbox.dynamic_lighting,false)
	end
	guiSetEnabled(GUIEditor_Checkbox.dynamic_lighting, dyn_light)

	local groundsnow = exports.global:isResourceRunning('shader_snow_ground') and true or false
	if groundsnow then
		posY = posY + lineH
		GUIEditor_Checkbox.groundsnow = guiCreateCheckBox(0.0222+posX,posY,0.313,lineH,"Enable ground snow.",false,true,GUIEditor_Tab.graphicSettings)
		if getElementData(localPlayer, "groundsnow") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.groundsnow,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.groundsnow,true)
		end
	end

	local snowfall = exports.global:isResourceRunning('snow') and true or false
	if snowfall then
		posY = posY + lineH
		GUIEditor_Checkbox.snowfall = guiCreateCheckBox(0.0222+posX,posY,0.313,lineH,"Enable snowfall.",false,true,GUIEditor_Tab.graphicSettings)
		if getElementData(localPlayer, "snowfall") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.snowfall,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.snowfall,true)
		end
	end

	local xmas = exports.global:isResourceRunning('xmas') and true or false
	if xmas then
		posY = posY + lineH
		GUIEditor_Checkbox.xmastreefx = guiCreateCheckBox(0.0222+posX,posY,0.313,lineH,"Enable christmas tree FX.",false,true,GUIEditor_Tab.graphicSettings)
		if getElementData(localPlayer, "xmastreefx") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.xmastreefx,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.xmastreefx,true)
		end
	end

	posY = posY + lineH
	GUIEditor_Checkbox.punishment_notification_selector = guiCreateCheckBox(0.0222+posX,posY,0.313,lineH,"Hide admin punishment notifications.",false,true,GUIEditor_Tab.graphicSettings)
	if getElementData(localPlayer, "punishment_notification_selector") == "1" then
		guiCheckBoxSetSelected(GUIEditor_Checkbox.punishment_notification_selector,true)
	else
		guiCheckBoxSetSelected(GUIEditor_Checkbox.punishment_notification_selector,false)
	end

	if exports.integration:isPlayerSupporter(getLocalPlayer()) or exports.integration:isPlayerTrialAdmin(getLocalPlayer()) then
		posY = posY + lineH
		GUIEditor_Checkbox.auto_check = guiCreateCheckBox(0.0222+posX,posY,0.313,lineH,"Automatically open /check on /ar",false,true,GUIEditor_Tab.graphicSettings)
		if getElementData(localPlayer, "auto_check") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.auto_check,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.auto_check,true)
		end
	end

	posY = posY + lineH
	GUIEditor_Checkbox.enableNewUIStyle = guiCreateCheckBox(0.0222+posX,posY,0.313,lineH,"Enable new GUI style",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("hud") then
		if getElementData(localPlayer, "enableNewUIStyle") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.enableNewUIStyle,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.enableNewUIStyle,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.enableNewUIStyle, false)
	end

	if exports.integration:isPlayerStaff(localPlayer) then
		posY = posY + lineH
		GUIEditor_Checkbox.enableIncomingReport = guiCreateCheckBox(0.0222+posX,posY,0.313,lineH,"Enable sounds on incoming reports",false,true,GUIEditor_Tab.graphicSettings)
		if getElementData(localPlayer, "incoming_report_sound") ~= "1" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.enableIncomingReport,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.enableIncomingReport,true)
		end

		posY = posY + lineH
		GUIEditor_Checkbox.enableIncomingPriorityReport = guiCreateCheckBox(0.0222+posX,posY,0.313,lineH,"Enable sounds in incoming priority reports",false,true,GUIEditor_Tab.graphicSettings)
		if getElementData(localPlayer, "incoming_priority_report_sound") ~= "1" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.enableIncomingPriorityReport,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.enableIncomingPriorityReport,true)
		end
	end

	posY = posY + lineH
	GUIEditor_Checkbox.misc_sounds = guiCreateCheckBox(0.0222+posX,posY,0.313,lineH,"Disable game default misc sounds",false,true,GUIEditor_Tab.graphicSettings)
	if getElementData(localPlayer, "misc_sounds") == "1" then
		guiCheckBoxSetSelected(GUIEditor_Checkbox.misc_sounds,true)
	else
		guiCheckBoxSetSelected(GUIEditor_Checkbox.misc_sounds,false)
	end

	posY = posY + lineH
	GUIEditor_Checkbox.vehicle_discs = guiCreateCheckBox(0.0222+posX,posY,0.413,lineH,"Hide current vehicle description with ALTGR",false,true,GUIEditor_Tab.graphicSettings)
	if getElementData(localPlayer, "vehicle_description_altgr") == "1" then
		guiCheckBoxSetSelected(GUIEditor_Checkbox.vehicle_discs,true)
	else
		guiCheckBoxSetSelected(GUIEditor_Checkbox.vehicle_discs,false)
	end
	--GUIEditor_Checkbox.noti_settings = guiCreateButton(0.0222+posX,posY,0.313,lineH,"Notification Settings",true,GUIEditor_Tab.graphicSettings)

	-----------------------------------------------------------------------

	posX = posX + lineW2
	GUIEditor_Label.graphicSettings_desc = guiCreateLabel(0.0222+posX,0.0361,0.313,lineH,"Description Overlay Configurations:",true,GUIEditor_Tab.graphicSettings)
	guiSetFont(GUIEditor_Label.graphicSettings_desc,"default-bold-small")

	GUIEditor_Checkbox.enableOverlayDescription = guiCreateCheckBox(0.036+posX,0.1005,0.2992,lineH,"Toggle all overlay description",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("description") then
		if getElementData(localPlayer, "enableOverlayDescription") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.enableOverlayDescription,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.enableOverlayDescription,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.enableOverlayDescription, false)
	end

	GUIEditor_Checkbox.enableOverlayDescriptionVeh = guiCreateCheckBox(0.036+posX,0.1005+lineH,0.2992,lineH,"Vehicle: Enable description",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("description") then
		if getElementData(localPlayer, "enableOverlayDescriptionVeh") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.enableOverlayDescriptionVeh,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.enableOverlayDescriptionVeh,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.enableOverlayDescriptionVeh, false)
	end

	guiCreateLabel ( 0.036+posX,0.1005+lineH*2+0.005,0.2992,lineH ,  "Font:", true, GUIEditor_Tab.graphicSettings )
	cFontVeh = guiCreateComboBox ( 0.036+posX+0.055,0.1005+lineH*2,0.2,lineH,  getElementData(localPlayer, "cFontVeh") or "default", true, GUIEditor_Tab.graphicSettings )
	local count1 = 0
	for key, font in pairs(fonts) do
		guiComboBoxAddItem(cFontVeh, type(font[1]) == "string" and font[1] or "BizNoteFont18")
		count1 = count1 + 1
	end
	guiComboBoxAdjustHeight ( cFontVeh, count1 )
	addEventHandler ( "onClientGUIComboBoxAccepted", guiRoot,
		function ( comboBox )
			if ( comboBox == cFontVeh ) then
				local item = guiComboBoxGetSelected ( cFontVeh )
				local text = tostring ( guiComboBoxGetItemText ( cFontVeh , item ) )
				if ( text ~= "" ) then
					updateAccountSettings("cFontVeh", text)
				end
			end
		end
	)

	GUIEditor_Checkbox.enableOverlayDescriptionPro = guiCreateCheckBox(0.036+posX,0.1005+lineH*3,0.2992,lineH,"Interior: Enable description",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("description") then
		if getElementData(localPlayer, "enableOverlayDescriptionPro") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.enableOverlayDescriptionPro,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.enableOverlayDescriptionPro,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.enableOverlayDescriptionPro, false)
	end

	guiCreateLabel ( 0.036+posX,0.1005+lineH*4+0.005,0.2992,lineH ,  "Font:", true, GUIEditor_Tab.graphicSettings )
	cFontPro = guiCreateComboBox ( 0.036+posX+0.055,0.1005+lineH*4,0.2,lineH,  getElementData(localPlayer, "cFontPro") or "default", true, GUIEditor_Tab.graphicSettings )
	local count1 = 0
	for key, font in pairs(fonts) do
		guiComboBoxAddItem(cFontPro, type(font[1]) == "string" and font[1] or "BizNoteFont18")
		count1 = count1 + 1
	end
	guiComboBoxAdjustHeight ( cFontPro, count1 )
	addEventHandler ( "onClientGUIComboBoxAccepted", guiRoot,
		function ( comboBox )
			if ( comboBox == cFontPro ) then
				local item = guiComboBoxGetSelected ( cFontPro )
				local text = tostring ( guiComboBoxGetItemText ( cFontPro , item ) )
				if ( text ~= "" ) then
					updateAccountSettings("cFontPro", text)
				end
			end
		end
	)

	GUIEditor_Checkbox.enableOverlayDescriptionNote = guiCreateCheckBox(0.036+posX,0.1005+lineH*5,0.2992,lineH,"Notes: Enable description",false,true,GUIEditor_Tab.graphicSettings)
	if getResourceFromName("description") then
		if getElementData(localPlayer, "enableOverlayDescriptionNote") == "0" then
			guiCheckBoxSetSelected(GUIEditor_Checkbox.enableOverlayDescriptionNote,false)
		else
			guiCheckBoxSetSelected(GUIEditor_Checkbox.enableOverlayDescriptionNote,true)
		end
	else
		guiSetEnabled(GUIEditor_Checkbox.enableOverlayDescriptionNote, false)
	end

	GUIEditor_Tab.Notifications = guiCreateTab("Notifications",GUIEditor_TabPanel.main)
	local lineH = 0.0515
	local posY = lineH

	GUIEditor_Label.graphicSettingsgeneral = guiCreateLabel(0.0222,0.0361,0.313,lineH,"Receive notifications about:",true,GUIEditor_Tab.Notifications)
	guiSetFont(GUIEditor_Label.graphicSettingsgeneral,"default-bold-small")

	GUIEditor_Checkbox.noti_faction_updates = guiCreateCheckBox(0.036,0.1005,0.2992,lineH,"Faction updates",false,true,GUIEditor_Tab.Notifications)
	guiCheckBoxSetSelected(GUIEditor_Checkbox.noti_faction_updates,getElementData(localPlayer, "noti_faction_updates") ~= "0")

	GUIEditor_Checkbox.noti_offline_pm = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Incoming offline messages",false,true,GUIEditor_Tab.Notifications)
	guiCheckBoxSetSelected(GUIEditor_Checkbox.noti_offline_pm,getElementData(localPlayer, "noti_offline_pm") ~= "0")

	posY = posY + lineH
	GUIEditor_Checkbox.vehicle_inactivity_scanner = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Vehicle inactivity scanner",false,true,GUIEditor_Tab.Notifications)
	guiCheckBoxSetSelected(GUIEditor_Checkbox.vehicle_inactivity_scanner,getElementData(localPlayer, "vehicle_inactivity_scanner") ~= "0")

	posY = posY + lineH
	GUIEditor_Checkbox.interior_inactivity_scanner = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Interior related",false,true,GUIEditor_Tab.Notifications)
	guiCheckBoxSetSelected(GUIEditor_Checkbox.interior_inactivity_scanner,getElementData(localPlayer, "interior_inactivity_scanner") ~= "0")

	posY = posY + lineH
	GUIEditor_Checkbox.support_center = guiCreateCheckBox(0.036,0.1005+posY,0.2992,lineH,"Support Center",false,true,GUIEditor_Tab.Notifications)
	guiCheckBoxSetSelected(GUIEditor_Checkbox.support_center,getElementData(localPlayer, "support_center") ~= "0")

	local lineW2 = 0.34
	local posX = lineW2
	posY = 0.1005
	GUIEditor_Label.graphicSettingsgeneral = guiCreateLabel(0.0222+posX,0.0361,0.313,lineH,"General Settings:",true,GUIEditor_Tab.Notifications)
	guiSetFont(GUIEditor_Label.graphicSettingsgeneral,"default-bold-small")

	GUIEditor_Checkbox.noti_no_noti = guiCreateCheckBox(0.036+posX,0.1005,1,lineH,"Show button even when there are no notifications",false,true,GUIEditor_Tab.Notifications)
	guiCheckBoxSetSelected(GUIEditor_Checkbox.noti_no_noti,getElementData(localPlayer, "noti_no_noti") == "1")


	GUIEditor_Tab.Social = guiCreateTab("Social",GUIEditor_TabPanel.main)
	local lineH = 0.0515
	local posY = lineH

	GUIEditor_Label.graphicSettingsgeneral = guiCreateLabel(0.0222,0.0361,0.313,lineH,"Friends List:",true,GUIEditor_Tab.Social)
	guiSetFont(GUIEditor_Label.graphicSettingsgeneral,"default-bold-small")

	GUIEditor_Checkbox.social_classic_user_interface = guiCreateCheckBox(0.036,0.1005,0.888,lineH,"Classic User Interface",false,true,GUIEditor_Tab.Social)
	guiCheckBoxSetSelected(GUIEditor_Checkbox.social_classic_user_interface,getElementData(localPlayer, "social_classic_user_interface") == "1")

	GUIEditor_Checkbox.social_invite_only = guiCreateCheckBox(0.036,0.1005+posY,0.888,lineH,"Invite only (Ignore all incoming friend requests)",false,true,GUIEditor_Tab.Social)
	guiCheckBoxSetSelected(GUIEditor_Checkbox.social_invite_only,getElementData(localPlayer, "social_invite_only") == "1")

	posY = posY + lineH
	GUIEditor_Checkbox.social_friends_bypass_pmblock = guiCreateCheckBox(0.036,0.1005+posY,0.888,lineH,"Allow my friends to bypass my PM block",false,true,GUIEditor_Tab.Social)
	guiCheckBoxSetSelected(GUIEditor_Checkbox.social_friends_bypass_pmblock,getElementData(localPlayer, "social_friends_bypass_pmblock") == "1")

	posY = posY + lineH
	GUIEditor_Checkbox.social_friend_updates = guiCreateCheckBox(0.036,0.1005+posY,0.888,lineH,"Receive friends alert and notification",false,true,GUIEditor_Tab.Social)
	guiCheckBoxSetSelected(GUIEditor_Checkbox.social_friend_updates,getElementData(localPlayer, "social_friend_updates") ~= "0")

	posY = posY + lineH
	local indent = 0.02
	GUIEditor_Checkbox.social_friend_updates_on_off = guiCreateCheckBox(0.036+indent,0.1005+posY,0.888,lineH,"Online/offline status",false,true,GUIEditor_Tab.Social)
	guiCheckBoxSetSelected(GUIEditor_Checkbox.social_friend_updates_on_off,getElementData(localPlayer, "social_friend_updates_on_off") ~= "0")

	posY = posY + lineH
	GUIEditor_Checkbox.social_friend_updates_msg = guiCreateCheckBox(0.036+indent,0.1005+posY,0.888,lineH,"Status messages",false,true,GUIEditor_Tab.Social)
	guiCheckBoxSetSelected(GUIEditor_Checkbox.social_friend_updates_msg,getElementData(localPlayer, "social_friend_updates_msg") ~= "0")

	posY = posY + lineH
	GUIEditor_Checkbox.social_friend_updates_char = guiCreateCheckBox(0.036+indent,0.1005+posY,0.888,lineH,"Character changes",false,true,GUIEditor_Tab.Social)
	guiCheckBoxSetSelected(GUIEditor_Checkbox.social_friend_updates_char,getElementData(localPlayer, "social_friend_updates_char") ~= "0")

	posY = posY + lineH
	GUIEditor_Checkbox.social_friend_updates_sound = guiCreateCheckBox(0.036+indent,0.1005+posY,0.888,lineH,"Enable sound effect",false,true,GUIEditor_Tab.Social)
	guiCheckBoxSetSelected(GUIEditor_Checkbox.social_friend_updates_sound,getElementData(localPlayer, "social_friend_updates_sound") ~= "0")

	guiSetEnabled(GUIEditor_Checkbox.social_friend_updates_on_off, guiCheckBoxGetSelected ( GUIEditor_Checkbox.social_friend_updates ))
	guiSetEnabled(GUIEditor_Checkbox.social_friend_updates_msg, guiCheckBoxGetSelected ( GUIEditor_Checkbox.social_friend_updates ))
	guiSetEnabled(GUIEditor_Checkbox.social_friend_updates_char, guiCheckBoxGetSelected ( GUIEditor_Checkbox.social_friend_updates ))
	guiSetEnabled(GUIEditor_Checkbox.social_friend_updates_sound, guiCheckBoxGetSelected ( GUIEditor_Checkbox.social_friend_updates ))

	---Character Settings------------------------------------------------------------------------------------------------------------
	local lineH = 0.0515
	local posY = lineH

	--GUIEditor_Label.charSettingsgeneral = guiCreateLabel(0.0222,0.0361,0.313,lineH,"Character Configurations:",true,GUIEditor_Tab.graphicSettings)
	--guiSetFont(GUIEditor_Label.charSettingsgeneral,"default-bold-small")



	posY = posY + lineH
	--[[
	GUIEditor_Checkbox.graphic_motionblur = guiCreateCheckBox(0.036,0.1005,0.2992,lineH,"Enable vehicle auto /park",false,true,GUIEditor_Tab.graphicSettings)
	if getElementData(localPlayer, "graphic_motionblur") == "0" then
		guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_motionblur,false)
	else
		guiCheckBoxSetSelected(GUIEditor_Checkbox.graphic_motionblur,true)
	end]]



	GUIEditor_Button.mainclose = guiCreateButton(0.0135,0.9135,0.9743,0.0675,"Close",true,GUIEditor_Window.main)
	addEventHandler("onClientGUIClick", GUIEditor_Window.main, options_updateGameSettings)
	--addEventHandler("onClientGUITabSwitched", GUIEditor_TabPanel.main, updateTabs)
	if tab and GUIEditor_Tab[tab] then
		guiSetSelectedTab ( GUIEditor_TabPanel.main, GUIEditor_Tab[tab] )
	end
end
addEvent("accounts:settings:fetchSettings", true)
addEventHandler("accounts:settings:fetchSettings", localPlayer, showSettingsWindow)

function updateTabs(selectedTab )
	--FETCH DATA
	if settings then
		for i, setting in pairs(settings) do

			if isElement(GUIEditor_Checkbox[setting[2]]) then
				guiCheckBoxSetSelected(GUIEditor_Checkbox[setting[2]],(setting[3] == "1"))
				--outputDebugString(setting[2].."-"..setting[3])
			end
		end
	else

	end
end

function closeSettingsWindow()
	if isElement(GUIEditor_Window.main) then
		removeEventHandler("onClientGUIClick", GUIEditor_Window.main, options_updateGameSettings)
		removeEventHandler("onClientGUITabSwitched", GUIEditor_TabPanel.main, updateTabs)
		destroyElement(GUIEditor_Window.main)
		GUIEditor_Window.main = nil
	end

	if wOptions and isElement(wOptions) then
		guiSetEnabled(wOptions, true)
	end
	setElementData(getLocalPlayer(), "exclusiveGUI", false, false)
	exports.OwlGamingLogs:closeInfoBox()
end

function options_updateGameSettings()
	if source == GUIEditor_Button.mainclose then
		closeSettingsWindow()
	elseif source == GUIEditor_Checkbox.graphic_motionblur then
		local name, value = "graphic_motionblur", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.graphic_motionblur ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.graphic_skyclouds then
		local name, value = "graphic_skyclouds", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.graphic_skyclouds ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.streams then
		local name, value = "streams", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.streams ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.graphic_nametags then
		local name, value = "graphic_nametags", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.graphic_nametags ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.settings_hud_style then
		local name, value = "settings_hud_style", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.settings_hud_style ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.graphic_logs then
		local name, value = "graphic_logs", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.graphic_logs ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.graphic_chatbub then
		local name, value = "graphic_chatbub", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.graphic_chatbub ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.graphic_typingicon then
		local name, value = "graphic_typingicon", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.graphic_typingicon ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.graphic_shaderradar then
		local name, value = "graphic_shaderradar", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.graphic_shaderradar ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.graphic_shaderwater then
		local name, value = "graphic_shaderwater", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.graphic_shaderwater ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.graphic_shaderveh then
		local name, value = "graphic_shaderveh", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.graphic_shaderveh ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.graphic_shaderveh_reflect then
		local name, value = "graphic_shaderveh_reflect", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.graphic_shaderveh_reflect ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.graphic_shader_darker_night then
		local name, value = "graphic_shader_darker_night", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.graphic_shader_darker_night ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.enableOverlayDescription then
		local name, value = "enableOverlayDescription", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.enableOverlayDescription ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.enableOverlayDescriptionVeh then
		local name, value = "enableOverlayDescriptionVeh", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.enableOverlayDescriptionVeh ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.enableOverlayDescriptionPro then
		local name, value = "enableOverlayDescriptionPro", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.enableOverlayDescriptionPro ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.enableOverlayDescriptionNote then
		local name, value = "enableOverlayDescriptionNote", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.enableOverlayDescriptionNote ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.autopark then
		local name, value = "autopark", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.autopark ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.graphic_chatbub_square then
		local name, value = "graphic_chatbub_square", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.graphic_chatbub_square ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.vehicle_hotkey then
		local name, value = "vehicle_hotkey", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.vehicle_hotkey ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.vehicle_rims then
		local name, value = "vehicle_rims", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.vehicle_rims ) then
			value = "1"
		end
		updateAccountSettings(name, value)
		triggerEvent("vehicle_rims", getRootElement(), value)
	elseif source == GUIEditor_Checkbox.phone_anim then
		local name, value = "phone_anim", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.phone_anim ) then
			value = "1"
		end
		updateCharacterSettings(name, value)
	elseif source == GUIEditor_Checkbox.cellphone_log then
		local name, value = "cellphone_log", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.cellphone_log ) then
			value = "1"
			exports.OwlGamingLogs:drawInfoBox()
		end
	elseif source == GUIEditor_Checkbox.talk_anim then
		local name, value = "talk_anim", "0"
		if guiCheckBoxGetSelected( GUIEditor_Checkbox.talk_anim ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.pm_username then
		local name, value = "pm_username", "0"
		if guiCheckBoxGetSelected( GUIEditor_Checkbox.pm_username ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.weapon_show_selector then
		local name, value = "weapon_show_selector", "0"
		if guiCheckBoxGetSelected( GUIEditor_Checkbox.weapon_show_selector ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.noti_faction_updates then
		local name, value = "noti_faction_updates", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.noti_faction_updates ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.noti_offline_pm then
		local name, value = "noti_offline_pm", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.noti_offline_pm ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.vehicle_inactivity_scanner then
		local name, value = "vehicle_inactivity_scanner", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.vehicle_inactivity_scanner ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.interior_inactivity_scanner then
		local name, value = "interior_inactivity_scanner", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.interior_inactivity_scanner ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.support_center then
		local name, value = "support_center", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.support_center ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.noti_no_noti then
		local name, value = "noti_no_noti", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.noti_no_noti ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.social_classic_user_interface then
		local name, value = "social_classic_user_interface", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.social_classic_user_interface ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.social_invite_only then
		local name, value = "social_invite_only", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.social_invite_only ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.social_friends_bypass_pmblock then
		local name, value = "social_friends_bypass_pmblock", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.social_friends_bypass_pmblock ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.social_friend_updates then
		local name, value = "social_friend_updates", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.social_friend_updates ) then
			value = "1"
		end
		updateAccountSettings(name, value)
		guiSetEnabled(GUIEditor_Checkbox.social_friend_updates_on_off, guiCheckBoxGetSelected ( GUIEditor_Checkbox.social_friend_updates ))
		guiSetEnabled(GUIEditor_Checkbox.social_friend_updates_msg, guiCheckBoxGetSelected ( GUIEditor_Checkbox.social_friend_updates ))
		guiSetEnabled(GUIEditor_Checkbox.social_friend_updates_char, guiCheckBoxGetSelected ( GUIEditor_Checkbox.social_friend_updates ))
		guiSetEnabled(GUIEditor_Checkbox.social_friend_updates_sound, guiCheckBoxGetSelected ( GUIEditor_Checkbox.social_friend_updates ))
	elseif source == GUIEditor_Checkbox.social_friend_updates_on_off then
		local name, value = "social_friend_updates_on_off", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.social_friend_updates_on_off ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.social_friend_updates_msg then
		local name, value = "social_friend_updates_msg", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.social_friend_updates_msg ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.social_friend_updates_char then
		local name, value = "social_friend_updates_char", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.social_friend_updates_char ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.social_friend_updates_sound then
		local name, value = "social_friend_updates_sound", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.social_friend_updates_sound ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.bind_indicators then
		local name, value = "bind_indicators", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.bind_indicators ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.dynamic_lighting then
		local name, value = "dynamic_lighting", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.dynamic_lighting ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.groundsnow then
		local name, value = "groundsnow", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.groundsnow ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.snowfall then
		local name, value = "snowfall", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.snowfall ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.xmastreefx then
		local name, value = "xmastreefx", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.xmastreefx ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.auto_check then
		local name, value = "auto_check", "0"
		if guiCheckBoxGetSelected ( GUIEditor_Checkbox.auto_check ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.punishment_notification_selector then
		local name, value = "punishment_notification_selector", "0"
		if guiCheckBoxGetSelected( GUIEditor_Checkbox.punishment_notification_selector ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.enableNewUIStyle then
		local name, value = "enableNewUIStyle", "0"
		if guiCheckBoxGetSelected( GUIEditor_Checkbox.enableNewUIStyle ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.enableIncomingReport then
		local name, value = "incoming_report_sound", "0"
		if guiCheckBoxGetSelected( GUIEditor_Checkbox.enableIncomingReport ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.enableIncomingPriorityReport then
		local name, value = "incoming_priority_report_sound", "0"
		if guiCheckBoxGetSelected( GUIEditor_Checkbox.enableIncomingReport ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.misc_sounds then
		local name, value = "misc_sounds", "0"
		if guiCheckBoxGetSelected( GUIEditor_Checkbox.misc_sounds ) then
			value = "1"
		end
		updateAccountSettings(name, value)
	elseif source == GUIEditor_Checkbox.vehicle_discs then 
		local name, value = "vehicle_description_altgr", "0"
		if guiCheckBoxGetSelected(GUIEditor_Checkbox.vehicle_discs) then
			value = "1"
		end
		updateAccountSettings(name, value)
	end
end

function applyGameSettings(name, value)
	if name and value then
		if name == "duty_admin" or name == "duty_supporter" or name == "wrn:style" then
			value = tonumber(value) or value
		end
		setElementData(localPlayer, name, value)
		--outputDebugString("applyAccountSettings".." "..name.." "..value)
		if name == "graphic_motionblur" then
			if (value == "0") then
				setBlurLevel(0)
			else
				setBlurLevel(40)
			end
			--setElementData(localPlayer, name, value, false)
		elseif name == "graphic_skyclouds" then
			if (value == "0") then
				setCloudsEnabled ( false )
			else
				setCloudsEnabled ( true )
			end
			--setElementData(localPlayer, name, value, false)
		elseif name == "streams" then
			--setElementData(localPlayer, name, value, false)
			triggerEvent("accounts:settings:updateCarRadio", localPlayer)
		--[[elseif name == "graphic_chatbub" then
			setElementData(localPlayer, name, value, false)
			triggerEvent("accounts:settings:updateChatBubbleState", localPlayer)]]
		elseif name == "graphic_typingicon" then
			--setElementData(localPlayer, name, value, false)
			triggerEvent("accounts:settings:graphic_typingicon", localPlayer)
		elseif name == "graphic_shaderradar" then
			--setElementData(localPlayer, name, value, false)
			--triggerEvent("accounts:settings:graphic_shaderradar", localPlayer)
		elseif name == "graphic_shaderwater" then
			--setElementData(localPlayer, name, value, false)
			triggerEvent("accounts:settings:graphic_shaderwater", localPlayer)
		elseif name == "graphic_shaderveh" then
			--setElementData(localPlayer, name, value, false)
			triggerEvent("accounts:settings:graphic_shaderveh", localPlayer)
		elseif name == "hide_hud" then
			if value == "0" then
				setPlayerHudComponentVisible("radar", false)
			elseif exports.global:hasItem(localPlayer, 111) then
				setPlayerHudComponentVisible("radar", true)
			end
		elseif name == "groundsnow" then
			local groundsnow = exports.global:isResourceRunning('shader_snow_ground') and true or false
			if groundsnow then
				if value == "0" then
					triggerEvent("switchGoundSnow", resourceRoot, false)
				elseif( value == "1") then
					triggerEvent("switchGoundSnow", resourceRoot, true)
				end
			end
		elseif name == "xmastreefx" then
			local xmas = exports.global:isResourceRunning('xmas') and true or false
			if xmas then
				if value == "0" then
					triggerEvent("xmas:updateTreeFX", root, true, false)
				elseif( value == "1") then
					triggerEvent("xmas:updateTreeFX", root, true, true)
				end
			end
		elseif name == "misc_sounds" then
			if (value == "0") then 
				resetWorldSounds()
			else
				setWorldSoundEnabled ( 19, -1, false, true )
				setWorldSoundEnabled ( 4, -1, false, true ) 
				setWorldSoundEnabled ( 0, 0, false, true )
				setWorldSoundEnabled ( 0, 29, false, true )
				setWorldSoundEnabled ( 0, 30, false, true )
				setWorldSoundEnabled ( 2, 3, false, true )
			end
		elseif name == "enableNewUIStyle" then
			triggerEvent("hud:guiReset", localPlayer, nil, value)
		elseif name == "vehicle_description_altgr" then 
			triggerEvent("description:updateOwnView", localPlayer, value)
		end
	end
end
addEvent("accounts:settings:applyGameSettings", true)
addEventHandler("accounts:settings:applyGameSettings", localPlayer, applyGameSettings)

function updateAccountSettings(name, value)
	applyGameSettings(name, value)
	triggerServerEvent("saveClientAccountSettingsOnServer", localPlayer, name, value)
end
addEvent("accounts:settings:updateAccountSettings", true)
addEventHandler("accounts:settings:updateAccountSettings", localPlayer, updateAccountSettings)

function applyCharacterSettings(name, value)
	if name and value then
		setElementData(localPlayer, name, value)
		--outputDebugString("applyCharacterSettings".." "..name.." "..value)
		if name == "head_turning" then
			triggerEvent("realism:updateLookAt", localPlayer)
		end
	end
end
addEvent("accounts:settings:applyCharacterSettings", true)
addEventHandler("accounts:settings:applyCharacterSettings", localPlayer, applyCharacterSettings)

function updateCharacterSettings(name, value)
	applyCharacterSettings(name, value)
	triggerServerEvent("saveClientCharacterSettingsOnServer", localPlayer, name, value)
end
addEvent("accounts:settings:updateCharacterSettings", true)
addEventHandler("accounts:settings:updateCharacterSettings", localPlayer, updateCharacterSettings)

function loadAccountSettings(settingsFromServer)
	if settingsFromServer then
		for i = 1, #settingsFromServer do
			if settingsFromServer[i][1] and settingsFromServer[i][2] then
				applyGameSettings(settingsFromServer[i][1], settingsFromServer[i][2])
			end
		end
	end
end
addEvent("accounts:settings:loadAccountSettings", true)
addEventHandler("accounts:settings:loadAccountSettings", localPlayer, loadAccountSettings)


function loadCharacterSettings(settingsFromServer)
	if settingsFromServer then
		for i = 1, #settingsFromServer do
			if settingsFromServer[i][1] and settingsFromServer[i][2] then
				applyCharacterSettings(settingsFromServer[i][1], settingsFromServer[i][2])
			end
		end
	end
end
addEvent("accounts:settings:loadCharacterSettings", true)
addEventHandler("accounts:settings:loadCharacterSettings", localPlayer, loadCharacterSettings)

function cleanUp()
	setElementData(localPlayer, "exclusiveGUI", false, false)
end
addEventHandler("onClientResourceStart", resourceRoot, cleanUp)

addCommandHandler("togglechatbubbles", function ()
	updateAccountSettings('graphic_chatbub', getElementData(localPlayer, "graphic_chatbub") == "0" and "1" or "0")
end)

addCommandHandler("togglehud", function ()
	updateAccountSettings('hide_hud', getElementData(localPlayer, "hide_hud") == "0" and "1" or "0")
end)
