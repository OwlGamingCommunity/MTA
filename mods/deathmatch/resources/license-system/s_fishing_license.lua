mysql = exports.mysql

function giveFishLicense(usingGC)
	if usingGC then
		local perk = exports.donators:getPerks(22)
		local success, reason = exports.donators:takeGC(client, perk[2])
		if success then
			exports.donators:addPurchaseHistory(client, perk[1], -perk[2])
		else
			exports.hud:sendBottomNotification(client, "Department of Motor Vehicles", "Could not take GCs from your account. Reason: "..reason.."." )
			return false
		end
	end

	dbExec(exports.mysql:getConn('mta'), "UPDATE characters SET fish_license='1' WHERE id = ?", getElementData(client, 'dbid'))
	exports.anticheat:changeProtectedElementDataEx(client, "license.fish", 1)
	exports.hud:sendBottomNotification(source, "Department of Motor Vehicles", "Congratulations! You now have a permit for fishing the waters of San Andreas." )
	exports.global:giveItem(client, 154, getPlayerName(client):gsub("_"," "))
	executeCommandHandler("stats", client, getPlayerName(client))
end
addEvent("acceptFishLicense", true)
addEventHandler("acceptFishLicense", getRootElement(), giveFishLicense)