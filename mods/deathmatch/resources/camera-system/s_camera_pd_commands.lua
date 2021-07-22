function toggleTrafficCam(thePlayer, commandName)
	local isLoggedIn = getElementData(thePlayer, "loggedin") or 0
	if (isLoggedIn == 1) then		
		-- factiontype == law
		if exports.factions:isInFactionType(thePlayer, 2) then
			local resultColshape
			local results = 0
			
			-- get current colshape
			for k, theColshape in ipairs(exports.pool:getPoolElementsByType("colshape")) do
				local isSpeedcam = getElementData(theColshape, "speedcam")
				if (isSpeedcam) then
					if (isElementWithinColShape(thePlayer, theColshape)) then
						resultColshape = theColshape
						results = results + 1
					end
				end
			end
			if (results == 0) then
				outputChatBox("The system returns an error: No nearby speedcam found.", thePlayer,255,0,0)
			elseif (results > 1) then
				outputChatBox("The system returns an error: Too many speedcams near.", thePlayer, 255,0,0)
			else
				local gender = getElementData(thePlayer, "gender")
				local genderm = "his"
				if (gender == 1) then
					genderm = "her"
				end
			
				exports.global:sendLocalText(thePlayer, " *"..getPlayerName(thePlayer):gsub("_", " ") .." taps a few keys on " .. genderm .. " mobile data computer.", 255, 51, 102)
				local result = toggleTrafficCam(resultColshape)
				if (result == 0) then
					outputChatBox("Error SPDCM03, please report at the mantis.", thePlayer, 255,0,0)
				elseif (result == 1) then
					outputChatBox("The speedcam has been turned off.", thePlayer, 0,255,0)
				else
					outputChatBox("The speedcam has been turned on.", thePlayer, 0,255,0)
				end
			end
		end
	end
end
addCommandHandler("togglespeedcam", toggleTrafficCam)