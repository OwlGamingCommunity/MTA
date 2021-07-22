-- configs
local scriptversion = "0.1"
local author = "anumaz"

local gui ={}
local data = {}
function openRestrictedFreqs(dataFromServer)
	if dataFromServer and type(dataFromServer) == "table" then
		data = dataFromServer
	end
	-- let's have center coordinates
	closeRestrictedFreqs()
	showCursor(true)
	local w, h = 600, 300
	gui.wMain = guiCreateWindow(0,0,w,h,"Restricted Frequency Panel - by "..author.." v"..scriptversion,false)
	exports.global:centerWindow(gui.wMain)

	gui.grid = guiCreateGridList(0,0.08,1,0.8, true, gui.wMain)
	gui.colID = guiGridListAddColumn(gui.grid, "ID", 0.1)
	gui.colFreq = guiGridListAddColumn(gui.grid, "Frequency", 0.3)
	gui.colLimitedto = guiGridListAddColumn(gui.grid, "Limited to", 0.3)
	gui.colAddedby = guiGridListAddColumn(gui.grid, "Added by", 0.2)

	for v, k in pairs(data) do
		gui.row = guiGridListAddRow(gui.grid)
		guiGridListSetItemText(gui.grid, gui.row, gui.colID, k["id"], false, true)
		guiGridListSetItemText(gui.grid, gui.row, gui.colFreq, k["frequency"], false, true)
		guiGridListSetItemText(gui.grid, gui.row, gui.colLimitedto, k["faction"], false, false)
		guiGridListSetItemText(gui.grid, gui.row, gui.colAddedby, k["addedby"], false, false)
	end

	local numberOfButtons = 3
	local btnWidth = 1/numberOfButtons
	local xOffset = 0.01
	gui.newFreq = guiCreateButton(0, 0.88, btnWidth , 0.18, "New", true, gui.wMain)
	addEventHandler("onClientGUIClick", gui.newFreq, function ()
		newFreqWindow()
		exports.global:playSoundSuccess()
	end, false)

	gui.bDelete = guiCreateButton(btnWidth+xOffset, 0.88, btnWidth , 0.18, "Delete", true, gui.wMain)
	addEventHandler("onClientGUIClick", gui.bDelete, function ()
		local row, col = guiGridListGetSelectedItem(gui.grid)
		if row ~= -1 and col ~= -1 then
			local id = guiGridListGetItemText( gui.grid , row, 1 )
			triggerServerEvent("deleteFrequency", localPlayer, localPlayer, nil, id)
			exports.global:playSoundCreate()
			closeRestrictedFreqs()
		else
			exports.global:playSoundError()
			exports.hud:sendBottomNotification(localPlayer, "Restricted Frequency", "Please select an item from the list first.")
		end
	end, false)

	gui.closeButton = guiCreateButton(btnWidth*2+xOffset, 0.88, btnWidth , 0.18, "Close", true, gui.wMain)
	addEventHandler("onClientGUIClick", gui.closeButton, function ()
		if source == gui.closeButton then
			closeRestrictedFreqs()
		end
	end, false)
end
addEvent("openRestrictedFreqs", true)
addEventHandler("openRestrictedFreqs", root, openRestrictedFreqs)

function closeRestrictedFreqs()
	if gui.wMain and isElement(gui.wMain) then
		destroyElement(gui.wMain)
		gui.wMain = nil
		showCursor(false)
		closeNewFreqWindow()
	end
end

function newFreqWindow()
	closeNewFreqWindow()
	closeRestrictedFreqs()
	showCursor(true)
	guiSetInputEnabled(true)
	local w, h = 300, 120
	gui.newFreq = guiCreateWindow(0,0,w,h,"Add a new frequency",false)
	exports.global:centerWindow(gui.newFreq)

	local yOffset = 10
	local lineH = 30
	local margin = 10
	local col1W = 70
	local col2W = w-col1W
	gui.lText1 = guiCreateLabel(margin, margin+yOffset, col1W, lineH, "Freq: ", false, gui.newFreq)
	guiLabelSetVerticalAlign(gui.lText1, "center", true)
	gui.inputFreq = guiCreateEdit(col1W, margin+yOffset, col2W, lineH, "", false, gui.newFreq)

	gui.lText2 = guiCreateLabel(margin, margin+yOffset+lineH, col1W, lineH, "Limited to: ", false, gui.newFreq)
	guiLabelSetVerticalAlign(gui.lText2, "center", true)
	gui.inputLimitedto = guiCreateEdit(col1W, margin+yOffset+lineH, col2W, lineH, "", false, gui.newFreq)

	local numberOfButtons = 2
	local btnWidth = (w-margin*2)/numberOfButtons
	local xOffset = 0.01
	gui.addNewFreq = guiCreateButton(margin, margin+yOffset+lineH*2, btnWidth, 35, "Add", false, gui.newFreq)
	addEventHandler("onClientGUIClick", gui.addNewFreq, function()
		if source == gui.addNewFreq then
			local freq = guiGetText(gui.inputFreq)
			local faction = guiGetText(gui.inputLimitedto)
			if string.len(freq) < 1 or string.len(faction) < 1 or not tonumber(faction) then	
				exports.global:playSoundError()
				exports.hud:sendBottomNotification(localPlayer, "Restricted Frequency", "Either the frequency or faction field is empty.")
			else
				--addNewFrequency(thePlayer, commandName, freq, factionID)
				triggerServerEvent("addNewFrequency", localPlayer, localPlayer, nil, freq, faction)
				exports.global:playSoundCreate()
				closeNewFreqWindow()
			end

		end
	end, false)

	gui.closeNewWindow = guiCreateButton(margin+btnWidth, margin+yOffset+lineH*2, btnWidth, 35, "Close", false, gui.newFreq)
	addEventHandler("onClientGUIClick", gui.closeNewWindow, function()
		if source == gui.closeNewWindow then
			closeNewFreqWindow()
		end
	end, false)
end

function closeNewFreqWindow()
	if gui.newFreq and isElement(gui.newFreq) then
		destroyElement(gui.newFreq)
		openRestrictedFreqs()
		gui.newFreq = nil
		showCursor(false)
		guiSetInputEnabled(false)
	end
end