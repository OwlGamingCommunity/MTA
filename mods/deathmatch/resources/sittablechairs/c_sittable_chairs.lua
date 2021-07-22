local chairData =
{
	-- offset = { x, y, z }, rotation = rz, rotateable = degrees in both direction you can turn
	[1720] = { offset = { 0, 0, 1.3 }, rotation = 0 },
	[1716] = { offset = { -0.3, -0.3, 1.5 }, rotation = 270, rotateable = 360 },
	[2125] = { offset = { 0, 0, 1.3 }, rotation = 90, rotateable = 180 },
	[1671] = { offset = { 0, 0, 0.8 }, rotation = 0 },
	[1714] = { offset = { 0, 0, 1.3 }, rotation = 0 },
	[1715] = { offset = { 0, -0.2, 1.3 }, rotation = 0 },
	[1722] = { offset = { 0, 0.3, 1.35 }, rotation = 180, rotateable = 100 },
	[1721] = { offset = { 0, 0.3, 1.35 }, rotation = 180, rotateable = 0 },
	[1704] = { offset = { 0.5, -0.25, 1.4 }, rotation = 0 },
	[1727] = { offset = { 0.5, -0.25, 1.4 }, rotation = 0 },
	[1754] = { offset = { 0, -0.25, 1.4 }, rotation = 0 },
	[2350] = { offset = { 0, 0, 1.3 }, rotation = 90, rotateable = 180 },
	[1663] = { offset = { 0, 0, 0.8 }, rotation = 0 },
	[1739] = { offset = { 0, 0, 0.6 }, rotation = 270 },
	[2183] = { offset = { 0, 0, 0.8 }, rotation = 0 },
	[1806] = { offset = { 0, 0.1, 1.3 }, rotation = 180 },
	[1562] = { offset = { 0, 0, 0.6 }, rotation = 0 },
	[2120] = { offset = { 0, 0, 0.6 }, rotation = 270 },
	[2636] = { offset = { 0, 0, 0.6 }, rotation = 270 },
	[2807] = { offset = { 0, 0, 0.8 }, rotation = 270 },
	[2123] = { offset = { -0.05, 0, 0.7 }, rotation = 270 },
	[1759] = { offset = { 0.5, 0, 1.28 }, rotation = 0 },
}

local unsolidObjects = { }
local localPlayer = getLocalPlayer()
local sitting = false
local myChair = nil
local px, py, pz = nil
local chairPerson = { }

function isValidChair(obj)
	return chairData[getElementModel(obj)] and true
end

function isValidObject(obj)
	return ( obj and isElement(obj) and getElementType(obj) == "object" and isValidChair(obj) )
end

function resourceStop()
	if ( sitting ) then
		attemptToStandUp()
	end
end
addEventHandler("onClientResourceStop", getResourceRootElement(), resourceStop)

function onRemotePlayerQuit()
	for k,v in ipairs(chairPerson) do
		if ( v == source ) then
			chairPerson[k] = nil
			break
		end
	end
end
addEventHandler("onClientPlayerQuit", getRootElement(), onRemotePlayerQuit)

function csit(x, y, z)
	for k,v in ipairs(getElementsByType("object")) do
		local ox, oy, oz = getElementPosition(v)
		if ( ox == x and oy == y and oz == z ) then
			if chairData[getElementModel(v)] then
				chairPerson[v] = source
				attachElements(source, v, unpack(chairData[getElementModel(v)].offset))
				break
			end
		end
	end
end
addEvent("csit", true)
addEventHandler("csit", getRootElement(), csit)

function cstand()
	for k,v in pairs(chairPerson) do
		if ( chairPerson[k] == source ) then
			if isElement(k) then
				detachElements(source, k)
			end
			chairPerson[k] = nil
			break
		end
	end
end
addEvent("cstand", true)
addEventHandler("cstand", getRootElement(), cstand)

function resourceStart(res)
	if ( res == getThisResource() ) then
		for k,v in ipairs(getElementsByType("object")) do
			if ( unsolidObjects[getElementModel(v)] ) then
				setElementCollisionsEnabled(v, false)
			else
				setElementCollisionsEnabled(v, true)
			end
		end
	end
end
addEventHandler("onClientResourceStart", getRootElement(), resourceStart)

