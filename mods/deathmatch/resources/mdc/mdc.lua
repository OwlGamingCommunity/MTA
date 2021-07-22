local possibleLicenses = {
	--[database field] = text
	gun_license = 'Firearm License - Tier 1',
	gun2_license = 'Firearm License - Tier 2',
	car_license = 'Driver\'s License - Automotive',
	bike_license = 'Driver\'s License - Motorbike',
	--pilot_license = 'San Andreas Pilot Certificate',
	fish_license = 'Fishing Permit',
	boat_license = 'Driver\'s License - Boat',
}

local PD_VEHICLES = { 427, 490, 528, 523, 598, 596, 597, 599, 601 }
local resourceName = getResourceName( getThisResource( ) )


-- CACHE (Exciter) --
mdc_users = {}
mdc_criminals = {}
mdc_faa_licenses = {}
apb = {}
anpr = {}

function cacheOnStart()
	--mdc_users
	--[[
	local result = exports.mysql:query("SELECT * FROM `mdc_users`")
	if result then
		while true do
			local row = exports.mysql:fetch_assoc(result)
			if not row then break end
			table.insert(mdc_users, { id = row.id, user = row.user, pass = md5(row.pass), level = row.level, organization = row.organization })
		end
		exports.mysql:free_result(result)
	end
	--]]

	--mdc_faa_licenses
	local startTime = getTickCount()
	local result = exports.mysql:query("SELECT * FROM `mdc_faa_licenses`")
	if result then
		local theTable = {}
		while true do
			row = exports.mysql:fetch_assoc(result)
			if not row then break end
			local thisValues = {}
			for key,value in pairs(row) do
				thisValues[key] = value
			end
			table.insert(theTable, thisValues)
		end
		mdc_faa_licenses = theTable
		exports.mysql:free_result(result)
		outputDebugString("Loaded "..tostring(#mdc_faa_licenses).." pilot licenses in "..tostring(math.ceil(getTickCount()-startTime)).."ms.")
	else
		outputDebugString("mdc-system/mdc.lua: Failed to load pilot licenses!",2)
	end
	
	local anprResult = dbQuery( exports.mysql:getConn('mta'), "SELECT a.*, charactername FROM mdc_anpr a LEFT JOIN characters c ON c.id=a.doneby ORDER BY time ASC" )
	local results, num_affected_rows, last_insert_id = dbPoll ( anprResult, 10000 )
	if results and num_affected_rows > 0 then
		for i, row in ipairs( results ) do
			local res = {}
			res[1] = row.vehicle_plate
			res[2] = row.description or "Unknown"
			res[3] = getCharacterNameFromID( row.charactername, 2 )
			res[4] = row.id
			res[5] = row.organization or "Unknown"
			res[6] = row.time
			table.insert( anpr, res )
		end
	else
		dbFree( anprResult )
    end

	local qh = dbQuery( exports.mysql:getConn('mta'), "SELECT a.*, charactername FROM mdc_apb a LEFT JOIN characters c ON c.id=a.doneby ORDER BY time ASC" )
	local results, num_affected_rows, last_insert_id = dbPoll ( qh, 10000 )
	if results and num_affected_rows > 0 then
		for i, row in ipairs( results ) do
			local res = {}
			res[1] = row.person_involved
			res[2] = row.description or "Unknown"
			res[3] = getCharacterNameFromID( row.charactername, 2 )
			res[4] = row.id
			res[5] = row.organization or "Unknown"
			res[6] = row.time
			table.insert( apb, res )
		end
	else
		dbFree( qh )
	end
end
addEventHandler("onResourceStart", getResourceRootElement(), cacheOnStart)

------------------------------------------
function getMDCNameFromID( id )
	local row = nil
	local result = exports.mysql:query( "SELECT charid FROM mdc_users WHERE `id` = '"..id.."'" )
	if exports.mysql:num_rows( result ) > 0 then
		row = exports.mysql:fetch_assoc( result )
		exports.mysql:free_result( result )
		local name = exports.cache:getCharacterNameFromID(row.charid)
		local playerName = name and split( tostring(name) , " " )
		local firstLetter = playerName and string.sub( playerName[ 1 ], 1, 1 )
		local playerName = firstLetter and (firstLetter .. playerName[ 2 ]) or 'Unknown'
		return playerName
	else
		return false
	end
end

function getCharacterNameFromID( name, org )
	if name then
		if tonumber(name) then
			name = exports.cache:getCharacterNameFromID(name)
		else
			name = string.gsub( name, "_", " ")
		end

		if org then
			local usernameFormat = 1
			local groups = getElementData( resourceRoot, 'mdc_groups' )
			if groups and groups[ org ] and groups[ org ].settingUsernameFormat then
				usernameFormat = groups[ org ].settingUsernameFormat
			end

			if usernameFormat == 2 then
			if name then
				local playerName = split( name, " " )
				local firstLetter = string.sub( playerName[ 1 ], 1, 1 )
				local playerName = firstLetter .. playerName[ 2 ]
				return playerName
			else
				return 'Unknown'
			end

			else
				return name
			end
		else
			--format 2
			if name then
				local playerName = split( name, " " )
				local firstLetter = string.sub( playerName[ 1 ], 1, 1 )
				local playerName = firstLetter .. playerName[ 2 ]
				return playerName
			else
				return 'Unknown'
			end
		end
	else
		return 'Unknown'
	end
end

------------------------------------------
function login( charid, silent )
	charid = tonumber(charid) or getElementData( source, "dbid" )
	local accountQuery = dbQuery( exports.mysql:getConn('mta'), "SELECT * FROM mdc_users WHERE `charid` = ? ", charid )
	local res, nums, id = dbPoll( accountQuery, 10000 )
	if res and nums > 0 then
		local account = {}
		for _, row in pairs( res ) do
			account[ row.organization ] = row.level
		end
		exports.anticheat:setEld( source, "mdc_account", account, 'one' )
		if silent then
			return account
		else
			triggerEvent( 'mdc:main', source )
		end
	else
		dbFree( accountQuery )
		if not silent then
			outputChatBox( "You do not have an account with sufficient access to use the MDC.", source, 255, 155, 155 )
		end
	end
end
addEvent( 'mdc:login', true )
addEventHandler( 'mdc:login', root, login )

function main ( )
	local warrants = { }
	local calls = { }

	if canAccess( source, 'canSeeWarrants' ) then
		local warrantResult = exports.mysql:query( "SELECT `character`,`wanted_by`,`wanted_details` FROM `mdc_criminals` WHERE `wanted` = '1'" )
		if ( warrantResult ) then
			local count = 1
			while true do
				row = exports.mysql:fetch_assoc( warrantResult )
				if not row then break end
				warrants[count] = { }

				--Fetch character name from ID
				local char = nil
				local characterResult = exports.mysql:query( "SELECT `charactername` FROM `characters` WHERE `id` = '".. exports.mysql:escape_string( row.character ) .."'" )
				if exports.mysql:num_rows( characterResult ) > 0 then
					char = exports.mysql:fetch_assoc( characterResult )
				end
				warrants[count][1] = char.charactername

				--Fetch mdc account name from ID
				local account = nil
				local accountResult = exports.mysql:query( "SELECT `charid`,`organization` FROM mdc_users WHERE `id` = '".. exports.mysql:escape_string( row.wanted_by ) .."'" )
				if exports.mysql:num_rows( accountResult ) > 0 then
					account = exports.mysql:fetch_assoc( accountResult )
				end
				warrants[count][3] = account and getCharacterNameFromID(account.charid, thisOrg) or "Unknown"
				warrants[count][4] = account and account.organization or "Unknown"
				warrants[count][2] = row.wanted_details
				count = count + 1
			end
			exports.mysql:free_result( warrantResult )
		end
	end

	if canAccess( source, 'canSeeCalls' ) then
		local callsResult = exports.mysql:query( "SELECT m.id, m.number, m.description, m.timestamp, c.charactername FROM `mdc_calls` m LEFT OUTER JOIN `mdc_criminals` t ON m.number = t.phone LEFT OUTER JOIN characters c ON c.id = t.character ORDER BY m.id DESC LIMIT 20" )
		if ( callsResult ) then
			while true do
				row = exports.mysql:fetch_assoc( callsResult )
				if not row then break end

				table.insert(calls, { row.id, row.charactername, row.number, row.description, row.timestamp })
			end
			exports.mysql:free_result( callsResult )
		end
	end

	local impounds = {}
	local org, level, can = canAccess( source, 'impound_can_see' )
	if can then
		local lanes = exports['tow-system']:getImpoundLanes( org )
		for i, lane in pairs(lanes) do
			local oneLane = {}
			oneLane.lane = tonumber(lane.lane)
			oneLane.impounder = tonumber(lane.faction)
			if tonumber(lane.veh) ~= 0 then
				local veh = exports.pool:getElement("vehicle", lane.veh)
				if veh and getElementData(veh, "impounder") == oneLane.impounder and getElementData(veh, "Impounded") ~= 0 then
					oneLane.id = getElementData(veh, "dbid")
					oneLane.vin = getElementData(veh, "show_vin") == 1 and getElementData(veh, "dbid") or "No VIN"
					oneLane.plate = getElementData(veh, "show_plate") == 1 and getElementData(veh, "plate") or "No Plate"
					oneLane.name = exports.global:getVehicleName(veh)
					oneLane.release_date = lane.release_date
					oneLane.fine = tonumber(lane.fine)
				else
					dbExec( exports.mysql:getConn('mta'), "UPDATE leo_impound_lot SET veh=0, release_date=NULL, fine=0 WHERE veh=?", lane.veh )
				end
			end
			table.insert(impounds, oneLane)
		end
	end
	triggerClientEvent( source, resourceName .. ":main", getRootElement(), warrants, apb, impounds, calls, anpr )
end
addEvent( 'mdc:main', true )
addEventHandler( 'mdc:main', root, main )

function search( query, queryType )
	if not queryType then --No type selected.
		triggerClientEvent( source, resourceName .. ":search_error", root )
	elseif queryType == "Person" or tonumber(queryType) == 0 then --Person
		local character = nil
		local criminal = nil
		local wantedUser = nil
		local crimesRow = nil

		local result = exports.mysql:query( "SELECT * FROM characters WHERE `charactername` = '".. exports.mysql:escape_string( query:gsub( " ", "_" ) ) .."'" ) --Fetch the information from the database about our character.


		if exports.mysql:num_rows( result ) > 0 then
			character = exports.mysql:fetch_assoc( result )
			local result2 = exports.mysql:query( "SELECT * FROM `mdc_criminals` WHERE `character` = '".. character.id .."'" ) --Select what the PD already knows about this character.

			if exports.mysql:num_rows( result2 ) > 0 then --This MDC profile has been visited before.
				criminal = exports.mysql:fetch_assoc( result2 )
			else -- Nobody has gone to this person's MDC, so lets create a template for them to add information to.
				local query = exports.mysql:query_insert_free( "INSERT INTO `mdc_criminals` ( `character` ) VALUES ('"..character.id.."')" )
				local result2 = exports.mysql:query( "SELECT * FROM `mdc_criminals` WHERE `character` = '".. character.id .."'" ) --Select what the PD already knows about this character.
				if query then
					if exports.mysql:num_rows( result2 ) > 0 then --This MDC profile has been visited before.
						criminal = exports.mysql:fetch_assoc( result2 )
					end
				end
			end



			if tonumber( criminal.wanted ) == 1 then
				result3 = getMDCNameFromID( criminal.wanted_by )
				criminal.wanted_by = "No-one"
				if result3 then
					criminal.wanted_by = result3
				end
			end

			local vehicles = { }
			local result4 = exports.mysql:query( "SELECT v.id, v.model, `plate`, c.vehbrand, c.vehmodel, c.vehyear FROM `vehicles` v LEFT JOIN vehicles_shop c ON v.vehicle_shop_id = c.id WHERE `owner` = '".. character.id .."' AND deleted = 0 AND registered = 1" )
			if ( result4 ) then
				local count = 1
				local _, _, value = canAccess( source, 'name' )
				local isFAA = value == 'FAA'
				while true do
					row = exports.mysql:fetch_assoc( result4 )
					if not row then break end
					vehicles[count] = { }
					if isFAA then --FAA only get aircrafts listed
						if(getVehicleType(tonumber(row.model)) == "Plane" or getVehicleType(tonumber(row.model)) == "Helicopter") then
							vehicles[count][1] = row.id
							if row.vehbrand and row.vehmodel and row.vehyear and row.vehbrand ~= mysql_null() and row.vehmodel ~= mysql_null() and row.vehyear ~= mysql_null() then
								vehicles[count][2] = row.vehyear .. " " .. row.vehbrand .. " " .. row.vehmodel
							else
								vehicles[count][2] = row.model
							end
							vehicles[count][3] = row.plate
							count = count + 1
						end
					else
						vehicles[count][1] = row.id
						if row.vehbrand and row.vehmodel and row.vehyear and row.vehbrand ~= mysql_null() and row.vehmodel ~= mysql_null() and row.vehyear ~= mysql_null() then
							vehicles[count][2] = row.vehyear .. " " .. row.vehbrand .. " " .. row.vehmodel
						else
							vehicles[count][2] = row.model
						end
						vehicles[count][3] = row.plate
						count = count + 1
					end
				end

				exports.mysql:free_result( result4 )
			end

			local properties = { }
			local result5 = exports.mysql:query( "SELECT `id`, `name` FROM `interiors` WHERE `owner` = '".. character.id .."'" )
			if ( result5 ) then
				local count = 1
				while true do
					row = exports.mysql:fetch_assoc( result5 )
					if not row then break end
					properties[count] = { }
					properties[count][1] = row.id
					properties[count][2] = row.name
					count = count + 1

				end

				exports.mysql:free_result( result5 )
			end

			local crimes = { }
			local result6 = exports.mysql:query( "SELECT * FROM `mdc_crimes` WHERE `character` = '".. character.id .."' ORDER BY `id` DESC" )
			if ( result6 ) then
				local count = 1
				while true do
					row = exports.mysql:fetch_assoc( result6 )
					if not row then break end
					crimes[count] = { }
					crimes[count][1] = row.id
					crimes[count][2] = row.crime
					crimes[count][3] = row.punishment
					crimes[count][4] = getCharacterNameFromID( row.officer )
					crimes[count][5] = row.timestamp
					count = count + 1

				end

				exports.mysql:free_result( result5 )
			end

			local licenses = {}
			for dbfield, name in pairs(possibleLicenses) do
				local val = tonumber(character[dbfield])
				if val == 1 then
					table.insert(licenses, name)
				elseif val ~= 0 then
					outputDebugString('MDC: Database field ' .. dbfield .. ' for characters doesnt exist')
				end
			end

			local pilotEvents = { }
			local pilotLicenses = { }
			--if(getElementData(source, "mdc_org") == "FAA") then
			if canAccess( source, 'canSeePilotStuff' ) then
				local result7 = exports.mysql:query( "SELECT * FROM `mdc_faa_events` WHERE `character` = '".. character.id .."' ORDER BY `id` DESC" )
				if ( result7 ) then
					local count = 1
					while true do
						row = exports.mysql:fetch_assoc( result7 )
						if not row then break end
						pilotEvents[count] = { }
						pilotEvents[count][1] = row.id
						pilotEvents[count][2] = row.crime
						pilotEvents[count][3] = row.punishment
						pilotEvents[count][4] =  row.officer --getMDCNameFromID()
						pilotEvents[count][5] = row.timestamp
						count = count + 1
					end

					exports.mysql:free_result( result7 )
				end

				if mdc_faa_licenses then
					local result8 = {}
					for k,v in ipairs(mdc_faa_licenses) do
						if(tonumber(v.character) == tonumber(character.id)) then
							table.insert(result8, v)
						end
					end
					local count = 1
					for k,row in ipairs(result8) do
						if not row then break end
						--outputDebugString(" id="..tostring(row.id).." license="..tostring(row.license).." value="..tostring(row.value).." officer="..tostring(row.officer).." timestamp="..tostring(row.timestamp))
						pilotLicenses[count] = { }
						pilotLicenses[count][1] = row.id
						pilotLicenses[count][2] = row.license
						pilotLicenses[count][3] = row.value
						pilotLicenses[count][4] = row.officer --getMDCNameFromID()
						pilotLicenses[count][5] = row.timestamp
						count = count + 1
					end
				else
					local result8 = exports.mysql:query( "SELECT * FROM `mdc_faa_licenses` WHERE `character` = '".. character.id .."' ORDER BY `id` ASC" )
					if ( result8 ) then
						local count = 1
						while true do
							row = exports.mysql:fetch_assoc( result8 )
							if not row then break end
							pilotLicenses[count] = { }
							pilotLicenses[count][1] = row.id
							pilotLicenses[count][2] = row.license
							pilotLicenses[count][3] = row.value
							pilotLicenses[count][4] = row.officer --getMDCNameFromID()
							pilotLicenses[count][5] = row.timestamp
							count = count + 1
						end
						exports.mysql:free_result( result8 )
					end
				end
			end

			local dmvhistory = {}
			local result9 =  exports.mysql:query("SELECT * FROM `mdc_dmv` WHERE `char` = '".. character.id .."' ORDER BY `id` ASC" )
			if ( result9 ) then
				local count = 1 
				while true do 
					row = exports.mysql:fetch_assoc( result9 )
					if not row then break end
					dmvhistory[count] = { }
					dmvhistory[count][1] = row.date
					dmvhistory[count][2] = row.vehicle 
					dmvhistory[count][3] = row.status
					count = count + 1
				end
				exports.mysql:free_result( result9 )
			end

			triggerClientEvent( source, resourceName .. ":display_person", root, character.charactername, character.age, character.weight, character.height, character.gender, licenses, character.pdjail, criminal.dob, criminal.ethnicity, criminal.phone, criminal.occupation, criminal.address, criminal.photo, criminal.details, criminal.created_by, criminal.wanted, criminal.wanted_by, criminal.wanted_details, character.id, vehicles, properties, crimes, pilotEvents, criminal.pilot_details, pilotLicenses, dmvhistory)

			exports.mysql:free_result( result )
		else
			triggerClientEvent( source, resourceName .. ":search_noresult", root )
		end
	elseif (queryType == "Vehicle by Plate" or tonumber(queryType) == 1) or (queryType == "Vehicle by VIN" or tonumber(queryType) == 3) then --Vehicle
		local q = ""
		if queryType == "Vehicle by Plate" or tonumber(queryType) == 1 then
			q = "v.plate = '".. exports.mysql:escape_string( query ) .. "'"
		elseif queryType == "Vehicle by VIN" or tonumber(queryType) == 3 then
			q = "v.id = '".. exports.mysql:escape_string( query ) .. "'"
		else
			return false
		end

		local vehicle = exports.mysql:query_fetch_assoc( "SELECT v.*, c.vehbrand, c.vehmodel, c.vehyear FROM `vehicles` v LEFT JOIN vehicles_shop c ON v.vehicle_shop_id = c.id WHERE " .. q .. " AND deleted = 0 AND registered = 1 LIMIT 1" ) --Fetch the information from the database
		if vehicle and vehicle.id ~= mysql_null() then
			local crimes = { }
			local result2 = exports.mysql:query( "SELECT * FROM `speedingviolations` WHERE `carID` = '".. vehicle.id .."' ORDER BY `id` DESC" )
			if ( result2 ) then
				local count = 1
				while true do
					row = exports.mysql:fetch_assoc( result2 )
					if not row then break end
					crimes[count] = { }
					crimes[count][1] = row.time
					crimes[count][2] = row.speed
					crimes[count][3] = row.area
					crimes[count][4] = exports.cache:getCharacterName(row["personVisible"]) or "Not visible"
					count = count + 1

				end
				exports.mysql:free_result( result2 )
			end

			if tonumber( vehicle.owner ) ~= -1 then
				local owner = nil
				local result3 = exports.mysql:query( "SELECT `charactername` FROM `characters` WHERE `id` = '".. exports.mysql:escape_string( vehicle.owner ).."'" )
				if exports.mysql:num_rows( result3 ) > 0 then
					owner = exports.mysql:fetch_assoc( result3 )
				end
				vehicle.owner = owner and (owner.charactername or "Unknown") or "Unknown"
				vehicle.owner_type = 1
			elseif tonumber( vehicle.faction ) ~= -1 then
				local owner = nil
				local result3 = exports.mysql:query( "SELECT `name` FROM `factions` WHERE `id` = '".. exports.mysql:escape_string( vehicle.faction ).."'" )
				if exports.mysql:num_rows( result3 ) > 0 then
					owner = exports.mysql:fetch_assoc( result3 )
				end
				vehicle.owner = owner.name
				vehicle.owner_type = 2
			else
				vehicle.owner = "None"
				vehicle.owner_type = 0
			end


			vehicle.model = "(("..tostring(mtamodelname).."))"

			local vehElement = exports.pool:getElement("vehicle", vehicle.id)
			local impounded = 0
			local impounder = 0
			if vehElement then
				impounded = getElementData(vehElement, "Impounded") or 0
				impounder = getElementData(vehElement, "impounder") or 0
				vehicle.model = exports.global:getVehicleName(vehElement).." (("..getVehicleName(vehElement).."))"
			end

			local imps = {}
			local q = exports.mysql:query("SELECT * FROM mdc_impounds WHERE veh="..vehicle.id)
			while q do
				local row = exports.mysql:fetch_assoc(q)
				if not row then break end
				table.insert(imps, row)
			end
			exports.mysql:free_result(q)

			triggerClientEvent( source, resourceName .. ":display_vehicle", root, vehicle.id, vehicle.model, vehicle.color1, vehicle.color2, vehicle.color3, vehicle.color4, vehicle.plate, vehicle.faction, vehicle.owner, vehicle.owner_type, {impounded, impounder, imps}, vehicle.stolen, crimes )
		else
			triggerClientEvent( source, resourceName .. ":search_noresult", root )
		end
	elseif queryType == "Property by ZIP Code (( ID ))" or tonumber(queryType) == 2 then --Property
		local result = exports.mysql:query( "SElECT * FROM interiors WHERE `id` = '"..exports.mysql:escape_string( query ).."'" )
		if exports.mysql:num_rows( result ) > 0 then
			interior = exports.mysql:fetch_assoc( result )
			if tonumber( interior.type ) == 0 then
				interior.type = "House"
			elseif tonumber( interior.type ) == 1 then
				interior.type = "Business"
			elseif tonumber( interior.type ) == 2 then
				interior.type = "Government"
			else
				interior.type = "Apartment"
			end

			local owner
			local ownerClickable = false
			if tonumber(interior.owner) > 0 then
				owner = exports.cache:getCharacterName( interior.owner )
				ownerClickable = true
			else
				owner = exports.cache:getFactionNameFromId(interior.faction)
			end

			if not owner then
				owner = 'N/A'
				ownerClickable = false
			end

			local district = getZoneName ( interior.x, interior.y, interior.z, false ) .. ", " .. getZoneName ( interior.x, interior.y, interior.z, true )
			triggerClientEvent ( source, resourceName .. ":display_property", root, interior.id, interior.type, owner, interior.cost, interior.name, interior.address, district, tonumber(interior.dimensionwithin), ownerClickable )
		else
			triggerClientEvent( source, resourceName .. ":search_error", root )
		end
	else --This wasn't called by the client GUI, and therefore do nothing.
		return false
	end
end
--addEvent("mdc:search", true)
--addEventHandler("mdc:search", root, search)

function add_crime( charid, charactername, crime, punishment, prefer_officer )
	local officer = prefer_officer or getElementData( source, 'dbid' )
	local time = getRealTime()
	local timestamp = time.timestamp
	local addCrime = exports.mysql:query_insert_free( "INSERT INTO `mdc_crimes` ( `crime`, `punishment`, `character`, `officer`, `timestamp` ) VALUES ( '"..exports.mysql:escape_string( crime ).."','"..exports.mysql:escape_string( punishment ).."','"..charid.."','"..officer.."', '"..timestamp.."' )" )
	if addCrime and officer ~= 532 then
		search( charactername, 0 )
	end
end
addEvent("mdc-system:add_crime", true)
addEventHandler("mdc-system:add_crime", getRootElement(), add_crime)

--apb = person_involved, description, CharNameFromID, ID, Org
function add_apb( type, description, person )
	local officer = getElementData( source, "dbid" )
	local time = getRealTime( )
	local timestamp = time.timestamp
	local _,_,org = canAccess( source, 'name' )
	if type == "APB" then
		local query = dbQuery( exports.mysql:getConn('mta'), "INSERT INTO `mdc_apb` ( `person_involved`, `description`, `doneby`, `time`, `organization` ) VALUES (?, ?, ?, ?, ?) ", person, description, officer, timestamp, org )
		local res, nums, id = dbPoll( query, 10000 )
		if res and nums > 0 then
			local officerName = getCharacterNameFromID( officer, 2 )
			table.insert( apb, {person, description, officerName, id, org, timestamp} )

			if query then
				triggerEvent( "mdc:main", source )
			end

			--For the Client dxDraw
			--updateClientAPB( apb )
		else
			outputDebugString("[MDC] Shit went wrong. Code 565.")
			dbFree( query )
		end
	elseif type == "ANPR" then
		local plate = person
		local query = dbQuery( exports.mysql:getConn('mta'), "INSERT INTO `mdc_anpr` ( `vehicle_plate`, `description`, `doneby`, `time`, `organization` ) VALUES (?, ?, ?, ?, ?)", plate, description, officer, timestamp, org)
		local res, nums, id = dbPoll( query, 10000 )
		if res and nums > 0 then
			local officerName = getCharacterNameFromID( officer, 2 )
			table.insert( anpr, {plate, description, officerName, id, org, timestamp} )

			if query then
				triggerEvent( "mdc:main", source )
			end
		else
			outputDebugString("[MDC] Shit went wrong. Code 565.")
			dbFree( query )
		end	
	end		
end

function add_pilot_event( charid, charactername, crime, punishment )
	--local officer = getElementData( source, "mdc_account" )
	local officer = getPlayerName(source):gsub("_", " ")
	local time = getRealTime( )
	local timestamp = time.timestamp
	local query = exports.mysql:query_insert_free( "INSERT INTO `mdc_faa_events` ( `crime`, `punishment`, `character`, `officer`, `timestamp` ) VALUES ( '"..exports.mysql:escape_string( crime ).."','"..exports.mysql:escape_string( punishment ).."','"..charid.."','"..exports.mysql:escape_string(officer).."', '"..timestamp.."' )" )
	if query then
		search( charactername, 0 )
	end
end

function add_pilot_license( charid, charactername, license, aircraft )
	--outputDebugString("add_pilot_license("..tostring(charid)..", "..tostring(charactername)..", "..tostring(license)..", "..tostring(aircraft)..")")
	--local officer = getElementData( source, "mdc_account" )
	local officer = getPlayerName(source):gsub("_", " ")
	local time = getRealTime( )
	local timestamp = time.timestamp
	if(license ~= 7) then
		aircraft = "NULL"
	end
	local query = exports.mysql:query_insert_free( "INSERT INTO `mdc_faa_licenses` ( `license`, `value`, `character`, `officer`, `timestamp` ) VALUES ( '"..exports.mysql:escape_string( license ).."',"..exports.mysql:escape_string(tostring(aircraft))..",'"..charid.."','"..exports.mysql:escape_string(officer).."', '"..timestamp.."' )" )
	if query then
		if mdc_faa_licenses then
			local insert = {id = tonumber(query), license = license, value = aircraft, character = charid, officer = officer, timestamp = timestamp}
			table.insert(mdc_faa_licenses, insert)
		end
		--[[
		local targetPlayer = exports.global:getPlayerFromCharacterID(charid)
		if targetPlayer then
			getPlayerPilotLicenses(targetPlayer, true)
		end
		--]]
		search( charactername, 0 )
	end
end

function remove_crime( charactername, crime_id )

	local query = exports.mysql:query( "DELETE FROM `mdc_crimes` WHERE `id` = '"..crime_id.."'" )
	if query then
		search( charactername, 0 )
	end
end

function remove_apb( id )
	for i, row in pairs( apb ) do
		if row[4] == tonumber( id ) then
			table.remove( apb, i )
			break
		end
	end

	triggerEvent( "mdc:main", source )

	updateClientAPB()
	dbExec( exports.mysql:getConn('mta'), "DELETE FROM `mdc_apb` WHERE `id` = ? ", id )
end

function remove_pilot_event( charactername, crime_id )
	local query = exports.mysql:query( "DELETE FROM `mdc_faa_events` WHERE `id` = '"..crime_id.."'" )
	if query then
		search( charactername, 0 )
	end
end

function remove_pilot_license( charid, charactername, license_uid, licensetext )
	local query = exports.mysql:query( "DELETE FROM `mdc_faa_licenses` WHERE `id` = '"..exports.mysql:escape_string(tostring(license_uid)).."'" )
	if query then
		local match
		if mdc_faa_licenses then
			for k,v in ipairs(mdc_faa_licenses) do
				if tonumber(v.id) == tonumber(license_uid) then
					match = k
					break
				end
			end
		end
		if match then
			table.remove(mdc_faa_licenses, match)
		end
		add_pilot_event( charid, charactername, "License Revoked (MDC)", tostring(licensetext) )
		--[[
		local targetPlayer = exports.global:getPlayerFromCharacterID(charid)
		if targetPlayer then
			getPlayerPilotLicenses(targetPlayer, true)
		end
		--]]
	end
end

function update_person( charid, charactername, dob, ethnicity, phone, occupation, address, photo )
	if tonumber(photo) == -2 then
		local qSkin = exports.mysql:query( "SELECT `skin` FROM `characters` WHERE `id` = '"..exports.mysql:escape_string( charid ).."' " )
		if exports.mysql:num_rows( qSkin ) > 0 then
			local row = exports.mysql:fetch_assoc( qSkin )
			photo = row.skin
		end
	end

	photo       = exports.mysql:escape_string( photo )
	dob			= exports.mysql:escape_string( dob )
	ethnicity	= exports.mysql:escape_string( ethnicity )
	phone		= exports.mysql:escape_string( phone )
	occupation	= exports.mysql:escape_string( occupation )
	address		= exports.mysql:escape_string( address )



	local qUpdate = exports.mysql:query( "UPDATE `mdc_criminals` SET `dob` = '"..dob.."', `ethnicity` = '"..ethnicity.."', `phone` = '"..phone.."', `occupation` = '"..occupation.."', `address` = '"..address.."', `photo` = '"..photo.."' WHERE `character` = '"..exports.mysql:escape_string( charid ).."' " )
	if qUpdate then
		search( charactername, 0 )
	end
end

function update_details( charid, charactername, details )

	details		= exports.mysql:escape_string( details )

	local qUpdate = exports.mysql:query( "UPDATE `mdc_criminals` SET `details` = '"..details.."' WHERE `character` = '"..exports.mysql:escape_string( charid ).."' " )
	if qUpdate then
		search( charactername, 0 )
	end
end

function update_pilot_details( charid, charactername, pilotDetails )
	pilotDetails = exports.mysql:escape_string( pilotDetails )
	local qUpdate = exports.mysql:query( "UPDATE `mdc_criminals` SET `pilot_details` = '"..pilotDetails.."' WHERE `character` = '"..exports.mysql:escape_string( charid ).."' " )
	if qUpdate then
		search( charactername, 0 )
	end
end

function update_warrant( charid, charactername, wanted, details )

	details = exports.mysql:escape_string( details )
	local wanted_by = getElementData( source, "dbid" )

	local qUpdate = exports.mysql:query( "UPDATE `mdc_criminals` SET `wanted` = '"..wanted.."', `wanted_by` = '"..wanted_by.."', `wanted_details` = '"..details.."' WHERE `character` = '"..exports.mysql:escape_string( charid ).."' " )
	if qUpdate then
		search( charactername, 0 )
	end
end

function tolls( )
	local locked = { }
	locked [ 1 ] = exports.toll:isTollLocked( 1 )
	locked [ 2 ] = exports.toll:isTollLocked( 3 )
	locked [ 3 ] = exports.toll:isTollLocked( 5 )
	locked [ 4 ] = exports.toll:isTollLocked( 6 )
	locked [ 5 ] = exports.toll:isTollLocked( 7 )
	locked [ 6 ] = exports.toll:isTollLocked( 9 )
	locked [ 7 ] = exports.toll:isTollLocked( 10 )
	locked [ 8 ] = exports.toll:isTollLocked( 11 )
	locked [ 9 ] = exports.toll:isTollLocked( 12 )
	locked [ 10 ] = exports.toll:isTollLocked( 13 )
	triggerClientEvent( source, resourceName..":tolls", root, locked )
end

function toggle_toll( id )
	--We create a system here so that both directions are blocked at once for simplicity's sake.
	if id == 1 then
		exports.toll:toggleToll( 1 )
		if exports.toll:isTollLocked( 1 ) ~= exports.toll:isTollLocked( 2 ) then exports.toll:toggleToll( 2 ) end
	elseif id == 2 then
		exports.toll:toggleToll( 3 )
		if exports.toll:isTollLocked( 3 ) ~= exports.toll:isTollLocked( 4 ) then exports.toll:toggleToll( 4 ) end
	elseif id == 3 then
		exports.toll:toggleToll( 5 )
	elseif id == 4 then
		exports.toll:toggleToll( 6 )
	elseif id == 5 then
		exports.toll:toggleToll( 7 )
		if exports.toll:isTollLocked( 7 ) ~= exports.toll:isTollLocked( 8 ) then exports.toll:toggleToll( 8 ) end
	elseif id == 6 then
		exports.toll:toggleToll( 9 )
	elseif id == 7 then
		exports.toll:toggleToll( 10 )
	elseif id == 8 then
		exports.toll:toggleToll( 11 )
	elseif id == 9 then
		exports.toll:toggleToll( 12 )
	elseif id == 10 then
		exports.toll:toggleToll( 13 )
	end

	tolls( )
end

function system_admin( faction_id )
	dbQuery( function( qh, faction_id, source )
		local res, nums, id = dbPoll( qh, 0 )
		if res and nums > 0 then
			local results = {}
			for _, row in ipairs( res ) do
				local result = { }
				result[1] = row.id
				result[2] = getCharacterNameFromID( row.charid, faction_id )
				result[3] = row.level
				result[4] = row.organization
				table.insert( results, result )
			end
			triggerClientEvent( source, resourceName .. ":system_admin", root, results, nums )
		end
	end, { faction_id, source }, exports.mysql:getConn('mta'), "SELECT * FROM `mdc_users` WHERE `organization`=? ORDER BY level DESC, id DESC ", faction_id )
end

function create_account( charid, level, organization )
	if level ~= -1 then
		level = 0
	end
	level = level + 1

	local charid = exports.cache:getCharacterIDFromName(charid)
	if not charid then
		outputChatBox("Unable to locate the character.", source, 255, 0, 0)
		return
	end

	local qh = dbQuery( exports.mysql:getConn('mta'), "SELECT * FROM mdc_users WHERE organization=? AND charid=? LIMIT 1", level, charid )
	local res, nums, id = dbPoll( qh, 10000 )
	if res and nums > 0 then
		outputChatBox( "MDC account for this user is already existed for this organization.", source, 255, 0, 0 )
	else
		dbExec( exports.mysql:getConn('mta'), "INSERT INTO `mdc_users` ( `charid`, `level`, `organization` ) VALUES ( ?, ?, ? ) ", charid, level + 1, organization )
		outputChatBox( "MDC account has been successfully created.", source, 255, 0, 0 )
	end
	triggerEvent( 'mdc:system_admin', source, organization )
end

function edit_account( id, level, org )
	dbExec( exports.mysql:getConn('mta'), "UPDATE mdc_users SET level=? WHERE id=? AND organization=?", tonumber(level) + 1, id, org )
	triggerEvent( 'mdc:system_admin', source, org )
	outputChatBox( "Done.", source )
end

function delete_account( id, org )
	dbExec( exports.mysql:getConn('mta'), "DELETE FROM mdc_users WHERE id=? AND organization=?", id, org )
	triggerEvent( 'mdc:system_admin', source, org )
	outputChatBox( "Done.", source )
end

local cachedPilotLicenses = {}
pilotLicenseNames = {
	[1] = "ARC",
	[2] = "Airport Driving Permit",
	[3] = "ROT",
	[4] = "SER",
	[5] = "MER",
	[6] = "TER",
	[7] = "Typerating",
	[8] = "CFI",
	[9] = "CPL",
}
function getPlayerPilotLicenses(thePlayer, noCache)
	local licenses = {}
	noCache = true --because we might get issues otherwise
	--if not noCache and cachedPilotLicenses[thePlayer] then
	--	licenses = cachedPilotLicenses[thePlayer]
	--else
		local charID = tonumber(getElementData(thePlayer, "dbid")) or false
		if charID then
			if mdc_faa_licenses then
				for k,row in ipairs(mdc_faa_licenses) do
					if tonumber(row.character) == charID then
						local licenseID = tonumber(row.license) or false
						if licenseID then
							local licenseText
							if licenseID == 7 then --typerating
								local vehName = getVehicleNameFromModel(tonumber(row.value))
								if vehName then
									licenseText = "Typerating: "..tostring(vehName)
								end
							else
								licenseText = pilotLicenseNames[licenseID]
							end
							table.insert(licenses, {licenseID, tonumber(row.value) or false, licenseText or false})
						end
					end
				end
				--cachedPilotLicenses[thePlayer] = licenses
			else
				local result8 = exports.mysql:query( "SELECT `license`, `value` FROM `mdc_faa_licenses` WHERE `character` = ".. charID .." ORDER BY `id` ASC" )
				if ( result8 ) then
					local count = 1
					while true do
						row = exports.mysql:fetch_assoc( result8 )
						if not row then break end

						local licenseID = tonumber(row.license) or false
						if licenseID then
							local licenseText
							if licenseID == 7 then --typerating
								local vehName = getVehicleNameFromModel(tonumber(row.value))
								if vehName then
									licenseText = "Typerating: "..tostring(vehName)
								end
							else
								licenseText = pilotLicenseNames[licenseID]
							end
							table.insert(licenses, {licenseID, tonumber(row.value) or false, licenseText or false})
						end
					end
					exports.mysql:free_result( result8 )
					--cachedPilotLicenses[thePlayer] = licenses
				end
			end
		end
	--end
	return licenses
end

function refreshPilotLicensesCache(thePlayer, commandName)
	local faction, rank = exports.factions:IsPlayerInFaction(thePlayer, 47)
	local leader = exports.factions:hasMemberPermissionTo(thePlayer, 47, "add_member")
	if (faction and leader) or exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) then
		outputChatBox("Refreshing pilot licenses cache...", thePlayer, 255, 194, 14)
		local startTime = getTickCount()
		--mdc_faa_licenses
		local result = exports.mysql:query("SELECT * FROM `mdc_faa_licenses`")
		if result then
			local theTable = {}
			while true do
				row = exports.mysql:fetch_assoc(result)
				if not row then break end
				local thisValues = {}
				for key,value in pairs(row) do
					--outputDebugString("key="..tostring(key).." value="..tostring(value))
					thisValues[key] = value
				end
				table.insert(theTable, thisValues)
			end
			mdc_faa_licenses = theTable
			exports.mysql:free_result(result)
		else
			outputChatBox("ERROR! Failed to load pilot licenses!", thePlayer, 255, 0, 0)
			outputDebugString("mdc-system/mdc.lua: Failed to load pilot licenses! (/"..tostring(commandName)..")",2)
			return
		end
		outputChatBox("Loaded "..tostring(#mdc_faa_licenses).." pilot licenses in "..tostring(math.ceil(getTickCount()-startTime)).."ms.", thePlayer, 255, 194, 14)
	end
end
addCommandHandler("refreshpilotlicenses", refreshPilotLicensesCache, false, false)

function remove_anpr( id )
	if client and client ~= source then return end

    for i, row in pairs( anpr ) do
        if row[4] == tonumber( id ) then
            table.remove( anpr, i )
            break
        end
    end

    triggerEvent( "mdc:main", source )

    dbExec( exports.mysql:getConn('mta'), "DELETE FROM `mdc_anpr` WHERE `id` = ? ", id )
end

function getANPRTable()
	return anpr
end	

addEvent( resourceName .. ":remove_anpr", true )
addEventHandler( resourceName .. ":remove_anpr", getRootElement(), remove_anpr )

function updateVehicleStolen( vehicleID )
	exports.mysql:query_free( 'UPDATE `vehicles` SET `stolen` = 1 - `stolen` WHERE `id` = ' .. vehicleID )
end

-- these are bad appoach, because it causes trouble when you rename resources.
addEvent( resourceName .. ":search", true )
addEvent( resourceName .. ":add_crime", true )
addEvent( resourceName .. ":add_pilot_event", true )
addEvent( resourceName .. ":add_pilot_license", true )
addEvent( resourceName .. ":add_apb", true )
addEvent( resourceName .. ":remove_crime", true )
addEvent( resourceName .. ":remove_pilot_event", true )
addEvent( resourceName .. ":remove_pilot_license", true )
addEvent( resourceName .. ":remove_apb", true )
addEvent( resourceName .. ":update_person", true )
addEvent( resourceName .. ":update_details", true )
addEvent( resourceName .. ":update_pilot_details", true )
addEvent( resourceName .. ":update_warrant", true )
addEvent( resourceName .. ":tolls", true )
addEvent( resourceName .. ":toggle_toll", true )
addEvent( resourceName .. ":system_admin", true )
addEvent( resourceName .. ":create_account", true )
addEvent( resourceName .. ":edit_account", true )
--addEvent( resourceName .. ":edit_self", true )
addEvent( resourceName .. ":delete_account", true )
addEvent( resourceName .. ":updateVehicleStolen", true )
addEventHandler( resourceName .. ":search", root, search )
addEventHandler( resourceName .. ":add_crime", root, add_crime )
addEventHandler( resourceName .. ":add_pilot_event", root, add_pilot_event )
addEventHandler( resourceName .. ":add_pilot_license", root, add_pilot_license )
addEventHandler( resourceName .. ":add_apb", root, add_apb )
addEventHandler( resourceName .. ":remove_crime", root, remove_crime )
addEventHandler( resourceName .. ":remove_pilot_event", root, remove_pilot_event )
addEventHandler( resourceName .. ":remove_pilot_license", root, remove_pilot_license )
addEventHandler( resourceName .. ":remove_apb", root, remove_apb )
addEventHandler( resourceName .. ":update_person", root, update_person )
addEventHandler( resourceName .. ":update_details", root, update_details )
addEventHandler( resourceName .. ":update_pilot_details", root, update_pilot_details )
addEventHandler( resourceName .. ":update_warrant", root, update_warrant )
addEventHandler( resourceName .. ":tolls", root, tolls )
addEventHandler( resourceName .. ":toggle_toll", root, toggle_toll )
addEventHandler( resourceName .. ":system_admin", root, system_admin )
addEventHandler( resourceName .. ":create_account", root, create_account )
addEventHandler( resourceName .. ":edit_account", root, edit_account )
--addEventHandler( resourceName .. ":edit_self", root, edit_self )
addEventHandler( resourceName .. ":delete_account", root, delete_account )
addEventHandler( resourceName .. ":updateVehicleStolen", root, updateVehicleStolen )

function makeMdcAccount(player, cmd, target, faction, level)
	if exports.integration:isPlayerScripter( player ) or exports.integration:isPlayerLeadAdmin( player ) then
		local function printTip( p )
			outputChatBox( "SYNTAX: /"..cmd.." [Partial player name or ID] [faction ID] [level; 0=delete account, 1=normal, 2=admin] ", p )
		end

		if not target or not faction or not tonumber(faction) or not level or not tonumber(level) then
			return printTip( player )
		end

		local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick( player, target )
		if not targetPlayer then
			printTip( player )
			return not outputChatBox( "Player not found.", player, 255,0,0 )
		end

		if not exports.factions:getFactionFromID( faction ) then
			printTip( player )
			return not outputChatBox( "Faction ID "..faction.." not found. See /showfactions ", player, 255, 0, 0 )
		elseif tonumber(level) ~= 0 and tonumber(level) ~= 1 and tonumber(level) ~= 2 then
			printTip( player )
			return not outputChatBox( "Level must be 1 or 2.", player, 255, 0, 0 )
		else
			local charid = getElementData( targetPlayer, 'dbid' )
			local qh = dbQuery( exports.mysql:getConn('mta'), "SELECT * FROM mdc_users WHERE charid=? AND organization=? LIMIT 1", charid, faction )
			local res, nums, id = dbPoll( qh, 10000 )
			if res and nums > 0 then
				if tonumber(level) == 0 then
					dbExec( exports.mysql:getConn('mta'), "DELETE FROM mdc_users WHERE id=?", res[1].id )
					return outputChatBox("MDC account for "..targetPlayerName.." has been deleted.", player, 0,255,0 )
				elseif res[1].level == tonumber(level) then
					return not outputChatBox( "This player has already had an MDC account for this faction with the same access level as you tried to make. ", player, 255,0,0 )
				else
					dbExec( exports.mysql:getConn('mta'), "UPDATE mdc_users SET level=? WHERE id=?", level, res[1].id )
					outputChatBox("Access level for MDC account for "..targetPlayerName.." has been updated from "..(res[1].level).." to "..level..".", player, 0,255,0 )
				end
			else
				if tonumber(level) == 0 then
					outputChatBox("MDC account for "..targetPlayerName.." was not found.", player, 0,255,0 )
				else
					dbExec( exports.mysql:getConn('mta'), "INSERT INTO mdc_users SET charid=?, level=?, organization=?", charid, level, faction )
					outputChatBox("MDC account for "..targetPlayerName.." has been successfully created.", player, 0,255,0 )
				end
			end
		end
	end
end
addCommandHandler("makemdcaccount", makeMdcAccount)
