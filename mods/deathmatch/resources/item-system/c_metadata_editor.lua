-- prefix all messages from this file with [metadata editor]
local outputDebugString = function(message, ...) _G['outputDebugString']("[metadata editor] " .. message, ...) end

local main_width, main_height = 300, 400
local editing_item -- inventory item that is to be edited
local wEditor, grid, cKey, cValue
local wEditing

local function centerUnderCursor(guiElement)
    local cursorX, cursorY = getCursorPosition()
    if not cursorX then
        exports.global:centerWindow(guiElement)
    else
        local screen_width, screen_height = guiGetScreenSize()
        local width, height = guiGetSize(guiElement, false)
        local x = cursorX * screen_width - width / 2
        local y = cursorY * screen_height - height / 2

        x = math.max(0, math.min(screen_width - width, x))
        y = math.max(0, math.min(screen_height - height, y))

        guiSetPosition(guiElement, x, y, false)
    end
end

local function closeEditingWindow()
    if wEditing then
        destroyElement(wEditing)
        wEditing = nil

        guiSetEnabled(grid, true)
        guiSetInputEnabled(false)
    end
end

function closeMetadataEditor()
    closeEditingWindow()
    guiSetInputEnabled(false)
    if wEditor then
        destroyElement(wEditor)
        wEditor = nil
    end
end
addEventHandler("account:character:select", localPlayer, closeMetadataEditor)

function openMetadataEditor(item)
    if not item then
        outputDebugString("No valid item passed", 2)
    elseif not canOpenMetadataEditor(localPlayer, item) then
        outputDebugString("Unable to edit metadata (no access or no configured metadata).")
    else
        closeMetadataEditor()
        editing_item = item
        guiSetInputEnabled(true)
        wEditor = guiCreateWindow(0, 0, main_width, main_height, "Item Properties", false)
        guiWindowSetSizable(wEditor, false)
        centerUnderCursor(wEditor)

        local bClose = guiCreateButton(10, main_height - 30, main_width, 25, "Close", false, wEditor)
        addEventHandler("onClientGUIClick", bClose, closeMetadataEditor, false)

        local lName = guiCreateLabel(8, 25, main_width - 10, 13, "Item ID: " .. tostring(item[1]) .. " (" .. tostring(g_items[item[1]][1]) .. ")", false, wEditor)
        guiSetFont(lName, "default-small")

        local lValue = guiCreateLabel(8, 37, main_width - 10, 13, "Item Value: " .. getItemValue(item[1], item[2]), false, wEditor)
        if exports.integration:isPlayerTrialAdmin(localPlayer) or exports.integration:isPlayerScripter(localPlayer) then
            guiSetText(lValue, "Item Value: " .. tostring(item[2]))
        end

        guiSetFont(lValue, "default-small")

        grid = guiCreateGridList(5, 55, main_width - 10, main_height - 90, false, wEditor)
        addEventHandler("onClientGUIDoubleClick", grid, showEditingWindow, false)
        guiGridListSetSortingEnabled(grid, false)

        cKey = guiGridListAddColumn(grid, "Key", 0.3)
        cValue = guiGridListAddColumn(grid, "Value", 0.63)

        -- show a list of all metadata values
        local editableMetadata = getEditableMetadataFor(localPlayer, item)
        for _, metadata_item in ipairs(editableMetadata) do
            local row = guiGridListAddRow(grid)
            guiGridListSetItemText(grid, row, cKey, metadata_item.name:gsub("_", " "), false, false)
            guiGridListSetItemData(grid, row, cKey, metadata_item)

            guiGridListSetItemText(grid, row, cValue, getStringForMetadataValue(item, metadata_item), false, false)
        end

        return true
    end
end

function showEditingWindow()
    local row = guiGridListGetSelectedItem(grid)
    if row == -1 then
        return
    else
        local metadata_item = guiGridListGetItemData(grid, row, cKey)
        if metadata_item.type == 'string' or metadata_item.type == 'integer' then
            local width, height = 500, 90
            local text_label = tostring(metadata_item.name):gsub("_", " ") .. ": "
            local text_width = dxGetTextWidth(text_label)

            wEditing = guiCreateWindow(0, 0, width, height, "Editing Item Property", false)
            guiWindowSetSizable(wEditing, false)
            exports.global:centerWindow(wEditing)

            local lName = guiCreateLabel(10, 33, text_width, 20, text_label, false, wEditing)

            local bClose = guiCreateButton(10, 60, width / 2 - 15, 25, "Cancel", false, wEditing)
            addEventHandler("onClientGUIClick", bClose, closeEditingWindow, false)

            local bSave = guiCreateButton(width / 2, 60, width / 2 - 10, 25, "Save", false, wEditing)
            guiSetEnabled(bSave, false)

            local eValue = guiCreateEdit(10 + text_width, 30, width - text_width - 20, 25, getStringForMetadataValue(editing_item, metadata_item), false, wEditing)
            addEventHandler("onClientGUIChanged", eValue, function()
                --- toggle the "save" button based on whether or not this is a valid value
                local value = guiGetText(eValue)
                if getStringForMetadataValue(editing_item, metadata_item) == value then
                    -- we have the same value we had initially
                    guiSetEnabled(bSave, false)
                elseif value == "" then
                    -- if saved, we remove this metadata element
                    guiSetEnabled(bSave, true)
                elseif metadata_item.type == "string" then
                    -- any string is a good string
                    guiSetEnabled(bSave, true)
                elseif metadata_item.type == "integer" then
                    -- must be an integer
                    local v = tonumber(value)
                    guiSetEnabled(bSave, v and v == math.floor(v))
                end
            end, false)

            if metadata_item.type == "string" or metadata_item.type == "integer" then
                guiEditSetMaxLength(eValue, metadata_item.max_length or 255)
            end

            local commitChanges = function()
                if not guiGetEnabled(bSave) then return end -- the "accepted" handler triggers regardless of clicking on save
                local value = guiGetText(eValue)
                local actualValue
                if value == "" then
                    actualValue = nil
                elseif metadata_item.type == "string" then
                    actualValue = value
                elseif metadata_item.type == "integer" then
                    actualValue = tonumber(value)
                else
                    return
                end

                local items = getItems(localPlayer)
                for slot, item in ipairs(items) do
                    -- figure out the actual slot by looking at the item ids.
                    if item[3] == editing_item[3] then
                        triggerServerEvent("items:metadata:update", localPlayer, localPlayer, slot, metadata_item.name, actualValue)
                        closeEditingWindow()

                        local metadata = editing_item[5] or {}
                        metadata[metadata_item.name] = actualValue
                        editing_item[5] = metadata
                        guiGridListSetItemText(grid, row, cValue, getStringForMetadataValue(editing_item, metadata_item), false, false)
                        return
                    end
                end
                outputChatBox("Unable to save, item no longer in inventory.", 255, 0, 0)
            end
            addEventHandler("onClientGUIClick", bSave, commitChanges, false)
            addEventHandler("onClientGUIAccepted", eValue, commitChanges, false) -- pressed enter in the input box

            guiSetInputEnabled(true)
            guiSetEnabled(grid, false)
        else
            outputChatBox("Editing of " .. tostring(metadata_item.name) .. " not yet supported.", 255, 0, 0)
        end
    end
    -- editing_item
end
