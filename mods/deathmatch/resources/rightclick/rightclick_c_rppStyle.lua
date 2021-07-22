--    ____        __     ____  __            ____               _           __ 
--   / __ \____  / /__  / __ \/ /___ ___  __/ __ \_________    (_)__  _____/ /_
--  / /_/ / __ \/ / _ \/ /_/ / / __ `/ / / / /_/ / ___/ __ \  / / _ \/ ___/ __/
-- / _, _/ /_/ / /  __/ ____/ / /_/ / /_/ / ____/ /  / /_/ / / /  __/ /__/ /_  
--/_/ |_|\____/_/\___/_/   /_/\__,_/\__, /_/   /_/   \____/_/ /\___/\___/\__/  
--                                 /____/                /___/                 
--Client-side script: Rightclick
--Last updated 23.02.2011 by Exciter
--Copyright 2008-2011, The Roleplay Project (www.roleplayproject.com)

rcmenu = false
local rcWidth = 0
local rcHeight = 0

function destroy()
	destroyTimer = nil
	if rcmenu then
		destroyElement(rcmenu)
	end
	rcWidth = 0
	rcHeight = 0
	rcmenu = nil
	if isCursorShowing() then
		showCursor(false)
		--triggerEvent("cursorHide", getLocalPlayer())
	end
	return true
end

function leftClickAnywhere(button, state, absX, absY, wx, wy, wz, element)
	if(button == "left" and state == "down") then
		if isElement(rcmenu) then
			destroyTimer = setTimer(destroy, 250, 1) --100
			--guiSetVisible(rcmenu, false)
		end
	end
end
addEventHandler("onClientClick", getRootElement(), leftClickAnywhere, true)
addEvent("serverTriggerLeftClick", true)
addEventHandler("serverTriggerLeftClick", localPlayer, leftClickAnywhere)

function create(title)
	if(destroyTimer) then
		killTimer(destroyTimer)
		destroyTimer = nil
	end
	if(rcmenu) then
		destroy()
	end
	if not title then title = "" end
	local x,y,wx,wy,wz = getCursorPosition()
	rcmenu = guiCreateStaticImage(x,y,0,0,"131.png",true)
	rcTitleBg = guiCreateStaticImage(0,0,0,0,"0.png",false,rcmenu)
	rcTitle = guiCreateLabel(2,0,0,0,tostring(title),false,rcTitleBg)
	guiSetFont(rcTitle,"default-bold-small")
	guiLabelSetColor(rcTitle,255,255,255)
	local extent = guiLabelGetTextExtent(rcTitle)
	guiSetSize(rcTitleBg,500,15,false)
	guiSetSize(rcTitle,extent,15,false)
	rcWidth = extent + 4
	rcHeight = 15
	guiSetSize(rcmenu,rcWidth,rcHeight,false)
	return rcmenu
end

function addRow(title,header,nohover)
	local row
	if not title then title = "" end
	if header then
		local rowbg = guiCreateStaticImage(0,rcHeight,500,15,"0.png",false,rcmenu)
		row = guiCreateLabel(2,0,0,0,tostring(title),false,rowbg)
		guiSetFont(row,"default-bold-small")
		guiLabelSetColor(row,255,255,255)
		local extent = guiLabelGetTextExtent(row)
		guiSetSize(row,extent,15,false)
		rcHeight = rcHeight + 15
		if(extent + 4 > rcWidth) then
			rcWidth = extent + 4
		end
		guiSetSize(rcmenu,rcWidth,rcHeight,false)
	else
		row = guiCreateLabel(2,rcHeight,0,0,tostring(title),false,rcmenu)
		guiSetFont(row,"default-normal")
		guiLabelSetColor(row,255,255,255)
		local extent = guiLabelGetTextExtent(row)
		guiSetSize(row,extent,15,false)
		rcHeight = rcHeight + 15
		if(extent + 4 > rcWidth) then
			rcWidth = extent + 4
		end
		guiSetSize(rcmenu,rcWidth,rcHeight,false)
		if not nohover then
			addEventHandler("onClientMouseEnter",row,function()
				guiLabelSetColor(row,255,187,0)
			end,false)
			addEventHandler("onClientMouseLeave",row,function()
				guiLabelSetColor(row,255,255,255)
			end,false)
		else
			guiLabelSetColor(row,180,180,180)
		end
	end
	return row
end

function addrow(title,header,nohover) --for compatibility (older versions used lowercase function names, which is still being called to by some older scripts)
	return addRow(title,header,nohover)
end