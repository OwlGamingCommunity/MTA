--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local mysql = exports.mysql
addEvent( "account:character:spawned", true )
addEvent( 'account:character:select', true )
addEvent( 'accounts:characters:fixCharacterSpawnPosition', true )

function characterList( theClient )
    local characters = { }
    local clientAccountID = getElementDataEx(theClient, "account:id") or -1

    local result = mysql:query("SELECT skincolor,`id`, `charactername`, `cked`, TIMESTAMPDIFF(YEAR, `date_of_birth`, CURDATE()) AS `real_age`, `weight`, `height`, `description`, `gender`, `skin`, `clothingid`, `hoursplayed` FROM `characters` WHERE `account`='" .. mysql:escape_string(clientAccountID) .. "' AND `active` = 1 ORDER BY `cked` ASC, `lastlogin` DESC")
    if (mysql:num_rows(result) > 0) then
        local i = 1
        while result do
            local row = mysql:fetch_assoc(result)
            if not row then break end

            characters[i] = { }
            characters[i][1] = tonumber(row["id"])
            characters[i][2] = row["charactername"]
            characters[i][3] = tonumber(row["cked"])
            characters[i][4] = tonumber(row["hoursplayed"])
            characters[i][5] = tonumber(row["real_age"])
            characters[i][6] = tonumber(row["gender"])
            characters[i][7] = tonumber(row["skincolor"])
            characters[i][8] = nil
            characters[i][9] = tonumber(row["skin"])
            characters[i][11] = tonumber(row["weight"])
            characters[i][12] = tonumber(row["height"])
            characters[i][13] = nil
            characters[i][14] = nil
            characters[i][15] = tonumber(row["clothingid"])

            i = i + 1
        end
    end
    mysql:free_result(result)
    return characters
end

function forumLogin(username, password)
    local result, er = exports.integration:logintoForumAccount(username, password)
    if result then
        setElementData(client, "account:forumid", result['member_id'])
        mysql:query_free("UPDATE accounts SET forumid='"..result['member_id'].."' WHERE id='"..getElementData(client, 'account:id').."'")
        --exports.integration:fetchForumInfo(result['member_id'], client)
    end
    triggerClientEvent(client, "forum:loginResult", resourceRoot, result, er)
end
addEvent("forum:login", true)
addEventHandler("forum:login", resourceRoot, forumLogin)

function removeForum()
    mysql:query_free("UPDATE accounts SET forumid=NULL WHERE username='"..getElementData(client, "account:username").."'")
    removeElementData(client, "account:forumid")
end
addEvent("forum:remove", true)
addEventHandler("forum:remove", resourceRoot, removeForum)

function reloadCharacters(fromButton)
    local chars = characterList(source)
    --setElementData(source, "account:characters", chars, true)
    exports.anticheat:changeProtectedElementDataEx(source, "account:characters", chars)
    if fromButton then
        triggerClientEvent(client, "refreshCharacters", resourceRoot)
    end
end
addEvent("updateCharacters", true)
addEventHandler("updateCharacters", getRootElement(), reloadCharacters)


function reconnectMe()
    redirectPlayer(client, "", 0 )
end
addEvent("accounts:reconnectMe", true)
addEventHandler("accounts:reconnectMe", getRootElement(), reconnectMe)