function useChair(chair)
	px, py, pz = getElementPosition(localPlayer)
	local x, y, z = getElementPosition(chair)
	local rx, ry, rz = getElementRotation(chair)
	local data = chairData[getElementModel(chair)]
	
	if getElementData(localPlayer, "recovery") then
		outputChatBox("You cannot sit on a chair whilst in recovery.", 255, 0, 0)
		return false
	end

	triggerServerEvent("sit", localPlayer, x, y, z, rz + data.rotation)
	sitting = true
	myChair = chair
	attachElements(localPlayer, chair, unpack(data.offset))
	call(getResourceFromName("social"), "toggleCursor")
	if data.rotateable then
		sitGUI(data.rotateable, rz + data.rotation)
	end
	
	outputChatBox("You are now sitting down on a chair. Press M then click on yourself to stand up.", 255, 195, 14)
end

function attemptToSitOnChair(chair)
	if ( canISitOnChair(chair) ) then
		if ( chairPerson[chair] ~= nil ) then
			outputChatBox("That seat is already occupied!", 255, 0, 0)
		else
			useChair(chair)
		end
	else
		outputChatBox("You are too far from that chair, get closer!", 255, 0, 0)
	end
end

addEvent("chair:selfsit", true)
addEventHandler("chair:selfsit", root,
	function( )
		useChair(source)
	end
)

function canISitOnChair(chair)
	local x, y, z = getElementPosition(localPlayer)
	local cx, cy, cz = getElementPosition(chair)
	
	return (getDistanceBetweenPoints3D(x, y, z, cx, cy, cz) < 3) and getElementAlpha(chair) == 255
end

function attemptToStandUp()
	if sitting then
		sitting = false
		myChair = nil
		triggerServerEvent("stand", localPlayer)
		detachElements(localPlayer, myChair)
		setElementPosition(localPlayer, px, py, pz)
		px, py, pz = nil
		call(getResourceFromName("social"), "toggleCursor")
		unsitGUI()
	end
end
addCommandHandler("stand", attemptToStandUp)

function clickedChair(button, state, absX, absY, wx, wy, wz, chair)
	if ( button == "right" and state == "down" ) then
		if chair == getLocalPlayer() and sitting then
			exports.rightclick:destroy()
			attemptToStandUp()
		end
		--[[ --sitting option has been moved to right-click menu
		if ( isValidObject(chair) and not sitting ) then
			exports.rightclick:destroy()
			attemptToSitOnChair(chair)
		elseif chair == getLocalPlayer() and sitting then
			exports.rightclick:destroy()
			attemptToStandUp()
		elseif not sitting then
			local camX, camY, camZ = getCameraMatrix()
			local cursorX, cursorY, endX, endY, endZ = getCursorPosition()
			
			local x = {processLineOfSight(camX, camY, camZ, endX, endY, endZ, true, true, true, true, true, true, false, true, localPlayer, true)}
			local hit, _, _, _, _, _, _, _, mat, _, _, buildingId, bx, by, bz, ba, bb, bc = unpack(x)
			
			if hit and chairData[buildingId] then
				local x, y, z = getElementPosition(getLocalPlayer())
				if (getDistanceBetweenPoints3D(x, y, z, wx, wy, wz)<=3) then
					exports.rightclick:destroy()
					triggerServerEvent("chair:allocate", localPlayer, buildingId, bx, by, bz, ba, bb, bc)
				end
			end
		end
		--]]
	end
end
addEventHandler("onClientClick", getRootElement(), clickedChair)

function onDead()
	sitting = false
	detachElements(localPlayer, myChair)
	myChair = nil
	unsitGUI()
end
addEventHandler("onClientPlayerWasted", getLocalPlayer(), onDead)

-- small GUI to change your rotation
local sitScroll = nil
local stuff, stoff
--[[
function sitGUI(rotateable, rotation)
	stuff = rotateable
	stoff = rotation - 180
	-- remove old scrollbar if any
	unsitGUI()
	
	local screenX, screenY = guiGetScreenSize( )
	sitScroll = guiCreateScrollBar( ( screenX / 2 ) - 100, screenY - 20, 200, 20, true, false )
	guiScrollBarSetScrollPosition( sitScroll, 50 )
	
	addEventHandler( "onClientGUIScroll", sitScroll,
		function( )
			local pos = ( guiScrollBarGetScrollPosition( sitScroll ) - 50 ) / 50
			setPedRotation( localPlayer, stoff + stuff * pos )
		end, false )
end

function unsitGUI()
	if sitScroll then
		destroyElement( sitScroll )
		sitScroll = nil
	end
end
]]

function sitGUI() end
function unsitGUI() end

--exported
function isSittableChair(element)
	return isValidObject(element)
end
function canSitOnChair(element)
	if not sitting then
		if canISitOnChair(element) then
			if chairPerson[element] == nil then
				return true
			end
		end
	end
	return false
end