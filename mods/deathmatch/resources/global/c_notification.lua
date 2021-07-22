-- VARIABLES
local sx, sy = guiGetScreenSize()

-- SHOW TIP WINDOW
function showTip(string)
	if not isElement(g_tip_window) then
		g_tip_window = guiCreateWindow((sx-330), 30, 300, 100, "Notification", false)
		Animation.createAndPlay(g_tip_window, Animation.presets.guiFadeIn(1000))
		guiWindowSetSizable(g_tip_window, false)
		guiWindowSetMovable(g_tip_window, false)
		
		g_tip_label = guiCreateLabel(15, 25, 270, 100, tostring(string), false, g_tip_window)
		guiLabelSetHorizontalAlign(g_tip_label, "left", true)
		guiSetFont(g_tip_label, "default-bold-small")
		
		tipremove1 = setTimer(function() Animation.createAndPlay(g_tip_window, Animation.presets.guiFadeOut(1000)) end, 8000, 1)
		tipremove2 = setTimer(function() destroyElement(g_tip_window) end, 9000, 1)
	else
		if isTimer(tipremove1) or isTimer(tipremove2) then
			local time, left, has = getTimerDetails(tipremove2)
			setTimer(function(string)
				showTip(string)
			end, time+1100, 1, string)
		end
	end
end
addEvent("onTipShow", true)
addEventHandler("onTipShow", root, showTip)