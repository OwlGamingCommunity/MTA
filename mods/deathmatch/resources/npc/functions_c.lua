--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

 function isBizOwner(player)
	local intid = getElementDimension(player)
	local possibleInteriors = getElementsByType("interior")
	local isOwner = false
	local interiorName = false
	local interiorBizNote = nil
	local interiorSupplies = 0
	local govOwned = true
	local int_element = nil
	for _, interior in ipairs(possibleInteriors) do
		if intid == getElementData(interior, "dbid") then
			interiorName = getElementData(interior, "name") or ""
			interiorBizNote = getElementData(interior, "business:note") or ""
			local status = getElementData(interior, "status")
			interiorSupplies = status.supplies
			local int_faction = status.faction or 0
            govOwned = status.type == 2
            int_element = interior
			if status.owner == getElementData(player, "dbid") then
				if status.type ~= 2 then
					isOwner = true
				end
			elseif exports.factions:hasMemberPermissionTo(player, int_faction, "manage_interiors") then
				isOwner = true
			end
            break
		end
	end

	return isOwner, interiorName, interiorBizNote, interiorSupplies, govOwned, int_element
end

function receiveServerSettings(settings)
	warningDebtAmount = settings.warningDebtAmount
	limitDebtAmount = settings.limitDebtAmount
	wageRate = settings.wageRate
end
addEvent('npc:receiveServerSettings', true)
addEventHandler('npc:receiveServerSettings', resourceRoot, receiveServerSettings)

function onClientStart()
	triggerServerEvent('npc:requestSettings', localPlayer)
end
addEventHandler('onClientResourceStart', resourceRoot, onClientStart)
