-- Chooseable phone numbers
function checkValidNumber(number, specialPhone)
	if type(number) ~= "number" then
		return false, "Invalid number"
	end
	
	if number ~= math.ceil(number) then
		return false, "Invalid number"
	end
	
	if specialPhone then
		if number < 10000 then
			return false, "Number is too short"
		end
	else
		if number < 100000 then
			return false, "Number is too short"
		end
	end
	
	if number > 999999999 then
		return false, "Number is too long"
	end
	
	if not specialPhone then
		-- enforce at least two different digits
		local str = tostring(number)
		local first = str:sub(1,1)
		for i = 2, #str do
			if str:sub(i, i) ~= first then
				return true
			end
		end
		return false, "Number needs two different digits"
	end
	
	return true
end


function checkValidUsername(username)
	if not username or username == "" then
		return false, "Please input new username."
	elseif string.len(username) < 3 then
		return false, "Username must be 3 characters or longer."
	elseif string.match(username,"%W") then
		return false, "\"!@#$\"%'^&*()\" are not allowed."
	end
	return true, "Looking good!"
end

function hasPlayerPerk(targetPlayer, perkID)
	if not isElement( targetPlayer ) then
		return false
	end
	
	if not tonumber(perkID) then
		return false
	end
	
	perkID = tonumber(perkID)
	
	if perkID == 1 and exports.global:isStaffOnDuty(targetPlayer) then
		return true, getElementData(targetPlayer, "pmblocked")
	end
	
	local perkTable = getElementData(targetPlayer, "donation-system:perks")
	if not (perkTable) then
		return false
	end
	
	if (perkTable[perkID] == nil) then
		return false
	end

	
	return true, perkTable[perkID]
end


