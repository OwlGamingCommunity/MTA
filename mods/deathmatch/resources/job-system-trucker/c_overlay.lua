--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

local width, height = 246,105
local sx, sy = guiGetScreenSize()
local localPlayer = getLocalPlayer()

-- dx stuff
local jobName = ""
local jobLevel = ""
local jobProgress = ""
local jobCurrentProgress = ""
local loadedSupplies = ""
local truckCap = ""

local nextLocation = ""
local nextDropStopRequires = ""
local r,b,g = 255,255,255
local r2, b2, g2 = 0, 255, 0
local timeoutClock = 0
local showTimeoutClock = false
timerCountDown = nil
local show = false
local display_distance = nil

function getJobTitleFromID(jobID)
	return exports["job-system"]:getJobTitleFromID(jobID)
end

-- update the labels
local function updateGUI(data)
	if show then	
		local job = getElementData(localPlayer, "job" ) or 0
		jobName = ("                    "..getJobTitleFromID(job)) or ""
		local veh = getPedOccupiedVehicle(localPlayer) or false
		local jobVeh = 0
		
		if veh then
			jobVeh = getElementData(veh, "job" ) or 0
		end

		if job == 1 and jobVeh == 1 then -- RS Haul
			wipeAdditionalInfo()
			local tempJobLevel = getElementData(localPlayer, "jobLevel") or 0
			local tempProgress = getElementData(localPlayer, "jobProgress" ) or 0
			local truckrunsTilNextLevel = level[tempJobLevel] or false
			local tempTruckRuns = getElementData(localPlayer, "job-system-trucker:truckruns" ) or 0

			jobLevel = "Certificate: Driver Level "..tempJobLevel
			if truckrunsTilNextLevel then
				jobProgress = "Progress: "..tempProgress.."/"..truckrunsTilNextLevel.." ("..math.floor(tempProgress/truckrunsTilNextLevel*100).."%)"
			else
				jobProgress = "Progress: "..tempProgress.." (You mastered this job)"
			end
			jobCurrentProgress = "Trucking runs: "..tempTruckRuns
			
			if veh and jobVeh == 1 then
				height = 175
				local model = getElementModel(veh)
				local manualSupplies = exports['item-system']:getCarriedWeight(veh, 121)
				local tempTruckCap = truckerJobVehicleInfo[model][2]
				truckCap = "Truck Capacity: "..getVehicleNameFromModel(model).." - "..exports.global:formatWeight(tempTruckCap)
				local tempLoadedSupplies = data and data.carried or manualSupplies
				loadedSupplies = "Loaded Supplies: "..exports.global:formatWeight(tempLoadedSupplies).." ("..math.floor(tempLoadedSupplies/tempTruckCap*100).."%)"
				local currentRoute = getElementData(localPlayer, "job-system-trucker:currentRoute") or false
				if currentRoute then
					height = 175
					nextLocation = "Target: "..currentRoute[6] or "Unknown"
					if currentRoute[4] then
						local requiredSupplies = currentRoute[4]
						if type(currentRoute[4]) == 'table' then
							requiredSupplies = 50
						end
						if tonumber(requiredSupplies) >= tempLoadedSupplies then
							nextDropStopRequires = "Requiring Supplies: "..exports.global:formatWeight(requiredSupplies).." - NOT ENOUGH"
							display_distance = currentRoute[9]
							r,b,g = 255, 0, 0
						else
							nextDropStopRequires = "Requiring Supplies: "..exports.global:formatWeight(requiredSupplies).." - ENOUGH"
							display_distance = currentRoute[9]
							r,b,g = 0, 255, 0
						end
					else
						nextDropStopRequires = ""
						display_distance = nil
						r,b,g = 255, 255, 255
					end
				else
					height = 130
					nextDropStopRequires = ""
					display_distance = nil
					r,b,g = 255, 255,255
				end
				showTimeoutClock = true
			else
				wipeAdditionalInfo()
			end
		elseif job == 2 and jobVeh == 2 then -- Taxi
			wipeAdditionalInfo()
			local tempJobLevel = getElementData(localPlayer, "jobLevel") or 0
			local tempProgress = getElementData(localPlayer, "jobProgress" ) or 0
			--local truckrunsTilNextLevel = level[tempJobLevel] or false
			local tempTruckRuns = getElementData(localPlayer, "job-system-trucker:truckruns" ) or 0

			jobLevel = "Certificate: Driver Level "..tempJobLevel
			if truckrunsTilNextLevel then
				jobProgress = "Progress: "..tempProgress.."/"..truckrunsTilNextLevel.." ("..math.floor(tempProgress/truckrunsTilNextLevel*100).."%)"
			else
				jobProgress = "Progress: "..tempProgress.." (You mastered this job)"
			end
			jobCurrentProgress = "Served Fares: "..tempTruckRuns
		elseif job == 3 and jobVeh == 3 then -- Bus Driver
			wipeAdditionalInfo()
			local tempJobLevel = getElementData(localPlayer, "jobLevel") or 0
			local tempProgress = getElementData(localPlayer, "jobProgress" ) or 0
			--local truckrunsTilNextLevel = level[tempJobLevel] or false
			local tempTruckRuns = getElementData(localPlayer, "job-system-trucker:truckruns" ) or 0

			jobLevel = "Certificate: Driver Level "..tempJobLevel
			if truckrunsTilNextLevel then
				jobProgress = "Progress: "..tempProgress.."/"..truckrunsTilNextLevel.." ("..math.floor(tempProgress/truckrunsTilNextLevel*100).."%)"
			else
				jobProgress = "Progress: "..tempProgress.." (You mastered this job)"
			end
			jobCurrentProgress = "Served Fares: "..tempTruckRuns
		elseif job == 4 and jobVeh == 4 then -- Citi Maintenance
			wipeAdditionalInfo()
			local tempJobLevel = getElementData(localPlayer, "jobLevel") or 0
			local tempProgress = getElementData(localPlayer, "jobProgress" ) or 0
			--local truckrunsTilNextLevel = level[tempJobLevel] or false
			local tempTruckRuns = getElementData(localPlayer, "job-system-trucker:truckruns" ) or 0

			jobLevel = "Certificate: Worker Level "..tempJobLevel
			if truckrunsTilNextLevel then
				jobProgress = "Progress: "..tempProgress.."/"..truckrunsTilNextLevel.." ("..math.floor(tempProgress/truckrunsTilNextLevel*100).."%)"
			else
				jobProgress = "Progress: "..tempProgress.." (You mastered this job)"
			end
			jobCurrentProgress = "Cleaned shifts: "..tempTruckRuns
		elseif job == 5 and jobVeh == 5 then -- Mechanic
			wipeAdditionalInfo()
			local tempJobLevel = getElementData(localPlayer, "jobLevel") or 0
			local tempProgress = getElementData(localPlayer, "jobProgress" ) or 0
			--local truckrunsTilNextLevel = level[tempJobLevel] or false
			local tempTruckRuns = getElementData(localPlayer, "job-system-trucker:truckruns" ) or 0

			jobLevel = "Certificate: Level "..tempJobLevel
			if truckrunsTilNextLevel then
				jobProgress = "Progress: "..tempProgress.."/"..truckrunsTilNextLevel.." ("..math.floor(tempProgress/truckrunsTilNextLevel*100).."%)"
			else
				jobProgress = "Progress: "..tempProgress.." (You mastered this job)"
			end
			jobCurrentProgress = "Served Vehicles: "..tempTruckRuns
		elseif job == 6 and jobVeh == 6 then -- Locksmith
			wipeAdditionalInfo()
			local tempJobLevel = getElementData(localPlayer, "jobLevel") or 0
			local tempProgress = getElementData(localPlayer, "jobProgress" ) or 0
			--local truckrunsTilNextLevel = level[tempJobLevel] or false
			local tempTruckRuns = getElementData(localPlayer, "job-system-trucker:truckruns" ) or 0

			jobLevel = "Certificate: Level "..tempJobLevel
			if truckrunsTilNextLevel then
				jobProgress = "Progress: "..tempProgress.."/"..truckrunsTilNextLevel.." ("..math.floor(tempProgress/truckrunsTilNextLevel*100).."%)"
			else
				jobProgress = "Progress: "..tempProgress.." (You mastered this job)"
			end
			jobCurrentProgress = "Manipulated Keys: "..tempTruckRuns
		else
			show = false
			return false
		end
	end
