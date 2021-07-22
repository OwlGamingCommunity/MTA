local mysql = exports.mysql
function isThisGunDuplicated(itemId, itemValue, fromPlayer)
	local itemCheckExplode = exports.global:explode(":", itemValue)
	local serial = itemCheckExplode and itemCheckExplode[itemId==115 and 2 or 3]
	if not serial then
		return false
	end
	
	local row1 = mysql:query_fetch_assoc("SELECT COUNT(*) AS 'inv' FROM `items` WHERE `itemValue` LIKE '%" .. mysql:escape_string(serial) .. "%' " ) or false
	if row1 and tonumber(row1.inv) then
		row1 = tonumber(row1.inv)
	else
		row1 = 0
	end
	
	local row2 = mysql:query_fetch_assoc("SELECT COUNT(*) AS 'world' FROM `worlditems` WHERE `itemvalue` LIKE '%" .. mysql:escape_string(serial) .. "%' " ) or false
	if row2 and tonumber(row2.world) then
		row2 = tonumber(row2.world)
	else
		row2 = 0
	end
	
	if (row1+row2) > 1 then
		exports.global:sendMessageToAdmins("[ITEM SYSTEM] Weapon duplicate detected and deleted from player " ..(fromPlayer and exports.global:getPlayerName(fromPlayer) or "Unknown").. "." )
		return true
	end
	return false
end