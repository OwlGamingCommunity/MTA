function initSpraying()
	addEvent("drawtag:onTagStartSpray",true)
	addEvent("drawtag:onTagFinishSpray",true)
	addEvent("drawtag:onTagStartErase",true)
	addEvent("drawtag:onTagFinishErase",true)
	tag_root = createElement("drawtag:tags","drawtag:tags")
	addEventHandler("onElementDataChange",tag_root,detectSprayOrErase)
	addEventHandler("onElementDestroy",root,destroyAttachedTags)
	addEventHandler("onElementDestroy",resourceRoot,unlinkTagFromAttached)
	addEventHandler("onPlayerJoin",root,createTagOnJoin)
	addEventHandler("onPlayerQuit",root,destroyTagOnQuit)
	local all_players = getElementsByType("player")
	for plnum,player in ipairs(all_players) do initSprayingForPlayer(player) end
end

function createTagForPlayer(player,pngdata)
	local player_tag = createElement("drawtag:tag")
	setElementParent(player_tag,tag_root)
	setElementData(player,"drawtag:tag",player_tag)
	if pngdata then
		setElementData(player_tag,"pngdata",pngdata)
	end
end

function initSprayingForPlayer(player)
	createTagForPlayer(player)
	addEventHandler("onElementDataChange",player,createAnotherTagForPlayer)
end

function createAnotherTagForPlayer(dataname,oldval)
	if
		client ~= source or
		dataname ~= "drawtag:tag" or
		getElementData(source,"drawtag:tag")
	then
		return
	end
	local pngdata
	if isElement(oldval) then
		triggerEvent("drawtag:onTagStartSpray",oldval,source)
		pngdata = getElementData(oldval,"pngdata")
	end
	createTagForPlayer(source,pngdata)
end

function createTagOnJoin()
	initSprayingForPlayer(source)
end

function destroyTagOnQuit()
	local tag = getElementData(source,"drawtag:tag")
	if not isElement(tag) then return end
	destroyElement(tag)
end

function detectSprayOrErase(dataname,oldval)
	if no_datachange_trigger then return end
	if dataname ~= "visibility" then return end
	local visibility = getElementData(source,"visibility")
	if visibility == 90 then
		triggerEvent("drawtag:onTagFinishSpray",source,client)
	elseif visibility == 0 then
		triggerEvent("drawtag:onTagFinishErase",source,client)
		destroyElement(source)
	elseif oldval == 90 then
		triggerEvent("drawtag:onTagStartErase",source,client)
	end
end

function destroyAttachedTags()
	local attlist = getElementData(source,"drawtag:attached")
	if attlist then
		attlist.n = nil
		no_tag_destroy_trigger = true
		for tag,attached in pairs(attlist) do
			destroyElement(tag)
		end
		no_tag_destroy_trigger = nil
	end
end

function unlinkTagFromAttached()
	if getElementType(source) ~= "drawtag:tag" then return end
	if no_tag_destroy_trigger then return end
	local att = getElementData(source,"attached")
	if att then
		local attlist = getElementData(att,"drawtag:attached")
		attlist[source] = nil
		attlist.n = attlist.n-1
		if attlist.n == 0 then
			removeElementData(att,"drawtag:attached")
		else
			setElementData(att,"drawtag:attached",attlist)
		end
	end
end

-----------------------------------------------------

function setPlayerSprayMode(player,mode)
	if not isElement(player) or getElementType(player) ~= "player" then return false end
	if mode == "none" then
		return removeElementData(player,"drawtag:spraymode")
	elseif mode == "draw" or mode == "erase" then
		return setElementData(player,"drawtag:spraymode",mode)
	end
end

function getPlayerSprayMode(player)
	if not isElement(player) or getElementType(player) ~= "player" then return false end
	return getElementData(player,"drawtag:spraymode") or "none"
end

function setPlayerTagSize(player,size)
	size = tonumber(size)
	if not size or size <= 0 then return false end
	if not isElement(player) or getElementType(player) ~= "player" then return false end
	setElementData(player,"drawtag:size",size)
	return true
end

function getPlayerTagSize(player)
	if not isElement(player) or getElementType(player) ~= "player" then return false end
	return getElementData(player,"drawtag:size")
end

