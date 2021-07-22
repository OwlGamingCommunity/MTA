
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
local len = string.len
local sub = string.sub
local gsub = string.gsub
BODY = _G['BODY']
x, y = guiGetScreenSize()
local sw, sh = 530, 600
local injuries = {}
local col = {}
local gui = {	tab = {},	grid = {},	button = {}, memo={}	}
local showing = 0

local legend = [[
Cleaning request - Wound dresser needed to bathe off contaminants.
Surgery required - Surgeon needed to excise necrotic tissue or repair organ damage
Medicine request - Medicine required.
Suture request - Suturer needed to repair cuts, wounds and nerve damage
Setting request - Bone doctor needed to set the subject's fractured bones
Dressing request - Wound dresser needed to top off the medical procedure using cloth bandages
Immobilization request - Cast (wound dresser) or splint (bone doctor) needed to stabilize a repaired fracture
Crutch required - Crutch needed for the subject to walk

Heavy bleeding - Subject is quickly losing blood through many wounds or torn arteries. This is an emergency.
Bleeding - Subject is losing blood through a wound. 
Severe Blood Loss - Subject is Pale. Caused by massive blood loss, typically from a severed limb. 
Faint - Subject is Faint. Caused by moderate blood loss from wounds or necrosis.
Paralyzed - Subject is completely paralyzed. Common effect of upper spinal injury. Death by suffocation is imminent
Partially paralyzed - One or more limbs unusable due to severed nerves
Sluggish - Characteristic of weak or lessening paralysis
Completely numb - Symptom of syndromes or sensory nerve damage. Eliminates pain sensation in affected areas and severely hampers motor ability. Protracted syndrome effects may cause permanent damage.
Partially numb - Symptom of syndromes or sensory nerve damage. Further reduces pain in affected areas and hampers fine motor ability.
Slightly numb - Symptom of syndromes or sensory nerve damage. Reduces pain in affected areas.

Serious fever -Typical warning sign of more dangerous syndromes.
Moderate fever - Typical warning sign of more dangerous syndromes.
Minor fever - Relatively harmless.
Dizzy - Common symptom of snake bites. Chance for subject to stumble in a random direction instead of performing an action, depending on severity.
Extreme pain - Bone fracture or a staggering number of surface wounds. Subject can't take any more and falls unconscious, giving into pain. 
Moderate pain - Serious, recent damage to muscle and/or fat. Interferes with actions.
Slight pain - Subject has suffered minor cuts or bruises.
Stunned - The wind has been knocked out of the subject by an unexpected fall, impact, cave-in or takedown.
Over-exerted - Last stage of tiredness, caused by for example drawn-out combat
Exhausted - Second stage of tiredness. Reduces speed.
Tired - Caused by executing many  actions in short time

Lost - What you lose part of, or all of a part of the body entirely 
Impaired - When Damage is severe enough to impair the use of a limb
Major artery torn - Heart injury or torn throat. This is invariably fatal.
Artery torn - Subject will probably suffer bleeding of some type. This can be an emergency.
Overlapping fracture - A widely displaced limb fracture
Compound fracture - A fracture that has also broken a tissue directly subordinate to the bone, such as fingernails or spinal nerves. Tissues torn by bone fragments jammed through them also count.
Torn tendon - Sinew damage. Limb is disabled. Cannot be set, heals on its own.
Tendon strain - Sinew damage.
Tendon bruise - Sinew damage. 
Torn muscle - Muscle damage. 
Muscle strain - Muscle damage. 
Muscle bruise - Muscle damage.
Broken tissue - Irrepairable damage to tissue
]]

