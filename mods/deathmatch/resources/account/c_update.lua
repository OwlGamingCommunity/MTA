function update_updateElementData(theElement, theParameter, theValue)
	if (theElement) and (theParameter) then
		if (theValue == nil) then
			theValue = false
		end
		setElementData(theElement, theParameter, theValue, false)
	end
end
addEventHandler("edu", getRootElement(), update_updateElementData)