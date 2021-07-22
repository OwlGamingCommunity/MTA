local c_x, c_y, c_z = 389.3779296875, 2497.4990234375, 16.5
local oldState = getTrafficLightState()

addEventHandler('onClientPreRender', root,
	function()
		local state = getTrafficLightState()
		local nearDrag = getDistanceBetweenPoints3D(c_x, c_y, c_z, getElementPosition(localPlayer)) < 150
		if state == 9 and nearDrag then
			-- restore the real traffic light state. will be overwritten by the server soon-ish
			setTrafficLightState(oldState)
		elseif state ~= 9 and not nearDrag then
			-- this is called every so often, but not every frame - only once per traffic light state change
			setTrafficLightState(9)
			oldState = state
		end
	end)
