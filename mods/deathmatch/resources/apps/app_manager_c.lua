--MAXIME
local gui1 = {}
local gui2 = {}
local gui3 = {}
local screenWidth, screenHeight = guiGetScreenSize()
local apps = {}
local quests = {}
local part = 1
function openAppsWindow(apps1, quests1)
	if not (exports.integration:isPlayerTrialAdmin(localPlayer) or exports.integration:isPlayerSupporter(localPlayer)) then
		return false
	end

	showCursor(true)
	guiSetInputEnabled(true)
	if type(apps1) == "table" then
		apps = apps1
		quests = quests1
	end
	if gui1.main and isElement(gui1.main) then
		guiSetText(gui1.main, "OwlGaming Application Manager")
		guiSetEnabled(gui1.main, true)
	else
		triggerEvent( 'hud:blur', resourceRoot, 6, false, 0.5, nil )
		local w, h = 740,474
		local x, y = (screenWidth-w)/2, (screenHeight-h)/2
		gui1.main = guiCreateWindow(x,y,w,h,"OwlGaming Application Manager | LOADING..",false)
		guiWindowSetSizable(gui1.main, false)

		gui1.tabPanel = guiCreateTabPanel(0.0122,0.0401,0.9757,0.87,true,gui1.main)

		gui1.tab_pendingApps = guiCreateTab("Pending",gui1.tabPanel)
		gui1.grid_pendingApps = guiCreateGridList(0,0,1,1,true,gui1.tab_pendingApps)
		gui1.grid_pendingApps_col_id = guiGridListAddColumn(gui1.grid_pendingApps,"Application ID",0.1)
		gui1.grid_pendingApps_col_applicant = guiGridListAddColumn(gui1.grid_pendingApps,"Applicant Name",0.2)
		gui1.grid_pendingApps_col_postDate = guiGridListAddColumn(gui1.grid_pendingApps,"Posted Date",0.2)
		gui1.grid_pendingApps_col_reviewer = guiGridListAddColumn(gui1.grid_pendingApps,"Reviewer",0.2)
		gui1.grid_pendingApps_col_reviewedDate = guiGridListAddColumn(gui1.grid_pendingApps,"Reviewed Date",0.2)

		gui1.tab_acceptedApps = guiCreateTab("Accepted",gui1.tabPanel)
		gui1.grid_acceptedApps = guiCreateGridList(0,0,1,1,true,gui1.tab_acceptedApps)
		gui1.grid_acceptedApps_col_id = guiGridListAddColumn(gui1.grid_acceptedApps,"Application ID",0.1)
		gui1.grid_acceptedApps_col_applicant = guiGridListAddColumn(gui1.grid_acceptedApps,"Applicant Name",0.2)
		gui1.grid_acceptedApps_col_postDate = guiGridListAddColumn(gui1.grid_acceptedApps,"Posted Date",0.2)
		gui1.grid_acceptedApps_col_reviewer = guiGridListAddColumn(gui1.grid_acceptedApps,"Reviewer",0.2)
		gui1.grid_acceptedApps_col_reviewedDate = guiGridListAddColumn(gui1.grid_acceptedApps,"Reviewed Date",0.2)

		gui1.tab_deniedApps = guiCreateTab("Declined",gui1.tabPanel)
		gui1.grid_deniedApps = guiCreateGridList(0,0,1,1,true,gui1.tab_deniedApps)
		gui1.grid_deniedApps_col_id = guiGridListAddColumn(gui1.grid_deniedApps,"Application ID",0.1)
		gui1.grid_deniedApps_col_applicant = guiGridListAddColumn(gui1.grid_deniedApps,"Applicant Name",0.2)
		gui1.grid_deniedApps_col_postDate = guiGridListAddColumn(gui1.grid_deniedApps,"Posted Date",0.2)
		gui1.grid_deniedApps_col_reviewer = guiGridListAddColumn(gui1.grid_deniedApps,"Reviewer",0.2)
		gui1.grid_deniedApps_col_reviewedDate = guiGridListAddColumn(gui1.grid_deniedApps,"Reviewed Date",0.2)

		gui1.tab_appPart1 = guiCreateTab("Application - Part 1",gui1.tabPanel)
		gui1.grid_appPart1 = guiCreateGridList(0,0,1,1,true,gui1.tab_appPart1)
		gui1.grid_appPart1_col_id = guiGridListAddColumn(gui1.grid_appPart1,"ID",0.05)
		gui1.grid_appPart1_col_question = guiGridListAddColumn(gui1.grid_appPart1,"Question",0.36)
		gui1.grid_appPart1_col_updatedBy = guiGridListAddColumn(gui1.grid_appPart1,"Updated by",0.1)
		gui1.grid_appPart1_col_updateDate = guiGridListAddColumn(gui1.grid_appPart1,"Update date",0.18)
		gui1.grid_appPart1_col_createdBy = guiGridListAddColumn(gui1.grid_appPart1,"Created by",0.1)
		gui1.grid_appPart1_col_createDate = guiGridListAddColumn(gui1.grid_appPart1,"Create date",0.18)

		gui1.tab_appPart2 = guiCreateTab("Application - Part 2",gui1.tabPanel)
		gui1.grid_appPart2 = guiCreateGridList(0,0,1,1,true,gui1.tab_appPart2)
		gui1.grid_appPart2_col_id = guiGridListAddColumn(gui1.grid_appPart2,"ID",0.05)
		gui1.grid_appPart2_col_question = guiGridListAddColumn(gui1.grid_appPart2,"Question",0.36)
		gui1.grid_appPart2_col_updatedBy = guiGridListAddColumn(gui1.grid_appPart2,"Updated by",0.1)
		gui1.grid_appPart2_col_updateDate = guiGridListAddColumn(gui1.grid_appPart2,"Update date",0.18)
		gui1.grid_appPart2_col_createdBy = guiGridListAddColumn(gui1.grid_appPart2,"Created by",0.1)
		gui1.grid_appPart2_col_createDate = guiGridListAddColumn(gui1.grid_appPart2,"Create date",0.18)

		gui1.refresh = guiCreateButton(0.0135,0.9135,0.48715,0.0675,"Refresh",true,gui1.main)

		gui1.part1CreateNew = guiCreateButton(0.0135,0.9135,0.48715,0.0675,"Create New Question",true,gui1.main)
		guiSetVisible(gui1.part1CreateNew, false)
		gui1.part2CreateNew = guiCreateButton(0.0135,0.9135,0.48715,0.0675,"Create New Question",true,gui1.main)
		guiSetVisible(gui1.part2CreateNew, false)

		gui1.bClose = guiCreateButton(0.0135+0.48715,0.9135,0.48715,0.0675,"Close",true,gui1.main)
		addEventHandler("onClientGUIClick", getResourceRootElement(getThisResource()), function()
			if source == gui1.bClose then
				closeAppsWindow()
			elseif source == gui1.refresh then
				triggerServerEvent("apps:openAppsWindow", localPlayer)
			elseif source == gui1.part1CreateNew then
				openQuestionDetail(1, true)
			elseif source == gui1.part2CreateNew then
				openQuestionDetail(2, true)
			end

			if gui1.tabPanel and isElement(gui1.tabPanel) and gui1.tab_appPart1 and isElement(gui1.tab_appPart1) and gui1.tab_appPart2 and isElement(gui1.tab_appPart2) then
				if guiGetSelectedTab(gui1.tabPanel) == gui1.tab_appPart1 then
					if gui1.refresh and isElement(gui1.refresh) then
						guiSetVisible(gui1.refresh, false)
						guiSetVisible(gui1.part2CreateNew, false)
					end
					if gui1.part1CreateNew and isElement(gui1.part1CreateNew) then
						guiSetVisible(gui1.part1CreateNew, true)
					end
				elseif guiGetSelectedTab(gui1.tabPanel) == gui1.tab_appPart2 then
					if gui1.refresh and isElement(gui1.refresh) then
						guiSetVisible(gui1.refresh, false)
						guiSetVisible(gui1.part1CreateNew, false)
					end
					if gui1.part1CreateNew and isElement(gui1.part1CreateNew) then
						guiSetVisible(gui1.part2CreateNew, true)
					end
				else
					if gui1.refresh and isElement(gui1.refresh) then
						guiSetVisible(gui1.refresh, true)
					end
					if gui1.part1CreateNew and isElement(gui1.part1CreateNew) then
						guiSetVisible(gui1.part1CreateNew, false)
						guiSetVisible(gui1.part2CreateNew, false)
					end
				end
			end
		end)
		triggerServerEvent("apps:openAppsWindow", localPlayer)
		guiSetEnabled(gui1.main, false)

		addEventHandler( "onClientGUIDoubleClick", gui1.grid_appPart1,
			function( button , state)
				if source==gui1.grid_appPart1 and button == "left" and state == "up" then
					local row, col = -1, -1
					local row, col = guiGridListGetSelectedItem(gui1.grid_appPart1)
					if row ~= -1 and col ~= -1 then
						local id = guiGridListGetItemText( gui1.grid_appPart1 , row, 1 )
						openQuestionDetail(1, false)
						triggerServerEvent("apps:openQuestionDetail", localPlayer, id, 1)
						playSuccess()
					end
				end
			end,
		false)

		addEventHandler( "onClientGUIDoubleClick", gui1.grid_appPart2,
			function( button, state )
				if source==gui1.grid_appPart2 and button == "left" and state == "up" then
					local row, col = -1, -1
					local row, col = guiGridListGetSelectedItem(gui1.grid_appPart2)
					if row ~= -1 and col ~= -1 then
						local id = guiGridListGetItemText( gui1.grid_appPart2 , row, 1 )
						openQuestionDetail(2, false)
						triggerServerEvent("apps:openQuestionDetail", localPlayer, id, 2)
						playSuccess()
					end
				end
			end,
		false)

		addEventHandler( "onClientGUIDoubleClick", gui1.grid_pendingApps,
			function( button, state )
				if button == "left" and source == gui1.grid_pendingApps and state == "up" then
					local row, col = -1, -1
					local row, col = guiGridListGetSelectedItem(gui1.grid_pendingApps)
					if row ~= -1 and col ~= -1 then
						local id = guiGridListGetItemText( gui1.grid_pendingApps , row, 1 )
						triggerServerEvent("apps:openAppDetail", localPlayer, id)
					end
				end
			end,
		false)

		addEventHandler( "onClientGUIDoubleClick", gui1.grid_acceptedApps,
			function( button, state )
				if button == "left" and source == gui1.grid_acceptedApps and state == "up" then
					local row, col = -1, -1
					local row, col = guiGridListGetSelectedItem(gui1.grid_acceptedApps)
					if row ~= -1 and col ~= -1 then
						local id = guiGridListGetItemText( gui1.grid_acceptedApps , row, 1 )
						if triggerServerEvent("apps:openAppDetail", localPlayer, id, true) then

						end
					end
				end
			end,
		false)

		addEventHandler( "onClientGUIDoubleClick", gui1.grid_deniedApps,
			function( button, state )
				if button == "left" and source == gui1.grid_deniedApps and state == "up" then
					local row, col = -1, -1
					local row, col = guiGridListGetSelectedItem(gui1.grid_deniedApps)
					if row ~= -1 and col ~= -1 then
						local id = guiGridListGetItemText( gui1.grid_deniedApps , row, 1 )
						triggerServerEvent("apps:openAppDetail", localPlayer, id, true)
					end
				end
			end,
		false)
	end

	updateQuests()
	updateApps()


