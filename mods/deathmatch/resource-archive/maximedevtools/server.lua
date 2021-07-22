mysql = exports.mysql

--[[function interior ( source, commandName, interior )
	--Let's see if they gave an interior ID
	if ( interior ) then
		--They did, so lets assign them to that interior and teleport them there (all in 1 function call!)
		setElementInterior ( source, interior, 2233.91, 1714.73, 1011.38 )
	else
		--They didn't give one, so set them to the interior they wanted, but don't teleport them.
		setElementInterior ( source, 0 )
	end
end
addCommandHandler ( "maxime", interior )
]]

--THIS IS USED TO GET  PLAYER'S ALL ELEMENT DATA FROM SERVER
function getAllDataFromPlayer ( player, commandName, playerid )
	local data = getAllElementData ( player )     -- get all the element data of the player who entered the command
		for k, v in pairs ( data ) do                    -- loop through the table that was returned
				outputChatBox ( tostring(k) .. ": " .. tostring(v), player )             -- print the name (k) and value (v) of each element data
			end
		end
--addCommandHandler ( "getelementserver", getAllDataFromPlayer )

function deletePosters(thePlayer)
	if exports.integration:isPlayerScripter(thePlayer) then
		outputChatBox("Possible Lag incoming as all posters are cleaned up...", getRootElement(), 53, 196, 170)
		outputChatBox("Please standby...", getRootElement(), 53, 196, 170)
		setTimer(function() exports["item-system"]:deleteAll(175) outputChatBox("Done!", getRootElement(), 53, 196, 170) end, 5000, 1)
	end
end
--addCommandHandler("clearposters", deletePosters)

local toLoad = {}
local threads = {}
function loadAllVehicles(res)
	local result = mysql:query("SELECT id FROM `worlditems`")
	if result then
		while true do
			local row = mysql:fetch_assoc(result)
			if not row then break end

			toLoad[tonumber(row["id"])] = true
		end
		mysql:free_result(result)

		for id in pairs( toLoad ) do
			local co = coroutine.create(loadOneVehicle)
			coroutine.resume(co, id, true)
			table.insert(threads, co)
		end
		setTimer(resume, 1000, 4)
		outputDebugString( "loadAllVehicles succeeded" )
	else
		outputDebugString( "loadAllVehicles failed" )
	end
end
--addEventHandler("onResourceStart", resourceRoot, loadAllVehicles)

function loadOneVehicle(id, hasCoroutine)
	if (hasCoroutine) then
		coroutine.yield()
	end
	outputDebugString( id )
end

function resume()
	for key, value in ipairs(threads) do
		coroutine.resume(value)
	end
end

function playerloc ( source )
	local playername = getPlayerName ( source )
	local location = getElementZoneName ( source )
		outputChatBox ( "* " .. playername .. "'s Location: " .. location, getRootElement(), 0, 255, 255 ) -- Output the player's name and zone name
	end
--addCommandHandler ( "loc", playerloc )

--[[function checkChange(dataName,oldValue)
				if (dataName == "seatbelt") then
						outputDebugString( "***DATA CHECK: Setting of "..tostring(dataName).. " to "..tostring((getElementData(source, "seatbelt") == true)).." RESOURCE: "..getResourceName(sourceResource).." SOURCE: "..getPlayerName(source) or "N/A" )
				end
end
addEventHandler("onElementDataChange",getRootElement(),checkChange)]]

TESTER = 25
SCRIPTER = 32
LEADSCRIPTER = 79
COMMUNITYLEADER = 14
TRIALADMIN = 18
ADMIN = 17
SENIORADMIN = 64
LEADADMIN = 15
SUPPORTER = 30
VEHICLE_CONSULTATION_TEAM_LEADER = 39
VEHICLE_CONSULTATION_TEAM_MEMBER = 43
MAPPING_TEAM_LEADER = 44
MAPPING_TEAM_MEMBER = 28
STAFF_MEMBER = {32, 14, 18, 17, 64, 15, 30, 39, 43, 44, 28}
AUXILIARY_GROUPS = {32, 39, 43, 44, 28}
ADMIN_GROUPS = {14, 18, 17, 64, 15}

