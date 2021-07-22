-------------------------------------------------------
--	Script written by Morelli
--	Given copy to vg.MTA on 12th December 2008
--
--
-- THIS COPY WAS INTENDED FOR vG.MTA
-- GAMING ONLY. FULL RIGHTS TO SCRIPT
-- ARE HELD BY Morelli (Cris G.)
-------------------------------------------------------

function Checkpoints( x_point, y_point, z_point )
	return { x_point=x_point, y_point=y_point, z_point=z_point }
end



--------- LIST OF CHECKPOINTS (x,y,z)
CheckpointStyle_1 = {
Checkpoints(1503.5179443359, 2369.0305175781, 10.8203125),	-- 1
Checkpoints(1464.6153564453, 2395.1040039063, 10.402856826782),	-- 2
Checkpoints(1384.7719726563, 2333.8818359375, 10.397030830383),		-- 3
Checkpoints(1551.2609863281, 2310.1337890625, 10.378786087036),	-- 4
Checkpoints(1564.5493164063, 2183.0297851563, 10.385837554932),		-- 5
Checkpoints(1721.5200195313, 2170.8815917969, 10.462002754211),	-- 6
Checkpoints(1794.4456787109, 2111.9787597656, 10.526327133179),	-- 7
Checkpoints(1906.0688476563, 2039.1931152344, 10.378953933716),	-- 8
Checkpoints(2047.5615234375, 2019.7652587891, 10.378077507019),		-- 9
Checkpoints(2119.1411132813, 1889.6407470703, 10.377884864807),	-- 10
Checkpoints(2040.5341796875, 1649.0466308594, 10.379492759705),
Checkpoints(2057.3032226563, 971.04376220703, 10.187139511108),
Checkpoints(2194.17578125, 970.45745849609, 10.379013061523),
Checkpoints(2349.8679199219, 1146.8768310547, 10.378357887268),
Checkpoints(2429.4118652344, 1294.2354736328, 10.379963874817),	-- 15
Checkpoints(2329.783203125, 1674.2967529297, 10.375924110413),
Checkpoints(2197.2158203125, 1776.431640625, 10.378499984741),
Checkpoints(2154.8635253906, 2036.650390625, 10.377578735352),
Checkpoints(2137.6833496094, 2149.0537109375, 10.380690574646),
Checkpoints(2070.3601074219, 2115.6586914063, 10.377153396606),	--20
Checkpoints(1929.2501220703, 2178.8508300781, 10.461337089539),
Checkpoints(1749.9678955078, 2276.0661621094, 10.767349243164),
Checkpoints(1589.3919677734, 2276.353515625, 10.383700370789),
Checkpoints(1570.5980224609, 2370.2763671875, 10.3788022995),
Checkpoints(1514.619140625, 2396.099609375, 10.380763053894)		-- 25
}

--------- LIST OF CHECKPOINTS (x,y,z) STILL LS

CheckpointStyle_2 = {
Checkpoints(1352.8961181641, -1859.5826416016, 13.062502861023),	-- 1
Checkpoints(1285.7108154297, -1848.6300048828, 13.070272445679),	-- 2
Checkpoints(1236.6922607422, -1848.9869384766, 13.062520980835),	-- 3
Checkpoints(1183.7025146484, -1829.6427001953, 13.084740638733),	-- 4
Checkpoints(1183.2073974609, -1745.0368652344, 13.078165054321),	-- 5
Checkpoints(1165.7062988281, -1709.0847167969, 13.386648178101),	-- 6
Checkpoints(1152.9514160156, -1655.8560791016, 13.460966110229),	-- 7
Checkpoints(1177.3618164063, -1575.5860595703, 13.021441459656),	-- 8
Checkpoints(1199.3806152344, -1537.73046875, 13.062530517578),		-- 9
Checkpoints(1229.5970458984, -1409.8035888672, 12.762256622314),	-- 10
Checkpoints(1326.4197998047, -1409.5676269531, 12.994469642639),
Checkpoints(1333.708984375, -1460.2164306641, 13.062521934509),
Checkpoints(1299.7297363281, -1531.2474365234, 13.062524795532),
Checkpoints(1293.5206298828, -1697.1125488281, 13.062491416931),
Checkpoints(1294.2446289063, -1758.6617431641, 13.062560081482),	-- 15
Checkpoints(1318.3055419922, -1855.8670654297, 13.062488555908),
Checkpoints(1466.8850097656, -1875.3677978516, 13.062706947327)
}

--------- LIST OF CHECKPOINTS (x,y,z) STIlL LS

