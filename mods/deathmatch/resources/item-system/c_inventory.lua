--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

-- Configuration
local background_color = tocolor( 0, 0, 0, 70 )
local background_error_color = tocolor( 255, 0, 0, 127 )
local background_movetoelement_color = tocolor( 0, 250, 0, 40 ) -- tocolor( 127, 127, 255, 63 )
local empty_color = tocolor( 127, 127, 127, 10 )
local full_color = tocolor( 255, 255, 255, 10 )
local tooltip_text_color = tocolor( 255, 255, 255, 255 )
local tooltip_background_color = { default = tocolor( 0, 0, 0, 190 ), delete = tocolor( 127, 0, 0, 190 ), drop = tocolor( 127, 255, 127, 63 ), split = tocolor( 127, 127, 255, 63 ) }
local active_tab_color = tocolor( 0, 0, 0, 70) --127, 255, 127, 127 )
local calibreWeapons = {[22]=true, [23]=true, [24]=true, [25]=true, [26]=true, [27]=true, [28]=true, [29]=true, [30]=true, [31]=true, [32]=true, [33]=true, [34]=true}

--

local rows = 5

local box = 90
local spacer = 1
local sbox = spacer + box

local sx, sy = guiGetScreenSize()

local localPlayer = getLocalPlayer( )

local inventory = false -- elements to display
local show = false -- defines wherever to show the inventory or not

--

local clickDown = false
waitingForItemDrop = false
local hoverElement = false

local hoverItemSlot = false
local clickItemSlot = false

local hoverWorldItem = false
local clickWorldItem = false

local TAB_WALLET, TAB_ITEMS, TAB_KEYS, TAB_WEAPONS = 1, 2, 3, 4
local ACTION_DROP, ACTION_SHOW, ACTION_DESTROY, ACTION_SPLIT = 10, 11, 12, 13

local isCursorOverInventory = false
local activeTab = TAB_WALLET
local activeTabItem = nil
local hoverAction = false
local actionIcons =
{
	[TAB_WALLET] = { -48, tocolor( 255, 255, 255, 50 ), "Wallet" },
	[TAB_ITEMS] = { 48, tocolor( 255, 255, 255, 50 ), "Items" },
	[TAB_KEYS] = { -203, tocolor( 255, 255, 255, 50 ), "Keys" },
	[TAB_WEAPONS] = { -204, tocolor( 255, 255, 255, 50 ), "Weapons" },
	
	[ACTION_DROP] = { -202, tocolor( 127, 255, 127, 63 ), "Drop Item", "Hold CTRL while selecting an item to quick drop it." },
	[ACTION_SHOW] = { -201, tocolor( 127, 127, 255, 63 ), "Show Item" },
	[ACTION_DESTROY] = { -200, tocolor( 255, 127, 127, 63 ), "Destroy Item", "Hold DELETE while selecting an item to quick delete it." },
	--[ACTION_SPLIT] = { -203, tocolor( 255, 127, 127, 63 ), "Destroy Item", "Press DELETE while selecting an item to automatically delete it." }
}

local savedArmor = false
local rotate = false

local function getHoverElement( force )
	if isWatchingTV() and not force then
		return
	end
	local cursorX, cursorY, absX, absY, absZ = getCursorPosition( )
	local cameraX, cameraY, cameraZ = getWorldFromScreenPosition( cursorX, cursorY, 0.1 )

	for _, acceptProtected in ipairs({false, true}) do
		local a, b, c, d, element = processLineOfSight( cameraX, cameraY, cameraZ, absX, absY, absZ )
		if element and not acceptProtected and getElementData(element, "protected") then
			element = nil
		end

		if element and getElementParent(getElementParent(element)) == getResourceRootElement(getResourceFromName("item-world")) then
			return element
		elseif b and c and d then
			element = nil
			local x, y, z = nil
			local maxdist = 0.34
			for key, value in ipairs(getElementsByType("object",getResourceRootElement(getResourceFromName("item-world")), true)) do
				if isElementStreamedIn(value) and isElementOnScreen(value) then
					
					x, y, z = getElementPosition(value)
					local dist = getDistanceBetweenPoints3D(x, y, z, b, c, d)
					
					if dist < maxdist then
						element = value
						maxdist = dist
					end
				end
			end
			if element then
				local px, py, pz = getElementPosition( localPlayer )
				return getDistanceBetweenPoints3D( px, py, pz, getElementPosition( element ) ) < 10 and element
			end
		end
	end
end

local function add_tooltip_prefix(text, action, item)
	if action == 'delete' then
		text = 'DELETE ' .. text
	elseif action == 'drop' then
		text = 'DROP '..text
	elseif action == 'split' then
		if splittableItems[item[1]] then
			if item[1] == 147 then -- picture frame
				text = 'RESET '..text
			elseif item[1] == 115 then -- weapons
				text = 'MODIFY '..text
			else
				text = 'SPLIT '..text
			end
		end
	end
	return text
end

local tooltipYet = false
local function tooltip( x, y, text, text2, action, item )
	tooltipYet = true
	
	text = tostring( text )
	if text2 then
		text2 = tostring( text2 )
	end
	
	if text == text2 then
		text2 = nil
	end

	text = add_tooltip_prefix(text, action, item )
	
	local width = dxGetTextWidth( text, 1, "clear" ) + 20
	if text2 then
		width = math.max( width, dxGetTextWidth( text2, 1, "clear" ) + 20 )
		text = text .. "\n" .. text2
	end
	local height = 10 * ( text2 and 5 or 3 )
	x = math.max( 10, math.min( x, sx - width - 10 ) )
	y = math.max( 10, math.min( y, sy - height - 10 ) )
	
	dxDrawRectangle( x, y, width, height, tooltip_background_color[action or 'default'], true )
	dxDrawText( text, x, y, x + width, y + height, tooltip_text_color, 1, "clear", "center", "center", false, false, true )
end

local function isInBox( x, y, xmin, xmax, ymin, ymax )
	return x >= xmin and x <= xmax and y >= ymin and y <= ymax
end

local res_name = getResourceName(getThisResource ( ))

