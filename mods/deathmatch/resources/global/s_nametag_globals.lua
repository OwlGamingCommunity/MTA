function updateNametagColor(thePlayer)
	if source then thePlayer = source end
	if getElementData(thePlayer, "loggedin") ~= 1 then -- Not logged in
		setPlayerNametagColor(thePlayer, 127, 127, 127)
	elseif (exports.integration:isPlayerLeadScripter(thePlayer) and getElementData(thePlayer, "admin_level") == 10 ) and getElementData(thePlayer, "duty_admin") == 1 and getElementData(thePlayer, "hiddenadmin") == 0 then -- Scripter Duty
		setPlayerNametagColor(thePlayer, 14, 194, 255)
	elseif (exports.integration:isPlayerLeadAdmin(thePlayer) and getElementData(thePlayer, "admin_level") <= 5 ) and getElementData(thePlayer, "duty_admin") == 1 and getElementData(thePlayer, "hiddenadmin") == 0 then -- UAT Duty
		setPlayerNametagColor(thePlayer, 14, 194, 255)
	elseif (exports.integration:isPlayerTrialAdmin(thePlayer) and getElementData(thePlayer, "admin_level") <= 5 ) and getElementData(thePlayer, "duty_admin") == 1 and getElementData(thePlayer, "hiddenadmin") == 0 then -- Admin on duty
		setPlayerNametagColor(thePlayer, 255, 194, 14)
	elseif exports.integration:isPlayerSupporter(thePlayer) and (getElementData(thePlayer, "duty_supporter") == 1) and getElementData(thePlayer, "hiddenadmin") == 0 then
		setPlayerNametagColor(thePlayer, 70, 200, 30)
	elseif exports.donators:hasPlayerPerk(thePlayer, 11) then
		setElementData(thePlayer, "donation:nametag", true, true)
		if getElementData(thePlayer, "nametag_on") then
			setPlayerNametagColor(thePlayer, 167, 133, 63)
		else
			setPlayerNametagColor(thePlayer, 255, 255, 255)
		end
	else
		setPlayerNametagColor(thePlayer, 255, 255, 255)
	end
end
addEvent("updateNametagColor", true)
addEventHandler("updateNametagColor", getRootElement(), updateNametagColor)

for key, value in ipairs( getElementsByType( "player" ) ) do
	updateNametagColor( value )
end

function toggleGoldenNametag()
	if not getElementData(client, "donation:nametag") and not getElementData(client, "donation:lifeTimeNameTag") then
		return
	end

	setElementData(client, "lifeTimeNameTag_on", not getElementData(client, "lifeTimeNameTag_on"), true)
	setElementData(client, "nametag_on", not getElementData(client, "nametag_on"), true)
	updateNametagColor(client)
end
addEvent("global:toggleGoldenNametag", true)
addEventHandler("global:toggleGoldenNametag", getRootElement(), toggleGoldenNametag)
