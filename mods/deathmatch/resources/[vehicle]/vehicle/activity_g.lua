--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

function isActive(veh)
	local warning_last_login, warning_last_used = nil
	local job = getElementData(veh, "job") or 0
	local owner = getElementData(veh, "owner") or -1
	local faction = getElementData(veh, "faction") or -1
	local Impounded = getElementData(veh, "Impounded") or 0
	if job ~= 0 or owner <= 0 or faction ~= -1 or Impounded ~= 0 then
		return true
	elseif getVehicleType(veh) == "Trailer" then
		return true
	else
		local oneDay = 60*60*24
		local owner_last_login = getElementData(veh, "owner_last_login")
		if owner_last_login and tonumber(owner_last_login) then
			local owner_last_login_text, owner_last_login_sec = exports.datetime:formatTimeInterval(owner_last_login)
			if owner_last_login_sec > oneDay*30 then
				return false, "Inactive Vehicle | Owner is inactive ("..owner_last_login_text..")", owner_last_login_sec
			elseif owner_last_login_sec > (oneDay*30 - oneDay/2) then --12 hours before it becomes inactive
				warning_last_login = (oneDay*30)-owner_last_login_sec
			end
		end

		local dim = getElementDimension(veh)
		-- Allow players to have their vehicles currently outside, as long as their respawn position is in a interior(due to some issues with vehicles falling out of interiors and into dimension 0) //Chaos
		local parkDim = getElementData(veh, "dimension")
		if dim == 0 and tonumber(parkDim) == 0 then
			local lastused = getElementData(veh, "lastused")
			if lastused and tonumber(lastused) then
				local lastusedText, lastusedSeconds = exports.datetime:formatTimeInterval(lastused)
				if lastusedSeconds > oneDay*14 then
					return false, "Inactive Vehicle | Last used "..lastusedText.." while parking outdoors", lastusedSeconds
				elseif lastusedSeconds > (oneDay*14 - oneDay/2) then --12 hours before it becomes inactive
					warning_last_used = (oneDay*14)-lastusedSeconds
				end
			end
		end
	end
	return true, getMoreCriticalWarning(warning_last_used,warning_last_login)
end

function isProtected(veh)
	local job = getElementData(veh, "job") or 0
	local owner = getElementData(veh, "owner") or -1
	local faction = getElementData(veh, "faction") or -1
	if job ~= 0 or owner <= 0 or faction ~= -1 then
		return false
	end
	local protected_until = getElementData(veh, "protected_until") or -1
	local protectText, protectSeconds = exports.datetime:formatFutureTimeInterval(protected_until)
	return protectSeconds > 0, protectText, protectSeconds
end

function getMoreCriticalWarning(a, b)
	if not a then
		return b
	end
	if not b then
		return a
	end
	if a and b then
		return (a < b) and a or b
	end
	return nil
end
