--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local cmds_cache = nil

local function reCacheCmds()
	local qh = dbQuery( exports.mysql:getConn('mta'), "SELECT * FROM `commands` ORDER BY `command` " )
	local res, nums, id = dbPoll( qh, 10000 )
	if res then 
		cmds_cache = res
		return cmds_cache
	else
		dbFree( qh )
	end
end

local function updateCmdCache( action, cmd_ )
	cmds_cache = cmds_cache or {}
	if action == 'add' then
		table.insert( cmds_cache, cmd_ )
		return true
	else
		for i, cmd in pairs( cmds_cache ) do
			if tonumber(cmd_[1]) == tonumber(cmd.id) then
				if action == 'delete' then
					table.remove( cmds_cache, i )
				elseif action == 'update' then
					cmds_cache[i].category = cmd_[2]
					cmds_cache[i].permission = cmd_[3]
					cmds_cache[i].command = cmd_[4]
					
					cmds_cache[i].hotkey = cmd_[5]
					cmds_cache[i].explanation = cmd_[6]
				end
				return true
			end
		end
	end
end

function sendCmdsHelpToClient( player )
	local target = player or source or root
	triggerLatentClientEvent( target, "getCmdsHelpFromServer", target, cmds_cache or reCacheCmds() or {} )
end
addEvent("sendCmdsHelpToClient", true)
addEventHandler("sendCmdsHelpToClient", root, sendCmdsHelpToClient)

function saveCommand( cmd )
	if not exports.integration:isPlayerTrialAdmin(client) then
		return
	end

	if cmd[1] then 
		dbExec( exports.mysql:getConn('mta'), "UPDATE commands SET category=?, permission=?, command=?, hotkey=?, explanation=? WHERE id=? ", cmd[2], cmd[3], cmd[4], cmd[5], cmd[6], cmd[1] )
		updateCmdCache( 'update', cmd )
		sendCmdsHelpToClient() -- send to all players.
	else
		local qh = dbQuery( exports.mysql:getConn('mta'), "INSERT INTO commands SET category=?, permission=?, command=?, hotkey=?, explanation=? ", cmd[2], cmd[3], cmd[4], cmd[5], cmd[6] )
		local res, nums, id = dbPoll( qh, 10000 )
		if res and nums > 0 then
			updateCmdCache( 'add', { id = id, category=cmd[2], permission=cmd[3], command=cmd[4], hotkey=cmd[5], explanation=cmd[6] } )
			sendCmdsHelpToClient() -- send to all players.
		end
	end
end
addEvent("saveCommand", true)
addEventHandler("saveCommand", root, saveCommand)

function deleteCommand(id)
	if not exports.integration:isPlayerTrialAdmin(client) then
		return
	end

	dbExec( exports.mysql:getConn('mta'), "DELETE FROM commands WHERE id=? ", id )
	updateCmdCache( 'delete', { id } )
	sendCmdsHelpToClient() -- send to all players.
end
addEvent("deleteCommand", true)
addEventHandler("deleteCommand", root, deleteCommand)