end
addCommandHandler("apps",openAppsWindow )
addCommandHandler("applications",openAppsWindow)
addEvent("apps:openAppsWindow", true)
addEventHandler("apps:openAppsWindow", getRootElement(), openAppsWindow)

function updateQuests()
	guiGridListClear(gui1.grid_appPart1)
	guiGridListClear(gui1.grid_appPart2)
	for i = 1, #quests do
		if quests[i]["part"] == "1" then
			local row = guiGridListAddRow(gui1.grid_appPart1)
			guiGridListSetItemText(gui1.grid_appPart1, row, gui1.grid_appPart1_col_id,( quests[i]["id"] ), false, true)
			guiGridListSetItemText(gui1.grid_appPart1, row, gui1.grid_appPart1_col_question,( quests[i]["question"] or "-" ), false, false)
			guiGridListSetItemText(gui1.grid_appPart1, row, gui1.grid_appPart1_col_updatedBy,( quests[i]["updatedBy"] or "-" ), false, false)
			guiGridListSetItemText(gui1.grid_appPart1, row, gui1.grid_appPart1_col_updateDate,( quests[i]["updateDate"] or "-" ), false, false)
			guiGridListSetItemText(gui1.grid_appPart1, row, gui1.grid_appPart1_col_createdBy,( quests[i]["createdBy"] or "-" ), false, false)
			guiGridListSetItemText(gui1.grid_appPart1, row, gui1.grid_appPart1_col_createDate,( quests[i]["createDate"] or "-" ), false, false)
		else
			local row = guiGridListAddRow(gui1.grid_appPart2)
			guiGridListSetItemText(gui1.grid_appPart2, row, gui1.grid_appPart2_col_id,( quests[i]["id"] ), false, true)
			guiGridListSetItemText(gui1.grid_appPart2, row, gui1.grid_appPart2_col_question,( quests[i]["question"] or "-" ), false, false)
			guiGridListSetItemText(gui1.grid_appPart2, row, gui1.grid_appPart2_col_updatedBy,( quests[i]["updatedBy"] or "-" ), false, false)
			guiGridListSetItemText(gui1.grid_appPart2, row, gui1.grid_appPart2_col_updateDate,( quests[i]["updateDate"] or "-" ), false, false)
			guiGridListSetItemText(gui1.grid_appPart2, row, gui1.grid_appPart2_col_createdBy,( quests[i]["createdBy"] or "-" ), false, false)
			guiGridListSetItemText(gui1.grid_appPart2, row, gui1.grid_appPart2_col_createDate,( quests[i]["createDate"] or "-" ), false, false)
		end
	end

	--stuff
