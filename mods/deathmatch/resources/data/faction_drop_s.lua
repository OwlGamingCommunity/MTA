--MAXIME
local logs = nil
function savePurchaseLogs(logs1) 
	if logs1 and type(logs1) == "table" then
		logs = logs1 
		outputDebugString("[DATA] Saved Faction Drop NPC logs records.")
	end
end

function loadPurchaseLogs() 
	if logs and type(logs) == "table" then
		outputDebugString("[DATA] Loaded Faction Drop NPC logs records.")
		return logs
	else
		return {}
	end
end