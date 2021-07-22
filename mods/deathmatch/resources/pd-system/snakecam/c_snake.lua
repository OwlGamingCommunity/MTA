addEvent('snakecam:toggleClientSnakeCam', true)

local visible = false
local pickupPositions = {}
local screenX, screenY = guiGetScreenSize()
local oldX, oldY, oldZ, oldDim, oldInt = 0, 0, 3
local currentX, currentY, currentZ = 0, 0, 3
local height = math.rad ( 1 )
local rotation = 0
local lineY = -0.15
local roll, fov = 0, 110

function snakecam_toggleSnakeCam(pos, show)
    visible = show
    if visible then
        local x, y, z, dim, int, ox, oy, oz, odim, oint = unpack(pos)
        oldX, oldY, oldZ, oldDim, oldInt = ox, oy, oz, odim, oint
        currentX, currentY, currentZ = x, y, z
        setElementPosition(localPlayer, x, y, z-10)
        setElementFrozen(localPlayer, true)
        setElementInterior(localPlayer, int)
        setElementDimension(localPlayer, dim)
        snakecam_toggleMarkers(false)
        bindKey('mouse_wheel_up', 'down', snakecam_zoomSnakeCamIn)
        bindKey('mouse_wheel_down', 'down', snakecam_zoomSnakeCamOut)
        addEventHandler('onClientPreRender', root, snakecam_updateSnakeCam)
    else
        removeEventHandler('onClientPreRender', root, snakecam_updateSnakeCam)
        setCameraTarget(localPlayer)
        setElementPosition(localPlayer, oldX, oldY, oldZ)
        setElementDimension(localPlayer, oldDim)
        setElementInterior(localPlayer, oldInt)
        setElementFrozen(localPlayer, false)
        snakecam_toggleMarkers(true)
        unbindKey('mouse_wheel_up', 'down', snakecam_zoomSnakeCamIn)
        unbindKey('mouse_wheel_down', 'down', snakecam_zoomSnakeCamOut)
    end
end
addEventHandler('snakecam:toggleClientSnakeCam', root, snakecam_toggleSnakeCam)

function snakecam_toggleMarkers(visible)
    if not visible then
        for i,v in pairs(getElementsByType('pickup')) do
            local mx, my, mz  = getElementPosition(v)
            local distance = getDistanceBetweenPoints3D(currentX, currentY, currentZ, mx, my, mz)
            if distance < 2 then
                table.insert(pickupPositions, {v, mx, my, mz})
                setElementPosition(v, 0, 0, 0)
            end
        end
    else
        for i,v in pairs(pickupPositions) do
            local mx, my, mz = v[2], v[3], v[4]
            local pickup = v[1]
            setElementPosition(pickup, mx, my, mz)
            table.remove(pickupPositions, i)
        end
    end
end

function snakecam_zoomSnakeCamIn()
    if fov < 50 then return end
    fov = fov - 3
end

function snakecam_zoomSnakeCamOut()
    if fov > 109 then return end
    fov = fov + 3
end

function snakecam_updateSnakeCam()
    if getKeyState('arrow_l') and roll < 25 then
        roll = roll + 1
    end
    if getKeyState('arrow_r') and roll > -25 then
        roll = roll - 1
    end
    if getKeyState('a') then
        rotation = ( rotation + 2 )
    end
    if getKeyState('d') then
        rotation = ( rotation - 2 )
    end
    if ( rotation >= 360 ) then
        rotation = 0
    end
    local angle = math.rad ( rotation )
    local camX = ( currentX + 3 * 0.1 * math.cos ( angle ) * math.cos ( height ) )
    local camY = ( currentY + 3 * 0.1 * math.sin ( angle ) * math.cos ( height ) )
    local camZ = ( currentZ + 0.4 * 0.1 + 2 * 0.1 * math.sin ( height ) )
    local hit, hitX, hitY, hitZ = processLineOfSight ( currentX, currentY, currentZ, camX, camY, camZ, false, false, false )
    if ( hit ) then
        camX, camY, camZ = ( currentX + 0.9 * ( hitX - currentY ) ), ( currentY + 0.9 * ( hitY - currentY ) ), ( currentZ + 0.9 * ( hitZ - currentZ ) )
    end
    setCameraMatrix(camX, camY, camZ-0.7, currentX, currentY, currentZ-0.7, roll, fov)
    dxDrawImage(0, 0, screenX, screenY, 'images/scanlines.png', 0, 0, 0, tocolor(255,255,255,100))
    dxDrawImage(0, screenY * lineY, screenX, screenY * 0.1, 'images/line.png', 0, 0, 0, tocolor(255,255,255,180))
    if lineY <= 1 then
        lineY = lineY + 0.001
    elseif lineY > 1 then
        lineY = -0.15
    end
end