function toSQL(stuff)
	return exports.mysql:escape_string(stuff)
end

function getSmallestIdFromDbTable(tableName) -- finds the smallest ID in the SQL instead of auto increment
	if not tableName then
		return false
	end
	local result = exports.mysql:query_fetch_assoc("SELECT MIN(e1.id+1) AS nextID FROM "..tableName.." AS e1 LEFT JOIN "..tableName.." AS e2 ON e1.id +1 = e2.id WHERE e2.id IS NULL")
	if result then
		local id = tonumber(result["nextID"]) or 1
		return id
	end
	return false
end