function quitPlayer(quitReason, reason)
	if not (getElementData(source, "reconx")) then
		if (quitReason == "Timed out") or (quitReason == "Bad Connection") then
			exports.global:sendLocalText(source, "(( "..getPlayerName(source):gsub("_", " ").." disconnected (".. quitReason .."). ))", nil, nil, nil, 10)
		elseif (quitReason == "Kicked" and reason == "Away From Keyboard") then
			exports.global:sendLocalText(source, "(( "..getPlayerName(source):gsub("_", " ").." disconnected (AFK Kick). ))", nil, nil, nil, 10)
		end
	end
end
addEventHandler("onPlayerQuit",getRootElement(), quitPlayer)