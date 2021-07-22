--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local pedTable = { }
local characterSelected, characterElementSelected, newCharacterButton, bLogout = nil
addEvent( 'account:character:select', true )
addEvent("account:character:spawned", true)

selectionScreenID = 0
function Characters_showSelection()
	characters_destroyDetailScreen()
	triggerEvent("account:changingchar", localPlayer)
	setPlayerHudComponentVisible("radar", false)

	guiSetInputEnabled(false)

	showCursor(true)

	setElementDimension ( localPlayer, 1 )
	setElementInterior( localPlayer, 0 )

	for _, thePed in ipairs(pedTable) do
		if isElement(thePed) then
			destroyElement(thePed)
		end
	end

	selectionScreenID = getSelectionScreenID()

	startCam[selectionScreenID] = originalStartCam[selectionScreenID]

	local x, y, z, rot =  pedPos[selectionScreenID][1], pedPos[selectionScreenID][2], pedPos[selectionScreenID][3], pedPos[selectionScreenID][4]
	local characterList = getElementData(localPlayer, "account:characters")
	if (characterList) then
		-- Prepare the peds
		local count = 0
		local oldPos = y
		username = getElementData(localPlayer, "account:username")
		credits = getElementData(localPlayer, "credits")
		createdDate = getElementData(localPlayer, "account:creationdate")
		lastLoginDate = getElementData(localPlayer, "account:lastlogin")
		accountEmail = getElementData(localPlayer, "account:email")
		for _, v in ipairs(characterList) do
			local thePed = createPed(tonumber(v[9]), x, y, z)
			if not thePed then
				thePed = createPed(264, x, y, z)
			end
			if thePed and isElement( thePed ) then
				setPedRotation(thePed, rot)
				setElementFrozen(thePed, true)
				setElementDimension(thePed, 1)
				setElementInterior(thePed, 0)
				setElementData(thePed,"account:charselect:id", v[1], false)
				setElementData(thePed,"account:charselect:name", v[2]:gsub("_", " "), false)
				setElementData(thePed,"account:charselect:cked", v[3], false)
				setElementData(thePed,"account:charselect:hoursplayed", v[4], false)
				setElementData(thePed,"account:charselect:lastseen", v[10], false)
				setElementData(thePed,"account:charselect:age", v[5], false)
				setElementData(thePed,"account:charselect:weight", v[11], false)
				setElementData(thePed,"account:charselect:height", v[12], false)
				setElementData(thePed,"account:charselect:age", v[5], false)
				setElementData(thePed,"account:charselect:gender", v[6], false)
				setElementData(thePed,"account:charselect:race", v[7], false)
				setElementData(thePed,"account:charselect:factionrank", v[8] or "", false)
				setElementData(thePed,"clothing:id", v[15] or "", false)
				setElementData(thePed,"account:charselect:month", v[13], false)
				setElementData(thePed,"account:charselect:day", v[14], false)

				local randomAnimation = getRandomAnim( v[3] > 0 and 4 or 2 )
				setPedAnimation ( thePed , randomAnimation[1], randomAnimation[2], -1, true, false, false, false )

				if selectionScreenID == 0 then
					y = y - 3
					count = count + 1
					if count >= 4 then
						count = 0
						y = oldPos
						x = x - 3
					end
				elseif selectionScreenID == 1 then
					y = y + 3
					count = count + 1
					if count >= 6 then
						count = 0
						y = oldPos
						x = x - 3
					end
				elseif selectionScreenID == 2 then
					y = y + 3
					count = count + 1
					if count >= 6 then
						count = 0
						y = oldPos
						x = x - 3
					end
				elseif selectionScreenID == 3 then
					y = y - 3
					count = count + 1
					if count >= 6 then
						count = 0
						y = oldPos
						x = x - 3
					end
				end
				table.insert(pedTable, thePed)
			else
				outputChatBox("[ACCOUNT] Error occurred while spawning character '"..v[2].."'. Please report on http://bugs.owlgaming.net :" )
				for index, value in pairs( v ) do
					outputChatBox( index .. " : " .. value )
				end
				outputChatBox("createPed( ".. v[9] .. ", " .. x .. ", " .. y .. ", " .. z .. ") failed."  )
			end
		end

		-- Cam magic
		fadeCamera ( false, 0, 0,0,0 )
		setCameraMatrix (originalStartCam[selectionScreenID][1], originalStartCam[selectionScreenID][2], originalStartCam[selectionScreenID][3], originalStartCam[selectionScreenID][4], originalStartCam[selectionScreenID][5], originalStartCam[selectionScreenID][6], 0, exports.global:getPlayerFov())
		setTimer(function ()
			fadeCamera ( true, 1, 0,0,0 )
			end, 1000, 1)

		setTimer(function ()
			showCursor(true)
			addEventHandler("onClientRender", getRootElement(), Characters_updateSelectionCamera)
			addEventHandler("onClientRender", getRootElement(), renderNametags)
			addEventHandler("onClientRender", root, characterMouseOver)

			--[[local bgMusic = getElementData(localPlayer, "bgMusic")
			if not bgMusic or not isElement(bgMusic) then
				local bgMusic = playSound ("http://files.owlgaming.net/menu.mp3", true)
				setSoundVolume(bgMusic, 1)
				setElementData(localPlayer, "bgMusic", bgMusic, false)
			end]]

			for i = 1, #pedTable do
				setElementFrozen(pedTable[i], false)
			end
			--[[
			local selectionSound = playSound ( "selection_screen.mp3")
			setSoundVolume(selectionSound, 0.3)
			setElementData(localPlayer, "selectionSound", selectionSound, false)
			--]]
		end, 2000, 1)
	end

	-- Prematurely prepare avatars a few seconds ealier. So it shortens the loading time, making avatar showing up faster on character selection screen.
	local id = getElementData(localPlayer, 'account:id')
	local fid = getElementData(localPlayer, 'account:forumid')

	if id and getElementData(localPlayer, "avatar") == 1  then
		avatar = exports.cache:getImage(id)
	end
	if fid then
		--exports.cache:getImage('http://owlgaming.net/favatar.php?id='..fid)
	end
