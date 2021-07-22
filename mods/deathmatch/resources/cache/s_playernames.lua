local mysql = exports.mysql

local charCache = {}
local singleCharCache = {}
local cacheUsed = 0

local function secondArg( a, b )
	return b
end

local function makeName( a, b )
	-- find first and last name
	local ax, ay = a:sub( 1, a:find( "_" ) - 1 ), a:sub( secondArg( a:find( "_" ) ) + 1 )
	local bx, by = b:sub( 1, b:find( "_" ) - 1 ), b:sub( secondArg( b:find( "_" ) ) + 1 )

	if ay == by then
		return ax .. " & " .. bx .. " " .. by
	else
		return a .. " & " .. b
	end
end

function stats()
	return cacheUsed
end

function getCharacterName( id, singleName )
	if not charCache[ id ] then
		id = tonumber(id)
		if not (id < 1) then
			local query = mysql:query_fetch_assoc("SELECT charactername, gender, marriedto FROM characters WHERE id = " .. mysql:escape_string(id) .. " LIMIT 1")
			if query then
				local name = query["charactername"]
				local gender = tonumber(query["gender"])
				local marriedto = tonumber(query["marriedto"])

				if name then
					singleCharCache[ id ] = name:gsub("_", " ")
					if marriedto > 0 then
						local query = mysql:query_fetch_assoc("SELECT charactername, gender FROM characters WHERE id = " .. mysql:escape_string(marriedto) .. " LIMIT 1")
						if query then
							local name2 = query["charactername"]
							local gender2 = tonumber(query["gender"])
							singleCharCache[ marriedto ] = name2:gsub("_", " ")
							if name2 ~= mysql_null( ) then
								if gender == gender2 then
									if name < name2 then
										name = makeName( name, name2 )
									else
										name = makeName( name2, name )
									end
								elseif gender == 1 then
									name = makeName( name, name2 )
								else
									name = makeName( name2, name )
								end
							end
						end
					end
					charCache[ id ] = name:gsub("_", " ")
				end
			end
		else
			charCache[ id ] = false
			singleCharCache[ id ] = false
		end
	else
		cacheUsed = cacheUsed + 1
	end
	return singleName and singleCharCache[ id ] or charCache[ id ]
end

function clearCharacterName( id )
	charCache[ id ] = nil
	singleCharCache[ id ] = nil
	triggerClientEvent("clearCharacterNameCache", resourceRoot, id)
end

function clearCharacterCache()
	charCache = { }
	singleCharCache = { }
end
