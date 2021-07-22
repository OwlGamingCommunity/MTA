--    ____        __     ____  __            ____               _           __ 
--   / __ \____  / /__  / __ \/ /___ ___  __/ __ \_________    (_)__  _____/ /_
--  / /_/ / __ \/ / _ \/ /_/ / / __ `/ / / / /_/ / ___/ __ \  / / _ \/ ___/ __/
-- / _, _/ /_/ / /  __/ ____/ / /_/ / /_/ / ____/ /  / /_/ / / /  __/ /__/ /_  
--/_/ |_|\____/_/\___/_/   /_/\__,_/\__, /_/   /_/   \____/_/ /\___/\___/\__/  
--                                 /____/                /___/                 
--Client-side script: Object interaction
--Last updated 23.02.2011 by Exciter
--Copyright 2008-2011, The Roleplay Project (www.roleplayproject.com)

function getPositionFromElementOffset(element,offX,offY,offZ)
	local m = getElementMatrix ( element ) -- Get the matrix
	local x = offX * m[1][1] + offY * m[2][1] + offZ * m[3][1] + m[4][1] -- Apply transform
	local y = offX * m[1][2] + offY * m[2][2] + offZ * m[3][2] + m[4][2]
	local z = offX * m[1][3] + offY * m[2][3] + offZ * m[3][3] + m[4][3]
	return x, y, z -- Return the transformed point
end

showering = {}
function takeShower(element)
	if showering[1] then
		setElementPosition(localPlayer, showering[2][1], showering[2][2], showering[2][3])
		removeEventHandler("onClientRender", localPlayer, renderShowerWater)
		--destroyElement(showering[5]) --destroy test marker
		--showering[5] = nil
		showering[4] = nil
		setElementFrozen (localPlayer, false)
		showering[1] = false
	else
		showering[1] = true
		local px,py,pz = getElementPosition(localPlayer)
		showering[2] = {px, py, pz}
		
		local x, y, z = getPositionFromElementOffset(element, 0, 1, 1.5)

		showering[3] = {x, y, z}
		setElementPosition(localPlayer, x, y, z)
		setElementFrozen(localPlayer, true)
		showering[4] = element
		--showering[5] = createMarker(x, y, z, "cylinder", 0.5)
		addEventHandler("onClientRender", localPlayer, renderShowerWater)
	end
end
function renderShowerWater(x,y,z)
	if showering[1] then
		fxAddWaterSplash(showering[3][1], showering[3][2] - 1, showering[3][3] + 1)
	else
		removeEventHandler("onClientRender", localPlayer, renderShowerWater)
	end
end