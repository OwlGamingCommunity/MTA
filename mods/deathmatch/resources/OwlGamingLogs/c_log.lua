--local isEnabled = true
local xmlFile = nil
local xmlNode = nil
local yearday, hour
local timer = nil

--[[
function applyClientConfigSettings()
	
	
	local logsEnabled = tonumber( exports.account:loadSavedData("logsenabled", "1") ) or 1
	if (logsEnabled == 1) then
		openFile( )
		isEnabled = true
	else
		closeFile( )
		isEnabled = false
	end
	
end
addEventHandler("accounts:settings:loadGraphicSettings", getRootElement(), applyClientConfigSettings)
]]
--

function openFile( )
	if getElementData(localPlayer, "graphic_logs") == "0" then
		return false
	end
	
	local time = getRealTime( )
	yearday = time.yearday
	hour = time.hour
	local fileName = ( "Chatbox/%04d-%02d-%02d/%02d.html" ):format( time.year + 1900, time.month + 1, time.monthday, time.hour )
	
	xmlFile = xmlLoadFile( fileName )
	if not xmlFile then
		-- create the basic layout
		xmlFile = xmlCreateFile( fileName, "html" )
		local head = xmlCreateChild( xmlFile, "head" )

		local charset = xmlCreateChild( head, "meta" )
		xmlNodeSetAttribute( charset, "charset", "utf-8" )

		local title = xmlCreateChild( head, "title" )
		xmlNodeSetValue( title, ( "OwlGaming MTA :: Client Logs :: %04d-%02d-%02d" ):format( time.year + 1900, time.month + 1, time.monthday ) )
		
		local style = xmlCreateChild( head, "style" )
		xmlNodeSetAttribute( style, "type", "text/css" )
		xmlNodeSetValue( style, "body { font-family: Tahoma; font-size: 0.8em; background: #000000; }  p { padding: 0; margin: 0; } .v1 { color: #AAAAAA; } .v2 { color: #DDDDDD; } .v3 { white-space:pre; }" )
		
		--
		
		xmlNode = xmlCreateChild( xmlFile, "body" )
		xmlSaveFile( xmlFile )
	else
		xmlNode = xmlFindChild( xmlFile, "body", 0 )
	end
end

function closeFile( )
	if xmlFile then
		if timer then
			xmlSaveFile( xmlFile )
			killTimer( timer )
		end
		xmlUnloadFile( xmlFile )
		xmlFile = nil
		xmlNode = nil
	end
end

function xmlNodeSetValue2( a, b )
	if b:match "^%s*(.-)%s*$" == "" then
		return xmlDestroyNode( a )
	else
		return xmlNodeSetValue( a, b )
	end
end

local lastMessage = nil
addEventHandler( "onClientChatMessage", getRootElement( ),
	function( message, r, g, b )
		if getElementData(localPlayer, "graphic_logs") == "0" then
			return false
		end
		
		if message == "" or message == " " then
			if lastMessage == message then
				return
			end
		end
		lastMessage = message
		
		local time = getRealTime( )
		if not xmlFile or not xmlNode then
			openFile( )
		elseif time.yearday ~= yearday or time.hour ~= hour then
			closeFile( )
			openFile( )
		end
		
		local node = xmlCreateChild( xmlNode, "p" )
		
		--
		local nodeDate = xmlCreateChild( node, "span" )
		xmlNodeSetValue( nodeDate, ( "%04d-%02d-%02d" ):format( time.year + 1900, time.month + 1, time.monthday ) )
		xmlNodeSetAttribute( nodeDate, "class", "v1" )
		
		local nodeTime = xmlCreateChild( node, "span" )
		xmlNodeSetValue( nodeTime, ( "%02d:%02d:%02d" ):format( time.hour, time.minute, time.second ) )
		xmlNodeSetAttribute( nodeTime, "class", "v2" )

		
		local t = { }
		local prevcolor = ("#%02x%02x%02x"):format( r, g, b )
		while true do
			local a, b = message:find("#%x%x%x%x%x%x")
			local t = xmlCreateChild( node, "span" )
			xmlNodeSetAttribute( t, "class", "v3" )
			if a and b then
				xmlNodeSetAttribute( t, "style", "color:" .. prevcolor )
				xmlNodeSetValue2( t, message:sub( 1, a - 1 ) )
				prevcolor = message:sub( a, b )
				message = message:sub( b + 1 )
			else
				xmlNodeSetAttribute( t, "style", "color:" .. prevcolor )
				xmlNodeSetValue2( t, message )
				break
			end
		end
		
		if not timer then
			setTimer( function( ) timer = nil xmlSaveFile( xmlFile ) end, 1000, 1 )
		end
	end
)

addEventHandler( "onClientResourceStart", getResourceRootElement( ),
	function( )
		openFile( )
	end
)

addEventHandler( "onClientResourceStop", getResourceRootElement( ),
	function( )
		closeFile( )
	end
)



function writeCellphoneLog(charName, fromPhone, subfolder, toPhone, message )
	if string.len(message) < 1 then
		return false
	end
	
	local fileName = "Cellphone/"..charName.."/From "..fromPhone.."/"..subfolder.."/To "..toPhone..".txt"
	
	local file = createFileIfNotExists(fileName)
	local size = fileGetSize(file)
	fileSetPos(file, size)
	fileWrite(file, message .. "\r\n")
	fileFlush(file)
	fileClose(file)
	return true
end

function createFileIfNotExists(filename)
	local file = nil
	if fileExists ( filename ) then
		file = fileOpen(filename)
	else
		file = fileCreate(filename)
	end
	return file
end

local GUIEditor = {
    button = {},
    window = {},
    label = {}
}
function drawInfoBox()
	closeInfoBox()
    GUIEditor.window[1] = guiCreateWindow(675, 318, 361, 189, "OwlGaming Client Logging", false)
    guiWindowSetSizable(GUIEditor.window[1], false)
    exports.global:centerWindow(GUIEditor.window[1])
    GUIEditor.label[1] = guiCreateLabel(14, 22, 333, 130, "OwlGaming Client Logging is a feature that writes down everything of your chatbox and your cellphone conversations then stores them in folders on your PC.\n\nThey are located in your MTA installation folder under:\n ../mods/deathmatch/resources/OwlGamingLogs\n\nThese features can also be toggled in F10 Game Settings.", false, GUIEditor.window[1])
    guiLabelSetHorizontalAlign(GUIEditor.label[1], "left", true)
    GUIEditor.button[1] = guiCreateButton(10, 149, 341, 30, "Ok, I've got it!", false, GUIEditor.window[1])  
    addEventHandler("onClientGUIClick", GUIEditor.button[1], closeInfoBox)  
end

function closeInfoBox()
	if GUIEditor.window[1] and isElement(GUIEditor.window[1]) then
		destroyElement(GUIEditor.window[1])
		GUIEditor.window[1] = nil
	end
end