end

--

local function updateButton(  )
	if exports.integration:isPlayerSupporter(localPlayer) or exports.integration:isPlayerTrialAdmin(localPlayer) then

		count = getElementData(getResourceRootElement(), "apps:number")

		if count > 0 then
			if not appsbutton then
				local screenWidth, screenHeight = guiGetScreenSize()
				appsbutton = guiCreateButton( screenWidth-40, screenHeight-90, 30, 30, tostring( count ), false )
					addEventHandler( "onClientGUIClick", appsbutton,
						function( )
							openAppsWindow()
						end, false
					)
				guiSetAlpha( appsbutton, 0.80 )
			else
				guiSetText( appsbutton, tostring( count ) )
			end
		else
			if appsbutton then
				destroyElement( appsbutton )
				appsbutton = nil
			end
		end

	else
		if appsbutton then
			destroyElement( appsbutton )
			appsbutton = nil
		end
	end
end

addEventHandler( "onClientResourceStart", getResourceRootElement(), updateButton)
addEventHandler( "onClientElementDataChange", getResourceRootElement( ), updateButton )
addEventHandler( "onClientElementDataChange", localPlayer,
	function(n)
		if n=="duty_supporter" or n=="duty_admin" then
			updateButton()
		end
	end, false
)

--

function updateApps()
	guiGridListClear(gui1.grid_pendingApps)
	guiGridListClear(gui1.grid_acceptedApps)
	guiGridListClear(gui1.grid_deniedApps)
	for i = 1, #apps do
		if apps[i]["state"] == "0" then
			local row = guiGridListAddRow(gui1.grid_pendingApps)
			guiGridListSetItemText(gui1.grid_pendingApps, row, gui1.grid_pendingApps_col_id,( apps[i]["id"] ), false, true)
			guiGridListSetItemText(gui1.grid_pendingApps, row, gui1.grid_pendingApps_col_applicant,( apps[i]["username"] or "-" ), false, false)
			guiGridListSetItemText(gui1.grid_pendingApps, row, gui1.grid_pendingApps_col_postDate,( apps[i]["dateposted"] or "-" ), false, false)
			guiGridListSetItemText(gui1.grid_pendingApps, row, gui1.grid_pendingApps_col_reviewer,( apps[i]["reviewer"] or "No-one" ), false, false)
			guiGridListSetItemText(gui1.grid_pendingApps, row, gui1.grid_pendingApps_col_reviewedDate,( apps[i]["datereviewed"] or "Never" ), false, false)
		elseif apps[i]["state"] == "1" then
			local row = guiGridListAddRow(gui1.grid_acceptedApps)
			guiGridListSetItemText(gui1.grid_acceptedApps, row, gui1.grid_acceptedApps_col_id,( apps[i]["id"] ), false, true)
			guiGridListSetItemText(gui1.grid_acceptedApps, row, gui1.grid_acceptedApps_col_applicant,( apps[i]["username"] or "-" ), false, false)
			guiGridListSetItemText(gui1.grid_acceptedApps, row, gui1.grid_acceptedApps_col_postDate,( apps[i]["dateposted"] or "-" ), false, false)
			guiGridListSetItemText(gui1.grid_acceptedApps, row, gui1.grid_acceptedApps_col_reviewer,( apps[i]["reviewer"] or "No-one" ), false, false)
			guiGridListSetItemText(gui1.grid_acceptedApps, row, gui1.grid_acceptedApps_col_reviewedDate,( apps[i]["datereviewed"] or "Never" ), false, false)
		elseif apps[i]["state"] == "2" then
			local row = guiGridListAddRow(gui1.grid_deniedApps)
			guiGridListSetItemText(gui1.grid_deniedApps, row, gui1.grid_deniedApps_col_id,( apps[i]["id"] ), false, true)
			guiGridListSetItemText(gui1.grid_deniedApps, row, gui1.grid_deniedApps_col_applicant,( apps[i]["username"] or "-" ), false, false)
			guiGridListSetItemText(gui1.grid_deniedApps, row, gui1.grid_deniedApps_col_postDate,( apps[i]["dateposted"] or "-" ), false, false)
			guiGridListSetItemText(gui1.grid_deniedApps, row, gui1.grid_deniedApps_col_reviewer, ( apps[i]["reviewer"] or "No-one" ), false, false) --
			guiGridListSetItemText(gui1.grid_deniedApps, row, gui1.grid_deniedApps_col_reviewedDate,( apps[i]["datereviewed"] or "Never" ), false, false)
		end
	end

	--stuff
