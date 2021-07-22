--[[
* ***********************************************************************************************************************
* Copyright (c) 2015 OwlGaming Community - All Rights Reserved
* All rights reserved. This program and the accompanying materials are private property belongs to OwlGaming Community
* Unauthorized copying of this file, via any medium is strictly prohibited
* Proprietary and confidential
* ***********************************************************************************************************************
]]

local GUIEditor = {
    label = {},
    edit = {},
    button = {},
    window = {},
    combobox = {},
    memo = {}
}

function openEditor(item)
    local item_values = exports.global:explode( ":", item[2] )
    closeEditor()
    guiSetInputEnabled(true)
    local wo = 50

    GUIEditor.window[1] = guiCreateWindow(391, 431, 280+wo, 207, "Modifying '"..(item_values[3] or "").."'", false)
    guiWindowSetSizable(GUIEditor.window[1], false)
    exports.global:centerWindow(GUIEditor.window[1])

    GUIEditor.label[1] = guiCreateLabel(16, 32, 62, 24, "Name:", false, GUIEditor.window[1])
    guiLabelSetVerticalAlign(GUIEditor.label[1], "center")

    GUIEditor.edit[1] = guiCreateEdit(78, 32, 187+wo, 24, item_values[3] or "", false, GUIEditor.window[1])
    guiEditSetMaxLength(GUIEditor.edit[1], 50)

    GUIEditor.label[2] = guiCreateLabel(16, 62, 62, 24, "Cartridge: ", false, GUIEditor.window[1])
    guiLabelSetVerticalAlign(GUIEditor.label[2], "center")

    local ammo, ammo_id = getAmmoForWeapon( tonumber(item_values[1]) )
    GUIEditor.combobox[1] = guiCreateComboBox(78, 62, 187+wo, 24, ammo and ammo.cartridge or "N/A", false, GUIEditor.window[1])
    guiSetEnabled(GUIEditor.combobox[1], false)

    GUIEditor.label[3] = guiCreateLabel(16, 92, 62, 24, "Others:", false, GUIEditor.window[1])
    guiLabelSetVerticalAlign(GUIEditor.label[3], "center")

    local serials = exports.global:retrieveWeaponDetails( item_values[2] )
    local gun_source = tonumber(serials[2])
    local buffer = ''
    if gun_source then
        buffer = buffer.."Serial: '"..item_values[2].."': \n"
        local gun_creator = tonumber(serials[3])
        local characterName = gun_creator and exports.cache:getCharacterNameFromID(gun_creator) or "Unknown"

        if gun_source == 1 then
            buffer = buffer.." - Source: Spawned by admin.\n"
            buffer = buffer.." - Spawned by: "..characterName.."\n"
        elseif gun_source == 2 then
            buffer = buffer.." - Source: Faction Duty\n"
            buffer = buffer.." - Spawned to: "..characterName.."\n"
        elseif gun_source == 3 then
            buffer = buffer.." - Source: Ammunation\n"
            buffer = buffer.." - Authorized under firearms license of: "..characterName.."\n"
        elseif gun_source == 4 then
            buffer = buffer.." - Source: Faction Drop NPC\n"
            buffer = buffer.." - Created by: "..characterName..")\n"
        else
            buffer = buffer.." - No info could be retrieved.\n"
        end
    end
    GUIEditor.memo[1] = guiCreateMemo(78, 92, 187+wo, 97, buffer, false, GUIEditor.window[1])
    guiMemoSetReadOnly(GUIEditor.memo[1], true)

    GUIEditor.button[1] = guiCreateButton(16, 121, 52, 33, "Save", false, GUIEditor.window[1])
    guiSetEnabled(GUIEditor.button[1], false)

    GUIEditor.button[2] = guiCreateButton(16, 156, 52, 33, "Close", false, GUIEditor.window[1])

    addEventHandler('onClientGUIClick', GUIEditor.window[1], function ()
        if source == GUIEditor.button[2] then
            closeEditor()
        elseif source == GUIEditor.button[1]  then
            triggerServerEvent( 'weapon:modify', resourceRoot, item[3], {[3] = guiGetText(GUIEditor.edit[1]), [5] = 1} )
            closeWeaponInteract()
        end
    end)

    addEventHandler('onClientGUIChanged', GUIEditor.window[1], function()
        if source ==  GUIEditor.edit[1] then
            local name = guiGetText( GUIEditor.edit[1])
            if string.len(name) > 0 and name ~= item_values[3] and not string.find(name, ':') then
                guiSetEnabled(GUIEditor.button[1], true)
            else
                guiSetEnabled(GUIEditor.button[1], false)
            end
        end
    end)

    addEventHandler('account:changingchar', root, closeEditor)
end

function closeEditor()
    if GUIEditor.window[1] and isElement(GUIEditor.window[1]) then
        destroyElement(GUIEditor.window[1])
        GUIEditor.window[1] = nil
        guiSetInputEnabled(false)
        removeEventHandler('account:changingchar', root, closeEditor)
    end
end