--/LOGINTO FOR LEAD+
function adminLoginToPlayerCharacter(thePlayer, commandName, ...)
    if exports.integration:isPlayerLeadAdmin(thePlayer) then
        if not (...) then
            outputChatBox("SYNTAX: /" .. commandName .. " [Exact Character Name]", thePlayer, 255, 194, 14, false)
            outputChatBox("Logs into player's character.", thePlayer, 255, 194, 0, false)
        else
            targetChar = table.concat({...}, "_")
            local fetchData = mysql:query_fetch_assoc("SELECT `characters`.`id` AS `targetCharID` , `characters`.`account` AS `targetUserID` FROM `characters` WHERE `charactername`='"..mysql:escape_string(targetChar).."' LIMIT 1")
            if not fetchData then
                outputChatBox("No character name found.", thePlayer, 255,0,0)
                return false
            end
            local qh = dbQuery(exports.mysql:getConn("core"), "SELECT username, admin FROM accounts WHERE id=?", fetchData["targetUserID"])
            local result = dbPoll(qh, -1)
            if result and #result == 1 then
                local targetCharID = tonumber(fetchData["targetCharID"]) or false
                local targetUserID = tonumber(fetchData["targetUserID"]) or false
                local targetAdminLevel = tonumber(result[1]["admin"]) or 0
                local targetUsername = result[1]["username"] or false
                local theAdminPower = exports.global:getPlayerAdminLevel(thePlayer)

                if targetCharID and  targetUserID then
                    local adminTitle = exports.global:getPlayerFullIdentity(thePlayer)
                    if targetAdminLevel > theAdminPower then
                        local adminUsername = getElementData(thePlayer, "account:username")
                        outputChatBox("You can't log into Character of a higher rank admin than you.", thePlayer, 255,0,0)
                        exports.global:sendMessageToAdmins("[LOGINTO]: " .. tostring(adminTitle) .. " attempted to log into character of higher rank admin ("..targetUsername..").")
                        return false
                    end
                    exports.logs:dbLog(thePlayer, 4, thePlayer, commandName.." account "..targetUsername)
                    spawnCharacter(targetCharID, targetUserID, thePlayer, targetUsername)
                    exports.global:sendMessageToAdmins("[LOGINTO]: " .. tostring(adminTitle) .. " has logged into account '"..targetUsername.."'.")
                end
            end
        end
    end
end
addCommandHandler("loginto", adminLoginToPlayerCharacter, false, false)