end

function openAppDetail(appData, readOnly)

	if appData then
		playSuccess()
		showCursor(true)
		guiSetInputEnabled(true)
		closeAppDetail()
		if gui1.main and isElement(gui1.main) then
			guiSetEnabled(gui1.main, false)
		end
		local w, h = 740,515
		local x, y = (screenWidth-w)/2, (screenHeight-h)/2
		gui3.main = guiCreateWindow(x,y,w,h,"Review "..appData.username.."'s Application ID#"..appData.id,false)
		guiWindowSetSizable(gui3.main, false)
		local line = 15
		local margin = 20
		local panelH = 165
		local panelW = w/2-(margin*2)
		local yOffset = 0

		--col 1 row 1
		gui3.q1 = guiCreateScrollPane(margin, margin+yOffset, panelW, panelH, false, gui3.main )
		gui3.q11 = guiCreateLabel(0, 0, panelW, line*3, (appData.question1 or "-"), false, gui3.q1 )
		guiSetFont(gui3.q11, "default-bold-small")
		guiLabelSetHorizontalAlign(gui3.q11, "left", true)
		guiLabelSetVerticalAlign(gui3.q11, "center", true)
		gui3.m1 = guiCreateMemo(0, line*3, panelW, line*8, (appData.answer1 or "-"), false, gui3.q1 )
		guiMemoSetReadOnly(gui3.m1, true)

		--col 1 row 2
		gui3.q2 = guiCreateScrollPane(margin, margin+yOffset+panelH, panelW, panelH, false, gui3.main )
		gui3.q22 = guiCreateLabel(0, 0, panelW, line*3, (appData.question2 or "-"), false, gui3.q2 )
		guiSetFont(gui3.q22, "default-bold-small")
		guiLabelSetHorizontalAlign(gui3.q22, "left", true)
		guiLabelSetVerticalAlign(gui3.q22, "center", true)
		gui3.m2 = guiCreateMemo(0, line*3, panelW, line*8, (appData.answer2 or "-"), false, gui3.q2 )
		guiMemoSetReadOnly(gui3.m2, true)

		--col 2 row 1
		gui3.q1 = guiCreateScrollPane(margin*2+panelW, margin+yOffset, panelW, panelH, false, gui3.main )
		gui3.q11 = guiCreateLabel(0, 0, panelW, line*3, (appData.question3 or "-"), false, gui3.q1 )
		guiSetFont(gui3.q11, "default-bold-small")
		guiLabelSetHorizontalAlign(gui3.q11, "left", true)
		guiLabelSetVerticalAlign(gui3.q11, "center", true)
		gui3.m1 = guiCreateMemo(0, line*3, panelW, line*8, (appData.answer3 or "-"), false, gui3.q1 )
		guiMemoSetReadOnly(gui3.m1, true)

		--col 2 row 2
		gui3.q2 = guiCreateScrollPane(margin*2+panelW, margin+yOffset+panelH, panelW, panelH, false, gui3.main )
		gui3.q22 = guiCreateLabel(0, 0, panelW, line*3, (appData.question4 or "-"), false, gui3.q2 )
		guiSetFont(gui3.q22, "default-bold-small")
		guiLabelSetHorizontalAlign(gui3.q22, "left", true)
		guiLabelSetVerticalAlign(gui3.q22, "center", true)
		gui3.m2 = guiCreateMemo(0, line*3, panelW, line*8, (appData.answer4 or "-"), false, gui3.q2 )
		guiMemoSetReadOnly(gui3.m2, true)

		guiCreateStaticImage(margin/2,margin+15+yOffset+panelH*2,w-margin,1,":admin-system/images/whitedot.jpg",false,gui3.main)

		--Meta data
		gui3.meta1 = guiCreateLabel(margin, margin+20+yOffset+panelH*2, panelW, line, "Applicant Name: "..(appData.username or "-"), false, gui3.main )
		guiSetFont(gui3.meta1, "default-bold-small")
		local status = "Pending"
		if appData.state == "1" then
			status = "Accepted"
		elseif appData.state == "2" then
			status = "Declined"
		end
		gui3.text = guiCreateLabel(margin, margin+20+line+yOffset+panelH*2, panelW, line, "Status : "..(status), false, gui3.main )
		guiSetFont(gui3.text, "default-bold-small")
		gui3.text = guiCreateLabel(margin+panelW+margin, margin+20+yOffset+panelH*2, panelW, line, "Posted Date: "..(appData.dateposted or "-"), false, gui3.main )
		guiSetFont(gui3.text, "default-bold-small")
		gui3.text = guiCreateLabel(margin+panelW+margin, margin+20+line+yOffset+panelH*2, panelW, line, "Reviewed Date: "..(appData.datereviewed or "Never"), false, gui3.main )
		guiSetFont(gui3.text, "default-bold-small")
		gui3.text = guiCreateLabel(margin+panelW+margin, margin+20+line*2+yOffset+panelH*2, panelW, line, "Reviewer: "..(appData.reviewer or "No-one"), false, gui3.main )
		guiSetFont(gui3.text, "default-bold-small")
		gui3.text = guiCreateLabel(margin, margin+20+line*2+yOffset+panelH*2, panelW, line, "Note (Reason to accept/decline):", false, gui3.main)
		guiSetFont(gui3.text, "default-bold-small")

		gui3.note = guiCreateMemo(margin, margin+25+line*3+yOffset+panelH*2, w-(margin*2), line*3, (appData.note or ""), false, gui3.main )
		if readOnly then
			guiMemoSetReadOnly(gui3.note, true)
		end
		local buttonW = (w-(margin*2))/3

		gui3.bAccept = guiCreateButton(margin,margin+25+line*7+yOffset+panelH*2,buttonW,30,"Accept",false,gui3.main)
		addEventHandler("onClientGUIClick",gui3.bAccept , function()
			openConfirmBox(tonumber(appData.id), tonumber(appData.applicant), appData.username, 1, guiGetText(gui3.note))
		end, false)

		gui3.bDecline = guiCreateButton(margin+buttonW,margin+25+line*7+yOffset+panelH*2,buttonW,30,"Decline",false,gui3.main)
		addEventHandler("onClientGUIClick",gui3.bDecline , function()
			openConfirmBox(tonumber(appData.id), tonumber(appData.applicant), appData.username, 2, guiGetText(gui3.note))
		end, false)

		guiSetEnabled(gui3.bAccept, false)
		guiSetEnabled(gui3.bDecline, false)
		gui3.bClose = guiCreateButton(margin+buttonW*2,margin+25+line*7+yOffset+panelH*2,buttonW,30,"Close",false,gui3.main)
		addEventHandler("onClientGUIClick",gui3.bClose , function()
			triggerServerEvent("apps:closeAppDetail", localPlayer, tonumber(appData.id))
		end, false)
		if not readOnly then
			addEventHandler("onClientGUIChanged",gui3.note , validateReason, false)
		end
	end
