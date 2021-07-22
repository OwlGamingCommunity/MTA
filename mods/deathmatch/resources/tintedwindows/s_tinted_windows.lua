
function responce()
	triggerClientEvent(source, "legitimateResponceRecived", source)
end
addEvent("tintDemWindows", true)
addEventHandler("tintDemWindows", getRootElement(), responce)