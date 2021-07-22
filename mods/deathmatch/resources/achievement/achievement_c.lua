local gui = {}
local timer = {}
function displayAchievement(title, desc, gc)
	closeAchievement()
	local w, h = 400, 70
	local scrWidth, scrHeight = guiGetScreenSize()
	local margin = 20
	local x = scrWidth - w - margin
	local y = scrHeight - h - margin - 20
	
	gui.wAchievement = guiCreateStaticImage(x, y, w, h,"achievement.png", false)
	gui.lTitle = guiCreateLabel(0.18, 0.25, 0.757, 0.2, title and string.upper(title) or "ACHIEVEMENT UNLOCKED!", true, gui.wAchievement)
	guiSetFont(gui.lTitle, "default-bold-small")
	guiLabelSetHorizontalAlign(gui.lTitle, "center")
	
	local reward = ""
	if gc and tonumber(gc) and tonumber(gc) > 0 then
		gc = math.floor(gc)
		reward = " (+"..gc.."GC)"
	end
	
	gui.lDesc = guiCreateLabel(0.18, 0.45, 0.757, 0.4, (desc or "")..reward, true, gui.wAchievement)
	guiLabelSetHorizontalAlign(gui.lDesc, "center")
	
	
	playSoundFx()
	timer[1] = setTimer(fadeWindowOutStart, 15000, 1, gui.wAchievement)
end
addEvent("displayAchievement", true)
addEventHandler("displayAchievement", root, displayAchievement)

function closeAchievement()
	if gui.wAchievement and isElement(gui.wAchievement) then
		destroyElement(gui.wAchievement)
		gui = {}
	end
	
	if isTimer(timer[1]) then
		killTimer(timer[1])
	end
	
	if isTimer(timer[2]) then
		killTimer(timer[2])
	end
end

function fadeWindowOutStart(window)
	timer[2] = setTimer(fadeWindowOut, 50, 15, window)
end

function fadeWindowOut(window)
	local alpha = isElement(window) and guiGetAlpha(window) or 0
	local newalpha = alpha - 0.1
	if isElement(window) then
		guiSetAlpha(window, newalpha)
	end
	
	if (newalpha<=0) then
		closeAchievement()
	end
end

function playSoundFx()
	playSound ( "achievement.mp3", false )
end
addEvent("playSoundFx", true)
addEventHandler("playSoundFx", localPlayer, playSoundFx)