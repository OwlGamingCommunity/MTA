addEvent("weaponDistrict:doDistrict", true)

function weaponDistrict_doDistrict(name)
	exports["chat-system"]:districtIC(client, _, "You'd hear a series of loud " .. name .. " gunshots echoing throughout the vicinity")
end

addEventHandler("weaponDistrict:doDistrict", root, weaponDistrict_doDistrict)