function getImage( itemID, itemValue )
	if not itemID or not tonumber(itemID) then --Stop bugging out int when picking up items too fast / Maxime
		return ":account/img/nil.png"
	end

	if itemID > 0 and not g_items[itemID] then
		return ":"..res_name.."/images/80.png"
	elseif itemID == 16 then -- Clothes
		local tmp = ("%03d"):format(tonumber(tostring(itemValue):gsub(":(.*)$", ""), 10) or 999)
		if not tmp or not tonumber(tmp) or tonumber(tmp) == 999 then
			return ":account/img/nil.png"
		else
			--return ":account/img/" .. ("%03d"):format(tonumber(itemValue)) .. ".png"
			return ":account/img/" .. tmp .. ".png"
		end
	-- within item system
	else
		if itemID == 55 or itemID == 128 or itemID == 159 or itemID == 161 or itemID == 180 or itemID == 222 then
			return ":"..res_name.."/images/55.png"
		elseif itemID == 115 then -- Weapon
			local itemValueExploded = explode(':', itemValue)
			return ":"..res_name.."/images/-" .. itemValueExploded[1] .. ".png"
		elseif itemID == 116 then -- Ammo
			local itemValueExploded = explode(':', itemValue)
			return ":"..res_name.."/images/"..itemID..'_'..itemValueExploded[1]..".png"
		elseif itemID == 147 then -- Picture frame
			if(itemValue and itemValue ~= 1) then
				return ":"..res_name.."/images/147b.png"
			else
				return ":"..res_name.."/images/147.png"
			end
		elseif itemID == 152 or itemID == 133 or itemID == 153 or itemID == 154 or itemID == 155 then -- Cards
			return ":"..res_name.."/images/149.png"
		elseif itemID == 162 or itemID == 219 or itemID == 220 or itemID == 221 then
			return ":"..res_name.."/images/162.png"
		elseif itemID == 165 then -- Animated Texture
			if(itemValue and itemValue ~= 1) then
				return ":"..res_name.."/images/165b.png"
			else
				return ":"..res_name.."/images/165.png"
			end
		elseif itemID == 184 or itemID == 185 then
			return ":"..res_name.."/images/184.png"
		elseif (itemID >= 194 and itemID <= 200) or itemID==201 or itemID==202 then
			return ":"..res_name.."/images/194.png"
		elseif itemID >= 206 and itemID <=208 then
			return ":"..res_name.."/images/206.png"
		elseif itemID == 215 or itemID == 216 then
			return ":"..res_name.."/images/215.png"
		elseif itemID == 229 or itemID == 230 or itemID == 233 or itemID == 235 then
			return ":"..res_name.."/images/229.png"
		else
			local image = g_items[itemID] and g_items[itemID].image
			if image then
				return  ":"..res_name.."/images/" .. image .. ".png"
			else
				return ":"..res_name.."/images/" .. itemID .. ".png"
			end
		end
	end
end

local function counterIDHelper( itemID, itemValue )
	if itemID == 16 then
		return -100-(tonumber(tostring(itemValue):gsub(":(.*)$", ""), 10) or 0)
	elseif itemID == 115 then
		return -(tonumber(explode(':', itemValue)[1]) or 0)
	elseif itemID == 116 then
		return -50-(tonumber(explode(':', itemValue)[1]) or 0)
	else
		return itemID
	end
end

