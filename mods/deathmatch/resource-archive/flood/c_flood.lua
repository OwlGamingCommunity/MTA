--[[local targetLevel = 12.5
local duration = 7200000

local startTick
local currentLevel = 0

--[[addEventHandler('onClientResourceStart', resourceRoot,
	function()
		startTick = getTickCount()
		triggerServerEvent('onPlayerReady', resourceRoot)
	end
)

local function render()
	resetWaterColor()
	local passed = getTickCount() - startTick
	if passed >= duration then
		setWaterLevel(targetLevel)
		removeEventHandler('onClientRender', root, render)
		return
	end
	setWaterLevel(targetLevel * (passed/duration))
end
--addEventHandler('onClientRender', root, render)

addEvent('doSetWaterLevel', true)
addEventHandler('doSetWaterLevel', resourceRoot,
	function(level)
		setWaterLevel(level)
		currentLevel = level
		startTick = getTickCount() - duration*(level/targetLevel)
	end
)]]