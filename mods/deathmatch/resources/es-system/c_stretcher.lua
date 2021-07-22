function getPositionInFrontOfElement(element, vehicle, action) 
	local matrix = getElementMatrix ( element )
	local offX = 0 * matrix[1][1] + 1.3 * matrix[2][1] + 0 * matrix[3][1] + 1 * matrix[4][1]
	local offY = 0 * matrix[1][2] + 1.3 * matrix[2][2] + 0 * matrix[3][2] + 1 * matrix[4][2]
	local offZ = 0 * matrix[1][3] + 1.3 * matrix[2][3] + 0 * matrix[3][3] + 1 * matrix[4][3]
	triggerServerEvent ( "stretcher:getPositionInFrontOfElement", getLocalPlayer(), element, offX, offY, offZ, vehicle, action ) 
end
addEvent( "stretcher:getPositionInFrontOfElement", true )
addEventHandler( "stretcher:getPositionInFrontOfElement", getRootElement( ), getPositionInFrontOfElement )

