function updateHudClock()
	-- 			watch											cellphone                                      PDA
	if exports.global:hasItem(getLocalPlayer(), 17) or exports.global:hasItem(getLocalPlayer(), 2) or exports.global:hasItem(getLocalPlayer(), 96) or not getPedOccupiedVehicle(getLocalPlayer()) == false then
		showPlayerHudComponent("clock", true)
	else
		showPlayerHudComponent("clock", false)
	end
end
addEvent ( "updateHudClock", true )
addEventHandler ( "updateHudClock", getRootElement(), updateHudClock )
