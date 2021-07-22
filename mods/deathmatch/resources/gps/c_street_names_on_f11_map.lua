-- DEBUG = true

---

local screenWidth, screenHeight = guiGetScreenSize()
local street_names_collapsed = true

-- while this would be nice as a GUI, it can't really be done since MTA hides all GUI elements while the map is active.
local expand_text = "Streets »"
local collapse_text = "Close"
local toggle_button_x = 0
local toggle_button_y = 20
local toggle_button_height = 30
local sidebar_width = 0
local sidebar_row_height = 20
local max_rows_on_screen = math.ceil( screenHeight / sidebar_row_height )
local scroll_position = 0

local text_color = tocolor( 255, 255, 255, 255 )
local tooltip_background_color = tocolor( 0, 0, 0, 190 )
local background_color = tocolor( 0, 0, 0, 70 )

local filtered_street_names = nil
local old_filter_position = { 0, 0, 0, 0 }

local active_street_color = tocolor( 255, 255, 0, 255 )

-- map position -> 2d world position
-- screen position minX, minY is GTA units [-3000, -3000]
-- screen position maxX, maxX is GTA units [3000, 3000]
local function getWorldPositionFromMapPosition(cursorX, cursorY)
    local minX, minY, maxX, maxY = getPlayerMapBoundingBox()

    -- is our mouse over the actual map?
    if cursorX < minX or cursorX > maxX or cursorY < minY or cursorY > maxY then
        return false
    end

    local worldX = ( cursorX - minX ) / ( maxX - minX ) *  6000 - 3000
    local worldY = ( cursorY - minY ) / ( maxY - minY ) * -6000 + 3000

    return worldX, worldY
end

-- 2d world position -> map position
local function getMapPositionFromWorldPosition(worldX, worldY)
    local minX, minY, maxX, maxY = getPlayerMapBoundingBox()
    if not minX then
        return -1, -1
    end

    local mapX = ( worldX + 3000 ) /  6000 * ( maxX - minX ) + minX
    local mapY = ( worldY - 3000 ) / -6000 * ( maxY - minY ) + minY

    return mapX, mapY
end

