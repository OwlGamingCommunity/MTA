--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

local sx, sy = guiGetScreenSize()
local localPlayer = getLocalPlayer()
local font = dxCreateFont (":resources/Anton.ttf" , 16 )
local unreads = 0
local notis = {}
local notis_pending_deleted = {}
local notis_pending_read = {}
--SETTINGS
local imgw, imgh = 64, 64 --icon size
local bulletW, bulletH = 16,16--bullet size
local bgw, bgh = 30, 30 --bg size
local bgDetailOffsetX, bgDetailOffsetY = 0, 20
local thumpOffsetX, thumpOffsetY = 150, -6
local globalOffSetX, globalOffSetY = (getElementData(localPlayer, "hud:whereToDisplay") or 0 ) - 200, getElementData(localPlayer, "hud:whereToDisplayY") or 0
local refreshRate1, refreshRate2 = 5, 10 --minutes
local showPreview = false
--[[
local invisibleArea = guiCreateWindow ( thumpOffsetX+globalOffSetX, thumpOffsetY+globalOffSetY, imgw+bgw , imgh+bgh , "" ,false)
guiSetAlpha(invisibleArea, 0)
guiWindowSetMovable ( invisibleArea, false )
guiWindowSetSizable ( invisibleArea, false )
]]
local justClicked_title = false
local lastClick = 0
function drawPmThump()
	if exports.hud:isActive() and getElementData(localPlayer, "loggedin") == 1 and not isPlayerMapVisible() and ((getElementData(localPlayer, "noti_no_noti") == "1" and #notis == 0) or (#notis > 0)) then
		globalOffSetX = (getElementData(localPlayer, "hud:whereToDisplay") or 0 ) - 120
		globalOffSetY = (getElementData(localPlayer, "hud:whereToDisplayY") or 0 ) - 5
		--guiSetPosition(invisibleArea, globalOffSetX+thumpOffsetX, thumpOffsetY, false)
		local posxIcon = globalOffSetX
		local posxBG = imgw+globalOffSetX
		local posxText = posxIcon+5
		dxDrawImage ( posxIcon+thumpOffsetX, 5+globalOffSetY, imgw, imgh, "owl_noti.png")
		--dxDrawRectangle(posxBG+thumpOffsetX, 10+globalOffSetY, bgw, bgh, tocolor(0, 0, 0, 100), false)
		if not font then
			font = dxCreateFont (":resources/Anton.ttf" , 10 )
		end
		local text = ''
		if unreads > 0 then
			if unreads <=10 then
				text = string.format("%2d", unreads)
			elseif unreads > 10 then
				text = '10+'
			end
		end
		dxDrawText( text, posxText+thumpOffsetX-24, 9+globalOffSetY+1.2, bgw, bgh, tocolor ( 0, 0, 0, 255 ), 1.2, font)
		dxDrawText( text, posxText+thumpOffsetX-26, 9+globalOffSetY, bgw, bgh, tocolor ( 255, 255, 255, 255 ), 1.2, font)

		if isCursorShowing() then
			local cursorX, cursorY, cwX, cwY, cwZ = getCursorPosition()
			cursorX, cursorY = cursorX * sx, cursorY * sy
			if isInBox( cursorX, cursorY, posxText+thumpOffsetX, posxText+thumpOffsetX+2+bgw, 12+globalOffSetY, 12+globalOffSetY+bgh) then
				if justClicked_title then
					if justClicked_title == "left" then
						playSound(":resources/toggle.mp3")
			            --if (#notis > 0) then
							toggleNotiDetail()
						--end
					elseif justClicked_title == "right" then
						if lastClick >= getTickCount()-2000 then
							lastClick = 0
							justClicked_title = false
							playSound(":resources/inv_toggle.mp3")
							if (#notis > 0) then
								clearNotifications()
							end
						end
					end

				end
			end
		end
		if justClicked_title and justClicked_title == "right" then
			lastClick = getTickCount()
		end
		justClicked_title = false
	end
end
addEventHandler("onClientRender",getRootElement(), drawPmThump)

local justClicked_preview = false
function drawPmPreviews()
	if exports.hud:isActive() and showPreview and getElementData(localPlayer, "loggedin") == 1 and not isPlayerMapVisible() then
		local count = 0
		for i = 1, #notis+1 do
			local margin = 3
			local lineH = 15
			local bgDetailsW, bgDetailsH =  300,36--bg detail size

			local noti = notis[i] or false
			local titleText = "• "..(noti and noti.title or "")
			local titleWith = dxGetTextWidth(titleText)
			local dateText = noti and ("  » "..exports.datetime:formatTimeInterval(tonumber(noti.datesec))..". "..noti.fdate) or ""
			if titleWith > bgDetailsW-margin*2 then
				bgDetailsW = titleWith+margin*2
			end

			if not noti then
				bgDetailsW = 100
				--bgDetailsH = 20
			end

			local dBoxX = sx-bgDetailsW-margin*4

			local ax, ay = bgDetailOffsetX+dBoxX, 10+bgh+bgDetailOffsetY+globalOffSetY+count*(bgDetailsH+margin*2)
			local bx, by = ax+bgDetailsW, ay+bgDetailsH
			local mhover = false

			if isCursorShowing() then
				local cursorX, cursorY, cwX, cwY, cwZ = getCursorPosition()
				cursorX, cursorY = cursorX * sx, cursorY * sy
				if isInBox( cursorX, cursorY, ax, bx, ay, by) then
					mhover = true
					if justClicked_preview then
						playSound(":resources/toggle.mp3")
						if noti then
							if justClicked_preview == "left" then
								openNoti(noti)
								if unreads <=0 then
									local deletes, reads = refreshAndUpdateNotisServerSide()
									if deletes then
										triggerServerEvent("deleteNoti", localPlayer, deletes)
									end
									if reads then
										triggerServerEvent("readNoti", localPlayer, reads)
									end
									if deletes or reads then
										setTimer(requestPmsFromServer, 1000, 1)
									end
								end
							else
								deleteNoti(noti)
								if #notis and #notis < 1 then
									local deletes, reads = refreshAndUpdateNotisServerSide()
									if deletes then
										triggerServerEvent("deleteNoti", localPlayer, deletes)
									end
									if reads then
										triggerServerEvent("readNoti", localPlayer, reads)
									end
									if deletes or reads then
										setTimer(requestPmsFromServer, 1000, 1)
									end
								end
							end
						else
							toggleNotiDetail()
							triggerEvent("accounts:settings:fetchSettings", localPlayer, "Notifications")
						end
					end
				end
			end
			local alpha = 100
			if mhover then
				alpha = 150
			end
			local bgColor = tocolor(0, 0, 0,alpha-80)
			if noti then
				if noti.read == "0" then
					bgColor = tocolor(0, 0, 0,alpha)
				end
				dxDrawRectangle(ax, ay, bgDetailsW, bgDetailsH, bgColor, false)
				dxDrawRectangleBorder(ax, ay, bgDetailsW, bgDetailsH, 1, tocolor(255, 255, 255, 100), true)
				dxDrawText(titleText, ax+margin, ay+margin, bgDetailsW-margin*2, lineH, tocolor(0, 0, 0, 150), 1, "default")
				dxDrawText(titleText, ax+margin-1, ay+margin-1, bgDetailsW-margin*2, lineH, tocolor(255, 255, 255, 255), 1, "default")
				dxDrawText(dateText, ax+margin, 10+bgh+bgDetailOffsetY+globalOffSetY+margin+lineH+count*(bgDetailsH+margin*2), bgDetailsW-margin*2, lineH, tocolor(255, 255, 255, 200), 1, "default-small")

			else
				--dxDrawImage ( sx-40, ay, 30, 30, ":phone/images/settings.png"  )
				dxDrawRectangle(ax, ay, bgDetailsW, bgDetailsH, tocolor(100, 100, 100,alpha), false)
				dxDrawRectangleBorder(ax, ay, bgDetailsW, bgDetailsH, 1, tocolor(255, 255, 255, 100), true)
				dxDrawText("SETTINGS", ax+margin+20, ay+margin+7, bgDetailsW-margin*2, lineH, tocolor(255, 255, 255, 255), 1, "default-bold")
				--dxDrawText(dateText, ax+margin, 10+bgh+bgDetailOffsetY+globalOffSetY+margin+lineH+count*(bgDetailsH+margin*2), bgDetailsW-margin*2, lineH, tocolor(255, 255, 255, 200), 1, "default-small")
			end
			count = count + 1
		end
		justClicked_preview = false
	end
end
addEventHandler("onClientRender",getRootElement(), drawPmPreviews)

function deleteNotisServerSide()
	local delete = nil
	if #notis_pending_deleted > 0 then
		for i, noti in pairs(notis_pending_deleted) do
			if not delete then
				delete = "id="..noti.id
			else
				delete = delete.." OR id="..noti.id
			end
		end
		notis_pending_deleted = {}
	end
	return delete
end

function readNotisServerSide()
	local read = nil
	if #notis_pending_read > 0 then
		for i, noti in pairs(notis_pending_read) do
			if not read then
				read = "id="..noti.id
			else
				read = read.." OR id="..noti.id
			end
		end
		notis_pending_read = {}
	end
	return read
end

function clearNotifications()
	triggerServerEvent("clearNotis", localPlayer, refreshAndUpdateNotisServerSide())
end

function refreshAndUpdateNotisServerSide()
	return deleteNotisServerSide(), readNotisServerSide()
end

local GUIEditor = {
    button = {},
    window = {},
    memo = {}
}

function openNoti(noti)
	closeNoti()
	exports.global:playSoundSuccess()
	GUIEditor.window[1] = guiCreateWindow(631, 387, 474, 215, "Notification", false)
	guiWindowSetSizable(GUIEditor.window[1], false)
	exports.global:centerWindow(GUIEditor.window[1])
	GUIEditor.memo[1] = guiCreateMemo(9, 23, 455, 152, noti.title.."\n\n"..(noti.details and noti.details or ""), false, GUIEditor.window[1])
	GUIEditor.button[1] = guiCreateButton(12, 181, 452, 24, "Close", false, GUIEditor.window[1])
	addEventHandler("onClientGUIClick", GUIEditor.button[1], function()
		if source == GUIEditor.button[1] then
			closeNoti()
		end
	end)
	if noti.read == "0" then
		unreads = unreads -1
		noti.read="1"
		table.insert(notis_pending_read, noti)
		table.sort(notis, function(a, b)
			if tonumber(a.read) == tonumber(b.read) then
				return tonumber(a.datesec) > tonumber(b.datesec)
			else
			 	return tonumber(a.read) < tonumber(b.read)
			end
		end)
		local opm = nil
		if noti.type and tonumber(noti.type) then
			opm = {}
			opm.sender = noti.type
			opm.sentdate = noti.fdate
			local text = noti.details and noti.details or nil
			if text then
				if string.len(text) > 20 then
					text = string.sub(text, 1, 20)..".."
				end
			end
			opm.details = text
			opm.receiver = getElementData(localPlayer, "account:username")
			triggerServerEvent("readNoti", localPlayer, noti.id, opm)
		end
	end
end

function closeNoti()
	if GUIEditor.window[1] and isElement(GUIEditor.window[1]) then
		destroyElement(GUIEditor.window[1])
	end
end

function deleteNoti(noti)
	--triggerServerEvent("deleteNoti", localPlayer, noti.id)
	noti.deleted = true
	if noti.read == "0" then
		unreads = unreads -1
	end
	local newNotis = {}
	for i, noti2 in ipairs(notis) do
		if noti2.deleted then
			table.insert(notis_pending_deleted, noti2)
		else
			table.insert(newNotis, noti2)
		end
	end
	notis = newNotis
	if #notis < 1 then
		showPreview = false
		setElementData(localPlayer, "integration:previewPMShowing", false, false)
	end
end

function isInBox( x, y, xmin, xmax, ymin, ymax )
	--outputDebugString(tostring(x)..", "..tostring(y)..", "..tostring(xmin)..", "..tostring(xmax)..", "..tostring(ymin)..", "..tostring(ymax))
	return x >= xmin and x <= xmax and y >= ymin and y <= ymax
end

addEventHandler( "onClientClick", root,
	function( button, state )
		if exports.hud:isActive() and state == "down" and getElementData(localPlayer, "loggedin") == 1 and not isPlayerMapVisible() then
			if showPreview then
				justClicked_preview = button
			end
			justClicked_title = button
		end
	end
)
--[[
addEventHandler( "onClientGUIMouseDown", getRootElement( ),
    function ( btn, x, y )
        if btn == "left" and source == invisibleArea then
        	playSound(":resources/toggle.mp3")
            if (#notis > 0) then
				toggleNotiDetail()
			end
        end
    end
)
]]

function toggleNotiDetail()
	--if not showPreview then return false end
	showPreview = not showPreview
	setElementData(localPlayer, "integration:previewPMShowing", showPreview, false)
end

function getPmsFromServer(notis1)
	if notis1 and #notis1 >= 0 then
		notis = notis1
		local unreads2 = 0
		for i, noti in ipairs(notis) do
			if noti.read == "0" then
				unreads2 = unreads2 + 1
			end
		end
		if unreads2 > unreads and getElementData(localPlayer, "loggedin") == 1 then
			exports.global:playSoundAlert()
		end
		unreads = unreads2
	end
	if #notis1 == 0 then
		showPreview = false
		setElementData(localPlayer, "integration:previewPMShowing", false, false)
	end
end
addEvent( "integration:getPmsFromServer", true )
addEventHandler( "integration:getPmsFromServer", localPlayer, getPmsFromServer )

local theTimer = nil
function requestPmsFromServer()
	local minutes = math.random(refreshRate1, refreshRate2)
	if theTimer and isTimer(theTimer) then
		killTimer(theTimer)
	end
	theTimer = setTimer ( requestPmsFromServer, 1000*60*minutes , 1)
	outputDebugString("[CLIENT] - requestNotiFromServer again in "..minutes.." minutes.")
	if getElementData(localPlayer,"loggedin") ~= 1 then
		return false
	end
	triggerServerEvent ( "integration:givePmsToClient", localPlayer, refreshAndUpdateNotisServerSide() )
end
addEventHandler("onClientResourceStart",resourceRoot,requestPmsFromServer)
addEventHandler( "account:character:spawned", root, requestPmsFromServer )

function dxDrawRectangleBorder(x, y, width, height, borderWidth, color, out, postGUI)
	if out then
		--[[Left]]	dxDrawRectangle(x - borderWidth, y, borderWidth, height, color, postGUI)
		--[[Right]]	dxDrawRectangle(x + width, y, borderWidth, height, color, postGUI)
		--[[Top]]	dxDrawRectangle(x - borderWidth, y - borderWidth, width + (borderWidth * 2), borderWidth, color, postGUI)
		--[[Botm]]	dxDrawRectangle(x - borderWidth, y + height, width + (borderWidth * 2), borderWidth, color, postGUI)
	else
		local halfW = width / 2
		local halfH = height / 2
		--[[Left]]	dxDrawRectangle(x, y, math.clip(0, borderWidth, halfW), height, color, postGUI)
		--[[Right]]	dxDrawRectangle(x + width - math.clip(0, borderWidth, halfW), y, math.clip(0, borderWidth, halfW), height, color, postGUI)
		--[[Top]]	dxDrawRectangle(x + math.clip(0, borderWidth, halfW), y, width - (math.clip(0, borderWidth, halfW) * 2), math.clip(0, borderWidth, halfH), color, postGUI)
		--[[Botm]]	dxDrawRectangle(x + math.clip(0, borderWidth, halfW), y + height - math.clip(0, borderWidth, halfH), width - (math.clip(0, borderWidth, halfW) * 2), math.clip(0, borderWidth, halfH), color, postGUI)
	end
end
