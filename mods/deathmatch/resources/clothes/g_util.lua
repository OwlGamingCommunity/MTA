--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

max_collection_items = 200

function isModerator(player)
	return exports.integration:isPlayerScripter(player)
end

function sortList(list)
	local newList = {}
	for k, v in pairs(list) do
		v.id = tonumber(v.id)
		v.skin = tonumber(v.skin)
		v.price = tonumber(v.price)

		table.insert(newList, v)
	end

	table.sort(newList,
		function(a, b)
			if a.skin == b.skin then
				if a.id == 0 then
					return false
				else
					return a.description < b.description
				end
			else
				return a.skin < b.skin
			end
		end)
	return newList
end

function getSkinBasicInfo(id)
	local gender, race, restricted
	for gender_, categories in pairs(exports.npc:getFittingSkins()) do
		for race_, cate in pairs(categories) do
			for _, skin_id in pairs(cate) do
				if skin_id == id then
					gender = gender_
					race = race_
					restricted = exports.npc:getRestrictedSkins()[id]
					break
				end
			end
		end
	end

	if gender and race then
		return (race == 0 and 'Black' or (race == 1 and 'White' or 'Asian'))..' '..(gender == 0 and 'male' or 'female')..(restricted and ' (Restricted)' or ''), gender, race, restricted
	end
	return ''
end

function getInteriorOwner(player)
	local dbid, theEntrance, theExit, interiorType, interiorElement = exports["interior_system"]:findProperty(player)
	local stt = getElementData(interiorElement, "status")
	for key, value in ipairs(getElementsByType("player")) do
		local id = getElementData(value, "dbid")
		if (id==stt.owner) then
			return stt.owner, value
		end
	end
	return stt.owner, nil -- no player found
end

function getPlayerName(player)
	return exports.global:getPlayerName(player)
end

function getGtaDesigners()
	local designers = {"ARSS", "Base 5", "Binco", "Bobo", "Bobo Dodger Boutique", "Didier Sachs", "Eris", "Exotic Boutique", "Gnocchi", "Heat", "Kevin Clone", "Little Lady",
	"Los Santos Fashions", "Mercury", "Monsiuer Trousers", "Phat Clothing", "ProLaps", "Princess P Fashions", "Ranch", "RRSS", "SEMI", "Soap Dodger Boutique", "Son of a Beach",
	"Sub Urban", "Victim", "Vulgari", "Zapateria", "Zip"}
	return designers[math.random(1,#designers)]
end

function getStatus(clothes)
	if clothes.distribution == 0 then
		return "Hidden"
	elseif clothes.distribution == 1 then
		return "Draft (Private)"
	elseif clothes.distribution == 2 then
		if clothes.mdate and clothes.mdate > 0 and clothes.mdate > exports.datetime:now() then
			return 'Arriving in '..exports.datetime:formatFutureTimeInterval(clothes.mdate)
		else
			return "Personal (Private)"
		end
	elseif clothes.distribution == 3 then
		return "Public"
	elseif clothes.distribution == 4 then
		if clothes.for_sale_until > exports.datetime:now() then
			return "Distributed globally for "..exports.datetime:formatFutureTimeInterval(clothes.for_sale_until)
		else
			return "Distribution expired "..exports.datetime:formatTimeInterval(clothes.for_sale_until).." (Private)"
		end
	elseif clothes.distribution == 5 then
		return "Faction Uniform"
	else
		return "Archived"
	end
end

function isDeletable(clothes)
	return clothes.distribution == 1 or clothes.distribution == 5
end

function canEditPrice(clothes)
	return clothes.distribution ~=3
end

function canEditModel(clothes)
	return clothes.distribution == 1
end

function isForSale(clothes)
	return clothes.distribution == 3 or (clothes.distribution == 4 and clothes.for_sale_until > exports.datetime:now())
end

function canDistribute(clothes)
	if clothes.distribution == 0 then
		return false
	elseif clothes.distribution == 1 then
		return true
	elseif clothes.distribution == 2 then
		return not (clothes.mdate and clothes.mdate>0 and clothes.mdate > exports.datetime:now())
	end
	return false
end

function formatManuDate(clothes)
	if clothes.fmdate then
		return clothes.fmdate
	elseif clothes.mdate and clothes.mdate > 0 then
		return clothes.mdate > exports.datetime:now() and ('Arriving in '..exports.datetime:formatFutureTimeInterval(clothes.mdate)) or exports.datetime:formatTimeInterval(clothes.mdate)
	end
	return 'Never'
end

function canUploadForFaction(player)
	local fid = exports.factions:getCurrentFactionDuty(player)
	if fid then
		local faction = exports.factions:getFactionFromID( fid )
		if faction and getElementData( faction, 'permissions' ).free_custom_skins == 1 and exports.factions:hasMemberPermissionTo(player, fid, "modify_duty_settings") then
			return fid
		end
	end
	return false
end
