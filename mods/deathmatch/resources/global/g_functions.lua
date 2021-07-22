--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

function explode(div,str)
	if (div=='') then return false end
	local pos,arr = 0,{}
	-- for each divider found
	for st,sp in function() return string.find(str,div,pos,true) end do
		table.insert(arr,string.sub(str,pos,st-1)) -- Attach chars left of current divider
		pos = sp + 1 -- Jump past current divider
	end
	table.insert(arr,string.sub(str,pos)) -- Attach chars right of last divider
	return arr
end

function implode(div, arr)
	return table.concat(arr,div)
end


function getUrlFromString(message)
	if not message or string.len(message) < 1 then
		return false
	end

	for _, v in ipairs(split(message, ' ')) do
		if v:sub(1, 7) == 'http://' or v:sub(1, 8) == 'https://' or v:sub(1, 4) == 'www.' or v:sub(1, 8) == 'owl.pm' then
			return v
		end
	end
	
	return false
end

function getRandomSkin()
	while true do 
		local ran = math.random(1,288)
		local ped = createPed(ran, 0, 0, 3)
		if ped then
			destroyElement(ped)
			return ran
		end
	end
end

function round(val, decimal)
  if (decimal) then
    return math.floor( (val * 10^decimal) + 0.5) / (10^decimal)
  else
    return math.floor(val+0.5)
  end
end

function formatWeight(kg)
	kg = tonumber(kg)
	if kg < 1000 then
		return round(kg,2).." kg(s)"
	else 
		return round(kg/1000,2).." tons"
	end
end

function formatLength(meters)
	meters = tonumber(meters) or 0
	if meters >=1000 then
		return round(meters/1000, 2).." km(s)"
	else
		return round(meters,2).." meter(s)"
	end
end

local alphanumberics = {
	['1'] = true,
	['2'] = true,
	['3'] = true,
	['4'] = true,
	['5'] = true,
	['6'] = true,
	['7'] = true,
	['8'] = true,
	['9'] = true,
	['0'] = true,
	['q'] = true,
	['w'] = true,
	['e'] = true,
	['r'] = true,
	['t'] = true,
	['y'] = true,
	['u'] = true,
	['i'] = true,
	['o'] = true,
	['p'] = true,
	['a'] = true,
	['s'] = true,
	['d'] = true,
	['f'] = true,
	['g'] = true,
	['h'] = true,
	['j'] = true,
	['k'] = true,
	['l'] = true,
	['z'] = true,
	['x'] = true,
	['c'] = true,
	['v'] = true,
	['b'] = true,
	['n'] = true,
	['m'] = true,
	['-'] = true,
	['_'] = true,
	['.'] = true,
}

function hasSpecialChars(str)
	for i = 1, string.len(str) do
		local char = string.lower(string.sub(str, i, i))
		if not alphanumberics[char] then
			return true
		end
	end
	return false
end

function isEmail(str)
	if not str or str == "" or string.len(str) < 1 then
		return false, "Email must not be empty."
	end

	local _,nAt = str:gsub('@','@') -- Counts the number of '@' symbol
	
	if nAt ~=1 then 
		return false, "Email must contain one and only one '@'."
	end

	if str:len() > 100 then
		return false, "Email must not be longer than 100 characters."
	end

	local text = exports.global:explode('@', str) 
	local localPart = text[1]
	local domainPart = text[2]
	if not localPart or not domainPart then 
		return false, "Email local or domain part is missing." 
	end

	if hasSpecialChars(localPart) then
		return false, "Email local part is invalid." 
	end

	if hasSpecialChars(domainPart) then
		return false, "Email domain part is invalid." 
	end

	return true, "Email address is valid!"
end

function getPedWeapons(ped,from_slot, to_slot)
	from_slot = tonumber(from_slot) or 2
	to_slot = tonumber(to_slot) or 9
	local playerWeapons = {}
	if ped and isElement(ped) and getElementType(ped) == "ped" or getElementType(ped) == "player" then
		for i=from_slot,to_slot do
			local wep = getPedWeapon(ped,i)
			if wep and wep ~= 0 then
				table.insert(playerWeapons,wep)
			end
		end
	else
		return false
	end
	return playerWeapons
end

function countTable(table)
	local count = 0
	for i, k in pairs(table) do
		count = count + 1
	end
	return count
end

function mergeTables(table1, table2)
    if not table1 or not table2 then return end
    if type(table1) ~= "table" or type(table2) ~= "table" then return end
   
    local mergedTable = {}
    for key, value in ipairs(table1) do
        table.insert(mergedTable, value)
    end
    for key, value in ipairs(table2) do
        table.insert(mergedTable, value)
    end
 
    if #mergedTable > 0 then
        return mergedTable
    end
end