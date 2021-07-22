--MAXIME / 2015.1.10


local GUIEditor = {
    button = {},
    window = {},
    label = {},
    memo = {},
    edit = {},

}
local timer = {}

function showOpmTip()
	closeOpmTip()
	GUIEditor.window[2] = guiCreateWindow(607, 304, 449, 280, "Offline Private Message", false)
	guiWindowSetSizable(GUIEditor.window[2], false)
	exports.global:centerWindow(GUIEditor.window[2])
	GUIEditor.button[1] = guiCreateStaticImage(19, 102, 412, 85, "opm.png", false, GUIEditor.window[2])
	GUIEditor.label[1] = guiCreateLabel(17, 31, 414, 67, "Offline Private Message is a premium feature that allows you to send a private massage to any player no matter if they're online or offline.\n\nTarget player will receive your PM as a notification demonstrated below:", false, GUIEditor.window[2])
	guiLabelSetHorizontalAlign(GUIEditor.label[1], "left", true)
	local perk = exports.donators:getPerks(37)
	GUIEditor.label[2] = guiCreateLabel(17, 197, 414, 30, "It costs "..perk[2].." GC(s) per message.\nTo send offline private message use /opm", false, GUIEditor.window[2])
	guiLabelSetHorizontalAlign(GUIEditor.label[2], "left", true)
	GUIEditor.button[2] = guiCreateButton(160, 235, 132, 32, "OK", false, GUIEditor.window[2])
	addEventHandler("onClientGUIClick", GUIEditor.button[2], function()
		if source == GUIEditor.button[2]  then
			closeOpmTip()
		end
	end)
end

function closeOpmTip()
	if GUIEditor.window[2] and isElement(GUIEditor.window[2]) then
		destroyElement(GUIEditor.window[2])
	end
end

local foundUsername = nil
function startOpm(cmd, username, ...)
	if not username or not (...) then
		local msg = table.concat({...}," ")
		--outputChatBox("TIP: You can also type /opm [Username] [Message] to quickly send an offline pm without using this GUI.")
		closeOpm()
		showCursor(true)
		guiSetInputEnabled(true)
		GUIEditor.window[1] = guiCreateWindow(664, 283, 438, 295, "Offline private message", false)
		guiWindowSetSizable(GUIEditor.window[1], false)
		exports.global:centerWindow(GUIEditor.window[1])

		GUIEditor.label[1] = guiCreateLabel(20, 33, 50, 26, "To:", false, GUIEditor.window[1])
		guiSetFont(GUIEditor.label[1], "default-bold-small")
		guiLabelSetVerticalAlign(GUIEditor.label[1], "center")
		GUIEditor.memo[1] = guiCreateMemo(20, 85, 398, 152, "", false, GUIEditor.window[1])
		GUIEditor.edit[1] = guiCreateEdit(70, 33, 348, 26, "", false, GUIEditor.window[1])

		guiEditSetMaxLength(GUIEditor.edit[1], 100)
		GUIEditor.label[2] = guiCreateLabel(20, 59, 60, 26, "Message:", false, GUIEditor.window[1])
		guiSetFont(GUIEditor.label[2], "default-bold-small")
		guiLabelSetVerticalAlign(GUIEditor.label[2], "center")
		GUIEditor.label[3] = guiCreateLabel(94, 63, 293, 16, "", false, GUIEditor.window[1])
		guiLabelSetHorizontalAlign(GUIEditor.label[3], "center", false)
		guiLabelSetVerticalAlign(GUIEditor.label[3], "center")
		GUIEditor.button[3] = guiCreateButton(22, 249, 197, 26, "Cancel", false, GUIEditor.window[1])
		guiSetFont(GUIEditor.button[3], "default-bold-small")
		local cost = 0
		GUIEditor.button[2] = guiCreateButton(219, 249, 197, 26, "Send"..(cost > 0 and (" ("..cost.." GCs)") or ""), false, GUIEditor.window[1])
		guiSetFont(GUIEditor.button[2], "default-bold-small")
		guiSetEnabled(GUIEditor.button[2], false)
		addEventHandler("onClientGUIClick", GUIEditor.button[3], function()
			if source == GUIEditor.button[3]  then
				closeOpm()
			end
		end)

		addEventHandler("onClientGUIChanged", GUIEditor.edit[1], function()
        	if source == GUIEditor.edit[1] then
        		local text = guiGetText(GUIEditor.edit[1])
        		foundUsername = nil
        		guiSetText(GUIEditor.label[3], "")
        		if string.len(text) >= 3 then
	        		local count = 0
	        		guiSetText(GUIEditor.label[3], "Searching..")
	        		guiLabelSetColor ( GUIEditor.label[3], 255,255,255 )

	       			killTimerIfExisted(timer.username)
	        		timer.username = setTimer(function()
	        			local username = exports.cache:getUsername(text)
	        			if username then
	        				foundUsername = username
	        				guiSetText(GUIEditor.label[3], "Found: "..username..".")
	        				guiLabelSetColor ( GUIEditor.label[3], 0,255,0 )
	        				killTimerIfExisted(timer.username)
	        				guiSetText(GUIEditor.edit[1], username)
	        				validateOpm(guiGetText(GUIEditor.memo[1]))
	        			else
	        				if count > 4 then
	        					guiSetText(GUIEditor.label[3], "Username not found.")
	        					guiLabelSetColor ( GUIEditor.label[3], 255,0,0 )
	        					killTimerIfExisted(timer.username)
	        				end
	        			end
		        		count = count + 1
		        		--outputDebugString(count)
	        		end, 500, 6)
        		end
        		validateOpm(guiGetText(GUIEditor.memo[1]))
        	end
        end)
		addEventHandler("onClientGUIChanged", GUIEditor.memo[1], function ()
			validateOpm(guiGetText(GUIEditor.memo[1]))
		end)
		if username then
			guiSetText(GUIEditor.edit[1], username)
		end
		if msg then
			guiSetText(GUIEditor.memo[1], msg)
		end

		addEventHandler("onClientGUIClick", GUIEditor.button[2], function()
			if source == GUIEditor.button[2]  then
				exports.global:playSoundSuccess()
				triggerServerEvent("opm:send", localPlayer, foundUsername, guiGetText(GUIEditor.memo[1]), cost)
				closeOpm()
			end
		end)
	end
end
addCommandHandler("opm", startOpm)

function closeOpm()
	if GUIEditor.window[1] and isElement(GUIEditor.window[1]) then
		destroyElement(GUIEditor.window[1])
		guiSetInputEnabled(false)
		showCursor(false)
	end
end

function killTimerIfExisted(timer)
	if isTimer(timer) then
		killTimer(timer)
	end
end

function validateOpm(msg)
	if foundUsername and string.len(msg) > 1 and string.len(msg) < 1000 then
		---outputChatBox("valid")
		guiSetEnabled(GUIEditor.button[2], true)
	else
		--outputChatBox("not valid")
		guiSetEnabled(GUIEditor.button[2], false)
	end
end
