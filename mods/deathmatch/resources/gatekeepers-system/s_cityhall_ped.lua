addEvent("cityhall:makeIdCard", true)
addEventHandler("cityhall:makeIdCard", root,
	function ()
		local characterName = getPlayerName(client)
		local gender = getElementData(client, "gender")
		local month = getElementData(client, "month")
		local day = getElementData(client, "day")
		local year = getElementData(client, "year")
		local fingerprint = getElementData(client, "fingerprint")
		if characterName and gender and month and day and year and fingerprint and exports.global:takeMoney(client, 5) then
			exports.global:giveItem( client, 152, characterName..";" .. (gender==0 and "Male" or "Female")..";"..exports.global:numberToMonth(month or 1).." "..exports.global:formatDate(day or 1)..", "..year..";"..fingerprint)
			outputChatBox("A new Identification Card has been created and given into your inventory for $5.", client)
		else
			outputChatBox("You need $5 for a new ID card.", client)
		end
	end
)
