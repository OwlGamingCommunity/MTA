local height = 0
local screenWidth, screenHeight = guiGetScreenSize()
local maximumBarHeight = screenHeight / 10

local function displayFancyScreenBars()
    if height < maximumBarHeight then
        height = height + maximumBarHeight / 100
    else
        height = maximumBarHeight
    end

    dxDrawRectangle(0, 0, screenWidth, height, tocolor(0, 0, 0), true)
    dxDrawRectangle(0, screenHeight - height, screenWidth, height, tocolor(0, 0, 0), true)
end

function enableCinematicScreenBars()
    addEventHandler("onClientRender", root, displayFancyScreenBars)
end

function disableCinematicScreenBars()
    removeEventHandler("onClientRender", root, displayFancyScreenBars)
end