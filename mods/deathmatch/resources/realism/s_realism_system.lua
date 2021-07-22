function onStealthKill(targetPlayer)
	--exports.global:sendMessageToAdmins("[ANTIDM] Blocked stealth kill from "..getPlayerName(source) .." against " .. getPlayerName(targetPlayer))
    cancelEvent(true)
end
addEventHandler("onPlayerStealthKill", getRootElement(), onStealthKill)

addEventHandler("onResourceStart", resourceRoot, function()
		setAircraftMaxHeight(20000) -- Limit in Z for aircrafts to fly
	end)