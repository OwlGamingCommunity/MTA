-- DISAPPEAR

function toggleInvisibility(thePlayer)
	if exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerScripter(thePlayer) then
		if getElementData(thePlayer, "supervising") then
			outputChatBox("Please disable /supervise first.", thePlayer, 255, 0, 0)
			return
		end
		local enabled = getElementData(thePlayer, "invisible")
		if (enabled == true) then
			setElementAlpha(thePlayer, 255)
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "reconx", false, false)
			outputChatBox("You are now visible.", thePlayer, 255, 0, 0)
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "invisible", false, false)
			exports.logs:dbLog(thePlayer, 4, thePlayer, "DISAPPEAR DISABLED")
		elseif (enabled == false or enabled == nil) then
			setElementAlpha(thePlayer, 0)
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "reconx", true, false)
			outputChatBox("You are now invisible.", thePlayer, 0, 255, 0)
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "invisible", true, false)
			exports.logs:dbLog(thePlayer, 4, thePlayer, "DISAPPEAR ENABLED")
		else
			outputChatBox("Please disable recon first.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("disappear", toggleInvisibility)


-- TOGGLE NAMETAG
function toggleMyNametag(thePlayer)
	local visible = getElementData(thePlayer, "reconx")
	local username = getElementData(thePlayer, "account:username")
	if exports.integration:isPlayerLeadAdmin(thePlayer) then
		if (visible == true) then
			setPlayerNametagShowing(thePlayer, false)
			--exports.anticheat:changeProtectedElementDataEx(thePlayer, "reconx", false, false)
			outputChatBox("Your nametag is now visible.", thePlayer, 255, 0, 0)
		elseif (visible == false or visible == nil) then
			setPlayerNametagShowing(thePlayer, false)
			--exports.anticheat:changeProtectedElementDataEx(thePlayer, "reconx", true, false)
			outputChatBox("Your nametag is now hidden.", thePlayer, 0, 255, 0)
		else
			outputChatBox("Please disable recon first.", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("togmytag", toggleMyNametag)

-- RP SUPERVISE
function roleplaySupervise(thePlayer)
	if exports.integration:isPlayerTrialAdmin(thePlayer) or exports.integration:isPlayerSupporter(thePlayer) then
		if exports.global:isStaffOnDuty(thePlayer) then
			if getElementData(thePlayer, "invisible") then
				outputChatBox("Please disable /disappear first.", thePlayer, 255, 0, 0)
				return
			end

			local enabled = getElementData(thePlayer, "supervising")
			if (enabled == true) then
				setElementAlpha(thePlayer, 255)
				outputChatBox("You are now no longer in supervisor state.", thePlayer, 255, 0, 0)
				exports.logs:dbLog(thePlayer, 4, thePlayer, "RP SUPERVISOR DISABLED")
				exports.global:sendWrnToStaff("[AdmCmd] "..getElementData(thePlayer, "account:username").." has disabled RP supervisor mode.")

				setElementData(thePlayer, "supervising", false)
			elseif (enabled == false or enabled == nil) then
				setElementAlpha(thePlayer, 100)
				outputChatBox("You are now in supervisor state.", thePlayer, 0, 255, 0)
				exports.logs:dbLog(thePlayer, 4, thePlayer, "RP SUPERVISOR ENABLED")
				exports.global:sendWrnToStaff("[AdmCmd] "..getElementData(thePlayer, "account:username").." has enabled RP supervisor mode.")

				setElementData(thePlayer, "supervising", true)
			else
				outputChatBox("Please disable recon first.", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("supervise", roleplaySupervise)

addEvent("recon:reattach", true)
addEventHandler("recon:reattach", resourceRoot, function(target, int, dim)
	setElementInterior(client, int)
	setElementDimension(client, dim)
	setCameraInterior(client, int)
	local x,y,z = getElementPosition(target)
	setElementPosition(client, x, y, z-5)
	attachElements(client, target, 0, 0, -5)
end)

-- MAXIME's reworks
function asyncReconActivate(cur)
	local target = exports.pool:getElement("player", cur.target)
	if not target then
		triggerClientEvent(source, "admin:recon", source)
		return
	end
	removePedFromVehicle(source)
	if exports.freecam:isEnabled(source) then
		triggerEvent("freecam:asyncDeactivateFreecam", source)
	end

	-- Set important element data
	setElementData(source, "reconx", target, true)
	setElementData(source, "recontp", true)

	setElementCollisionsEnabled ( source, false )
	triggerEvent('artifacts:removeAllOnPlayer', root, source)
	setElementAlpha(source, 0)
	setPedWeaponSlot(source, 0)

	local t_int = getElementInterior(target)
	local t_dim = getElementDimension(target)

	setElementDimension(source, t_dim)
	setElementInterior(source, t_int)
	setCameraInterior(source, t_int)

	local x1, y1, z1 = getElementPosition(target)
	setElementPosition(source, x1, y1, 0)

	setTimer(function(source, xl, yl, zl, target) setElementPosition(source, x1, y1, z1-5); 	attachElements(source, target, 0, 0, -5) end, 500, 1, source, xl, yl, zl, target)

	setCameraTarget(source,target)
	exports.logs:dbLog(source, 4, target, "RECON")
	local hiddenAdmin = getElementData(source, "hiddenadmin")
	if hiddenAdmin == 0 and not (exports.integration:isPlayerSeniorAdmin(source) and exports.integration:isPlayerTrialAdmin(target) and not exports.integration:isPlayerAdmin(target))  then
		local adminTitle = exports.global:getPlayerAdminTitle(source)
		exports.global:sendMessageToAdmins("AdmCmd: " .. tostring(adminTitle) .. " " .. getElementData(source, "account:username") .. " started reconning " .. getPlayerName(target):gsub("_", " ") .. " (" .. getElementData(target, "account:username") .. ").")
	elseif exports.integration:isPlayerSeniorAdmin(source) and exports.integration:isPlayerTrialAdmin(target) and not exports.integration:isPlayerAdmin(target) and hiddenAdmin == 0 then
		local adminTitle = exports.global:getPlayerAdminTitle(source)
		exports.global:sendMessageToSeniorAdmins("SeniorAdmCmd: " .. tostring(adminTitle) .. " " .. getElementData(source, "account:username") .. " started reconning " .. getElementData(target, "account:username") .. ".")
	end
end
addEvent("admin:recon:async:activate", true)
addEventHandler("admin:recon:async:activate", root, asyncReconActivate)

function asyncReconDeactivate(cur)
	if exports.freecam:isEnabled(source) then
		triggerEvent("freecam:asyncDeactivateFreecam", source)
	end
	setElementData(source, "reconx", false, true)
	removeElementData(source, "recontp")

	removePedFromVehicle(source)
	detachElements(source)

	setElementPosition(source, cur.x, cur.y, cur.z)
	setElementRotation(source, cur.rx, cur.ry, cur.rz)

	setElementDimension(source, cur.dim)
	setElementInterior(source, cur.int)
	setCameraInterior(source,cur.int)

	setCameraTarget(source, nil)
	setElementAlpha(source, 255)
	setElementCollisionsEnabled ( source, true )
end
addEvent("admin:recon:async:deactivate", true)
addEventHandler("admin:recon:async:deactivate", root, asyncReconDeactivate)


addEvent("admin:disabledisappear", true)
addEventHandler("admin:disabledisappear", root, function (thePlayer)
	exports.anticheat:changeProtectedElementDataEx(thePlayer, "reconx", false, false)
	exports.anticheat:changeProtectedElementDataEx(thePlayer, "invisible", false, false)		
end)