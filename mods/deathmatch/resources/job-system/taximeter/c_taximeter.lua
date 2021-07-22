--Client-side script: Taximeter
--Created by Exciter, anumaz, 04.05.2014
--Last updated 05.05.2014 by Exciter
--Released as open source. This header should remain intact. Otherwise no use restrictions.

--[[ For standalone only:
bindKey("m", "down", function()
	showCursor(not isCursorShowing())
end )
--]]
--set vars
local gui_base = nil
local meterRunning = false
local lightOn = false
local isDriver = false
local taxiFare = 0
local taxiDistance = 0
local root = getRootElement()
local localPlayer = getLocalPlayer()
local driversSendSyncTimer = nil

function showTaximeterGui()
	if gui_base then
		destroyElement(gui_base)
		gui_base = nil
	end
	
	local screenX, screenY = guiGetScreenSize()
	local width, height = 299, 168
	local x, y
	local speedowidth = 280
 	x = screenX-speedowidth-width
	y = screenY-height-60
	
	if isDriver then
		gui_base = guiCreateStaticImage(x,y,width,height,"taximeter/images/base_driver.png",false,nil)
	else
		gui_base = guiCreateStaticImage(x,y,width,height,"taximeter/images/base_pax.png",false,nil)
	end
	
	--displays
	gui_label_totalFare = guiCreateLabel(23,32,108,28,tostring(math.ceil(taxiFare*(taxiDistance/1000))),false,gui_base) -- since we can't pay cents, need: math.ceil(totalFare) which, if there are cents, its going to go to the higher amount
		guiLabelSetHorizontalAlign(gui_label_totalFare, "right", false)
		guiLabelSetVerticalAlign(gui_label_totalFare, "center")
	gui_label_distance = guiCreateLabel(177,32,93,28,string.format("%.1f", tostring(taxiDistance/1000)),false,gui_base)
		guiLabelSetHorizontalAlign(gui_label_distance, "right", false)
		guiLabelSetVerticalAlign(gui_label_distance, "center")		
	gui_label_fare = guiCreateLabel(76,67,56,17,string.format("%.2f", tostring(taxiFare)),false,gui_base)
		guiLabelSetHorizontalAlign(gui_label_fare, "right", false)
		guiLabelSetVerticalAlign(gui_label_fare, "center")
		
	if isDriver then --buttons etc. go here
		gui_btn1 = guiCreateStaticImage(24,112,31,31,"taximeter/images/btn.png",false,gui_base)
			addEventHandler("onClientGUIClick", gui_btn1, toggleMeter)
			if meterRunning then
				guiStaticImageLoadImage(gui_btn1, "taximeter/images/btn_active.png")
			end
		
		gui_btn2 = guiCreateStaticImage(82,112,31,31,"taximeter/images/btn.png",false,gui_base) --x=+27 =58
			addEventHandler("onClientGUIClick", gui_btn2, resetMeter)
		
		gui_btn3 = guiCreateStaticImage(140,112,31,31,"taximeter/images/btn.png",false,gui_base)
			addEventHandler("onClientGUIClick", gui_btn3, setFare)
		
		gui_btn4 = guiCreateStaticImage(198,112,31,31,"taximeter/images/btn.png",false,gui_base)
			addEventHandler("onClientGUIClick", gui_btn4, toggleLight)
			if lightOn then
				guiStaticImageLoadImage(gui_btn4, "taximeter/images/btn_on.png")
			end		
	else
		if meterRunning then
			gui_label_pax_running = guiCreateLabel(17,113,218,20,"Taximeter running",false,gui_base)
			guiLabelSetColor(gui_label_pax_running,0,255,0)
		else
			gui_label_pax_running = guiCreateLabel(17,113,218,20,"Taximeter not running",false,gui_base)
			guiLabelSetColor(gui_label_pax_running,255,0,0)
		end
	end
	
end

function hideTaximeterGui()
	if gui_base then
		destroyElement(gui_base)
		gui_base = nil
	end
	taxiFare = 0
	taxiDistance = 0
	meterRunning = false
	lightOn = false
	isDriver = false
end

function toggleMeter()
	if(source == gui_btn1) then
		if isDriver then
			if meterRunning then
				meterRunning = false
				local theVehicle = getPedOccupiedVehicle(localPlayer)
				
				if driversSendSyncTimer then
					killTimer(driversSendSyncTimer)
					driversSendSyncTimer = nil
				end
				
				removeEventHandler("onClientRender",root,monitoring)
				sendTaximeterSync()
				
				guiStaticImageLoadImage(gui_btn1, "taximeter/images/btn.png")
			else
				meterRunning = true
				local theVehicle = getPedOccupiedVehicle(localPlayer)
				
				if driversSendSyncTimer then
					killTimer(driversSendSyncTimer)
					driversSendSyncTimer = nil
				end
				
				sendTaximeterSync()
				driversSendSyncTimer = setTimer(sendTaximeterSync, syncInterval, 0)
				addEventHandler("onClientRender",root,monitoring)
				guiStaticImageLoadImage(gui_btn1, "taximeter/images/btn_active.png")
			end
		end
	end
