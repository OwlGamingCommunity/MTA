--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

local everage_body_weight = 80 --kgs
local max

local function getPassengersTotalWeight(veh)
	local passenger_weight = 0
	for seat, passenger in pairs(getVehicleOccupants(veh)) do
		passenger_weight = passenger_weight + (getElementData(passenger, 'weight') or 0)
	end
	return passenger_weight
end

function setVehicleWeight ( thePlayer, seat, jacked ) 
	-- get extra weight being on the vehicle.
	local passenger_weight = getPassengersTotalWeight(source)
	local veh_carried_weight = exports['item-system']:getCarriedWeight(source)
	local extra_weight = passenger_weight + veh_carried_weight
	
	outputChatBox("extra_weight = "..extra_weight)
	
	-- get normal handling.
	local handling = getElementData(source, 'handling') 
	if not handling then
		handling = getVehicleHandling(source)
		exports.anticheat:setEld(source, 'handling', handling ) -- don't lose it.
	end

	local veh_max_speed = handling['maxVelocity']
	local veh_mass = handling['mass']
	outputChatBox("veh_max_speed = "..veh_max_speed)
	outputChatBox("veh_mass = "..veh_mass)

	-- increase vehicle weight realistically.
	local new_mass = handling['mass']+passenger_weight+veh_carried_weight
	setVehicleHandling(source, 'mass', new_mass)

	-- 
	local weight_ratio = new_mass/handling['mass']
	outputChatBox("weight_ratio = "..weight_ratio)
	--setVehicleHandling(source, 'suspensionFrontRearBias', handling.suspensionFrontRearBias)
	--setVehicleHandling(source, 'maxVelocity', handling['maxVelocity']/(weight_ratio*2))
	outputChatBox("maxVelocity = "..handling['maxVelocity'])

end

--addEventHandler ( "onVehicleEnter", getRootElement(), setVehicleWeight ) --NOT being used yet