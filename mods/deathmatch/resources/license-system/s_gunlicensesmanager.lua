addEventHandler("onResourceStart", resourceRoot,
	function()
		local result = mysql:query( "SELECT `charactername`, `gun_license`, `gun2_license` FROM `characters` WHERE `gun_license`=1 OR `gun2_license`=1" )
		local result_table = { }
		while true do
			local row = mysql:fetch_assoc( result )
			if not row then
				break
			end
			table.insert(result_table, row)
		end
		mysql:free_result( result )

		--[[setTimer( function()
			triggerClientEvent("fetchTable", resourceRoot, result_table)
		end, 2000, 1) ]]

		setElementData(resourceRoot, "gunlicense:table", result_table)
	end)

function syncTable(guntable)
	if type(guntable) == "table" then
		setElementData(resourceRoot, "gunlicense:table", guntable)
		for k,v in ipairs(exports.pool:getPoolElementsByType("player")) do
			if getElementData(v, "gunlicense:activewindow") then
				triggerClientEvent(v, "gunlicense:refreshclient", resourceRoot)
			end
		end
	end
end
addEvent("gunlicense:synctable", true)
addEventHandler("gunlicense:synctable", resourceRoot, syncTable)

local function canManageLicenses(player)
	return exports.integration:isPlayerLeadAdmin(player) or (
			exports.global:hasItem(player, 209) and (
				exports.factions:isPlayerInFaction(player, 1) or
				exports.factions:isPlayerInFaction(player, 50) or
				exports.factions:isPlayerInFaction(player, 59)
			)
		)
end

function startThis(thePlayer)
	if not canManageLicenses(thePlayer) then
		return
	end

	triggerClientEvent(thePlayer, "weaponlicensesGUI", thePlayer)
end
addCommandHandler("weaponlicenses", startThis)
addEvent("gunlicense:weaponlicenses", true)
addEventHandler("gunlicense:weaponlicenses", root, startThis)


-- Revoking section
function revokeElements(name)
	if not canManageLicenses(client) then
		return
	end

	if name then
		exports.anticheat:changeProtectedElementDataEx(getPlayerFromName(name), "license.gun", 0, false)
		exports.anticheat:changeProtectedElementDataEx(getPlayerFromName(name), "license.gun2", 0, false)
	end
end
addEvent("gunlicense:revokeElement", true)
addEventHandler("gunlicense:revokeElement", resourceRoot, revokeElements)

function mysqlRevoke(name)
	if not canManageLicenses(client) then
		return
	end

	if name then
		exports.mysql:query_free("UPDATE characters SET gun_license='0', gun2_license='0' WHERE charactername='"..exports.mysql:escape_string(name).."' LIMIT 1")
	end
end
addEvent("gunlicense:revokemysql", true)
addEventHandler("gunlicense:revokemysql", resourceRoot, mysqlRevoke)

-- Issueing section
function changeElement(name, licensetype)
	if not canManageLicenses(client) then
		return
	end

	if name and (licensetype == "gun" or licensetype == "gun2") and isElement(getPlayerFromName(name)) then
		if getElementData(getPlayerFromName(name), "loggedin") == 1 then
			exports.anticheat:changeProtectedElementDataEx(getPlayerFromName(name), "license."..licensetype, 1, false)
		end
	end
end
addEvent("gunlicense:changeelement", true)
addEventHandler("gunlicense:changeelement", resourceRoot, changeElement)

function mysqlIssue(name, licensetype)
	if not canManageLicenses(client) then
		return
	end

	local onlinePlayer = getPlayerFromName(name)

	if name and (licensetype == "gun" or licensetype == "gun2") then
		dbExec(exports.mysql:getConn('mta'), "UPDATE characters SET ?? = 1 WHERE charactername = ?", licensetype .. '_license', name)
		if onlinePlayer then
			outputChatBox("You have been issued a weapon license.", onlinePlayer)
		end
	end
end
addEvent("gunlicense:issuemysql", true)
addEventHandler("gunlicense:issuemysql", resourceRoot, mysqlIssue)