local function formatNodeInfo(node)
    local node_info = ''
    for k, v in pairs(node) do
        node_info = node_info .. "\n" .. k .. ": "
        if k == "nodes" then
            node_info = node_info .. tostring(#v)
        else
            node_info = node_info .. (type(v) == 'table' and toJSON(v) or tostring(v))
        end
    end
    return node_info
end

local function drawStreet(nodes, color)
    -- let's draw the street
    for _, localNodes in ipairs(nodes) do
        local last
        for _, v in ipairs(localNodes) do
            local positionOnScreen = { getMapPositionFromWorldPosition(v.x, v.y) }
            if last ~= nil then
                dxDrawLine(positionOnScreen[1], positionOnScreen[2], last[1], last[2], color, 3)
            end
            last = positionOnScreen
        end
    end
end

local function isStreetOnScreen(nodes)
    for _, localNodes in ipairs(nodes) do
        for _, v in ipairs(localNodes) do
            for _, v2 in ipairs(v) do
                local x, y = getMapPositionFromWorldPosition(v2.x, v2.y)
                if x >= 0 and x < screenWidth and y >= 0 and y < screenHeight then
                    return true
                end
            end
        end
    end
    return false
end

local function wrongBoundingBox(...)
    local new = {...}
    for i = 1, 4 do
        if old_filter_position[i] ~= new[i] then
            old_filter_position = new
            return true
        end
    end
    return false
end

local function filterStreetNames()
    local minX, minY, maxX, maxY = getPlayerMapBoundingBox()
    if not minX or not minY or not maxX or not maxY then
        if filtered_street_names ~= street_name_info then
            outputDebugString("cleared gps filter")
            filtered_street_names = street_name_info
            scroll_position = 0
        end
    elseif filtered_street_names == nil or wrongBoundingBox(minX, minY, maxX, maxY) then
        filtered_street_names = {}
        outputDebugString("rebuild gps filter")
        for k, v in ipairs(street_name_info) do
            if isStreetOnScreen(v.nodes) then
                table.insert(filtered_street_names, v)
            end
        end

        -- scroll to the end if we're beyond the end
        scroll_position = math.min( scroll_position, math.max(#(filtered_street_names or street_name_info) - max_rows_on_screen + 1, 0 ) )
    end
end

local function renderStreets()
    if isPlayerMapVisible() then -- if the console or some mta windows are shown, this might actually be not the true despite the radar technically being toggled
        local tickCount = DEBUG and getTickCount() or nil
        filterStreetNames()

        local cursorRelativeX, cursorRelativeY = getCursorPosition()
        if street_names_collapsed or not cursorRelativeX then
            -- draw the expand icon
            local width = dxGetTextWidth( expand_text, 1, 'clear' ) + 10
            dxDrawRectangle( toggle_button_x, toggle_button_y, width, toggle_button_height, background_color, true )
            dxDrawText(expand_text, toggle_button_x, toggle_button_y, toggle_button_x + width, toggle_button_y + toggle_button_height, text_color, 1, "clear", "center", "center", false, false, true)
        else
            local cursorX, cursorY = cursorRelativeX * screenWidth, cursorRelativeY * screenHeight

            -- draw the close button
            local width = dxGetTextWidth( collapse_text, 1, 'clear' ) + 10
            dxDrawRectangle(sidebar_width + toggle_button_x, toggle_button_y, width, toggle_button_height, background_color, true)
            dxDrawText(collapse_text, sidebar_width + toggle_button_x, toggle_button_y, sidebar_width + toggle_button_x + width, toggle_button_y + toggle_button_height, text_color, 1, "clear", "center", "center", false, false, true)

            -- draw the sidebar
            dxDrawRectangle( 0, 0, sidebar_width, screenHeight, background_color, true )

            local hover_position = math.floor(cursorY / sidebar_row_height) + 1
            for i = 1, math.min( 1 + max_rows_on_screen, #filtered_street_names - scroll_position ) do
                local info = filtered_street_names[i+scroll_position]
                if info then
                    -- are we hovering over this entry?
                    if i == hover_position and cursorX <= sidebar_width then
                        dxDrawRectangle(0, (i-1) * sidebar_row_height, sidebar_width, sidebar_row_height, tooltip_background_color, true)
                        for _, nodes in ipairs(info.nodes) do
                            drawStreet(nodes, active_street_color)
                        end
                    end

                    dxDrawText(info.name, 5, (i-1) * sidebar_row_height, sidebar_width, i * sidebar_row_height, text_color, 1, "clear", "left", "center", true, false, true)
                end
            end
        end

        -- is the cursor showing?
        if cursorRelativeX and cursorRelativeY then
            local cursorX, cursorY = cursorRelativeX * screenWidth, cursorRelativeY * screenHeight
            -- not over the sidebar?
            if cursorX > sidebar_width or street_names_collapsed then
                -- calculate the relative position within the map based on the coordinates
                local worldX, worldY = getWorldPositionFromMapPosition(cursorX, cursorY)
                if not worldX then return end

                local node = findNodeClosestToPoint(vehicleNodes, worldX, worldY, 10)

                if node and node.streetname then
                    local width = dxGetTextWidth( node.streetname, 1, 'clear' ) + 10
                    dxDrawRectangle( cursorX, cursorY, width, 30, tooltip_background_color, true )
                    dxDrawText( node.streetname, cursorX, cursorY, cursorX + width, cursorY + 30, text_color, 1, "clear", "center", "center", false, false, true )

                    for _, nodes in ipairs(node.nodes or {}) do
                        drawStreet(nodes, active_street_color)
                    end
                end


                if DEBUG then
                    local timeTaken = getTickCount() - tickCount
                    dxDrawText(
                        'world pos: ' .. string.format("%.1f %.1f", worldX, worldY) .. "\n" ..
                        'map pos: ' .. string.format("%.1f %.1f", cursorX, cursorY) .. "\n" ..
                        'render time: ' .. timeTaken .. 'ms' .. "\n" ..
                        formatNodeInfo(node),
                        0, 0, cursorX, cursorY, text_color, 1, 'default', 'right', 'bottom', false, false, false, false, true)
                end
            end
        end
    end
end

local function toggleStreetNamesList(button, state, cursorX, cursorY)
    if button == "left" and state == "down" and isPlayerMapVisible() then
        if street_names_collapsed then
            local width = dxGetTextWidth( expand_text, 1, 'clear' ) + 10
            if cursorX >= toggle_button_x and cursorX <= toggle_button_x + width and cursorY > toggle_button_y and cursorY < toggle_button_y + toggle_button_height then
                street_names_collapsed = false
            end
        else
            local width = dxGetTextWidth( expand_text, 1, 'clear' ) + 10
            if cursorX >= sidebar_width + toggle_button_x and cursorX <= sidebar_width + toggle_button_x + width and cursorY > toggle_button_y and cursorY < toggle_button_y + toggle_button_height then
                street_names_collapsed = true
            end
        end
    end
end

-- toggle the map visibility state
local function updateVisibility()
    if isPlayerMapVisible() then
        addEventHandler('onClientRender', root, renderStreets)
        addEventHandler('onClientClick', root, toggleStreetNamesList)
        street_names_collapsed = true
        scroll_position = 0
    else
        removeEventHandler('onClientRender', root, renderStreets)
        removeEventHandler('onClientClick', root, toggleStreetNamesList)
    end
end

addEventHandler('onClientResourceStart', resourceRoot, function()
    -- set the current map visibility
    if isPlayerMapVisible() then
        setTimer(updateVisibility, 200, 1)
    end

    -- pressing the key for the radar toggles the visibility, obviously
    bindKey(getKeyBoundToCommand('radar'), 'down', function()
        setTimer(updateVisibility, 50, 1)
    end)

    bindKey('mouse_wheel_up', 'down', function()
        if isPlayerMapVisible() and not street_names_collapsed then
            scroll_position = math.max( scroll_position - 5, 0 )
        end
    end)

    bindKey('mouse_wheel_down', 'down', function()
        if isPlayerMapVisible() and not street_names_collapsed then
            scroll_position = math.min( scroll_position + 5, math.max(#(filtered_street_names or street_name_info) - max_rows_on_screen + 1, 0 ) )
        end
    end)

    -- adjust the sidebar width based on the street names
    for _, info in ipairs(street_name_info) do
        sidebar_width = math.max(sidebar_width, dxGetTextWidth( info.name, 1, 'clear' ) + 10)
    end
end)
