--MAXIME

function writeCellphoneLog(convs, from, type, to )
	if source == localPlayer then
		for i, message in ipairs(convs) do
			exports.OwlGamingLogs:writeCellphoneLog(exports.global:getPlayerName(localPlayer), from, type, to, message )
		end
	end
end
addEvent("phone:writeCellphoneLog", true)
addEventHandler("phone:writeCellphoneLog", root, writeCellphoneLog)