function spawnCharacter(characterID, remoteAccountID, theAdmin, targetAccountName, location, freshSpawn)
    if theAdmin then
        client = theAdmin
    end

    if not client then
        return false
    end

    if not characterID then
        return false
    end

    if not tonumber(characterID) then
        return false
    end
    characterID = tonumber(characterID)

    triggerEvent('setDrunkness', client, 0)
    setElementDataEx(client, "alcohollevel", 0, true)

    removeMasksAndBadges(client)

    setElementDataEx(client, "pd.jailserved")
    setElementDataEx(client, "pd.jailtime")
    setElementDataEx(client, "pd.jailtimer")
    setElementDataEx(client, "pd.jailstation")
    setElementDataEx(client, "loggedin", 0, true)
    setElementData(client, "faction", {})
    setElementData(client, "duty", 0)

    local timer = getElementData(client, "pd.jailtimer")
    if isTimer(timer) then
        killTimer(timer)
    end

    if (getPedOccupiedVehicle(client)) then
        removePedFromVehicle(client)
    end
    -- End cleaning up

    local accountID = tonumber(getElementDataEx(client, "account:id"))

    local characterData = false

    if theAdmin then
        accountID = remoteAccountID
        characterData = mysql:query_fetch_assoc("SELECT *, DAY(`date_of_birth`) AS dob_day, MONTH(`date_of_birth`) AS dob_month, YEAR(`date_of_birth`) AS dob_year, TIMESTAMPDIFF(YEAR, `date_of_birth`, NOW()) AS dob_age FROM `characters` LEFT JOIN `jobs` ON `characters`.`id` = `jobs`.`jobCharID` AND `characters`.`job` = `jobs`.`jobID` WHERE `id`='" .. tostring(characterID) .. "' AND `account`='" .. tostring(accountID) .. "'")
    else
        characterData = mysql:query_fetch_assoc("SELECT *, DAY(`date_of_birth`) AS dob_day, MONTH(`date_of_birth`) AS dob_month, YEAR(`date_of_birth`) AS dob_year, TIMESTAMPDIFF(YEAR, `date_of_birth`, NOW()) AS dob_age FROM `characters` LEFT JOIN `jobs` ON `characters`.`id` = `jobs`.`jobCharID` AND `characters`.`job` = `jobs`.`jobID` WHERE `id`='" .. tostring(characterID) .. "' AND `account`='" .. tostring(accountID) .. "' AND `cked`=0")
    end

    if characterData then
        setElementDataEx(client, "look", fromJSON(characterData["description"]) or {"", "", "", "", characterData["description"], ""})
        setElementDataEx(client, "weight", characterData["weight"])
        setElementDataEx(client, "height", characterData["height"])
        setElementDataEx(client, "race", tonumber(characterData["skincolor"]))
        setElementDataEx(client, "maxvehicles", tonumber(characterData["maxvehicles"]))
        setElementDataEx(client, "maxinteriors", tonumber(characterData["maxinteriors"]))
        --DATE OF BIRTH
        setElementDataEx(client, "age", tonumber(characterData["dob_age"]))
        setElementDataEx(client, "month", tonumber(characterData["dob_month"]))
        setElementDataEx(client, "day", tonumber(characterData["dob_day"]))
        setElementDataEx(client, "year", tonumber(characterData["dob_year"]))

        -- LANGUAGES
        local lang1 = tonumber(characterData["lang1"])
        local lang1skill = tonumber(characterData["lang1skill"])
        local lang2 = tonumber(characterData["lang2"])
        local lang2skill = tonumber(characterData["lang2skill"])
        local lang3 = tonumber(characterData["lang3"])
        local lang3skill = tonumber(characterData["lang3skill"])
        local currentLanguage = tonumber(characterData["currlang"]) or 1
        setElementDataEx(client, "languages.current", currentLanguage, false)

        if lang1 == 0 then
            lang1skill = 0
        end

        if lang2 == 0 then
            lang2skill = 0
        end

        if lang3 == 0 then
            lang3skill = 0
        end

        setElementDataEx(client, "languages.lang1", lang1, false)
        setElementDataEx(client, "languages.lang1skill", lang1skill, false)

        setElementDataEx(client, "languages.lang2", lang2, false)
        setElementDataEx(client, "languages.lang2skill", lang2skill, false)

        setElementDataEx(client, "languages.lang3", lang3, false)
        setElementDataEx(client, "languages.lang3skill", lang3skill, false)
        -- END OF LANGUAGES

        setElementDataEx(client, "timeinserver", tonumber(characterData["timeinserver"]), false)
        setElementDataEx(client, "account:character:id", characterID, false)
        setElementDataEx(client, "dbid", characterID, true) -- workaround
        exports['item-system']:loadItems( client, true )


        setElementDataEx(client, "loggedin", 1, true)

        -- Check his name isn't in use by a squatter
        local playerWithNick = getPlayerFromName(tostring(characterData["charactername"]))
        if isElement(playerWithNick) and (playerWithNick~=client) then
            if theAdmin then
                local adminTitle = exports.global:getPlayerAdminTitle(theAdmin)
                local adminUsername = getElementData(theAdmin, "account:username")
                kickPlayer(playerWithNick, getRootElement(), adminTitle.." "..adminUsername.." has logged into your account.")
                outputChatBox("Account "..targetAccountName.." ("..tostring(characterData["charactername"]):gsub("_"," ")..") has been kicked out of game.", theAdmin, 0, 255, 0 )
            else
                kickPlayer(playerWithNick, getRootElement(), "Someone else has logged into your character.")
            end
        end

        setElementDataEx(client, "bleeding", 0, false)

        -- Set their name to the characters
        setElementDataEx(client, "legitnamechange", 1)
        setPlayerName(client, tostring(characterData["charactername"]))
        local pid = getElementData(client, "playerid")
        local fixedName = string.gsub(tostring(characterData["charactername"]), "_", " ")

        setElementDataEx(client, "legitnamechange", 0)


        setPlayerNametagShowing(client, false)
        setElementFrozen(client, true)
        setPedGravity(client, 0)

        local locationToSpawn = {}
        locationToSpawn.x = tonumber(characterData["x"])
        locationToSpawn.y = tonumber(characterData["y"])
        locationToSpawn.z = tonumber(characterData["z"])
        locationToSpawn.rot = tonumber(characterData["rotation"])
        locationToSpawn.int = tonumber(characterData["interior_id"])
        locationToSpawn.dim = tonumber(characterData["dimension_id"])
        spawnPlayer(client, locationToSpawn.x ,locationToSpawn.y ,locationToSpawn.z , locationToSpawn.rot, tonumber(characterData["skin"]))
        setElementDimension(client, locationToSpawn.dim)
        setElementInterior(client, locationToSpawn.int , locationToSpawn.x, locationToSpawn.y, locationToSpawn.z)
        setCameraInterior(client, locationToSpawn.int)


        setCameraTarget(client, client)
        setPedArmor(client, tonumber(characterData["armor"]))

        -- Handle all faction info
        local qh = dbQuery(mysql:getConn("mta"), "SELECT * FROM characters_faction WHERE character_id=? ORDER BY id ASC", tonumber(characterData["id"]))
        local result, num_affected_rows = dbPoll ( qh, 10000 )

        if result and num_affected_rows > 0 then
            local factionT = {}
            local count = 0
            for _, row in pairs(result) do
                count = count+1
                factionT[row.faction_id] = { rank = row.faction_rank, leader = row.faction_leader == 1 or false, phone = row.faction_phone, perks =  type(row.faction_perks) == "string" and fromJSON(row.faction_perks) or { }, count = count }
            end
            local duty = tonumber(characterData["duty"]) or 0
            setElementData(client, "duty", duty)

            -- check if the player has the duty package
            if duty > 0 then
                local foundPackage = false
                for k,v in pairs(factionT) do
                    for key, value in ipairs(v.perks) do
                        if tonumber(value) == tonumber(duty) then
                            foundPackage = true
                            break
                        end
                    end
                end

                if not foundPackage then
                    triggerEvent("duty:offduty", client)
                    outputChatBox("You don't have access to the duty you are using anymore - thus, removed.", client, 255, 0, 0)
                end
            end

            setElementData(client, "factionMenu", 0)
            setElementData(client, "faction", factionT)
        else -- Aren't in any faction, just a citizen.
            setElementData(client, "factionMenu", 0)
            setElementData(client, "faction", { })
            dbFree(qh)
        end

        local team = getTeamFromName("Citizen") -- Needed for using team chat.
        setPlayerTeam(client, team)
        local adminLevel = getElementDataEx(client, "admin_level")
        local gmLevel = getElementDataEx(client, "account:gmlevel")
        exports.global:updateNametagColor(client)
        -- ADMIN JAIL
        local jailed = getElementData(client, "adminjailed")
        local jailed_time = getElementData(client, "jailtime")
        local jailed_by = getElementData(client, "jailadmin")
        local jailed_reason = getElementData(client, "jailreason")

        if location then
            setElementPosition(client, location[1], location[2], location[3])
            setElementRotation(client, 0, 0, location[4])
        end

        if jailed then
            local incVal = getElementData(client, "playerid")

            setElementDimension(client, 55000+incVal)
            setElementInterior(client, 6)
            setCameraInterior(client, 6)
            setElementPosition(client, 263.821807, 77.848365, 1001.0390625)
            setPedRotation(client, 267.438446)

            setElementDataEx(client, "jailserved", 0, false)
            setElementDataEx(client, "adminjailed", true)
            setElementDataEx(client, "jailreason", jailed_reason, false)
            setElementDataEx(client, "jailadmin", jailed_by, false)

            if jailed_time ~= 999 then
                if not getElementData(client, "jailtimer") then
                    setElementDataEx(client, "jailtime", jailed_time+1, false)
                    triggerEvent("admin:timerUnjailPlayer", client, client)
                end
            else
                setElementDataEx(client, "jailtime", "Unlimited", false)
                setElementDataEx(client, "jailtimer", true, false)
            end
            setElementInterior(client, 6)
            setCameraInterior(client, 6)
        end

        setElementDataEx(client, "legitnamechange", 0)
        setElementDataEx(client, "muted", tonumber(muted))
        setElementDataEx(client, "hoursplayed",  tonumber(characterData["hoursplayed"]), true)
        setPlayerAnnounceValue ( client, "score", characterData["hoursplayed"] )
        setElementDataEx(client, "alcohollevel", tonumber(characterData["alcohollevel"]) or 0, true)
        exports.global:setMoney(client, tonumber(characterData["money"]), true)
        exports.global:checkMoneyHacks(client)

        setElementDataEx(client, "restrain", tonumber(characterData["cuffed"]), true)
        setElementDataEx(client, "tazed", false, false)
        setElementDataEx(client, "realinvehicle", 0, false)

        -- Job system - MAXIME
        setElementData(client, "job", tonumber(characterData["job"]) or 0, true)
        setElementData(client, "jobLevel", tonumber(characterData["jobLevel"]) or 0, true)
        setElementData(client, "jobProgress", tonumber(characterData["jobProgress"]) or 0, true)

        -- MAXIME JOB SYSTEM
        if tonumber(characterData["job"]) == 1 then
            if characterData["jobTruckingRuns"] then
                setElementData(client, "job-system-trucker:truckruns", tonumber(characterData["jobTruckingRuns"]), true)
                mysql:query_free("UPDATE `jobs` SET `jobTruckingRuns`='0' WHERE `jobCharID`='"..tostring(characterID).."' AND `jobID`='1' " )
            end
            triggerClientEvent(client,"restoreTruckerJob",client)
        end
        triggerEvent("restoreJob", client)
        triggerClientEvent(client, "updateCollectionValue", client, tonumber(characterData["photos"]))
        --------------------------------------------------------------------------
        setElementDataEx(client, "license.car", tonumber(characterData["car_license"]), true)
        setElementDataEx(client, "license.bike", tonumber(characterData["bike_license"]), true)
        setElementDataEx(client, "license.boat", tonumber(characterData["boat_license"]), true)
        setElementDataEx(client, "license.pilot", tonumber(characterData["pilot_license"]), true)
        setElementDataEx(client, "license.fish", tonumber(characterData["fish_license"]), true)
        setElementDataEx(client, "license.gun", tonumber(characterData["gun_license"]), true)
        setElementDataEx(client, "license.gun2", tonumber(characterData["gun2_license"]), true)

        setElementDataEx(client, "bankmoney", tonumber(characterData["bankmoney"]), true)
        setElementDataEx(client, "fingerprint", tostring(characterData["fingerprint"]), false)
        setElementDataEx(client, "tag", tonumber(characterData["tag"]))
        setElementDataEx(client, "blindfold", tonumber(characterData["blindfold"]), false)
        setElementDataEx(client, "gender", tonumber(characterData["gender"]))
        setElementDataEx(client, "deaglemode", 1, true) -- Default to lethal
        setElementDataEx(client, "shotgunmode", 1, true) -- Default to lethal
        setElementDataEx(client, "firemode", 0, true) -- Default to auto
        setElementDataEx(client, "clothing:id", tonumber(characterData["clothingid"]) or nil, true)
        
        if tonumber(characterData["pdjail"]) == 1 then -- PD JAIL Chaos New System
            setElementData(client, "jailed", 1)
            exports["prison-system"]:checkForRelease(client, true)
        end

        if (tonumber(characterData["restrainedobj"])>0) then
            setElementDataEx(client, "restrainedObj", tonumber(characterData["restrainedobj"]), false)
        end

        if ( tonumber(characterData["restrainedby"])>0) then
            setElementDataEx(client, "restrainedBy",  tonumber(characterData["restrainedby"]), false)
        end

        -- Cleaning their old weapons
        takeAllWeapons(client)

        if (getElementType(client) == 'player') then
            triggerEvent("updateLocalGuns", client)
        end


        setPedStat(client, 70, 999)
        setPedStat(client, 71, 999)
        setPedStat(client, 72, 999)
        setPedStat(client, 74, 999)
        setPedStat(client, 76, 999)
        setPedStat(client, 77, 999)
        setPedStat(client, 78, 999)
        setPedStat(client, 77, 999)
        setPedStat(client, 78, 999)
        setPedStat(client, 79, 999) -- Strafeing fix

        toggleAllControls(client, true, true, true)
        setElementFrozen(client, false)

        -- Player is cuffed
        if (tonumber(characterData["cuffed"])==1) then
            toggleControl(client, "sprint", false)
            toggleControl(client, "fire", false)
            toggleControl(client, "jump", false)
            toggleControl(client, "next_weapon", false)
            toggleControl(client, "previous_weapon", false)
            toggleControl(client, "accelerate", false)
            toggleControl(client, "brake_reverse", false)
            toggleControl(client, "aim_weapon", false)
        end

        -- Impounded cars, old location


        setPedFightingStyle(client, tonumber(characterData["fightstyle"]))
        triggerEvent("onCharacterLogin", client, charname)

        if not location then
            location = { locationToSpawn.x, locationToSpawn.y, locationToSpawn.z, locationToSpawn.rot, locationToSpawn.int, locationToSpawn.dim }
        end

        triggerClientEvent(client, "accounts:characters:spawn", client, fixedName, adminLevel, gmLevel, location)
        triggerClientEvent(client, "item:updateclient", client)

        if theAdmin then
            local adminTitle = exports.global:getPlayerAdminTitle(theAdmin)
            local adminUsername = getElementData(theAdmin, "account:username")
            outputChatBox("You've logged into player's character successfully!", theAdmin, 0, 255, 0 )
            local hiddenAdmin = getElementData(theAdmin, "hiddenadmin")
            if hiddenAdmin == 0 then
                exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " "..adminUsername.." logged into an other account ("..targetAccountName..") "..tostring(characterData["charactername"]):gsub("_"," ")..".")
            end
        else
            mysql:query_free("UPDATE characters SET lastlogin=NOW() WHERE id='" .. mysql:escape_string(characterID) .. "'")
            exports.logs:dbLog("ac"..tostring(accountID), 27, { "ac"..tostring(accountID), source } , "Spawned" )
            local monitored = getElementData(client, "admin:monitor")
            if monitored then
                if monitored ~= "New Player" then
                    exports.global:sendMessageToAdmins("[MONITOR] ".. getPlayerName(client):gsub("_", " ") .." ("..pid.."): "..monitored)
                    exports.global:sendMessageToSupporters("[MONITOR] ".. getPlayerName(client):gsub("_", " ") .." ("..pid.."): "..monitored)
                end
            end
        end

        setTimer(setPedGravity, 2000, 1, client, 0.008)
        setElementAlpha(client, 255)

        -- WALKING STYLE
        triggerEvent("realism:applyWalkingStyle", client, characterData["walkingstyle"] or 128, true)

        -- blindfolds
        if (tonumber(characterData["blindfold"])==1) then
            setElementDataEx(client, "blindfold", 1)
            outputChatBox("Your character is blindfolded. If this was an OOC action, please contact an administrator via F2.", client, 255, 194, 15)
            fadeCamera(client, false)
        else
            fadeCamera(client, true, 4)
        end

        if (tonumber(characterData["cuffed"])==1) then
            outputChatBox("Your character is restrained.", client, 255, 0, 0)
        end

        setElementHealth(client, tonumber(characterData["health"]))

        --character settings / MAXIME
        loadCharacterSettings(client,characterID)
        setTimer(executeCommandHandler, 3000, 1, "stats", client)
        triggerClientEvent(client, "drawAllMyInteriorBlips", client)

        --MOTD / MAXIME /2015.1.9
        triggerEvent("playerGetMotds", client)

        triggerEvent("item-system:addPlayerArtifacts", client)

        triggerEvent( "account:character:spawned", client ) -- have an event that we can call when a character is spawned.
        triggerClientEvent( client, "account:character:spawned", client ) -- have an event that we can call when a character is spawned.
        --outputDebugString('account:character:spawned')
        if freshSpawn then
            triggerEvent( "social:look", client, client, ":edit" )
        end
    end
