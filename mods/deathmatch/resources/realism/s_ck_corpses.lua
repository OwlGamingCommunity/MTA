mysql = exports.mysql

local CKs = {}
local araces = {"White", "Asian", [0] = "Black"}
local descriptionNames = {"Hair Color", "Hair Style", "Facial Features", "Physical Features", "Clothing", "Accessoires"}
local function getCharacterDescription(desc)
	local charDescription = fromJSON(desc)
	if type(charDescription) == 'table' then
		local text = ''
		for key, value in ipairs(charDescription) do
			if not descriptionNames[key] then
				break
			end

			text = text .. "\n" .. descriptionNames[key] .. ": " .. value
		end
		return text
	end

	-- not a table
	return tostring(desc)
end

function addCharacterKillBody( x, y, z, rotation, skin, id, name, interior, dimension, age, race, weight, height, desc, cod, gender )
	local ped = createPed(skin, x, y, z)
	setElementFrozen(ped, true)
	setPedRotation(ped, rotation)
	setElementInterior(ped, interior)
	setElementDimension(ped, dimension)
	exports.anticheat:changeProtectedElementDataEx(ped, "ckid", id, false)
	exports.pool:allocateElement(ped)
	killPed(ped)

	CKs[ped] = { name = name:gsub("_", " "), text = "Corpse appears to be a " .. araces[race] .. " " .. ( gender == 1 and "Female" or "Male" ) .. "  between the ages of " .. age - 2 .. " and " .. age + 2 .. ". The corpse weighs around " .. weight .. "kg and looks about " .. height .. "cm tall.\n" .. getCharacterDescription(desc) .. "\n\nPossible Cause of Death: \n" .. cod }

	addEventHandler("onElementDestroy", ped, function() CKs[source] = nil end, false)

	return ped
end

addEvent("ck:info", true)
addEventHandler("ck:info", getRootElement(),
	function()
		if CKs[source] then
			triggerClientEvent(client, "ck:show", client, CKs[source].text, exports.integration:isPlayerTrialAdmin(client) and CKs[source].name)
		end
	end
)

function loadAllCorpses(res)
	local result = mysql:query("SELECT x, y, z, skin, rotation, id, charactername, interior_id, dimension_id, age, weight, height, ck_info, description, skincolor, gender FROM characters WHERE cked = 1")
	
	local counter = 0
	local rowc = 1
	
	if (result) then
		local continue = true
		while continue do
			local row = mysql:fetch_assoc(result)
			if not row then
				break
			end
			local x = tonumber(row["x"])
			local y = tonumber(row["y"])
			local z = tonumber(row["z"])
			local skin = tonumber(row["skin"])
			local rotation = tonumber(row["rotation"])
			local id = tonumber(row["id"])
			local name = row["charactername"]
			if name == mysql_null() then
				name = ""
			end
			local interior = tonumber(row["interior_id"])
			local dimension = tonumber(row["dimension_id"])
			
			local age = tonumber(row["age"])
			local race = tonumber(row["skincolor"])
			local weight = tonumber(row["weight"])
			local height = tonumber(row["height"])
			local cod = row["ck_info"]
			local desc = row["description"]
			if desc == mysql_null() then
				desc = "unknown"
			end
			if cod == mysql_null() then
				cod = "unknown"
			end
			local gender = tonumber(row["gender"])

			addCharacterKillBody(x, y, z, rotation, skin, id, name, interior, dimension, age, race, weight, height, desc, cod, gender)
		end
		mysql:free_result(result)
	end
	
	-- Garage Stuff
	local result = mysql:query_fetch_assoc("SELECT value FROM settings WHERE name = 'garagestates'" )
	if result then
		local res = result["value"]
		local garages = fromJSON( res )
		
		if garages then
			for i = 0, 49 do
				setGarageOpen( i, garages[tostring(i)] )
			end
		else
			outputDebugString( "Failed to load Garage States" )
		end
	end
end
addEventHandler("onResourceStart", getResourceRootElement(), loadAllCorpses)

function getNearbyCKs(thePlayer, commandName)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) or exports.factions:isInFactionType(thePlayer, 4) then
		local posX, posY, posZ = getElementPosition(thePlayer)
		outputChatBox("Nearby Character Kill Bodies:", thePlayer, 255, 126, 0)
		local count = 0
		
		for ped, data in pairs(CKs) do
			if data then
				if isElement(ped) then
					local x, y, z = getElementPosition(ped)
					local distance = getDistanceBetweenPoints3D(posX, posY, posZ, x, y, z)
					if getElementDimension(ped) == getElementDimension(thePlayer) and (distance<=20) then
						outputChatBox("   " .. data.name, thePlayer, 255, 126, 0)
						count = count + 1
					end
				end
			end
		end
		
		if (count==0) then
			outputChatBox("   None.", thePlayer, 255, 126, 0)
		end
	end
end
addCommandHandler("nearbycks", getNearbyCKs, false, false)

-- in remembrance of
local function showCKList( thePlayer, data )
	local result = mysql:query("SELECT charactername FROM characters WHERE cked = " .. mysql:escape_string(data) .. " ORDER BY charactername")
	if result then
		local names = {}
		local continue = true
		while continue do
			row = mysql:fetch_assoc(result)
			if not row then
				break
			end
			local name = row["charactername"]
			if name ~= mysql_null() then
				names[ #names + 1 ] = name
			end
		end
		triggerClientEvent( thePlayer, "showCKList", thePlayer, names, data )
		mysql:free_result(result)
	end
end

local ckBuried = createPickup( 815, -1100, 25.8, 3, 1254 )
addEventHandler( "onPickupHit", ckBuried,
	function( thePlayer )
		cancelEvent()
		showCKList( thePlayer, 2 )
	end
)

local ckMissing = createPickup( 819, -1100, 25.8, 3, 1314 )
addEventHandler( "onPickupHit", ckMissing,
	function( thePlayer )
		cancelEvent()
		showCKList( thePlayer, 1 )
	end
)