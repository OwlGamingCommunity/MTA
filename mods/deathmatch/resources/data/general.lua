--MAXIME
local general = {}
function save(data, accessKey)
	if data then
		general[accessKey] = data
		return true
	else
		return false
	end
end

function load(accessKey)
	if general[accessKey] then
		local tmp = general[accessKey]
		general[accessKey] = nil
		return tmp
	else
		return false
	end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	local dataToRestore = getElementData(root, "resource:data:restore")
	if dataToRestore then
		general = dataToRestore
		setElementData(root, "resource:data:restore", nil, false)
	end
end)

addEventHandler("onClientResourceStop", resourceRoot, function()
	setElementData(root, "resource:data:restore", general, false)
end)

addEventHandler("onResourceStart", resourceRoot, function()
	local dataToRestore = getElementData(root, "resource:data:restore")
	if dataToRestore then
		general = dataToRestore
		setElementData(root, "resource:data:restore", nil, false)
	end
end)

addEventHandler("onResourceStop", resourceRoot, function()
	setElementData(root, "resource:data:restore", general, false)
end)