end
addEvent("apps:openAppDetail", true)
addEventHandler("apps:openAppDetail", root, openAppDetail)

local GUIEditor_Window = {}
local GUIEditor_Label = {}
local GUIEditor_Button = {}
function openConfirmBox(id, applicant, username, num, text34 )
	closeConfirmDelete()
	if gui3.main and isElement(gui3.main) then
		guiSetEnabled(gui3.main, false)
	end
	local w, h = 394,111
	local sx, sy = guiGetScreenSize()
	GUIEditor_Window[3] = guiCreateWindow((sx-w)/2,(sy-h)/2,w,h,"",false)
	guiWindowSetSizable(GUIEditor_Window[3],false)
	guiSetProperty(GUIEditor_Window[3],"AlwaysOnTop","true")
	guiSetProperty(GUIEditor_Window[3],"TitlebarEnabled","false")
	GUIEditor_Label[8] = guiCreateLabel(0.0254,0.2072,0.9645,0.1982,"You are about to "..(num == 1 and "ACCEPT" or "DECLINE").." "..username.."'s application.",true,GUIEditor_Window[3])
	guiLabelSetHorizontalAlign(GUIEditor_Label[8],"center",false)
	GUIEditor_Label[9] = guiCreateLabel(0.0254,0.4054,0.9492,0.2162,"This action can't be undone!",true,GUIEditor_Window[3])
	guiLabelSetHorizontalAlign(GUIEditor_Label[9],"center",false)
	GUIEditor_Button[10] = guiCreateButton(0.0254,0.6577,0.4695,0.2613,"Cancel",true,GUIEditor_Window[3])
	addEventHandler( "onClientGUIClick", GUIEditor_Button[10], function()
		if source == GUIEditor_Button[10] then
			closeConfirmDelete()
		end
	end)
	GUIEditor_Button[11] = guiCreateButton(0.5051,0.6577,0.4695,0.2613,"Confirm",true,GUIEditor_Window[3])
	addEventHandler( "onClientGUIClick", GUIEditor_Button[11], function()
		if source == GUIEditor_Button[11] then
			closeConfirmDelete(true)
			exports.global:playSoundSuccess()
			triggerServerEvent("apps:updateAppState", localPlayer, tonumber(id), tonumber(applicant), username, num, text34)
		end
	end)

