--MAXIME
local guiStep2 = {}
local quests_p2 = {}
local q2 = {}
function startStep2(questsFromServer)
	triggerEvent("account:hideRules", localPlayer)
	
	if guiStep2.back and isElement(guiStep2.back) then
		showGUIPart(guiStep2)
		return false
	else
		quests_p2 = questsFromServer
	end
	
	local sWidth,sHeight = guiGetScreenSize() 
	
	local line = 15
	local startY = sHeight*0.45
	local width = 800
	local startX = (sWidth-width)/2
	local panelH = 130
	local panelW = width/2
	local margin = 30
	guiStep2.intro2 = guiCreateLabel(startX-1, startY-1, width+1, line*2+1, "Before becoming eligible to play on this server you'll first have to finish a short application which will test your English, general roleplay knowledge & general understanding of the servers rules which you have just previously viewed. (Section 2/2)", false )
	guiLabelSetHorizontalAlign(guiStep2.intro2, "center", true)
	guiLabelSetColor( guiStep2.intro2, 0, 0, 0 )
	guiStep2.intro = guiCreateLabel(startX, startY, width, line*2, "Before becoming eligible to play on this server you'll first have to finish a short application which will test your English, general roleplay knowledge & general understanding of the servers rules which you have just previously viewed. (Section 2/2)", false )
	guiLabelSetHorizontalAlign(guiStep2.intro, "center", true)
	startX = startX-10
	startY = startY+10
	--col 1 row 1
	guiStep2.q1 = guiCreateScrollPane(startX, startY+line*3, panelW, panelH, false )
	guiStep2.q11 = guiCreateLabel(0, 0, panelW, line*2, (quests_p2[1] or "-"), false, guiStep2.q1 )
	guiSetFont(guiStep2.q11, "default-bold-small")
	guiLabelSetHorizontalAlign(guiStep2.q11, "left", true)
	guiLabelSetVerticalAlign(guiStep2.q11, "center", true)
	q2[1] = guiCreateMemo(0, line*2, panelW, line*6, "", false, guiStep2.q1 )
	
	--col 1 row 2
	guiStep2.q2 = guiCreateScrollPane(startX, startY+line*3+panelH, panelW, panelH, false )
	guiStep2.q22 = guiCreateLabel(0, 0, panelW, line*2, (quests_p2[2] or "-"), false, guiStep2.q2 )
	guiSetFont(guiStep2.q22, "default-bold-small")
	guiLabelSetHorizontalAlign(guiStep2.q22, "left", true)
	guiLabelSetVerticalAlign(guiStep2.q22, "center", true)
	q2[2] = guiCreateMemo(0, line*2, panelW, line*6, "", false, guiStep2.q2 )
	
	--col 2 row 1
	guiStep2.q3 = guiCreateScrollPane(startX+panelW+margin, startY+line*3, panelW, panelH, false )
	guiStep2.q33 = guiCreateLabel(0, 0, panelW, line*2, (quests_p2[3] or "-"), false, guiStep2.q3 )
	guiSetFont(guiStep2.q33, "default-bold-small")
	guiLabelSetHorizontalAlign(guiStep2.q33, "left", true)
	guiLabelSetVerticalAlign(guiStep2.q33, "center", true)
	q2[3] = guiCreateMemo(0, line*2, panelW, line*6, "", false, guiStep2.q3 )
	
	--col 2 row 2
	guiStep2.q4 = guiCreateScrollPane(startX+panelW+margin, startY+line*3+panelH, panelW, panelH, false )
	guiStep2.q44 = guiCreateLabel(0, 0, panelW, line*2, (quests_p2[4] or "-"), false, guiStep2.q4 )
	guiSetFont(guiStep2.q44, "default-bold-small")
	guiLabelSetHorizontalAlign(guiStep2.q44, "left", true)
	guiLabelSetVerticalAlign(guiStep2.q44, "center", true)
	q2[4] = guiCreateMemo(0, line*2, panelW, line*6, "", false, guiStep2.q4 )
	
	local bW, bH = 120, 30
	local bX = (sWidth-bW*2)/2
	local bY = startY+line*3+panelH*2
	
	guiStep2.back = guiCreateButton ( bX, bY, bW, bH, "< Server Rules", false)
	guiStep2.next = guiCreateButton ( bX+bW, bY, bW, bH, "Next >", false)

	addEventHandler ( "onClientGUIClick", guiStep2.next, validateApp, false)
	addEventHandler ( "onClientGUIClick", guiStep2.back, function()
		killTimer1()
		hideGUIPart(guiStep2)
		triggerEvent("account:showRules",localPlayer, 1)
	end, false)
	addEventHandler ( "onClientGUIChanged", q2[1], resetNoti, false)
	addEventHandler ( "onClientGUIChanged", q2[2], resetNoti, false)	
	addEventHandler ( "onClientGUIChanged", q2[3], resetNoti, false)
	addEventHandler ( "onClientGUIChanged", q2[4], resetNoti, false)

	for i = 1, 4 do
		addEventHandler( "onClientMouseEnter",guiStep2['q'..i..i], function ()
			guiLabelSetColor( source, 0, 0, 0 )
		end, false )
		addEventHandler("onClientMouseLeave",guiStep2['q'..i..i], function ()
			guiLabelSetColor( source, 255, 255, 255 )
		end, false )
	end