end

function resetMeter()
	if(source == gui_btn2) then
		taxiDistance = 0
		guiSetText(gui_label_totalFare, "0")
		guiSetText(gui_label_distance, "0")
		triggerServerEvent("taximeter:resetMeter", localPlayer)
	end
end

function setFare()
	if(source == gui_btn3) then
		if gui_fareWin then
			destroyElement(gui_fareWin)
			gui_fareWin = nil
		end
		local screenX, screenY = guiGetScreenSize()
		local width, height = 300, 140
		local x, y
		x = (screenX/2)-(width/2)
		y = (screenY/2)-(height/2)
		
		gui_fareWin = guiCreateWindow(x,y,width,height,"Set Taximeter Fare",false,nil)
			
			if(meterRunning and taxiDistance > 0) then
				local lbl = guiCreateLabel(20,20,260,80,"Meter must be stopped and reset before setting a new fare!",false,gui_fareWin)
					guiLabelSetColor(lbl,255,0,0)
					guiLabelSetHorizontalAlign(lbl,"center",true)
				local cnfm = guiCreateButton(110,100,80,40,"OK",false,gui_fareWin)
				addEventHandler("onClientGUIClick", cnfm, function()
					destroyElement(gui_fareWin)
					gui_fareWin = nil
				end)
				return			
			elseif meterRunning then
				local lbl = guiCreateLabel(20,20,260,80,"Meter must be stopped before setting a new fare!",false,gui_fareWin)
					guiLabelSetColor(lbl,255,0,0)
					guiLabelSetHorizontalAlign(lbl,"center",true)
				local cnfm = guiCreateButton(110,100,80,40,"OK",false,gui_fareWin)
				addEventHandler("onClientGUIClick", cnfm, function()
					destroyElement(gui_fareWin)
					gui_fareWin = nil
				end)
				return
			elseif taxiDistance > 0 then
				local lbl = guiCreateLabel(20,20,260,80,"Meter must be reset before setting a new fare!",false,gui_fareWin)
					guiLabelSetColor(lbl,255,0,0)
					guiLabelSetHorizontalAlign(lbl,"center",true)
				local cnfm = guiCreateButton(110,100,80,40,"OK",false,gui_fareWin)
				addEventHandler("onClientGUIClick", cnfm, function()
					destroyElement(gui_fareWin)
					gui_fareWin = nil
				end)
				return
			end
			
			local lbl = guiCreateLabel(20,20,150,20,"Set a fare per kilometer",false,gui_fareWin)
			--local inpt = guiCreateEdit(20,40,60,20,"1",false,gui_fareWin)
			
			local lbl2 = guiCreateLabel(20,70,260,20,"$"..string.format("%.2f", tostring(minFare)).."/km",false,gui_fareWin)
				guiLabelSetHorizontalAlign(lbl2, "center", false)
			
			local scroll = guiCreateScrollBar(20,40,260,20,true,false,gui_fareWin)
			local stepsize = 100/((maxFare-minFare)/0.05)
			guiSetProperty(scroll, "StepSize", "0.01")
			addEventHandler("onClientGUIScroll", scroll, function()
				if(source == scroll) then
					local percent = (guiScrollBarGetScrollPosition(scroll)/100)
					local scrollFare = (((maxFare-minFare)*percent)+minFare)
					scrollFare = string.format("%.2f", tostring(scrollFare))
					guiSetText(lbl2, "$"..tostring(scrollFare).."/km")
					scrollFare = tonumber(scrollFare)
				end
			end, false)
			
			local cnfm = guiCreateButton(110,100,80,40,"Set Fare",false,gui_fareWin)
			addEventHandler("onClientGUIClick", cnfm, function()
				local percent = (guiScrollBarGetScrollPosition(scroll)/100)
				local newFare = (((maxFare-minFare)*percent)+minFare)
				guiSetText(gui_label_fare, string.format("%.2f", tostring(newFare)))
				local theVehicle = getPedOccupiedVehicle(localPlayer)
				triggerServerEvent("taximeter:setFare", theVehicle, newFare)
				taxiFare = newFare
				destroyElement(gui_fareWin)
				gui_fareWin = nil
			end)
	end
end

function toggleLight()
	if(source == gui_btn4) then
		if lightOn then --turn off
			lightOn = false
			triggerServerEvent("taximeter:setLight", localPlayer, lightOn)
			guiStaticImageLoadImage(gui_btn4, "taximeter/images/btn.png")
		else --turn on
			lightOn = true
			guiStaticImageLoadImage(gui_btn4, "taximeter/images/btn_on.png")
			triggerServerEvent("taximeter:setLight", localPlayer, lightOn)
		end
	end
end


