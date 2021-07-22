--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

validWalkingStyles = { [57]=true, [58]=true, [59]=true, [60]=true, [61]=true, [62]=true, [63]=true, [64]=true, [65]=true, [66]=true, [67]=true, [68]=true, [118]=true, [119]=true, [120]=true, [121]=true, [122]=true, [123]=true, [124]=true, [125]=true, [126]=true, [128]=true, [129]=true, [130]=true, [131]=true, [132]=true, [133]=true, [134]=true, [135]=true, [136]=true, [137]=true, [138]=true }
function setWalkingStyle(thePlayer, commandName, walkingStyle)
	if not walkingStyle or not validWalkingStyles[tonumber(walkingStyle)] or not tonumber(walkingStyle) then
		outputChatBox("SYNTAX: /" .. commandName .. " [Walking Style ID]", thePlayer, 255, 194, 14)
		outputChatBox("'/walklist' to list all valid walking style IDs.", thePlayer, 255, 194, 14)
	-- if having a forced walking style
	elseif getElementData( thePlayer, 'old_walkstyle' ) then
		outputChatBox("You can not change walking style at the moment.", thePlayer, 255, 0, 0)
	else
		setPedWalkingStyle( thePlayer, tonumber(walkingStyle) )
		outputChatBox("Walking style successfully set to: " .. walkingStyle, thePlayer, 0, 255, 0)
		dbExec( exports.mysql:getConn('mta'), "UPDATE characters SET walkingstyle=? WHERE id=? ", walkingStyle, getElementData(thePlayer, "dbid") )
	end
end
addCommandHandler("setwalkingstyle", setWalkingStyle)
addCommandHandler("setwalk", setWalkingStyle)

function applyWalkingStyle(style, ignoreSQL)
	if not style or not validWalkingStyles[tonumber(style)] then
		if getElementData(source, "gender") == 1 then
			style = 129
		else
			style = 128
		end
		ignoreSQL = true
	else
		ignoreSQL = false
	end
	-- if not having a forced walking style
	if not getElementData( source, 'old_walkstyle' ) then
		setPedWalkingStyle(source, tonumber(style))
	end

	if not ignoreSQL then
		dbExec( exports.mysql:getConn('mta'), "UPDATE characters SET walkingstyle=? WHERE id=? ", style, getElementData(source, "dbid") )
	end
end
addEvent("realism:applyWalkingStyle", true)
addEventHandler("realism:applyWalkingStyle", root, applyWalkingStyle)

function switchWalkingStyle()
	local walkingStyle = getPedWalkingStyle(client)
	walkingStyle = walkingStyle > 57 and walkingStyle or 57
	local nextStyle = getNextValidWalkingStype(walkingStyle)
	if not nextStyle then
		nextStyle = getNextValidWalkingStype(56)
	end
	triggerEvent("realism:applyWalkingStyle", client, nextStyle)
end
addEvent("realism:switchWalkingStyle", true)
addEventHandler("realism:switchWalkingStyle", root, switchWalkingStyle)

function getNextValidWalkingStype(cur)
	cur = tonumber(cur)
	local found = false
	for i = cur, 138 do
		if validWalkingStyles[i+1] then
			found = i+1
			break
		end
	end
	
	return found
end

function walkStyleList(thePlayer, commandName)
	outputChatBox("Walking style IDs list:", thePlayer, 255, 194, 14)
	outputChatBox("57, 58, 59, 60, 61, 62, 63, 64, 65, 66, 67, 68, 118", thePlayer, 100, 194, 14)
	outputChatBox("119, 120, 121, 122, 123, 124, 125, 126, 128", thePlayer, 100, 194, 14)
	outputChatBox("129, 130, 131, 132, 133, 134, 135, 136, 137, 138", thePlayer, 100, 194, 14)
end
addCommandHandler("walklist", walkStyleList)

function setForceWalkStyle(player, style)
	if validWalkingStyles[style] then
		exports.anticheat:setEld( player, 'old_walkstyle', getPedWalkingStyle(player) , 'one' )
		setPedWalkingStyle( player, style )
		return true
	end
end

function unsetForceWalkStyle(player)
	local style = getElementData( player, 'old_walkstyle')
	if style then
		setPedWalkingStyle( player, style )
		removeElementData( player, 'old_walkstyle' )
		return true
	end
end

addEventHandler( 'account:character:select', root, function ()
	unsetForceWalkStyle(source)
end)

addEventHandler( 'onResourceStop', resourceRoot, function()
	for i, player in pairs( getElementsByType('player') ) do
		unsetForceWalkStyle(player)
	end
end)