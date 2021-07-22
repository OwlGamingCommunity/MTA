function fetchNotamData()
	local table = exports.mysql:query_fetch_assoc("SELECT `information` FROM `pilot_notams` WHERE `id`='1'")
	local info = table and table["information"] or "No input"

	return info
	--triggerClientEvent("listenToServerCall", resourceRoot, tostring(info))
end
--addEvent("fetchNotamData", true)
--addEventHandler("fetchNotamData", resourceRoot, fetchNotamData)

function updateNotamData(data)
	if exports.mysql:query_free("UPDATE `pilot_notams` SET `information`='"..exports.global:toSQL(data).."' WHERE `id`='1'") then
	end
end
addEvent("updateNotamData", true)
addEventHandler("updateNotamData", root, updateNotamData)

function startGUI()
	triggerClientEvent(source, "build_Dialog", source, fetchNotamData())
end
addEvent("startFAAmapGUI", true)
addEventHandler("startFAAmapGUI", root, startGUI)
--addCommandHandler("maps", startGUI)

-- Unknown column id in WHERE clause wfewew
