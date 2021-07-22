function doTheft(thePlayer, command, targetPlayerName, targetVehicle)
	if (exports.integration:isPlayerTrialAdmin(thePlayer)) then
		if not (targetPlayerName) or not (targetVehicle) then
			outputChatBox("SYNTAX: /" .. command .. " [Partial Player Name / ID] [Vehicle ID]", thePlayer, 255, 194, 14)
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick( thePlayer, targetPlayerName )
			local logged = getElementData(targetPlayer, "loggedin")
			if (logged==1) then
				triggerClientEvent(thePlayer, "theft:render", getRootElement(), targetPlayerName, targetVehicle, targetPlayer, thePlayer)
			else
				outputChatBox("Player is not logged in.", thePlayer, 255, 0, 0)
			end
		end
	end
end
-- Disabled temporarly
--addCommandHandler("vehpost", doTheft)

function theftPost(noteEdit, EngineCheck, KeyCheck, targetPlayerName, targetVehicle, targetPlayer, SellVehCheck, ChangeLockCheck)
	--[[
	local veh = getPedOccupiedVehicle(targetPlayer)
	local enginestarted = "No."
	local keygiven = "No."
	local lockchanged = "No."
	local vehsold = "No."
	if EngineCheck then
		local theVehicle = exports.pool:getElement("vehicle", targetVehicle)
		setVehicleEngineState(theVehicle, true)
		exports.mysql:query_free("UPDATE vehicles SET engine='1', handbrake='0' WHERE id = '" .. exports.mysql:escape_string(targetVehicle) .. "'")
		exports.anticheat:changeProtectedElementDataEx(theVehicle, "engine", 1, true)
		exports.anticheat:changeProtectedElementDataEx(theVehicle, "handbrake", 0, true)
		enginestarted = "Yes."
		local x, y, z = getElementPosition(theVehicle)
		local int = getElementInterior(theVehicle)
		local dim = getElementDimension(theVehicle)
		exports.vehicle:reloadVehicle(tonumber(targetVehicle))
		local newVehicleElement = exports.pool:getElement("vehicle", targetVehicle)
		setElementPosition(newVehicleElement, x, y, z)
		setElementInterior(newVehicleElement, int)
		setElementDimension(newVehicleElement, dim)
		outputChatBox("Engine started, handbrake lifted.", source, 255, 0, 0)
	end
	if KeyCheck then
		exports['global']:giveItem(targetPlayer, 3, targetVehicle)
		keygiven = "Yes."
		outputChatBox(targetPlayerName:gsub("_"," ").. " has been spawned a vehicle key for vehicle ID " ..targetVehicle.. ".", source, 0, 255, 0)
		outputChatBox("You have been given a vehicle key to vehicle ID " ..targetVehicle.. ".", targetPlayer, 0, 255, 0)
	end
	if ChangeLockCheck then
		exports['item-system']:deleteAll(3, targetVehicle)
		local possiblePlayers = getElementsByType("player")
		for k, v in ipairs(possiblePlayers) do
			exports["item-system"]:takeItem(v, 3, tonumber(targetVehicle))
		end
		exports['item-system']:giveItem(targetPlayer, 3, targetVehicle)
		lockchanged = "Yes."
		outputChatBox( "Locks changed and keys spawned.", source, 0, 255, 0 )
		outputChatBox("Locks on a vehicle has been changed, and you have been given the keys.", targetPlayer, 0, 255, 0)
	end
	local targetUsername = getElementData(targetPlayer, "account:username")
	local adminUsername = getElementData(source, "account:username")
	local realTime = getRealTime()
	local notes = noteEdit:gsub("'","''")
	date = string.format("%04d/%02d/%02d", realTime.year + 1900, realTime.month + 1, realTime.monthday )
	time = string.format("%02d:%02d", realTime.hour, realTime.minute )
	local query = exports.mysql:query("SELECT `model` FROM `vehicles` WHERE id ='" .. exports.mysql:escape_string(targetVehicle) .. "'")
	local model = false
	if query then
		model  = exports.mysql:fetch_assoc(query)["model"]
		exports.mysql:free_result(query) -- Free RAM Memory
	else
		outputDebugString("[THEFT POST SYSTEM] / s_vehtheft.lua / line 41 / Database Error!")
		return false
	end
	if not model then
		outputDebugString("[THEFT POST SYSTEM] / s_vehtheft.lua / line 45 / Vehicle has no ID!")
		return false
	end
	local query2 = exports.mysql:query("SELECT `owner` FROM `vehicles` WHERE id ='" .. exports.mysql:escape_string(targetVehicle) .. "'")
	local owner = false
	if query2 then
		owner  = exports.mysql:fetch_assoc(query2)["owner"]
		exports.mysql:free_result(query2) -- Free RAM Memory
	else
		outputDebugString("[THEFT POST SYSTEM] / s_vehtheft.lua / line 54 / Database Error!")
		return false
	end
	if not owner then
		outputDebugString("[THEFT POST SYSTEM] / s_vehtheft.lua / line 58 / Vehicle has no ownert!")
		return false
	end
	local query3 = exports.mysql:query("SELECT `charactername` FROM `characters` WHERE id ='" .. owner .. "'")
	local actualOwner = false
	if query3 then
		actualOwner  = exports.mysql:fetch_assoc(query3)["charactername"]
		exports.mysql:free_result(query3) -- Free RAM Memory
	else
		outputDebugString("[THEFT POST SYSTEM] / s_vehtheft.lua / line 67 / Database Error!")
		return false
	end
	if not actualOwner then
		outputDebugString("THEFT POST SYSTEM] / s_vehtheft.lua / line 71 / Vehicle has no ID!")
		return false
	end
	if SellVehCheck then
		local query = exports.mysql:query_free("UPDATE vehicles SET owner = '" .. exports.mysql:escape_string(getElementData(targetPlayer, "dbid")) .. "' WHERE id='" .. exports.mysql:escape_string(targetVehicle) .. "'")
		if query then
			local theVehicle = exports.pool:getElement("vehicle", targetVehicle)
			exports.anticheat:changeProtectedElementDataEx(theVehicle, "owner", getElementData(targetPlayer, "dbid"))
			vehsold = "Yes."
			exports.global:giveItem(targetPlayer, 3, targetVehicle)
			outputChatBox("Vehicle has been sold.", source, 0, 255, 0)
			outputChatBox("A vehicle has been sold to you.", targetPlayer, 0, 255, 0)
		end
	end
	local account = getElementData(targetPlayer, "account:id")
	local result = exports.mysql:query("SELECT `adminnote` FROM `accounts` WHERE id='" .. account .."'")
	local note = " "
	if result then
		note = exports.mysql:fetch_assoc(result)["adminnote"]
		exports.mysql:free_result(result)
	end
	local plustext = ("--------- Vehicle Theft --------- \r\nVehicle ID: " .. targetVehicle:gsub("'","''") .. " \r\nCharacter: " .. getPlayerName(targetPlayer):gsub("'","''"):gsub("_"," ") .. "\r\nDate: " .. date:gsub("'","''") .. "\r\nApproved by: " ..adminUsername:gsub("'","''").. "\r\nNotes: \r\n" .. notes:gsub("'","''") .. "\r\n--------------------------------------")
	--local result2 = exports.mysql:query_free("UPDATE accounts SET adminnote = '" .. exports.mysql:escape_string( plustext ).. '\r\n \r\n' .. exports.mysql:escape_string( note ) .."' WHERE id = " .. exports.mysql:escape_string(account) )
	local result2 = false
	if result2 then
		outputChatBox(getPlayerName(targetPlayer):gsub("_"," ").. "'s /check updated.", source, 0, 255, 0)
	else
		outputChatBox("Autoupdate for "..getPlayerName(targetPlayer):gsub("_"," ").. "'s adminnote in /check has failed. Please update manually.", source, 255, 0, 0)
	end
	local result3 = exports.mysql:query("SELECT `note` FROM `vehicles` WHERE `id`='" .. targetVehicle .."'")
	local note2 = " "
	if result3 then
		note2 = tostring(exports.mysql:fetch_assoc(result3)["note"])
		exports.mysql:free_result(result3)
	end
	--outputDebugString(tostring(note2))
	local result4 = exports.mysql:query_free("UPDATE `vehicles` SET `note`='" ..plustext:gsub("'","''").. "\r\n \r\n" ..note2:gsub("'","''").."' WHERE `id`=" ..targetVehicle)
	if result4 then
		outputChatBox("Vehicle ID " .. targetVehicle .. "'s /checkveh updated.", source, 0, 255, 0)
	else
		outputChatBox("Vehicle ID " .. targetVehicle .. "'s /checkveh failed to update.", source, 255, 0, 0)
	end
	exports.vehicle_manager:addVehicleLogs(targetVehicle, "approved theft", source)
	local vehicleName = getVehicleNameFromModel(model)

	local threadTitle = ("Vehicle ID " .. targetVehicle .. " (" .. vehicleName .. ") - " ..getPlayerName(targetPlayer):gsub("_"," "))
	local postID = exports.mysql:forum_query_insert_free("insert into post set threadid = '9999', parentid = '0', username = 'Chuevo', userid = '2', title = '" .. threadTitle .. "', dateline = unix_timestamp(), pagetext = '[B]Players Name:[/B] " .. getPlayerName(targetPlayer):gsub("_", " ").. " (" ..targetUsername.. ") <br>[B]Date: [/B]" ..date.. "<br>[B]Vehicle Owner: [/B]" ..actualOwner:gsub("_", " ").. "<br>[B]Vehicle Model:[/B] " .. vehicleName .. " <br>[B]Vehicle ID:[/B] "..targetVehicle.."<br>[B]Approved by:[/B] " .. getPlayerName(source):gsub("_", " ").. " (" ..adminUsername..")<br>[B]Notes:[/B]<br> " ..notes.. "<br><br>[B]Engine started: [/B]" ..enginestarted.. "<br>[B]Keys given:[/B] " ..keygiven.. "<br>[B]Locks changed: [/B]" ..lockchanged.. "<br>[B]Vehicle sold: [/B]" ..vehsold.. "', allowsmilie = '1', showsignature = '0', ipaddress = '127.0.0.1', iconid = '0', visible = '1', attach = '0', infraction = '0', reportthreadid = '0'")
	local secondShit = exports.mysql:forum_query_insert_free("insert into thread set title = '" .. threadTitle .. "', firstpostid = '" .. postID .. "', lastpostid = '19285', lastpost = unix_timestamp(), forumid = '561', pollid = '0', open = '1', replycount = '0', postercount = '1', hiddencount = '0', deletedcount = '0', postusername = 'Chuevo', postuserid = '2', lastposter = 'Chuevo', lastposterid = '2', dateline = unix_timestamp(), views = '0', iconid = '0', visible = '1', sticky = '0', votenum = '0', votetotal = '0', attach = '0', force_read = '0', force_read_order = '10', force_read_expire_date = '0'")
		exports.mysql:forum_query_free("update post set threadid = '"..secondShit.."' where postid = '"..postID.."'")
		exports.mysql:forum_query_free("update `user` set posts = posts + 1 where userid = '2'")
		exports.mysql:forum_query_free("UPDATE forum set replycount = replycount + 1, lastpost = unix_timestamp(), lastposter = 'Chuevo', lastposterid='2', lastpostid='"..postID.."', lastthread='"..threadTitle.."', lastthreadid='"..secondShit.."', threadcount = threadcount + 1 WHERE forumid = 561")
		exports.mysql:forum_query_free("UPDATE forum set replycount = replycount + 1, lastpost = unix_timestamp(), lastposter = 'Chuevo', lastposterid='2', lastpostid='"..postID.."', lastthread='"..threadTitle.."', lastthreadid='"..secondShit.."', threadcount = threadcount + 1 WHERE forumid = 41")
		--exports.mysql:forum_query_free("UPDATE forum set replycount = replycount + 1, lastpost = unix_timestamp(), lastposter = 'Chuevo', lastposterid='2', lastpostid='"..postID.."', lastthread='"..threadTitle.."', lastthreadid='"..secondShit.."', threadcount = threadcount + 1 WHERE forumid = 93")
		exports.mysql:forum_query_free("UPDATE forum set replycount = replycount + 1, lastpost = unix_timestamp(), lastposter = 'Chuevo', lastposterid='2', lastpostid='"..postID.."', lastthread='"..threadTitle.."', lastthreadid='"..secondShit.."', threadcount = threadcount + 1 WHERE forumid = 38")
		exports.mysql:forum_query_free("UPDATE forum set replycount = replycount + 1, lastpost = unix_timestamp(), lastposter = 'Chuevo', lastposterid='2', lastpostid='"..postID.."', lastthread='"..threadTitle.."', lastthreadid='"..secondShit.."', threadcount = threadcount + 1 WHERE forumid = 31")
	for k, v in ipairs(exports.global:getAdmins()) do
		local adminduty = getElementData(v, "duty_admin")
		if adminduty == 1 then
		outputChatBox("[VT-POST] " .. adminUsername .. " has approved a vehicle theft for " .. getPlayerName(targetPlayer):gsub("_", " ").. " on vehicle ID " .. targetVehicle .. " (" .. vehicleName .. ").", v, 250, 217, 5)
		outputChatBox("[VT-POST] Theft post successfully created: http://www.forums.owlgaming.net/showthread.php/6205-Vehicle-Thefts?p="..postID.."#post"..postID..".", v, 250, 217, 5)
		end
	end
	]]
end
addEvent("forum:theftpost", true)
addEventHandler("forum:theftpost", getRootElement(), theftPost)