local function getOverlayText( itemID, itemValue, metadata, isGrouped )
	local v = tostring(itemValue)
	local text = nil
	if itemID == 115 then
		text = getItemName( itemID, v, metadata )
	elseif itemID == 116 then
		local name = getItemName(itemID, itemValue, metadata)
		text = isGrouped and name or ( string.gsub( name, ' '..g_items[itemID][1], '' )..'\n'..(explode(':', itemValue)[2] or 0)..' round(s)' )
	elseif itemID == 134 then -- Money
		text = "$"..exports.global:formatMoney(itemValue)
	elseif itemID == 150 then -- ATM Card
		text = g_items[itemID][1]
	elseif itemID == 152 then -- ID Card
		text = "ID Card"
	elseif itemID == 133 then
		text = "Car License"
	elseif itemID == 153 then
		text = "Bike License"
	elseif itemID == 155 then
		text = "Boat License"
	elseif itemID == 154 then
		text = "Fishing Permit"
	elseif itemID == 78 then
		text = "Pilot Certificate"
	end
	
	if isGrouped then
		text = isGrouped .. "x\n" .. ( text or "" )
	elseif itemID == 80 then
		text = getItemName(itemID, itemValue, metadata)
	elseif itemID == 72 or itemID == 214 then
		text = v:sub( 1, 35 ) .. ( #v > 35 and "..." or "")
	elseif itemID == 71 then
		text = tostring(v)
	elseif itemID == 10 and itemValue ~= 1 and itemValue ~= 6 then
		text = "d" .. tostring(itemValue)
	end
	return text or ""
end

local function getTooltipFor( itemID, itemValue, isGrouped, isProtected, metadata )
	local name, x = getItemName( itemID, itemValue, metadata )
	local desc = getItemDescription( itemID, getItemValue( itemID, itemValue, metadata ), metadata )
	if x then
		name = g_items[itemID][1]
		desc = x
	end
	
	if itemID == 80 then
		if isGrouped then
			return isGrouped .. " Generic Items", ""
		else
			name = getItemName(itemID, itemValue, metadata)
		end
	end

	if itemID == 214 and isGrouped then
		return isGrouped .. " Drugs", ""
	end

	if itemID == 223 and isGrouped then
		return isGrouped .. " Storage Items"
	end

	if itemID == 178 then
		return desc
	end
	
	if isGrouped then
		return isGrouped .. "x " .. name, "Click to show all of these items."
	end

	if isProtected then
		name = name .. " ◊"
	end
	
	if itemID == 134 then
		if itemValue and itemValue ~= 1 and #tostring(itemValue) > 0 and not g_items[itemID][2]:find("#v") and itemValue ~= itemName then -- if #v is there, it's put into the description already
			name = name .. " ($" .. exports.global:formatMoney(itemValue) .. ")"
		end
	elseif itemID == 150 or itemID == 152 then --ATM + ID card
		name = name
	else
		if not getItemHideItemValue(itemID) then
			if itemValue and itemValue ~= 1 and #tostring(itemValue) > 0 and not g_items[itemID][2]:find("#v") and itemValue ~= itemName then -- if #v is there, it's put into the description already
				if g_items[itemID].ooc_item_value then
					name = name .. " ((" .. itemValue .. "))"
				else
					name = name .. " (" .. itemValue .. ")"
				end
			end
		end
	end
	return name, desc
end

function displayItems()
	hoverItemSlot = false
	hoverWorldItem = false
	hoverAction = false
	isCursorOverInventory = false
	hoverElement = false
	tooltipYet = false
	
	if not isCursorShowing( ) and clickWorldItem then
		hideNewInventory( )
	elseif not guiGetInputEnabled( ) and not isMTAWindowActive( ) and isCursorShowing( ) and not isPlayerMapVisible( ) then
		local cursorX, cursorY, cwX, cwY, cwZ = getCursorPosition( )
		local cursorX, cursorY = cursorX * sx, cursorY * sy
		
		-- background
		if not inventory then
			local items = getItems( localPlayer )
			if items then
				inventory = {}
				local counters = {}
				
				local retry = false
				repeat
					if activeTabItem then
						retry = true
					else
						retry = false
					end
					
					for k, v in ipairs( items ) do
						if activeTabItem then
							if counterIDHelper(v[1], v[2]) == activeTabItem then
								inventory[ #inventory + 1 ] = { v[1], v[2], v[3], k, false, v[5], k }
							end
						elseif getItemTab( v[1] ) == activeTab then
							inventory[ #inventory + 1 ] = { v[1], v[2], v[3], k, false, v[5], k }
							counters[ counterIDHelper( v[1], v[2] ) ] = 1 + ( counters[ counterIDHelper( v[1], v[2] ) ] or 0 )
							retry = false
						end
					end

					if activeTabItem then
						if #inventory == 0 then
							activeTabItem = nil
						else
							retry = false
						end
					end
				until not retry
				-- I changed the 3 below from a 2 so if anything bugs outtt - antohny
				if not activeTabItem and activeTab ~= 3 then
					-- remove all items that are here 3 times or more
					for id, occurs in pairs(counters) do
						if occurs >= 3 then
							local first = {-1, -1}
							for i = #inventory, 1, -1 do
								if counterIDHelper( inventory[i][1], inventory[i][2] ) == id then
									first = {inventory[i][1], inventory[i][2]}
									table.remove( inventory, i )
								end
							end
							inventory[ #inventory + 1 ] = { first[1], first[2], nil, nil, occurs, nil, nil }
						end
					end
				end
			else
				return
			end
		end

		local isMove = clickDown and clickItemSlot and not clickItemSlot.group and ( getTickCount( ) - clickDown >= 200 ) -- dragging items from inv
		local columns = math.ceil( #inventory / 5 )
		local x = sx - columns * sbox - spacer
		local y = ( sy - rows * sbox - spacer ) / 2 + sbox + spacer

		if show then
			-- inventory buttons
			local x2 = x - sbox
			local irows = isMove and ACTION_DROP or TAB_WALLET
			local jrows = isMove and ACTION_DESTROY or TAB_WEAPONS
			local y2 = y + sbox
			dxDrawRectangle( x2, y2, sbox, ( jrows - irows + 1 ) * sbox + spacer, background_color )
			for i = irows, jrows do
				local icon = actionIcons[ i ]
				local boxx = x2 + spacer
				--local boxy = y2 + spacer + sbox * ( i - irows + -1 )
				local boxy = y2 + spacer + sbox * ( i - irows )
				dxDrawRectangle( boxx, boxy, box, box, i == activeTab and active_tab_color or icon[2] )
				dxDrawImage( boxx, boxy, box, box, getImage( icon[1] ) )

				if not clickWorldItem and isInBox( cursorX, cursorY, boxx, boxx + box, boxy, boxy + box ) then
					if i <= 6 then
						if not isMove then -- tabs
							tooltip( cursorX, cursorY, icon[3], icon[4] )
							hoverAction = i
						end
					elseif isMove then
						tooltip( cursorX, cursorY, icon[3], icon[4] )
						hoverAction = i
					end
				end
			end

			isCursorOverInventory = isInBox( cursorX, cursorY, x, sx, y, y + rows * sbox + spacer ) or isInBox( cursorX, cursorY, x2, x2 + sbox, y2, y2 + ( jrows - irows + 1 ) * sbox + spacer )

			-- actual inv
			dxDrawRectangle( x, y, columns * sbox + spacer, rows * sbox + spacer, background_color )
			for i = 1, columns * 5 do
				local col = math.floor( ( i - 1 ) / 5 )
				local row = ( i - 1 ) % 5

				local boxx = x + col * sbox + spacer
				local boxy = y + row * sbox + spacer

				local item = inventory[ i ]
				if item then
					if not isMove or item[4] ~= clickItemSlot.id then
						dxDrawRectangle( boxx, boxy, box, box, full_color )
						dxDrawImage( boxx, boxy, box, box, getImage( item[1], item[2] ) )

						-- overlay text for some items
						local text = getOverlayText( item[1], item[2], item[6] or {}, item[5] )
						if #text > 0 then
							dxDrawText( text, boxx + 2, boxy + 2, boxx + box - 2, boxy + box - 2, tooltip_text_color, 1, "clear", "right", "bottom", true, true, true )
						end

						if not isMove and not clickWorldItem and isInBox( cursorX, cursorY, boxx, boxx + box, boxy, boxy + box ) then
							local t = { getTooltipFor( item[1], item[2], item[5], nil, item[6] or {} ) }

							local action
							if not item[5] then
								if getKeyState( "delete" ) then
									action = 'delete'
								elseif getKeyState( "lctrl" ) or getKeyState( "rctrl" ) then
									action = 'drop'
								elseif getKeyState( "lshift" ) or getKeyState( "rshift" ) then
									action = 'split'
								end
							end

							tooltip( cursorX, cursorY, t[1], t[2], action, item )
							hoverItemSlot = { invslot = i, id = item[4], x = boxx, y = boxy, group = item[5] }
						end
					end
				else
					dxDrawRectangle( boxx, boxy, box, box, empty_color )
				end
			end
		end
		
		if clickDown and ( getTickCount( ) - clickDown >= 200 ) and ( ( clickItemSlot and not clickItemSlot.group ) or ( clickWorldItem and isElement(clickWorldItem) and not getElementData( clickWorldItem, "protected" ) ) ) then
			local boxx, boxy, item
			local color = full_color
			local col, x, y, z
			if clickWorldItem then
				item = { getElementData( clickWorldItem, "itemID" ), getElementData( clickWorldItem, "itemValue" ) or 1, false, false }
				boxx = cursorX - spacer - box / 2
				boxy = cursorY - spacer - box / 2
				if isCursorOverInventory then
					if item[ 1 ] == 81 or item[ 1 ] == 103 then
						color = background_error_color
					elseif not hasSpaceForItem( localPlayer, item[1], item[2] ) then
						color = background_error_color
					end
				else
					-- check if we can drop there
					local cameraX, cameraY, cameraZ = getWorldFromScreenPosition( cursorX, cursorY, 0.1 )
					col, x, y, z, hoverElement = processLineOfSight( cameraX, cameraY, cameraZ, cwX, cwY, cwZ )
					--outputDebugString("yes")
					if not col or getDistanceBetweenPoints3D( x, y, z, getElementPosition( localPlayer ) ) >= 10 then
						color = background_error_color
					elseif hoverElement then
						--outputDebugString("yes")
						local elementType = getElementType( hoverElement ) 
						if item[ 1 ] == 81 or item[ 1 ] == 103 then
							color = hoverElement == clickWorldItem and full_color or background_error_color
						elseif elementType == "vehicle" then
							color = background_movetoelement_color
						elseif elementType == "player" then
							color = item[1] < 0 and background_error_color or background_movetoelement_color
						elseif getElementModel( hoverElement ) == 2942 and item [ 1 ] == 150 then -- ATM card into ATM/ MAXIME
							color = background_movetoelement_color
						elseif getElementModel( hoverElement ) == 2934 then -- ATM card into ATM/ MAXIME
							color = background_movetoelement_color
						elseif elementType == "object" then
							if getElementParent(getElementParent(hoverElement)) == getResourceRootElement(getResourceFromName("item-world")) then
								local targetItemID =  getElementData( hoverElement, "itemID" )
								local targetItemValue = getElementData( hoverElement, "itemValue" ) or 1
								if isStorageItem( targetItemID, targetItemValue ) then --storage items /Exciter
									color = background_movetoelement_color or background_error_color
								elseif targetItemID == 166 and item[1] == 165 then -- Video disc into video player /Exciter
									color = background_movetoelement_color
								else
									color = full_color
								end
							else
								color = full_color
							end
						else
							color = full_color
						end
					end
				end
			else
				item = inventory[ clickItemSlot.invslot ]
				boxx = clickItemSlot.rx + cursorX
				boxy = clickItemSlot.ry + cursorY

				if not isCursorOverInventory then
					-- check if we can drop there
					local cameraX, cameraY, cameraZ = getWorldFromScreenPosition( cursorX, cursorY, 0.1 )
					col, x, y, z, hoverElement = processLineOfSight( cameraX, cameraY, cameraZ, cwX, cwY, cwZ )
					if not col or getDistanceBetweenPoints3D( x, y, z, getElementPosition( localPlayer ) ) >= 10 or isWatchingTV() then
						color = background_error_color
					elseif hoverElement then
						--outputDebugString("yes")
						local elementType = getElementType( hoverElement )
						--outputDebugString(tostring(elementType))
						if elementType == "vehicle" then
							color = background_movetoelement_color
						elseif elementType == "player" then
							color = item[1] < 0 and background_error_color or background_movetoelement_color
						elseif getElementModel( hoverElement ) == 2942 and item [ 1 ] == 150 then -- ATM card into ATM/ MAXIME
							color = background_movetoelement_color
						elseif elementType == "ped" and item[1] == 211 and getElementData(hoverElement,"rpp.npc.type") == "santa" then --lottery ticket to santa
							color = background_movetoelement_color
						elseif elementType == "ped" and getElementData(hoverElement,"customshop") then --  import products to custom shop
							color = background_movetoelement_color
						elseif elementType == "object" then
							--outputDebugString("object")
							if getElementParent(getElementParent(hoverElement)) == getResourceRootElement(getResourceFromName("item-world")) then
								--outputDebugString("item-world")
								local targetItemID =  getElementData( hoverElement, "itemID" )
								local targetItemValue = getElementData( hoverElement, "itemValue" ) or 1
								if isStorageItem( targetItemID, targetItemValue ) then --storage items /Exciter
									color = background_movetoelement_color
								elseif targetItemID == 166 and item[1] == 165 then -- Video disc into video player /Exciter
									color = background_movetoelement_color
								else
									color = full_color
								end
							else
								color = full_color
							end
						elseif hoverElement == getHoverElement() then
							color = full_color
						else
							color = background_error_color
						end
					end

				end
			end
			
			dxDrawRectangle( boxx - spacer, boxy - spacer, box + 2 * spacer, box + 2 * spacer, background_color )
			dxDrawRectangle( boxx, boxy, box, box, color )
			dxDrawImage( boxx, boxy, box, box, getImage( item[1], item[2] ) )
			if hoverElement then
				if color == background_movetoelement_color then
					local name = ""
					local elementType = getElementType( hoverElement )
					if elementType == "player" then
						name = getPlayerName( hoverElement ):gsub( "_", " " )
					elseif elementType == "ped" and getElementData(hoverElement,"shopkeeper") then
						name = "store"
					elseif elementType == "ped" then
						local pedName = tostring(getElementData(hoverElement, "name"))
						if pedName then name = pedName else name = "person" end
					elseif elementType == "vehicle" then
						name = getVehicleName( hoverElement ) .. " (#" .. getElementData( hoverElement, "dbid" ) .. ")"
					elseif getElementModel ( hoverElement ) == 2942 then -- ATM card into ATM/MAXIME
						name = "ATM"
					elseif elementType == "object" then
						name = "storage"
						if getElementParent(getElementParent(hoverElement)) == getResourceRootElement(getResourceFromName("item-world")) then
							local targetItemID =  getElementData( hoverElement, "itemID" )
							if targetItemID == 166 then --Video System
								name = "video player"
							else
								local targetItemValue = getElementData(hoverElement, "itemValue") or 1
								local targetItemMetadata = getElementData(hoverElement, "metadata")
								name = getItemName(targetItemID, targetItemValue, targetItemMetadata) or "storage"
							end
						end		
					end
					tooltip( boxx + sbox, boxy + ( box - 50 ) / 2, getItemName( item[1], item[2], item[6] ), "Move to " .. name .. "." )
				elseif color == full_color then
					hoverElement = nil
				else
					hoverElement = false
				end
			else
				hoverElement = nil
			end
		end
		
		if show then
			-- hide any tooltips while over the inventory
			if isCursorOverInventory or clickWorldItem then
				return
			end
		end
		
		local element = getHoverElement(true)
		if element then
			local itemID = getElementData( element, "itemID" )
			local itemValue = getElementData( element, "itemValue" ) or 1

			if itemID ~= 81 and itemID ~= 103 and not getElementData ( localPlayer, "exclusiveGUI" ) then
				local tooltipText1, tooltipText2 = getTooltipFor( itemID, itemValue, false, getElementData( element, "protected" ), getElementData( element, "metadata" ) or {} )
				tooltip( cursorX, cursorY, tooltipText1, getElementData(element, "transfering") and "Please wait.." or tooltipText2)
			end
			hoverWorldItem = getHoverElement()
		end
	end
end
addEventHandler('onClientRender', root, displayItems)

addEventHandler( "recieveItems", getRootElement( ), 
	function( )
		inventory = false
	end
)

addEventHandler( "onClientClick", getRootElement( ),
	function( button, state, cursorX, cursorY, worldX, worldY, worldZ )
		if not waitingForItemDrop then
			if button == "left" or ( button == "middle" and exports.integration:isPlayerTrialAdmin( getLocalPlayer( ) ) ) then
				if button == "left" and ( hoverItemSlot or clickItemSlot ) then
					if state == "down" then
						clickDown = getTickCount( )
						clickItemSlot = hoverItemSlot
						clickItemSlot.rx = clickItemSlot.x - cursorX
						clickItemSlot.ry = clickItemSlot.y - cursorY
					end
					
					if state == "down" and getKeyState( "delete" ) then -- quick delete
						state = "up"
						clickDown = 0
						hoverAction = ACTION_DESTROY
					elseif state == "down" and ( getKeyState( "lctrl" ) or getKeyState( "rctrl" ) ) then -- quick drop
						state = "up"
						clickDown = 0
						hoverAction = ACTION_DROP
					elseif state == "down" and ( getKeyState( "lshift" ) or getKeyState( "rshift" ) ) then -- Split / MAXIME
						state = "up"
						clickDown = 0
						hoverAction = ACTION_SPLIT
					end
					
					if state == "up" and clickItemSlot then
						if getTickCount( ) - clickDown < 200 then
							if isCursorOverInventory then
								if clickItemSlot.group then
									activeTabItem = counterIDHelper( inventory[ clickItemSlot.invslot ][1], inventory[ clickItemSlot.invslot ][2] )
									inventory = false
								else
									useItem( inventory[ clickItemSlot.invslot ][ 1 ] < 0 and inventory[ clickItemSlot.invslot ][ 3 ] or clickItemSlot.id )
								end
							end
						elseif not clickItemSlot.group then
							if not isCursorOverInventory then
								if isWatchingTV() then
									clickItemSlot = nil
									return
								end
								
								-- Drag&Drop
								if getDistanceBetweenPoints3D( worldX, worldY, worldZ, getElementPosition( localPlayer ) ) < 10 then
									local item = inventory[ clickItemSlot.invslot ]
									local itemID = item[1]
									local itemValue = item[2]
									if hoverElement == nil then
										if itemID > 0 then
											if itemID == 48 and countItems( localPlayer, 48 ) == 1 and getCarriedWeight( localPlayer ) - getItemWeight( 48, 1 ) > 10 then
												outputChatBox( "You have too much stuff in your inventory.", 255, 0, 0 )
											else
												waitingForItemDrop = true
												triggerServerEvent( "dropItem", localPlayer, clickItemSlot.id, worldX, worldY, worldZ )
											end
										elseif itemID == -100 then
											waitingForItemDrop = true
											triggerServerEvent( "dropItem", localPlayer, 100, worldX, worldY, worldZ, savedArmor )
										end
									elseif hoverElement then
										local elementType = getElementType(hoverElement)
										if elementType == "ped" and itemID == 211 and getElementData(hoverElement,"rpp.npc.type") == "santa" then --lottery ticket to santa
											triggerServerEvent("xmas:useChristmasLotteryTicket", localPlayer, hoverElement, clickItemSlot.id)
										elseif itemID > 0 then
											waitingForItemDrop = true
											triggerServerEvent( "moveToElement", localPlayer, hoverElement, clickItemSlot.id, nil, "finishItemDrop" )
										elseif itemID == -100 then
											triggerServerEvent( "moveToElement", localPlayer, hoverElement, clickItemSlot.id, true, "finishItemDrop" )
										end
									end
								end
							elseif hoverAction == ACTION_DROP then
								if isWatchingTV() then
									outputChatBox( "You aren't IN your TV. Just sitting in front of it.", 255, 0, 0 )
									clickItemSlot = nil
									return
								end
								local item = inventory[ clickItemSlot.invslot ]
								local itemID = item[ 1 ]
								local itemValue = item[2]
								
								local matrix = getElementMatrix(getLocalPlayer())
								local oldX = 0
								local oldY = 1
								local oldZ = 0
								local x = oldX * matrix[1][1] + oldY * matrix [2][1] + oldZ * matrix [3][1] + matrix [4][1]
								local y = oldX * matrix[1][2] + oldY * matrix [2][2] + oldZ * matrix [3][2] + matrix [4][2]
								local z = oldX * matrix[1][3] + oldY * matrix [2][3] + oldZ * matrix [3][3] + matrix [4][3]
								
								local z = getGroundPosition( x, y, z + 2 )
								
								if itemID > 0 then
									waitingForItemDrop = true
									triggerServerEvent( "dropItem", localPlayer, clickItemSlot.id, x, y, z )
								elseif itemID == -100 then
									waitingForItemDrop = true
									triggerServerEvent( "dropItem", localPlayer, 100, x, y, z, savedArmor )
								else
									-- weapon
									local slot = -item[3]
									if slot >= 2 and slot <= 9 then
										openWeaponDropGUI(-itemID, itemValue, x, y, z)
									else
										waitingForItemDrop = true
										triggerServerEvent( "dropItem", localPlayer, -itemID, x, y, z, itemValue )
									end
								end
							elseif hoverAction == ACTION_SHOW then
								-- Show Item
								local item = inventory[ clickItemSlot.invslot ]
								local itemName, itemValue = getItemName( item[1], item[2], item[6] ), getItemValue( item[1], item[2], item[6] )
								if item[1] == 72 then
									itemName = itemName .. ", reading " .. itemValue
								elseif item[1] == 79 then
									itemName = itemName .. ", " .. itemValue
								elseif item[1] == 64 or item[1] == 65 or item[1] == 86 or item[1] == 87 or item[1] == 82 or item[1] == 112 or item[1] == 127 then
									itemName = itemName .. ", reading " .. itemValue
								elseif item[1] == 133 or item[1] == 153 or item[1] == 154 or item[1] == 155 or item[1] == 78 then--Cards
									itemName = itemName .. ", issued for "..itemValue..""
								elseif item[1] == 150 then--ATM card
									local itemExploded = explode(";", itemValue )
									local owner = exports.cache:getCharacterNameFromID(itemExploded[2])
									owner = string.gsub(owner, "_", " ")
									itemName = itemName .. ", issued for "..owner
								elseif item[1] == 152 then -- ID card
									local itemExploded = explode(";", itemValue )
									local owner = itemExploded[1]
									owner = string.gsub(owner, "_", " ")
									itemName = itemName .. ", issued for "..owner
								end
								triggerServerEvent( "showItem", localPlayer, itemName )
							elseif hoverAction == ACTION_DESTROY then
								local item = inventory[ clickItemSlot.invslot ]
								local itemID = item[ 1 ]
								local itemSlot = itemID < 0 and itemID or clickItemSlot.id
								if itemID == 48 and countItems( localPlayer, 48 ) == 1 then -- backpack
									if getCarriedWeight( localPlayer ) - getItemWeight( 48, 1 ) > 10 then
										outputChatBox("You have too much stuff in your inventory.")
									else
										triggerServerEvent( "destroyItem", localPlayer, itemSlot )
									end
								elseif itemID == 134 then --Money
									outputChatBox("You can't destroy money.")
								else
									triggerServerEvent( "destroyItem", localPlayer, itemSlot )
								end
							elseif hoverAction == ACTION_SPLIT then
								local item = inventory[ clickItemSlot.invslot ]
								local itemName, itemValue = getItemName( item[1], item[2] ), getItemValue( item[1], item[2] )
								local itemID = item[1]
								if splittableItems[itemID] then
									splitItem(itemID, itemName, itemValue, item)
								else
									outputChatBox(itemName.." is not splittable, type '/splits' for a list of splittable items.",255,0,0)
								end
							end
						end
						hoverItemSlot = false
						clickItemSlot = false
						clickDown = false
					end
				elseif hoverWorldItem or clickWorldItem and isElement(clickWorldItem) then
					if state == "down" and button == "left" then
						local x, y, z = getElementPosition(getLocalPlayer())
						local eX, eY, eZ = getElementPosition(hoverWorldItem)
						local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(hoverWorldItem)
						local addDistance = 0 --compensate for object size
						if minX then
							local boundingBoxBiggestDist = 0
							if minX > boundingBoxBiggestDist then
								boundingBoxBiggestDist = minX
							end
							if minY > boundingBoxBiggestDist then
								boundingBoxBiggestDist = minY
							end
							if maxX > boundingBoxBiggestDist then
								boundingBoxBiggestDist = maxX
							end
							if maxY > boundingBoxBiggestDist then
								boundingBoxBiggestDist = maxY
							end
							addDistance = boundingBoxBiggestDist
						end
						local maxDistance = 3 + addDistance
						if (getDistanceBetweenPoints3D(x, y, z, eX, eY, eZ)<=maxDistance) then						
							local itemID = getElementData( hoverWorldItem, "itemID" )
							--[[ moved to object-interaction
								if itemID == 81 or itemID == 103 then
								if not getElementData ( localPlayer, "exclusiveGUI" ) then
									triggerServerEvent( "openFreakinInventory", getLocalPlayer(), hoverWorldItem, cursorX, cursorY )
								end
							--]]
							if itemID == 169 then
								if not getElementData ( localPlayer, "exclusiveGUI" ) then
									triggerServerEvent("openKeypadInterface", localPlayer, hoverWorldItem)
								end
							else
								for _, value in ipairs( getElementsByType( "player" ) ) do
									if getPedContactElement( value ) == hoverWorldItem or isLikelyStandingOn( value, hoverWorldItem ) then
										return
									end
								end

								clickDown = getTickCount( )
								clickWorldItem = hoverWorldItem

								if not getElementData( clickWorldItem, "protected" ) and not getElementData(localPlayer, "exclusiveGUI") and not exports.rightclick:isrcOpen() then
									if exports['item-world']:can(localPlayer, "pickup", clickWorldItem) or exports['item-world']:can(localPlayer, "move", clickWorldItem) or getKeyState("p") or getKeyState("n") then
										setElementAlpha( clickWorldItem, 150 ) --127
										setElementCollisionsEnabled( clickWorldItem, false )
									end
								end
							end
						end
					elseif state == "up" and clickWorldItem and isElement(clickWorldItem) then
						local x, y, z = getElementPosition(getLocalPlayer())
						local eX, eY, eZ = getElementPosition(clickWorldItem)
						local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(clickWorldItem)
						local addDistance = 0 --compensate for object size
						if minX then
							local boundingBoxBiggestDist = 0
							if minX > boundingBoxBiggestDist then
								boundingBoxBiggestDist = minX
							end
							if minY > boundingBoxBiggestDist then
								boundingBoxBiggestDist = minY
							end
							if maxX > boundingBoxBiggestDist then
								boundingBoxBiggestDist = maxX
							end
							if maxY > boundingBoxBiggestDist then
								boundingBoxBiggestDist = maxY
							end
							addDistance = boundingBoxBiggestDist
						end
						local maxDistance = 3 + addDistance
						if (getDistanceBetweenPoints3D(x, y, z, eX, eY, eZ)<=maxDistance) then	
							setElementAlpha( clickWorldItem, 255 )
							setElementCollisionsEnabled( clickWorldItem, true )
							local itemID = tonumber(getElementData(clickWorldItem, "itemID")) or 0
							--outputDebugString(tostring(getElementData(clickWorldItem, "transfering")))
							local canBePickedUp = not ( itemID == 81 or itemID == 103 or itemID == 169 or itemID == 223 ) and not getElementData(clickWorldItem, "transfering")
							if canBePickedUp then
								if getItemUseNewPickupMethod(itemID) then
									canBePickedUp = false --prevent picking up item this old way if it has been specified to use the new method instead /Exciter
								end
							end

							if not exports.rightclick:isrcOpen() then
								if getKeyState("p") then
									if exports.global:isStaffOnDuty(localPlayer) then
										triggerServerEvent("protectItem", clickWorldItem, fp)
									end
								elseif getKeyState("n") then
									if exports.global:isStaffOnDuty(localPlayer) or (getElementDimension(localPlayer) ~= 0 and hasItem(localPlayer, 4, getElementDimension(localPlayer)) or hasItem(localPlayer, 5, getElementDimension(localPlayer))) then
										if exports['item-world']:can(localPlayer, "move", clickWorldItem) then
											triggerEvent("item:move", root, clickWorldItem)
										end
									end
								else
									if getTickCount( ) - clickDown < 200 then
										if canBePickedUp then
											if itemID == 169 then -- Keypad Door Lock / Maxime
												if not getElementData(localPlayer, "exclusiveGUI") then
													triggerServerEvent("openKeypadInterface", localPlayer, clickWorldItem)
												end
											else
												pickupItem( "left", "down", clickWorldItem )
											end
										end
									else
										if isCursorOverInventory then
											if canBePickedUp then
												if itemID == 169 then -- Keypad Door Lock / Maxime
													if not getElementData(localPlayer, "exclusiveGUI") then
														triggerServerEvent("openKeypadInterface", localPlayer, clickWorldItem)
													end
												else
													pickupItem( "left", "down", clickWorldItem )
												end
											end
										elseif rotate then
											local rx, ry, rz = getElementRotation( clickWorldItem )
											setElementRotation( clickWorldItem, rx, ry, rz - rotate )
											triggerServerEvent( "rotateItem", localPlayer, clickWorldItem, rotate )
										else
											-- Drag&Drop, bitches
											if getDistanceBetweenPoints3D( worldX, worldY, worldZ, getElementPosition( localPlayer ) ) < 10 then
												if hoverElement == nil then
													for _, value in ipairs( getElementsByType( "player" ) ) do
														if getPedContactElement( value ) == clickWorldItem or isLikelyStandingOn( value, clickWorldItem ) then
															return
														end
													end
													if exports['item-world']:can(localPlayer, "move", clickWorldItem) then
														triggerServerEvent( "moveItem", localPlayer, clickWorldItem, worldX, worldY, worldZ )
													end
												else
													if button == "left" then
														local hoverElementX, hoverElementY, hoverElementZ = getElementPosition(hoverElement)
														local hoverMinX, hoverMinY, hoverMinZ, hoverMaxX, hoverMaxY, hoverMaxZ = getElementBoundingBox(hoverElement)
														local hoverAddDistance = 0 --compensate for object size
														if hoverMinX then
															local hoverBoundingBoxBiggestDist = 0
															if hoverMinX > hoverBoundingBoxBiggestDist then
																hoverBoundingBoxBiggestDist = hoverMinX
															end
															if hoverMinY > hoverBoundingBoxBiggestDist then
																hoverBoundingBoxBiggestDist = hoverMinY
															end
															if hoverMaxX > hoverBoundingBoxBiggestDist then
																hoverBoundingBoxBiggestDist = hoverMaxX
															end
															if hoverMaxY > hoverBoundingBoxBiggestDist then
																hoverBoundingBoxBiggestDist = hoverMaxY
															end
															hoverAddDistance = hoverBoundingBoxBiggestDist
														end
														local hoverMaxDistance = 3 + hoverAddDistance + addDistance
														if getDistanceBetweenPoints3D(hoverElementX, hoverElementY, hoverElementZ, eX, eY, eZ) < hoverMaxDistance then
															if exports['item-world']:can(localPlayer, "pickup", clickWorldItem) then
																if hoverElement == localPlayer then
																	pickupItem('left', 'down', clickWorldItem)
																else
																	triggerServerEvent( "moveWorldItemToElement", localPlayer, clickWorldItem, hoverElement )
																end
															end
														end
													end
												end
											end
										end
									end
								end
							end
							
							clickWorldItem = false
							cursorDown = false
							rotate = false
						end
					end
				elseif button == "left" and isCursorOverInventory and hoverAction and state == "down" then
					if show then
						if activeTabItem then
							activeTabItem = nil
							activeTab = hoverAction
						elseif activeTab == hoverAction then
							show = false
							showCursor( false )
							exports["realism"]:showSpeedo()
						else
							activeTab = hoverAction
						end
					else
						activeTab = hoverAction
						show = true
					end
					inventory = false
				end
			elseif button == "right" then
				if clickItemSlot then
					clickItemSlot = false
					clickDown = false
				end

				if clickWorldItem then
					setElementAlpha( clickWorldItem, 255 )
					setElementCollisionsEnabled( clickWorldItem, true )
					clickWorldItem = false
					clickDown = false
				end

				if state == "up" and hoverWorldItem then
					local x, y, z = getElementPosition(getLocalPlayer())
					local eX, eY, eZ = getElementPosition(hoverWorldItem)
					local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(hoverWorldItem)
					local addDistance = 0 --compensate for object size
					if minX then
						local boundingBoxBiggestDist = 0
						if minX > boundingBoxBiggestDist then
							boundingBoxBiggestDist = minX
						end
						if minY > boundingBoxBiggestDist then
							boundingBoxBiggestDist = minY
						end
						if maxX > boundingBoxBiggestDist then
							boundingBoxBiggestDist = maxX
						end
						if maxY > boundingBoxBiggestDist then
							boundingBoxBiggestDist = maxY
						end
						addDistance = boundingBoxBiggestDist
					end
					local maxDistance = 3 + addDistance
					if (getDistanceBetweenPoints3D(x, y, z, eX, eY, eZ)<=maxDistance) then
						exports['object-interaction']:clickObject("right", "down", cursorX, cursorY, eX, eY, eZ, hoverWorldItem)
						--[[ moved to object-interaction
						if getElementData ( hoverWorldItem, "itemID" ) == 103 or getElementData ( hoverWorldItem, "itemID" ) == 81 then -- Shelf/Fridge
							if not getElementData ( localPlayer, "exclusiveGUI" ) then
								triggerServerEvent( "openFreakinInventory", getLocalPlayer(), hoverWorldItem, cursorX, cursorY )
							end
						--]]
						if getElementData( hoverWorldItem, "itemID" ) == 54 or getElementData( hoverWorldItem, "itemID" ) == 176 then -- Ghettoblaster
							item = hoverWorldItem
							ax, ay = cursorX, cursorY
							--showItemMenu( )
						end
					end
				elseif state == "up" and hoverItemSlot and not hoverItemSlot.group then
					local realSlot = inventory[ hoverItemSlot.invslot ][7]
					local item = getItems(localPlayer)[realSlot]
					if openMetadataEditor( item ) then
						hideNewInventory( )
					end
				end
			end
		end
	end
)

bindKey( "i", "down",
	function( )
		if getElementData(localPlayer, "loggedin") == 1 then
			if show then
				hideNewInventory( )
				playSoundInvClose()
			elseif ((not getElementData(localPlayer, "adminjailed")) or exports.integration:isPlayerTrialAdmin(localPlayer)) and getElementData(getLocalPlayer(), "viewingInterior")~=1 then -- Chaos | Allowed admins to view inventory in jail, not in previewing interiors
				if getElementData(localPlayer, "exclusiveGUI") then
					return
				end
				show = true
				activeTabItem = nil
				inventory = false
				showCursor( true )
				exports["realism"]:hideSpeedo()
				playSoundInvOpen()
			else
				outputChatBox("You can't access your inventory in jail or in property preview.", 255, 0, 0)
			end
		end
	end
)

addEvent( "finishItemDrop", true )
addEventHandler("finishItemDrop", getLocalPlayer(),
	function( )
		waitingForItemDrop = false
		inventory = false
		--playSound(":resources/item_drop.mp3")
	end
)

--

function hideNewInventory( )
	clickDown = false
	clickItemSlot = false
	rotate = false
	if clickWorldItem then 
		if isElement(clickWorldItem) then
			setElementAlpha( clickWorldItem, 255 )
			setElementCollisionsEnabled( clickWorldItem, true )
		end
		clickWorldItem = false
	end
	
	
	if show then
		show = false
		showCursor( false )
		exports["realism"]:showSpeedo()
	end
end
addEvent( "items:inventory:hideinv", true )
addEventHandler("items:inventory:hideinv", getLocalPlayer(), hideNewInventory)

function resetPicFrame(itemID, itemValue)
	if itemValue == 1 then
		outputChatBox("This texture is already empty.", localPlayer, 255, 0, 0)
	else
		triggerServerEvent("resetFrame", localPlayer , localPlayer, itemID, itemValue)
	end
end

function splitItem(itemID, itemName, itemValue, item)
	if itemID == 147 then
		resetPicFrame(itemID, itemValue)
	elseif itemID == 115 then
		triggerEvent('weapon:interact', localPlayer, item)
	else 
		local width, height = 226, 78
		local scrWidth, scrHeight = guiGetScreenSize()
		local x = scrWidth/2 - (width/2)
		local y = scrHeight/2 - (height/2)
		
		showCursor(true)
		guiSetInputEnabled ( true)
		
		local wSplitting = guiCreateWindow(x, y, width, height,itemName.." - "..itemValue,false)
			--guiWindowSetMovable(wSplitting,false)
			guiWindowSetSizable(wSplitting,false)
			--guiSetProperty(wSplitting,"TitlebarEnabled","false")
		local GUIEditor_Label = guiCreateLabel(12,20,54,24,"Amount:",false,wSplitting)
			guiLabelSetVerticalAlign(GUIEditor_Label,"center")
			guiSetFont(GUIEditor_Label,"default-bold-small")
		local eAmount = guiCreateEdit(66,20,146,24,"an integer number",false,wSplitting)
		local bOK = guiCreateButton(12,48,100,21,"OK",false,wSplitting)
		local bCancel = guiCreateButton(112,48,100,21,"CANCEL",false,wSplitting)
		
		addEventHandler("onClientGUIClick", eAmount, function()
			guiSetText(eAmount,"")
		end, false)
		
		addEventHandler("onClientGUIClick", bCancel, function()
			destroyElement(wSplitting)
			wSplitting = nil
			--showCursor(false)
			guiSetInputEnabled ( false)
		end, false)
		
		addEventHandler("onClientGUIClick", bOK, function()
			local amount = tonumber(guiGetText(eAmount))
			if not amount then
				guiSetText(wSplitting,"Amount must be number!")
				return false
			end
			if amount%1 ~= 0 then
				guiSetText(wSplitting,"Amount must be integer, like 1, 2, 3...")
				return false
			else
				if amount <= 0 then
					guiSetText(wSplitting,"Amount must be greater than 0!")
					return false
				end
			end
			
			triggerServerEvent("splitItem", localPlayer, itemID, amount)
			
			destroyElement(wSplitting)
			wSplitting = nil
			--showCursor(false)
			guiSetInputEnabled ( false)
		end, false)
	end
end

function explode(div,str)
  if (div=='') then return false end
  local pos,arr = 0,{}
  for st,sp in function() return string.find(str,div,pos,true) end do
	table.insert(arr,string.sub(str,pos,st-1))
	pos = sp + 1
  end
  table.insert(arr,string.sub(str,pos))
  return arr
end

function playSoundInvOpen()
	setSoundVolume(playSound(":resources/inv_open.mp3"), 0.3)
end

function playSoundInvClose()
	setSoundVolume(playSound(":resources/inv_close.mp3"), 0.3)
end

function isLikelyStandingOn(player, object)
	if replacedModelsWithWrongCollisionCheck[getElementModel(object)] then
		return false
	end

	local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(object)
	local oX, oY, oZ = getElementPosition(object)
	local pX, pY, pZ = getElementPosition(player)
	if isPedOnGround(player) then
		pZ = getGroundPosition(pX, pY, pZ)
	else
		pZ = pZ - 1
	end

	--outputDebugString(toJSON({oX + minX, oX + maxX, pX}) .. tostring(pX >= oX + minX and pX <= oX + maxX))
	--outputDebugString(toJSON({oY + minY, oY + maxY, pY}) .. tostring(pY >= oY + minY and pY <= oY + maxY))
	--outputDebugString(toJSON({oZ + minZ, oZ + maxZ, pZ}) .. tostring(pZ >= oZ + minZ and pZ <= oZ + maxZ))

	-- are we outside of the bounding box?
	return not (pX < oX + minX or pX > oX + maxX or pY < oY + minY or pY > oY + maxY or pZ < oZ + minZ or pZ > oZ + maxZ)
end
