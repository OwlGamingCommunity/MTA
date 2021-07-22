--[[
	Check if anyone is doing the taxi or bus jobs and give them a shoutout
]]
function jobAdverts()
	local taxicount = 0
	local buscount = 0
	local buses = {[431]=true, [437]=true}
	local taxis = {[438]=true, [420]=true}
	
	for _, worker in pairs(exports.pool:getPoolElementsByType('player')) do 
        local motor = getPedOccupiedVehicle(worker)
 
        if (getElementData(worker, "job") == 2) and (motor) and (getVehicleController(motor) == worker) and taxis[getElementModel(motor)] then
            taxicount = taxicount + 1
        end
 
        if (getElementData(worker, "job") == 3) and (motor) and (getVehicleController(motor) == worker) and buses[getElementModel(motor)] then
            buscount = buscount + 1
        end
	end

	for _, ourPlayer in pairs(exports.pool:getPoolElementsByType( 'player' )) do
		if (getElementData(ourPlayer, 'loggedin') == 1) then
			if taxicount > 0 then
				text = "ADVERT: Yellow Cab Co is now taking fares! Call us today! - #8294"
				if exports.integration:isPlayerTrialAdmin(ourPlayer) then 
					text = text .. " (( Job Advert. ))"
				end

				outputChatBox(text, ourPlayer, 0, 255, 0)
			end
			if buscount > 0 then
				text = "ADVERT: Los Santos Bus is now running routes! If you need a ride wait by one of our stops!"
				if exports.integration:isPlayerTrialAdmin(ourPlayer) then 
					text = text .. " (( Job Advert. ))"
				end

				outputChatBox(text, ourPlayer, 0, 255, 0)
			end
		end
	end
end
setTimer(jobAdverts, 600000, 0)	-- Every 10 mins