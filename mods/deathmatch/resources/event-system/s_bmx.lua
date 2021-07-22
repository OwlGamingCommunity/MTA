bmxCol = createColPolygon(
	1862.216796875, -1450.5458984375,
	1862.216796875, -1450.5458984375,
	1862.185546875, -1351.2451171875,
	1976.10546875, -1351.2451171875,
	1976.10546875, -1450.31640625
)

--[[function enterBmxCOL(thePlayer, matchingDimension)
        if getElementType ( thePlayer ) == "player" then
	        outputChatBox ("Welcome to the skatepark, type /sprules for the roleplay rules!", thePlayer, 255, 255, 255 )
        end
end
addEventHandler("onColShapeHit", bmxCol, enterBmxCOL)]]

function setBmxGravity()
	checkTimer =  setTimer(function()
		for _, player in ipairs(getElementsByType("player")) do
			local theVehicle = getPedOccupiedVehicle(player)
			if isElementWithinColShape(player, bmxCol) and theVehicle and getElementModel(theVehicle) == 481 then
				setPedGravity(player, 0.0069)
				setPedStat(player, 229, 999)
			else
				setPedGravity(player, 0.008)
				setPedStat(player, 229, 0)
			end
		end
	end, 5000, 1)
end
addEventHandler("onResourceStart", getResourceRootElement(getThisResource()), setBmxGravity)