end
addEventHandler("accounts:characters:spawn", getRootElement(), spawnCharacter)

function Characters_onCharacterChange()
    triggerClientEvent(client, "items:inventory:hideinv", client)
    --triggerEvent("updateCharacters", client) -- Refresh the character selection screen, perhaps? / No it's too late to update shit here
    triggerEvent("savePlayer", client, "Change Character")
    triggerEvent('setDrunkness', client, 0)
    setElementDataEx(client, "alcohollevel", 0, true)
    setElementDataEx(client, "clothing:id", nil, true)
    removeMasksAndBadges(client)

    setElementDataEx(client, "loggedin", 0, true)
    setElementDataEx(client, "dbid", 0, true)
    setElementDataEx(client, "bankmoney", 0)
    setElementDataEx(client, "account:character:id", false)
    setElementAlpha(client, 0)

    --[[removeElementData(client, "jailed")
    removeElementData(client, "jail_time")
    removeElementData(client, "jail:id")
    removeElementData(client, "jail:cell")
    removeElementData(client, "jail_time_online")
    removeElementData(client, "jail:timer")]]
    setElementData(client, "dispatch:onDuty", false)
    triggerClientEvent("dispatch:onDutyChange", root, false, client)
    removeElementData(client, "enableGunAttach")
    triggerEvent("destroyWepObjects", client)
    triggerEvent("cards:leave_session", client)
    triggerEvent("endViewPropertyInterior", client, client, true)

    if (getPedOccupiedVehicle(client)) then
        removePedFromVehicle(client)
    end
    exports.global:updateNametagColor(client)
    local clientAccountID = getElementDataEx(client, "account:id") or -1

    setElementInterior(client, 0)
    setElementDimension(client, 1)
    setElementPosition(client, -26.8828125, 2320.951171875, 24.303373336792)

    setElementDataEx(client, "legitnamechange", 1)
    makeOwlName(client)
    setElementDataEx(client, "legitnamechange", 0)

    exports.logs:dbLog("ac"..tostring(clientAccountID), 27, { "ac"..tostring(clientAccountID), client } , "Went to character selection" )
    triggerEvent("shop:removeMeFromCurrentShopUser",client, client)
    triggerClientEvent(client, "hideGeneralshopUI", client)
    triggerEvent("artifacts:removeAllOnPlayer",client, client)

    removeElementData(client, "chat:status")

    --outputDebugString('account:character:select')
    triggerEvent( "account:character:select", client ) -- have an event that we can call when player comes to character selectio screen.
    triggerClientEvent( client, "account:character:select", client ) -- have an event that we can call when player comes to character selectio screen.

    --keypad door lock
    local padId = getElementData(client, "padUsing")
    if padId then
        removeElementData(client, "padUsing")
        for key, thePad in pairs(getElementsByType("object", getResourceRootElement(getResourceFromName("item-world")))) do
            if getElementData(thePad, "id") == padId then
                removeElementData(thePad, "playerUsing")
                break
            end
        end
    end
