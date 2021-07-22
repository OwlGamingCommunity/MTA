local mysql = exports.mysql

function newCharacter_create(characterName, characterDescription, race, gender, skin, height, weight, age, languageselected, month, day, location)
	if not (checkValidCharacterName(characterName)) then
		triggerClientEvent(client, "accounts:characters:new", client, 1, 1) -- State 1:1: error validating data
		return
	end

	if not (race > -1 and race < 3) then
		triggerClientEvent(client, "accounts:characters:new", client, 1, 2) -- State 1:2: error validating data
		return
	end

	if not (gender == 0 or gender == 1) then
		triggerClientEvent(client, "accounts:characters:new", client, 1, 3) -- State 1:3: error validating data
		return
	end

	if not skin then
		triggerClientEvent(client, "accounts:characters:new", client, 1, 4) -- State 1:4: error validating data
		return
	end

	if not (height < 201 and height > 149) then
		triggerClientEvent(client, "accounts:characters:new", client, 1, 5) -- State 1:5: error validating data
		return
	end

	if not (weight < 200 and weight > 49) then
		triggerClientEvent(client, "accounts:characters:new", client, 1, 6) -- State 1:6: error validating data
		return
	end

	if not (age > 15 and age < 101) then
		triggerClientEvent(client, "accounts:characters:new", client, 1, 7) -- State 1:7: error validating data
		return
	end

	if not tonumber(languageselected) then
		triggerClientEvent(client, "accounts:characters:new", client, 1, 8) -- State 1:8: error validating data
		return
	end


	characterName = string.gsub(tostring(characterName), " ", "_")

	--[[if #characterDescription < 50 or #characterDescription > 128 then
	triggerClientEvent(client, "accounts:characters:new", client, 1, 9) -- State 1:9: error validating data
		return
	end
	characterDescription = mysql:escape_string(characterDescription)]]

	local mQuery1 = mysql:query("SELECT charactername FROM characters WHERE charactername='" .. mysql:escape_string(characterName) .. "'")
	if (mysql:num_rows(mQuery1)>0) then
		mysql:free_result(mQuery1)
		triggerClientEvent(client, "accounts:characters:new", client, 2, 1) -- State 2:1: Name already in use
		return
	end
	mysql:free_result(mQuery1)

	local accountID = getElementData(client, "account:id")
	local accountUsername = getElementData(client, "account:username")

	month = tonumber(month) or 1
	day = tonumber(day) or 1
	local year = calculateYearBornIn(age, month, day)
	local dob = string.format("%04d-%02d-%02d", year, month, day)
	local fingerprint = md5(mysql:escape_string(characterName) .. accountID .. race .. gender .. dob)

	local walkingstyle = 128
	if gender == 1 then
		walkingstyle = 129
	end


	local id = mysql:query_insert_free("INSERT INTO `characters` SET `charactername`='" .. mysql:escape_string(characterName).. "', `x`='"..location[1].."', `y`='"..location[2].."', `z`='"..location[3].."', `rotation`='"..location[4].."', `interior_id`='"..location[5].."', `dimension_id`='"..location[6].."', `lastarea`='"..exports.global:toSQL(location[7]).."', `gender`='" .. mysql:escape_string(gender) .. "', `skincolor`='" .. mysql:escape_string(race) .. "', `weight`='" .. mysql:escape_string(weight) .. "', `height`='" .. mysql:escape_string(height) .. "', `description`='', `account`='" .. mysql:escape_string(accountID) .. "', `skin`='" .. mysql:escape_string(skin) .. "', `age`='" .. mysql:escape_string(age) .. "', `fingerprint`='" .. mysql:escape_string(fingerprint) .. "', `lang1`='" .. mysql:escape_string(languageselected) .. "', `lang1skill`='100', `currLang`='1' , `month`='" .. mysql:escape_string(month or "1") .. "', `day`='" .. mysql:escape_string(day or "1").."', `walkingstyle`='" .. mysql:escape_string(walkingstyle).."', date_of_birth = '" .. mysql:escape_string(dob) .. "'" )

	if (id) then --
		exports.logs:dbLog("ac"..tostring(accountID), 27, { "ac"..tostring(accountID), "ch" .. id } , "Created" )

		exports.anticheat:changeProtectedElementDataEx(client, "dbid", id, false)
		exports['item-system']:loadItems( client, true )
		exports.global:giveItem( client, 16, skin )
		exports.global:giveItem( client, 17, 1 )
		exports.global:giveItem( client, 262, 1 ) -- Tokens
		exports.global:giveItem( client, 263, 1 )
		-- ID CARD
		exports.global:giveItem( client, 152, characterName..";"..(gender==0 and "Male" or "Female")..";"..exports.global:numberToMonth(month).." "..exports.global:formatDate(day)..", "..year..";"..fingerprint)
		-- Briefcase
		if exports.global:giveItem( client, 160, 1 ) then
			triggerEvent("artifacts:toggle", client, client, "briefcase")
		end

		--Make a new phone and give it to player
		local attempts = 0
		local itemValue = 1
		while true do
			-- generate a larger phone number if we're totally out of numbers and/or too lazy to perform more than 20+ checks.
			attempts = attempts + 1
			itemValue = math.random(311111, attempts < 20 and 899999 or 8999999)

			local mysqlQ = mysql:query("SELECT `phonenumber` FROM `phones` WHERE `phonenumber` = '" .. itemValue .. "'")
			if mysql:num_rows(mysqlQ) == 0 then
				mysql:free_result(mysqlQ)
				break
			end
			mysql:free_result(mysqlQ)
		end
		exports.global:giveItem( client, 2, itemValue )

		exports.anticheat:changeProtectedElementDataEx(client, "dbid")
		triggerClientEvent(client, "accounts:characters:new", client, 3, tonumber(id)) -- State 3:<var>: Spic win!
	else
		triggerClientEvent(client, "accounts:characters:new", client, 2, 2) -- State 2:2: Failed to update database
	end
end
addEventHandler("accounts:characters:new", getRootElement(), newCharacter_create)

function charactersQuotaCheck()
	local id = getElementData(client, 'account:id')
	dbQuery( function(qh, client)
		local res = dbPoll(qh, 0)
		if res and #res==1 then
			local ok = res[1].cap > res[1].cur
			triggerClientEvent( client, 'account:charactersQuotaCheck', resourceRoot, ok, ok and ("Quota: "..res[1].cur.."/"..res[1].cap) or ("You reached "..res[1].cur.."/"..res[1].cap.." characters.\nTo create more, make a report to admins with a proper reason or use Premium Feature.") )
		else
			triggerClientEvent( client, 'account:charactersQuotaCheck', resourceRoot, false, "Errors occurred while checking characters quota." )
		end
	end, { client }, exports.mysql:getConn('mta'), "SELECT COUNT(id) AS cur, (SELECT max_characters FROM account_details WHERE account_details.account_id=?) AS cap FROM characters WHERE account=?", id, id )
end
addEvent('account:charactersQuotaCheck', true)
addEventHandler('account:charactersQuotaCheck', resourceRoot, charactersQuotaCheck)

function calculateYearBornIn(age, month, day)
	local currentTime = getRealTime()
	local currentYear, currentMonth, currentDay = currentTime.year + 1900, currentTime.month + 1, currentTime.monthday
	local year = currentYear - age
	if month > currentMonth or (month == currentMonth and day > currentDay) then
		year = year - 1
	end
	return year
end
