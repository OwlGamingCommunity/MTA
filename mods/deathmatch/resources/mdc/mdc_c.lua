--[[
--	Copyright (C) Root Gaming - All Rights Reserved
--	Unauthorized copying of this file, via any medium is strictly prohibited
--	Proprietary and confidential
--	Written by Daniel Lett <me@lettuceboi.org>, December 2012
]]--

local SCREEN_X, SCREEN_Y = guiGetScreenSize( )
local PD_VEHICLES = { 427, 490, 528, 523, 598, 596, 597, 599, 601 }
PD_ID = 1
FAA_ID = 47
GOV_ID = 3
SASD_ID = 59
RT_ID = 4
local FAA_VEHICLES = { 596, 490, 426 }
local FAA_INTERIORS = {}
local resourceName = getResourceName( getThisResource( ) )
local filePath = ":"..resourceName.."/account.xml"
localPlayer = localPlayer
local window = {}
local login = {}
------------------------------------------
function hasMDCPermissions( )
	if isPedInVehicle( localPlayer ) then
		local vehicle = getPedOccupiedVehicle( localPlayer )
		local vehicleFaction = tonumber(getElementData(vehicle, "faction"))
		if vehicleFaction then
			if getResourceFromName('factions') ~= false then
				return exports.factions:isPlayerInFaction( localPlayer, vehicleFaction )
			else
				return false
			end
		elseif (vehicleFaction == GOV_ID) then
			return true
		elseif(vehicleFaction == FAA_ID) then
			for k,v in ipairs(FAA_VEHICLES) do
				if(getElementModel(vehicle) == v) then
					return true
				end
			end
		elseif(vehicle == 596 or vehicle == 427 or vehicle == 490 or vehicle == 599 or vehicle == 601 or vehicle == 523 or vehicle == 597 or vehicle == 598 or exports.global:hasItem(vehicle, 143)) then
			return true
		else
			return false
		end
	else
		return false
	end
end

--[[function saveAccountData( username, password )
	local file = xmlLoadFile( filePath )
	if not file then
		file = xmlCreateFile( filePath, "account" )
	end
	xmlNodeSetValue ( xmlFindChild( file, "username", 0 ) or xmlCreateChild ( file, "username"), username )
	xmlNodeSetValue ( xmlFindChild( file, "password", 0 ) or xmlCreateChild ( file, "password"), password )

	xmlSaveFile( file )
	xmlUnloadFile( file )
end

function getAccountData( )
	local file = xmlLoadFile( filePath )
	if not file then
		return { username = "Username", password = "Password" }
	end
	local username = xmlNodeGetValue( xmlFindChild( file, "username", 0 ) ) or "Username"
	local password = xmlNodeGetValue( xmlFindChild( file, "password", 0 ) ) or "Password"

	xmlSaveFile( file )
	xmlUnloadFile( file )

	return { username = username, password = password }
end]]

------------------------------------------

function openLogin (fromComputer)
	if fromComputer or hasMDCPermissions() then
		if login and login.window and isElement(login.window) then
			closeLoginWindow()
		else
			triggerServerEvent( "mdc:login", localPlayer, getElementData(localPlayer, "dbid") )
		end
	else
		outputChatBox( "You are not near a mobile data computer.", 255, 155, 155 )
	end
end
addEvent("mdc:loginW")
addEventHandler("mdc:loginW", localPlayer, openLogin)

--[[function closeLoginWindow()
	if login and login.window and isElement(login.window) then
		destroyElement(login.window)
		login.window = nil
		showCursor( false, false )
		guiSetInputEnabled ( false )
		login = { }
	end
end]]

------------------------------------------
--addCommandHandler( "mdc", openLogin, false, false ) / Removed it so ppl can only access mdc from vehicles which MDC or with computer only, not everywhere. / Maxime


function mdc_errorWin ( text )
	if window then
		if window.dialog then
			if window.dialog.window then
				destroyElement(window.dialog.window)
				window.dialog = { }
			end
		end
	else
		window = {}
	end
	window.dialog = { }
	local width = 250
	local height = 110
	local x = SCREEN_X / 2 - width / 2
	local y = SCREEN_Y / 2 - height / 2
	window.dialog.window = guiCreateWindow( x, y, width, height, "MDC Error", false )

	window.dialog.errorLabel = guiCreateLabel( 10, 30, width - 20, 20, tostring(text), false, window.dialog.window )

	window.dialog.closeButton = guiCreateButton( 10, 60, width - 20, 40, "Close", false, window.dialog.window )
	addEventHandler( "onClientGUIClick", window.dialog.closeButton,
		function ()
			guiSetVisible( window.dialog.window, false )
			destroyElement( window.dialog.window )
			window.dialog = { }
		end
	, false )
end

function mdc_confirmWin ( text )
	if window then
		if window.confirmWin then
			if window.confirmWin.window then
				if isElement(window.confirmWin.window) then
					destroyElement(window.confirmWin.window)
				end
			end
			window.confirmWin = { }
		end
	else
		window = {}
	end
	window.confirmWin = { }
	local width = 250
	local height = 130
	local x = SCREEN_X / 2 - width / 2
	local y = SCREEN_Y / 2 - height / 2
	window.confirmWin.window = guiCreateWindow( x, y, width, height, "MDC Confirm", false )

	window.confirmWin.label = guiCreateLabel( 10, 30, width - 20, 40, tostring(text), false, window.confirmWin.window )
	guiLabelSetHorizontalAlign(window.confirmWin.label, "center", true)

	window.confirmWin.bYes = guiCreateButton( 10, 80, 110, 40, "Yes", false, window.confirmWin.window )
	window.confirmWin.bNo = guiCreateButton( 130, 80, 110, 40, "No", false, window.confirmWin.window )

	return window.confirmWin.window, window.confirmWin.bYes, window.confirmWin.bNo, window.confirmWin.label
end

function mdc_confirmWin_destroy()
	if window then
		if window.confirmWin then
			if window.confirmWin.window then
				if isElement(window.confirmWin.window) then
					destroyElement(window.confirmWin.window)
				end
			end
			window.confirmWin = {}
		end
	end
end
