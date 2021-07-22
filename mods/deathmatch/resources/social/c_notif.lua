--[[
 * ***********************************************************************************************************************
 * Copyright (c) 2015 OwlGaming Community - All Rights Reserved
 * All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
 * Unauthorized copying of this file, via any medium is strictly prohibited
 * Proprietary and confidential
 * ***********************************************************************************************************************
 ]]

--------------------------------------------------------------------------------
local is_showing = false
local function isInBox( x, y, xmin, xmax, ymin, ymax )
    return x and y and x >= xmin and x <= xmax and y >= ymin and y <= ymax
end

-- Drawing stuff
local container_width, container_height, padding = 250, 100, 30

local scroll_y = 0.1
local min_scroll_y = -5
local max_scroll_y = 0.1

-- calculate the maximum numbers of stuff to fit on one line
local screen_x, screen_y = guiGetScreenSize( )
local max_containers = math.floor( screen_y / ( container_height + padding ) )
local container_start_x = padding
local container_start_y = screen_y - container_height - padding - 25
local max_containers_y = screen_y / ( ( container_height ) + padding )
local can_scroll_down = false
local justClicked = false

local title_size = 0.3 * container_height

local items = {}

function statusUpdate(user_id, item)
    if item then
        table.insert(items, item)
        if getElementData(localPlayer, 'social_friend_updates_sound') ~= '0' then
            playSound('status.mp3')
        end
        if not is_showing then
            addEventHandler( "onClientRender", root, drawFriendsUpdates )
        end
    end
end
addEvent('social:statusUpdate', true)
addEventHandler('social:statusUpdate', root, statusUpdate)


function drawFriendsUpdates()
    is_showing = true
    local cursorX, cursorY
    if isCursorShowing() then
        cursorX, cursorY = getCursorPosition()
        cursorX, cursorY = cursorX * screen_x, cursorY * screen_y
    end
    -- this ensures all fonts will still be working in case of other resources that has the fonts restart
    makeFonts()
    local justForcedNewLine = false
    if (#items>0) then
        for key = 1, #items do
            local value = items[key]
            if not value then
                break
            end
            local alpha = items[key].alpha
            if alpha < 0 then alpha = 0 end
            local pos = ( key-1 )
            local x, y, w, h = container_start_x , container_start_y-((container_height+padding)*pos), container_width, container_height

            local alpha2 = alpha-155
            if alpha2 < 0 then alpha2 = 0 end
            dxDrawRectangle( x, y, w, h, tocolor( 0, 0, 0, alpha2 ), true )

            local avatar = exports.cache:getImage(value.accountID)
            dxDrawImage ( x, y, h, h, (avatar and avatar.tex or ':cache/default.png'), 0,0,0, tocolor(255,255,255,alpha), true)
            local avatar_size = h

            w = x + w
            h = y + h

            local margin = 3
            local name_ox = margin--+avatar_size
            local name_oy = margin
            local name_l = x+name_ox
            local name_t = y+name_oy
            local name_r = name_l+avatar_size
            local name_b = name_t+dxGetFontHeight(1, font2)*2
            local shadow = 2
            --value.name = "Maximemaxime Maxime Maxime Maxime Maxime Maxime"
            dxDrawText(value.name ,name_l+shadow ,name_t+shadow, name_r+shadow, name_b+shadow, tocolor ( 0, 0, 0, alpha ), 1, font2, "left", "top", true, true, true ) -- shadow
            if value.player and isElement(value.player) then
                r, g, b = getPlayerNametagColor( value.player )
                dxDrawText( value.name, name_l ,name_t , name_r, name_b, tocolor ( r, g, b, alpha ), 1, font2, "left", "top", true, true, true )
            else
                dxDrawText( value.name, name_l ,name_t , name_r, name_b, tocolor( 255, 255, 255, alpha ), 1, font2, "left", "top", true, true, true )
            end

            --draw noti
            dxDrawText( value.noti, name_l, name_t+h-y-5 , name_r, name_b, tocolor( 255, 255, 255, alpha ), 1, font, "left", "top", false, false, true )


            -- draw removal 'X'
            local str = "X"
            local strwidth = 8

            local inBox = isInBox( cursorX, cursorY, w - strwidth, w, y, y + 11 )
            dxDrawText( str, w - strwidth, y, w, y + 14, inBox and tocolor( 255, 0, 0, alpha ) or tocolor( 255, 255, 255, alpha ), 0.8, "default-bold", "right", "top", true, false, true )
            if inBox and justClicked then
                table.remove(items,key)
                break
            end

            shadow = shadow-1
            local char_ox = margin
            local char_oy = margin
            local one_line = dxGetFontHeight(1, "default")
            local char_l = x+margin
            local char_t = h-one_line*2
            local char_r = char_l+avatar_size-margin
            local char_b = char_t+one_line*2

            -- draw offline counter/playing as
            local text = ""
            if value.player and isElement(value.player) then
                text = getPlayerName( value.player ):gsub( "_", " " ) .. " (" .. getElementData( value.player, "playerid" ) .. ")"
            else
                text = value.lastOnline and ("Last online\n"..exports.datetime:formatTimeInterval( value.lastOnline )) or ''
            end
            dxDrawText( text, char_l-shadow , char_t-shadow, char_r-shadow, char_b-shadow, tocolor ( 0, 0, 0, alpha ), 1, font4, "left", "bottom", true, true, true ) -- shadow
            dxDrawText( text, char_l+shadow , char_t+shadow, char_r+shadow, char_b+shadow, tocolor ( 0, 0, 0, alpha ), 1, font4, "left", "bottom", true, true, true ) -- shadow
            dxDrawText( text, char_l+shadow , char_t-shadow, char_r+shadow, char_b-shadow, tocolor ( 0, 0, 0, alpha ), 1, font4, "left", "bottom", true, true, true ) -- shadow
            dxDrawText( text, char_l-shadow , char_t+shadow, char_r-shadow, char_b+shadow, tocolor ( 0, 0, 0, alpha ), 1, font4, "left", "bottom", true, true, true ) -- shadow
            dxDrawText( text, char_l , char_t, char_r, char_b, tocolor( 255, 255, 255, alpha ), 1, "default", "left", "bottom", true, true, true )


            -- draw message
            dxDrawText( value.message or "Hi!", name_r+margin*2, y+margin*2, w-margin*2, h-margin*2, tocolor( 255, 255, 255, alpha ), 1, "default", "left", "top", true, true, true )

            -- increase y thing
            if key % max_containers == 0 then
                justForcedNewLine = true
            else
                justForcedNewLine = false
            end

            -- Removing old noti
            items[key].time_out = items[key].time_out - 1
            if value.time_out <=0 then
                table.remove(items,key)
            elseif value.time_out < 255 then
                items[key].alpha = items[key].alpha - 5
            end
        end
    else
        removeEventHandler( "onClientRender", root, drawFriendsUpdates )
        is_showing = false
    end
    justClicked = false
end

addEventHandler( "onClientClick", root,
    function( button, state )
        if is_showing and button == "left" and state == "up" then
            justClicked = true
        end
    end
)