function setPlayerTagTexture(player,pngdata)
	if not isElement(player) or getElementType(player) ~= "player" then return false end
	local tag = getElementData(player,"drawtag:tag")
	if not isElement(tag) then return false end
	setElementData(tag,"pngdata",pngdata)
	return true
end

-----------------------------------------------------

function createTagFromExistingData(attached,x,y,z,x1,y1,z1,x2,y2,z2,nx,ny,nz,size,visibility,pngdata)
	if attached and not isElement(attached) then return false end
	x,y,z = tonumber(x),tonumber(y),tonumber(z)
	if not (x and y and z) then return false end
	x1,y1,z1 = tonumber(x1),tonumber(y1),tonumber(z1)
	if not (x1 and y1 and z1) then return false end
	x2,y2,z2 = tonumber(x2),tonumber(y2),tonumber(z2)
	if not (x2 and y2 and z2) then return false end
	nx,ny,nz = tonumber(nx),tonumber(ny),tonumber(nz)
	if not (nx and ny and nz) then return false end
	visibility = tonumber(visibility)
	if not visibility then return false end
	if type(pngdata) ~= "string" then return false end
	local tag = createElement("drawtag:tag")
	setElementParent(tag,tag_root)
	no_datachange_trigger = true

	if attached then
		setElementData(tag,"attached",attached)
		local attlist = getElementData(attached,"drawtag:attached") or {n = 0}
		attlist[tag] = true
		attlist.n = attlist.n+1
		setElementData(attached,"drawtag:attached",attlist)
	end

	setElementData(tag,"x",x)
	setElementData(tag,"y",y)
	setElementData(tag,"z",z)
	setElementData(tag,"x1",x1)
	setElementData(tag,"y1",y1)
	setElementData(tag,"z1",z1)
	setElementData(tag,"x2",x2)
	setElementData(tag,"y2",y2)
	setElementData(tag,"z2",z2)
	setElementData(tag,"nx",nx)
	setElementData(tag,"ny",ny)
	setElementData(tag,"nz",nz)
	setElementData(tag,"size",size)
	setElementData(tag,"visibility",visibility)
	setElementData(tag,"pngdata",pngdata)
	setElementData(tag,"visible",true)
	no_datachange_trigger = nil
	return tag
end

function getAllTags()
	local tagcount = getElementChildrenCount(tag_root)
	local tags = {}
	for tagnum = 0,tagcount-1 do
		local tag = getElementChild(tag_root,tagnum)
		if getElementData(tag,"visible") then table.insert(tags,tag) end
	end
	return tags
end

function getTagAttachedElement(tag)
	if not isElement(tag) or getElementType(tag) ~= "drawtag:tag" then return false end
	return getElementData(tag,"attached")
end

function getTagPosition(tag)
	if not isElement(tag) or getElementType(tag) ~= "drawtag:tag" then return false end
	return getElementData(tag,"x"),getElementData(tag,"y"),getElementData(tag,"z")
end

function getTagNormal(tag)
	if not isElement(tag) or getElementType(tag) ~= "drawtag:tag" then return false end
	return getElementData(tag,"nx"),getElementData(tag,"ny"),getElementData(tag,"nz")
end

function getTagSize(tag)
	if not isElement(tag) or getElementType(tag) ~= "drawtag:tag" then return false end
	return getElementData(tag,"size")
end

function getTagTexture(tag)
	if not isElement(tag) or getElementType(tag) ~= "drawtag:tag" then return false end
	return getElementData(tag,"pngdata")
end

function getTagData(tag)
	if not isElement(tag) or getElementType(tag) ~= "drawtag:tag" then return false end
	if not getElementData(tag,"visible") then return false end
	return
		getElementData(tag,"attached"),
		getElementData(tag,"x" ),getElementData(tag,"y" ),getElementData(tag,"z" ),
		getElementData(tag,"x1"),getElementData(tag,"y1"),getElementData(tag,"z1"),
		getElementData(tag,"x2"),getElementData(tag,"y2"),getElementData(tag,"z2"),
		getElementData(tag,"nx"),getElementData(tag,"ny"),getElementData(tag,"nz"),
		getElementData(tag,"size"),
		getElementData(tag,"visibility"),getElementData(tag,"pngdata")
end

