local mysql = exports.mysql

function getElementDataEx(theElement, theParameter)
	return getElementData(theElement, theParameter)
end

function setElementDataEx(theElement, theParameter, theValue, syncToClient, noSyncAtall)
	if syncToClient == nil then
		syncToClient = false
	end

	if noSyncAtall == nil then
		noSyncAtall = false
	end

	if tonumber(theValue) then
		theValue = tonumber(theValue)
	end

	exports.anticheat:changeProtectedElementDataEx(theElement, theParameter, theValue, syncToClient, noSyncAtall)
	return true
end

function resourceStart(resource)
	setWaveHeight ( 0 )
	setGameType("Roleplay")
	--setGameType("")
	setMapName("Los Santos")
	setRuleValue("Script Version", exports.global:getScriptVersion())
	setRuleValue("Author", "OwlGaming - MTA Server Development Team")
	setRuleValue("Website", "www.owlgaming.net")
	setGlitchEnabled ( "baddrivebyhitbox", false )
	setFPSLimit(60) -- 72 is the real max before issues arise

	for key, value in ipairs(exports.pool:getPoolElementsByType("player")) do
		triggerEvent("playerJoinResourceStart", value, resource)
	end

	local appsRes = getResourceFromName("apps")
	if appsRes then
		restartResource(appsRes)
	end
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), resourceStart)

function onJoin()
	local skipreset = false
	local loggedIn = getElementData(source, "loggedin")
	if loggedIn == 1 then
		local accountID = getElementData(source, "account:id")
		local mQuery1 = mysql:query("SELECT `account_id` FROM `account_details` WHERE `account_id`='"..mysql:escape_string(accountID).."'")
		if mysql:num_rows(mQuery1) == 1 then
			skipreset = true
			setElementDataEx(source, "account:seamless:validated", true, false, true)
		end
		mysql:free_result(mQuery1)
	end
	if not skipreset then
		-- Set the user as not logged in, so they can't see chat or use commands
		exports.anticheat:changeProtectedElementDataEx(source, "loggedin", 0, false)
		exports.anticheat:changeProtectedElementDataEx(source, "account:loggedin", false, false)
		exports.anticheat:changeProtectedElementDataEx(source, "account:username", "", false)
		exports.anticheat:changeProtectedElementDataEx(source, "account:id", "", false)
		exports.anticheat:changeProtectedElementDataEx(source, "dbid", 0, true)
		exports.anticheat:changeProtectedElementDataEx(source, "admin_level", 0, false)
		exports.anticheat:changeProtectedElementDataEx(source, "hiddenadmin", 0, false)
		exports.anticheat:changeProtectedElementDataEx(source, "globalooc", 1, false)
		exports.anticheat:changeProtectedElementDataEx(source, "muted", 0, false)
		exports.anticheat:changeProtectedElementDataEx(source, "loginattempts", 0, false)
		exports.anticheat:changeProtectedElementDataEx(source, "timeinserver", 0, false)
		setElementData(source, "chatbubbles", 0, false)
		setElementDimension(source, 9999)
		setElementInterior(source, 0)
		makeOwlName(source)

		-- slowly fade the camera in to make the screen visible
		fadeCamera(source, true, 5)
		-- set the player's camera to a fixed position, looking at a fixed point
		setCameraMatrix(source, 1468.8785400391, -919.25317382813, 100.153465271, 1468.388671875, -918.42474365234, 99.881813049316)
	end

	exports.global:updateNametagColor(source)
end
addEventHandler("onPlayerJoin", getRootElement(), onJoin)
addEvent("playerJoinResourceStart", false)
addEventHandler("playerJoinResourceStart", getRootElement(), onJoin)

function resetNick(oldNick, newNick)
	exports.anticheat:changeProtectedElementDataEx(client, "legitnamechange", 1)
	setPlayerName(client, oldNick)
	exports.anticheat:changeProtectedElementDataEx(client, "legitnamechange", 0)
	exports.global:sendMessageToAdmins("AdmWrn: " .. tostring(oldNick) .. " tried to change their name to " .. tostring(newNick) .. ".")
end
addEvent("resetName", true )
addEventHandler("resetName", getRootElement(), resetNick)

function makeOwlName(thePlayer)
	setPlayerName(thePlayer, "Owl.Player."..tostring(math.random(0,9))..tostring(math.random(0,9))..tostring(math.random(0,9))..tostring(math.random(0,9)))
end
