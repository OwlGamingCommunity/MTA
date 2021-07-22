function respawnPed(ped)
	local new = createPed(getElementModel(ped), getElementPosition(ped))
	setPedRotation(new, getElementData(ped, "rotation"))
	setElementInterior(new, getElementInterior(ped))
	setElementDimension(new, getElementDimension(ped))

	for k, v in next, getAllElementData(ped) do
		exports.anticheat:changeProtectedElementDataEx(new, k, v)
	end
	exports.anticheat:changeProtectedElementDataEx(new, "activeConvo", 0)

	destroyElement(ped)
end

addEventHandler("onPedWasted", resourceRoot,
	function()
		setTimer(respawnPed, 360000, 1, source)
	end
)