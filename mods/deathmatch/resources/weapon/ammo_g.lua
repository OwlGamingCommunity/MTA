--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local ammunition = {
	[1] = {
		id = 1,
		cartridge = '9mm',
		rounds = 25,
		bullet_weight = 0.00745187465, -- kilograms
		bullet_style = 'Flex Tip Expanding (FTX)',
		application = 'Self Defense',
		weapons = { 
			22, -- Pistol
			23, -- Silenced
			28, -- Uzi
			29, -- MP5
			32, -- Tec-9
		}
	},
	[2] = {
		id = 2,
		cartridge = '7.62mm',
		rounds = 30,
		bullet_weight = 0.00965503759, -- kilograms
		bullet_style = 'Full Metal Jacket (FMJ)',
		application = 'Practice, Target, Training',
		weapons = { 
			30, -- AK-47
			33, -- Country Rifle
			34, -- Sniper Rifle
			38, -- Minigun
		}
	},
	[3] = {
		id = 3,
		cartridge = '5.56mm',
		rounds = 50,
		bullet_weight = 0.00401753242, -- kilograms
		bullet_style = 'Full Metal Jacket (FMJ)',
		application = 'Law Enforcement, Plinking',
		weapons = { 
			31, -- M4
		}
	},
	[4] = {
		id = 4,
		cartridge = '.45 ACP',
		rounds = 20,
		bullet_weight = 0.0119877984, -- kilograms
		bullet_style = 'Full Metal Jacket (FMJ), Metal Case (MC)',
		application = 'Target, Competition, Training',
		weapons = { 
			24, -- Deagle
		}
	},
	[5] = {
		id = 5,
		cartridge = '12 Gauge',
		rounds = 25,
		bullet_weight = 0.0318932135, -- kilograms
		bullet_style = 'Factory-style',
		application = 'Target, Hunting',
		weapons = { 
			25, -- Shotgun
			26, -- Saw-off
			27, -- Spaz
		}
	},
	[6] = {
		id = 6,
		cartridge = 'High Explosive Warhead',
		rounds = 2,
		bullet_weight = 1.558, -- kilograms
		bullet_style = 'Factory-style',
		application = 'Destruction',
		weapons = { 
			35, -- Rocket Launcher
			36, -- Heat-Seeking RPG
		}
	}
}

--Faction Drop
local weaponList = {
--	ItemID, ItemValue, ItemName
	{115, 22, "Colt 45"},
	{115, 24, "Deagle"},
	{115, 23, "Silenced"},
	{115, 25, "Shotgun"},
	{115, 32, "Tec-9"},
	{115, 28, "Uzi"},
	{115, 29, "MP5"},
	{115, 30, "AK-47"},
	{115, 31, "M4A1"},
	{115, 18, "Molotov"},
	{115, 3, "Nightstick"},
	{115, 8, "Katana"},
	{115, 9, "Chainsaw"},
	{115, 1, "Brass Knuckles"},
	{115, 34, "Sniper"},
	{115, 26, "Sawed-off"},
	{115, 33, "Country Rifle"},
	{115, 27, "Combat Shotgun"},
	{115, 35, "Rocket Launcher"},
	{116, 35, "Ammo for Rocket Launcher"},
}

for pack_id, pack in ipairs( ammunition ) do
	table.insert( weaponList, {116, pack_id, pack.cartridge } )
end

function getFactionNpcItems()
	return weaponList
end

function getAmmo(id)
	return id and ammunition[id] or ammunition
end

function getAmmoForWeapon( weap_id )
	for ammo_id, ammo in pairs( ammunition ) do
		for _, weap_id_ in pairs( ammo.weapons ) do
			if weap_id_ == weap_id then
				return ammo, ammo_id
			end
		end
	end
end

function formatWeaponNames(weapons)
	local buffer = ''
	for _, weap_id in pairs(weapons) do
		buffer = buffer..getWeaponNameFromID(weap_id)..', '
	end
	return string.sub(buffer, 1, string.len(buffer)-2)
end