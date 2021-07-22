-- removes all useless element data for <object>, since only the parts for <removeWorldObject> are actually used.
-- objects are fine regardless of this
local names = { 'id', 'interior', 'alpha', 'model', 'doublesided', 'scale', 'dimension', 'posX', 'posY', 'posZ', 'rotX', 'rotY', 'rotZ' }
addEventHandler('onResourceStart', resourceRoot,
	function()
		setTimer( startCleanupFunction, 15000, 1) -- Delay the function 15s
	end)

function startCleanupFunction()
	for k, v in ipairs(getElementsByType('object'), resourceRoot) do
		if getElementParent(getElementParent(v)) == getResourceRootElement(getResourceFromName("maps")) then
			for _, name in ipairs(names) do
				removeElementData(v, name)
			end

			setElementData(v, 'breakable', getElementData(v, 'breakable') == 'true')

			local collisions = getElementData(v, 'collisions')
			if collisions == 'false' then -- If the collisions is set to "false"
				setElementCollisionsEnabled(v, false)
			else --otherwise set collisions to true
				--setElementData(v, 'collisions', 'true')
				setElementCollisionsEnabled(v, true)
			end
		else
			--outputDebugString("no")
		end
	end
end