CheckpointStyle_3 = {
Checkpoints(1392.9182128906, -1849.4359130859, 13.062501907349),	-- 1
Checkpoints(1359.4191894531, -1728.3851318359, 13.062509536743),	-- 2
Checkpoints(1316.0694580078, -1706.1624755859, 13.062499046326),	-- 3
Checkpoints(1315.7808837891, -1613.7049560547, 13.062588691711),	-- 4
Checkpoints(1350.2197265625, -1482.302734375, 13.062542915344),	-- 5
Checkpoints(1361.4122314453, -1331.4384765625, 13.072121620178),	-- 6
Checkpoints(1376.0242919922, -1244.6530761719, 13.062377929688),	-- 7
Checkpoints(1458.2574462891, -1204.8851318359, 17.670797348022),	-- 8
Checkpoints(1552.6872558594, -1164.6351318359, 23.586046218872),	-- 9
Checkpoints(1677.3698730469, -1163.7897949219, 23.336751937866),	-- 10
Checkpoints(1785.4711914063, -1175.5250244141, 23.334577560425),
Checkpoints(1843.4012451172, -1213.3070068359, 19.598274230957),
Checkpoints(1843.5284423828, -1308.5684814453, 13.069962501526),
Checkpoints(1825.5729980469, -1554.466796875, 13.05043888092),
Checkpoints(1818.0430908203, -1675.3146972656, 13.062560081482),	-- 15
Checkpoints(1817.8955078125, -1795.8341064453, 13.062686920166),
Checkpoints(1831.951171875, -1936.1204833984, 13.059115409851)
}


function initiateCleanerJob(thePlayer)
	
	local blip = createBlip(1504.0679931641, 2364.36328125, 10.8203125, 0, 2, 255, 0, 255, 255)
	local marker = createMarker(1504.3505859375, 2363.8732910156, 10.8203125, "cylinder", 2, 0, 255, 0, 150)
	exports.pool:allocateElement(blip)
	exports.pool:allocateElement(marker)
	attachElements ( marker, blip )
	
	setElementVisibleTo(blip, getRootElement(), false)
	setElementVisibleTo(blip, thePlayer, true)
	setElementVisibleTo(marker, getRootElement(), false)
	setElementVisibleTo(marker, thePlayer, true)

	
	outputChatBox("Welcome to the team, you can pick up your street cleaning van at the Depo near City Hall. ", thePlayer, 255, 194, 14)
	outputChatBox("((A pink blip has been added to your map - Press F11))", thePlayer, 255, 194, 14)
	addEventHandler("onMarkerHit", marker, startCleaningMission, false)
end

function startCleaningMission(thePlayer)
	if (isElement(thePlayer)) then
		local attached = getElementAttachedTo ( source ) -- source is the marker; attatched is the blip
		destroyElement(attached)
		destroyElement(source)
		attached = nil
		source = nil
		
		local vehicle = createVehicle(574,  1503.5179443359, 2369.0305175781, 10.8203125, 0, 0, 0.645355224609, "CLEANER")
		exports.pool:allocateElement(vehicle)
			
		exports.anticheat:setEld( vehicle, "fuel", 100 )
		exports.anticheat:changeProtectedElementDataEx(vehicle, "owner", -2, false)
		exports.anticheat:changeProtectedElementDataEx(vehicle, "faction", -1, false)
		exports.anticheat:changeProtectedElementDataEx(vehicle, "dbid", 999999, false)
		exports.anticheat:changeProtectedElementDataEx(vehicle, "engine", 1, false)
		removePedFromVehicle(thePlayer)
		warpPedIntoVehicle(thePlayer, vehicle)
		
		exports.anticheat:changeProtectedElementDataEx(thePlayer, "cleaner.marker", "1")
		exports.anticheat:changeProtectedElementDataEx(thePlayer, "cleaner.vehicle", vehicle)
		
		local int = math.random ( 1, 1 ) -- Number of checkpoint paths. (1 minimum , 3 max )
		local x1,y1,z1 = nil
		if tonumber(int) == 1 then
			x1 = CheckpointStyle_1[1].x_point
			y1 = CheckpointStyle_1[1].y_point
			z1 = CheckpointStyle_1[1].z_point
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "cleaner.checkmarkers", "25")
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "cleaner.t", "1")
		elseif tonumber(int) == 2 then
			x1 = CheckpointStyle_2[1].x_point
			y1 = CheckpointStyle_2[1].y_point
			z1 = CheckpointStyle_2[1].z_point
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "cleaner.checkmarkers", "17")
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "cleaner.t", "2")
		elseif tonumber(int) == 3 then
			x1 = CheckpointStyle_3[1].x_point
			y1 = CheckpointStyle_3[1].y_point
			z1 = CheckpointStyle_3[1].z_point
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "cleaner.checkmarkers", "17")
			exports.anticheat:changeProtectedElementDataEx(thePlayer, "cleaner.t", "3")
		end																				--- <<<<<<<<<<<<<<<<<<<<<<<<<<<<<
		local blip2 = createBlip(x1 ,y1 ,z1, 0, 2, 255, 0, 255, 255)
		local marker2 = createMarker(x1 ,y1 ,z1 , "checkpoint", 4, 255, 0, 255, 150)
		exports.pool:allocateElement(blip2)
		exports.pool:allocateElement(marker2)
		
		setElementVisibleTo(blip2, getRootElement(), false)
		setElementVisibleTo(blip2, thePlayer, true)
		setElementVisibleTo(marker2, getRootElement(), false)
		setElementVisibleTo(marker2, thePlayer, true)
		
		local colsphere = createColSphere ( x1 ,y1 ,z1 , 4 )
		exports.pool:allocateElement(colsphere)
		attachElements ( marker2, blip2 )
		exports.anticheat:changeProtectedElementDataEx(colsphere, "attatched", marker2)
		
		addEventHandler("onColShapeHit", colsphere, UpdateCheckpoints)
		
		outputChatBox("Drive around Los Santos on your cleaning path, sweeping the streets. ((Drive through the checkpoints))", thePlayer, 255, 194, 14)
	end
	
