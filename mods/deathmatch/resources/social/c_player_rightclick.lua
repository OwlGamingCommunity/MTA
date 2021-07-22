wRightClick = nil
bAddAsFriend, bFrisk, bRestrain, bCloseMenu, bInformation, bBlindfold, bStabilize = nil
sent = false
ax, ay = nil
player = nil
gotClick = false
closing = false

function clickPlayer(button, state, absX, absY, wx, wy, wz, element)
	if getElementData(getLocalPlayer(), "exclusiveGUI") then
		return
	end
	if (element) and (getElementType(element)=="player") and (button=="right") and (state=="down") and (sent==false) then
		local x, y, z = getElementPosition(getLocalPlayer())
		
		if (getDistanceBetweenPoints3D(x, y, z, wx, wy, wz)<=5) then
			if (wRightClick) then
				hidePlayerMenu()
			end
			--showCursor(true)
			ax = absX
			ay = absY
			player = element
			sent = true
			closing = false
			
			if(element == getLocalPlayer()) then
				showPlayerSelfMenu()
			else
				showPlayerMenu(player, isFriendOf(getElementData(player, "account:id")))
			end
		end
	end
end
addEventHandler("onClientClick", getRootElement(), clickPlayer, true)

function showPlayerSelfMenu()
	local row = {}
	local rcMenu
	local playerid = tonumber(getElementData(getLocalPlayer(), "playerid")) or 0

	if getElementInterior(getLocalPlayer()) == 0 and exports.weather:getSnowLevel() >= 2 then
		rcMenu = exports['rightclick']:create("Me ("..tostring(playerid)..")")
		row.snowball = exports['rightclick']:addRow("Make snowball")
		addEventHandler("onClientGUIClick", row.snowball, makeSnowball, false)
	end

	if getElementData(getLocalPlayer(), "realism:stretcher:hasStretcher") then
		if not rcMenu then
			rcMenu = exports['rightclick']:create("Me ("..tostring(playerid)..")")
		end
		row.stretcher = exports['rightclick']:addRow("Leave stretcher")
		addEventHandler("onClientGUIClick", row.stretcher, leaveStretcher, false)
	end
	sent = false
end

function showPlayerMenu(targetPlayer, friend)
	local row = {}
	local rcMenu
	local playerid = tonumber(getElementData(targetPlayer, "playerid")) or 0
	rcMenu = exports.rightclick:create(string.gsub(exports.global:getPlayerName(targetPlayer), "_", " ").." ("..tostring(playerid)..")")

	-- are we currently hosting a game of cards?
	if getElementData(localPlayer, "cards:host") then
		local bAddToGame = exports['rightclick']:addRow("Invite to Card Game")
		addEventHandler("onClientGUIClick", bAddToGame, function() triggerServerEvent("cards:invite_player", localPlayer, targetPlayer) end, false)
	end
	
	if not friend then
		bAddAsFriend = exports['rightclick']:addRow("Add as friend")
		addEventHandler("onClientGUIClick", bAddAsFriend, caddFriend, false)
	else
		bAddAsFriend = exports['rightclick']:addRow("Remove as friend")
		addEventHandler("onClientGUIClick", bAddAsFriend, cremoveFriend, false)
	end

	-- FRISK
	bFrisk = exports['rightclick']:addRow("Frisk")
	addEventHandler("onClientGUIClick", bFrisk, cfriskPlayer, false)
	
	-- RESTRAIN
	local cuffed = getElementData(player, "restrain")
	if cuffed == 0 then
		bRestrain = exports['rightclick']:addRow("Restrain")
		addEventHandler("onClientGUIClick", bRestrain, crestrainPlayer, false)
	else
		bRestrain = exports['rightclick']:addRow("Unrestrain")
		addEventHandler("onClientGUIClick", bRestrain, cunrestrainPlayer, false)
	end
	
	-- BLINDFOLD
	local blindfold = getElementData(player, "blindfold")
	if (blindfold) and (blindfold == 1) then
		bBlindfold = exports['rightclick']:addRow("Remove blindfold")
		addEventHandler("onClientGUIClick", bBlindfold, cremoveBlindfold, false)
	else
		bBlindfold = exports['rightclick']:addRow("Blindfold")
		addEventHandler("onClientGUIClick", bBlindfold, cBlindfold, false)
	end
	
	-- STABILIZE
	if exports.global:hasItem(getLocalPlayer(), 70) and getElementData(player, "injuriedanimation") then
		bStabilize = exports['rightclick']:addRow("Stabilize")
		addEventHandler("onClientGUIClick", bStabilize, cStabilize, false)
	end

	-- Stretcher system
	local stretcherElement = getElementData(getLocalPlayer(), "realism:stretcher:hasStretcher") 
	if stretcherElement then
		local stretcherPlayer = getElementData( stretcherElement, "realism:stretcher:playerOnIt" )
		if stretcherPlayer and stretcherPlayer == player then
			bStabilize = exports['rightclick']:addRow("Take from stretcher")
			addEventHandler("onClientGUIClick", bStabilize, fTakeFromStretcher, false)
		end
		if not stretcherPlayer then
			bStabilize = exports['rightclick']:addRow("Lay on stretcher")
			addEventHandler("onClientGUIClick", bStabilize, fLayOnStretcher, false)
		end
	end
	
	bInformation = exports['rightclick']:addRow("Information")
	addEventHandler("onClientGUIClick", bInformation, showPlayerInfo, false)

	sent = false
