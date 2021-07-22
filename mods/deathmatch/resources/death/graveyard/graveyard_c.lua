--Maxime
local newTombs = tombs
local showing = false
local viewDistance = 20
local heightOffset = -1
local refreshRate = 30 -- minutes
local font = dxCreateFont ( "graveyard/tombstone.ttf" , 20 ) or false

function drawTombPlates()
	if getKeyState('lalt') then
		for i = 1, #newTombs do
			local x, y, z, int, dim = newTombs[i][1], newTombs[i][2], newTombs[i][3], newTombs[i][4], newTombs[i][5]
			local cx,cy,cz = getCameraMatrix()
			if getDistanceBetweenPoints3D(cx,cy,cz,x,y,z) <= viewDistance then --Within radius viewDistance
				local px,py,pz = getScreenFromWorldPosition(x,y,z+heightOffset,0.05)
				if px and isLineOfSightClear(cx, cy, cz, x, y, z, true, false, false, true, true, false, false) then	
					--START DRAWING
					local marg = 5

					local tombInfo = newTombs[i][6]

					local textToDraw = string.gsub(tombInfo.charactername or "Unknown", "_", " ")
					local textToDraw2 = "○ "..(tombInfo.born or "Unknown").." ○"
					local textToDraw3 = "○ "..(tombInfo.dead or "Unknown").." ○"
					local textToDraw4 = string.upper(tombInfo.tomb_text and ("'"..tombInfo.tomb_text.."'") or "'Rest In Peace'")

					local fontWidth1 = dxGetTextWidth(textToDraw, 1, font)
					local fontWidth2 = dxGetTextWidth(textToDraw2)
					local fontWidth3 = dxGetTextWidth(textToDraw3)
					local fontWidth4 = dxGetTextWidth(textToDraw4)

					local fontWidth = getLongestLine({fontWidth1, fontWidth2, fontWidth3, fontWidth4})

					local fontHeight1 = dxGetFontHeight(1, font)
					local fontHeight2 = dxGetFontHeight(1, "default-small")
					local fontHeight = fontHeight1+fontHeight2*3

					px = px - (fontWidth-marg*4)/2

					dxDrawRectangle(px-marg, py-marg, (marg*2)+fontWidth, fontHeight+(marg*2), tocolor(0, 0, 0, 50))
					dxDrawRectangleBorder(px-marg, py-marg, (marg*2)+fontWidth, fontHeight+(marg*2), 1, tocolor(255, 255, 255, 50), true)
					dxDrawText(textToDraw, px, py+marg*2, px+fontWidth, (py + fontHeight2), tocolor(255, 255, 255, 200), 1, font or "default-small", "center", "center")
					dxDrawText(textToDraw2, px, py, px+fontWidth, (py + fontHeight), tocolor(255, 255, 255, 200), 1, "default-small", "center", "center")
					dxDrawText(textToDraw3, px, py+fontHeight2*2, px+fontWidth, (py + fontHeight), tocolor(255, 255, 255, 200), 1, "default-small", "center", "center")
					dxDrawText(textToDraw4, px, py+fontHeight2*4, px+fontWidth, (py + fontHeight), tocolor(255, 255, 255, 200), 1, "default-small", "center", "center")
				end
			end
		end
	end
end

function getLongestLine(lines)
	local longest = 0
	for i, line in pairs(lines) do
		if line >= longest then
			longest = line
		end
	end
	return longest
end



function dxDrawRectangleBorder(x, y, width, height, borderWidth, color, out, postGUI)
	if out then
		--[[Left]]	dxDrawRectangle(x - borderWidth, y, borderWidth, height, color, postGUI)
		--[[Right]]	dxDrawRectangle(x + width, y, borderWidth, height, color, postGUI)
		--[[Top]]	dxDrawRectangle(x - borderWidth, y - borderWidth, width + (borderWidth * 2), borderWidth, color, postGUI)
		--[[Botm]]	dxDrawRectangle(x - borderWidth, y + height, width + (borderWidth * 2), borderWidth, color, postGUI)
	else
		local halfW = width / 2
		local halfH = height / 2
		--[[Left]]	dxDrawRectangle(x, y, math.clip(0, borderWidth, halfW), height, color, postGUI)
		--[[Right]]	dxDrawRectangle(x + width - math.clip(0, borderWidth, halfW), y, math.clip(0, borderWidth, halfW), height, color, postGUI)
		--[[Top]]	dxDrawRectangle(x + math.clip(0, borderWidth, halfW), y, width - (math.clip(0, borderWidth, halfW) * 2), math.clip(0, borderWidth, halfH), color, postGUI)
		--[[Botm]]	dxDrawRectangle(x + math.clip(0, borderWidth, halfW), y + height - math.clip(0, borderWidth, halfH), width - (math.clip(0, borderWidth, halfW) * 2), math.clip(0, borderWidth, halfH), color, postGUI)
	end
end

function receiveBuriedCharactersFromServer(buriedCharacters)
	newTombs = {}
	for i = 1, #tombs do
		if buriedCharacters[i] then
			tombs[i][6] = buriedCharacters[i]
			table.insert(newTombs, tombs[i])
		end
	end
end
addEvent("receiveBuriedCharactersFromServer", true)
addEventHandler("receiveBuriedCharactersFromServer", localPlayer, receiveBuriedCharactersFromServer) 

function togGraves(_, state)
	if state == "down" then
		addEventHandler("onClientRender", root, drawTombPlates)
	elseif state == "up" then
		removeEventHandler("onClientRender", root, drawTombPlates)
	end
end

function initiation()
	bindKey("lalt", "both", togGraves)
	triggerServerEvent("sendburiedCharactersToClient", localPlayer)
	setTimer(function()
		triggerServerEvent("sendburiedCharactersToClient", localPlayer)
	end, refreshRate*1000*60, 0)
end
addEventHandler ( "onClientResourceStart", resourceRoot, initiation )