end
addCommandHandler("cj", startCleaningMission)

function UpdateCheckpoints(thePlayer)
	if ( isPedInVehicle ( thePlayer ) ) then
		local vehicle = getPedOccupiedVehicle ( thePlayer )
		local vehid = getElementModel ( vehicle )
		if tonumber(vehid) == 574 then
			local markerattatched = getElementData(source, "attatched" )
			local attached = getElementAttachedTo ( markerattatched ) -- source is the marker; attatched is the blip
			destroyElement(attached)
			destroyElement(markerattatched)
			destroyElement(source)
			attached = nil
			markerattatched = nil
			source = nil
			
			local m_number = getElementData(thePlayer, "cleaner.marker")
			local max_number = getElementData(thePlayer, "cleaner.checkmarkers")
			if tonumber(max_number) == tonumber(m_number) then
				outputChatBox("Alright, that should be enough. Drive to the trash dump. (( Blip added. Check on F11 ))", thePlayer, 255, 194, 14)
				local marker3 = createMarker(1503.5179443359, 2369.0305175781, 10.8203125, "checkpoint", 4, 255, 0, 255, 150)
				local blip3 = createBlip(1503.5179443359, 2369.0305175781, 10.8203125, 0, 2, 255, 0, 255, 255)
				exports.pool:allocateElement(marker3)
				exports.pool:allocateElement(blip3)
				
				setElementVisibleTo(blip3, getRootElement(), false)
				setElementVisibleTo(blip3, thePlayer, true)
				setElementVisibleTo(marker3, getRootElement(), false)
				setElementVisibleTo(marker3, thePlayer, true)
				
				local colsphere = createColSphere (1503.5179443359, 2369.0305175781, 10.8203125 , 4 )
				exports.pool:allocateElement(colsphere)
				attachElements ( marker3, blip3 )
				exports.anticheat:changeProtectedElementDataEx(colsphere, "attatched", marker3)
				
				addEventHandler("onColShapeHit", colsphere, FinalCheckpoints)
			else
				local newnumber = m_number+1
				exports.anticheat:changeProtectedElementDataEx(thePlayer, "cleaner.marker", newnumber)
				
				local x2, y2, z2 = nil
				
				local type2 = getElementData(thePlayer, "cleaner.t")
				if tonumber(type2) == 1 then
					x2 = CheckpointStyle_1[newnumber].x_point
					y2 = CheckpointStyle_1[newnumber].y_point
					z2 = CheckpointStyle_1[newnumber].z_point
				elseif tonumber(type2) == 2 then
					x2 = CheckpointStyle_2[newnumber].x_point
					y2 = CheckpointStyle_2[newnumber].y_point
					z2 = CheckpointStyle_2[newnumber].z_point
				elseif tonumber(type2) == 3 then
					x2 = CheckpointStyle_3[newnumber].x_point
					y2 = CheckpointStyle_3[newnumber].y_point
					z2 = CheckpointStyle_3[newnumber].z_point
				end
				
				local marker3 = createMarker( x2, y2, z2, "checkpoint", 4, 255, 0, 255, 150)
				local blip3 = createBlip( x2, y2, z2, 0, 2, 255, 0, 255, 255)
				exports.pool:allocateElement(marker3)
				exports.pool:allocateElement(blip3)
				
				setElementVisibleTo(blip3, getRootElement(), false)
				setElementVisibleTo(blip3, thePlayer, true)
				setElementVisibleTo(marker3, getRootElement(), false)
				setElementVisibleTo(marker3, thePlayer, true)
				
				local colsphere = createColSphere ( x2 ,y2 ,z2 , 4 )
				exports.pool:allocateElement(colsphere)
				attachElements ( marker3, blip3 )
				exports.anticheat:changeProtectedElementDataEx(colsphere, "attatched", marker3)
				
				
				addEventHandler("onColShapeHit", colsphere, UpdateCheckpoints)
			end
		else
			outputChatBox( "(( You must pass through the checkpoints in the street sweeper. ))", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox( "(( You must pass through the checkpoints in the street sweeper. ))", thePlayer, 255, 194, 14)
	end
end

function FinalCheckpoints( thePlayer )
	if ( isPedInVehicle ( thePlayer ) ) then
		local vehicle = getPedOccupiedVehicle ( thePlayer )
		local vehid = getElementModel ( vehicle )
		if tonumber(vehid) == 574 then
			local markerattatched = getElementData(source, "attatched" )
			local attached = getElementAttachedTo ( markerattatched ) -- source is the marker; attatched is the blip
			destroyElement(attached)
			destroyElement(markerattatched)
			destroyElement(source)
			attached = nil
			markerattatched = nil
			source = nil
			
			outputChatBox("Drive over to the drop-off spot to collect payment. (( Blip added. Check on F11 ))", thePlayer, 255, 194, 14)
			
			local marker4 = createMarker(1442.3360595703, 2371.0288085938, 10.8203125, "checkpoint", 4, 255, 0, 255, 150)
			local blip4 = createBlip(1442.3360595703, 2371.0288085938, 10.8203125, 0, 2, 255, 0, 255, 255)
			exports.pool:allocateElement(marker4)
			exports.pool:allocateElement(blip4)
			
			setElementVisibleTo(blip4, getRootElement(), false)
			setElementVisibleTo(blip4, thePlayer, true)
			setElementVisibleTo(marker4, getRootElement(), false)
			setElementVisibleTo(marker4, thePlayer, true)
			
			local colsphere = createColSphere (1442.3360595703, 2371.0288085938, 10.8203125, 4 )
			exports.pool:allocateElement(colsphere)
			attachElements ( marker4, blip4 )
			exports.anticheat:changeProtectedElementDataEx(colsphere, "attatched", marker4)
				
			addEventHandler("onColShapeHit", colsphere, FinishCheckpoints)
		else
			outputChatBox( "(( You must pass through the checkpoints in the street sweeper. ))", thePlayer, 255, 194, 14)
		end
	else
		outputChatBox( "(( You must pass through the checkpoints in the street sweeper. ))", thePlayer, 255, 194, 14)
	end
end

function FinishCheckpoints(thePlayer)
	if (isElement(thePlayer)) then
		if ( isPedInVehicle ( thePlayer ) ) then
			local vehicle = getPedOccupiedVehicle ( thePlayer )
			local vehid = getElementModel ( vehicle )
			if tonumber(vehid) == 574 then
				local markerattatched = getElementData(source, "attatched" )
				local attached = getElementAttachedTo ( markerattatched ) -- source is the marker; attatched is the blip
				destroyElement(attached)
				destroyElement(markerattatched)
				destroyElement(source)
				attached = nil
				markerattatched = nil
				source = nil

				removePedFromVehicle ( thePlayer )
				
				exports.anticheat:changeProtectedElementDataEx(vehicle, "fuel")
				exports.anticheat:changeProtectedElementDataEx(vehicle, "dbid")
				
				if (isElement(vehicle)) then
					destroyElement(vehicle)
					vehicle = nil
					exports.anticheat:changeProtectedElementDataEx(thePlayer, "cleaner.vehicle")
					
					outputChatBox("You have completed your task, well done.", thePlayer, 255, 194, 14)
					outputChatBox("You received: 300$", thePlayer, 255, 194, 14)
					exports.global:giveMoney(thePlayer, 300)
					
					removeElementData ( thePlayer, "cleaner.marker" )
					removeElementData ( thePlayer, "cleaner.t" )
					removeElementData ( thePlayer, "cleaner.checkmarkers" )
				end
			else
				outputChatBox( "(( You must pass through the checkpoints in the street sweeper. ))", thePlayer, 255, 194, 14)
			end
		else
			outputChatBox( "(( You must pass through the checkpoints in the street sweeper. ))", thePlayer, 255, 194, 14)
		end
	end
end

function quit()
	local vehicle = getElementData(source, "cleaner.vehicle")
	if vehicle then
		destroyElement(vehicle)
	end
	exports.anticheat:changeProtectedElementDataEx(source, "cleaner.vehicle")
end

addEventHandler("onPlayerQuit", getRootElement(), quit)