end
addEvent("displayPlayerMenu", true)
addEventHandler("displayPlayerMenu", getRootElement(), showPlayerMenu)

function fTakeFromStretcher(button, state)
	if button == "left" and state == "up" then
		triggerServerEvent("stretcher:takePedFromStretcher", getLocalPlayer(), player)
		hidePlayerMenu()
	end
end

function fLayOnStretcher(button, state)
	if button == "left" and state == "up" then
		triggerServerEvent("stretcher:movePedOntoStretcher", getLocalPlayer(), player)
		hidePlayerMenu()
	end
end

function leaveStretcher()
	triggerServerEvent("stretcher:leaveStretcher", getLocalPlayer())
end

function makeSnowball()
	triggerServerEvent("xmas:snowball:make", getLocalPlayer(), getLocalPlayer())
end

function showPlayerInfo(button, state)
	if (button=="left") then
		triggerServerEvent("social:look", player)
		hidePlayerMenu()
	end
end


--------------------
--   STABILIZING  --
--------------------

function cStabilize(button, state)
	if button == "left" and state == "up" then
		if (exports.global:hasItem(getLocalPlayer(), 70)) then -- Has First Aid Kit?
			local knockedout = getElementData(player, "injuriedanimation")
			
			if not knockedout then
				outputChatBox("This player is not knocked out.", 255, 0, 0)
				hidePlayerMenu()
			else
				triggerServerEvent("stabilizePlayer", getLocalPlayer(), player)
				hidePlayerMenu()
			end
		else
			outputChatBox("You do not have a First Aid Kit.", 255, 0, 0)
		end
	end
end

--------------------
--  BLINDFOLDING  --
-------------------
function cBlindfold(button, state, x, y)
	if (button=="left") then
		if (exports.global:hasItem(getLocalPlayer(), 66)) then -- Has blindfold?
			local blindfolded = getElementData(player, "blindfold")
			local restrained = getElementData(player, "restrain")
			
			if (blindfolded==1) then
				outputChatBox("This player is already blindfolded.", 255, 0, 0)
				hidePlayerMenu()
			elseif (restrained==0) then
				outputChatBox("This player must be restrained in order to blindfold them.", 255, 0, 0)
				hidePlayerMenu()
			else
				triggerServerEvent("blindfoldPlayer", getLocalPlayer(), player)
				hidePlayerMenu()
			end
		else
			outputChatBox("You do not have a blindfold.", 255, 0, 0)
		end
	end
end

function cremoveBlindfold(button, state, x, y)
	if (button=="left") then
		local blindfolded = getElementData(player, "blindfold")
		if (blindfolded==1) then
			triggerServerEvent("removeBlindfold", getLocalPlayer(), player)
			hidePlayerMenu()
		else
			outputChatBox("This player is not blindfolded.", 255, 0, 0)
			hidePlayerMenu()
		end
	end
end

