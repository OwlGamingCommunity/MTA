--[[local Fitz = createPed(288, -2469.1640625, -2519.6396484375, 2499.8569335938)
setPedRotation(Fitz, 2)
setElementDimension(Fitz, 1526)
setElementInterior(Fitz, 2)
setElementData( Fitz, "talk", 1 )
setElementData( Fitz, "name", "Bobby Fitzgerald", false )
exports.global:applyAnimation( Fitz, "FOOD", "FF_Sit_Look", -1, true, false, true)
setElementFrozen( Fitz, true)

function doTimer(thePed)
	--setElementPosition(thePed, -2469.1640625, -2519.6396484375, 2499.8569335938)
	--setPedRotation(thePed, 2)
	exports.global:applyAnimation( thePed, "FOOD", "FF_Sit_Look", -1, true, false, true)
	--setElementFrozen( thePed, true)
	
end
setTimer(doTimer, 3000, 0, Fitz)]]