local emitters = { }

function streamInEmitter()
	if (getElementType(source)=="object") and getElementParent(getElementParent(source)) == getResourceRootElement() then
		local model = getElementModel(source)
		local x, y, z = getElementPosition(source)
			
		if (model == 849) then -- small fire emitter
			emitters[source] = createFire(x, y, z, 1.8)
			setElementCollisionsEnabled(source, false)
		elseif (model == 850) then -- large fire emitter
			emitters[source] = createFire(x, y, z, 15.0)
			setElementCollisionsEnabled(source, false)
		elseif (model == 851) then -- water
			emitters[source] = fxAddWaterHydrant(x, y, z)
			setElementCollisionsEnabled(source, false)
		end
	end
end
addEventHandler("onClientElementStreamIn", getRootElement(), streamInEmitter)

function streamOutEmitter()
	if emitters[source] and isElement(emitters[source]) then
		destroyElement(emitters[source])
		emitters[source] = nil
	end
end
addEventHandler("onClientElementStreamOut", getRootElement(), streamOutEmitter)