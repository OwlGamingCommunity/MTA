--local vehicleTempPosList = {}

function restartSingleResource(thePlayer, commandName, resourceName, seconds)
	if (exports["integration"]:isPlayerScripter(thePlayer) or exports["integration"]:isPlayerAdmin(thePlayer)) then
		if not (resourceName) then
			outputChatBox("SYNTAX: /restartres [Resource Name] [Seconds delay]", thePlayer, 255, 194, 14)
		else
			local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
			local theResource = getResourceFromName(tostring(resourceName))
			local username = getElementData(thePlayer, "account:username")
			local adminTitle = exports.global:getPlayerFullIdentity(thePlayer, 2)
			if (theResource) then

				-- To limit /restartres for admin+ to 'artifacts' only.
				if (resourceName:lower() ~= "artifacts") and not exports["integration"]:isPlayerLeadAdmin(thePlayer) and not exports["integration"]:isPlayerScripter(thePlayer) then
					return false
				end
				if not seconds or not tonumber(seconds) or tonumber(seconds) < 1 then seconds = 1 else seconds = math.ceil(tonumber(seconds)) end
				local delayTime = 1000*seconds
				if resourceName:lower() == "elevator-system" then
					if (not getElementData(thePlayer, "resconfirmed") and not exports.integration:isPlayerScripter(thePlayer)) then
						outputChatBox("Are you sure you want to restart Elevator-system? It will be causing massive lag. Re-type it if you are sure.", thePlayer)
						setElementData(thePlayer, "resconfirmed", true)
						setTimer(function ()
								setElementData(thePlayer, "resconfirmed", false)
							end, 10000, 1)
						return false
					else
						--delayTime = 5*1000
						outputChatBox("* Elevators system is restarting in "..seconds.." seconds! *", root, 255, 0, 0)
						outputChatBox("* Your game may be frozen for a short moment, please standby.. *", root, 255, 0, 0)
					end

				elseif resourceName:lower() == "item-system" then
					if (not getElementData(thePlayer, "resconfirmed") and not exports.integration:isPlayerScripter(thePlayer)) then
						outputChatBox("Are you sure you want to restart Item-system? It will be causing massive lag. Re-type it if you are sure.", thePlayer)
						setElementData(thePlayer, "resconfirmed", true)
						setTimer(function ()
								setElementData(thePlayer, "resconfirmed", false)
							end, 10000, 1)
						return false
					else
						--delayTime = 5*1000
						outputChatBox("* Item system is restarting in ".. seconds .." seconds! *", root, 255, 0, 0)
						outputChatBox("* Your game may be frozen for a short moment. *", root, 255, 0, 0)
						outputChatBox("* It may take up to a minute before your inventory re-appears. *", root, 255, 0, 0)
					end

				elseif resourceName:lower() == "shop-system" then
					if (not getElementData(thePlayer, "resconfirmed") and not exports.integration:isPlayerScripter(thePlayer)) then
						outputChatBox("Are you sure you want to restart Shop-system? It will be causing massive lag. Re-type it if you are sure.", thePlayer)
						setElementData(thePlayer, "resconfirmed", true)
						setTimer(function ()
								setElementData(thePlayer, "resconfirmed", false)
							end, 10000, 1)
						return false
					else
						--delayTime = 10*1000
						outputChatBox("* Shop-system is restarting in "..seconds.." seconds! *", root, 255, 0, 0)
						outputChatBox("* There will be a short Network Trouble during the time, please standby.. *", root, 255, 0, 0)
					end
				elseif resourceName:lower() == "item-world" then
					if (not getElementData(thePlayer, "resconfirmed") and not exports.integration:isPlayerScripter(thePlayer)) then
						outputChatBox("Are you sure you want to restart Item-world? It will be causing massive lag. Re-type it if you are sure.", thePlayer)
						outputChatBox("MSG from Scripters: Please do not restart this unless you -know- you need to restart it.", thePlayer)
						setElementData(thePlayer, "resconfirmed", true)
						setTimer(function ()
								setElementData(thePlayer, "resconfirmed", false)
							end, 10000, 1)
						return false
					else
						--delayTime = 10*1000
						outputChatBox("* Item-world is restarting in "..seconds.." seconds! *", root, 255, 0, 0)
						outputChatBox("* There will be a short Network Trouble during the time, please standby.. *", root, 255, 0, 0)
					end
				end
				setTimer(function ()
					if getResourceState(theResource) == "running" then
						restartResource(theResource)
						outputChatBox("Resource " .. resourceName .. " was restarted.", thePlayer, 0, 255, 0)
						exports.global:sendWrnToStaff(adminTitle.." restarted the resource '" .. resourceName .. "'.", "SCRIPT", 255, 0, 0, true)
					elseif getResourceState(theResource) == "loaded" then
						startResource(theResource, true)
						outputChatBox("Resource " .. resourceName .. " was started.", thePlayer, 0, 255, 0)
						exports.global:sendWrnToStaff(adminTitle.." started the resource '" .. resourceName .. "'.", "SCRIPT", 255, 0, 0, true)
					elseif getResourceState(theResource) == "failed to load" then
						outputChatBox("Resource " .. resourceName .. " could not be loaded (" .. getResourceLoadFailureReason(theResource) .. ")", thePlayer, 255, 0, 0)
					else
						outputChatBox("Resource " .. resourceName .. " could not be started (" .. getResourceState(theResource) .. ")", thePlayer, 255, 0, 0)
					end
				end, delayTime, 1)
			else
				outputChatBox("Resource not found.", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("restartres", restartSingleResource)

function stopSingleResource(thePlayer, commandName, resourceName)
	if (exports["integration"]:isPlayerScripter(thePlayer) or exports.integration:isPlayerHeadAdmin(thePlayer)) then
		if not (resourceName) then
			outputChatBox("SYNTAX: /stopres [Resource Name]", thePlayer, 255, 194, 14)
		else
			local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
			local theResource = getResourceFromName(tostring(resourceName))
			local username = getElementData(thePlayer, "account:username")
			local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
			if (theResource) then
				if stopResource(theResource) then
					outputChatBox("Resource " .. resourceName .. " was stopped.", thePlayer, 0, 255, 0)
					if hiddenAdmin == 0 then
						--exports.global:sendMessageToAdmins("AdmScript: " .. getPlayerName(thePlayer) .. " stopped the resource '" .. resourceName .. "'.")
						exports.global:sendMessageToAdmins("AdmScript: " .. tostring(adminTitle) .. " " .. username .. " stopped the resource '" .. resourceName .. "'.")
					else
						exports.global:sendMessageToAdmins("AdmScript: A hidden admin stopped the resource '" .. resourceName .. "'.")
					end
				else
					outputChatBox("Couldn't stop Resource " .. resourceName .. ".", thePlayer, 255, 0, 0)
				end
			else
				outputChatBox("Resource not found.", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("stopres", stopSingleResource)

function startSingleResource(thePlayer, commandName, resourceName)
	if (exports["integration"]:isPlayerScripter(thePlayer) or exports.integration:isPlayerHeadAdmin(thePlayer)) then
		if not (resourceName) then
			outputChatBox("SYNTAX: /startres [Resource Name]", thePlayer, 255, 194, 14)
		else
			local theResource = getResourceFromName(tostring(resourceName))
			local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
			local username = getElementData(thePlayer, "account:username")
			local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
			if (theResource) then
				if getResourceState(theResource) == "running" then
					outputChatBox("Resource " .. resourceName .. " is already started.", thePlayer, 0, 255, 0)
				elseif getResourceState(theResource) == "loaded" then
					startResource(theResource, true)
					outputChatBox("Resource " .. resourceName .. " was started.", thePlayer, 0, 255, 0)
					if hiddenAdmin == 0 then
						--exports.global:sendMessageToAdmins("AdmScript: " .. getPlayerName(thePlayer) .. " started the resource '" .. resourceName .. "'.")
						exports.global:sendMessageToAdmins("AdmScript: " .. tostring(adminTitle) .. " " .. username .. " started the resource '" .. resourceName .. "'.")
					else
						exports.global:sendMessageToAdmins("AdmScript: A hidden admin started the resource '" .. resourceName .. "'.")
					end
				elseif getResourceState(theResource) == "failed to load" then
					outputChatBox("Resource " .. resourceName .. " could not be loaded (" .. getResourceLoadFailureReason(theResource) .. ")", thePlayer, 255, 0, 0)
				else
					outputChatBox("Resource " .. resourceName .. " could not be started (" .. getResourceState(theResource) .. ")", thePlayer, 255, 0, 0)
				end
			else
				outputChatBox("Resource not found.", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("startres", startSingleResource)

function getResState(thePlayer, commandName, resourceName)
	if (exports["integration"]:isPlayerScripter(thePlayer) or exports.integration:isPlayerHeadAdmin(thePlayer)) then
		if not (resourceName) then
			outputChatBox("SYNTAX: /resstate [Resource Name]", thePlayer, 255, 194, 14)
		else
			local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
			local theResource = getResourceFromName(tostring(resourceName))
			local username = getElementData(thePlayer, "account:username")
			local adminTitle = exports.global:getPlayerAdminTitle(thePlayer)
			if (theResource) then
				local resState = getResourceState(theResource)
				local statusColour = {
					["loaded"] = "#FFFFFF",
					["running"] = "#00FF00",
					["starting"] = "#FFF700",
					["stopping"] = "#FFF700",
					["failed to load"] = "#FF0000"
				}

				if resState then
					outputChatBox("#E7D9B0Resource " .. resourceName .. " is "..statusColour[tostring(resState)]..tostring(resState).."#E7D9B0.", thePlayer, 231, 217, 176, true)
					if(resState == "failed to load") then
						local reason = getResourceLoadFailureReason(theResource)
						if reason then
							outputChatBox("  "..tostring(reason),thePlayer)
						end
					end
				end
			else
				outputChatBox("Resource not found.", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("resstate", getResState)

function restartGateKeepers(thePlayer, commandName)
	if exports.integration:isPlayerTrialAdmin(thePlayer) then
		local theResource = getResourceFromName("gatekeepers-system")
		if theResource then
			local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
			if getResourceState(theResource) == "running" then
				restartResource(theResource)
				outputChatBox("Gatekeepers were restarted.", thePlayer, 0, 255, 0)
				if  hiddenAdmin == 0 then
					exports.global:sendMessageToAdmins("AdmScript: " .. getPlayerName(thePlayer) .. " restarted the gatekeepers.")
				else
					exports.global:sendMessageToAdmins("AdmScript: A hidden admin restarted the gatekeepers.")
				end
				exports.logs:dbLog(thePlayer, 4, thePlayer, "RESETSTEVIE")
			elseif getResourceState(theResource) == "loaded" then
				startResource(theResource)
				outputChatBox("Gatekeepers were started", thePlayer, 0, 255, 0)
				if  hiddenAdmin == 0 then
					exports.global:sendMessageToAdmins("AdmScript: " .. getPlayerName(thePlayer) .. " started the gatekeepers.")
				else
					exports.global:sendMessageToAdmins("AdmScript: A hidden admin started the gatekeepers.")
				end
				exports.logs:dbLog(thePlayer, 4, thePlayer, "RESETSTEVIE")
			elseif getResourceState(theResource) == "failed to load" then
				outputChatBox("Gatekeepers could not be loaded (" .. getResourceLoadFailureReason(theResource) .. ")", thePlayer, 255, 0, 0)
			end
		end
	end
end
addCommandHandler("restartgatekeepers", restartGateKeepers)


-- DISABLED, Using /refreshcarshops now. Less intensive on the server.
function restartCarShop(thePlayer, commandName)
	if exports.integration:isPlayerAdmin(thePlayer) then
		local theResource = getResourceFromName("carshop-system")
		if theResource then
			local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
			if getResourceState(theResource) == "running" then
				restartResource(theResource)
				outputChatBox("Carshops were restarted.", thePlayer, 0, 255, 0)
				if hiddenAdmin == 0 then
					exports.global:sendMessageToAdmins("AdmScript: " .. getPlayerName(thePlayer) .. " restarted the carshops.")
				else
					exports.global:sendMessageToAdmins("AdmScript: A hidden admin restarted the carshops.")
				end
				exports.logs:dbLog(thePlayer, 4, thePlayer, "RESETCARSHOP")
			elseif getResourceState(theResource) == "loaded" then
				startResource(theResource)
				outputChatBox("Carshops were started", thePlayer, 0, 255, 0)
				if hiddenAdmin == 0 then
					exports.global:sendMessageToAdmins("AdmScript: " .. getPlayerName(thePlayer) .. " started the carshops.")
				else
					exports.global:sendMessageToAdmins("AdmScript: A hidden admin started the carshops.")
				end
				exports.logs:dbLog(thePlayer, 4, thePlayer, "RESETCARSHOP")
			elseif getResourceState(theResource) == "failed to load" then
				outputChatBox("Carshop's could not be loaded (" .. getResourceLoadFailureReason(theResource) .. ")", thePlayer, 255, 0, 0)
			end
		end
	end
end
--addCommandHandler("restartcarshops", restartCarShop)

-- ACL
function reloadACL(thePlayer)
	if (exports["integration"]:isPlayerScripter(thePlayer) or exports.integration:isPlayerTrialAdmin(thePlayer)) then
		local acl = aclReload()
		local hiddenAdmin = getElementData(thePlayer, "hiddenadmin")
		if acl then
			outputChatBox("The ACL has been succefully reloaded!", thePlayer, 0, 255, 0)
			if hiddenAdmin == 0 then
				exports.global:sendMessageToAdmins("AdmACL: " .. getPlayerName(thePlayer):gsub("_"," ") .. " has reloaded the ACL settings!")
			else
				exports.global:sendMessageToAdmins("AdmACL: A hidden admin has reloaded the ACL settings!")
			end
		else
			outputChatBox("Failed to reload the ACL!", thePlayer, 255, 0, 0)
		end
	end
end
addCommandHandler("reloadacl", reloadACL, false, false)

function getVehTempPosList()
	--[[return vehicleTempPosList]]
end