end

function refreshCharacters()
	for _, thePed in ipairs(pedTable) do
		if isElement(thePed) then
			destroyElement(thePed)
		end
	end
	selectionScreenID = getSelectionScreenID()

	local x, y, z, rot =  pedPos[selectionScreenID][1], pedPos[selectionScreenID][2], pedPos[selectionScreenID][3], pedPos[selectionScreenID][4]
	local characterList = getElementData(localPlayer, "account:characters")
	if (characterList) then
		-- Prepare the peds
		local count = 0
		local oldPos = y
		username = getElementData(localPlayer, "account:username")
		credits = getElementData(localPlayer, "credits")
		createdDate = getElementData(localPlayer, "account:creationdate")
		lastLoginDate = getElementData(localPlayer, "account:lastlogin")
		accountEmail = getElementData(localPlayer, "account:email")
		for _, v in ipairs(characterList) do
			local thePed = createPed(tonumber(v[9]), x, y, z)
			if not thePed then
				thePed = createPed(264, x, y, z)
			end
			setPedRotation(thePed, rot)
			setElementDimension(thePed, 1)
			setElementInterior(thePed, 0)
			setElementData(thePed,"account:charselect:id", v[1], false)
			setElementData(thePed,"account:charselect:name", v[2]:gsub("_", " "), false)
			setElementData(thePed,"account:charselect:cked", v[3], false)
			setElementData(thePed,"account:charselect:hoursplayed", v[4], false)
			setElementData(thePed,"account:charselect:lastseen", v[10], false)
			setElementData(thePed,"account:charselect:age", v[5], false)
			setElementData(thePed,"account:charselect:weight", v[11], false)
			setElementData(thePed,"account:charselect:height", v[12], false)
			setElementData(thePed,"account:charselect:age", v[5], false)
			setElementData(thePed,"account:charselect:gender", v[6], false)
			setElementData(thePed,"account:charselect:race", v[7], false)
			setElementData(thePed,"account:charselect:factionrank", v[8] or "", false)
			setElementData(thePed,"clothing:id", v[15] or "", false)

			setElementData(thePed,"account:charselect:month", v[13], false)
			setElementData(thePed,"account:charselect:day", v[14], false)

			local randomAnimation = getRandomAnim( v[3] == 1 and 4 or 2 )
			setPedAnimation ( thePed , randomAnimation[1], randomAnimation[2], -1, true, false, false, false )


			if selectionScreenID == 0 then
				y = y - 3
				count = count + 1
				if count >= 4 then
					count = 0
					y = oldPos
					x = x - 3
				end
			elseif selectionScreenID == 1 then
				y = y + 3
				count = count + 1
				if count >= 6 then
					count = 0
					y = oldPos
					x = x - 3
				end
			elseif selectionScreenID == 2 then
				y = y + 3
				count = count + 1
				if count >= 6 then
					count = 0
					y = oldPos
					x = x - 3
				end
			elseif selectionScreenID == 3 then
				y = y - 3
				count = count + 1
				if count >= 6 then
					count = 0
					y = oldPos
					x = x - 3
				end
			end
			table.insert(pedTable, thePed)
		end
	end
end
addEvent("refreshCharacters", true)
addEventHandler("refreshCharacters", resourceRoot, refreshCharacters)

local forum_box = {}
function updateForumBox(data)
	for key, value in pairs(data) do
		forum_box[key] = value
	end
end
addEvent("updateForumBox", true)
addEventHandler("updateForumBox", root, updateForumBox)



cooldown = false
showing = false
justClicked = false
local swidth, sheight = guiGetScreenSize()

local function isInBox( x, y, xmin, xmax, ymin, ymax )
	return x and y and x >= xmin and x <= xmax and y >= ymin and y <= ymax
end

avatar = nil
calledAvatar = false
calledGot = false
local function getAvatar()
	if not calledAvatar or (getTickCount() - 10000 >= calledAvatar and not calledGot) then
		if getElementData(localPlayer, "avatar") == 1 then
			avatar = exports.cache:getImage(getElementData(localPlayer,"account:id"))
			if avatar and avatar.tex then
				calledGot = true
			end
		else
			exports.cache:removeImage(getElementData(localPlayer,"account:id"), true)
			calledGot = true
		end
	end
	calledAvatar = getTickCount()

	return avatar
end

local hover = tocolor( 255, 0, 0, 255 )
local mta_posxOffset, mta_posyOffset = 0,106
local character_detail_yoffset = 0
function renderAccountStats()
	if isCursorShowing( ) then
		cursorX, cursorY = getCursorPosition( )
		cursorX, cursorY = cursorX * swidth, cursorY * sheight
	end
	if cooldown then
		if cooldown<=getTickCount()-5000 then
			cooldown = false
		end
	end
