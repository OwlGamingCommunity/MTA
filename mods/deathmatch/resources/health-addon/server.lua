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
addEvent('disp_diagnose', true)
local fID = 4
local show = 0
local gsub = string.gsub
local len = string.len
local sub = string.sub
local random = math.random
local floor = math.floor
local mysql = exports.mysql
local JSON = toJSON({head="0",torso="0",abdomen="0",l_arm="0", r_arm= "0",l_hand= "0",r_hand= "0",groin="0",l_leg="0",r_leg="0",l_foot="0",r_foot="0"})

local body_region ={
	high = {'head', 'torso'},
	middle = {'abdomen', 'l_arm', 'r_arm', 'l_hand', 'r_hand'},
	low = {"groin", "l_leg", "r_leg", "l_foot", "r_foot"}
}

addCommandHandler( "injure", 
	function(ply, cmd, target, wType, bPart, dmg)
		local body_type = nil
		if (not target)or(not dmg) or (not bPart) or (not wType) or (not dmg) then
			outputChatBox("SYNTAX: /"..cmd.." <Playername/ID> <sharp/blunt> <high/mid/low or bodypart> <light/heavy>", ply, 255, 200, 0)
			return
		end
		if target then
			local targetply = exports.global:findPlayerByPartialNick(ply, target)
			if ( targetply ) then
				local px, py = getElementPosition(ply)
				local tx, ty = getElementPosition(targetply)
				local dist = getDistanceBetweenPoints2D(tx, ty, px, py)
				if dist < 7 then
					
					if wType == 'blunt' or wType =='sharp' then
						if bPart == 'high' then
							local num =  random(1, #body_region['high'])
							body_type = body_region.high[num]
						elseif bPart == 'middle' or bPart == 'mid' then
							local num =  random(1, #body_region['middle'])
							body_type = body_region.middle[num]
						elseif bPart == 'low' then
							local num =  random(1, #body_region['low'])
							body_type = body_region.low[num]
						else
							for i=2, #BODY do
								if bPart == BODY[i] then
									body_type = bPart
								end
							end
							if (not body_type) then
								outputChatBox("[BODY_TYPES]", ply, 255,0,0)
								for i=2, #BODY do
									outputChatBox("   "..BODY[i], ply, 255,200,0)
								end
								return
							end
						end
						
						if dmg=='light' or dmg == 'heavy' then
							--send data to targetplayer
							triggerClientEvent(targetply, 'send_damage_data', targetply, getPlayerName(ply), wType, body_type, dmg )
						else
							outputChatBox("SYNTAX: /"..cmd.." <Playername/ID> <sharp/blunt> <high/mid/low or bodypart> <light/heavy>", ply, 255, 200, 0)
							return
						end
					else
						outputChatBox("SYNTAX: /"..cmd.." <Playername/ID> <sharp/blunt> <high/mid/low or bodypart> <light/heavy>", ply, 255, 200, 0)
					end
				else
					outputChatBox('You are too far away!', ply, 255, 150, 0)
					return
				end
			end
		end
	end
)

function target_response(num, ply, bPart, wType, dmg)
	local ch_perc = 100
	local ply = getPlayerFromName(ply)
	local chance = 0
	if num == 0 then
		outputChatBox('Player has declined the damage output', ply, 255, 220, 0)
		return
	elseif num == 1 then
		--Get the values
		local charID=getElementData(source, 'dbid')
		if charID then
			local newstring_ext = flag_guarantee(wType)
			local newstring_int = flag_guarantee(wType)
			local get_body_type = list_body_injury[tostring(bType)]
			local guaranteed = flag_guarantee(wType)
			-- Create chances
			local multiplier = 0.4
			while ch_perc > 20 do
				if dmg == 'light' then
					chance = random(30,60)
				elseif dmg == 'heavy' then
					chance = random(25,50)
				end
				if (ch_perc <= chance) then
					break
				else --add another condition
					local dice = random(1,10)
					local result = flag_body_damage(bPart, wType, dmg, dice)
					if result then --check if not already in current string
						local length = 0
						if dice <= 5 then
							length = len(newstring_ext)
							if length > 0 then
								for i=0, length do
									local char = sub(newstring_ext, i, i)
									if char ~= result then
										if i==length then
											newstring_ext = newstring_ext..result
										end
									else
										break
									end
								end
							else
								newstring_ext= newstring_ext..result
							end
						elseif dice >= 6 then
							length = len(newstring_int)
							if length > 0 then
								for i=0, length do
									local char = sub(newstring_int, i, i)
									if char ~= result then
										if i==length then
											newstring_int = newstring_int..result
										end
									else
										break
									end
								end
							else
								newstring_int= newstring_int..result
							end
						end
					end
					ch_perc = floor(ch_perc*multiplier)
				end
			end
			--update the database
			update_json(charID, bPart, newstring_ext, newstring_int)
		end
	end
end
addEvent('send_response_data', true)
addEventHandler('send_response_data', getRootElement(), target_response)

function update_json(dbid, bPart, ext, int)
	local query = mysql:query_fetch_assoc("SELECT ext_diagnose, int_diagnose FROM health_diagnose WHERE uniqueID="..mysql:escape_string(dbid).." LIMIT 1;")
	if (not query) then
		local result = mysql:query_free("INSERT INTO health_diagnose (uniqueID, int_diagnose, ext_diagnose) VALUES ('"..mysql:escape_string(dbid).."','"..JSON.."','"..JSON.."');")
		mysql:free_result(result)
		update_json(dbid, bPart, ext, int)
		return
	end
	if query then
		local int_dia = fromJSON(query['int_diagnose'])
		if int ~= "" then
			for k, v in pairs(int_dia) do
				if k == bPart then
					local line = v
					local line_length = len(line)
					if line_length ~= 0 and line ~= "0" or line ~= "0" then
						for i=1, line_length do
							local dbSubString = sub(int, i, i)
							local char = flag_string_add(line, dbSubString)
							if char then
								line = line..dbSubString
							end
						end
					else
						line = int
					end
					--now fill the table with the new line
					int_dia[bPart] = line
					break
				end
			end
			--convert back to JSON
		end
		int_dia = toJSON(int_dia)
		
		local ext_dia = fromJSON(query['ext_diagnose'])
		if ext ~= "" then
			for k, v in pairs(ext_dia) do
				if k == bPart then
					local line = v
					local line_length = len(line)
					if line_length ~= 0 and line ~= "0" or line ~= "0" then
						for i=1, line_length do
							local dbSubString = sub(ext, i, i)
							local char = flag_string_add(line, dbSubString)
							if char then
								line = line..dbSubString
							end
						end
					else
						line = ext
					end
					--now fill the table with the new line
					ext_dia[bPart] = line
					break
				end
			end
			--convert back to JSON
		end
		ext_dia = toJSON(ext_dia)
		
		--we converted all the strings, now we update the table
		mysql:query_free("UPDATE health_diagnose SET int_diagnose='"..int_dia.."', ext_diagnose='"..ext_dia.."' WHERE uniqueID="..dbid.." LIMIT 1;")
	end
	mysql:free_result(query)
end

local targetply
addCommandHandler('diagnose',
	function(ply, cmd, target)
		if target then
			targetply = exports.global:findPlayerByPartialNick(ply, target)
		end
		local charID = ""
		if targetply and targetply ~= ply then
			local px, py = getElementPosition(ply)
			local tx, ty = getElementPosition(targetply)
			local dist = getDistanceBetweenPoints2D(tx, ty, px, py)
			if dist < 7 then
				charID = getElementData(targetply, 'dbid')
				triggerClientEvent(targetply, 'diag_request', targetply, ply, charID)
				return
			else
				outputChatBox('You are too far away!', ply, 255, 150, 0)
				return
			end
		else
			charID = getElementData(ply, 'dbid')
			disp_diag_window(ply, charID)
		end
	end
)

function disp_diag_window(ply, charID, target, res)
	if res == 1 then
		outputChatBox(gsub(getPlayerName(ply), "_", " ") .. " is diagnosing you.", target, 255, 200, 0)
	end
	if charID then
		if charID == 'close' then
			triggerClientEvent(ply, 'close_diag_window', ply)
			return
		end
		local query = mysql:query_fetch_assoc("SELECT ext_diagnose, int_diagnose FROM health_diagnose WHERE uniqueID="..mysql:escape_string(charID).." LIMIT 1;")
		if query then
			local ext = fromJSON(query['ext_diagnose'])
			local int = fromJSON(query['int_diagnose'])
			triggerClientEvent(ply, 'show_diagnose_window', ply, int, ext, target)
		else
			triggerClientEvent(ply, 'show_diagnose_window', ply)
		end
		mysql:free_result(query)
	else
		outputChatBox(gsub(getPlayerName(target), "_", " ").." has refused diagnosis.", ply, 255, 200, 0)
	end
end
addEventHandler('disp_diagnose', getRootElement(), disp_diag_window)

--treatment handlers
--TODO: handle all injuries individually
function treat_single_bodypart(dbid, part) --injury
	--treatment 
	if dbid then
		local query = mysql:query_fetch_assoc("SELECT ext_diagnose, int_diagnose FROM health_diagnose WHERE uniqueID="..mysql:escape_string(dbid).." LIMIT 1;")
		if query then
			local ext = fromJSON(query['ext_diagnose'])
			local int = fromJSON(query['int_diagnose'])
			--for now, just wipe the data within and set the value back to 0
			if (ext[part]) then
				ext[part] = "0"
			end
			if int[part] then
				int[part]="0"
			end
			mysql:query_free("UPDATE health_diagnose SET int_diagnose='"..toJSON(int).."', ext_diagnose='"..toJSON(ext).."' WHERE uniqueID="..dbid.." LIMIT 1;")
		end
		mysql:free_result(query)
	end
end
addEvent('init_treat_bodypart', true)
addEventHandler('init_treat_bodypart', getRootElement(), treat_single_bodypart)

function treat_all(dbid)
	if dbid then
		local query = mysql:query_fetch_assoc('SELECT * FROM health_diagnose WHERE uniqueID='..dbid.." LIMIT 1;")
		if query then
			local result_ext_table = fromJSON(query['ext_diagnose'])
			local result_int_table = fromJSON(query['int_diagnose'])
			for k, v in pairs(result_ext_table) do
				result_ext_table[k] = "0"
			end
			for k, v in pairs(result_int_table) do
				result_int_table[k] = "0"
			end
			mysql:query_free("UPDATE health_diagnose SET int_diagnose='"..toJSON(result_int_table).."', ext_diagnose='"..toJSON(result_ext_table).."' WHERE uniqueID="..dbid.." LIMIT 1;")
		end
		mysql:free_result(query)
	end
end
addEvent('init_treat_all', true)
addEventHandler('init_treat_all', getRootElement(), treat_all)

addCommandHandler('treat',
	function(ply, cmd, target, part)
		local targetply, charID, faction, fName, fTeam, ext, int
		if (not target) then
			outputChatBox('Syntax: /'..cmd.." <playername/id> <bodypart or all>", ply, 255,200,0)
			return
		else
			if target then
				targetply = exports.global:findPlayerByPartialNick(ply, target)
				if targetply then
					charID = getElementData(targetply, 'dbid')
					ext, int = getInfo(charID)
					if part and part ~= 'all' then
						local result = nil
						for i=1, #BODY do
							if (BODY[i] == part) then
								result = 1
								break
							end
						end
						if result ~= 1 then
							outputChatBox("#FF0000Invalid Bodypart!", ply, 255, 255, 255, true)
							outputChatBox("#EDAD00BODYPARTS: head, torso, abdomen, l_arm, r_arm, l_hand, r_hand, groin, l_leg, r_leg, l_foot, r_foot", ply, 255, 255, 255, true)
							return
						end
					end

					if exports.integration:isPlayerTrialAdmin(ply) or exports.integration:isPlayerSupporter(ply) then
						if (part == nil) or part == 'all' then
							treat_all(charID)
						elseif part then
							treat_single_bodypart(charID, part)
							outputChatBox('You have treated '..gsub(getPlayerName(targetply), "_", " ")..' from their injuries on bodypart: '..part..'.', ply, 255, 220, 0)
							outputChatBox('Admin '..gsub(getPlayerName(ply), "_", " ")..' has cleared you from your injuries on bodypart: '..part..'.', targetply, 255, 220, 0)
							return
						end
						outputChatBox('You have treated '..gsub(getPlayerName(targetply), "_", " ")..' from their injuries.', ply, 255, 220, 0)
						outputChatBox('Admin '..gsub(getPlayerName(ply), "_", " ")..' has cleared you from your injuries.', targetply, 255, 220, 0)
						return
					end

					if targetply == ply then
						if getElementDimension(ply) == 180 then
							triggerClientEvent(targetply, 'req_treat_confirm', targetply, ply, part, int, ext)
							return
						else	
							outputChatBox("You have to be in the hospital to use this command", ply, 255,0,0)
							return
						end
					else
						outputChatBox('You are not part of the LSES, you cannot perform any treatments', ply, 255, 0, 0)
					end

					if exports.factions:isPlayerInFaction(ply, 2) then
						outputChatBox('You are trying to treat '..gsub(getPlayerName(targetply), "_", " ")..' from their injuries.', ply, 255, 220, 0)
						triggerClientEvent(targetply, 'req_treat_confirm', targetply, ply, part, int, ext)
					end
				end
			end
		end
	end
)

addEvent('init_treat_response', true)
addEventHandler('init_treat_response', getRootElement(), 
	function(charID, part, ply, name, money)
		if charID == "no" then
			outputChatBox(name.." has refused the treatment.", ply, 255, 200, 0)
			return
		else
			local money = exports.global:hasMoney(ply, money)
			if money then
				if (part == nil) or part == 'all' then
					treat_all(charID)
				elseif part then
					treat_single_bodypart(charID, part)
				end
				outputChatBox("Patient "..gsub(name, "_", " ").. " has accepted the treatment. $"..exports.global:formatMoney(money).." has been deducted from your wallet.", ply, 255, 200, 0)
				return
			else
				outputChatBox("You cannot afford the supplies: $"..exports.global:formatMoney(money).." needed to perform this treatment.", ply, 255, 200, 0)
				return
			end
		end
	end
)

function getInfo(charID)
	if charID then
		local query = mysql:query_fetch_assoc('SELECT * FROM health_diagnose WHERE uniqueID='..charID..";")
		if query then
			local result_ext_table = fromJSON(query['ext_diagnose'])
			local result_int_table = fromJSON(query['int_diagnose'])
			mysql:free_result(query)
			return result_ext_table, result_int_table
		end
		mysql:free_result(query)
	end
end

--this is mainly for ped functionality
addEvent('send_info', true)
addEventHandler('send_info', getRootElement(),
	function(charID)
		ext, int = getInfo(charID)
		triggerClientEvent(source, 'print_info', source, ext, int)
	end
)

addEvent('ped_treat', true)
addEventHandler('ped_treat', getRootElement(),
	function (ply, dbid, money)
		if exports.global:hasMoney(ply, money) then
			treat_all(dbid)
			exports.global:takeMoney(ply, money)
			outputChatBox('you have been treated and paid #00DA10$'..exports.global:formatMoney(money), ply, 255,255,255, true)
		else
			outputChatBox('#FF0000You do not have the money to afford treatment', ply, 255, 255, 255, true)
		end
	end
)