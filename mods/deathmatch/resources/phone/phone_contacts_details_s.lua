--MAXIME
function updateContactDetails(id, name, number, email, address, favo)
	if not id or not name or not number or not tonumber(id) or not tonumber(number) or string.len(name) < 1 or string.len(number) < 1 then
		return false
	end
	if mysql:query_free("UPDATE `phone_contacts` SET `entryName`='"..exports.global:toSQL(name).."', `entryNumber`='"..exports.global:toSQL(number).."', `entryEmail`='"..exports.global:toSQL(email).."', `entryAddress`='"..exports.global:toSQL(address).."', `entryFavorited`='"..exports.global:toSQL(favo).."' WHERE `id`='"..exports.global:toSQL(id).."' ") then
		triggerClientEvent(source, "phone:contacts:details:update:response", source, id, name, number, email, address, favo)
		return true
	end
	triggerClientEvent(source, "phone:contacts:details:update:response", source, false)
	return false
end
addEvent("phone:contacts:details:update", true)
addEventHandler("phone:contacts:details:update", root, updateContactDetails)

function deleteContact(id)
	if not id or not tonumber(id) then
		return false
	end
	if mysql:query_free("DELETE FROM `phone_contacts` WHERE `id`='"..exports.global:toSQL(id).."' ") then
		triggerClientEvent(source, "phone:contacts:details:delete:response", source, id)
		return true
	end
	triggerClientEvent(source, "phone:contacts:details:delete:response", source, false)
	return false
end
addEvent("phone:contacts:details:delete", true)
addEventHandler("phone:contacts:details:delete", root, deleteContact)