function reloadTime()
	setElementData(root, "server:Timestamp", getRealTime().timestamp)
end

addEventHandler("onResourceStart", resourceRoot, function()
	reloadTime()
	setTimer(reloadTime, 1000, 0)
end)

function getServerTimestamp()
	return getRealTime().timestamp
end