end
addEvent("apps:startStep2", true)
addEventHandler("apps:startStep2", root, startStep2)

function validateApp()
	local quest1 = string.len(guiGetText(q2[1]))
	local quest2 = string.len(guiGetText(q2[2]))
	local quest3 = string.len(guiGetText(q2[3]))
	local quest4 = string.len(guiGetText(q2[4]))
	
	if (quest1>1) and (quest2>1) and (quest3>1) and (quest4>1) then
		guiSetText(guiStep2.intro2, "Sending application to server..\nProcessing application..Please stand by!")
		guiSetText(guiStep2.intro, "Sending application to server..\nProcessing application..Please stand by!")
		guiLabelSetColor(guiStep2.intro, 0,255,0)
		guiSetEnabled(guiStep2.back, false)
		guiSetEnabled(guiStep2.next, false)
		guiSetEnabled(guiStep2.q1, false)
		guiSetEnabled(guiStep2.q2, false)
		guiSetEnabled(guiStep2.q3, false)
		guiSetEnabled(guiStep2.q4, false)
		setTimer(function()
			triggerServerEvent("apps:processPart2", localPlayer, quests_p2, {guiGetText(q2[1]), guiGetText(q2[2]), guiGetText(q2[3]), guiGetText(q2[4])})
			destroyGUIPart2()
		end, 3000, 1)
	else
		guiSetText(guiStep2.intro2, "You didn't answer all the questions.")
		guiSetText(guiStep2.intro, "You didn't answer all the questions.")
		guiLabelSetColor(guiStep2.intro, 255,0,0)
	end
end

function resetNoti()
	if guiStep2.intro and isElement(guiStep2.intro) and guiGetVisible(guiStep2.intro) then
		guiSetText(guiStep2.intro2, "Before becoming eligible to play on this server you'll first have to finish a short application which will test your English, general roleplay knowledge & general understanding of the servers rules which you have just previously viewed. (Section 2/2)")
		guiSetText(guiStep2.intro, "Before becoming eligible to play on this server you'll first have to finish a short application which will test your English, general roleplay knowledge & general understanding of the servers rules which you have just previously viewed. (Section 2/2)")
		guiLabelSetColor(guiStep2.intro, 255,255,255)
	end
end

function destroyGUIPart2()
	for i, gui in pairs (guiStep2) do
		if gui and isElement(gui) then
			destroyElement(gui)
		end
	end
	guiStep2 = {}
end