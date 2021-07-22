-- Updated by Adams 27/01/14
local sound = false
local made = false
local gbObject = 2226
local speakerObject = 2232

blasters = { }

local function updateVolume(blaster)
    local splitValue = split(tostring(getElementData(blaster, "itemValue")), ':')
    local volume = (tonumber(splitValue[2]) or 100) / 100
    local sound = blasters[blaster] and blasters[blaster].sound
    if sound then
        -- windowstat = 1 -> windows down
        if isPedInVehicle(getLocalPlayer()) and getElementData(getPedOccupiedVehicle(localPlayer), 'vehicle:windowstat') ~= 1  then
            volume = 0.3 * volume
        end
        setSoundVolume(sound, 1.0 * volume)
    end
end

function startGB(blaster)
    if getElementData(localPlayer, "streams") == "0" then
        return
    end
    if not getElementData(blaster, "itemID") then 
        return 
    end
    local splitValue = split(tostring(getElementData(blaster, "itemValue")), ':')
    local station = tonumber(splitValue[1]) or 1
    local volume = (tonumber(splitValue[2]) or 100) / 100
    if station > 0 and volume > 0 then
        local streams = exports.carradio:getStreams()
        local x, y, z = getElementPosition(blaster)
        local int = getElementInterior(blaster)
        local dim = getElementDimension(blaster)
        local px, py, pz = getElementPosition(localPlayer)
        if #streams > 0 and isElementStreamedIn(blaster) then
            local sound = playSound3D(streams[station][2], x, y, z)
            if getElementModel(source) == speakerObject then -- larger speaker
                setSoundMaxDistance(sound, 400)
            else
                setSoundMaxDistance(sound, 60)
            end
            setElementDimension(sound, dim)
            setElementInterior(sound, int)
            attachElements ( sound, blaster )
            blasters[blaster] = { }
            blasters[blaster].sound = sound
            blasters[blaster].position = { x, y, z }
            blasters[blaster].itemValue = station

            updateVolume(blaster)
        end
    end
end

function stopGB(blaster)
    if isElement ( blaster ) and getElementType(blaster) == "object" and blasters[blaster] then
        local sound = blasters[blaster].sound
        if isElement ( sound ) then
            stopSound(sound)
        end
        blasters[blaster] = nil
    end
end

function elementStreamIn()
    if getElementModel(source) == gbObject or getElementModel(source) == speakerObject then
        startGB(source)
    end
end
addEventHandler("onClientElementStreamIn", getRootElement(), elementStreamIn)

addEventHandler("onClientElementStreamOut", getRootElement(), function ( ) stopGB ( source ) end )
addEventHandler("onClientElementDestroy", getRootElement(), function ( ) stopGB ( source ) end )

function dampenSound(theVehicle)
    if getVehicleType( theVehicle ) ~= "Automobile" then
        return
    end
    for blaster in pairs(blasters) do
        updateVolume(blaster)
    end
end
addEventHandler("onClientPlayerVehicleEnter", localPlayer, dampenSound)

function boostSound(thePlayer)
    for blaster in pairs(blasters) do
        updateVolume(blaster)
    end
end
addEventHandler("onClientPlayerVehicleExit", localPlayer, boostSound)

addEvent("toggleSound", true )
function toggleSound()
    if isElementStreamedIn(source) then
        local splitValue = split(tostring(getElementData(source, "itemValue")), ':')
        local station = tonumber(splitValue[1]) or 1

        if not blasters[source] or station ~= blasters[source].itemValue then
            stopGB(source)
            if station > 0 then
                startGB(source)
            end
        else
            local sound = blasters[source].sound
            local volume = (tonumber(splitValue[2]) or 100) / 100
            if volume == 0 then
                stopGB(source)
            else
                updateVolume(source)
            end
        end
    end
end
addEventHandler("toggleSound", root, toggleSound)

-- Shmorf // 18-8-2013
addEventHandler ( "onClientResourceStart", resourceRoot,
    function ( )
        for i,v in ipairs ( getElementsByType ( "object" ) ) do
            if getElementModel ( v ) == 2226 or getElementModel(v) == speakerObject then
                if isElementStreamedIn(v) then
                    startGB(v)
                end
            end
        end
    end )

addEventHandler ( "onClientPreRender", root,
    function ( )
        for i,v in pairs ( blasters ) do
            if not v.sound or getElementDimension ( localPlayer ) ~= getElementDimension ( v.sound ) then return end
            
            local x, y, z = getElementPosition ( v.sound )
            local px, py, pz = getElementPosition ( localPlayer )
            local distance = getDistanceBetweenPoints3D ( px, py, pz, x, y, z )
            local sx, sy = getScreenFromWorldPosition ( x, y, z + 0.7 )
            
            if sx and distance <= 10 then
                local itemValue = v.itemValue
                
                if isElement ( v.sound ) then
                    song = getSoundMetaTags ( v.sound )["stream_title"]
                end
                
                local streams = exports.carradio:getStreams()
                dxDrawText ( "#" .. itemValue .. " - " .. streams[itemValue][1], sx, sy, sx, sy, tocolor ( 255, 255, 255, 255 ), 0.85, "default-bold", "center" )
                
                if type ( song ) == "string" then
                    dxDrawText ( "Now playing: " .. song, sx, sy + 15, sx, sy, tocolor ( 255, 255, 255, 255 ), 0.85, "default-bold", "center" )
                end
            end
        end
    end )

function updateCarRadio()
    local state = getElementData(localPlayer, "streams")
    if (state == "0") then
        -- kill all ghettoblasters
        for k, v in pairs(blasters) do
            stopGB(k)
        end
    else
        -- re-populate them all
        for i,v in ipairs ( getElementsByType ( "object" ) ) do
            if getElementModel ( v ) == gbObject or getElementModel ( v ) == speakerObject then
                if isElementStreamedIn(v) then
                    startGB(v)
                end
            end
        end
    end
end
addEvent("accounts:settings:updateCarRadio", false)
addEventHandler("accounts:settings:updateCarRadio", getRootElement(), updateCarRadio)

addEvent('updateWindow', true)
addEventHandler('updateWindow', root,
    function()
        if source == getPedOccupiedVehicle(localPlayer) then
            for blaster in pairs(blasters) do
                updateVolume(blaster)
            end
        end
    end)
