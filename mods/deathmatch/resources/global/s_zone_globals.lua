--MAXIME
gezn = getElementZoneName

function getElementZoneName( theElement, interiorsFound )
	if not interiorsFound then interiorsFound = {} end
	local text = "Unknown Area"
	if not theElement or not isElement(theElement) then
		return text
	end

	local int = getElementInterior(theElement)
	local dim = getElementDimension(theElement)

	if int == 0 and dim == 0 then
		if getElementType(theElement) == "interior" then
			text = getElementData(theElement, "name")..", "..gezn( theElement )..", "..gezn( theElement, true )
		else
			text = gezn( theElement )..", "..gezn( theElement, true )
		end
	else
		local dimension, entrance, exit, interiorType, interiorElement = exports.interior_system:findProperty( theElement )
		if interiorElement and not interiorsFound[dimension] then
			interiorsFound[dimension] = true
			return getElementZoneName ( interiorElement, interiorsFound )
		else
			return "Unknown Area"
		end
	end
	return text
end
