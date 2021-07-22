--[[--------------------------------------------------
	GUI Editor
	client
	snapping.lua
	
	manages element snapping while being moved/resized
--]]--------------------------------------------------


Snapping = {
	active = Settings.default.snapping.value,
	precision = Settings.default.snapping_precision.value,
	offset = Settings.default.snapping_recommended.value,
	influence = Settings.default.snapping_influence.value,

	colour = tocolor(unpack(gColours.secondary)),
	lineWidth = 1,	

	updateValues = 
		function()
			Snapping.active = Settings.loaded.snapping.value
			Snapping.precision = Settings.loaded.snapping_precision.value
			Snapping.offset = Settings.loaded.snapping_recommended.value
			Snapping.influence = Settings.loaded.snapping_influence.value		
		end,
		
	lines = {
		cache = {},
		add = function(sX, sY, eX, eY)
			Snapping.lines.cache[#Snapping.lines.cache + 1] = {sX = sX, sY = sY, eX = eX, eY = eY}
		end,
		clear = function()
			if #Snapping.lines.cache > 0 then
				Snapping.lines.cache = {}
			end
		end			
	}
}


addEventHandler("onClientRender", root,
	function()
		if not gEnabled then
			return
		end
	
		for i,line in ipairs(Snapping.lines.cache) do
			dxDrawLine(line.sX, line.sY, line.eX, line.eY, Snapping.colour, Snapping.lineWidth, true)
		end
	end,
true, gEventPriorities.snappingRender)


function Snapping.snap()
	if Snapping.active and (Mover.active() or Sizer.active()) and not getKeyState("lalt") then
		Snapping.lines.clear()
		
		local tbl = {}
		local lookup = {}
		local siblingLookup = {}

		if Mover.active() then
			if #Mover.items > 1 then
				local l, r, t, b = 99999, -99999, 99999, -99999
				
				for _, item in ipairs(Mover.items) do
					local itemX, itemY = guiGetPosition(item.element, false)
					local itemW, itemH = guiGetSize(item.element, false)
					
					l = math.min(l, itemX)
					t = math.min(t, itemY)				
					r = math.max(r, itemX + itemW)
					b = math.max(b, itemY + itemH)
					
					lookup[item.element] = true
				end
				
				if not exists(Snapping.multiMoveGhost) then
					local parent = guiGetParent(Mover.items[1].element)
					
					if parent == nil then
						parent = false
					end
					
					Snapping.multiMoveGhost = guiCreateLabel(l, t, r - l, b - t, "", parent)
					setElementData(Snapping.multiMoveGhost, "guieditor:drawBorder", true)
				else
					guiSetPosition(Snapping.multiMoveGhost, l, t, false)
					guiSetSize(Snapping.multiMoveGhost, r - l, b - t, false)
				end
				
				tbl = {{element = Snapping.multiMoveGhost, isGhost = true}}
			else
				tbl = Mover.items
			end
		elseif Sizer.active() then
			tbl = Sizer.items
		end
		
		for _, item in ipairs(tbl) do
			lookup[item.element] = true
		end
		
		for _,item in ipairs(tbl) do
			local eX, eY = guiGetPosition(item.element, false)
			local eW, eH = guiGetSize(item.element, false)
				
			--local x, y = eX, eY
			--local w, h = eW, eH
			local parent = guiGetParent(item.element)
				
			--[[--------------------------------------------------
				05/mar/13 - reworked snapping, this is no longer needed (still a bug though)
				
				-1 when negative to account for an mta bug
				
				negative coords are returned by guiGetPosition as +1 from what they are set as in guiSetPosition
				ie: guiSetPosition(e, -10, -10, false) gives -9, -9 from guiGetPosition(e, false)
			--]]--------------------------------------------------
			--[[
			if x < 0 then
				x = x - 1
			end
				
			if y < 0 then
				y = y - 1
			end		
			]]
			-- get all other gui elements on the same 'plane' as this one
			local siblings
			local distances = {}
			
			-- cache our sibling lookup (because it takes ages) and re-use for other elements on the same plane
			for _,set in ipairs(siblingLookup) do
				if table.find(set, item.element) then
					siblings = set
				end
			end
			
			if not siblings then
				siblings = guiGetSiblings(item.element)	
				siblingLookup[#siblingLookup + 1] = siblings
			end
				
			for _,sibling in ipairs(siblings) do
				if not lookup[sibling] then
					distances[sibling] = Snapping.getDistance(item.element, sibling)
				end
			end				
				
			table.sort(siblings, 
				function(a, b) 
					if item.element == a then 
						return false 
					end 
					
					if not distances[a] and not distances[b] then
						return false
					elseif distances[a] and not distances[b] then
						return true
					elseif distances[b] and not distances[a] then
						return false
					end
					
					return distances[a] < distances[b]
				end
			)
				
			-- try to sensibly limit how many elements we can snap with at once
			local breakpoint = (#siblings > 2 and ( 2 + math.floor((#siblings * 0.2) + 0.5)) or #siblings)
				
			local l, r, t, b	
				
			for i,sibling in ipairs(siblings) do
				-- don't snap to other things that are being moved/resized
				if not lookup[sibling] then
					if i > breakpoint then
						break
					end
						
					if distances[sibling] > (Snapping.influence * Snapping.influence) then
						break
					end
						
					-- check for snaps against the sibling
					if sibling ~= item.element and relevant(sibling) then
						local sX, sY = guiGetPosition(sibling, false)
						local sW, sH = guiGetSize(sibling, false)

						l, r, t, b = Snapping.calculateSnaps(l, r, t, b, eX, eY, eW, eH, sX, sY, sW, sH, nil, parent)
						l, r, t, b = Snapping.calculateSnaps(l, r, t, b, eX, eY, eW, eH, sX, sY, sW, sH, Snapping.offset, parent)
						l, r, t, b = Snapping.calculateSnaps(l, r, t, b, eX, eY, eW, eH, sX, sY, sW, sH, -Snapping.offset, parent)
					end
				end
			end
				
			-- check for snaps against the inside of the parent
			-- parent overrides sibling
			local pW, pH = gScreen.x, gScreen.y

			if parent then
				pW, pH = guiGetSize(parent, false)
			end
				
			l, r, t, b = Snapping.calculateSnaps(l, r, t, b, eX, eY, eW, eH, 0, 0, pW, pH, nil, parent)
			l, r, t, b = Snapping.calculateSnaps(l, r, t, b, eX, eY, eW, eH, 0, 0, pW, pH, -Snapping.offset, parent)				
			
			local x, y = 0, 0
			
			if Mover.active() then
				if (l and r) then
					x = math.abs(l) < math.abs(r) and l or r
				elseif (l and not r) then
					x = l
				elseif (r and not l) then
					x = r
				end
				
				x = x * -1
				
				if (t and b) then
					y = math.abs(t) < math.abs(b) and t or b
				elseif (t and not b) then
					y = t
				elseif (b and not t) then
					y = b
				end
							
				y = y * -1
				
				--outputDebug(string.format("Move: %s, %s [l:%s, r:%s, t:%s, b:%s]", tostring(x), tostring(y), tostring(l), tostring(t), tostring(r), tostring(b)))
				
				guiSetPosition(item.element, eX + x, eY + y, false)
				
				-- this is just the multi move ghost, so apply the actual snaps to the real elements within it
				if item.isGhost then
					for _, mItem in ipairs(Mover.items) do
						local itemX, itemY = guiGetPosition(mItem.element, false)

						guiSetPosition(mItem.element, itemX + x, itemY + y, false)
					end
				end
			elseif Sizer.active() then
				if r then
					x = r * -1
				end
				
				if b then
					y = b * -1
				end
				
				--outputDebug(string.format("Size: %s, %s [l:%s, r:%s, t:%s, b:%s]", tostring(x), tostring(y), tostring(l), tostring(t), tostring(r), tostring(b)))
				
				guiSetSize(item.element, eW + x, eH + y, false)
			end
		end
	else
		Snapping.lines.clear()
		
		if exists(Snapping.multiMoveGhost) then
			destroyElement(Snapping.multiMoveGhost)
			Snapping.multiMoveGhost = nil
		end
	end
end



function Snapping.calculateSnaps(l, r, t, b, eX, eY, eW, eH, sX, sY, sW, sH, offset, parent)
	local originals = {sX = sX, sY = sY, sW = sW, sH = sH, sW2 = sW / 2, sH2 = sH / 2}
	
	-- expand/contract the sibling element according to the offset parameter
	-- this way we check 3 different states: +offset, normal, -offset
	-- this tells us any potential snaps
	if offset then
		sW = sW + (offset * 2)
		sH = sH + (offset * 2)
		sX = sX - offset
		sY = sY - offset
	end
	
	local sH2, sW2 = originals.sH / 2, originals.sW / 2
	local eH2, eW2 = eH / 2, eW / 2
	
	local pX, pY = 0, 0
	if parent then
		pX, pY = guiGetAbsolutePosition(parent)
	end
	
	-- sibling / item
						
	-- left / left
	if math.abs(eX - sX) <= Snapping.precision then
		if (not l) or (math.abs(eX - sX) < math.abs(l)) then
			l = eX - sX
		end
		
		if offset then			
			Snapping.lines.add(pX + originals.sX, pY + math.min(eY + eH2, originals.sY + originals.sH2), pX + originals.sX, pY + math.max(eY + eH2, originals.sY + originals.sH2))
			Snapping.lines.add(pX + originals.sX, pY + eY + eH2, pX + sX, pY + eY + eH2)
		else
			Snapping.lines.add(pX + sX, pY + math.min(eY + eH2, sY + sH2), pX + sX, pY + math.max(eY + eH2, sY + sH2))
			
		end
	end
	
	-- left / right
	if math.abs((eX + eW) - sX) <= Snapping.precision then
		if (not r) or (math.abs((eX + eW) - sX) < math.abs(r)) then
			r = (eX + eW) - sX
		end
		
		if offset then			
			Snapping.lines.add(pX + originals.sX, pY + math.min(eY + eH2, originals.sY + originals.sH2), pX + originals.sX, pY + math.max(eY + eH2, originals.sY + originals.sH2))
			Snapping.lines.add(pX + originals.sX, pY + eY + eH2, pX + sX, pY + eY + eH2)
		else
			Snapping.lines.add(pX + sX, pY + math.min(eY + eH2, sY + sH2), pX + sX, pY + math.max(eY + eH2, sY + sH2))
		end	
	end
	
	-- right / right
	if math.abs((eX + eW) - (sX + sW)) <= Snapping.precision then
		if (not r) or (math.abs((eX + eW) - (sX + sW)) < math.abs(r)) then
			r = (eX + eW) - (sX + sW)
		end
		
		if offset then			
			Snapping.lines.add(pX + originals.sX + originals.sW, pY + math.min(eY + eH2, originals.sY + originals.sH2), pX + originals.sX + originals.sW, pY + math.max(eY + eH2, originals.sY + originals.sH2))
			Snapping.lines.add(pX + originals.sX + originals.sW, pY + eY + eH2, pX + sX + sW, pY + eY + eH2)
		else
			Snapping.lines.add(pX + sX + sW, pY + math.min(eY + eH2, sY + sH2), pX + sX + sW, pY + math.max(eY + eH2, sY + sH2))
		end		
	end
	
	-- right / left
	if math.abs(eX - (sX + sW)) <= Snapping.precision then
		if (not l) or (math.abs(eX - (sX + sW)) < math.abs(l)) then
			l = eX - (sX + sW)
		end
		
		if offset then			
			Snapping.lines.add(pX + originals.sX + originals.sW, pY + math.min(eY + eH2, originals.sY + originals.sH2), pX + originals.sX + originals.sW, pY + math.max(eY + eH2, originals.sY + originals.sH2))
			Snapping.lines.add(pX + originals.sX + originals.sW, pY + eY + eH2, pX + sX + sW, pY + eY + eH2)
		else
			Snapping.lines.add(pX + sX + sW, pY + math.min(eY + eH2, sY + sH2), pX + sX + sW, pY + math.max(eY + eH2, sY + sH2))
		end	
	end

	-- top / top
	if math.abs(eY - sY) <= Snapping.precision then
		if (not t) or (math.abs(eY - sY) < math.abs(t)) then
			t = eY - sY
		end
		
		if offset then			
			Snapping.lines.add(pX + math.min(eX + eW2, originals.sX + originals.sW2), pY + originals.sY, pX + math.max(eX + eW2, originals.sX + originals.sW2), pY + originals.sY)
			Snapping.lines.add(pX + eX + eW2, pY + originals.sY, pX + eX + eW2, pY + sY)
		else
			Snapping.lines.add(pX + math.min(eX + eW2, sX + sW2), pY + sY, pX + math.max(eX + eW2, sX + sW2), pY + sY)
		end		
	end
	
	-- top / bottom
	if math.abs((eY + eH) - sY) <= Snapping.precision then
		if (not b) or (math.abs((eY + eH) - sY) < math.abs(b)) then
			b = (eY + eH) - sY
		end
		
		if offset then			
			Snapping.lines.add(pX + math.min(eX + eW2, originals.sX + originals.sW2), pY + originals.sY, pX + math.max(eX + eW2, originals.sX + originals.sW2), pY + originals.sY)
			Snapping.lines.add(pX + eX + eW2, pY + originals.sY, pX + eX + eW2, pY + sY)
		else
			Snapping.lines.add(pX + math.min(eX + eW2, sX + sW2), pY + sY, pX + math.max(eX + eW2, sX + sW2), pY + sY)
		end		
	end
	
	-- bottom / bottom
	if math.abs((eY + eH) - (sY + sH)) <= Snapping.precision then
		if (not b) or (math.abs((eY + eH) - (sY + sH)) < math.abs(b)) then
			b = (eY + eH) - (sY + sH)
		end
		
		if offset then			
			Snapping.lines.add(pX + math.min(eX + eW2, originals.sX + originals.sW2), pY + originals.sY + originals.sH, pX + math.max(eX + eW2, originals.sX + originals.sW2), pY + originals.sY + originals.sH)
			Snapping.lines.add(pX + eX + eW2, pY + originals.sY + originals.sH, pX + eX + eW2, pY + sY + sH)
		else
			Snapping.lines.add(pX + math.min(eX + eW2, sX + sW2), pY + sY + sH, pX + math.max(eX + eW2, sX + sW2), pY + sY + sH)
		end		
	end
	
	-- bottom / top
	if math.abs(eY - (sY + sH)) <= Snapping.precision then
		if (not t) or (math.abs(eY - (sY + sH)) < math.abs(t)) then
			t = eY - (sY + sH)
		end
		
		if offset then			
			Snapping.lines.add(pX + math.min(eX + eW2, originals.sX + originals.sW2), pY + originals.sY + originals.sH, pX + math.max(eX + eW2, originals.sX + originals.sW2), pY + originals.sY + originals.sH)
			Snapping.lines.add(pX + eX + eW2, pY + originals.sY + originals.sH, pX + eX + eW2, pY + sY + sH)
		else
			Snapping.lines.add(pX + math.min(eX + eW2, sX + sW2), pY + sY + sH, pX + math.max(eX + eW2, sX + sW2), pY + sY + sH)
		end			
	end	

	return l, r, t, b
end


function Snapping.getDistance(a, b)
	if not exists(a) or not exists(b) then
		return 99999
	end

	local xOverlap, yOverlap = elementOverlap(a, b)
	
	if xOverlap and yOverlap then
		return 0
	else
		local aX, aY = guiGetPosition(a, false)
		local aW, aH = guiGetSize(a, false)
		
		local bX, bY = guiGetPosition(b, false)
		local bW, bH = guiGetSize(b, false)
	
		local xDist, yDist = 0, 0
		
		if yOverlap then
			--yDist = 0
		elseif aY <= bY then
			yDist = (aY + aH) - bY
		else
			yDist = (bY + bH) - aY
		end
		
		if xOverlap then
			--xDist = 0
		elseif aX <= bX then
			xDist = (aX + aW) - bX
		else
			xDist = (bX + bW) - aX
		end	
		
		return (xDist * xDist) + (yDist * yDist)
	end
end


-- superseded by the one above
function Snapping.calculateSnaps_old(x, y, eX, eY, eW, eH, sX, sY, sW, sH, offset, parent)
	local originals = {sX = sX, sY = sY, sW = sW, sH = sH, sW2 = sW / 2, sH2 = sH / 2}
	
	-- expand/contract the sibling element according to the offset parameter
	-- this way we check 3 different states: +offset, normal, -offset
	-- this tells us any potential snaps
	if offset then
		sW = sW + (offset * 2)
		sH = sH + (offset * 2)
		sX = sX - offset
		sY = sY - offset
	end
	
	local sH2, sW2 = originals.sH / 2, originals.sW / 2
	local eH2, eW2 = eH / 2, eW / 2
	local snap = false

	local pX, pY = 0, 0
	if parent then
		pX, pY = guiGetAbsolutePosition(parent)
	end
	
	-- sibling / item
						
	-- left / left
	if math.abs(eX - sX) <= Snapping.precision then
		snap = true
		x = sX

		if offset then			
			dxDrawLine(pX + originals.sX, pY + math.min(eY + eH2, originals.sY + originals.sH2), pX + originals.sX, pY + math.max(eY + eH2, originals.sY + originals.sH2), Snapping.colour, Snapping.lineWidth, true)
			dxDrawLine(pX + originals.sX, pY + eY + eH2, pX + sX, pY + eY + eH2, Snapping.colour, Snapping.lineWidth, true)
		else
			dxDrawLine(pX + sX, pY + math.min(eY + eH2, sY + sH2), pX + sX, pY + math.max(eY + eH2, sY + sH2), Snapping.colour, Snapping.lineWidth, true)
		end
	-- left / right
	elseif math.abs((eX + eW) - sX) <= Snapping.precision then
		snap = true
		x = sX - eW
		
		if offset then			
			dxDrawLine(pX + originals.sX, pY + math.min(eY + eH2, originals.sY + originals.sH2), pX + originals.sX, pY + math.max(eY + eH2, originals.sY + originals.sH2), Snapping.colour, Snapping.lineWidth, true)
			dxDrawLine(pX + originals.sX, pY + eY + eH2, pX + sX, pY + eY + eH2, Snapping.colour, Snapping.lineWidth, true)
		else
			dxDrawLine(pX + sX, pY + math.min(eY + eH2, sY + sH2), pX + sX, pY + math.max(eY + eH2, sY + sH2), Snapping.colour, Snapping.lineWidth, true)
		end	
	-- right / right
	elseif math.abs((eX + eW) - (sX + sW)) <= Snapping.precision then
		snap = true
		x = sX + sW - eW
		
		if offset then			
			dxDrawLine(pX + originals.sX + originals.sW, pY + math.min(eY + eH2, originals.sY + originals.sH2), pX + originals.sX + originals.sW, pY + math.max(eY + eH2, originals.sY + originals.sH2), Snapping.colour, Snapping.lineWidth, true)
			dxDrawLine(pX + originals.sX + originals.sW, pY + eY + eH2, pX + sX + sW, pY + eY + eH2, Snapping.colour, Snapping.lineWidth, true)
		else
			dxDrawLine(pX + sX + sW, pY + math.min(eY + eH2, sY + sH2), pX + sX + sW, pY + math.max(eY + eH2, sY + sH2), Snapping.colour, Snapping.lineWidth, true)
		end		
	-- right / left
	elseif math.abs(eX - (sX + sW)) <= Snapping.precision then
		snap = true
		x = sX + sW
		
		if offset then			
			dxDrawLine(pX + originals.sX + originals.sW, pY + math.min(eY + eH2, originals.sY + originals.sH2), pX + originals.sX + originals.sW, pY + math.max(eY + eH2, originals.sY + originals.sH2), Snapping.colour, Snapping.lineWidth, true)
			dxDrawLine(pX + originals.sX + originals.sW, pY + eY + eH2, pX + sX + sW, pY + eY + eH2, Snapping.colour, Snapping.lineWidth, true)
		else
			dxDrawLine(pX + sX + sW, pY + math.min(eY + eH2, sY + sH2), pX + sX + sW, pY + math.max(eY + eH2, sY + sH2), Snapping.colour, Snapping.lineWidth, true)
		end	
	end

	-- top / top
	if math.abs(eY - sY) <= Snapping.precision then
		snap = true
		y = sY
		
		if offset then			
			dxDrawLine(pX + math.min(eX + eW2, originals.sX + originals.sW2), pY + originals.sY, pX + math.max(eX + eW2, originals.sX + originals.sW2), pY + originals.sY, Snapping.colour, Snapping.lineWidth, true)
			dxDrawLine(pX + eX + eW2, pY + originals.sY, pX + eX + eW2, pY + sY, Snapping.colour, Snapping.lineWidth, true)
		else
			dxDrawLine(pX + math.min(eX + eW2, sX + sW2), pY + sY, pX + math.max(eX + eW2, sX + sW2), pY + sY, Snapping.colour, Snapping.lineWidth, true)
		end		
	-- top / bottom
	elseif math.abs((eY + eH) - sY) <= Snapping.precision then
		snap = true
		y = sY - eH
		
		if offset then			
			dxDrawLine(pX + math.min(eX + eW2, originals.sX + originals.sW2), pY + originals.sY, pX + math.max(eX + eW2, originals.sX + originals.sW2), pY + originals.sY, Snapping.colour, Snapping.lineWidth, true)
			dxDrawLine(pX + eX + eW2, pY + originals.sY, pX + eX + eW2, pY + sY, Snapping.colour, Snapping.lineWidth, true)
		else
			dxDrawLine(pX + math.min(eX + eW2, sX + sW2), pY + sY, pX + math.max(eX + eW2, sX + sW2), pY + sY, Snapping.colour, Snapping.lineWidth, true)
		end				
	-- bottom / bottom
	elseif math.abs((eY + eH) - (sY + sH)) <= Snapping.precision then
		snap = true
		y = sY + sH - eH
		
		if offset then			
			dxDrawLine(pX + math.min(eX + eW2, originals.sX + originals.sW2), pY + originals.sY + originals.sH, pX + math.max(eX + eW2, originals.sX + originals.sW2), pY + originals.sY + originals.sH, Snapping.colour, Snapping.lineWidth, true)
			dxDrawLine(pX + eX + eW2, pY + originals.sY + originals.sH, pX + eX + eW2, pY + sY + sH, Snapping.colour, Snapping.lineWidth, true)
		else
			dxDrawLine(pX + math.min(eX + eW2, sX + sW2), pY + sY + sH, pX + math.max(eX + eW2, sX + sW2), pY + sY + sH, Snapping.colour, Snapping.lineWidth, true)
		end				
	-- bottom / top
	elseif math.abs(eY - (sY + sH)) <= Snapping.precision then
		snap = true
		y = sY + sH
		
		if offset then			
			dxDrawLine(pX + math.min(eX + eW2, originals.sX + originals.sW2), pY + originals.sY + originals.sH, pX + math.max(eX + eW2, originals.sX + originals.sW2), pY + originals.sY + originals.sH, Snapping.colour, Snapping.lineWidth, true)
			dxDrawLine(pX + eX + eW2, pY + originals.sY + originals.sH, pX + eX + eW2, pY + sY + sH, Snapping.colour, Snapping.lineWidth, true)
		else
			dxDrawLine(pX + math.min(eX + eW2, sX + sW2), pY + sY + sH, pX + math.max(eX + eW2, sX + sW2), pY + sY + sH, Snapping.colour, Snapping.lineWidth, true)
		end			
	end	

	return x, y, w, h
end