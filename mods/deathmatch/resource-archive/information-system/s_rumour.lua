--mysql = exports.mysql
--[[
function SmallestID() -- finds the smallest ID in the SQL instead of auto increment
	local result = mysql:query_fetch_assoc("SELECT MIN(e1.id+1) AS nextID FROM districts AS e1 LEFT JOIN marijuanaplants AS e2 ON e1.id +1 = e2.id WHERE e2.id IS NULL")
	if result then
		local id = tonumber(result["nextID"]) or 1
		return id
	end
	return false
end

function loadAllDistrictInformation()
	local ticks = getTickCount( )
	local counter = 0
	local result = mysql:query("SELECT * FROM `district`")
	while true do
		local row = mysql:fetch_assoc(result)
		if not row then break end
		district = tonumber(row["district"])
		rumour = tonumber(row["rumour"])
		counter = counter + 1
	end
	outputDebugString("Loaded " .. counter .. " marijuana plants in " .. ( getTickCount( ) - ticks ) .. "ms")
end
addEventHandler("onResourceStart", getResourceRootElement(), loadAllMarijuanaPlants)
]]
function showDistrictInformation(thePlayer, commandName)
	local zoneName = exports.global:getElementZoneName(thePlayer, false)
	outputDebugString(zoneName)
	--local result = mysql:query("SELECT district FROM `district` WHERE district="..mysql.escape-szoneName.."")
end
addCommandHandler("showdistrictinformation", showDistrictInformation, false, false)