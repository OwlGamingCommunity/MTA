--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

truckerJobVehicleInfo = {
--  Model   (1)Level (2)Capacity
	[440] = {1,700}, -- Rumpo
	[499] = {2,1120}, -- Benson
	[414] = {3,1400}, -- Mule
	[498] = {4,2100}, -- Boxville
	[456] = {5,2800}, -- Yankee
}

level = {
	[1] = 50,
	[2] = 200,
	[3] = 1000,
	[4] = 3200,
}

function getRandomRequiredWeight(model) 
	local cap = truckerJobVehicleInfo[model][2]
	local lowest_cap = truckerJobVehicleInfo[440][2]
	local from_lowest_cap_to_current_cap = math.random(lowest_cap,cap)
	local from_10_to_30_percent = math.random(10,30)/100
	-- 10~30% of the lowest cap to vehicle cap.
	return from_10_to_30_percent*from_lowest_cap_to_current_cap
end

function calculateEarning(player, supplies, veh_hp, distance)
	-- core formula
	local earning = supplies*veh_hp*distance
	
	-- reduce it to something realistic & consider hoursplayed too
	local multifier_min = 750000
	local multifier_max = multifier_min*8
	local multifier_gap = multifier_max-multifier_min

	local effected_hours_range = 1000
	local hoursplayed = math.min(getElementData(player, 'hoursplayed') or 0, effected_hours_range)
	local additional = hoursplayed/effected_hours_range*multifier_gap
	local devider = multifier_min+additional
	earning = math.ceil(earning/devider)

	--Cap at around $500~$700 max
	if earning > 500 then
		earning = 500 + math.random(0,200)
	end

	outputDebugString("[TRUCKER] Calculated earning for "..getPlayerName(player)..": $"..earning..", supplies="..supplies..", distance="..exports.global:formatLength(distance)..", hoursplayed="..hoursplayed.."/"..effected_hours_range.." (Reduced payout by "..exports.global:round(100-(multifier_min/devider*100)).."%, dividers="..devider..")")
	return earning
end


