--[[
    health-addon | An injury system that affects the conditions of a player
    Copyright © 2014 Mittell Buurman (http://prospect-gaming.com)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]
local sub = string.sub
local match = string.match
local len = string.len
local random = math.random

_G["BODY"] = {"", "head", "torso", "abdomen", "l_arm", "r_arm", "l_hand", "r_hand", "groin", "l_leg", "r_leg", "l_foot", "r_foot"}
list_body_injury= {
	--<injury flags> <treatment exclude>
	head =	{"abcdefghijklmnoABCDEFGHIJKMNOPQRSTUVWXYZp", "t"},
	torso = {"abcdefghijklmnoABCDEFGMNOPQRSTUVWXYZp", "tz"},
	abdomen = {"abcdefghijklmnoABCDEFGMNOPQRSTUVWXYZp", "tz"},
	l_arm = {"abcdefghijklmnoABCDEFGMNOPQRSTUVWXYZp", "t"},
	r_arm = {"abcdefghijklmnoABCDEFGMNOPQRSTUVWXYZp", "t"},
	l_hand= {"abcdefghijklmnoABCDEFGMNOPQRSTUVWXYZp", "t"},
	r_hand= {"abcdefghijklmnoABCDEFGMNOPQRSTUVWXYZp", "t"},
	groin= {"abcdehijklmnoABCDEFGMNOPQRSTUVWXYZp", "tz"},
	l_leg= {"abcdefghijklmnoABCDEFGMNOPQRSTUVWXYZp", ""},
	r_leg= {"abcdefghijklmnoABCDEFGMNOPQRSTUVWXYZp", ""},
	l_foot= {"abcdefghijklmnoABCDEFGMNOPQRSTUVWXYZp", ""},
	r_foot= {"abcdefghijklmnoABCDEFGMNOPQRSTUVWXYZp", ""}
}
local flags = "abcdefghijklmnorstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZp"
--GLOBAL INJURIES
_G['list_flags']={
-- <name>, <treatment>
a={"Major swelling", "rsuy", 75},
b={"Minor swelling", "rsuy", 50},
c={"Broken tissue", "rw", 30},
--EXT INJURIES FLAGS
d={"Lost", "rxy", 750},
e={"Impaired", "x", 100},
--INT INJURIES FLAGS
f={"Overlapping fracture", "rxz", 120},
g={"Compound fracture", "rxz", 200},
h={"Torn tendon", "w", 120},
i={"Tendon strain,", "y", 75},
j={"Tendon bruise", "y", 25},
k={"Torn muscle", "w", 270},
l={"Muscle strain", "y", 120},
m={"Muscle bruise", "y", 50},
n={"Artery damage", "w", 320},
o={"Major artery damage", "r", 620},
-- TREATMENT FLAGS
r={"Surgery required", "", 80},
s={"Medicine required", "", 60},
t={"Crutch required", "", 30},
u={"Diagnosis request", "", 25},
v={"Cleaning request", "", 25},
w={"Suture request", "", 70},
x={"Setting request", "", 50},
y={"Dressing request", "", 20},
z={"Immobilization request", "", 90},
--GLOBAL SYMPTOMS FLAGS
A={"Bleeding", "y", 0},
B={"Heavy bleeding", "y", 0},
C={"Severe blood loss", "sy", 0},
D={"Slight pain", "s", 0},
E={"Moderate pain", "s", 0},
F={"Extreme pain", "s", 0},
--EXTERNAL SYMPTOMS FLAGS
G={"Infection", "rs", 40},
H={"Serious fever", "s", 40},
I={"Moderate fever", "s", 30},
J={"Slight fever", "s", 20},
K={"Dizzy", "s", 20},
L={"stunned", "s", 20},
M={"Over exerted", "y", 0},
N={"Exhausted", "y", 10},
O={"Tired", "y", 0},
P={"Faint", "sy", 0},
Q={"Paralysed", "rsz", 30},
R={"Partially paralysed", "rs", 15},
S={"Sluggish", "s", 20},
T={"Completely numb", "r", 15},
U={"partially numb", "r", 10},
V={"slightly numb", "s", 5},

--INTERNAL SYMPTOMS FLAGS
W={"Function lost", "r", 50},
X={"Function impaired", "rz", 30},
Y={"Spilled", "rw", 50},
Z={"Motor nerve damage", "rs", 100},
p={"Sensory nerve damage", "rs", 150}
}

_G['EXT_LIST_MAIN']={
	injuries = "abcde",
	symptoms = "ABCDEFGHIJKLMNOPQRSTUV"
}

_G['INT_LIST_MAIN']={
	injuries = "abcfghijklmno",
	symptoms = "ABCDEFGWXYZp"
}

--BLUNT
BL_GUARANTEE = "aD"
BL_LIGHT= "bAE"
BL_LIGHT_EXT ="KLMOPRSV"
BL_LIGHT_INT ="fgilpEXZ"

BL_HEAVY= "acepAEFZWX"
BL_HEAVY_EXT="FKLNPQT"
BL_HEAVY_INT="ghjm"
--SHARP
SH_GUARANTEE = "cAD"
SH_LIGHT= "E"
SH_LIGHT_INT="hknpGJXZ"
SH_LIGHT_EXT="eIJSV"

SH_HEAVY= "ABGEF"
SH_HEAVY_INT="hknoCWXY"
SH_HEAVY_EXT="deHIPQTU"

function flag_string_add(theString, theChar)
	local length = len(theString)
	for i=1, length do
		local subChar = sub(theString, i, i)
		local check = match(subChar, theChar)
		if check then
			return false
		end
	end
	return theChar
end

function flag_guarantee (weap)
	if weap == 'blunt' then
		return BL_GUARANTEE
	elseif weap == 'sharp' then
		return SH_GUARANTEE
	end
end
function get_weapon_damage(weap, dmg)
	if weap == 'blunt' and dmg == 'light' then
		return BL_LIGHT
	elseif weap == 'blunt' and dmg == 'heavy' then
		return BL_HEAVY
	elseif weap == 'sharp' and dmg == 'light' then
		return SH_LIGHT
	elseif weap == 'sharp' and dmg == 'heavy' then
		return SH_HEAVY
	end
end

function flag_body_damage(body, wpn, dmg, dice)
	local part = list_body_injury[body][1]
	local flag = ""
	
	if wpn == 'blunt' then
		if dmg == 'light' then
			if dice <= 5 then
				flag = BL_LIGHT_EXT
			elseif dice >= 6 then
				flag = BL_LIGHT_INT
			end
		elseif dmg=='heavy' then
			if dice <= 5 then
				flag = BL_HEAVY_EXT
			elseif dice >= 6 then
				flag = BL_HEAVY_INT
			end
		end
	elseif wpn == 'sharp' then
		if dmg == 'light' then
			if dice <= 5 then
				flag = SH_LIGHT_EXT
			elseif dice >= 6 then
				flag = SH_LIGHT_INT
			end
		elseif dmg=='heavy' then
			if dice <= 5 then
				flag = SH_HEAVY_EXT
			elseif dice >= 6 then
				flag = SH_HEAVY_INT
			end
		end
	end
	local length = len(flag)
	local rnd = random(1, length)
	local char = sub(flag, rnd, rnd)
	return char
end

--should we be making better and more generic functional functions?
--Yes ... yes we should

function tbl_index_getValue(name, num)
	if _G[name] then
		if _G[name][num] then
			return _G[name][num]
		else
			outputDebugString("[ERROR]: Specified Index "..num.." not found in table: "..name)
			return false
		end
	else
		outputDebugString("[ERROR]: Table: "..name.." does not exist")
		return false
	end
end

function tbl_getIndex(name, num)
	if _G[name] then
		if num then
			return num
		else
			outputDebugString("[ERROR]: Specified Index "..num.." not found in table: "..name)
			return false
		end
	else
		outputDebugString("[ERROR]: Table: "..name.." does not exist")
		return false
	end
end

--treatment handlers
function get_treatFlags(char)
	if _G['list_flags'][char] then
		return _G['list_flags'][char][2]
	end
end

function list_treatments(char)
	if char then
		local flag = get_treatFlags(char)
		if flag then
			local length = len(flag)
			local cache = {}
			for i=1, length do
				local check = sub(flag, i, i)
				local result = tbl_index_getValue('list_flags', check)
				if result then
					table.insert(cache, flag)
				end
			end
			return cache
		end
	end
end

function cl_getInfo(dbid)
	local int, ext = getInfo(dbid)
	return int, ext
end