addEventHandler("onClientKey", getRootElement(), function(button)
	if (getElementData(localPlayer, "blindfold") == 1) then
		local keys = getBoundKeys("radar")
		if keys and type(keys) == 'table' then
			for keyName, state in pairs(keys) do
				if button == keyName then
					return cancelEvent()
				end
			end
		end
	end
end)

--------------------
--  RESTRAINING   --
--------------------
function crestrainPlayer(button, state, x, y)
	if (button=="left") then
		if (exports.global:hasItem(getLocalPlayer(), 45) or exports.global:hasItem(getLocalPlayer(), 46)) then
			local restrained = getElementData(player, "restrain")
			
			if (restrained==1) then
				outputChatBox("This player is already restrained.", 255, 0, 0)
				hidePlayerMenu()
			else
				local restrainedObj
				
				if (exports.global:hasItem(getLocalPlayer(), 45)) then
					restrainedObj = 45
				elseif (exports.global:hasItem(getLocalPlayer(), 46)) then
					restrainedObj = 46
				end
					
				triggerServerEvent("restrainPlayer", getLocalPlayer(), player, restrainedObj)
				hidePlayerMenu()
			end
		else
			outputChatBox("You have no items to restrain with.", 255, 0, 0)
			hidePlayerMenu()
		end
	end
end

function cunrestrainPlayer(button, state, x, y)
	if (button=="left") then
		local restrained = getElementData(player, "restrain")
		
		if (restrained==0) then
			outputChatBox("This player is not restrained.", 255, 0, 0)
			hidePlayerMenu()
		else
			local restrainedObj = getElementData(player, "restrainedObj")
			local dbid = getElementData(player, "dbid")
			
			if (exports.global:hasItem(getLocalPlayer(), 47, dbid)) or (restrainedObj==46) then -- has the keys, or its a rope
				triggerServerEvent("unrestrainPlayer", getLocalPlayer(), player, restrainedObj)
				hidePlayerMenu()
			else
				outputChatBox("You do not have the keys to these handcuffs.", 255, 0, 0)
			end
		end
	end
end
--------------------
-- END RESTRAINING--
--------------------

--------------------
--    FRISKING    --
--------------------

gx, gy, wFriskItems, bFriskTakeItem, bFriskClose, gFriskItems, FriskColName = nil
function cfriskPlayer(button, state, x, y)
	if (button=="left") then
		local restrained = getElementData(player, "restrain")
		local injured = getElementData(player, "injuriedanimation")
		
		if restrained ~= 1 and not injured then
			outputChatBox("This player is not restrained or injured.", 255, 0, 0)
			hidePlayerMenu()
		--[[elseif getElementHealth(getLocalPlayer()) < 50 then
			outputChatBox("You need at least half health to frisk someone.", 255, 0, 0)
			hidePlayerMenu()]]--
		else
			gx = x
			gy = y
			triggerServerEvent("friskShowItems", getLocalPlayer(), player)
			hidePlayerMenu()
		end
	end
end

--------------------
--  END FRISKING  --
--------------------

function caddFriend()
	triggerServerEvent("addFriend", getLocalPlayer(), player)
	hidePlayerMenu()
end

function cremoveFriend()
	triggerServerEvent("social:remove", getLocalPlayer(), getElementData(player, "account:id"))
	hidePlayerMenu()
end

function hidePlayerMenu()
	if (isElement(bAddAsFriend)) then
		destroyElement(bAddAsFriend)
	end
	bAddAsFriend = nil
	
	if (isElement(bCloseMenu)) then
		destroyElement(bCloseMenu)
	end
	bCloseMenu = nil

	if (isElement(wRightClick)) then
		destroyElement(wRightClick)
	end
	wRightClick = nil

	if (isElement(wFriskItems)) then
		destroyElement(wFriskItems)
	end
	wFriskItems = nil
	
	ax = nil
	ay = nil
	
	description = nil
	age = nil
	weight = nil
	height = nil
	
	if player then
		removeEventHandler("onClientPlayerQuit", player, hidePlayerMenu)
	end
	
	sent = false
	player = nil
	
	showCursor(false)
end

function checkMenuWasted()
	if source == getLocalPlayer() or source == player then
		hidePlayerMenu()
	end
end

addEventHandler("onClientPlayerWasted", getRootElement(), checkMenuWasted)
