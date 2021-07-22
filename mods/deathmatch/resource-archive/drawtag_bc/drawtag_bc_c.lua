addCommandHandler("draw",function()
	local drawtag = getResourceFromName("drawtag")
	if not (drawtag and getResourceRootElement(drawtag)) then return end
	local show = not exports.drawtag:isDrawingWindowVisible()
	exports.drawtag:showDrawingWindow(show)
end)

addCommandHandler("edittag",function()
	local drawtag = getResourceFromName("drawtag")
	if not (drawtag and getResourceRootElement(drawtag)) then return end
	local x,y,z = getElementPosition(localPlayer)
	local tag = getNearestTag(x,y,z)
	if not tag then return end
	local png = exports.drawtag:getTagTexture(tag)
	exports.drawtag:setEditorTexture(png)
	outputChatBox("Tag texture copied into editor")
end)

addCommandHandler("copytag",function()
	local drawtag = getResourceFromName("drawtag")
	if not (drawtag and getResourceRootElement(drawtag)) then return end
	local x,y,z = getElementPosition(localPlayer)
	local tag = getNearestTag(x,y,z)
	if not tag then return end
	triggerServerEvent("drawtag_bc:copyTag",tag)
end)

