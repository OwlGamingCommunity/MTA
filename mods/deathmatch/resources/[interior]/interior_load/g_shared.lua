-- Defines
INTERIOR_X = 1
INTERIOR_Y = 2
INTERIOR_Z = 3
INTERIOR_INT = 4
INTERIOR_DIM = 5
INTERIOR_ANGLE = 6
INTERIOR_FEE = 7

INTERIOR_TYPE = 1
INTERIOR_DISABLED = 2
INTERIOR_LOCKED = 3
INTERIOR_OWNER = 4
INTERIOR_COST = 5
INTERIOR_SUPPLIES = 6
INTERIOR_FACTION = 7


function canEnterInterior(theInterior)
	local interiorID = getElementData(theInterior, "dbid")
	if interiorID then
		local interiorStatus = getElementData(theInterior, "status")
		if interiorStatus.disabled then
			return false, 1, "This interior is currently disabled."
		elseif interiorStatus.locked then
			return false, 2, "You try to move the door handle, but you notice that the door is locked."
		end
		return true
	end
	return false, 3, "Script error 100.4"
end

function isInteriorForSale( theInterior )
	local interiorStatus = getElementData(theInterior, "status") 
	if not interiorStatus then
		return false
	end
	
	if interiorStatus.type ~= 2 then
		if interiorStatus.owner <= 0 and interiorStatus.faction <= 0 then
			if interiorStatus.locked then
				if not interiorStatus.disabled then
					return true
				end
			end
		end
	end		
	return false
end
