--MAXIME / 2015.01.07
function isActive(interiorElement)
	local warning_last_login, warning_last_used = nil
	local interiorStatus = getElementData(interiorElement, "status")
	local interiorType = interiorStatus.type or 2
	local interiorOwner = interiorStatus.owner or 0
	local interiorFaction = interiorStatus.faction or 0
	local interiorDisabled = interiorStatus.disabled or false
	if interiorDisabled or interiorType == 2 or interiorFaction ~= 0 or interiorOwner < 1 then
		return true
	else
		local oneDay = 60*60*24
		local owner_last_login = getElementData(interiorElement, "owner_last_login")

		if owner_last_login and tonumber(owner_last_login) then
			local owner_last_login_text, owner_last_login_sec = exports.datetime:formatTimeInterval(owner_last_login)
			if owner_last_login_sec > oneDay*30 then
				return false, "Inactive interior | Owner is inactive ("..owner_last_login_text..")", owner_last_login_sec
			elseif owner_last_login_sec > (oneDay*30 - oneDay/2) then --12 hours before it becomes inactive
				warning_last_login = (oneDay*30)-owner_last_login_sec
			end
		end
		local lastused = getElementData(interiorElement, "lastused")
		if lastused and tonumber(lastused) then
			local lastusedText, lastusedSeconds = exports.datetime:formatTimeInterval(lastused)
			if lastusedSeconds > oneDay*14 then
				return false, "Inactive interior | Last used "..lastusedText, lastusedSeconds
			elseif lastusedSeconds > (oneDay*14 - oneDay/2) then --12 hours before it becomes inactive
				warning_last_used = (oneDay*14)-lastusedSeconds
			end
		end
	end

	return true, getMoreCriticalWarning(warning_last_used,warning_last_login)
end

function isProtected(interiorElement)
	local interiorStatus = getElementData(interiorElement, "status")
	local interiorType = interiorStatus.type or 2
	local interiorOwner = interiorStatus.owner or 0
	local interiorFaction = interiorStatus.faction or 0
	if interiorType == 2 or interiorFaction > 0  or interiorOwner < 1 then
		return false
	end
	local protected_until = getElementData(interiorElement, "protected_until") or -1
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
