--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]
	
function addInteriorLogs(intID, action, actor, clearPreviousLogs)
	if intID and action then
		if clearPreviousLogs then
			dbExec( exports.mysql:getConn('mta'), "DELETE FROM `interior_logs` WHERE `intID`=?", intID)
		end

		local adminID = nil
		if actor and isElement(actor) and getElementType(actor) == "player" then
		 	adminID = getElementData(actor, "account:id") 
		elseif tonumber(actor) then
			adminID = tonumber(actor)
		end
		
		return dbExec( exports.mysql:getConn('mta'), "INSERT INTO `interior_logs` SET `intID`=?, `action`=? "..(adminID and (", `actor`="..adminID) or ""), intID, action )
	else
		outputDebugString("[INTERIOR MANAGER] Lack of agruments #1 or #2 for the function addInteriorLogs().")
		return false
	end
end