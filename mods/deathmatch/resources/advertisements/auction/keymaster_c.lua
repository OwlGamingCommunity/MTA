local KEYMASTER_POSITION = Vector3(1270, -1645, 13.5)
local KEYMASTER_ROTATION = 135
local KEYMASTER_NAME = "Keymaster Michael Lepore"

local keymasterPed = Ped(125, KEYMASTER_POSITION, KEYMASTER_ROTATION)
setElementData(keymasterPed, "name", KEYMASTER_NAME)
setElementData(keymasterPed, "nametag", KEYMASTER_NAME)

addEventHandler("onClientClick", root, function (button, state, absX, absY, wx, wy, wz, element)
    if element ~= keymasterPed then
        return
    end

    if button ~= 'right' or state ~= 'up' then
        return
    end

    triggerServerEvent("keymaster:get-available-keys", resourceRoot)
end, true)

addEvent("keymaster:create-menu", true)
addEventHandler("keymaster:create-menu", root, function (keysAvailable)
    local menu = exports.rightclick:create("Keymaster")
    showCursor(true)

    for _, auction in pairs(keysAvailable) do
        local row = exports.rightclick:addRow("Get " .. auction.vehicle_name .. " key")
        addEventHandler("onClientGUIClick", row, function (button, state)
            if button ~= 'left' or state ~= 'up' then
                return
            end

            showCursor(false)
            exports.rightclick:destroy(menu)
            triggerServerEvent("keymaster:get-key", resourceRoot, auction)
        end, false)
    end

    local cancelRow = exports.rightclick:addRow("Close")
    addEventHandler("onClientGUIClick", cancelRow, function (button, state)
        exports.rightclick:destroy(menu)
        showCursor(false)
    end, false)
end)