addEvent("show_diagnose_window", true)
addEventHandler("show_diagnose_window", getLocalPlayer(),
	function(int_tbl,ext_tbl, patient)
		local name = getPlayerName(localPlayer)
		if patient ~= nil then
			name = getPlayerName(patient)
		end
		if gui['window'] then 
			closeWindow()
			return
		end			
			gui['window'] = guiCreateWindow( (x/2)-(sw/2), (y/2)-(sh/2), sw, sh-80, "Showing patient: "..gsub(name, "_", " "), false)
			gui.button[1] = guiCreateButton( sw-60, sh-105, 50, 25, "Close", false, gui['window'])



			gui['w_tab'] = guiCreateTabPanel (0, 25, sw-10, sh-140, false, gui['window'])
			gui.tab[1] = guiCreateTab('External', gui['w_tab'])
			gui.tab[2] = guiCreateTab('Internal', gui['w_tab'])
			--gui.tab[3] = guiCreateTab('Status', gui['w_tab'])
			gui.tab[4] = guiCreateTab('Legend', gui['w_tab'])
			--addEventHandler('onClientGUIClick', gui['w_tab'], showtab)
			gui.memo = guiCreateMemo(0, 0, sw-10, sh-140, legend, false, gui.tab[4])
			
			if (not gui.grid[1]) then
			gui.grid[1]= guiCreateGridList(0, 0, sw-10, sh-160, false, gui.tab[1])
			gui.grid[2] = guiCreateGridList(0, 0, sw-10, sh-160, false, gui.tab[2])
			
			--colums
			for k, v in ipairs(BODY) do
				col[k] = guiGridListAddColumn(gui.grid[1], tostring(BODY[k]), 0.05)
				col[k] = guiGridListAddColumn(gui.grid[2], tostring(BODY[k]), 0.05)
			end
			--I had some old code before where I explained cool stuff about flags
			--I came across something that will make it waay simpler (check the old file and you'll see what I mean)
			gui_fill('EXT_LIST_MAIN', 'injuries', gui.grid[1])
			gui_fill('EXT_LIST_MAIN', 'symptoms', gui.grid[1])
			gui_fill('INT_LIST_MAIN', 'injuries', gui.grid[2])
			gui_fill('INT_LIST_MAIN', 'symptoms', gui.grid[2])

			guiGridListAutoSizeColumn(gui.grid[1], col[1])
			guiGridListAutoSizeColumn(gui.grid[2], col[1])
			showCursor(true)
		end
		
		if ext_tbl then
			fill_grid(ext_tbl, gui.grid[1])
		end
		
		if int_tbl then
			fill_grid(int_tbl, gui.grid[2])
		end
		addEventHandler('onClientGUIClick', gui.button[1], 
			function (button, state)
				if source == gui.button[1] then
					closeWindow()
				end
			end
			)
	end
)



function gui_fill(tbl, val, grid)
	local list = tbl_index_getValue(tbl, val)
	if val == 'symptoms' then
		val = 'Symptoms'
	elseif val == 'injuries' then
		cal = 'Injuries'
	end
	
	if list then
		local row = guiGridListAddRow(grid)
		guiGridListSetItemText(grid, row, 1, val, false, false)
		guiGridListSetItemColor(grid, row, 1, 255, 0, 0)
		local length = len(list)
		for i=1, length do
			row = guiGridListAddRow(grid)
			local char = sub(list, i,i)
			local value = tbl_index_getValue('list_flags', char)
			if value then
				guiGridListSetItemText(grid, row, 1, '- '..value[1].."-", false, false)
				guiGridListSetItemData(grid, row, 1, char, false, false)
			end
		end
	end
end

function fill_grid(tbl, grid)
	local count = guiGridListGetRowCount(grid)
	local flag = ""
	for k, v in pairs(tbl) do
		if v ~= "0" then
			--breakdown the string value into seperate characters
			local length = len(v)
			for i=1, length do
				local char = sub(v, i, i)
				if char then
					--you got the character, get the right value
					local val = tbl_index_getValue('list_flags', char)
					--now look for the matching gui element with the same value
					if val then
						for list=1, count do
							local gridVal = guiGridListGetItemData(grid, list, 1)
							if gridVal == char then
								update_gridlist(grid, k, list)
								break
							end
						end
					end
				end
			end
		end
	end
end

function update_gridlist(grid, part, row)
	for i=2, #BODY do
		if BODY[i] == part then
			guiGridListSetItemText(grid, row, i, '-X-', false, false)
			break
		end
	end
end

local pl_name, dmg_bpart, dmg_wtype, dmg_type= nil
addEvent('send_damage_data', true)
function player_injury_request(name, wType, bPart, dmg)
	pl_name = name
	name = string.gsub(name, "_", " ")
	dmg_bpart = bPart
	dmg_wtype = wType
	dmg_type = dmg
	if bPart then
		if bPart=='l_arm' then
			bPart = "left arm"
		elseif bPart=='r_arm' then
			bPart = "right arm"
		elseif bPart=='l_hand' then
			bPart = "left hand"
		elseif bPart=='r_hand' then
			bPart = "right hand"
		elseif bPart=='l_leg' then
			bPart = "left leg"
		elseif bPart=='r_leg' then
			bPart = "right leg"
		elseif bPart=='l_foot' then
			bPart = "left foot"
		elseif bPart=='r_foot' then
			bPart = "right foot"
		end
	end
	outputChatBox("Player "..name.." wants to apply "..dmg.." damage with a "..wType.." object to your "..bPart..". To reply type /irespond (y/n) or (yes/no)" )	
end
addEventHandler('send_damage_data', getLocalPlayer(), player_injury_request)

addEvent('diag_request', true)
local diag_req, diag_ply, diag_dbid = nil
addEventHandler('diag_request', getLocalPlayer(), 
	function (ply, dbid)
		diag_ply = ply
		if showing == 0 then
			diag_dbid = dbid
			diag_req = true
			outputChatBox(gsub(getPlayerName(ply), "_", " ").." has requested to diagnose you. /irespond (y/n) or (yes/no)", 255, 200, 0)
		else
			triggerServerEvent('disp_diagnose', getLocalPlayer(), diag_ply, 'close')
			diag_req, diag_ply, diag_dbid = nil
			showing = 0
		end
	end
)

addCommandHandler('irespond',
	function(cmd, res)
		if diag_req then
			if res == 'y' or res == 'yes' then
				showing  = 1
				triggerServerEvent('disp_diagnose', getLocalPlayer(), diag_ply, diag_dbid,localPlayer, showing)
				diag_req, diag_ply, diag_dbid = nil, nil, nil
				return
			elseif res == 'n' or res == 'no' then
				triggerServerEvent('disp_diagnose', getLocalPlayer(), diag_ply, nil, localPlayer)
				showing = 0
				return
			end
		end
	
		if (not dmg_bpart) or (not dmg_wtype) or (not dmg_type) then
			return
		end
		if (not res) then
			outputChatBox ("SYNTAX: /"..cmd.." (y/n) or (yes/no)", 255, 200, 0)
		end
		if (res == 'y') or  (res == 'yes') then
			outputChatBox ("You have accepted the injury.", 255, 200, 0)
			triggerServerEvent('send_response_data', getLocalPlayer(), 1, pl_name, dmg_bpart, dmg_wtype, dmg_type)
		elseif (res == 'n') or (res =='no') then
			outputChatBox ("You have declined the injury.", 255, 200, 0)
			triggerServerEvent('send_response_data', getLocalPlayer(), 0, pl_name, dmg_bpart, dmg_wtype, dmg_type)
		else
			outputChatBox ("SYNTAX: /"..cmd.." (y/n) or (yes/no)", 255, 200, 0)
		end
		dmg_bpart, dmg_wtype, dmg_type= nil, nil, nil
	end
)

function closeWindow()
	showing = 0
	destroyElement(gui['window'])
	gui = {	tab = {},	grid = {},	button = {}	}
	showCursor(false)
end
addEvent('close_diag_window', true)
addEventHandler('close_diag_window', getLocalPlayer(), closeWindow)


local treatply, treatpart
addEvent('req_treat_confirm', true)
addEventHandler('req_treat_confirm', getLocalPlayer(),
	function(ply, part, int, ext)
		treatply = ply
		treatpart = part
		money = 0
		local charID = getElementData(localPlayer, 'dbid')
		--get the bodypart, flags and return money value
		if part == 'all' or part == "" or part == nil then
			treatpart = 'all'
			for i=2, #BODY do
				local extramoney = moneyInfo(i, ext, int)
				money = money + extramoney
			end
		else
			money = moneyInfo(part, ext, int)
		end
		outputChatBox("#FFBB00"..gsub(getPlayerName(ply), "_", " ").." is about to treat you.\n#FF0000Type: /treataccept (y/n) or (yes/no)", 255, 255, 255, true)
	end
)

function moneyInfo(part, ext, int)
	local money = 0
	local body = BODY[part]
	if ext[body] and (ext[body] ~= "0") then
		length = len(ext[body])
		for i=1, length do
			char = sub(ext[body], i, i)
			if char then
				result = tbl_index_getValue('list_flags', char)
				if result then
					money = money + result[3]
				end
			end
		end
	end
	if int[body] and (int[body] ~= "0")  then
		length = len(int[body])
		for i=1, length do
			char = sub(int[body], i, i)
			if char then
				result = tbl_index_getValue('list_flags', char)
				if result then
					money = money + result[3]
				end
			end
		end
	end
	return money
end

addCommandHandler('treataccept',
	function(cmd, res)
		if (treatply ~= nil) then
			local charID = getElementData(localPlayer, 'dbid')
			if res == 'y' or res == 'yes' then
				triggerServerEvent('init_treat_response', getLocalPlayer(), charID, treatpart, treatply, getPlayerName(localPlayer), money)
			elseif res == 'n' or res == 'no' then
				triggerServerEvent('init_treat_response', getLocalPlayer(), "no", 0, treatply, name)
			end
			treatply = nil
		end
	end
)