--[[
	width = dxGetTextWidth( greeting..", "..username, 0.7, "bankgothic" )+72
	if width < 318 then
		width = 318
	end
	]]
	local width = 295
	mta_posxOffset = swidth - width - 3
	mta_posyOffset = 106 + character_detail_yoffset

	--MTA info box
	local mta_box_height = 203
	local fid = getElementData(localPlayer, "account:forumid")

	dxDrawRectangle(0+mta_posxOffset, 0+mta_posyOffset, width, mta_box_height, tocolor(0, 0, 0, 214), true)
	dxDrawLine(5+mta_posxOffset, 57+mta_posyOffset, width+mta_posxOffset, 57+mta_posyOffset, tocolor(255, 255, 255, 255), 1, true)
	avatar = getAvatar()
	dxDrawImage(5+mta_posxOffset, 3+mta_posyOffset, 50, 50, avatar and avatar.tex or ":cache/default.png" , 0, 0, 0, tocolor(255, 255, 255, 255), true)
	dxDrawText(greeting..", "..username, 46+mta_posxOffset, mta_posyOffset-4, 302+mta_posxOffset, 72+mta_posyOffset, tocolor(255, 255, 255, 255), 0.70, "bankgothic", "center", "center", false, true, true, false, false)
	w = dxGetTextWidth( credits )
	dxDrawImage(75+mta_posxOffset, 66+mta_posyOffset, 14, 13, ":donators/gamecoin.png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
	dxDrawText("GameCoins:", 8+mta_posxOffset, 65+mta_posyOffset, 74, 107+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "default-bold", "left", "top", false, false, true, false, false)
	dxDrawText("Total Hours:", 170+mta_posxOffset, 65+mta_posyOffset, 242, 106+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "default-bold", "left", "top", false, false, true, false, false)
	dxDrawText(getElementData(localPlayer, "account:hours") or 0, 244+mta_posxOffset, 65+mta_posyOffset, 311, 109+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, true, false, false)
	dxDrawText(exports.global:formatMoney(credits), 89+mta_posxOffset, 65+mta_posyOffset, 111, 101+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, true, false, false)
	dxDrawText("Account Creation Date:", 8+mta_posxOffset, 88+mta_posyOffset, 137, 124+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "default-bold", "left", "top", false, false, true, false, false)
	dxDrawText(createdDate, 143+mta_posxOffset, 88+mta_posyOffset, 181, 125+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, true, false, false)
	dxDrawText("Last Played:", 8+mta_posxOffset, 106+mta_posyOffset, 74, 144+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "default-bold", "left", "top", false, false, true, false, false)
	dxDrawText(lastLoginDate or "Never", 81+mta_posxOffset, 106+mta_posyOffset, 171, 148+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, true, false, false)
	dxDrawText("Registered Email:", 8+mta_posxOffset, 125+mta_posyOffset, 113, 169+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "default-bold", "left", "top", false, false, true, false, false)
	dxDrawText(accountEmail, 113+mta_posxOffset, 125+mta_posyOffset, 165, 166+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, true, false, false)

    -- Buttons
    local hoverAccountHis = isInBox( cursorX, cursorY, 3+mta_posxOffset, 3 + width-6+mta_posxOffset, 148+mta_posyOffset, 148 + 18+mta_posyOffset )
    dxDrawRectangle(3+mta_posxOffset, 148+mta_posyOffset, width-6, 18, hoverAccountHis and hover or tocolor(63, 63, 63, 174), true)
    dxDrawText("Account History", 54+mta_posxOffset, 150+mta_posyOffset, width-54+mta_posxOffset, 183+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "arial", "center", "top", false, false, true, false, false) -- History
    if justClicked and hoverAccountHis then
    	triggerServerEvent("showAdminHistory", root, localPlayer)
    end

    buttonWidth = width / 2 - 4
    if fid then
    	buttonWidth = buttonWidth * 2 + 2
    end
    local hoverRefresh = isInBox( cursorX, cursorY, 3+mta_posxOffset, 3 + buttonWidth+mta_posxOffset, 170+mta_posyOffset, 170 + 22+mta_posyOffset )
    dxDrawRectangle(3+mta_posxOffset, 170+mta_posyOffset, buttonWidth, 22, hoverRefresh and hover or tocolor(63, 63, 63, 174), true) -- Refresh Chars
    dxDrawText("Refresh Characters", 3+mta_posxOffset, 172+mta_posyOffset, buttonWidth+mta_posxOffset, 204+mta_posyOffset,  cooldown and cooldown>=getTickCount()-5000 and tocolor(255, 255, 255, 100) or tocolor(255, 255, 255, 255), 1.00, "arial", "center", "top", false, false, true, false, false)
    if justClicked and hoverRefresh and not cooldown then
    	triggerServerEvent("updateCharacters", resourceRoot, true)
    	cooldown = getTickCount()
    end
    --[[if not fid then
    	local hoverLink = isInBox( cursorX, cursorY, width-buttonWidth+mta_posxOffset, width-buttonWidth + buttonWidth+mta_posxOffset, 170+mta_posyOffset, 170 + 22+mta_posyOffset )
    	dxDrawRectangle(width-buttonWidth-3+mta_posxOffset, 170+mta_posyOffset, buttonWidth, 22, hoverLink and hover or fid and tocolor(100, 200, 100, 174) or tocolor(63, 63, 63, 174), true)
	    dxDrawText(fid and "Close" or "Link Forum Account", width-buttonWidth+3+mta_posxOffset, 173+mta_posyOffset, buttonWidth+width/2+mta_posxOffset, 209+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "arial", "center", "top", false, false, true, false, false) -- Link Forums account
	    if justClicked and hoverLink then
	    	if not fid then
	    		linkForumAccount()
	    	end
	    end
	end]]

	--Forums info box
	--[[if forum_box['show'] and fid then
		mta_posyOffset = mta_posyOffset + mta_box_height + 3
		dxDrawRectangle(0+mta_posxOffset, 0+mta_posyOffset, width, 203, tocolor(0, 0, 0, 214), true)
		dxDrawLine(5+mta_posxOffset, 57+mta_posyOffset, width+mta_posxOffset, 57+mta_posyOffset, tocolor(255, 255, 255, 255), 1, true)
		local avatar = exports.cache:getImage('http://owlgaming.net/favatar.php?id='..fid)
		dxDrawImage(5+mta_posxOffset, 3+mta_posyOffset, 50, 50, avatar and avatar.tex or ':cache/default.png', 0, 0, 0, tocolor(255, 255, 255, 255), true)
		dxDrawText(forum_box['name'] and (greeting..", "..forum_box['name']) or "Loading..", 46+mta_posxOffset, mta_posyOffset-4, 302+mta_posxOffset, 72+mta_posyOffset, tocolor(255, 255, 255, 255), 0.70, "bankgothic", "center", "center", false, true, true, false, false)
		dxDrawText("Reputation:", 8+mta_posxOffset, 65+mta_posyOffset, 74, 107+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "default-bold", "left", "top", false, false, true, false, false)
		dxDrawText("Posts:", 170+mta_posxOffset, 65+mta_posyOffset, 242, 106+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "default-bold", "left", "top", false, false, true, false, false)
		dxDrawText(forum_box['posts'] and exports.global:formatMoney(forum_box['posts']) or "...", 214+mta_posxOffset, 65+mta_posyOffset, 311, 109+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, true, false, false)
		dxDrawText(forum_box['pp_reputation_points'] and exports.global:formatMoney(forum_box['pp_reputation_points']) or "...", 80+mta_posxOffset, 65+mta_posyOffset, 111, 101+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, true, false, false)

		mta_posyOffset = mta_posyOffset + 18

		dxDrawText("Unread Msgs:", 8+mta_posxOffset, 65+mta_posyOffset, 74, 107+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "default-bold", "left", "top", false, false, true, false, false)
		dxDrawText("Warnings:", 170+mta_posxOffset, 65+mta_posyOffset, 242, 106+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "default-bold", "left", "top", false, false, true, false, false)
		dxDrawText(forum_box['warn_level'] and exports.global:formatMoney(forum_box['warn_level']) or "...", 234+mta_posxOffset, 65+mta_posyOffset, 311, 109+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, true, false, false)
		dxDrawText(forum_box['msg_count_new'] and (exports.global:formatMoney(forum_box['msg_count_new']).."/"..exports.global:formatMoney(forum_box['msg_count_total'])) or "...", 90+mta_posxOffset, 65+mta_posyOffset, 111, 101+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, true, false, false)

		dxDrawText("Last Activity:", 8+mta_posxOffset, 88+mta_posyOffset, 137, 124+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "default-bold", "left", "top", false, false, true, false, false)
		dxDrawText(forum_box['last_activity'] and forum_box['last_activity'] or "...", 100+mta_posxOffset, 88+mta_posyOffset, 181, 125+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, true, false, false)
		dxDrawText("Joined Date:", 8+mta_posxOffset, 106+mta_posyOffset, 74, 144+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "default-bold", "left", "top", false, false, true, false, false)
		dxDrawText(forum_box['joined'] and forum_box['joined'] or "...", 100+mta_posxOffset, 106+mta_posyOffset, 171, 148+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, true, false, false)


		dxDrawText("Registered Email:", 8+mta_posxOffset, 125+mta_posyOffset, 113, 169+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "default-bold", "left", "top", false, false, true, false, false)
		dxDrawText(forum_box['email'] and forum_box['email'] or "...", 113+mta_posxOffset, 125+mta_posyOffset, 165, 166+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, true, false, false)
		mta_posyOffset = mta_posyOffset - 18
	    -- Buttons

	    local hoverAccountHis = isInBox( cursorX, cursorY, 3+mta_posxOffset, 3 + width-6+mta_posxOffset, 148+mta_posyOffset, 148 + 18+mta_posyOffset )
	    dxDrawRectangle(3+mta_posxOffset, 148+mta_posyOffset, width-6, 18, hoverAccountHis and hover or tocolor(63, 63, 63, 174), true)
	    dxDrawText("Account History", 54+mta_posxOffset, 150+mta_posyOffset, width-54+mta_posxOffset, 183+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "arial", "center", "top", false, false, true, false, false) -- History
	    if justClicked and hoverAccountHis then
	    	triggerServerEvent("showAdminHistory", root, localPlayer)
	    end

	    local hoverRefresh = isInBox( cursorX, cursorY, 3+mta_posxOffset, 3 + buttonWidth+mta_posxOffset, 170+mta_posyOffset, 170 + 22+mta_posyOffset )
	    dxDrawRectangle(3+mta_posxOffset, 170+mta_posyOffset, buttonWidth, 22, hoverRefresh and hover or tocolor(63, 63, 63, 174), true) -- Refresh Chars
	    dxDrawText("Remove Forum Link", 3+mta_posxOffset, 172+mta_posyOffset, buttonWidth+mta_posxOffset, 204+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "arial", "center", "top", false, false, true, false, false)
	    if justClicked and hoverRefresh then
	    	triggerServerEvent("forum:remove", resourceRoot)
	    end

	    local fid = getElementData(localPlayer, "account:forumid")
	    local hoverLink = isInBox( cursorX, cursorY, width-buttonWidth+mta_posxOffset, width-buttonWidth + buttonWidth+mta_posxOffset, 170+mta_posyOffset, 170 + 22+mta_posyOffset )
	    dxDrawRectangle(width-buttonWidth-3+mta_posxOffset, 170+mta_posyOffset, buttonWidth, 22, hoverLink and hover or fid and tocolor(100, 200, 100, 174) or tocolor(63, 63, 63, 174), true)
	    dxDrawText(fid and "Remove Forum Link" or "Link Forum Account", width-buttonWidth+3+mta_posxOffset, 173+mta_posyOffset, buttonWidth+width/2+mta_posxOffset, 209+mta_posyOffset, tocolor(255, 255, 255, 255), 1.00, "arial", "center", "top", false, false, true, false, false) -- Link Forums account
	    if justClicked and hoverLink then
	    	if not fid then
	    		linkForumAccount()
	    	else
	    		triggerServerEvent("forum:remove", resourceRoot)
	    	end
	    end

	end]]

	justClicked = false
end

forumLink = {
button = {},
window = {},
edit = {},
label = {}
}

function linkForumAccount()
	if isElement(forumLink.window[1]) then destroyElement(forumLink.window[1]) end

	guiSetInputEnabled(true)
	forumLink.window[1] = guiCreateWindow(749, 273, 318, 223, "Forum Login", false)
	guiWindowSetSizable(forumLink.window[1], false)
	exports.global:centerWindow(forumLink.window[1])

	forumLink.button[1] = guiCreateButton(165, 171, 143, 42, "Cancel", false, forumLink.window[1])
	guiSetProperty(forumLink.button[1], "NormalTextColour", "FFAAAAAA")
	forumLink.button[2] = guiCreateButton(9, 171, 146, 42, "Login", false, forumLink.window[1])
	guiSetProperty(forumLink.button[2], "NormalTextColour", "FFAAAAAA")
	forumLink.label[1] = guiCreateLabel(11, 23, 287, 17, "OwlGaming Forum Login", false, forumLink.window[1])
	guiSetFont(forumLink.label[1], "default-bold-small")
	guiLabelSetHorizontalAlign(forumLink.label[1], "center", false)
	forumLink.label[2] = guiCreateLabel(12, 40, 287, 17, "Enter your forum credentials below", false, forumLink.window[1])
	guiLabelSetHorizontalAlign(forumLink.label[2], "center", false)
	forumLink.label[3] = guiCreateLabel(19, 71, 113, 15, "Username:", false, forumLink.window[1])
	forumLink.edit[1] = guiCreateEdit(20, 86, 278, 23, "", false, forumLink.window[1])
	forumLink.label[4] = guiCreateLabel(19, 118, 113, 15, "Password:", false, forumLink.window[1])
	forumLink.edit[2] = guiCreateEdit(20, 133, 278, 23, "", false, forumLink.window[1])

	guiEditSetMaxLength ( forumLink.edit[1] ,25)
	guiEditSetMaxLength ( forumLink.edit[2] ,25)
	guiEditSetMasked ( forumLink.edit[2] , true )
	guiSetProperty( forumLink.edit[2] , 'MaskCodepoint', '8226' )

	addEventHandler("onClientGUIClick", forumLink.button[1], function()
		destroyElement(forumLink.window[1])
		guiSetInputEnabled(false)
		end, false)

	addEventHandler("onClientGUIClick", forumLink.button[2], function()
		local username = guiGetText(forumLink.edit[1])
		local password = guiGetText(forumLink.edit[2])
		if username~="" and password~="" then
			triggerServerEvent("forum:login", root, username, password)
		end
		end, false)
end

function returnForumResults(result, er)
	if not result then
		guiSetText(forumLink.label[1], er)
		guiLabelSetColor( forumLink.label[1], 255, 0, 0 )
		guiSetText(forumLink.edit[1], "")
		guiSetText(forumLink.edit[2], "")
	else
		destroyElement(forumLink.window[1])
		guiSetInputEnabled(false)
		--Now display forums info box.
		forum_box['show'] = true
	end
end
addEvent("forum:loginResult", true)
addEventHandler("forum:loginResult", resourceRoot, returnForumResults)

function Characters_characterSelectionVisisble()
	addEventHandler("onClientClick", getRootElement(), Characters_onClientClick)

	local width, height = 300, 50


	bLogout = guiCreateStaticImage(swidth-width, 0, width, height, ":resources/window_body.png" , false, nil)
	local text1= guiCreateLabel (0,0,1,1, "Logout", true, bLogout)
	guiLabelSetHorizontalAlign(text1, "center", true)
	guiLabelSetVerticalAlign(text1, "center", true)

	addEventHandler("onClientGUIClick", bLogout, function ()
		removeEventHandler("onClientRender", getRootElement(), renderNametags)
		removeEventHandler("onClientRender", root, characterMouseOver)
		fadeCamera ( false, 2, 0,0,0 )
		setTimer(function()
			triggerServerEvent("accounts:reconnectMe", localPlayer)
			end, 2000,1)
		end)

	newCharacterButton = guiCreateStaticImage(swidth-width, 53, width, height, ":resources/window_body.png" , false, nil)
	newCharacterButton_text = guiCreateLabel (0,0,1,1, "Create a new character!", true, newCharacterButton)
	guiLabelSetHorizontalAlign(newCharacterButton_text, "center", true)
	guiLabelSetVerticalAlign(newCharacterButton_text, "center", true)
	addEventHandler("onClientGUIClick", newCharacterButton, function()
		if source == newCharacterButton or source == newCharacterButton_text then
			if guiGetText(newCharacterButton_text) ~= "Checking for characters quota..." then
				guiSetText(newCharacterButton_text, "Checking for characters quota...")
				guiSetEnabled(newCharacterButton_text, false)
				guiSetEnabled(newCharacterButton, false)
				guiSetAlpha(newCharacterButton_text, 0.3)
				triggerServerEvent('account:charactersQuotaCheck', resourceRoot)
			end
		end
	end)

	local greetings = {
		"Howdy",
		"Welcome",
		"Hello",
		"Hey",
		"Hi",
	}
	greeting = greetings[math.random(#greetings)]
	showing = true
	addEventHandler("onClientRender", root, renderAccountStats)
end

function charactersQuotaCheck(ok, why)
	guiSetText(newCharacterButton_text, why)
	guiSetEnabled(newCharacterButton_text, true)
	guiSetEnabled(newCharacterButton, true)
	guiSetAlpha(newCharacterButton_text, 1)
	if ok then
		Characters_deactivateGUI()
		characters_destroyDetailScreen()
		newCharacter_init()
	end
end
addEvent('account:charactersQuotaCheck', true)
addEventHandler('account:charactersQuotaCheck', resourceRoot, charactersQuotaCheck)

--Character info box / Maxime
local function getHoverElement()
	local cursorX, cursorY, absX, absY, absZ = getCursorPosition( )
	local cameraX, cameraY, cameraZ = getWorldFromScreenPosition( cursorX, cursorY, 0.1 )

	local a, b, c, d, element = processLineOfSight( cameraX, cameraY, cameraZ, absX, absY, absZ )
	if element and getElementParent(getElementParent(element)) == getResourceRootElement(getResourceFromName("account")) then
		return element
	elseif b and c and d then
		element = nil
		local x, y, z = nil
		local maxdist = 0.34
		for key, value in ipairs(getElementsByType("ped", getResourceRootElement(getResourceFromName("account")))) do
			if isElementStreamedIn(value) and isElementOnScreen(value) then
				x, y, z = getElementPosition(value)
				local dist = getDistanceBetweenPoints3D(x, y, z, b, c, d)
				if dist < maxdist then
					element = value
					maxdist = dist
				end
			end
		end
		if element then
			return element
		end
	end
end

local font1 = dxCreateFont(':resources/nametags0.ttf')
local font2 = dxCreateFont(':interior_system/intNameFont.ttf')
function characterMouseOver()
	local cursorX, cursorY
	if isCursorShowing( ) then
		local ped = getHoverElement()
		if ped and isElement(ped) then
			cursorX, cursorY = getCursorPosition( )
			cursorX, cursorY = cursorX * swidth, cursorY * sheight
			local ox, oy = cursorX-1053, cursorY-564
			dxDrawImage(805+ox, 432+oy, 109, 105, "img/" .. ("%03d"):format(getElementModel(ped)) .. ".png", 0, 0, 0, tocolor(255, 255, 255, 255), true)
			local tRace = "Black"
			local race = getElementData(ped, "account:charselect:race")
			if race == 1 then
				tRace="White"
			elseif race == 2 then
				tRace="Asian"
			end
			local text = "■ Race: "..tRace.."\n■ Gender: "..(getElementData(ped, "account:charselect:gender") == 0 and "Male" or "Female").."\n■ Status: "..(getElementData(ped, "account:charselect:cked") > 0 and "#FF0000Dead" or "#00FF00Alive").."\n#FFFFFF■ Age: "..getElementData(ped, "account:charselect:age").."\n■ Height: "..getElementData(ped, "account:charselect:height").."cm\n■ Weight: "..getElementData(ped, "account:charselect:weight").."kg\n■ Played: "..getElementData(ped, "account:charselect:hoursplayed").."h"
			local text2 = "■ Race: "..tRace.."\n■ Gender: "..(getElementData(ped, "account:charselect:gender") == 0 and "Male" or "Female").."\n■ Status: "..(getElementData(ped, "account:charselect:cked") > 0 and "Dead" or "Alive").."\n■ Age: "..getElementData(ped, "account:charselect:age").."\n■ Height: "..getElementData(ped, "account:charselect:height").."cm\n■ Weight: "..getElementData(ped, "account:charselect:weight").."kg\n■ Played: "..getElementData(ped, "account:charselect:hoursplayed").."h"
			if not font1 then font1 = dxCreateFont(':resources/nametags0.ttf') end
			dxDrawText(text2, 915+ox, 433+oy, 1050+ox, 538+oy, tocolor(0, 0, 0, 255), 1.00, font1 or "default", "left", "top", true, false, true, true, false)
			dxDrawText(text2, 915+ox, 431+oy, 1050+ox, 536+oy, tocolor(0, 0, 0, 255), 1.00, font1 or "default", "left", "top", true, false, true, true, false)
			dxDrawText(text2, 913+ox, 433+oy, 1048+ox, 538+oy, tocolor(0, 0, 0, 255), 1.00, font1 or "default", "left", "top", true, false, true, true, false)
			dxDrawText(text2, 913+ox, 431+oy, 1048+ox, 536+oy, tocolor(0, 0, 0, 255), 1.00, font1 or "default", "left", "top", true, false, true, true, false)
			dxDrawText(text, 914+ox, 432+oy, 1049+ox, 537+oy, tocolor(255, 255, 255, 255), 1.00, font1 or "default", "left", "top", true, false, true, true, false)
			dxDrawLine(805+ox, 542+oy, 1017+ox, 542+oy, tocolor(255, 255, 255, 255), 1, true)
			dxDrawLine(1017+ox, 542+oy, 1054+ox, 563+oy, tocolor(255, 255, 255, 255), 1, true)
			local name = exports.global:explode(" ", getElementData(ped,"account:charselect:name"))[1]
			text = string.upper("Click to play as "..name)
			if not font2 then font2 = dxCreateFont(':interior_system/intNameFont.ttf') end
			dxDrawText(text, 805+ox, 549+oy, 1017+ox, 565+oy, tocolor(0, 0, 0, 255), 1.00, font2 or "default", "center", "center", true, false, true, false, false)
			dxDrawText(text, 805+ox, 547+oy, 1017+ox, 563+oy, tocolor(0, 0, 0, 255), 1.00, font2 or "default", "center", "center", true, false, true, false, false)
			dxDrawText(text, 803+ox, 549+oy, 1015+ox, 565+oy, tocolor(0, 0, 0, 255), 1.00, font2 or "default", "center", "center", true, false, true, false, false)
			dxDrawText(text, 803+ox, 547+oy, 1015+ox, 563+oy, tocolor(0, 0, 0, 255), 1.00, font2 or "default", "center", "center", true, false, true, false, false)
			dxDrawText(text, 804+ox, 548+oy, 1016+ox, 564+oy, tocolor(255, 255, 255, 255), 1.00, font2 or "default", "center", "center", true, false, true, false, false)
			updateCharacterAnim(ped)
		end
	end
end
local lastCharAnim = nil
function updateCharacterAnim(theElement)
	if not theElement then lastCharAnim = nil end
	if theElement and theElement ~= lastCharAnim then
		lastCharAnim = theElement
		local cked = getElementData(theElement,"account:charselect:cked")
		local randomAnimation = cked > 0 and getRandomAnim( 4 ) or getRandomAnim( 1 )
		setPedAnimation ( theElement , randomAnimation[1], randomAnimation[2], -1, cked > 0, false, false, false )
		playSoundFrontEnd(cked>0 and 4 or 1)
	end
end



function getCamSpeed( index1, startCam1, endCam1, globalspeed1)
return (math.abs(startCam1[index1]-endCam1[index1])/globalspeed1)
end

--Check c_login.lua for settings block
function Characters_updateSelectionCamera ()
	for var = 1, 6, 1 do
		if not doneCam[selectionScreenID][var] then
			--outputDebugString("if not doneCam[selectionScreenID][var] then")
			if (math.abs(startCam[selectionScreenID][var] - endCam[selectionScreenID][var]) > 0.2) then
			if startCam[selectionScreenID][var] > endCam[selectionScreenID][var] then
			startCam[selectionScreenID][var] = startCam[selectionScreenID][var] - getCamSpeed( var, startCam[selectionScreenID], endCam[selectionScreenID], globalspeed)
		else
			startCam[selectionScreenID][var] = startCam[selectionScreenID][var] + getCamSpeed( var, startCam[selectionScreenID], endCam[selectionScreenID], globalspeed)
		end
	else
		doneCam[selectionScreenID][var] = true
	end
end
end

setCameraMatrix (startCam[selectionScreenID][1], startCam[selectionScreenID][2], startCam[selectionScreenID][3], startCam[selectionScreenID][4], startCam[selectionScreenID][5], startCam[selectionScreenID][6], 0, exports.global:getPlayerFov())
if doneCam[selectionScreenID][1] and doneCam[selectionScreenID][2] and doneCam[selectionScreenID][3] and doneCam[selectionScreenID][4] and doneCam[selectionScreenID][5] and doneCam[selectionScreenID][6] then
	stopMovingCam()
end
end

function stopMovingCam()
	removeEventHandler("onClientRender",getRootElement(),Characters_updateSelectionCamera)
	Characters_characterSelectionVisisble()
end

function renderNametags()
	for key, player in ipairs(getElementsByType("ped")) do
		if (isElement(player))then
			if (getElementData(player,"account:charselect:id")) then
				local lx, ly, lz = getElementPosition( localPlayer )
				local rx, ry, rz = getElementPosition(player)
				local distance = getDistanceBetweenPoints3D(lx, ly, lz, rx, ry, rz)
				if  (isElementOnScreen(player)) then
					local lx, ly, lz = getCameraMatrix()
					local collision, cx, cy, cz, element = processLineOfSight(lx, ly, lz, rx, ry, rz+1, true, true, true, true, false, false, true, false, nil)
					if not (collision) then
						local x, y, z = getElementPosition(player)
						local sx, sy = getScreenFromWorldPosition(x, y, z+0.45, 100, false)
						if (sx) and (sy) then
							if (distance<=2) then
								sy = math.ceil( sy - ( 2 - distance ) * 40 )
							end
							sy = sy - 20
							if (sx) and (sy) then
								distance = 1.5
								local offset = 75 / distance
								dxDrawText(getElementData(player,"account:charselect:name"), sx-offset+2, sy+2, (sx-offset)+130 / distance, sy+20 / distance, tocolor(0, 0, 0, 220), 0.6 / distance, "bankgothic", "center", "center", false, false, false)
								dxDrawText(getElementData(player,"account:charselect:name"), sx-offset, sy, (sx-offset)+130 / distance, sy+20 / distance, tocolor(255, 255, 255, 220), 0.6 / distance, "bankgothic", "center", "center", false, false, false)
							end
						end
					end
				end
			end
		end
	end
end

function Characters_onClientClick(mouseButton, state, alsoluteX, alsoluteY, worldX, worldY, worldZ, theElement)
	if mouseButton=="left" and state=="up" and theElement and getElementData(theElement, "account:charselect:cked") == 0 then
		if (getElementData(theElement,"account:charselect:id")) then
			characterSelected = getElementData(theElement,"account:charselect:id")
			characterElementSelected = theElement

			Characters_deactivateGUI()
			local randomAnimation = getRandomAnim(3)
			setPedAnimation ( characterElementSelected, randomAnimation[1], randomAnimation[2], -1, true, false, false, false )
			cFadeOutTime = 254
			addEventHandler("onClientRender", getRootElement(), Characters_FadeOut)
			fadeCamera ( false, 2, 0,0,0 )
			setTimer(function()
				triggerServerEvent("accounts:characters:spawn", localPlayer, characterSelected)
			end, 2000,1)
		end
	end
	justClicked = state=="up"
end
--- Character detail screen
local wDetailScreen, lDetailScreen, iCharacterImage, bPlayAs,cFadeOutTime = nil

function Characters_deactivateGUI()
	if isElement(bLogout) then
		guiSetEnabled( newCharacterButton, false )
		guiSetEnabled( bLogout, false )
	end
	removeEventHandler("onClientRender", getRootElement(), renderNametags)
	removeEventHandler("onClientRender", root, renderAccountStats)
	showing = false
	removeEventHandler("onClientClick", getRootElement(), Characters_onClientClick)
	removeEventHandler("onClientRender", root, characterMouseOver)
end

function Characters_FadeOut()
	cFadeOutTime = cFadeOutTime -3
	if (cFadeOutTime <= 0) then
		removeEventHandler("onClientRender", getRootElement(), Characters_FadeOut)
	else
		for _, thePed in ipairs(pedTable) do
			if isElement(thePed) and (thePed ~= characterElementSelected) then
				setElementAlpha(thePed, cFadeOutTime)
			end
		end
	end
end

function characters_destroyDetailScreen()
	lDetailScreen = { }
	if isElement(wDetailScreen) then
		destroyElement(iCharacterImage)
		destroyElement(bPlayAs)
		destroyElement(wDetailScreen)
		iCharacterImage = nil
		iPlayAs = nil
		wDetailScreen = nil
		character_detail_yoffset = 0

	end
	for _, thePed in ipairs(pedTable) do
		if isElement(thePed) then
			destroyElement(thePed)
		end
	end
	pedTable = { }
	cFadeOutTime = 0
	if isElement(newCharacterButton) then
		destroyElement( newCharacterButton )
	end
	if isElement(bLogout) then
		destroyElement( bLogout )
	end
	removeEventHandler("onClientRender", root, renderAccountStats)
	showing = false
end
--- End character detail screen

function characters_onSpawn(fixedName, adminLevel, gmLevel, location)
	clearChat()
	showChat(true)
	guiSetInputEnabled(false)
	showCursor(false)
	--outputChatBox("You are now playing as '" .. fixedName .. "'.", 0, 255, 0)
	outputChatBox("Press F1 for Help.", 255, 194, 14)
	outputChatBox("You can visit the Options menu by pressing 'F10' or /home.", 255, 194, 15)
	outputChatBox(" ")
	characters_destroyDetailScreen()

	setElementData(localPlayer, "admin_level", adminLevel, false)
	setElementData(localPlayer, "account:gmlevel", gmLevel, false)

	-- Adams
	options_enable()
	--Stop bgMusic + spawning sound fx / maxime
	stopLoginSound()
	if toggleSoundLabel then 
		destroyElement(toggleSoundLabel)
		toggleSoundLabel = nil
	end

	setTimer(function(expectedLocation)
		local currentPositionX, currentPositionY = getElementPosition(localPlayer)
		local expectedPositionX, expectedPositionY = expectedLocation[1], expectedLocation[2]
		if getDistanceBetweenPoints2D( currentPositionX, currentPositionY, unpack( defaultCharacterSelectionSpawnPosition ) ) < 20 and -- we are near angel pine
				getDistanceBetweenPoints2D( expectedPositionX, expectedPositionY, unpack( defaultCharacterSelectionSpawnPosition ) ) > 20 then -- but we shouldn't actually be near angel pine
			outputDebugString('We got stuck in a river near Angel Pine, oooh~', 2)
			triggerServerEvent('accounts:characters:fixCharacterSpawnPosition', localPlayer, expectedLocation)
		end
	end, 5000, 1, location)
end
addEventHandler("accounts:characters:spawn", getRootElement(), characters_onSpawn)

function stopLoginSound()
	local bgMusic = getElementData(localPlayer, "bgMusic")
	if bgMusic and isElement(bgMusic) then
		setTimer(startSoundFadeOut, 2000, 1, bgMusic, 100, 30, 0.04, "bgMusic")
	end
	local selectionSound = getElementData(localPlayer, "selectionSound")
	if selectionSound and isElement(selectionSound) then
		destroyElement(selectionSound)
		bgMusic = nil
	end
end

function soundFadeOut(sound, decrease, dataKey)
	if sound and isElement(sound) then
		local oldVol = getSoundVolume(sound)
		if oldVol <= 0 then
			if soundFadeTimer and isElement(soundFadeTimer) then
				killTimer(soundFadeTimer)
				soundFadeTimer = nil
			end
			destroyElement(sound)
			if dataKey then
				setElementData(localPlayer, dataKey, false)
			end
		else
			if not decrease then decrease = 0.05 end
			local newVol = oldVol - decrease
			setSoundVolume(sound, newVol)
		end
	end
end
function startSoundFadeOut(sound, timeInterval, timesToExecute, decrease, dataKey)
	if not sound or not isElement(sound) then return false end
	if not tonumber(timeInterval) then timeInterval = 100 end
	if not tonumber(timesToExecute) then timesToExecute = 30 end
	if not tonumber(decrease) then decrease = 0.05 end
	soundFadeTimer = setTimer(soundFadeOut, timeInterval, timesToExecute, sound, decrease, dataKey)
	setTimer(forceStopSound, 4000, 1, sound, dataKey)
end
function forceStopSound(sound, dataKey)
	if sound and isElement(sound) then
		destroyElement(sound)
		if dataKey then
			setElementData(localPlayer, dataKey, false)
		end
	end
end

function playerLogout()
	Characters_deactivateGUI()
	characters_destroyDetailScreen()
	for _, thePed in ipairs(pedTable) do
		destroyElement(thePed, 0)
	end
end
