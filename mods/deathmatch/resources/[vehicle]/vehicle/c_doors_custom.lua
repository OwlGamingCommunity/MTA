-- Special doors script by Puma
-- pretty much not like it was before ;D

local doorTypeRotation = {
    [1] = {-72, 0, 0}, -- scissor
    [2] = {-35, 0, -60} -- butterfly
}


local doorIDComponentTable = {
    [2] = "door_lf_dummy",
    [3] = "door_rf_dummy",
    [4] = "door_lr_dummy",
    [5] = "door_rr_dummy"
                        }
local vDoorType = {}

addEventHandler('onClientElementStreamIn', root, function ()
    if getElementType(source) == 'vehicle' then
        local doorType = getElementData(source, "vDoorType")
        if doorType then
            vDoorType[source] = doorType
        end
    end
end)

local function elementDataChange ( key, oldValue )
    if key == "vDoorType" and getElementType(source) == 'vehicle' then
        local t = getElementData ( source, "vDoorType" )
        if t and doorTypeRotation[t] then
            vDoorType[source] = t
        else
            vDoorType[source] = nil
            for door, dummyName in pairs(doorIDComponentTable) do
                local ratio = getVehicleDoorOpenRatio(source, door)
                setVehicleComponentRotation( source, dummyName, 0, 0, 0 )
                setVehicleDoorOpenRatio(source, door, ratio)
            end
        end
    end
end
addEventHandler ( "onClientElementDataChange", root, elementDataChange )

local function preRender ()
    for v, doorType in pairs ( vDoorType ) do
        doorType = tonumber(doorType)
        if isElement(v) and doorType and doorType > 0 then
            if isElementStreamedIn(v) then
                for door, dummyName in pairs ( doorIDComponentTable ) do
                    local ratio = getVehicleDoorOpenRatio(v, door)
                    local rx, ry, rz = unpack(doorTypeRotation[doorType])
                    local rx, ry, rz = rx*ratio, ry*ratio, rz*ratio
                    if string.find(dummyName,"rf") or string.find(dummyName,"rr") then
                        ry, rz = ry*-1, rz*-1
                    end
                    setVehicleComponentRotation ( v, dummyName, rx, ry, rz )
                end
            end
        else
            vDoorType[v] = nil
        end
    end
end
addEventHandler ( "onClientPreRender", root, preRender )
