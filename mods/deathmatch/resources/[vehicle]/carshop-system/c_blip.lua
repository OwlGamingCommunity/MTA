local thisResourceElement = getResourceRootElement(getThisResource())
function loadBlips()
	for i = 1, #shops do
		local blip = shops[i].blippoint
		createBlip(blip[1], blip[2], blip[3], 56, 2, 0, 255, 0, 255, 0, 300)
	end
end
addEventHandler("onClientResourceStart", thisResourceElement, loadBlips)

