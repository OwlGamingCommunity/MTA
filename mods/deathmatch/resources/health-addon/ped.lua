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
local buurman = createPed(276, 1594.3386230469, 1796.7481689453, 2083.376953125)
setElementData(buurman, 'name', 'Corey Byrd', false)
setElementData(buurman, 'talk', 1, false)
setElementRotation(buurman, 0, 0, 90)
setElementFrozen(buurman, true)
setElementDimension(buurman, 180)
setElementInterior(buurman, 10)

addEvent('ha:treatment', true)
addEventHandler('ha:treatment', getLocalPlayer(),
	--Just don't ask
	function()
		local dbid = getElementData(localPlayer, 'dbid')
		triggerServerEvent('send_info', getLocalPlayer(), dbid)		
	end
)

function print_info( ext, int )
	local money = 5000
	if ext==nil then
		outputChatBox("[English] Corey Byrd says: Tell your wife you are alright, you do not have to be treated.", 255, 255, 255, true)
		return
	end
	for i=2, #BODY do
		local extramoney = moneyInfo(i, ext, int)
		money = money + extramoney
	end
	--It may be a weird check, but lets face it. treatments and diagnoses cost money.
	if money == 5000 then
		outputChatBox("[English] Corey Byrd says: Tell your wife you are alright, you do not have to be treated.", 255, 255, 255, true)
		return
	end
	ped_window_treat(money)
end
addEvent('print_info', true)
addEventHandler('print_info', getLocalPlayer(), print_info)

local gui={ window, button={}}
local sw, sh = 200, 130
function ped_window_treat(money)
	gui.window = guiCreateWindow(x/2-(sw/2), y/2-(sh/2), sw, sh, '',false)
	guiCreateLabel(15, 25, sw, 30, "Do you wish to be treated?\nThis will cost you $"..exports.global:formatMoney(money), false, gui.window)
	gui.button[1] = guiCreateButton(15, 65, 80, 50, "Yes, please", false, gui.window)
	gui.button[2] = guiCreateButton(sw-95, 65, 80, 50, "No, thank you", false, gui.window)

	addEventHandler('onClientGUIClick', gui.button[1],
		function ( button, state )
			local dbid = getElementData(localPlayer, 'dbid')
			if state == 'up' and source == gui.button[1] then
				triggerServerEvent('ped_treat', getLocalPlayer(), localPlayer, dbid, money)
				ped_window_close()
				return
			end
		end
		)
	addEventHandler('onClientGUIClick', gui.button[2],
		function ( button, state )
			if state == 'up' and source == gui.button[2] then
				ped_window_close()
				return
			end
		end
		)
end

function ped_window_close()
	destroyElement(gui['window'])
	gui = {	window, button = {}	}
	showCursor(false)
end