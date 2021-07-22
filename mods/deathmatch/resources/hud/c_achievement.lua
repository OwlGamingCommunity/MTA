wAchievement, imgAchievement, lTitle, lDesc = nil

function displayAchievement(title, name, description, points)
	local width, height = 600, 100
	local scrWidth, scrHeight = guiGetScreenSize()
	local x = scrWidth/2 - (width/2)
	local y = scrHeight - (scrHeight/6 - (height/6))
	
	wAchievement = guiCreateWindow(x, y, width, height,title, false)
	imgAchievement = guiCreateStaticImage(0.025, 0.25, 0.15, 0.7, "images/achievement/achievement.png", true, wAchievement)
	
	lTitle = guiCreateLabel(0.2, 0.25, 0.6, 0.2, tostring(name) .. " (" .. points .. " Points)", true, wAchievement)
	guiSetFont(lTitle, "default-bold-small")
	guiLabelSetHorizontalAlign(lTitle, "center")
	
	lDesc = guiCreateLabel(0.2, 0.45, 0.6, 0.4, tostring(description), true, wAchievement)
	guiLabelSetHorizontalAlign(lDesc, "center")
	
	
	playSoundFrontEnd(101)
	guiSetAlpha(wAchievement, 0)
	setTimer(fadeWindowIn, 50, 15, wAchievement)
	setTimer(fadeWindowOutStart, 8000, 1, wAchievement)
end
addEvent("onPlayerGetAchievement", true)
addEventHandler("onPlayerGetAchievement", getRootElement(), displayAchievement)

function fadeWindowIn(window)
	local alpha = guiGetAlpha(window)
	local newalpha = alpha + 0.05
	guiSetAlpha(window, newalpha)
end

function fadeWindowOutStart(window)
	setTimer(fadeWindowOut, 50, 15, window)
end

function fadeWindowOut(window)
	local alpha = guiGetAlpha(window)
	local newalpha = alpha - 0.05
	guiSetAlpha(window, newalpha)
	
	if (newalpha<=0) then
		destroyElement(wAchievement)
		wAchievement, imgAchievement, lTitle, lDesc = nil, nil, nil, nil
	end
end

