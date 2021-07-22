local blip
local jobstate = 0
local route = 0
local marker
local colshape
local routescompleted = 0

routes = { }
routes[1] = { 2430.5205078125, 1262.431640625, 9.443614006042 }
routes[2] = { 2429.6953125, 1460.9482421875, 9.420741081238 }
routes[3] = { 2419.92578125, 1664.232421875, 9.566228866577 }
routes[4] = { 2118.0400390625, 1776.337890625, 9.419044494629 }
routes[5] = { 2149.91015625, 2119.57421875, 9.418784141541 }
routes[6] = { 1939.5078125, 2116.16015625, 9.411161422729 }
routes[7] = { 2190.0830078125, 1356.025390625, 9.420398712158 }
routes[8] = { 1862.5185546875, 1274.9775390625, 9.418623924255 }
routes[9] = { 1735.6337890625, 1306.5048828125, 9.488379478455 }
routes[10] = { 1662.6455078125, 1715.7353515625, 9.424433708191 }
routes[11] = { 1570.5185546875, 1863.1220703125,9.423510551453 }
routes[12] = { 1151.1455078125, 1815.681640625, 10.409116744995 }
routes[13] = { 921.390625, 1855.4375, 9.420220375061 }
routes[14] = { 1009.529296875, 2138.138671875, 9.4192943573 }
routes[15] = { 1028.443359375, 2390.4072265625, 9.417165756226 }


function resetSweeperJob()
	jobstate = 0
	
	if (isElement(marker)) then
		destroyElement(marker)
	end
	
	if (isElement(colshape)) then
		destroyElement(colshape)
	end
	
	if (isElement(blip)) then
		destroyElement(blip)
	end
end

function displaySweeperJob()
	if (jobstate==0) then
		jobstate = 1
		blip = createBlip(1480.6318359375, 2372.498046875, 10.8203125, 0, 4, 255, 127, 255)
		outputChatBox("#FF9933Approach the #FF66CCblip#FF9933 on your radar and enter the sweeper to start your job.", 255, 194, 15, true)
		outputChatBox("#FF9933Type /startjob once you are in the sweeper.", 255, 194, 15, true)
	end
end

function startSweeperJob()
	if (jobstate==1) then
		local vehicle = getPedOccupiedVehicle(localPlayer)
		
		if not (vehicle) then
			outputChatBox("You must be in a sweeper.", 255, 0, 0)
		else
			local model = getElementModel(vehicle)
			if (model==574) then -- SWEEPER
				routescompleted = 0
			
				outputChatBox("#FF9933Drive to the #FF66CCblip#FF9933 on the radar and use /cleanroad.", 255, 194, 15, true)
				destroyElement(blip)
				
				local rand = math.random(1, 15)
				route = routes[rand]
				local x, y, z = routes[rand][1], routes[rand][2], routes[rand][3]
				blip = createBlip(x, y, z, 0, 4, 255, 127, 255)
				marker = createMarker(x, y, z, "cylinder", 4, 255, 127, 255, 150)
				colshape = createColCircle(x, y, z, 4)
								
				jobstate = 2
			else
				outputChatBox("You are not in a sweeper.", 255, 0, 0)
			end
		end
	end
end
addCommandHandler("startjob", startSweeperJob)

function cleanRoad()
	if (jobstate==2 or jobstate==3) then
		local vehicle = getPedOccupiedVehicle(localPlayer)
		
		if not (vehicle) then
			outputChatBox("You are not in the van.", 255, 0, 0)
		else
			local model = getElementModel(vehicle)
			if (model==414) then -- MULE
				if (isElementWithinColShape(vehicle, colshape)) then
					destroyElement(colshape)
					destroyElement(marker)
					destroyElement(blip)
					outputChatBox("You completed your trucking run.", 0, 255, 0)
					routescompleted = routescompleted + 1
					outputChatBox("#FF9933You can now either return to the #00CC00warehouse #FF9933and obtain your wage", 0, 0, 0, true)
					outputChatBox("#FF9933or continue onto the next #FF66CCdrop off point#FF9933 and increase your wage.", 0, 0, 0, true)
					
					-- next drop off
					local rand = math.random(1, 10)
					route = routes[rand]
					local x, y, z = routes[rand][1], routes[rand][2], routes[rand][3]
					blip = createBlip(x, y, z, 0, 4, 255, 127, 255)
					marker = createMarker(x, y, z, "cylinder", 4, 255, 127, 255, 150)
					colshape = createColCircle(x, y, z, 4)
					
					if not(endblip)then
						-- end marker
						endblip = createBlip(2836, 975, 9.75, 0, 4, 0, 255, 0)
						endmarker = createMarker(2836, 975, 9.75, "cylinder", 4, 0, 255, 0, 150)
						endcolshape = createColCircle(2836, 975, 9.75, 4)
						addEventHandler("onClientColShapeHit", endcolshape, endTruckJob, false)
					end
					jobstate = 3
				else
					outputChatBox("#FF0066You are not at your #FF66CCdrop off point#FF0066.", 255, 0, 0, true)
				end
			else
				outputChatBox("You are not in a van.", 255, 0, 0)
			end
		end
	end
end
addCommandHandler("dumpload", dumpTruckLoad)

function endTruckJob()
	local vehicle = getPedOccupiedVehicle(localPlayer)
	if not (vehicle) then
		outputChatBox("You are not in the van.", 255, 0, 0)
	else
		local model = getElementModel(vehicle)
		if (model==414) then -- MULE
			if (jobstate==3) then

				local wage = 50*routescompleted
				outputChatBox("You earned $" .. wage .. " on your trucking runs.", 255, 194, 15)
				local vehicle = getPedOccupiedVehicle(localPlayer)
				triggerServerEvent("giveTruckingMoney", localPlayer, wage)

			end
			
			triggerServerEvent("respawnTruck", localPlayer, vehicle)
			outputChatBox("Thank you for your services to RS Haul.", 0, 255, 0)
			destroyElement(colshape)
			destroyElement(marker)
			destroyElement(blip)
			destroyElement(endblip)
			destroyElement(endmarker)
			destroyElement(endcolshape)
			routescompleted = 0

			triggerServerEvent("quitjob", localPlayer)
		else
			outputChatBox("You are not in the van.", 255, 0, 0)
		end
	end
end