function cloneBan(thePlayer, cmd)
	local forums = {}
	outputChatBox("1. Started Fetching Bans.", thePlayer)
	local mQuery1 = mysql:query("SELECT id, mtaserial, ip, banned_reason, banned_by FROM accounts WHERE banned=1")
	while true do
		local row = mysql:fetch_assoc(mQuery1)
		if not row then break end
		table.insert(forums, row )
	end
	mysql:free_result(mQuery1)
	outputChatBox("-> Fetched "..#forums.." records.", thePlayer)

	outputChatBox("2. Started updating", thePlayer)
	for key, user in pairs(forums) do
		local tail = ''
		local banned_by = user.banned_by
		if banned_by and tonumber(banned_by) then
			tail = tail..", admin='"..banned_by.."'"
		end
		local mtaserial = user.mtaserial
		if mtaserial and string.len(mtaserial) and string.len(mtaserial)>0 then
			tail = tail..", serial='"..mtaserial.."'"
		end
		local ip = user.ip
		if ip and string.len(ip) and string.len(ip)>0 then
			tail = tail..", ip='"..ip.."'"
		end
		local banned_reason = user.banned_reason
		if banned_reason and string.len(banned_reason) and string.len(banned_reason)>0 then
			tail = tail..", reason='"..banned_reason.."'"
		else
			tail = tail..", reason='N/A'"
		end
		mysql:query_free("INSERT INTO bans SET account='"..user.id.."' "..tail) 
	end
	outputChatBox("-> Done.", thePlayer)
end
--addCommandHandler ( "cloneban", cloneBan )

-- result is called when the function returns
function result(sum)
	outputDebugString(sum)
end
function addNumbers1(p, c, number1, number2)
	callRemote ( "http://owlgaming.net/postback-mta.php", result, number1, number2 )
	outputDebugString("called")
end 


function patchNotes_update(player)
	callRemote("http://owlgaming.net/postback-mta.php?action=account_activation&data=1", 
		function( title, text)
			if title == "ERROR" then
				outputDebugString( "Failed to activate : " .. text )
				if player then
					outputChatBox( "Patch notes failed: " .. text, player )
				end
			else
				if player then
					outputChatBox( "Patch notes set to: " .. tostring(title), player )
					outputChatBox( "Patch notes set to: " .. tostring(text), player )
				end
			end
		end
		)
end
--addCommandHandler("addNumbers", patchNotes_update)

function kickEveryone(player, c, d)
	if exports.integration:isPlayerScripter(player) then
		executeCommandHandler('saveall', player)
		setTimer(function ()
			local p = getRandomPlayer ( )
			if p ~= player then
				kickPlayer ( p, "Server maintemaince. Check back soon!" )
			end
			end, tonumber(d) or 100, 0)
		setServerPassword ( 'stringthePassword' )
	end
end
addCommandHandler("kickall", kickEveryone)

local counter1 = 0
local counter2 = 0
local bigAccounts = {}
local smallAccounts = {}
function cleanUpAccounts(p, c, d)
	if exports.integration:isPlayerScripter(p) then
		exports.global:sendMessageToStaff("Account Cleanup Started...", true)
		counter1=0
		counter2=0
		bigAccounts = {}
		smallAccounts = {}
		dbQuery( function(qh, p) 
			local result, total_accounts = dbPoll ( qh, 0 ) 
			if result and #result>0 then
				exports.global:sendMessageToStaff("- Going thru "..#result.." accounts.", true)
				for _, row in ipairs(result) do
					if tonumber(row.chars) > 30 then
						table.insert(bigAccounts, row)
					elseif tonumber(row.chars) == 0 then
						table.insert(smallAccounts, row)
					end
				end
			end
						
			exports.global:sendMessageToStaff("-- Detected and going thru "..#bigAccounts.." accounts with more than 30 characters created.", true)
			for _, row in ipairs(bigAccounts) do
				dbQuery( function(qh2, row) 
					local chars = dbPoll ( qh2, 0 ) 
					if chars and #chars>0 then
						exports.global:sendMessageToStaff("---- Reset and deleting "..#chars.." characters with last login > 15 days and with 0 hoursplayed from account '"..row.username.."'.", true)
						for _, char in pairs(chars) do
							executeCommandHandler('resetcharacter', p, char.charactername)
							dbExec( exports.mysql:getConn('mta'), "DELETE FROM characters WHERE id=?", char.id )
							counter1 = counter1 + 1
							if counter1 == #chars then
								cleanUpAccountsResults(1)
							end
						end
					end
				end, {row}, exports.mysql:getConn('mta'), "SELECT id, charactername FROM characters WHERE account=? AND hoursplayed=0 AND DATEDIFF(NOW(), lastlogin) > 15", row.id )
			end

			dbQuery( function (qh3) 
				local accs = dbPoll ( qh3, 0 ) 
				if accs and #accs>0 then
					for _, acc in pairs(accs) do
						if acc.chars == 0 then
							dbExec( exports.mysql:getConn('mta'), "DELETE FROM accounts WHERE id=?", acc.id )
							counter2 = counter2 + 1
							if counter2 == #accs then
								cleanUpAccountsResults(2)
							end
						end
					end
				end
			end, {}, exports.mysql:getConn('mta'), "SELECT username, a.id AS id, count(c.account) AS chars FROM accounts a LEFT JOIN characters c ON a.id=c.account WHERE DATEDIFF(NOW(), a.lastlogin) > 15 GROUP BY username" )
			
		end, {p}, exports.mysql:getConn('mta'), "SELECT username, a.id AS id, count(c.account) AS chars FROM accounts a LEFT JOIN characters c ON a.id=c.account GROUP BY username ORDER BY chars DESC" )
	end
end
addCommandHandler('cleanupaccounts', cleanUpAccounts, false)

function cleanUpAccountsResults(id)
	exports.global:sendMessageToStaff("-----------------ACCOUNT CLEANUP RESULT-----------------", true)
	if id == 1 then
		exports.global:sendMessageToStaff("Reset and deleted "..counter1.." characters over "..#bigAccounts.." accounts with 30+ characters.", true)
	else
		exports.global:sendMessageToStaff("Detected and deleted "..counter2.."/"..#smallAccounts.." accounts with last login > 15 days and with 0 characters.", true)
	end
	exports.global:sendMessageToStaff("------------------END------------------", true)
end

function revertIntVehsTaxPerk(p)
	if exports.integration:isPlayerScripter(p) then
		dbQuery( function (qh) 
			local perkcost = {
				[39] = 300,
				[40] = 200,
			}
			local perks = dbPoll ( qh, 0 ) 
			if perks and #perks>0 then
				local t_hours, t_gc = 0, 0
				for _, perk in pairs(perks) do
					dbExec( exports.mysql:getConn('mta'), "DELETE FROM donators WHERE id=? ", perk.id )
					local gc = exports.global:round( ( perkcost[ perk.perkID ] / 30 / 24 ) * perk.remaining_hours )
					local log = "Refund for remaining "..exports.global:round(perk.remaining_hours).." hours of '"..exports.donators:getPerks(perk.perkID)[1].."' as this perk was removed from donation system."
					exports.donators:giveAccountGC( perk.accountID, gc, log )
					t_hours = t_hours + perk.remaining_hours
					t_gc = t_gc + gc
				end
				exports.global:sendMessageToStaff("[DONATION] No vehicle/interior taxes perks removed. Refunded in total of "..t_gc.." GC for total "..t_hours.." remaining hours to "..#perks.." accounts.", true)

				for i, p in pairs( getElementsByType('player') ) do
					local perkTable = getElementData(p, "donation-system:perks")				
					if perkTable and type(perkTable) == 'table' then
						table.remove(perkTable, 39)
						table.remove(perkTable, 40)
						exports.anticheat:setEld( p, "donation-system:perks", perkTable, 'one' )
					end
				end
			end
		end, {}, exports.mysql:getConn('mta'), "SELECT *, time_to_sec(timediff(expirationDate, NOW()))/3600 AS remaining_hours FROM donators WHERE (perkID=39 OR perkID=40) AND expirationDate > NOW()" )
	end
end
addCommandHandler( 'revertIntVehsTaxPerk', revertIntVehsTaxPerk )

local file
local renamed = true

addCommandHandler( 'open', function()
	file = fileOpen( 'test.txt' )
	outputChatBox( tostring( file ) )
end )

addCommandHandler( 'create', function()
	file = fileCreate( 'test.txt' )
	outputChatBox( tostring( file ) )
end )

addCommandHandler( 'close', function()
	outputChatBox( tostring( fileClose( file ) ) )
end )

addCommandHandler( 'delete', function()
	outputChatBox( tostring( fileDelete( 'test.txt' ) ) )
end )

addCommandHandler( 'write', function()
	outputChatBox( tostring( fileWrite( file, "This is a test file!") ) )
end )

addCommandHandler( 'rename', function()
	local a = renamed and fileRename( 'test.txt',  'test_2.txt' ) or fileRename( 'test_2.txt',  'test.txt' )
	renamed = not renamed
	outputChatBox( tostring( a ) )
end )

addCommandHandler( 'createalot', function()
	for i=1, 1000 do 
		if not fileCreate( 'test_'..i..'.txt' ) then
			outputChatBox(i)
			break
		end
	end
end )

addCommandHandler( 'openalot', function()
	for i=1, 1000 do 
		if not fileOpen( 'test_'..i..'.txt' ) then
			outputChatBox(i)
			break
		end
	end
end )
