local notes = {}
local text_font = "default"
local max_text_width = 400 -- in pixels

local margin = 5
local oneLineHeight = dxGetFontHeight(1, text_font)

local enabled = false

function bindND()
  bindKey ( "lalt", "down", showNearbyNoteDescriptions )
  bindKey ( "lalt", "up", removeND )
  bindKey ( "ralt", "down", toggleNearbyNoteDescriptions )
end
addEventHandler ( "onClientResourceStart", resourceRoot, bindND )

function toggleNearbyNoteDescriptions()
	if enabled then
		removeND()
	else
		showNearbyNoteDescriptions()
	end
end

function removeND( key, keyState )
	if enabled then
		enabled = false
        notes = {}
		removeEventHandler ( "onClientRender", getRootElement(), showTextNote )
	end
end

local function wrapNoteItem(itemValue)
	local text = { "" }

	local splitItems = split(tostring(itemValue), ' ')
	for _, word in ipairs(splitItems) do
		local last_line = text[#text]
		if dxGetTextWidth(last_line .. word, 1, text_font) < max_text_width then
			if #last_line == 0 then
				text[#text] = word
			else
				text[#text] = last_line .. " " .. word
			end
		else
			table.insert(text, word)
		end
	end
	table.insert(text, 1, "The note reads:")
	return text
end

function showNearbyNoteDescriptions()
    if getElementData(localPlayer, "enableOverlayDescription") == "0" or getElementData(localPlayer, "enableOverlayDescriptionNote") == "0" then
        return
    end
	if not enabled then
		enabled = true
		for index, nearbyObject in ipairs( exports.global:getNearbyElements(getLocalPlayer(), "object") ) do
			if isElement(nearbyObject) then
				if (getElementData(nearbyObject, "itemID")==72) then
					local itemValue = getElementData(nearbyObject, "itemValue")
					notes[nearbyObject] = wrapNoteItem(itemValue)
				end
			end
		end
		addEventHandler("onClientRender", getRootElement(), showTextNote)
	end
end

function showTextNote()
	for theObject, note_text in pairs(notes) do
		if not isElement(theObject) then
			notes[theObject] = nil
		else
			local x,y,z = getElementPosition(theObject)
			local cx, cy, cz = getCameraMatrix()
			if getDistanceBetweenPoints3D(cx,cy,cz,x,y,z) <= 15 then
				local px,py = getScreenFromWorldPosition(x,y,z+1,0.05)
				if px and isLineOfSightClear(cx, cy, cz, x, y, z, false, false, false, true, true, false, false) then

					local lines = #note_text
					local toBeShowed = table.concat(note_text, "\n")
					local fontHeight = oneLineHeight * lines
					local fontWidth = dxGetTextWidth(toBeShowed, 1, text_font)
					px = px-(fontWidth/2)

					dxDrawRectangle(px- margin, py- margin, fontWidth+(margin *2), fontHeight+(margin *2), tocolor(0, 0, 0, 100))
					dxDrawRectangleBorder(px- margin, py- margin, fontWidth+(margin *2), fontHeight+(margin *2), 1, tocolor(255, 255, 255, 100), true)
					dxDrawText(toBeShowed, px, py, px + fontWidth, (py + fontHeight), tocolor(255, 255, 255, 255), 1, text_font, "left")
				end
			end
		end
	end
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
