--MAXIME
local hotlinesGUI = {}
function drawPhoneHotlines(xoffset, yoffset)
	if not isPhoneGUICreated() then
		return false
	end

	if not xoffset then xoffset = 0 end
	if not yoffset then yoffset = 0 end

	if wHotlines and isElement(wHotlines) then
		return false
		--destroyElement(wHotlines)
	end

	wHotlines = guiCreateScrollPane(30+xoffset, 100+yoffset, 230, 370, false, wPhoneMenu)
	local count = 0
	for _, line in ipairs(getHotlines()) do
		local lineNumber = line[2]
		hotlinesGUI[lineNumber] = {}
	    hotlinesGUI[lineNumber].number = guiCreateLabel(10+xoffset, 10+yoffset, 153, 19, lineNumber, false, wHotlines)
	    guiSetFont(hotlinesGUI[lineNumber].number, "default-bold-small")
	    guiLabelSetVerticalAlign(hotlinesGUI[lineNumber].number, "center")
	
	    hotlinesGUI[lineNumber].name = guiCreateLabel(10+xoffset, 29+yoffset, 150, 16, line[1], false, wHotlines)
	    guiSetFont(hotlinesGUI[lineNumber].name, "default-small")

	    guiCreateStaticImage(163+xoffset, 25+yoffset, 48, 14, "images/call.png", false, wHotlines)
	    hotlinesGUI[lineNumber].call = guiCreateButton(163+xoffset, 24+yoffset, 48, 16, "", false, wHotlines)
	    guiSetAlpha(hotlinesGUI[lineNumber].call, 0.3)

		addEventHandler("onClientGUIClick", hotlinesGUI[lineNumber].call, function()
			startDialing(phone, lineNumber)
		end, false)

		guiSetAlpha(guiCreateStaticImage(10+xoffset, 50+yoffset, 200, 1, ":admin-system/images/whitedot.jpg", false, wHotlines), 0.1)
	    yoffset = yoffset + 40 
	    count = count + 1
	end
	if count == 0 then
		guiCreateLabel(0.5, 0.5, 1, 0.5, "It's lonely here..", true, wHotlines)
	end
	return wHotlines
end

function toggleHotlines(state)
	if wHotlines and isElement(wHotlines) then
		guiSetVisible(wHotlines, state)
	else
		if state then
			drawPhoneHotlines()
		end
	end
end
