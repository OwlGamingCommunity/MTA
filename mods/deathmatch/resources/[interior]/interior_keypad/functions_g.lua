function getInteriorFromId(theID)
	if not theID or not tonumber(theID) then
		return false
	else
		theID =  tonumber(theID) 
		for key, theInterior in pairs(getElementsByType("interior")) do
			if getElementData(theInterior, "dbid") == theID then
				return theInterior
			end
		end
	end
	return false
end

function isPasscodeMatched(theInterior, raw)
	if not theInterior or not isElement(theInterior) or not getElementType(theInterior) == "interior" then
		return false
	end

	local encryptedPW = getElementData(theInterior, "keypad_lock_pw")
	if not encryptedPW then
		return false
	end

	return md5(raw) == encryptedPW
end

function encryptPW(raw)
	return md5(raw)
end

function findPadElementFromIntID(intId)
	local foundPads = {}
	if intId and tonumber(intId) then
		for key, thePad in pairs(getElementsByType("object", getResourceRootElement(getResourceFromName("item-world")))) do
			if getElementData(thePad, "itemID") == 169 and getElementData(thePad, "itemValue") == tonumber(intId) then
				table.insert(foundPads, thePad)
			end
		end
	end
	return foundPads
end
