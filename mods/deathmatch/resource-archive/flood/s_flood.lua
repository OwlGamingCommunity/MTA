local targetLevel = 9.5
local currentLevel = 9.5
local water = nil
local riseTimer = nil
local timesToExecute = 30
local risePerMinute = 60000

addEventHandler('onResourceStart', resourceRoot,
	function()
		water = createWater(-2998, -2998, 0, 2998, -2998, 0, -2998, 2998, 0, 2998, 2998, 0)
		setWaterLevel(water, currentLevel)
		riseTimer = setTimer(riseWater, risePerMinute, timesToExecute)
	end
)

addEventHandler('onResourceStop', resourceRoot,
	function()
		destroyElement(water)
	end
)

-- Joe Unit's rising server side because FUCK clients
function riseWater()
	if currentLevel ~= targetLevel then
		currentLevel = currentLevel + 1.2
		setWaterLevel(water, currentLevel)
	else
		-- Incase theres another execution when we've already reached our target level. Might be useless but worth cancelling any remaining timers (if theres any).
		killTimer(riseTimer)
	end
end