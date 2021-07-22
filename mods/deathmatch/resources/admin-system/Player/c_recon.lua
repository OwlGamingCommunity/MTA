addEventHandler("onClientChangeChar", getRootElement(), function ()
		local enabled = getElementData(localPlayer, "supervising")
		if (enabled == true) then
			setElementData(localPlayer, "supervising", false)
		end

		triggerServerEvent("admin:disabledisappear", root, localPlayer)
 end)

--Reworked by Chaos
-- RECON
local reconTarget = nil
local reconTargets = {}
local pointer = 0

local function addToReconTable(id)
	for i, existingId in pairs(reconTargets) do
		if existingId == id then
			return false
		end
	end
	table.insert(reconTargets, id)
	return true
end

function toggleRecon(state, targetPlayer)
	if state then
		local cur = exports.data:load("reconCurpos")
		if not cur then
			cur = {}
			cur.x, cur.y, cur.z = getElementPosition(localPlayer)
			cur.rx, cur.ry, cur.rz = getElementRotation(localPlayer)
			cur.dim = getElementDimension(localPlayer)
			cur.int = getElementInterior(localPlayer)
		end

		cur.target = getElementData(targetPlayer, "playerid")
		reconTarget = targetPlayer
		exports.data:save(cur, "reconCurpos")
		return triggerServerEvent("admin:recon:async:activate", localPlayer, cur)
	else
		local cur = exports.data:load("reconCurpos")
		if cur then
			setElementPosition(localPlayer, cur.x, cur.y, cur.z)
			setElementRotation(localPlayer, cur.rx, cur.ry, cur.rz)

			setElementDimension(localPlayer, cur.dim)
			setElementInterior(localPlayer, cur.int)
			setCameraInterior(cur.int)

			setCameraTarget(localPlayer, nil)
			setElementAlpha(localPlayer, 255)
			setElementCollisionsEnabled ( localPlayer, true )

			exports.data:save(nil, "reconCurpos")
			reconTarget = nil
			return triggerServerEvent("admin:recon:async:deactivate", localPlayer, cur)
		end
	end
end

function reconPlayer(commandName, targetPlayer)
	if source then localPlayer = source end
	if getElementData(localPlayer, "loggedin") == 1 and (exports.integration:isPlayerTrialAdmin(localPlayer)) then
		local reconx = getElementData(localPlayer, "reconx")
		if not (targetPlayer) then
			if not reconx then
				return outputChatBox("SYNTAX: /" .. commandName .. " [Player Partial Nick]", 255, 194, 14)
			end
			if toggleRecon(false) then
				reconTargets = {}
				pointer = 0
				outputChatBox("Recon turned off.", 0, 255, 0)
			end
		else
			local targetPlayer, targetPlayerName = exports.global:findPlayerByPartialNick(localPlayer, targetPlayer)
			if not targetPlayer then
				return outputChatBox("Player not found.", 255, 194, 14)
			end

			if getElementData(targetPlayer, "loggedin") ~= 1 then
				return outputChatBox("Player is not logged in.", 255, 0, 0)
			end

			if targetPlayer == localPlayer then
				return outputChatBox("You can not recon yourself.", 255,0,0)
			end

			if exports.freecam:isEnabled (localPlayer) then
				exports.freecam:toggleFreecam("dropme")
			end

			local newtarget = getElementData(targetPlayer, "reconx")
			if isElement(newtarget) then
				targetPlayer = newtarget
				targetPlayerName = getPlayerName(targetPlayer)
				outputChatBox("The person you tried to recon is currently reconning "..targetPlayerName..", your recon request has been transferred.", 255, 194, 14)
			end

			if toggleRecon(true, targetPlayer) then
				outputChatBox("Now reconning " .. targetPlayerName .. ".", 0, 255, 0)
				if addToReconTable(getElementData(targetPlayer, "playerid")) then
					pointer = #reconTargets
				end
			end
		end
	end
end
addEvent("admin:recon", true)
addEventHandler("admin:recon", root, reconPlayer)
addCommandHandler("recon", reconPlayer)