end

function wipeAdditionalInfo()
	height = 90
	loadedSupplies = ""
	truckCap = ""
	nextLocation = ""
	nextDropStopRequires = ""
	showTimeoutClock = false
	timeoutClock = ""
	display_distance = nil
end
addEvent( "job-system:trucker:wipeAdditionalInfo", true )
addEventHandler( "job-system:trucker:wipeAdditionalInfo", localPlayer, wipeAdditionalInfo)

-- create the gui
function createGUI(data)
	show = false
	local logged = getElementData(localPlayer, "loggedin")
	local job = getElementData( localPlayer, "job" ) or 0
	if logged == 1 and (job == 1 or job == 2 or job == 3 or job == 4 or job == 5 or job == 6) then
		show = true
		updateGUI(type(data)=='table' and data)
	end
end
addEvent( "job-system:trucker:UpdateOverLay", true )
addEventHandler( "job-system:trucker:UpdateOverLay", localPlayer, createGUI)

addEventHandler( "onClientResourceStart", getResourceRootElement(), createGUI, false )

addEventHandler( "onClientElementDataChange", localPlayer, 
	function(n)
		if n == "job" or n == "jobProgress" or n=="jobLevel" or n == "job-system-trucker:truckruns" or n == "job-system-trucker:currentRoute" or n == "job-system:trucker:updateOverLay" then
			createGUI()
		end
	end, false
)