end
addEventHandler("accounts:characters:change", getRootElement(), Characters_onCharacterChange)

-- sometimes your character position is not properly set, and your position is retained from the char selection (somewhere near angel pine) albeit it shouldn't be.
function fixCharacterSpawnPosition(expectedLocation)
    local currentPositionX, currentPositionY = getElementPosition(client)
    local expectedPositionX, expectedPositionY = expectedLocation[1], expectedLocation[2]
    if getDistanceBetweenPoints2D( currentPositionX, currentPositionY, unpack( defaultCharacterSelectionSpawnPosition ) ) < 20 and -- we are near angel pine
            getDistanceBetweenPoints2D( expectedPositionX, expectedPositionY, unpack( defaultCharacterSelectionSpawnPosition ) ) > 20 then -- but we shouldn't actually be near angel pine
        setElementPosition(client, expectedPositionX, expectedPositionY, expectedLocation[3])
        setElementInterior(client, expectedLocation[5] or 0)
        setElementDimension(client, expectedLocation[6] or 0)
    end
end
addEventHandler("accounts:characters:fixCharacterSpawnPosition", root, fixCharacterSpawnPosition)

function removeMasksAndBadges(client)
    for k, v in ipairs({exports['item-system']:getMasks(), exports['item-system']:getBadges()}) do
        for kx, vx in pairs(v) do
            if getElementData(client, vx[1]) then
                setElementDataEx(client, vx[1], false, true)
            end
        end
    end
end

function flushPlayerAvatars ( quitType )
    local id = getElementData(source, 'account:id')
    local fid = getElementData(source, 'account:forumid')
    if id then
        exports.cache:removeImage(id, false)
    end
    if fid then
        --exports.cache:removeImage('http://owlgaming.net/favatar.php?id='..fid, true)
    end
end
addEventHandler ( "onPlayerQuit", getRootElement(), flushPlayerAvatars )