end

function closeConfirmDelete(keepLock)
	if GUIEditor_Window[3] then
		destroyElement(GUIEditor_Window[3])
		GUIEditor_Window[3] = nil
		if not keepLock and gui3.main and isElement(gui3.main) then
			guiSetEnabled(gui3.main, true)
		end
	end
end

function validateReason()
	if source == gui3.note then
		if string.len(guiGetText(gui3.note)) > 1 then
			guiSetEnabled(gui3.bAccept, true)
			guiSetEnabled(gui3.bDecline, true)
		else
			guiSetEnabled(gui3.bAccept, false)
			guiSetEnabled(gui3.bDecline, false)
		end
	end
end

function closeAppDetail()
	if gui3.main and isElement(gui3.main) then
		destroyElement(gui3.main)
		gui3 = {}
	end
	if gui1.main and isElement(gui1.main) then
		guiSetEnabled(gui1.main, true)
	end
end
addEvent("apps:closeAppDetail", true)
addEventHandler("apps:closeAppDetail", root, closeAppDetail)

local questionID = false
function openQuestionDetail(part1, createNew, fromServer, data)
	part = part1
	--outputDebugString(part)
	if gui1.main and isElement(gui1.main) then
		guiSetEnabled(gui1.main, false)
	end

	if createNew then
		questionID = false
	else
		if data and data.id then
			questionID = data.id
		end
	end

	if gui2.main and isElement(gui2.main) then

	else
		local length = 180
		local line = 20
		if part == 2 then
			length = 0
		end
		local windowWidth, windowHeight = 450, 190+length

		local left = screenWidth/2 - windowWidth/2
		local top = screenHeight/2 - windowHeight/2
		local loadingText = "Retrieving data from server. Please wait.."
		if createNew then
			loadingText = ""
		end


		gui2.main = guiCreateStaticImage(left, top, windowWidth, windowHeight, ":resources/window_body.png", false)

		gui2.lQuestion = guiCreateLabel(20, 25, windowWidth-40, line, "Question:", false, gui2.main)
		gui2.eQuestion = guiCreateEdit(20, 25+line, windowWidth-40, line*2, loadingText, false, gui2.main)
		guiEditSetMaxLength(gui2.eQuestion, ((part == 1) and 70 or 140))

		if part == 1 then
			gui2.rAns1 = guiCreateRadioButton(20, 30+line*4, windowWidth-40, line, "Choice 1:", false, gui2.main)
			gui2.eAns1 = guiCreateEdit(20, 30+line*5, windowWidth-40, line*2, loadingText, false, gui2.main)
			guiEditSetMaxLength(gui2.eAns1, 65)
			guiRadioButtonSetSelected(gui2.rAns1, true)

			gui2.rAns2 = guiCreateRadioButton(20, 30+line*7, windowWidth-40, line, "Choice 2:", false, gui2.main)
			gui2.eAns2 = guiCreateEdit(20, 30+line*8, windowWidth-40, line*2, loadingText, false, gui2.main)
			guiEditSetMaxLength(gui2.eAns2, 65)

			gui2.rAns3 = guiCreateRadioButton(20, 30+line*10, windowWidth-40, line, "Choice 3:", false, gui2.main)
			gui2.eAns3 = guiCreateEdit(20, 30+line*11, windowWidth-40, line*2, loadingText, false, gui2.main)
			guiEditSetMaxLength(gui2.eAns3, 65)
		end

		gui2["confirm"] = guiCreateButton(20, 130+length, windowWidth/3-20, 40, "Save", false, gui2.main)
		addEventHandler( "onClientGUIClick", gui2["confirm"], function()
			if source == gui2["confirm"] then
				if part == 1 then
					local key = 1
					if guiRadioButtonGetSelected(gui2.rAns3) then
						key = 3
					elseif guiRadioButtonGetSelected(gui2.rAns2) then
						key = 2
					else
						key = 1
					end
					triggerServerEvent("apps:saveQuestion", localPlayer, 1, questionID, guiGetText(gui2.eQuestion), key, guiGetText(gui2.eAns1), guiGetText(gui2.eAns2), guiGetText(gui2.eAns3))
				else
					triggerServerEvent("apps:saveQuestion", localPlayer, 2, questionID, guiGetText(gui2.eQuestion))
				end
				playSoundCreate()
				closeQuestionDetail()
			end
		end)
		guiSetEnabled(gui2["confirm"], false)

		gui2["delete"] = guiCreateButton(windowWidth/3, 130+length, windowWidth/3, 40, "Delete", false, gui2.main)
		addEventHandler( "onClientGUIClick", gui2["delete"], function()
			if source == gui2["delete"] then
				triggerServerEvent("apps:deleteQuestion", localPlayer, questionID, part)
				playSoundCreate()
				closeQuestionDetail()
			end
		end)
		if createNew then
			guiSetEnabled(gui2["delete"], false)
		else
			guiSetEnabled(gui2["delete"], true)
		end

		gui2["btnCancel"] = guiCreateButton((windowWidth/3)*2, 130+length, windowWidth/3-20, 40, "Cancel", false, gui2.main)
		addEventHandler( "onClientGUIClick", gui2["btnCancel"], function()
			if source == gui2["btnCancel"] then
				closeQuestionDetail()
			end
		end)

		addEventHandler("onClientGUIChanged", getResourceRootElement(getThisResource()), function()
			if part == 1 then
				if guiGetText(gui2.eQuestion) == "" or guiGetText(gui2.eAns1) == "" or guiGetText(gui2.eAns2) == "" or guiGetText(gui2.eAns3) == "" then
					guiSetEnabled(gui2["confirm"], false)
				else
					guiSetEnabled(gui2["confirm"], true)
				end
			else
				if guiGetText(gui2.eQuestion) == "" then
					guiSetEnabled(gui2["confirm"], false)
				else
					guiSetEnabled(gui2["confirm"], true)
				end
			end
		end)
	end
	if fromServer then
		guiSetText(gui2.eQuestion, data.question or "-")
		if part == 1 then
			guiSetText(gui2.eAns1, data.answer1 or "-")
			guiSetText(gui2.eAns2, data.answer2 or "-")
			guiSetText(gui2.eAns3, data.answer3 or "-")
			if data.key == "2" then
				guiRadioButtonSetSelected(gui2.rAns2, true)
			elseif data.key == "3" then
				guiRadioButtonSetSelected(gui2.rAns3, true)
			else
				guiRadioButtonSetSelected(gui2.rAns1, true)
			end
		end
		guiSetEnabled(gui2.main, true)
	else
		if createNew then
			guiSetEnabled(gui2.main, true)
		else
			guiSetEnabled(gui2.main, false)
		end
	end
end
addEvent("apps:openQuestionDetail", true)
addEventHandler("apps:openQuestionDetail", getRootElement(), openQuestionDetail)

function closeQuestionDetail()
	if gui2.main and isElement(gui2.main) then
		destroyElement(gui2.main)
		gui2 = {}
	end
	if gui1.main and isElement(gui1.main) then
		guiSetEnabled(gui1.main, true)
	end
end

function closeAppsWindow()
	if gui1.main and isElement(gui1.main) then
		destroyElement(gui1.main)
		gui1 = {}
		triggerEvent( 'hud:blur', resourceRoot, 'off' )
	end
	closeQuestionDetail()
	closeAppDetail()
	showCursor(false)
	guiSetInputEnabled(false)
end

function bindIt()
	bindKey ( "F7" , "down", "apps" )
end
addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()), bindIt)

function playError()
	playSoundFrontEnd(4)
end

function playSuccess()
	playSoundFrontEnd(13)
end

function playSoundCreate()
	playSoundFrontEnd(6)
end
