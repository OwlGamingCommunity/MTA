------------------------------------------
-- 		 	  	 GUIRuncode	 		 	--
------------------------------------------
-- Developer: Braydon Davis	(xXMADEXx)	--
-- File: run_client.lua					--
-- Copyright 2013 (C) RoS				--
-- All rights reserved.					--

-- Modified by anumaz, for owlgaming    --
------------------------------------------
sec = {{{{{{},{},{},{}}}}}}				--
------------------------------------------

local sx, sy = guiGetScreenSize ( )
window = guiCreateWindow( ( sx / 2 - 854 / 2 ), ( sy / 2 - 545 / 2 ), 854, 545, "GUI Runcode by RoS", false)
guiWindowSetSizable(window, false)
guiSetVisible ( window, false )
playerCode = guiCreateMemo(12, 47, 831, 396, "outputChatBox ( \"This is your code!!\" )", false, window)
exitPanel = guiCreateButton(693, 484, 150, 44, "Exit", false, window)
runcode = guiCreateButton(10, 487, 150, 44, "Run the code!", false, window)
codetype = guiCreateButton(170, 487, 150, 44, "Type: Server", false, window)
results_lbl = guiCreateLabel(12, 443, 831, 31, "Results: N/A", false, window)
guiCreateLabel(10, 27, 323, 16, "Your Code:", false, window)
guiCreateLabel(680, 31, 163, 16, "Panel scripted by xXMADEXx!", false, window)

addEvent ( 'GUIRuncode:onClientOpenPanel', true )
addEventHandler ( 'GUIRuncode:onClientOpenPanel', root, function ( )
	local to = not guiGetVisible ( window )
	guiSetVisible ( window, to )
	showCursor ( to )
	if to then
		addEventHandler ( 'onClientGUIClick', root, clickingButtonEvents )
		guiSetInputMode("no_binds_when_editing")
	else
		removeEventHandler ( 'onClientGUIClick', root, clickingButtonEvents )
		guiSetInputMode("allow_binds")
	end
end )

function clickingButtonEvents ( )
	if ( source == exitPanel ) then
		triggerEvent ( 'GUIRuncode:onClientOpenPanel', localPlayer )
	elseif ( source == codetype ) then
		local text = convertRunTypeButtonTextToScriptType ( )
		if ( text == 'server' ) then
			guiSetText ( codetype, "Type: Client" )
		else
			guiSetText ( codetype, "Type: Server" )
		end
	elseif ( source == runcode ) then
		local code = guiGetText ( playerCode )
		local side = convertRunTypeButtonTextToScriptType ( )
		if ( side == 'client' ) then
			runString ( code )
			triggerServerEvent ( "GUIRuncode:outputLogs", localPlayer, localPlayer, code, 'client' )
		elseif ( side == 'server' ) then
			triggerServerEvent ( "GUIRuncode:runServerCode", localPlayer, code )
		end
	end
end

function runString ( code )
	local notReturned
	local commandFunction,errorMsg = loadstring("return "..code)
	if errorMsg then
		notReturned = true
		commandFunction, errorMsg = loadstring(code)
	end
	if errorMsg then
		guiSetText ( results_lbl, "Results: "..errorMsg )
		return
	end
	results = { pcall(commandFunction) }
	if not results[1] then
		guiSetText ( results_lbl, "Results: "..results[2] )
		return
	end
	if not notReturned then
		local resultsString = ""
		local first = true
		for i = 2, #results do
			if first then
				first = false
			else
				resultsString = resultsString..", "
			end
			local resultType = type(results[i])
			if isElement(results[i]) then
				resultType = "element:"..getElementType(results[i])
			end
			resultsString = resultsString..tostring(results[i]).." ["..resultType.."]"
		end
		guiSetText ( results_lbl, "Results: "..resultsString )
	elseif not errorMsg then
		guiSetText ( results_lbl, "Results: Command executed" )
	end
end

function convertRunTypeButtonTextToScriptType ( )
	local text = guiGetText ( codetype )
	if ( text == "Type: Server" ) then
		return "server"
	elseif ( text == "Type: Client" ) then
		return "client"
	end
end

addEvent ( 'GUIRuncode:setClientResultText', true )
addEventHandler ( 'GUIRuncode:setClientResultText', root, function ( text )
	guiSetText ( results_lbl, text )
end )

