--MAXIME

GUIEditor_Window = {}
GUIEditor_Button = {}
GUIEditor_Edit = {}

local url = nil
local sender = nil

function showUrlSender(url1)
	closeUrlSender()

	local screenWidth, screenHeight = guiGetScreenSize()
	local windowWidth, windowHeight = 531,106
	local left = screenWidth - windowWidth - 20
	local top = screenHeight - windowHeight - 40

	exports["item-system"]:playSoundInvOpen()
	playSound(":integration/invite.ogg")

	url = url1 or ""
	sender = exports.global:getPlayerName(source)

	GUIEditor_Window[1] = guiCreateWindow(left,top,windowWidth,windowHeight,sender.." has linked you to an URL. Do you want to copy it to clipboard?'",false)
	guiWindowSetSizable(GUIEditor_Window[1],false)
	GUIEditor_Edit[1] = guiCreateEdit(10,26,512,30,url,false,GUIEditor_Window[1])
	guiEditSetReadOnly(GUIEditor_Edit[1],true)
	GUIEditor_Button[1] = guiCreateButton(10,67,256,28,"Copy (Enter)",false,GUIEditor_Window[1])
	GUIEditor_Button[2] = guiCreateButton(266,67,256,28,"Dismiss (Backspace)",false,GUIEditor_Window[1])
	addEventHandler("onClientGUIClick", GUIEditor_Button[2], function()
		if source == GUIEditor_Button[2] then
			closeUrlSender()
		end
	end)
	addEventHandler("onClientGUIClick", GUIEditor_Button[1], function()
		closeUrlSender()
		if setClipboard(url) then
			outputChatBox("Copied '"..url.."'.")
			url = nil
			sender = nil
		end
	end, false)
	addEventHandler("onClientKey", root, copyIt)
	addEventHandler("onClientKey", root, dismissIt)
end
addEvent("showUrlSender", true)
addEventHandler("showUrlSender", root, showUrlSender)

function closeUrlSender()
	if GUIEditor_Window[1] and isElement(GUIEditor_Window[1]) then
		destroyElement(GUIEditor_Window[1])
		showing = nil
		exports["item-system"]:playSoundInvClose()
		removeEventHandler("onClientKey", root, copyIt)
		removeEventHandler("onClientKey", root, dismissIt)
	end
end

function copyIt(button, press)
	if GUIEditor_Window[1] and isElement(GUIEditor_Window[1]) and press and button == "enter" then
		closeUrlSender()
		if setClipboard(url) then
			outputChatBox("Copied '"..url.."'.")
			url = nil
			sender = nil
		end
		cancelEvent()
	end
end

function dismissIt(button, press)
	if GUIEditor_Window[1] and isElement(GUIEditor_Window[1]) and press and button == "backspace" then
		closeUrlSender()
		url = nil
		sender = nil
		cancelEvent()
	end
end