addEvent("recon:goto", true)
addEventHandler("recon:goto", root, function(x, y, z, interior, dimension, r)
	cur = {}
	cur.x, cur.y, cur.z = x, y, z
	cur.rx, cur.ry, cur.rz = 0, 0, r
	cur.dim = dimension
	cur.int = interior
	exports.data:save(cur, "reconCurpos")
	triggerEvent("admin:recon", localPlayer)
end)

addEventHandler ( "onClientElementDataChange", root,
function ( dataName )
	if getElementType ( source ) == "player" and dataName == "reconx" and source == getLocalPlayer() then
		if getElementData(source, "reconx") and not getElementData(source, "recon:whereToDisplayY") then -- New recon target and not already reconning
			addEventHandler("onClientRender", root, displayReconInfo)
		elseif not getElementData(source, "reconx") then
			setElementData(localPlayer, "recon:whereToDisplayY", nil, false)
			removeEventHandler("onClientRender", root, displayReconInfo)
		end
	end
end )

local function tableToString(table)
	local text = ""
	for i, id in ipairs(table) do
		text = text..id..", "
	end
	return #text>0 and string.sub(text, 1, #text-2) or "None"
end

function getTarget(order)
	if #reconTargets < 2 then
		return false, "Please /recon more players to be able to swap between them."
	end
	if order == "arrow_r" then
		pointer = pointer + 1
		if not reconTargets[pointer] then
			pointer = 1
			local target = exports.global:findPlayerByPartialNick(localPlayer, reconTargets[pointer])
			if not target then
				table.remove(reconTargets, pointer)
				return false, "This player has just logged out."
			else
				return reconTargets[pointer]
			end
		else
			local target = exports.global:findPlayerByPartialNick(localPlayer, reconTargets[pointer])
			if not target then
				table.remove(reconTargets, pointer)
				return false, "This player has just logged out."
			else
				return reconTargets[pointer]
			end
		end
	else
		pointer = pointer - 1
		if not reconTargets[pointer] then
			pointer = #reconTargets
			local target = exports.global:findPlayerByPartialNick(localPlayer, reconTargets[pointer])
			if not target then
				table.remove(reconTargets, pointer)
				return false, "This player has just logged out."
			else
				return reconTargets[pointer]
			end
		else
			local target = exports.global:findPlayerByPartialNick(localPlayer, reconTargets[pointer])
			if not target then
				table.remove(reconTargets, pointer)
				return false, "This player has just logged out."
			else
				return reconTargets[pointer]
			end
		end
	end
end