addEvent( "job-system:trucker:startTimeoutClock", true )
--addEventHandler( "job-system:trucker:startTimeoutClock", localPlayer,
--	function( distance )
--		if distance > 0 then
--			-- display distance to HUD
--			display_distance = distance
--
--			-- get an appropriate time inteveral based on distance.
--			local seconds = math.ceil(distance/4)
--
--			-- if it's too close, set min timer too 1 minute.
--			if seconds < 60 then
--				seconds = 60
--			end
--
--			killTimerCountDown()
--			timerCountDown = setTimer(function()
--				if seconds >=20 then
--					r2, b2, g2 = 0, 255, 0
--				elseif seconds >= 10 then
--					r2, b2, g2 = 255, 255, 0
--				elseif seconds > 0 then
--					r2, b2, g2 = 255, 0, 0
--				else
--					r2, b2, g2 = 255, 0, 0
--					killTimerCountDown()
--					triggerServerEvent("job-system:trucker:spawnRoute", localPlayer, localPlayer, true)
--				end
--				timeoutClock = "Deadline: "..seconds.." second(s)"
--				seconds = seconds - 1
--			end, 1000, 0)
--		end
--	end, false
--)

function killTimerCountDown()
	if timerCountDown then
		killTimer(timerCountDown)
		timerCountDown = nil
	end
end
addEvent( "job-system:trucker:killTimerCountDown", true )
--addEventHandler("job-system:trucker:killTimerCountDown", localPlayer,killTimerCountDown)

local function formatLength(meters)
	meters = tonumber(meters) or 0
	if meters >=1000 then
		return exports.global:round(meters/1000, 2).." kms"
	elseif meters == 1000 then
		return exports.global:round(meters/1000, 2).." km"
	else
		-- round to nearest 10 meters
		meters = math.ceil(meters)
		return meters.." meters"
	end
end

function drawText ( )
	if show and not getElementData(localPlayer, "integration:previewPMShowing") then
		if ( getPedWeapon( localPlayer ) ~= 43 or not getPedControlState( localPlayer, "aim_weapon" ) ) then
			local yOffset = (getElementData(localPlayer, "hud:whereToDisplayY") or 0) + (getElementData(localPlayer, "report-system:dxBoxHeight") or 0) + (getElementData(localPlayer, "hud:overlayTopRight") or 0) + 40
			dxDrawRectangle(sx-width-5, 5+yOffset, width, height, tocolor(0, 0, 0, 150), false)
			
			dxDrawText( jobName or "" , sx-width+10, 10+yOffset, width-5, 20, tocolor ( 255, 255, 255, 255 ), 1, "default-bold" )
			
			dxDrawText( jobLevel or "" , sx-width+10, 30+yOffset, width-5, 15, tocolor ( 255, 255, 255, 255 ), 1, "default" )
			dxDrawText( jobProgress or "" , sx-width+10, 45+yOffset, width-5, 15, tocolor ( 255, 255, 255, 255 ), 1, "default" )
			dxDrawText( jobCurrentProgress or "" , sx-width+10, 60+yOffset, width-5, 15, tocolor ( 255, 255, 255, 255 ), 1, "default" )
			
			dxDrawText( truckCap or "" , sx-width+10, 80+yOffset, width-5, 15, tocolor ( 255, 255, 255, 255 ), 1, "default" )
			dxDrawText( loadedSupplies or "" , sx-width+10, 95+yOffset, width-5, 15, tocolor ( 255, 255, 255, 255 ), 1, "default" )
			
			dxDrawText( nextLocation or "" , sx-width+10, 115+yOffset, width-5, 15, tocolor ( 0, 255, 0, 255 ), 1, "default" )
			dxDrawText( nextDropStopRequires or "" , sx-width+10, 130+yOffset, width-5, 15, tocolor ( r, b, g, 255 ), 1, "default" )
			
			if tonumber(display_distance) then
				local px, py = getElementPosition(localPlayer)
				local route = getElementData(localPlayer, "job-system-trucker:currentRoute")
				local rx, ry = route and route[1], route and route[2]
				local current_distance = rx and getDistanceBetweenPoints2D(px,py,rx, ry)
				dxDrawText( current_distance and ("Distance: "..formatLength(current_distance).."/"..formatLength(display_distance)) or "" , sx-width+10, 145+yOffset, width-5, 15, tocolor ( r2, b2, g2, 255 ), 1, "default" )
			end
--			dxDrawText( timeoutClock or "" , sx-width+10, 160+yOffset, width-5, 15, tocolor ( r2, b2, g2, 255 ), 1, "default" )
		end
	end
end
addEventHandler("onClientRender",root, drawText)