local oX, oY, oZ
function monitoring()
	if(isPedInVehicle(localPlayer)) then
		local x,y,z = getElementPosition(getPedOccupiedVehicle(localPlayer))
		local thisTime  = getDistanceBetweenPoints3D(x,y,z,oX,oY,oZ)
		taxiDistance = taxiDistance + thisTime
		oX = x
		oY = y
		oZ = z
		if gui_base then
			guiSetText(gui_label_totalFare, tostring(math.ceil(taxiFare*(taxiDistance/1000))))
			guiSetText(gui_label_distance, string.format("%.1f", tostring(taxiDistance/1000)))
		end
	end
end

function incomingTaximeterSync(realDistance, realRunning, realPos)
	if not isDriver then
		if meterRunning then
			removeEventHandler("onClientRender",root,monitoring)
		end
		taxiDistance = realDistance
		oX, oY, oZ = realPos[1], realPos[2], realPos[3]
		if realRunning then
			meterRunning = true
			addEventHandler("onClientRender",root,monitoring)
			guiSetText(gui_label_pax_running, "Taximeter running")
			guiLabelSetColor(gui_label_pax_running,0,255,0)
		else
			meterRunning = false
			guiSetText(gui_label_pax_running, "Taximeter not running")
			guiLabelSetColor(gui_label_pax_running,255,0,0)
		end
	end
end
addEvent("taximeter:sync", true)
addEventHandler("taximeter:sync", root, incomingTaximeterSync)

function incomingFareUpdate(newFare)
	taxiFare = newFare
	if gui_base then
		guiSetText(gui_label_fare, string.format("%.2f", tostring(taxiFare)))
	end
end
addEvent("taximeter:sendFare", true)
addEventHandler("taximeter:sendFare", root, incomingFareUpdate)

function incomingReset(newFare)
	taxiDistance = 0
	if gui_base then
		guiSetText(gui_label_distance, "0")
		guiSetText(gui_label_totalFare, "0")
	end
end
addEvent("taximeter:resetMeter", true)
addEventHandler("taximeter:resetMeter", root, incomingReset)

function sendTaximeterSync(vehicle, ignoreCheck)
	if isDriver then
		local theVehicle
		if vehicle then
			theVehicle = vehicle
		else
			theVehicle = getPedOccupiedVehicle(localPlayer)
		end
		local x,y,z = getElementPosition(theVehicle)
		local pos = {x,y,z}
		triggerServerEvent("taximeter:sendSync", theVehicle, taxiDistance, meterRunning, pos, ignoreCheck)
	end
end

function initializeTaximeter(seat, realDistance, realRunning, realPos, realFare, taxiLight)
	local theVehicle = source
	if(seat == 0) then
		isDriver = true
	else
		isDriver = false
	end
	taxiFare = realFare
	taxiDistance = realDistance
	oX, oY, oZ = realPos[1], realPos[2], realPos[3]
	meterRunning = realRunning
	lightOn = taxiLight
	showTaximeterGui()
	if meterRunning then
		addEventHandler("onClientRender",root,monitoring)
		if isDriver then
			if driversSendSyncTimer then
				killTimer(driversSendSyncTimer)
				driversSendSyncTimer = nil
			end
			driversSendSyncTimer = setTimer(sendTaximeterSync, syncInterval, 0)
		end	
	end
end
addEvent("taximeter:initialize", true)
addEventHandler("taximeter:initialize", root, initializeTaximeter)

--[[
addEventHandler("onClientVehicleEnter", root,
		function (player, seat)
				local theVehicle = source		
				if(taxiModels[getElementModel(theVehicle)]) then --if taxi	
					taxiFare = tonumber(getElementData(theVehicle, "taximeter.fare")) or 0
					taxiDistance = tonumber(getElementData(theVehicle, "taximeter.distance")) or 0
					meterRunning = getElementData(theVehicle, "taximeter.running") and true or false
					if (seat == 0) then --if driver
						isDriver = true
						showTaximeterGui()
					else --if passenger
						isDriver = false
						showTaximeterGui()			
					end
				end
		end
)
--]]
addEventHandler("onClientVehicleStartExit", root,
		function (player, seat, door)
			if(player == localPlayer) then
				local theVehicle = source
				if(taxiModels[getElementModel(theVehicle)]) then --if taxi	
					if meterRunning then
						meterRunning = false
						removeEventHandler("onClientRender",root,monitoring)
						if isDriver and gui_base then
							guiStaticImageLoadImage(gui_btn1, "taximeter/images/btn.png")
						end
					end
					if isDriver then
						if driversSendSyncTimer then
							killTimer(driversSendSyncTimer)
							driversSendSyncTimer = nil
						end
					end
				end
			end
		end
)
addEventHandler("onClientVehicleExit", root,
		function (player, seat)
			if(player == localPlayer) then
				local theVehicle = source
				if(taxiModels[getElementModel(theVehicle)]) then --if taxi	
					if isDriver then
						sendTaximeterSync(theVehicle, true)
					end
					hideTaximeterGui()
				end
			end
		end
)

addEventHandler("onClientResourceStart", getResourceRootElement(getThisResource()),
		function (startedRes)
			triggerServerEvent("taximeter:clientStarted", localPlayer)
		end
)

--addEventHandler("onClientResourceStart", getRootElement(), showTaximeterGui)