local sw, sh = guiGetScreenSize()
function displayReconInfo()
	if not exports.hud:isActive() then
		return
	end

	if not reconTarget or not isElement(reconTarget) or getElementData(reconTarget, "loggedin") ~= 1 then
		if #reconTargets >= 1 then
			local target, reason = getTarget("arrow_r")
			if target then
				triggerEvent("admin:recon", localPlayer, nil, target)
			end
		else
			setElementData(localPlayer, "recon:whereToDisplayY", nil, false)
			toggleRecon(false)
			return removeEventHandler("onClientRender", root, displayReconInfo)
		end
	end

	local w, h = 760, 105
	local x, y = (sw-w)/2, sh-h-30
	setElementData(localPlayer, "recon:whereToDisplayY", y, false)
    dxDrawRectangle(x, y, w, h, tocolor(0, 0, 0, 100), true)
    local ox, oy = 507, 396
	local xo, yo = x-ox, y-oy
	local text = ""
    dxDrawText("HP: "..math.floor( getElementHealth( reconTarget )), 517+xo, 423+yo, 706+xo, 440+yo, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, true, false, false)
    dxDrawText("Target: "..exports.global:getPlayerFullIdentity(reconTarget,3,true), 517+xo, 406+yo, 887+xo, 423+yo, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, true, false, false)
    local weapon = getPedWeapon( reconTarget )
	if weapon then
		weapon = getWeaponNameFromID( weapon )
	else
		weapon = "N/A"
	end
    dxDrawText("Weapon: "..weapon, 517+xo, 440+yo, 706+xo, 457+yo, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, true, false, false)
    dxDrawText("Armour: "..math.floor( getPedArmor( reconTarget ) ), 706+xo, 423+yo, 887+xo, 440+yo, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, true, false, false)
    dxDrawText("Skin: "..getElementModel( reconTarget ), 706+xo, 440+yo, 887+xo, 457+yo, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, true, false, false)
    dxDrawText("Money: $"..exports.global:formatMoney(getElementData(reconTarget, "money")), 517+xo, 457+yo, 706+xo, 474+yo, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, true, false, false)
    dxDrawText("Bank: $"..exports.global:formatMoney(getElementData(reconTarget, "bankmoney")), 706+xo, 457+yo, 887+xo, 474+yo, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, true, false, false)
    local veh = "Press Arrow Left/Right to swap between reconning targets ("..tableToString(reconTargets)..")"
    local vehicle = getPedOccupiedVehicle( reconTarget )
    if vehicle then
    	veh = "Vehicle: " .. exports.global:getVehicleName( vehicle ) .. " (" ..getVehicleName( vehicle ).." - ID #"..getElementData( vehicle, "dbid" ) .. " - HP: "..math.floor( getElementHealth( vehicle ))..")"
    end
    dxDrawText(veh, 517+xo, 474+yo, 1257+xo, 491+yo, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, true, false, false)
    text = ""
	local fid = getElementData(reconTarget, "faction")
	for k,v in pairs(fid) do
		local rank = v.rank
		local theFaction = exports.factions:getFactionFromID(k)
		if rank and theFaction then
			text = text .. k
			local ranks = getElementData(theFaction, "ranks")
			if ranks then
				local fRank = ranks[rank] and ranks[rank] or false
				if fRank then
					text = text.." ("..fRank.."), "
				end
			end
		end
	end
	local loc = getZoneName(getElementPosition(reconTarget))
	local int = getElementInterior(reconTarget)
	local dim = getElementDimension(reconTarget)

	-- Follow the recon target through interiors
	if dim ~= getElementDimension(localPlayer) then
		triggerServerEvent("recon:reattach", resourceRoot, reconTarget, int, dim)
	end

	if dim > 0 then
		loc = "Inside interior ID #"..dim
	end
    dxDrawText("Faction: "..text, 887+xo, 406+yo, 1257+xo, 423+yo, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, true, true, false, false)
    dxDrawText("Location: "..loc, 1076+xo, 440+yo, 1257+xo, 440+yo, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, true, false, false)
    dxDrawText("Interior: "..int, 887+xo, 457+yo, 1076+xo, 457+yo, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, true, false, false)
    dxDrawText("Dimension: "..dim, 1076+xo, 457+yo, 1257+xo, 457+yo, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, true, false, false)
    local hoursplayed = getElementData(reconTarget, "hoursplayed")
    hoursplayed = tonumber(hoursplayed) or "Unknown"
    dxDrawText("Hoursplayed: "..hoursplayed, 887+xo, 474+yo, 1076+xo, 474+yo, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, true, false, false)
    dxDrawText("Ping: "..getPlayerPing(reconTarget), 1076+xo, 474+yo, 1257+xo, 474+yo, tocolor(255, 255, 255, 255), 1.00, "default", "left", "top", false, false, true, false, false)
end

addEventHandler( "onClientKey", root, function(button,press)
	if getElementData(localPlayer, "reconx") and press then
	    if button == "arrow_l" or button == "arrow_r" then
	    	local target, reason = getTarget(button)
	    	if target then
	    		triggerEvent("admin:recon", localPlayer, nil, target)
	    	else
	    		outputChatBox(reason, 255,0,0)
	    	end
	    end
	end
end )

addEventHandler("onClientPlayerDamage", localPlayer, function()
	if getElementData(localPlayer, "reconx") then
		cancelEvent()
	end
end, false)