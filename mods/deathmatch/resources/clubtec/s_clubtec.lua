--clubtec
--Script that adds functionality for a range of items
--Created by Exciter, 23.06.2014 (DD.MM.YYYY).

addEvent("clubtec:vs1000:gui", true)
addEventHandler("clubtec:vs1000:gui", root, function(element)
	worlditems = exports['item-world']
	local currentFakevideo
	local videoData
	local currentFakevideo = getVideoPlayerCurrentVideoDisc(element) or 0
	if currentFakevideo and currentFakevideo > 1 then
		videoData = exports.fakevideo:getFakevideoData(currentFakevideo)
	else
		videoData = false
	end
	local texture = getElementData(element, "itemValue")
	local data = worlditems:getData(element, "shaderData", "table") or {}
	local shaderData = { 
		brightness = data.brightness or shaderDataDefault.brightness,
		scrollX = data.scrollX or shaderDataDefault.scrollX,
		scrollY = data.scrollY or shaderDataDefault.scrollY,
		xScale = data.xScale or shaderDataDefault.xScale,
		yScale = data.yScale or shaderDataDefault.yScale,
		rotAngle = data.rotAngle or shaderDataDefault.rotAngle,
		alpha = data.alpha or shaderDataDefault.alpha,
		grayScale = data.grayScale or shaderDataDefault.grayScale,
		redColor = data.redColor or shaderDataDefault.redColor,
		grnColor = data.grnColor or shaderDataDefault.grnColor,
		bluColor = data.bluColor or shaderDataDefault.bluColor,
		xOffset = data.xOffset or shaderDataDefault.xOffset,
		yOffset = data.yOffset or shaderDataDefault.yOffset,
		speed = data.speed or shaderDataDefault.speed
	}
	local generalData = {texture = texture, video = currentFakevideo}
	local powerOn = worlditems:getData(element, "active") == 1 or false
	triggerClientEvent(client or source, "clubtec:vs1000:gui", resourceRoot, element, generalData, shaderData, videoData, powerOn)
end)

addEvent("clubtec:vs1000:ejectDisc", true)
addEventHandler("clubtec:vs1000:ejectDisc", root, function(element, powerOn)
	if not element then return false end
	items = exports['item-system']
	local theSlot
	local inventory = items:getItems(element) --{ slot = { itemID, itemValue } }
	for slot,v in pairs(inventory) do
		if isVideoDisc(tonumber(v[1])) then
			theSlot = slot
			break
		end
	end
	--outputDebugString("client='"..tostring(client).."' element='"..tostring(element).."' theSlot='"..tostring(theSlot).."'")
	if not theSlot then return false end
	items:moveItem(element, client, theSlot)
	--triggerEvent("moveFromElement", client, element, theSlot)
	if powerOn then
		for key, value in ipairs(getElementsByType("player")) do
			if getElementDimension(value)==getElementDimension(element) then
				triggerEvent("fakevideo:loadDimension", value)
			end
		end
	end
	return true
end)

addEvent("clubtec:vs1000:togglePower", true)
addEventHandler("clubtec:vs1000:togglePower", resourceRoot, function(element, powerOn)
	if not element then return false end
	worlditems = exports['item-world']

	worlditems:setData(element, "active", powerOn and 1 or 0)

	for key, value in ipairs(getElementsByType("player")) do
		if getElementDimension(value)==getElementDimension(element) then
			triggerEvent("fakevideo:loadDimension", value)
		end
	end
	return true
end)

