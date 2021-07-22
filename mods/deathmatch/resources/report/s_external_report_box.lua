--MAXIME
local thisResourceElement = getResourceRootElement(getThisResource())

function showToAllAdminPanel(content, r,g,b)
	if string.len(content) > 105 then
		local content1 = string.sub(content,1,115)
		local content2 = string.sub(content,116)
		setElementData(thisResourceElement ,"reportPanel",  {content1, r, g, b} , true)
		showToAllAdminPanel(content2, r,g,b)
	else
		setElementData(thisResourceElement ,"reportPanel",  {content, r, g, b} , true)
	end
end

function showToAdminPanel(content, specifiedPlayer, r,g,b)
	if string.len(content) > 105 then
		local content1 = string.sub(content,1,115)
		local content2 = string.sub(content,116)
		triggerClientEvent(specifiedPlayer, "report-system:updateOverlay" , specifiedPlayer, {content1, r, g, b, 255,1, "default"})
		showToAdminPanel(content2,specifiedPlayer, r,g,b)
	else
		triggerClientEvent(specifiedPlayer, "report-system:updateOverlay" , specifiedPlayer, {content, r, g, b, 255,1, "default"})
	end
end