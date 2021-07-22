--MAXIME
function updatePerkValue (targetPlayer, perkID, newValue)
	newValue = tostring(newValue)
	if not tonumber(perkID) then
		return false
	end
	
	perkID = tonumber(perkID)
	
	if triggerServerEvent("donators:updatePerkValue", localPlayer, targetPlayer, perkID, newValue) then
		return true
	else
		return false
	end
end