addEvent("clubtec:vs1000:updateSettings", true)
addEventHandler("clubtec:vs1000:updateSettings", resourceRoot, function(element, data, powerOn)
	if not isElement(element) then return end
	worlditems = exports['item-world']
	local newTexture = data.texture
	local oldTexture = getElementData(element, "itemValue")
	if(newTexture ~= oldTexture) then
		worlditems:updateItemValue(element, newTexture)
	end
	local shaderData = { 
		brightness = data.brightness or shaderDataDefault.brightness,
		scrollX = data.scrollX or shaderDataDefault.scrollX,
		scrollY = data.scrollY or shaderDataDefault.scrollY,
		xScale = data.xScale or shaderDataDefault.xScale,
		yScale = data.yScale or shaderDataDefault.yScale,
		rotAngle = data.rotAngle or shaderDataDefault.rotAngle,
		alpha = data.alpha or shaderDataDefault.alpha,
		grayScale = data.grayScale or shaderDataDefault.grayScale,
		redColor = data.redColor or shaderDataDefault.redColor,
		grnColor = data.grnColor or shaderDataDefault.grnColor,
		bluColor = data.bluColor or shaderDataDefault.bluColor,
		xOffset = data.xOffset or shaderDataDefault.xOffset,
		yOffset = data.yOffset or shaderDataDefault.yOffset,
		speed = data.speed or shaderDataDefault.speed
	}
	local oldShaderData = worlditems:getData(element, "shaderData", "table") or {}
	local anythingNew = false
	if(shaderData.brightness ~= oldShaderData.brightness) then
		anythingNew = true
	elseif(shaderData.scrollX ~= oldShaderData.scrollX) then
		anythingNew = true
	elseif(shaderData.scrollY ~= oldShaderData.scrollY) then
		anythingNew = true
	elseif(shaderData.xScale ~= oldShaderData.xScale) then
		anythingNew = true
	elseif(shaderData.yScale ~= oldShaderData.yScale) then
		anythingNew = true
	elseif(shaderData.rotAngle ~= oldShaderData.rotAngle) then
		anythingNew = true
	elseif(shaderData.alpha ~= oldShaderData.alpha) then
		anythingNew = true
	elseif(shaderData.grayScale ~= oldShaderData.grayScale) then
		anythingNew = true
	elseif(shaderData.redColor ~= oldShaderData.redColor) then
		anythingNew = true
	elseif(shaderData.grnColor ~= oldShaderData.grnColor) then
		anythingNew = true
	elseif(shaderData.bluColor ~= oldShaderData.bluColor) then
		anythingNew = true
	elseif(shaderData.xOffset ~= oldShaderData.xOffset) then
		anythingNew = true
	elseif(shaderData.yOffset ~= oldShaderData.yOffset) then
		anythingNew = true
	elseif(shaderData.speed ~= oldShaderData.speed) then
		anythingNew = true
	end
	if anythingNew then
		worlditems:setData(element, "shaderData", shaderData)
		if powerOn then
			local dimension = getElementDimension(element)
			local players = getElementsInDimension("player",dimension)
			triggerClientEvent(players, "fakevideo:updateShader", resourceRoot, oldTexture, nil, shaderData, newTexture, nil, oldShaderData.speed, shaderData.speed)
		end
	end
end)

function getElementsInDimension(theType,dimension)
    local elementsInDimension = { }
      for key, value in ipairs(getElementsByType(theType)) do
        if getElementDimension(value)==dimension then
        table.insert(elementsInDimension,value)
        end
      end
      return elementsInDimension
end

function getVideoPlayerCurrentVideoDisc(element)
	if isVideoPlayer(element) then
		items = exports['item-system']
		local inventory = items:getItems(element) --{ slot = { itemID, itemValue } }
		local disc = 0
		for slot,v in pairs(inventory) do
			if isVideoDisc(tonumber(v[1])) then
				disc = tonumber(v[2]) or 0
				break
			end
		end
		if disc > 1 then
			return disc
		end
	end
	return false
end

function tempVidSysSpawn(thePlayer, commandName)
	if isClubtecGuy(thePlayer) then
		local success, reason = exports.global:giveItem(thePlayer, 166, 1)
		if success then
			outputChatBox("Check your inventory.", thePlayer, 0, 255, 0)
			--exports.logs:dbLog(thePlayer, 4, targetPlayer, "tempvsspawn "..name.." "..tostring(itemValue))
			triggerClientEvent(thePlayer, "item:updateclient", thePlayer)
		else
			outputChatBox("Couldn't make a video system: " .. tostring(reason), thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("tempvsspawn", tempVidSysSpawn, false, true)