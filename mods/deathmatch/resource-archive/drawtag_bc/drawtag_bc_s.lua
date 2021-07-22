function initDrawtagBC()
	if initialized then return end
	initialized = true
	addEventHandler("drawtag:onTagStartSpray",root,startDrawMsg)
	addEventHandler("drawtag:onTagFinishSpray",root,finishDrawMsg)
	addEventHandler("drawtag:onTagStartErase",root,startEraseMsg)
	addEventHandler("drawtag:onTagFinishErase",root,finishEraseMsg)
	addCommandHandler("drawtag",modeDraw)
	addCommandHandler("erasetag",modeErase)
	addCommandHandler("tagsize",changeSize)
	addEvent("drawtag_bc:copyTag",true)
	addEventHandler("drawtag_bc:copyTag",root,copyTag)
	loadTagsFromFile()
	local all_players = getElementsByType("player")
	for plnum,player in ipairs(all_players) do
		exports.drawtag:setPlayerTagSize(player,1.5)
	end
	addEventHandler("onPlayerJoin",root,setDefaultTagSize)
end

function uninitDrawtagBC()
	if not initialized then return end
	initialized = nil
	removeEventHandler("drawtag:onTagStartSpray",root,startDrawMsg)
	removeEventHandler("drawtag:onTagFinishSpray",root,finishDrawMsg)
	removeEventHandler("drawtag:onTagStartErase",root,startEraseMsg)
	removeEventHandler("drawtag:onTagFinishErase",root,finishEraseMsg)
	removeCommandHandler("drawtag",modeDraw)
	removeCommandHandler("erasetag",modeErase)
	removeCommandHandler("tagsize",changeSize)
	removeEventHandler("drawtag_bc:copyTag",root,copyTag)
	saveTagsToFile()
	removeEventHandler("onPlayerJoin",root,setDefaultTagSize)
end

function initOnStart(resource)
	if getResourceName(resource) == "drawtag" then
		initDrawtagBC()
	elseif source == resourceRoot and getResourceState(getResourceFromName("drawtag")) == "running" then
		initDrawtagBC()
	end
end

function uninitOnStop(resource)
	if getResourceName(resource) == "drawtag" then
		uninitDrawtagBC()
	elseif source == resourceRoot and getResourceState(getResourceFromName("drawtag")) == "running" then
		uninitDrawtagBC()
	end
end

addEventHandler("onResourceStart",root,initOnStart)
addEventHandler("onResourceStop",root,uninitOnStop)

function setDefaultTagSize()
	exports.drawtag:setPlayerTagSize(source,1.5)
end

function startDrawMsg(player)
	--outputChatBox(identifyPlayer(player).." started spraying a tag.")
end

function finishDrawMsg(player)
	--outputChatBox(identifyPlayer(player).." finished spraying a tag.")
end

function startEraseMsg(player)
	--outputChatBox(identifyPlayer(player).." started erasing a tag.")
end

function finishEraseMsg(player)
	--outputChatBox(identifyPlayer(player).." finished erasing a tag.")
end

function identifyPlayer(player)
	return player and getPlayerName(player) or "Unknown player"
end

function modeDraw(player)
	exports.drawtag:setPlayerSprayMode(player,"draw")
	outputChatBox("Spraying mode: draw",player)
end

function modeErase(player)
	exports.drawtag:setPlayerSprayMode(player,"erase")
	outputChatBox("Spraying mode: erase",player)
end

function changeSize(player,cmdname,size)
	size = tonumber(size)
	if not size or math.abs(size) > 1000 then return end
	if not exports.drawtag:setPlayerTagSize(player,size) then return end
	outputChatBox("Tag size changed to "..size,player)
end

function copyTag()
	local png = exports.drawtag:getTagTexture(source)
	exports.drawtag:setPlayerTagTexture(client,png)
	outputChatBox("Tag texture copied",client)
end

