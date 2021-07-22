-- by anumaz
-- for owlgaming 2015-03-04

--[[

Database table

CREATE TABLE `owl_mta`.`faa_registry` (
  `codeid` INT NOT NULL,
  `owner` VARCHAR(45) NULL,
  `condition` VARCHAR(45) NULL,
  `notes` LONGTEXT NULL,
  PRIMARY KEY (`codeid`));

]]

local mysql = exports.mysql

addEventHandler("onResourceStart", resourceRoot,
	function()
		local result = mysql:query( "SELECT `codeid`, `owner`, `condition`, `notes`, `x`, `y` FROM `faa_registry`")
		local result_table = { }
		while true do
			local row = mysql:fetch_assoc( result )
			if not row then
				break
			end
			row.codeid = tonumber(row.codeid)
			result_table[row.codeid] = {}
			result_table[row.codeid]["owner"] = row.owner
			result_table[row.codeid]["condition"] = row.condition
			result_table[row.codeid]["notes"] = row.notes
			result_table[row.codeid]["x"] = row.x
			result_table[row.codeid]["y"] = row.y
			--table.insert(result_table, row)
		end
		mysql:free_result( result )
		setElementData(resourceRoot, "faa:registrytable", result_table)
	end)

function sqlQuery(uniquecode, owner, condition, location)
	if uniquecode and owner and condition and location then
		mysql:query_free("INSERT INTO `faa_registry` SET `codeid`="..mysql:escape_string(uniquecode)..", `owner`='"..mysql:escape_string(owner).."', `condition`='"..mysql:escape_string(condition).."', `notes`='Initial location: "..mysql:escape_string(location).."'")
	end
end
addEvent("faa:sqlQuery", true)
addEventHandler("faa:sqlQuery", resourceRoot, sqlQuery)

function editRegistry(code, owner, condition, newnote, client)
	if not isElement(client) then return false end
	local time = getRealTime()
	local content = string.gsub(getPlayerName(client), "_", " ").." - "..time.hour..":"..time.minute.." on "..tonumber(time.year + 1900).."/"..tonumber(time.month + 1).."/"..time.monthday
	code = tonumber(code) or false
	if code then
		local t = getElementData(resourceRoot, "faa:registrytable")
		local newnotecontent = t[code]["notes"]
		if newnote then
			newnotecontent = t[code]["notes"].."\n\n"..content.."\n"..newnote
		end
		mysql:query_free("UPDATE `faa_registry` SET `owner`='"..mysql:escape_string(owner).."', `condition`='"..mysql:escape_string(condition).."', `notes`='"..mysql:escape_string(newnotecontent).."' WHERE `codeid`="..mysql:escape_string(code))
		t[code]["owner"] = owner or t[code]["owner"]
		t[code]["condition"] = condition or t[code]["condition"]
		t[code]["notes"] = newnotecontent
		setElementData(resourceRoot, "faa:registrytable", t)
	end
end
addEvent("faa:editregistry", true)
addEventHandler("faa:editregistry", resourceRoot, editRegistry)

function deleteRegistry(code)
	code = tonumber(code)
	if code then
		mysql:query_free("DELETE FROM `faa_registry` WHERE `codeid`="..mysql:escape_string(code))
	end
end
addEvent("faa:deleteregistry", true)
addEventHandler("faa:deleteregistry", resourceRoot, deleteRegistry)

function addCoordinates(code, x, y)
	code = tonumber(code)
	x = tonumber(x)
	y = tonumber(y)
	if code and x and y then
		mysql:query_free("UPDATE `faa_registry` SET `x`="..mysql:escape_string(x)..", `y`="..mysql:escape_string(y).." WHERE `codeid`="..mysql:escape_string(code))
	end
end
addEvent("faa:addCoordinates", true)
addEventHandler("faa:addCoordinates", resourceRoot, addCoordinates)
